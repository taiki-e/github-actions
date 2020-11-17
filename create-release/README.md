# create-release

The `create-release` action creates a new GitHub release.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

### Example workflow

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  create-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: taiki-e/github-actions/create-release@main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
