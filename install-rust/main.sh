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

rustup_args=(--profile minimal)
toolchain="${INPUT_TOOLCHAIN:?}"
if [[ -n "${INPUT_COMPONENT:-}" ]]; then
  if [[ "${INPUT_COMPONENT}" =~ (^|,)miri(,|$) ]] && [[ ! "${INPUT_COMPONENT}" =~ (^|,)rust-src(,|$) ]]; then
    INPUT_COMPONENT+=',rust-src'
  fi
  rustup_args+=("--component=${INPUT_COMPONENT}")
fi
if [[ -n "${INPUT_TARGET:-}" ]]; then
  rustup_args+=("--target=${INPUT_TARGET}")
fi

if type -P rustup; then
  # --no-self-update is necessary because the windows environment cannot self-update rustup.exe.
  g retry rustup toolchain add "${toolchain}" --no-self-update "${rustup_args[@]}"
  g rustup default "${toolchain}"
else
  retry curl --proto '=https' --tlsv1.2 -fsSL --retry 10 https://sh.rustup.rs | sh -s -- -y --default-toolchain "${toolchain}" --no-modify-path "${rustup_args[@]}"
  printf '%s\n' "${HOME}/.cargo/bin" >>"${GITHUB_PATH}"
fi
