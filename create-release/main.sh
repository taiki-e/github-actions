#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

function error {
  echo "$*" >&2
}

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
date=$(date --utc '+%Y-%m-%d')
title="${version}"
changelog="https://github.com/${GITHUB_REPOSITORY:?}/blob/HEAD/CHANGELOG.md#${version//./}---${date}"
notes="See the [release notes](${changelog}) for a complete list of changes."

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  error "GITHUB_TOKEN not set, skipping release"
  exit 1
fi

if gh release view "${tag}" &>/dev/null; then
  gh release delete "${tag}" -y
fi
gh release create "${tag}" ${prerelease:-} --title "${title}" --notes "${notes}"
