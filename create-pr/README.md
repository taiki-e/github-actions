# create-pr

GitHub Action for creating PR.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

### Example workflow

```yaml
- uses: taiki-e/github-actions/create-pr@main
  with:
    # (required)
    branch: ...
    # (required)
    token: ${{ secrets.GITHUB_TOKEN }}
```
