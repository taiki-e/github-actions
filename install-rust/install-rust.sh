#!/bin/bash

# Install Rust toolchain.
#
# If the toolchain is nightly (default) and the component is specified,
# this script will install the latest nightly toolchain that the specified
# component is available.

set -euo pipefail
IFS=$'\n\t'

toolchain="${INPUT_TOOLCHAIN:-nightly}"
component="${INPUT_COMPONENT:-}"

if [[ -n "${component}" ]] && [[ "${toolchain}" == "nightly"* ]]; then
  host=$(rustc -Vv | grep host | sed 's/host: //')
  toolchain=nightly-$(curl -sSf https://rust-lang.github.io/rustup-components-history/"${host}"/"${component}")
fi

# --no-self-update is necessary because the windows environment cannot self-update rustup.exe.
rustup toolchain install "${toolchain}" --no-self-update --profile minimal
rustup default "${toolchain}"

if [[ -n "${component}" ]]; then
  rustup component add "${component}"
fi
