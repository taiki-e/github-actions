#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'

g() {
  IFS=' '
  local cmd="$*"
  IFS=$'\n\t'
  printf '::group::%s\n' "${cmd#retry }"
  "$@" 2>&1
  printf '::endgroup::\n'
}
retry() {
  for i in {1..10}; do
    if "$@"; then
      return 0
    else
      "${sleep}" "${i}"
    fi
  done
  "$@"
}
bail() {
  printf '::error::%s\n' "$*"
  exit 1
}
resolve_path() {
  if [[ -x /bin/"$1" ]]; then
    printf '/bin/%s\n' "$1"
  elif [[ -x /usr/bin/"$1" ]]; then
    printf '/usr/bin/%s\n' "$1"
  else
    bail "$1 is unavailable at standard location; found $(type -P "$1")"
  fi
}
normalize_comma_or_space_separated() {
  # Normalize whitespace characters into space because it's hard to handle single input contains lines with POSIX sed alone.
  local list="${1//[$'\r\n\t']/ }"
  if [[ "${list}" == *","* ]]; then
    # If a comma is contained, consider it is a comma-separated list.
    # Drop leading and trailing whitespaces in each element.
    "${sed}" -E 's/ *, */,/g; s/^.//; s/,,$/,/' <<<",${list},"
  else
    # Otherwise, consider it is a whitespace-separated list.
    # Convert whitespace characters into comma.
    "${sed}" -E 's/ +/,/g; s/^.//' <<<" ${list} "
  fi
}

token="${INPUT_TOKEN}"
# This prevents tokens from being exposed to subprocesses via environment variables.
# Note that this does not prevent token leaks via reading `/proc/*/environ` on Linux or
# via `ps -Eww` on macOS. It only reduces the risk of leaks.
unset INPUT_TOKEN
# This prevents tokens from being exposed to log when tracing is activated.
unset GIT_TRACE_REDACT GIT_CURL_VERBOSE GIT_TRACE_CURL

sleep=$(resolve_path sleep)
sed=$(resolve_path sed)
git=$(resolve_path git)
openssl=$(resolve_path openssl)

if [[ -z "${INPUT_REF}" ]]; then
  bail "'ref' input option must not empty"
fi
refs=()
while read -rd, ref; do
  if [[ -z "${ref}" ]]; then
    bail "'ref' input option must not empty"
  fi
  refs+=("${ref}")
done < <(normalize_comma_or_space_separated "${INPUT_REF}")
if [[ ${#refs[@]} -eq 0 ]]; then
  bail "'ref' input option must not empty"
fi

repository_url="${INPUT_SERVER_URL}/${INPUT_REPOSITORY}"

# Since we currently do not support checking out other repositories, this should always be enforced.
# https://github.blog/security/application-security/improving-git-protocol-security-github/
export GIT_ALLOW_PROTOCOL=https:ssh

protocol="${INPUT_SERVER_URL%%://*}"
hostname="${INPUT_SERVER_URL#*://}"
hostname="${hostname%%/*}"
# Sanitize inputs and runner-provided environment variables for credential helper which uses line-separated format.
# Also sanitize encoded newline (%0a) and carriage return (\r, %0d) for old git affected by CVE-2020-5260/CVE-2024-52006.
for c in $'\n' '%0a' '%0A' $'\r' '%0d' '%0D'; do
  if [[ "${protocol}" == *"${c}"* ]] || [[ "${hostname}" == *"${c}"* ]] || [[ "${token}" == *"${c}"* ]]; then
    bail "github.server_url and 'token' input option must not contain newline"
  fi
done

# Prevents the leak of the token as much as possible, even in
# compromised environments (or environments that were previously compromised and only incompletely repaired).
# Ignore some configs and config overrides to prevent malicious config (e.g., malicious fsmonitor) and/or hooks.
# BASH_FUNC_*/ENV/BASH_ENV/CDPATH/SHELLOPTS/BASHOPTS/LD_*/DYLD_*/PERL* environment variables and profile/rc files, which also affect
# non-git programs are handled in action.yml.
unset GIT_DIR GIT_WORK_TREE GIT_EXEC_PATH GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
unset GIT_SSH_COMMAND GIT_SSH GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS

# They normally do nothing, and in compromised environments (or environments that were previously
# compromised and only incompletely repaired) they can lead to arbitrary code execution.
common_args=(-c core.hooksPath=/dev/null -c core.fsmonitor=false)
# hooksPath=/dev/null doesn't disable config-based hooks added in Git 2.54:
# https://github.blog/open-source/git/highlights-from-git-2-54/#h-config-based-hooks
# So, disable them individually. This is not resistant to TOCTOU attacks, but AFAIK,
# Git 2.54 unfortunately does not provide an appropriate mechanism to prevent them.
# https://git-scm.com/docs/githooks
hooks=(
  reference-transaction # ref update
  post-index-change     # index update
  pre-push              # push
)
for hook in "${hooks[@]}"; do
  # git hook list fails on old version or on no hook available.
  names=$("${git}" "${common_args[@]}" hook list "${hook}" 2>/dev/null || true)
  if [[ -n "${names}" ]]; then
    while IFS= read -r name; do
      common_args+=(-c "hook.${name}.enabled=false")
    done <<<"${names}"
  fi
done

# Disable askPass to prevent arbitrary code execution if authentication fails.
# Enforce sslVerify to ensure security of https.
unset GIT_ASKPASS GIT_SSL_NO_VERIFY
args=(
  -c core.askPass=/dev/null
  -c "http.${repository_url}.sslVerify=true"
  -c "https.${repository_url}.sslVerify=true"
)
# Block URL manipulation using proxy.
unset GIT_PROXY_COMMAND http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
args+=(
  -c "http.${repository_url}.proxy="
  -c "https.${repository_url}.proxy="
)
args+=(push --atomic)

case "${INPUT_FORCE}" in
  false) ;;
  true) args+=(--force) ;;
  *) bail "'force' input option must be 'true' or 'false': '${INPUT_FORCE}'" ;;
esac

if [[ ${#refs[@]} -eq 1 ]]; then
  ref="${refs[0]#+}"
  if [[ "${ref}" == 'refs/heads/'* ]]; then
    branch="${ref#refs/heads/}"
    if ! "${git}" "${common_args[@]}" rev-parse --verify "refs/heads/${branch}" &>/dev/null; then
      g "${git}" "${common_args[@]}" branch -- "${branch}"
    fi
  fi
fi

IFS=' '
cmd="${git} ${common_args[*]} ${args[*]} origin ${refs[*]}"
IFS=$'\n\t'
printf '::group::%s\n' "${cmd}"
# In url.*.insteadOf, global/local config is preferred over -c when URL is the same.
# (In most options, -c is preferred over global/local config when URL is the same.)
# So using a sufficiently long random value as URL placeholder and replacing it with -c option,
# to mitigate the risk of token leaks caused by compromised global/local config.
# Since there is an interval between the command being displayed in /proc/*/cmdline and
# the config being resolved, it is technically possible for a malicious url.*.insteadOf to inject
# local/global config, causing a malicious repository hosted on the same host to be checked out
# (though this is hard because we specify SHA in refspec). Anyway, thanks to credential helper's
# hostname verification, sending credentials to a malicious host should be prevented.
retry_push() {
  for i in {1..10}; do
    rand=$("${openssl}" rand -hex 64)
    if INPUT_TOKEN="${token}" \
      "$@" -c "url.${repository_url}.insteadOf=${rand}" \
      "${args[@]}" "${rand}" "${refs[@]}" 2>&1; then
      return 0
    else
      "${sleep}" "${i}"
    fi
  done
  rand=$("${openssl}" rand -hex 64)
  INPUT_TOKEN="${token}" \
    "$@" -c "url.${repository_url}.insteadOf=${rand}" \
    "${args[@]}" "${rand}" "${refs[@]}" 2>&1
}
# The first credential.helper= is needed to ignore existing credential helpers.
# shellcheck disable=SC2016
INPUT_PROTOCOL="${protocol}" \
  INPUT_HOSTNAME="${hostname}" \
  retry_push "${git}" "${common_args[@]}" \
  -c credential.helper= \
  -c 'credential.helper=!f() {
protocol=""
host=""
while IFS= read -r line; do
  case "${line}" in
    protocol=*) protocol="${line#protocol=}" ;;
    host=*) host="${line#host=}" ;;
  esac
  [ -n "${line}" ] || break
done
if [ "${protocol}" = "${INPUT_PROTOCOL}" ] && [ "${host}" = "${INPUT_HOSTNAME}" ]; then
  printf "protocol=%s\nhost=%s\nusername=x-access-token\npassword=%s\n" "${INPUT_PROTOCOL}" "${INPUT_HOSTNAME}" "${INPUT_TOKEN}"
fi
}; f'
printf '::endgroup::\n'
