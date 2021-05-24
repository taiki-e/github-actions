#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

toolchain="${INPUT_TOOLCHAIN:-nightly}"
if [[ -n "${INPUT_COMPONENT:-}" ]]; then
    component="--component=${INPUT_COMPONENT}"
fi
if [[ -n "${INPUT_TARGET:-}" ]]; then
    target="--target=${INPUT_TARGET}"
fi

set -x

case "${OSTYPE}" in
    cygwin* | msys*)
        # `rustup self update` is necessary because the windows environment cannot self-update rustup.exe by `rustup update`.
        rustup self update
        ;;
    *) ;;
esac

# shellcheck disable=SC2086
rustup toolchain install "${toolchain}" --profile minimal ${component:-} ${target:-}

rustup default "${toolchain}"
