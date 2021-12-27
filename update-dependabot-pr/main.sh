#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

header="Accept: application/vnd.github.v3+json"

bail() {
    echo "::error::$*"
    exit 1
}

# https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#pull_request
if [[ ! "${GITHUB_REF:?}" =~ ^refs/pull/[0-9]+/merge$ ]]; then
    bail "GITHUB_REF should be 'refs/pull/[0-9]+/merge'"
fi
pr_number="${GITHUB_REF#refs/pull/}"
pr_number="${pr_number%/merge}"
pr_url="https://api.github.com/repos/${GITHUB_REPOSITORY:?}/pulls/${pr_number}"
pr_data=$(curl --proto '=https' --tlsv1.2 -fsSL --retry 10 --retry-connrefused -H "${header}" "${pr_url}")
pr_url=$(echo "${pr_data}" | jq -r '.url')

if [[ $(echo "${pr_data}" | jq -r '.user.login') != "dependabot[bot]" ]]; then
    bail "this PR created by a user other than 'dependabot[bot]'"
fi

commits_url=$(echo "${pr_data}" | jq -r '.commits_url')
message=$(
    curl --proto '=https' --tlsv1.2 -fsSL --retry 10 --retry-connrefused "${commits_url}" \
        | jq -r '.[0].commit.message' \
        | sed '1,2d' \
        | sed -z 's/\n/\\n/g' \
        | sed -e 's/\\n$//'
)

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    bail "GITHUB_TOKEN not set"
fi

curl --proto '=https' --tlsv1.2 -fsSL --retry 10 --retry-connrefused -X PATCH -H "${header}" "${pr_url}" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -d "{ \"body\": \"${message}\" }" >/dev/null
