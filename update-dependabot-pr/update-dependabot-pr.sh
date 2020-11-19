#!/bin/bash

# Replace Dependabot PR description with the message of the first commit.

set -euo pipefail
IFS=$'\n\t'

HEADER="Accept: application/vnd.github.v3+json"

function error {
  echo "$*" >&2
}

# https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#pull_request
if [[ ! "${GITHUB_REF:?}" =~ refs/pull/[0-9]+/merge ]]; then
  error "GITHUB_REF should be 'refs/pull/[0-9]+/merge'"
  exit 1
fi
pr_number="${GITHUB_REF#refs/pull/}"
pr_number="${pr_number%/merge}"
pr_url="https://api.github.com/repos/${GITHUB_REPOSITORY:?}/pulls/${pr_number}"

commits_url=$(curl -sSf -H "${HEADER}" "$pr_url" | jq -r '.commits_url')
message=$(
  curl -sSf "${commits_url}" |
    jq -r '.[0].commit.message' |
    sed '1,2d' |
    sed -z 's/\n/\\n/g' |
    sed -e 's/\\n$//'
)

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  error "GITHUB_TOKEN not set"
  exit 1
fi

curl -X PATCH -H "${HEADER}" "$pr_url" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -d "{ \"body\": \"${message}\" }" >/dev/null
