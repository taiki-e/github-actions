# install-rust

GitHub Action for installing Rust toolchain.
There is no stability guarantee for this action, since it's supposed to only be
used in infra managed by us.

## Usage

See [action.yml](action.yml)

```yaml
- uses: taiki-e/github-actions/install-rust@main
  with:
    # Default toolchain to install.
    toolchain: stable
    # Components to add (comma-separated), default is empty.
    component: rustfmt,clippy
    # Targets to add (comma-separated), default is empty.
    target: x86_64-unknown-linux-musl
```
