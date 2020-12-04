# upload-rust-binary

GitHub Action for building and uploading Rust binary to GitHub Releases.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

See [action.yml](action.yml)

### Example workflow

```yaml
name: Release

on:
  release:
    types: [created]

jobs:
  upload-assets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: taiki-e/github-actions/upload-rust-binary@main
        with:
          # Binary name to build and upload (required).
          bin: ...
          # Target name, default is host triple.
          target: ...
          # On which platform to distribute the `.tar.gz` file.
          # [default value: all]
          # [possible values: all, unix, windows, none]
          tar: unix
          # On which platform to distribute the `.zip` file.
          # [default value: none]
          # [possible values: all, unix, windows, none]
          zip: windows
        env:
          # (required)
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          # (not required)
          CARGO_PROFILE_RELEASE_LTO: true
```
