#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR

case "$(uname -s)" in
  Linux)
    # GitHub-hosted Ubuntu runners have 14-20GB of free space.
    # There is a tradeoff here between the amount of files deleted and
    # performance. Deleting android and node_modules is particularly
    # time-consuming. Additionally, due to a GitHub Actions bug, it
    # sometimes takes a more long time.
    # https://github.com/actions/runner-images/issues/1939
    dirs=(
      /home/linuxbrew             # 164M
      /home/packer/.dotnet        # 49M
      /home/runner/.dotnet        # 51M
      /home/runneradmin/.dotnet   # 51M
      /opt/actionarchivecache     # 209M
      /opt/az                     # 763M
      /opt/google-cloud-sdk       # 397M
      /opt/google/chrome          # 342M
      /opt/hostedtoolcache/CodeQL # 5.1G
      /opt/microsoft/msedge       # 565M
      /opt/microsoft/powershell   # 174M
      # /opt/pipx # 513M
      # /opt/pipx/venvs # 500M
      /usr/include/php          # 5.7M
      /usr/lib/dotnet           # 508M
      /usr/lib/firefox          # 238M
      /usr/lib/google-cloud-sdk # 909M
      /usr/lib/heroku           # 280M
      /usr/lib/jvm              # 1.2G
      /usr/lib/linux-azure-*    # 14M
      /usr/lib/mono             # 423M
      /usr/lib/monodoc          # 22M
      /usr/lib/mysql            # 6.5M
      /usr/lib/nuget            # 7.0M
      /usr/lib/php              # 23M
      /usr/local/.ghcup         # 5.5G
      # /usr/local/aws-cli     # 248M
      # /usr/local/aws-sam-cli # 179M
      /usr/local/doc         # 51M
      /usr/local/julia*      # 602M
      /usr/local/lib/android # 7.6G
      # /usr/local/lib/node_modules # 635M
      /usr/local/man              # 4.1M
      /usr/local/n                # 166M
      /usr/local/share/chromium   # 535M
      /usr/local/share/powershell # 1.2G
      /usr/share/az_*             # 468M
      /usr/share/doc              # 64M
      /usr/share/dotnet           # 1.6G
      /usr/share/gradle-*         # 146M
      /usr/share/groovy           # 14M
      /usr/share/i18n             # 16M
      /usr/share/java             # 131M
      /usr/share/kotlinc          # 91M
      /usr/share/man              # 36M
      /usr/share/mecab            # 52M
      /usr/share/miniconda        # 658M
      /usr/share/mysql            # 9.4M
      /usr/share/R                # 11M
      /usr/share/ri               # 56M
      /usr/share/sbt              # 138M
      /usr/share/swift            # 2.5G
      /var/lib/mecab              # 91M
      /var/lib/mysql              # 180M
    )
    # ubuntu-22.04
    if [[ -e /usr/lib/llvm-15 ]]; then
      dirs+=(
        /usr/include/llvm-13 # 24M
        /usr/include/llvm-14 # 24M
        # /usr/include/llvm-15 # 25M
        /usr/lib/llvm-13 # 448M
        /usr/lib/llvm-14 # 486M
        # /usr/lib/llvm-15 # 514M
      )
    fi
    # ubuntu-24.04
    if [[ -e /usr/lib/llvm-18 ]]; then
      dirs+=(
        /usr/include/llvm-16 # 26M
        /usr/include/llvm-17 # 27M
        # /usr/include/llvm-18 # 28M
        /usr/lib/llvm-16 # 558M
        /usr/lib/llvm-17 # 564M
        # /usr/lib/llvm-18 # 697M
      )
    fi
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
    # GitHub-hosted macOS runners already have a lot of free space than Ubuntu runners.
    # However, older minor versions of each major version of Xcode take significant space:
    # 70G (macos-12), 32G (macos-13), 19G (macos-14)
    dirs=()
    # https://github.com/actions/runner-images/tree/HEAD/images/macos
    # macos-12: 13.1, 13.2, 13.3, 13.4, 14.0, 14.1, 14.2
    if [[ -e /Applications/Xcode_13.4.app ]]; then
      dirs+=(
        /Applications/Xcode_13.1.0.app
        /Applications/Xcode_13.1.app
        /Applications/Xcode_13.2.1.app
        /Applications/Xcode_13.2.app
        /Applications/Xcode_13.3.1.app
        /Applications/Xcode_13.3.app
      )
    fi
    if [[ -e /Applications/Xcode_14.2.app ]]; then
      dirs+=(
        /Applications/Xcode_14.0.1.app
        /Applications/Xcode_14.0.app
        /Applications/Xcode_14.1.0.app
        /Applications/Xcode_14.1.app
      )
    fi
    # macos-13: 14.1, 14.2, 14.3, 15.0, 15.1, 15.2
    if [[ -e /Applications/Xcode_14.3.app ]]; then
      dirs+=(
        /Applications/Xcode_14.2.0.app
        /Applications/Xcode_14.2.app
      )
    fi
    if [[ -e /Applications/Xcode_15.2.app ]]; then
      dirs+=(
        /Applications/Xcode_15.0.1.app
        /Applications/Xcode_15.0.app
        /Applications/Xcode_15.1.0.app
        /Applications/Xcode_15.1.app
      )
    fi
    # macos-14: 14.3, 15.0, 15.1, 15.2, 15.3, 15.4, 16.0, 16.1
    # macos-15: 16.0, 16.1
    if [[ -e /Applications/Xcode_15.4.app ]]; then
      dirs+=(
        /Applications/Xcode_15.2.0.app
        /Applications/Xcode_15.2.app
        /Applications/Xcode_15.3.0.app
        /Applications/Xcode_15.3.app
      )
    fi
    # 16.1 is still in beta.
    # if [[ -e /Applications/Xcode_16.1.app ]]; then
    #     dirs+=(
    #         /Applications/Xcode_16.0.0.app
    #         /Applications/Xcode_16.0.app
    #     )
    # fi
    if [[ ${#dirs[@]} -gt 0 ]]; then
      for dir in "${dirs[@]}"; do
        if [[ ! -d "${dir}" ]]; then
          continue
        fi
        (
          set -x
          time sudo find "${dir}" -type f -delete
        )
      done
    fi
    ;;
  MINGW* | MSYS* | CYGWIN* | Windows_NT)
    # GitHub-hosted Windows runners have a lot of free space in C drive,
    # but D drive which is used as a workspace has only 14GB of free space.
    # https://github.com/actions/runner-images/issues/1341
    ;;
  *) bail "unrecognized OS type '$(uname -s)'" ;;
esac
