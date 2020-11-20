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

- The generated note format is:
  `See the [release notes]($LINK_TO_CHANGELOG) for a complete list of changes.`
- The generated link format is:
  `https://github.com/$GITHUB_REPOSITORY/blob/HEAD/CHANGELOG.md#${TAG/v/}---${RELEASE_DATE}`
- This script assumes that the format (file name and title of section) of
  release notes is based on [Keep a Changelog](https://keepachangelog.com).
- The valid tag format is `vMAJOR.MINOR.PATCH(-PRERELEASE)(+BUILD_METADATA)`
  This is based on [Semantic Versioning](https://semver.org)
- The release date is based on the time this script was run, the time zone is
  the UTC.
- The generated link to the release notes will be broken when the version
  yanked if the project adheres to the Keep a Changelog's yanking style.
  Consider adding a note like the following instead of using the `[YANKED]` tag:
  `**Note: This release has been yanked.** See $LINK_TO_YANKED_REASON for details.`
