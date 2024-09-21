#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR

case "$(uname -s)" in
    Linux)
        # GitHub-hosted Linux runners have 14-20GB of free space.
        # There is a tradeoff here between the amount of files deleted and
        # performance. Deleting android and node_modules is particularly
        # time-consuming. Additionally, due to a GitHub Actions bug, it
        # sometimes takes a more long time.
        # https://github.com/actions/runner-images/issues/1939
        dirs=(
            /opt/az # 758M
            # /opt/google/chrome # 342M
            /opt/hostedtoolcache/CodeQL # 5.1G
            # /opt/microsoft/msedge # 565M
            /opt/microsoft/powershell # 174M
            # /usr/lib/firefox # 257M
            /usr/lib/google-cloud-sdk # 909M
            /usr/lib/jvm              # 1.2G
            # /usr/lib/llvm-13 # 448M
            # /usr/lib/llvm-14 # 486M
            # /usr/lib/llvm-15 # 514M
            /usr/lib/mono # 423M
            # /usr/local/aws-cli # 226M
            /usr/local/.ghcup      # 5.5G
            /usr/local/julia*      # 602M
            /usr/local/lib/android # 7.6G
            # /usr/local/lib/node_modules # 1.1G
            # /usr/local/share/chromium # 535M
            /usr/local/share/powershell # 1.2G
            /usr/share/az_*             # 467M
            /usr/share/dotnet           # 1.6G
            /usr/share/miniconda        # 658M
            /usr/share/swift            # 1.9G
        )
        for dir in "${dirs[@]}"; do
            if [[ ! -d "${dir}" ]]; then
                continue
            fi
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
