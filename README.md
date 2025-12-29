# Actions and Reusable Workflows for GitHub Actions

This repository contains some [actions](https://docs.github.com/en/actions/creating-actions/about-custom-actions)
and [reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
used on CIs managed by @taiki-e.
There are no stability guarantees for these actions and workflows, since they're
supposed to only be used in infra managed by us.

## Actions

- [**free-device-space**](free-device-space): Free device space.
- [**install-rust**](install-rust): Install Rust toolchain.
- [**setup-docker**](setup-docker): Setup docker.

## Reusable workflows

- [**check-external-types**](.github/workflows/check-external-types.yml): Run `cargo check-external-types` in a way that respects the docs.rs metadata.
- [**docs**](.github/workflows/docs.yml): Run `cargo doc` in a way that is as similar to docs.rs as possible.
- [**fuzz**](.github/workflows/fuzz.yml): Build fuzzing code with `cargo fuzz`, `cargo afl`, and `cargo hfuzz`, and run fuzzing with them on scheduled run.
- [**miri**](.github/workflows/miri.yml): Run `cargo miri test` in strict mode.
- [**msrv**](.github/workflows/msrv.yml): Run MSRV (minimum supported Rust version) check in [a pedantic, time-consuming but highly accurate way](https://github.com/taiki-e/cargo-hack/issues/93).
- [**rust-release**](.github/workflows/rust-release.yml): Create and push the release commit and tag, create GitHub release, and publish crates.
- [**release-dry-run**](.github/workflows/release-dry-run.yml): Build Rust binaries based on release workflow.
- [**test**](.github/workflows/test.yml): Run `cargo test` `cargo careful test` + `cargo hack build --feature-powerset` + `cargo minimal-versions build`.
- [**tidy**](.github/workflows/tidy.yml): Run various checks.

## Moved or removed actions

These actions were previously included in this repository but have been moved into their own repository because they were considered stable enough.

- **checkout**: moved into the
  [**checkout-action**][checkout-action] repository.
- **create-release**: moved into the
  [**create-gh-release-action**][create-gh-release-action] repository.
- **install**: moved into the
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
