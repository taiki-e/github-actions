# update-dependabot-pr

The `update-dependabot-pr` action replaces PR description with the message of the first commit.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

**Motivation**:

[Dependabot] creates a very verbose PR description by default. And there is
currently no way to configure this.

## Usage

See [action.yml](action.yml)

### Example workflow

```yaml
name: Dependabot PR

on:
  # This should not be pull_request_target because this action gets the PR number from GITHUB_REF.
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
          # GITHUB_TOKEN is unavailable for PR from the fork, but Dependabot does not send PR from the fork, so this is fine.
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

[Dependabot]: https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/keeping-your-dependencies-updated-automatically
