# install

GitHub Action for installing tools.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

See [action.yml](action.yml)

```yaml
- uses: taiki-e/github-actions/install@main
  with:
    # Tools to install (comma-separated)
    tool: cargo-hack
```
