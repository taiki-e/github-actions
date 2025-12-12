#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR

dirs=()
case "$(uname -s)" in
  Linux)
    # GitHub-hosted Ubuntu runners have 14-20GB of free space.
    # There is a tradeoff here between the amount of files deleted and
    # performance. Deleting android and node_modules is particularly
    # time-consuming. Additionally, due to a GitHub Actions bug, it
    # sometimes takes a more long time.
    # https://github.com/actions/runner-images/issues/1939
    dirs+=(
      # Last checked 2025-12-12 (ubuntu-24.04)
      /home/linuxbrew # 184M
      # /home/packer/.nvm # 3.2M
      # /home/runner/.nvm # 3.2M
      # /home/runner/actions-runner # 1.4G
      # /home/runner/work # 1.1M
      # /opt/actionarchivecache # 244M
      /opt/az            # 668M
      /opt/google/chrome # 375M
      # /opt/hca # 14M
      /opt/hostedtoolcache/CodeQL # 1.7G
      # /opt/hostedtoolcache/PyPy # 520M
      # /opt/hostedtoolcache/Python # 1.9G
      # /opt/hostedtoolcache/node # 574M
      /opt/microsoft/msedge # 608M
      # /opt/pipx # 514M
      # /opt/pipx/shared # 13M
      # /opt/pipx/venvs # 502M
      # /opt/runner-cache # 429M
      # /usr/include/python3.* # 1.7M
      # /usr/lib/apache2 # 4.3M
      /usr/lib/aspell # 1.7M
      # /usr/lib/cgi-bin # 5.5M
      /usr/lib/firefox          # 275M
      /usr/lib/google-cloud-sdk # 1008M
      # /usr/lib/linux-azure-*-tools-* # 14M
      /usr/lib/mysql      # 5.5M
      /usr/lib/podman     # 8.2M
      /usr/lib/postgresql # 44M
      # /usr/lib/python3 # 259M
      # /usr/lib/python3.* # 54M
      /usr/libexec/podman    # 5.4M
      /usr/local/.ghcup      # 6.4G
      /usr/local/aws-cli     # 240M
      /usr/local/aws-sam-cli # 266M
      # /usr/local/doc # 51M
      /usr/local/julia*      # 1015M
      /usr/local/lib/android # 12G
      # /usr/local/lib/python3.* # 1.5M
      # /usr/local/lib/node_modules # 486M
      /usr/local/man                        # 4.1M
      /usr/local/n                          # 167M
      /usr/local/sessionmanagerplugin       # 13M
      /usr/local/share/chromedriver-linux64 # 19M
      /usr/local/share/chromium             # 619M
      /usr/local/share/edge_driver          # 34M
      /usr/local/share/gecko_driver         # 5.9M
      # /usr/local/share/vcpkg # 182M
      # /usr/share/apache2 # 1.7M
      /usr/share/az_* # 496M
      # /usr/share/bash-completion # 3.3M
      # /usr/share/doc # 60M
      # /usr/share/fonts # 36M
      /usr/share/google-cloud-sdk # 1.5M
      # /usr/share/i18n # 17M
      # /usr/share/icons # 47M
      # /usr/share/info # 2.2M
      # /usr/share/locale # 63M
      /usr/share/man        # 108M
      /usr/share/mecab      # 52M
      /usr/share/miniconda  # 802M
      /usr/share/mysql      # 9.5M
      /usr/share/postgresql # 3.8M
      # /usr/share/python-babel-localedata # 31M
      # /usr/share/python-wheels # 2.5M
      # /usr/share/swig* # 5.2M
      /usr/share/vim # 42M
      # /usr/src/linux-headers-*-azure # 29M
      # /usr/src/linux-azure-*-headers-* # 130M
      # /var/backups # 1.4M
      # /var/cache # 22M
      /var/lib/mecab      # 91M
      /var/lib/mysql      # 180M
      /var/lib/postgresql # 39M
      # /var/lib/waagent # 20M
      # /var/log # 32M
    )
    # CLI languages
    dirs+=(
      /home/packer/.dotnet        # 58M
      /home/runner/.dotnet        # 58M
      /opt/microsoft/powershell   # 178M
      /usr/local/share/powershell # 1.3G
      /usr/share/dotnet           # 4.0G
    )
    # JVM languages
    dirs+=(
      /usr/lib/jvm              # 1.5G
      /usr/share/apache-maven-* # 11M
      /usr/share/gradle-*       # 144M
      /usr/share/java           # 46M
      /usr/share/kotlinc        # 83M
      /usr/share/swift          # 3.2G
    )
    # Go
    dirs+=(
      /opt/hostedtoolcache/go # 1.1G
    )
    # PHP
    dirs+=(
      /usr/include/php # 5.7M
      /usr/lib/php     # 21M
      /usr/share/php   # 2.3M
    )
    # Ruby
    dirs+=(
      /opt/hostedtoolcache/Ruby # 217M
      /usr/include/ruby-*       # 2.0M
      /usr/lib/ruby             # 23M
      /usr/share/ri             # 56M
      /var/lib/gems             # 63M
    )
    # Rust
    dirs+=(
      # /home/packer/.cargo # 20M
      # /home/packer/.rustup # 600M
      # /home/runner/.cargo # 20M
      # /home/runner/.rustup # 600M
    )
    unused_llvm_versions=()
    if [[ -e /usr/lib/llvm-15 ]]; then
      unused_llvm_versions+=(13 14) # ubuntu-22.04
    fi
    if [[ -e /usr/lib/llvm-18 ]]; then
      unused_llvm_versions+=(16 17) # ubuntu-24.04
    fi
    if [[ ${#unused_llvm_versions[@]} -gt 0 ]]; then
      for v in "${unused_llvm_versions[@]}"; do
        dirs+=(
          /usr/include/llvm-"${v}" # 26M (16), 27M (17)
          /usr/lib/llvm-"${v}"     # 588M (16), 584M (17)
        )
      done
    fi
    ;;
  Darwin)
    # GitHub-hosted macOS runners already have a lot of free space than Ubuntu runners.
    # However, non-default Xcode take significant space (Last checked 2025-10-11):
    # 70GiB (macos-12), 44GiB (macos-13), 28GiB (macos-14), 26GiB (macos-15), 27GiB (macos-15-intel), 9GiB (macos-26)
    dirs+=(
      # Last checked 2025-12-12 (macos-26)
      # /Applications/'Python 3.11' # 1.2M
      # /Applications/'Python 3.12' # 1.2M
      # /Applications/'Python 3.13' # 1.2M
      # /Applications/'Python 3.14' # 1.2M
      /Applications/'Firefox.app'                   # 452M
      /Applications/'Google Chrome for Testing.app' # 325M
      /Applications/'Google Chrome.app'             # 637M
      /Applications/'Microsoft Edge.app'            # 917M
    )
    default_xcode=$(xcode-select --print-path | grep -Eo 'Xcode_[0-9]+(\.[0-9]+(\.[0-9]+)?)?\.app' | grep -Eo 'Xcode_[0-9]+(\.[0-9]+)?')
    for dir in /Applications/Xcode_*.app; do
      if [[ "${dir}" != /Applications/"${default_xcode}"* ]]; then
        dirs+=("${dir}")
      fi
    done
    ;;
  MINGW* | MSYS* | CYGWIN* | Windows_NT)
    # GitHub-hosted Windows runners have a lot of free space in C drive,
    # but D drive which is used as a workspace has only 14GB of free space.
    # https://github.com/actions/runner-images/issues/1341
    exit 0
    ;;
  *) bail "unrecognized OS type '$(uname -s)'" ;;
esac
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
