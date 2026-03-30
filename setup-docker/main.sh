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
bail() {
  printf '::error::%s\n' "$*"
  exit 1
}
normalize_comma_or_space_separated() {
  # Normalize whitespace characters into space because it's hard to handle single input contains lines with POSIX sed alone.
  local list="${1//[$'\r\n\t']/ }"
  if [[ "${list}" == *","* ]]; then
    # If a comma is contained, consider it is a comma-separated list.
    # Drop leading and trailing whitespaces in each element.
    sed -E 's/ *, */,/g; s/^.//; s/,,$/,/' <<<",${list},"
  else
    # Otherwise, consider it is a whitespace-separated list.
    # Convert whitespace characters into comma.
    sed -E 's/ +/,/g; s/^.//' <<<" ${list} "
  fi
}
install_qemu() {
  qemu_bin_dir=/usr/bin
  printf '::group::Instal QEMU\n'
  # https://github.com/taiki-e/dockerfiles/pkgs/container/qemu-user
  qemu_version='10.2'
  qemu_user_tag=":${qemu_version}"
  retry docker create --name qemu-user "ghcr.io/taiki-e/qemu-user${qemu_user_tag}"
  mkdir -p -- .setup-docker-action-tmp
  for arch in "${qemu_arch[@]}"; do
    docker cp -- "qemu-user:/usr/bin/qemu-${arch}" ".setup-docker-action-tmp/qemu-${arch}"
    sudo mv -- ".setup-docker-action-tmp/qemu-${arch}" "${qemu_bin_dir}"/
  done
  docker rm -f -- qemu-user >/dev/null
  rm -rf -- ./.setup-docker-action-tmp
  printf '::endgroup::\n'
}
# Refs: https://github.com/qemu/qemu/blob/v10.1.0/scripts/qemu-binfmt-conf.sh
register_binfmt() {
  printf '::group::Register binfmt\n'
  if [[ ! -d /proc/sys/fs/binfmt_misc ]]; then
    sudo /sbin/modprobe binfmt_misc
  fi
  if [[ ! -f /proc/sys/fs/binfmt_misc/register ]]; then
    # TODO: return with failure instead of exit for unprivileged containers
    sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
  fi
  local url='https://raw.githubusercontent.com/qemu/qemu/f8b2f64e2336a28bf0d50b6ef8a7d8c013e9bcf3/scripts/qemu-binfmt-conf.sh'
  retry curl --proto '=https' --tlsv1.2 -fsSL -o __qemu-binfmt-conf.sh "${url}"
  IFS=' '
  sed -Ei "s/i386_magic/qemu_target_list=\"${qemu_arch[*]}\"\\ni386_magic/" ./__qemu-binfmt-conf.sh
  IFS=$'\n\t'
  chmod +x ./__qemu-binfmt-conf.sh
  sudo ./__qemu-binfmt-conf.sh --qemu-path "${qemu_bin_dir}" --persistent yes
  rm -- ./__qemu-binfmt-conf.sh
  printf '::endgroup::\n'
}

g retry docker version

case "${INPUT_QEMU}" in
  false) ;;
  *)
    qemu_arch=()
    while read -rd, arch; do
      # Refs:
      # https://hub.docker.com/r/docker/dockerfile/tags
      # https://hub.docker.com/r/alpinelinux/build-base/tags
      # https://hub.docker.com/r/paleozogt/scratch/tags
      # https://hub.docker.com/r/polyarch/debian-ports/tags
      case "${arch}" in
        386) qemu_arch+=(i386) ;;
        amd64) qemu_arch+=(x86_64) ;;
        arm64*) qemu_arch+=(aarch64) ;;
        arm*) qemu_arch+=(arm) ;;
        loong64) qemu_arch+=(loongarch64) ;;
        mipsle) qemu_arch+=(mipsel) ;;
        mips64le) qemu_arch+=(mips64el) ;;
        sparc) qemu_arch+=(sparc32plus) ;;
        m68k | mips | mips64 | ppc | ppc64 | ppc64le | riscv64 | s390x | sparc64) qemu_arch+=("${arch}") ;;
        *) bail "unrecognized docker arch '${arch}'" ;;
      esac
    done < <(normalize_comma_or_space_separated "${INPUT_QEMU}")
    install_qemu
    register_binfmt qemu-user
    ;;
esac

case "${INPUT_BUILDX}" in
  false) ;;
  true)
    g docker buildx version
    g docker buildx create --name setup-docker-buildx-builder --driver docker-container --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760 --driver-opt network=host --buildkitd-flags --debug --use
    g retry docker buildx inspect --bootstrap --builder setup-docker-buildx-builder
    ;;
  *) bail "'buildx' input option must be 'true' or 'false': '${INPUT_BUILDX}'" ;;
esac
