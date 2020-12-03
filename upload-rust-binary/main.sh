#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

function error {
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    echo "::error::$*"
  else
    echo "error: $*" >&2
  fi
}

if [[ "${GITHUB_REF:?}" != "refs/tags/"* ]]; then
  error "GITHUB_REF should start with 'refs/tags/'"
  exit 1
fi
tag="${GITHUB_REF#refs/tags/}"

package=${INPUT_BIN:?}
if [[ ! "${INPUT_TAR}" =~ ^(all|unix|windows|none)$ ]]; then
  error "invalid input 'tar': ${INPUT_TAR}"
  exit 1
elif [[ ! "${INPUT_ZIP}" =~ ^(all|unix|windows|none)$ ]]; then
  error "invalid input 'zip': ${INPUT_ZIP}"
  exit 1
elif [[ "${INPUT_TAR}" == "none" ]] && [[ "${INPUT_ZIP}" == "none" ]]; then
  error "at least one of INPUT_TAR or INPUT_ZIP must be a value other than 'none'"
  exit 1
fi

host=$(rustc -Vv | grep host | sed 's/host: //')
target="${INPUT_TARGET:-"${host}"}"
cargo="cargo"
if [[ "${host}" != "${target}" ]]; then
  rustup target add "${target}"
  case "${target}" in
    # https://github.com/rust-embedded/cross#supported-targets
    *windows-msvc | *windows-gnu | *darwin | *fuchsia | *redox) ;;
    *)
      cargo="cross"
      cargo install cross
      ;;
  esac
fi

case "${OSTYPE}" in
  linux*)
    platform="unix"
    strip="strip"
    ;;
  darwin*)
    platform="unix"
    strip="strip"
    # Work around https://github.com/actions/cache/issues/403 by using GNU tar
    # instead of BSD tar.
    brew install gnu-tar
    export PATH=${PATH}:/usr/local/opt/gnu-tar/libexec/gnubin
    ;;
  cygwin* | msys*)
    platform="windows"
    exe=".exe"
    ;;
  *)
    error "unrecognized OSTYPE: ${OSTYPE}"
    exit 1
    ;;
esac
bin="${package}${exe:-}"

$cargo build --bin "${package}" --release --target "${target}"

cd target/"${target}"/release
assets=()
if [[ -n "${strip:-}" ]]; then
  strip "${bin}"
fi
if [[ "${INPUT_TAR/all/${platform}}" == "${platform}" ]]; then
  assets+=("${package}-${target}.tar.gz")
  tar czf ../../../"${assets[0]}" "${bin}"
fi
if [[ "${INPUT_ZIP/all/${platform}}" == "${platform}" ]]; then
  assets+=("${package}-${target}.zip")
  if [[ "${platform}" == "unix" ]]; then
    zip ../../../"${package}-${target}.zip" "${bin}"
  else
    7z a ../../../"${package}-${target}.zip" "${bin}"
  fi
fi
cd ../../..

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  error "GITHUB_TOKEN not set, skipping deploy"
  exit 1
else
  gh release upload "${tag}" "${assets[@]}" --clobber
fi
