#!/bin/bash

# Create a new GitHub release.
#
# Note:
# - The generated note format is:
#   `See the [release notes]($LINK_TO_CHANGELOG) for a complete list of changes.`
# - The generated link format is:
#   `https://github.com/$GITHUB_REPOSITORY/blob/HEAD/CHANGELOG.md#${TAG/v/}---${RELEASE_DATE}`
# - This script assumes that the format (file name and title of section) of
#   release notes is based on [Keep a Changelog](https://keepachangelog.com).
# - The valid tag format is `vMAJOR.MINOR.PATCH(-PRERELEASE)(+BUILD_METADATA)`
#   This is based on [Semantic Versioning](https://semver.org)
# - The release date is based on the time this script was run, the time zone is
#   the UTC.
# - The generated link to the release notes will be broken when the version
#   yanked if the project adheres to the Keep a Changelog's yanking style.
#   Consider adding a note like the following instead of using the `[YANKED]` tag:
#   `**Note: This release has been yanked.** See $LINK_TO_YANKED_REASON for details.`

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
version="${tag/v/}"
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
