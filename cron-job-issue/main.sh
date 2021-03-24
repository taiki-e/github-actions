#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

TEST=1
title="Cron Job Failed"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-"taiki-e/test"}"
GITHUB_RUN_ID="${GITHUB_RUN_ID:-}"

header="Accept: application/vnd.github.v3+json"
failed="true"
failed="false"

set -x

issue_number=$(
    curl -LsSf -H "${header}" "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues" \
        | jq "map(select(.title == \"${title}\" and .user.login == \"github-actions[bot]\")) | .[0].number"
)
echo "https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
curl -LsSf -H "${header}" "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID/jobs"

if [[ "${failed}" != "true" ]]; then
    if [[ "${issue_number}" != "null" ]]; then
        echo "info: fixed: https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
        if [[ -z "${TEST:-}" ]]; then
            body="Fixed: https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
            gh issue comment "${issue_number}" --repo "${GITHUB_REPOSITORY}" --body "${body}"
            gh issue close "${issue_number}" --repo "${GITHUB_REPOSITORY}"
        fi
    fi
    exit 0
fi

if [[ "${issue_number}" != "null" ]]; then
    echo "${issue_number}"
    echo "info: still failing: https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
    echo "info: skip creating a new issue because an issue with the same title already exists"
    if [[ -z "${TEST:-}" ]]; then
        body="Still Failing: https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
        gh issue comment "${issue_number}" --repo "${GITHUB_REPOSITORY}" --body "${body}"
    fi
    exit 0
fi

echo "info: failed: https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
if [[ -z "${TEST:-}" ]]; then
    # https://cli.github.com/manual/gh_issue_create
    gh issue create --title "${title}"
fi
