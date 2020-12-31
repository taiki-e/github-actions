# create-release

GitHub Action for creating GitHub Releases based on changelog.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

See [action.yml](action.yml)

### Example workflow

```yaml
name: Release

on:
  push:
    tags:
      - "v*"

jobs:
  create-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: taiki-e/github-actions/create-release@main
        with:
          # Path to changelog, default is CHANGELOG.md.
          changelog: CHANGELOG.md
        env:
          # (required)
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- This script uses [parse-changelog] to parse changelog.
- The valid tag format is `v?MAJOR.MINOR.PATCH(-PRERELEASE)?(+BUILD_METADATA)?`.
  (leading "v", pre-release version, and build metadata are optional.)
  This is based on [Semantic Versioning][semver]

[parse-changelog]: https://github.com/taiki-e/parse-changelog
[semver]: https://semver.org
