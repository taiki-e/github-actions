# Actions and Reusable Workflows for GitHub Actions

This repository contains some [actions](https://docs.github.com/en/actions/creating-actions/about-custom-actions)
and [reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
used on CIs managed by @taiki-e.

There are no stability guarantees for these actions and workflows, since they're
supposed to only be used in infra managed by us.

## Actions

- [**free-device-space**](free-device-space): Free device space.
- [**push**](push): Push branch or tag.
- [**setup-docker**](setup-docker): Setup docker.

## Reusable workflows

- [**action-release**](.github/workflows/action-release.yml): Create and push the release commit and tag, and create GitHub release.
- [**gen**](.github/workflows/gen.yml): Run code generator and open PR if new change available.
- [**rust-release**](.github/workflows/rust-release.yml): Create and push the release commit and tag, publish crates, create GitHub release, and optionally upload binaries.
- [**rust-test**](.github/workflows/rust-test.yml): Run various builds/tests for Rust code. (`cargo test`, `cargo careful test`, `cargo hack build --feature-powerset`, `cargo minimal-versions build`, and the following reusable workflows if setup exists)
  - [**rust-fuzz**](.github/workflows/rust-fuzz.yml): Run fuzzing with `cargo fuzz`, `cargo afl`, and `cargo hfuzz`.
  - [**rust-miri**](.github/workflows/rust-miri.yml): Run `cargo miri test` in strict mode.
  - [**rust-msrv**](.github/workflows/rust-msrv.yml): Run MSRV (minimum supported Rust version) check in [a pedantic, time-consuming but highly accurate way](https://github.com/taiki-e/cargo-hack/issues/93).
  - [**rust-release-dry-run**](.github/workflows/rust-release-dry-run.yml): Build Rust binaries based on release workflow.
- [**tidy**](.github/workflows/tidy.yml): Run various checks (including the following reusable workflows).
  - [**rust-check-external-types**](.github/workflows/rust-check-external-types.yml): Run `cargo check-external-types` in a way that respects the docs.rs metadata.
  - [**rust-clippy**](.github/workflows/rust-clippy.yml): Run `cargo clippy` and apply clippy for doctest.
  - [**rust-docs**](.github/workflows/rust-docs.yml): Run `cargo doc` in a way that is as similar to docs.rs as possible.

## Moved or removed actions

These actions were previously included in this repository but have been moved into their own repository because they were considered stable enough.

- **checkout**: moved into the
  [**checkout-action**][checkout-action] repository.
- **create-release**: moved into the
  [**create-gh-release-action**][create-gh-release-action] repository.
- **install**: moved into the
  [**install-action**][install-action] repository.
- **install-rust**: merged into the
  [**install-action**][install-action] repository.
- **upload-rust-binary**: moved into the
  [**upload-rust-binary-action**][upload-rust-binary-action] repository.

These actions were previously included in this repository but have been removed.

- **deploy-gh-pages**: removed because no longer used.
- **update-dependabot-pr**: removed because no longer used.

[checkout-action]: https://github.com/taiki-e/checkout-action
[create-gh-release-action]: https://github.com/taiki-e/create-gh-release-action
[install-action]: https://github.com/taiki-e/install-action
[upload-rust-binary-action]: https://github.com/taiki-e/upload-rust-binary-action

## License

Licensed under either of [Apache License, Version 2.0](LICENSE-APACHE) or
[MIT license](LICENSE-MIT) at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall
be dual licensed as above, without any additional terms or conditions.
