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
  rustup_args+=(--component "${INPUT_COMPONENT}")
fi
if [[ -n "${INPUT_TARGET:-}" ]]; then
  rustup_args+=(--target "${INPUT_TARGET}")
fi

if type -P rustup; then
  # --no-self-update is necessary because the windows environment cannot self-update rustup.exe.
  g retry rustup toolchain add "${toolchain}" --no-self-update "${rustup_args[@]}"
  g rustup default "${toolchain}"
else
  retry curl --proto '=https' --tlsv1.2 -fsSL --retry 10 https://sh.rustup.rs | sh -s -- -y --default-toolchain "${toolchain}" --no-modify-path "${rustup_args[@]}"
  home="${HOME}"
  case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN* | Windows_NT)
      if [[ "${home}" == "/home/"* ]]; then
        if [[ -d "${home/\/home\///c/Users/}" ]]; then
          # MSYS2 https://github.com/taiki-e/install-action/pull/518#issuecomment-2160736760
          home="${home/\/home\///c/Users/}"
        elif [[ -d "${home/\/home\///cygdrive/c/Users/}" ]]; then
          # Cygwin https://github.com/taiki-e/install-action/issues/224#issuecomment-1720196288
          home="${home/\/home\///cygdrive/c/Users/}"
        else
          warn "\$HOME starting /home/ (${home}) on Windows bash is usually fake path, this may cause installation issue"
        fi
      fi
      canonicalize_windows_path() {
        sed -E 's/^\/cygdrive\//\//; s/^\/c\//C:\\/; s/\//\\/g' <<<"$1"
      }
      ;;
    *)
      canonicalize_windows_path() {
        printf '%s\n' "$1"
      }
      ;;
  esac
  cargo_bin_dir=$(canonicalize_windows_path "${home}/.cargo/bin")
  printf '%s\n' "${cargo_bin_dir}" >>"${GITHUB_PATH}"
fi
