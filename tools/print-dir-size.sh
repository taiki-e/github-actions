#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR

du_mg() {
  (
    set -x
    { sudo du -h "$@" || true; } | { grep -E '^[0-9.]+[MG]' || true; }
  )
}

case "$(uname -s)" in
  Linux)
    { sudo du -h -d1 / 2>/dev/null || true; } | { grep -E '^[0-9.]+[MG]' || true; }
    du_mg -d2 /home
    du_mg -d2 /opt
    du_mg -d2 /usr
    du_mg -d1 /usr/local/lib
    du_mg -d1 /usr/local/share
    du_mg -d1 /var
    du_mg -d1 /var/lib
    ;;
  Darwin)
    xcode-select --print-path
    du_mg -d1 /Applications
    ;;
  MINGW* | MSYS* | CYGWIN* | Windows_NT) ;;
  *) bail "unrecognized OS type '$(uname -s)'" ;;
esac
