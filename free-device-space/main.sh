#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR

(
  set -x
  df -h
)

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
      # Last checked 2026-10-31 (ubuntu-24.04)
      /home/linuxbrew # 217M
      # /home/packer/.cache # 191M
      # /home/packer/.cpan # 45M
      # /home/packer/.nvm # 2.0M
      # /home/runner/.nvm # 2.0M
      # /home/runner/actions-runner # 163M
      # /home/runner/work # 1.3M
      # /opt/actionarchivecache # 273M
      /opt/az            # 668M
      /opt/google/chrome # 446M
      # /opt/hca # 32M
      # /opt/hostedtoolcache/agentic-workflow-firewall-js # 5.4M
      /opt/hostedtoolcache/CodeQL      # 1.4G
      /opt/hostedtoolcache/copilot-cli # 188M
      # /opt/hostedtoolcache/node # 411M
      # /opt/hostedtoolcache/PyPy # 524M
      # /opt/hostedtoolcache/Python # 1.7G
      /opt/microsoft/msedge # 673M
      /opt/pipx             # 503M
      # /opt/primer # 14M
      # /opt/runner-cache # 1.1G
      # /usr/include/python3.* # 1.7M
      # /usr/lib/apache2 # 4.3M
      /usr/lib/aspell           # 1.7M
      /usr/lib/firefox          # 308M
      /usr/lib/google-cloud-sdk # 846M
      # /usr/lib/linux-azure-*-tools-* # 41M
      # /usr/lib/modules # 148M
      /usr/lib/mysql      # 5.5M
      /usr/lib/podman     # 8.2M
      /usr/lib/postgresql # 44M
      # /usr/lib/python3 # 264M
      # /usr/lib/python3.* # 54M
      # /usr/lib/shim # 4.7M
      # /usr/libexec/docker # 138M
      /usr/libexec/podman    # 5.4M
      /usr/local/.ghcup      # 3.7G
      /usr/local/aws-cli     # 275M
      /usr/local/aws-sam-cli # 201M
      # /usr/local/doc # 51M
      /usr/local/julia*      # 1.1G
      /usr/local/lib/android # 12G
      # /usr/local/lib/node_modules # 476M
      # /usr/local/lib/python3.* # 3.6M
      /usr/local/man                        # 4.1M
      /usr/local/n                          # 203M
      /usr/local/sessionmanagerplugin       # 11M
      /usr/local/share/chromedriver-linux64 # 24M
      /usr/local/share/chromium             # 672M
      # /usr/local/share/cmake-* # 21M
      /usr/local/share/edge_driver  # 31M
      /usr/local/share/gecko_driver # 5.8M
      # /usr/local/share/vcpkg # 210M
      # /usr/share/apache2 # 1.7M
      # /usr/share/autoconf # 1.9M
      # /usr/share/automake-* # 1.1M
      /usr/share/az_* # 584M
      # /usr/share/bash-completion # 3.3M
      # /usr/share/consolefonts # 2.7M
      # /usr/share/dbus-1 # 1.1M
      # /usr/share/doc # 59M
      /usr/share/google-cloud-sdk # 1.8M
      # /usr/share/groff # 2.0M
      # /usr/share/gtk-* # 3.9M
      # /usr/share/i18n # 16M
      # /usr/share/icons # 47M
      # /usr/share/info # 2.2M
      # /usr/share/lintian # 1.6M
      # /usr/share/locale # 67M
      /usr/share/man   # 36M
      /usr/share/mecab # 52M
      # /usr/share/mime # 6.4M
      /usr/share/miniconda  # 1.2G
      /usr/share/mysql      # 9.5M
      /usr/share/postgresql # 3.8M
      # /usr/share/python-babel-localedata # 31M
      # /usr/share/python-wheels # 2.5M
      /usr/share/swift # 3.5G
      # /usr/share/swig* # 5.2M
      # /usr/share/tcltk # 3.8M
      /usr/share/vim # 42M
      # /usr/share/X11 # 5.9M
      # /usr/share/zoneinfo # 3.9M
      # /usr/src/linux-azure-*-headers-* # 140M
      # /usr/src/linux-headers-*-azure # 31M
      # /var/backups # 1.4M
      # /var/cache # 15M
      # /var/lib/docker # 2.5G
      /var/lib/mecab      # 91M
      /var/lib/mysql      # 180M
      /var/lib/postgresql # 39M
      # /var/lib/ubuntu-advantage # 6.9M
      # /var/lib/waagent # 1.6M
      # /var/log # 33M
    )
    # CLI languages
    dirs+=(
      /home/packer/.dotnet        # 175M
      /home/runner/.dotnet        # 175M
      /opt/microsoft/powershell   # 172M
      /usr/local/share/powershell # 1.4G
      /usr/share/dotnet           # 5.8G
    )
    # JVM languages
    dirs+=(
      /usr/lib/jvm              # 1.5G
      /usr/share/apache-maven-* # 12M
      /usr/share/gradle-*       # 165M
      /usr/share/java           # 57M
      /usr/share/kotlinc        # 94M
    )
    # Go
    dirs+=(
      /opt/hostedtoolcache/go # 799M
    )
    # PHP
    dirs+=(
      /usr/include/php # 5.7M
      /usr/lib/php     # 21M
      /usr/share/php   # 2.3M
    )
    # Ruby
    dirs+=(
      /opt/hostedtoolcache/Ruby # 313M
      /usr/include/ruby-*       # 2.0M
      /usr/lib/ruby             # 23M
      /usr/share/ri             # 56M
      /var/lib/gems             # 83M
    )
    # Rust
    dirs+=(
      # /home/packer/.cargo # 21M
      # /home/packer/.rustup # 617M
      # /home/runner/.cargo # 21M
      # /home/runner/.rustup # 617M
    )
    unused_llvm_versions=()
    if [[ -e /usr/lib/llvm-15 ]]; then
      unused_llvm_versions+=(13 14) # ubuntu-22.04
    fi
    if [[ -e /usr/lib/llvm-18 ]]; then
      unused_llvm_versions+=(16 17) # ubuntu-24.04
    fi
    if [[ -e /usr/lib/llvm-22 ]]; then
      unused_llvm_versions+=(20 21) # ubuntu-26.04
    fi
    if [[ ${#unused_llvm_versions[@]} -gt 0 ]]; then
      for v in "${unused_llvm_versions[@]}"; do
        dirs+=(
          /usr/include/llvm-"${v}" # 26M (16), 27M (17), 33M (20), 37M (21)
          /usr/lib/llvm-"${v}"     # 588M (16), 584M (17), 560M (20), 557M (21)
        )
      done
    fi
    ;;
  Darwin)
    # GitHub-hosted macOS runners already have a lot of free space than Ubuntu runners.
    # However, non-default Xcode take significant space (Last checked 2026-10-31):
    # 70GiB (macos-12), 44GiB (macos-13), 28GiB (macos-14), 35GiB (macos-15), 35GiB (macos-15-intel), 26GiB (macos-26)
    dirs+=(
      # Last checked 2026-10-31 (macos-26)
      # /Applications/'Python 3.11' # 1.2M
      # /Applications/'Python 3.12' # 1.2M
      # /Applications/'Python 3.13' # 1.2M
      # /Applications/'Python 3.14' # 1.2M
      /Applications/'Firefox.app'                   # 520M
      /Applications/'Google Chrome for Testing.app' # 367M
      /Applications/'Google Chrome.app'             # 730M
      /Applications/'Microsoft Edge.app'            # 924M
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

(
  set -x
  df -h
)
