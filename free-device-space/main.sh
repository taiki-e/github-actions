#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -eEuo pipefail
IFS=$'\n\t'

# shellcheck disable=SC2154
trap 's=$?; echo >&2 "$0: error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}' ERR

case "$(uname -s)" in
    Linux)
        # GitHub-hosted Linux runners have 14-20GB of free space.
        # There is a tradeoff here between the amount of files deleted and
        # performance. Deleting android and node_modules is particularly
        # time-consuming. Additionally, due to a GitHub Actions bug, it
        # sometimes takes a more long time.
        # https://github.com/actions/runner-images/issues/1939
        dirs=(
            # /opt/az # 676M
            # /opt/google/chrome # 318M
            /opt/hostedtoolcache/CodeQL # 8.3G
            # /opt/microsoft # 695M
            # /usr/lib/firefox # 234M
            # /usr/lib/google-cloud-sdk # 939M
            # /usr/lib/mono # 423M
            /usr/local/.ghcup # 4.7G
            # /usr/local/julia* # 501M
            /usr/local/lib/android # 15G
            # /usr/local/lib/node_modules # 1.2G
            # /usr/local/share/chromium # 506M
            /usr/local/share/powershell # 1.1G
            # /usr/share/az_* # 346M
            /usr/share/dotnet # 2.2G
            /usr/share/swift  # 1.9G
        )
        for dir in "${dirs[@]}"; do
            (
                set -x
                time sudo find "${dir}" -type f -delete
            )
        done
        ;;
    Darwin)
        # GitHub-hosted macOS runners already have a lot of free space.
        ;;
    MINGW* | MSYS* | CYGWIN* | Windows_NT)
        # GitHub-hosted Windows runners have a lot of free space in C drive,
        # but D drive which is used as a workspace has only 14GB of free space.
        # https://github.com/actions/runner-images/issues/1341
        ;;
    *) bail "unrecognized OS type '$(uname -s)'" ;;
esac
