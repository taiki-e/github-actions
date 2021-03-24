# GitHub Actions

This repository contains some shared [GitHub Actions][actions] used on CIs
managed by @taiki-e.
There are no stability guarantees for these actions, since they're supposed to
only be used in infra managed by us.

- [**install-rust**](install-rust): installs Rust toolchain and component.
- [**update-dependabot-pr**](update-dependabot-pr): replaces PR description with
  the message of the first commit.
- [**deploy-gh-pages**](deploy-gh-pages): deploys GitHub Pages.

## Moved Actions

These actions were previously included in this repository but have been moved into their own repository because they were considered stable enough.

- **create-release**: moved into the
  [**create-gh-release-action**][create-gh-release-action] repository.
- **upload-rust-binary**: moved into the
  [**upload-rust-binary-action**][upload-rust-binary-action] repository.

[actions]: https://docs.github.com/en/free-pro-team@latest/actions/creating-actions/about-actions
[create-gh-release-action]: https://github.com/taiki-e/create-gh-release-action
[upload-rust-binary-action]: https://github.com/taiki-e/upload-rust-binary-action

## Development

- [GitHub Actions Reference](https://docs.github.com/en/actions/reference)
- [GitHub CLI Manual](https://cli.github.com/manual)

## License

Licensed under either of [Apache License, Version 2.0](LICENSE-APACHE) or
[MIT license](LICENSE-MIT) at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall
be dual licensed as above, without any additional terms or conditions.
