# deploy-gh-pages

GitHub Action for deploying GitHub Pages.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

See [action.yml](action.yml)

```yaml
- uses: taiki-e/github-actions/deploy-gh-pages@main
  with:
    # Directory to deploy
    deploy_dir: target/doc
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
