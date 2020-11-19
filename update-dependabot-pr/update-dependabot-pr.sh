#!/bin/bash

# Replace Dependabot PR description with commit message.

set -euo pipefail
IFS=$'\n\t'

HEADER="Accept: application/vnd.github.v3+json"

pr_url="https://api.github.com/repos/${GITHUB_REPOSITORY:?}/pulls/${GITHUB_PR_NUMBER:?}"
commits_url=$(curl -sSf -H "${HEADER}" "$pr_url" | jq -r '.commits_url')
message=$(curl -sSf "${commits_url}" | jq -r '.[0].commit.message' | sed '1,2d' | sed -z 's/\n/\\n/g')

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GITHUB_TOKEN not set"
  exit 1
fi

curl -X PATCH -H "${HEADER}" "$pr_url" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -d "{ \"body\": \"${message}\" }" >/dev/null
