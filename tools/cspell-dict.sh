#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
# shellcheck disable=SC2013
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR

bail() {
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    printf '::error::%s\n' "$*"
  else
    printf >&2 'error: %s\n' "$*"
  fi
  exit 1
}

case "$1" in
  clean)
    cd -- "$(dirname -- "$0")"/..
    dictionary=.github/.cspell/organization-dictionary.txt
    grep_args=()
    for word in $(grep -Ev '^//' "${dictionary}" || true); do
      [[ -n "${word}" ]] || continue
      if npx -y cspell trace "${word}" | grep -Fv "${dictionary}" | grep -Eq "^${word} \\* [^ ]+\*"; then
        grep_args+=(-e "^${word}$")
      fi
    done
    if [[ ${#grep_args[@]} -gt 0 ]]; then
      printf 'info: %s\n' "removing needless words from ${dictionary}"
      res=$(grep -Ev "${grep_args[@]}" "${dictionary}")
      printf '%s\n' "${res}" >|"${dictionary}"
    fi
    ;;
  trace)
    for dictionary in .github/.cspell/*; do
      if [[ -f "${dictionary}" ]]; then
        for word in $(grep -Ev '^//' "${dictionary}" || true); do
          [[ -n "${word}" ]] || continue
          npx -y cspell trace "${word}" | grep -E "^${word} \\*" | { grep -Fv "${dictionary}" || true; }
        done
      fi
    done
    ;;
  *) bail "unrecognized subcommand '$1'" ;;
esac
