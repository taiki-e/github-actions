#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -eEuo pipefail
IFS=$'\n\t'

g() {
    local cmd="$1"
    shift
    IFS=' '
    echo "::group::${cmd} $*"
    IFS=$'\n\t'
    "${cmd}" "$@"
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

wd=$(pwd)

g git version

g git init
g git remote add origin "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"

g git config --local gc.auto 0

g retry git -c protocol.version=2 fetch --no-tags --prune --no-recurse-submodules --depth=1 origin "+${GITHUB_SHA}:${GITHUB_REF}"

g retry git checkout --progress --force "${GITHUB_REF}"

g git config --global --add safe.directory "${wd}"
