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

case "${OSTYPE}" in
    cygwin* | msys*)
        (
            set -x
            # `rustup self update` is necessary because the windows environment cannot self-update rustup.exe by `rustup update`.
            rustup self update
        )
        ;;
    *) ;;
esac

set -x

# --no-self-update is necessary because the windows environment cannot self-update rustup.exe.
# shellcheck disable=SC2086
rustup toolchain install "${toolchain}" --no-self-update --profile minimal \
    ${component:-} ${target:-}

rustup default "${toolchain}"
