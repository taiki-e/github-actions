# push

GitHub Action for pushing branch or tag.

There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

See [action.yml](action.yml)

```yaml
- uses: taiki-e/github-actions/push@main
  with:
    # Ref to push.
    ref: refs/heads/my-branch
```
