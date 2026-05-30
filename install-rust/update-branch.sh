#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR
cd -- "$(dirname -- "$0")"/..

# Update stable/beta/nightly branches.
#
# USAGE:
#    ./install-rust/update-branch.sh

retry() {
  for i in {1..10}; do
    if "$@"; then
      return 0
    else
      sleep "${i}"
    fi
  done
  "$@"
}
bail() {
  printf >&2 'error: %s\n' "$*"
  exit 1
}

if [[ $# -gt 1 ]]; then
  bail "invalid argument '$2'"
fi
if { sed --help 2>&1 || true; } | grep -Eq -e '-i extension'; then
  in_place=(-i '')
else
  in_place=(-i)
fi

# Make sure there is no uncommitted change.
git diff --exit-code
git diff --exit-code --staged

# Make sure that the release was created from an allowed branch.
if ! git branch | grep -Eq '\* main$'; then
  bail "current branch is not 'main'"
fi
if ! git remote -v | grep -F origin | grep -Eq 'github\.com[:/]taiki-e/'; then
  bail "cannot publish a new release from fork repository"
fi

set -x

retry git push origin refs/heads/main

toolchains=(
  stable
  beta
  nightly
)
refs=()
for toolchain in "${toolchains[@]}"; do
  git checkout -b "${toolchain}"
  sed -E "${in_place[@]}" install-rust/action.yml \
    -e "s/required: true/required: false/g" \
    -e "s/# default: #publish:toolchain/default: ${toolchain}/g"
  git add install-rust/action.yml
  git commit -m "${toolchain}"
  git checkout main
  refs+=(refs/heads/"${toolchain}")
done
retry git push origin --atomic -f "${refs[@]}"
git branch -D "${toolchains[@]}"
