#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

x() {
    local cmd="$1"
    shift
    (
        set -x
        "${cmd}" "$@"
    )
}

toolchain="${INPUT_TOOLCHAIN:-nightly}"
if [[ -n "${INPUT_COMPONENT:-}" ]]; then
    component="--component=${INPUT_COMPONENT}"
fi
if [[ -n "${INPUT_TARGET:-}" ]]; then
    target="--target=${INPUT_TARGET}"
fi

# --no-self-update is necessary because the windows environment cannot self-update rustup.exe.
# shellcheck disable=SC2086
x rustup toolchain install "${toolchain}" --no-self-update --profile minimal ${component:-} ${target:-}

x rustup default "${toolchain}"
