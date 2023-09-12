#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -euo pipefail
IFS=$'\n\t'

g() {
    local cmd="$1"
    shift
    IFS=' '
    echo "::group::${cmd} $*"
    IFS=$'\n\t'
    "${cmd}" "$@"
}

g docker version
g docker buildx version

g docker run --rm --privileged tonistiigi/binfmt --install arm64

g docker buildx create --name setup-docker-buildx-builder --driver docker-container --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760 --driver-opt network=host --buildkitd-flags --debug --use
g docker buildx inspect --bootstrap --builder setup-docker-buildx-builder
