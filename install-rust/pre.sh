#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR

printf '::warning::install-rust: %s\n' "this action is deprecated in favor of taiki-e/install-action with \`tool: rust@<version>\`"

additional=''
if [[ -n "${INPUT_COMPONENT:-}" ]]; then
  additional+="+${INPUT_COMPONENT//,/+}"
fi
if [[ -n "${INPUT_TARGET:-}" ]]; then
  additional+="+${INPUT_TARGET//,/+}"
fi
printf 'additional=%s\n' "${additional}" >>"${GITHUB_OUTPUT}"
