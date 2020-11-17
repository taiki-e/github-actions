# install-rust

The `install-rust` action installs Rust toolchain.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

```yaml
- uses: taiki-e/github-actions/install-rust@main
  with:
    # Default toolchain to install, default value is nightly
    # If the toolchain is nightly (default) and the component is specified,
    # this script will install the latest nightly toolchain that the specified
    # component is available.
    toolchain: stable
    # Component to install
    component: rustfmt
```
