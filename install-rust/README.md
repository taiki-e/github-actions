# install-rust

GitHub Action for installing Rust toolchain.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

See [action.yml](action.yml)

```yaml
- uses: taiki-e/github-actions/install-rust@main
  with:
    # Default toolchain to install, default is nightly
    toolchain: stable
    # Component to install
    component: rustfmt
```

If the toolchain is nightly (default) and the component is specified, this
script will install the latest nightly toolchain that the specified component
is available.
