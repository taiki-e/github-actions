#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

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
    echo "::error::$*"
    exit 1
}
run_curl() {
    retry curl --proto '=https' --tlsv1.2 -fsSL --retry 10 --retry-connrefused \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${token}" \
        "$@"
}

token="${INPUT_TOKEN:-"${GITHUB_TOKEN:-}"}"

if [[ -z "${token}" ]]; then
    bail "neither GITHUB_TOKEN environment variable nor 'token' input option is set"
fi

# https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#pull_request
if [[ ! "${GITHUB_REF:?}" =~ ^refs/pull/[0-9]+/merge$ ]]; then
    bail "GITHUB_REF should be 'refs/pull/[0-9]+/merge'"
fi
pr_number="${GITHUB_REF#refs/pull/}"
pr_number="${pr_number%/merge}"
pr_url="https://api.github.com/repos/${GITHUB_REPOSITORY:?}/pulls/${pr_number}"
pr_data=$(run_curl "${pr_url}")
pr_url=$(jq <<<"${pr_data}" -r '.url')

if [[ $(jq <<<"${pr_data}" -r '.user.login') != "dependabot[bot]" ]]; then
    bail "this PR created by a user other than 'dependabot[bot]'"
fi

commits_url=$(jq <<<"${pr_data}" -r '.commits_url')
message=$(
    run_curl "${commits_url}" \
        | jq -r '.[0].commit.message' \
        | sed '1,2d' \
        | sed -z 's/\n/\\n/g' \
        | sed -e 's/\\n$//'
)

run_curl -X PATCH "${pr_url}" \
    -d "{ \"body\": \"${message}\" }" >/dev/null
