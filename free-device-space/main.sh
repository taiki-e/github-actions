#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -eEuo pipefail
IFS=$'\n\t'

case "${OSTYPE}" in
    linux*)
        # Inspired by https://github.com/easimon/maximize-build-space
        (
            set -x
            sudo rm -rf \
                /opt/hostedtoolcache/CodeQL \
                /usr/local/.ghcup \
                /usr/local/lib/android \
                /usr/share/dotnet
        )
        ;;
    darwin*) ;;
    cygwin* | msys*) ;;
    *) bail "unrecognized OSTYPE '${OSTYPE}'" ;;
esac
