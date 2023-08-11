# GitHub Actions

This repository contains some shared [GitHub Actions][actions] used on CIs
managed by @taiki-e.
There are no stability guarantees for these actions, since they're supposed to
only be used in infra managed by us.

- [**deploy-gh-pages**](deploy-gh-pages): deploys GitHub Pages.
- [**free-device-space**](free-device-space): frees device space.

## Moved Actions

These actions were previously included in this repository but have been moved into their own repository because they were considered stable enough.

- **create-release**: moved into the
  [**create-gh-release-action**][create-gh-release-action] repository.
- **install**: moved into the
  [**install-action**][install-action] repository.
- **upload-rust-binary**: moved into the
  [**upload-rust-binary-action**][upload-rust-binary-action] repository.

## Removed Actions

These actions were previously included in this repository but have been removed in favor of other actions.

- **install-rust**: removed in favor of calling `rustup` directly.
- **update-dependabot-pr**: removed because no longer used.

[actions]: https://docs.github.com/en/free-pro-team@latest/actions/creating-actions/about-actions
[create-gh-release-action]: https://github.com/taiki-e/create-gh-release-action
[install-action]: https://github.com/taiki-e/install-action
[upload-rust-binary-action]: https://github.com/taiki-e/upload-rust-binary-action

## License

Licensed under either of [Apache License, Version 2.0](LICENSE-APACHE) or
[MIT license](LICENSE-MIT) at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall
be dual licensed as above, without any additional terms or conditions.
