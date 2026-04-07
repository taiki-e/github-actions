#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'

retry() {
  for i in {1..10}; do
    if "$@"; then
      return 0
    else
      sleep "${i}"
    fi
  done
  "$@"
}
bail() {
  printf '::error::%s\n' "$*"
  exit 1
}
normalize_comma_or_space_separated() {
  # Normalize whitespace characters into space because it's hard to handle single input contains lines with POSIX sed alone.
  local list="${1//[$'\r\n\t']/ }"
  if [[ "${list}" == *","* ]]; then
    # If a comma is contained, consider it is a comma-separated list.
    # Drop leading and trailing whitespaces in each element.
    sed -E 's/ *, */,/g; s/^.//; s/,,$/,/' <<<",${list},"
  else
    # Otherwise, consider it is a whitespace-separated list.
    # Convert whitespace characters into comma.
    sed -E 's/ +/,/g; s/^.//' <<<" ${list} "
  fi
}

args=(--atomic)
case "${INPUT_FORCE}" in
  false) ;;
  true) args=(--force) ;;
  *) bail "'force' input option must be 'true' or 'false': '${INPUT_FORCE}'" ;;
esac

separate_first="${INPUT_SEPARATE_FIRST}"
case "${separate_first}" in
  false) separate_first='' ;;
  true) ;;
  *) bail "'separate-first' input option must be 'true' or 'false': '${INPUT_SEPARATE_FIRST}'" ;;
esac

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
elif [[ ${#refs[@]} -eq 1 ]]; then
  if [[ -n "${separate_first}" ]]; then
    bail "'separate-first' input option requires multiple refs"
  fi
  ref="${refs[0]#+}"
  if [[ "${ref}" == 'refs/heads/'* ]]; then
    branch="${ref#refs/heads/}"
    if ! git branch | grep -Eq '. '"${branch}"'$'; then
      git checkout -b "${branch}"
    fi
  fi
fi

prev_credential_helper=$(git config get --local credential.helper || true)
if [[ -n "${prev_credential_helper}" ]]; then
  printf 'credential helper is already set (%s)\n' "${prev_credential_helper}"
else
  protocol="${GITHUB_SERVER_URL%%://*}"
  hostname="${GITHUB_SERVER_URL#*://}"
  (
    set -x
    git config --local credential.helper cache
  )
  git credential approve <<EOF
protocol=${protocol}
host=${hostname}
username=${GITHUB_ACTOR}
password=${GITHUB_TOKEN}
EOF
  # Remove credential helper config on exit.
  trap -- '(set -x; git credential-cache exit; git config --local --unset credential.helper || true)' EXIT
fi

if [[ -n "${separate_first}" ]]; then
  first="${refs[0]}"
  refs=("${refs[@]:1}")
  (
    set -x
    retry git push origin "${args[@]}" "${first}"
    retry git push origin "${args[@]}" "${refs[@]}"
  )
else
  (
    set -x
    retry git push origin "${args[@]}" "${refs[@]}"
  )
fi
