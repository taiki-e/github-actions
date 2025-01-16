#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR

g() {
  IFS=' '
  local cmd="$*"
  IFS=$'\n\t'
  printf '::group::%s\n' "${cmd#retry }"
  "$@"
  printf '::endgroup::\n'
}
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

export RUSTUP_MAX_RETRIES="${RUSTUP_MAX_RETRIES:-10}"

# --no-self-update is necessary because the windows environment cannot self-update rustup.exe.
rustup_args=(--no-self-update --profile minimal)
toolchain="${INPUT_TOOLCHAIN:?}"
if [[ -n "${INPUT_COMPONENT:-}" ]]; then
  rustup_args+=("--component=${INPUT_COMPONENT}")
fi
if [[ -n "${INPUT_TARGET:-}" ]]; then
  rustup_args+=("--target=${INPUT_TARGET}")
fi

g retry rustup toolchain add "${toolchain}" "${rustup_args[@]}"

g rustup default "${toolchain}"
