#!/bin/bash

# Source: https://github.com/rust-lang/simpleinfra/blob/2e042b654e76fe435bbab0f4c743a1015d575be4/github-actions/static-websites/entrypoint.sh

set -euo pipefail
IFS=$'\n\t'

deploy_dir="${GITHUB_WORKSPACE:?}/${INPUT_DEPLOY_DIR:?}"

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
git push -f "https://x-token:${GITHUB_TOKEN:?}@github.com/${GITHUB_REPOSITORY:?}" master:gh-pages
