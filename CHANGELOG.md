# Changelog

All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## `2025-12-04`

- Added `crictl` to the default set of installed tools.

## `2025-12-02`

- Added the `aws` CLI and `gcloud` CLI to the default set of installed tools.

## `2025-11-29`

- Bash: Add a new `tw` alias for creating temporary workspace directories under
  `${HOME}/.tmp/workspace/`
  ([#577](https://github.com/ianlewis/dotfiles/issues/577)).

## `2025-11-28`

- `cron`: Add support for loading user-specific `crontab` files in the
  `~/.config/dotfiles/crontab/` directory.

## `2025-11-26`

- Bash: Add support for Bash completion on macOS
  ([#564](https://github.com/ianlewis/dotfiles/issues/564)).
- `clone`: Add support for creating new repositories in the `clone` script.
- `cron`: Add support for loading the user `crontab`
  ([#503](https://github.com/ianlewis/dotfiles/issues/503)).

<!-- TODO(#566): Add missing entries -->

## `2025-10-16`

- Git: Add a `git amend` alias to amend the last commit
  ([#427](https://github.com/ianlewis/dotfiles/issues/427)).
- Git: Add a `git undo` alias to undo the last commit.
- Git: Add a `git unstage` alias to unstage files from the index.

## `2025-10-04`

- Neovim: Search hidden directories and files with telescope's `live_grep`
  feature ([#407](https://github.com/ianlewis/dotfiles/issues/407)).

## `2025-10-03`

- Neovim: Format and sort Python imports with `ruff`
  ([#396](https://github.com/ianlewis/dotfiles/issues/396)).

## `2025-09-27`

- CLI: Removed `flake8` as a dependency. Configuration was removed and the
  command will no longer be available
  ([#379](https://github.com/ianlewis/dotfiles/issues/379)).
- Neovim: Added Rust to Markdown fenced languages
  ([#376](https://github.com/ianlewis/dotfiles/issues/376)).
