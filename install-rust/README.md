# install-rust

> [!NOTE]
> This action has been [replaced by `taiki-e/install-action`](https://github.com/taiki-e/install-action/pull/1779).

\[Deprecated] GitHub Action for installing Rust toolchain.

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

Equivalent to:

```yaml
- uses: taiki-e/install-action@7ea35f098a7369cd23488403f58be9c491a6c55f # v2.77.0
  with:
    tool: rust@stable + rustfmt + clippy + x86_64-unknown-linux-musl
```
