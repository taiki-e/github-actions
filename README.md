# GitHub Actions

This repository contains some shared [GitHub Actions][actions] used on CIs
managed by @taiki-e.
There are no stability guarantees for these actions, since they're supposed to
only be used in infra managed by us.

* [**create-release**](create-release): creates a new GitHub release based on
  changelog.
* [**install-rust**](install-rust): installs Rust toolchain and component.
* [**update-dependabot-pr**](update-dependabot-pr): replaces PR description with
  the message of the first commit.
* [**upload-rust-binary**](upload-rust-binary): builds and uploads Rust binary
  to GitHub Releases.

[actions]: https://docs.github.com/en/free-pro-team@latest/actions/creating-actions/about-actions

## License

Licensed under either of [Apache License, Version 2.0](LICENSE-APACHE) or
[MIT license](LICENSE-MIT) at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall
be dual licensed as above, without any additional terms or conditions.
