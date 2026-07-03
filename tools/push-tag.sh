#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -CeEuo pipefail
IFS=$'\n\t'
trap -- 's=$?; printf >&2 "%s\n" "${0##*/}:${LINENO}: \`${BASH_COMMAND}\` exit with ${s}"; exit ${s}' ERR
cd -- "$(dirname -- "$0")"/..

# USAGE:
#    ./tools/push-tag.sh

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

release_date=$(date -u '+%Y-%m-%d')
tag="${release_date//-/.}"
tag="${tag//.0/.}"

git tag "${tag}"
retry git push origin refs/tags/"${tag}"
