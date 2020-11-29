# create-release

GitHub Action for creating GitHub Releases.
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

- This script assumes that the format (file name and title of section) of
  release notes is based on [Keep a Changelog](https://keepachangelog.com).
- The valid tag format is `vMAJOR.MINOR.PATCH(-PRERELEASE)(+BUILD_METADATA)`
  This is based on [Semantic Versioning](https://semver.org)
