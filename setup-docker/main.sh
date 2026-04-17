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
  local qemu_user_tag='@sha256:06e15011a88c9495e8e2c35d578dc305bd5ede8a5671689ea552d99ad7c6f746' # 10.2
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
# Refs: https://github.com/qemu/qemu/blob/v10.2.0/scripts/qemu-binfmt-conf.sh
register_binfmt() {
  printf '::group::Register binfmt\n'
  if [[ ! -d /proc/sys/fs/binfmt_misc ]]; then
    sudo /sbin/modprobe binfmt_misc
  fi
  if [[ ! -f /proc/sys/fs/binfmt_misc/register ]]; then
    # TODO: return with failure instead of exit for unprivileged containers
    sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
  fi
  local magic
  local mask
  local runner_path
  for arch in "${qemu_arch[@]}"; do
    runner_path="${qemu_bin_dir}/qemu-${arch}"
    printf '%s\n' "Setting ${runner_path} as binfmt interpreter for ${arch}"
    case "${arch}" in
      aarch64)
        magic='\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        ;;
      aarch64_be)
        magic='\x7fELF\x02\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'
        ;;
      arm)
        magic='\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        ;;
      armeb)
        magic='\x7fELF\x01\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'
        ;;
      i386)
        # i386
        magic='\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00'
        mask='\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        sudo tee -- /proc/sys/fs/binfmt_misc/register >/dev/null \
          <<<":${arch}-i386:M::${magic}:${mask}:${runner_path}:F"
        # i486
        magic='\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x06\x00'
        mask='\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        sudo tee -- /proc/sys/fs/binfmt_misc/register >/dev/null \
          <<<":${arch}-i486:M::${magic}:${mask}:${runner_path}:F"
        continue
        ;;
      hexagon)
        magic='\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xa4\x00'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        ;;
      loongarch64)
        magic='\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x02\x01'
        mask='\xff\xff\xff\xff\xff\xff\xff\xfc\x00\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        ;;
      m68k)
        magic='\x7fELF\x01\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x04'
        mask='\xff\xff\xff\xff\xff\xff\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'
        ;;
      mips)
        magic='\x7fELF\x01\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x08\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x20'
        ;;
      mipsel)
        magic='\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x08\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\x00\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x20\x00\x00\x00'
        ;;
      mips64)
        magic='\x7fELF\x02\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x08'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'
        ;;
      mips64el)
        magic='\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x08\x00'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\x00\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        ;;
      ppc)
        magic='\x7fELF\x01\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x14'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'
        ;;
      ppc64)
        magic='\x7fELF\x02\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x15'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'
        ;;
      ppc64le)
        magic='\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x15\x00'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\x00'
        ;;
      riscv32)
        magic='\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        ;;
      riscv64)
        magic='\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        ;;
      s390x)
        magic='\x7fELF\x02\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x16'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'
        ;;
      sparc32plus)
        magic='\x7fELF\x01\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x12'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'
        ;;
      sparc64)
        magic='\x7fELF\x02\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x2b'
        mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'
        ;;
      x86_64)
        magic='\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'
        mask='\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
        ;;
      *) bail "internal error: unrecognized qemu arch '${arch}'" ;;
    esac
    sudo tee -- /proc/sys/fs/binfmt_misc/register >/dev/null \
      <<<":${arch}:M::${magic}:${mask}:${runner_path}:F"
  done
  printf '::endgroup::\n'
}

host_arch="$(uname -m)"
case "${host_arch}" in
  aarch64 | arm64) host_arch=aarch64 ;;
  xscale | arm | armv*l | loongarch64 | mips | mips64 | ppc | ppc64 | ppc64le | riscv64 | s390x | sun4v)
    bail "unsupported host arch '${host_arch}'"
    ;;
  # Assume x86_64 unless it has a known non-x86_64 uname -m result.
  *) host_arch=x86_64 ;;
esac

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
        386)
          if [[ "${host_arch}" != 'x86_64' ]]; then
            qemu_arch+=(i386)
          fi
          ;;
        amd64)
          if [[ "${host_arch}" != 'x86_64' ]]; then
            qemu_arch+=(x86_64)
          fi
          ;;
        arm64*)
          if [[ "${host_arch}" != 'aarch64' ]]; then
            qemu_arch+=(aarch64)
          fi
          ;;
        arm*)
          if [[ "${host_arch}" != 'aarch64' ]]; then
            qemu_arch+=(arm)
          fi
          ;;
        loong64) qemu_arch+=(loongarch64) ;;
        mipsle) qemu_arch+=(mipsel) ;;
        mips64le) qemu_arch+=(mips64el) ;;
        sparc) qemu_arch+=(sparc32plus) ;;
        m68k | mips | mips64 | ppc | ppc64 | ppc64le | riscv64 | s390x | sparc64) qemu_arch+=("${arch}") ;;
        *) bail "unrecognized docker arch '${arch}'" ;;
      esac
    done < <(normalize_comma_or_space_separated "${INPUT_QEMU}")
    if [[ ${#qemu_arch[@]} -gt 0 ]]; then
      install_qemu
      register_binfmt qemu-user
    fi
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
