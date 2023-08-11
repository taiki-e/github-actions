#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -euo pipefail
IFS=$'\n\t'

case "${OSTYPE}" in
    linux*)
        # Inspired by https://github.com/easimon/maximize-build-space
        sudo rm -rf /opt/ghc
        sudo rm -rf /opt/hostedtoolcache/CodeQL
        sudo rm -rf /usr/local/.ghcup
        sudo rm -rf /usr/local/lib/android
        sudo rm -rf /usr/share/dotnet
        ;;
    darwin*) ;;
    cygwin* | msys*) ;;
    *) bail "unrecognized OSTYPE '${OSTYPE}'" ;;
esac
