#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -euo pipefail
IFS=$'\n\t'

case "${OSTYPE}" in
    linux*)
        # Inspired by https://github.com/easimon/maximize-build-space
        sudo rm -rf /usr/share/dotnet
        sudo rm -rf /usr/local/lib/android
        sudo rm -rf /opt/ghc
        sudo rm -rf /opt/hostedtoolcache/CodeQL
        ;;
    darwin*) ;;
    cygwin* | msys*) ;;
    *) bail "unrecognized OSTYPE '${OSTYPE}'" ;;
esac
