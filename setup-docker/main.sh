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

g docker version
g docker buildx version

case "${INPUT_QEMU:-}" in
  false) ;;
  *) g retry docker run --rm --privileged tonistiigi/binfmt --install "${INPUT_QEMU:-}" ;;
esac

g docker buildx create --name setup-docker-buildx-builder --driver docker-container --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760 --driver-opt network=host --buildkitd-flags --debug --use
g retry docker buildx inspect --bootstrap --builder setup-docker-buildx-builder
