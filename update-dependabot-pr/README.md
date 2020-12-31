# update-dependabot-pr

GitHub Action for replacing PR description with the message of the first commit.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Motivation

[Dependabot] creates a very verbose PR description by default. And there is
currently no way to configure this.

## Usage

### Example workflow

```yaml
name: PR

on:
  pull_request:
    types: [opened, reopened]

jobs:
  # This only affects PRs created by Dependabot.
  dependabot:
    if: startsWith(github.head_ref, 'dependabot/')
    runs-on: ubuntu-latest
    steps:
      - uses: taiki-e/github-actions/update-dependabot-pr@main
        env:
          # (required)
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- Workflows should be `on.pull_request`, not `on.pull_request_target` because
  this action gets the PR number from `GITHUB_REF`.
- `GITHUB_TOKEN` is unavailable for PR from forks, but Dependabot does not send
  PR from forks, so this is fine.

[Dependabot]: https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/keeping-your-dependencies-updated-automatically
