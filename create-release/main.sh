#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

function error {
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    echo "::error::$*"
  else
    echo "error: $*" >&2
  fi
}

changelog="${INPUT_CHANGELOG:-CHANGELOG.md}"

if [[ "${GITHUB_REF:?}" != "refs/tags/"* ]]; then
  error "GITHUB_REF should start with 'refs/tags/'"
  exit 1
fi
tag="${GITHUB_REF#refs/tags/}"

if [[ ! "${tag}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z_0-9\.-]+)?(\+[a-zA-Z_0-9\.-]+)?$ ]]; then
  error "invalid tag format: ${tag}"
  exit 1
fi
if [[ "${tag}" =~ ^v[0-9\.]+-[a-zA-Z_0-9\.-]+(\+[a-zA-Z_0-9\.-]+)?$ ]]; then
  prerelease="--prerelease"
fi
version="${tag#v}"
title="${version}"

curl -LsSf https://github.com/taiki-e/parse-changelog/releases/latest/download/parse-changelog-x86_64-unknown-linux-gnu.tar.gz | tar xzf -
notes=$(./parse-changelog "${changelog}" "${version}")
rm -f ./parse-changelog

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  error "GITHUB_TOKEN not set, skipping release"
  exit 1
fi

if gh release view "${tag}" &>/dev/null; then
  gh release delete "${tag}" -y
fi
gh release create "${tag}" ${prerelease:-} --title "${title}" --notes "${notes}"
