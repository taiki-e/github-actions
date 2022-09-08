#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Source: https://github.com/rust-lang/simpleinfra/blob/2e042b654e76fe435bbab0f4c743a1015d575be4/github-actions/static-websites/entrypoint.sh

deploy_dir="${GITHUB_WORKSPACE:?}/${INPUT_DEPLOY_DIR:?}"
token="${INPUT_TOKEN:-"${GITHUB_TOKEN:-}"}"

if [[ -z "${token}" ]]; then
    bail "neither GITHUB_TOKEN environment variable nor 'token' input option is set"
fi

# Ensure GitHub doesn't mess around with the uploaded file.
# Without the file, for example, files with an underscore in the name won't be
# included in the pages.
touch "${deploy_dir}/.nojekyll"

# Push the website to GitHub pages
cd "${deploy_dir}"
rm -rf .git
git init
git config user.name "Deploy from CI"
git config user.email ""
git add .
git commit -m "Deploy ${GITHUB_SHA:?} to gh-pages"
git push -f "https://x-token:${token}@github.com/${GITHUB_REPOSITORY:?}" master:gh-pages
