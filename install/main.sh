#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

x() {
    local cmd="$1"
    shift
    (
        set -x
        "${cmd}" "$@"
    )
}
bail() {
    echo "::error::$*"
    exit 1
}

export DEBIAN_FRONTEND=noninteractive

tools=()
if [[ -n "${INPUT_TOOL:-}" ]]; then
    while read -rd,; do tools+=("${REPLY}"); done <<<"${INPUT_TOOL},"
fi

for tool in "${tools[@]}"; do
    case "${tool}" in
        cargo-hack | cargo-llvm-cov | cargo-minimal-versions)
            host=$(rustc -Vv | grep host | sed 's/host: //')
            curl --proto '=https' --tlsv1.2 -fsSL --retry 10 --retry-connrefused "https://github.com/taiki-e/${tool}/releases/latest/download/${tool}-${host}.tar.gz" \
                | tar xzf - -C ~/.cargo/bin
            x cargo "${tool#cargo-}" --version
            ;;
        prettier)
            x npm install prettier
            x npx prettier --version
            ;;
        shellcheck)
            x sudo apt-get -o Dpkg::Use-Pty=0 remove -y shellcheck
            tag="$(curl --proto '=https' --tlsv1.2 -fsSL --retry 10 --retry-connrefused https://api.github.com/repos/koalaman/shellcheck/releases/latest | jq -r '.tag_name')"
            curl --proto '=https' --tlsv1.2 -fsSL --retry 10 --retry-connrefused "https://github.com/koalaman/shellcheck/releases/download/${tag}/shellcheck-${tag}.linux.x86_64.tar.xz" \
                | tar xJf - --strip-components 1 -C /usr/local/bin "shellcheck-${tag}/shellcheck"
            x shellcheck --version
            ;;
        shfmt)
            x "${GOROOT_1_17_X64}"/bin/go install mvdan.cc/sh/v3/cmd/shfmt@latest
            echo "${HOME}/go/bin" >>"${GITHUB_PATH}"
            x "${HOME}/go/bin/shfmt" --version
            ;;
        *) bail "unsupported tool '${tool}'" ;;
    esac
done
