# Changelog

All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## `2026-02-28`

- Added a `withpass` script to read passwords from standard input and pass them
  to a command as an environment variable.
  ([#687](https://github.com/ianlewis/dotfiles/issues/687).

## `2026-02-25`

- Added `krew` as a global CLI tool.

## `2026-02-02`

- Added `k9s` as a global CLI tool
  ([#663](https://github.com/ianlewis/dotfiles/issues/663).

## `2026-01-28`

- Added syntax highlighting for `CODEOWNERS` files in Neovim
  ([#665](https://github.com/ianlewis/dotfiles/issues/665).

## `2026-01-27`

- Updated Neovim LSP key mappings
  ([#668](https://github.com/ianlewis/dotfiles/issues/668).

    `gd` -> `grd` to better match the default key mappings.
    Remove `gi` mapping in deference to default `gri` mapping.

## `2026-01-23`

- Added `yarn` as a global CLI tool
  ([#666](https://github.com/ianlewis/dotfiles/issues/666).

## `2026-01-16`

- Added `bazel` as a global CLI tool
  ([#661](https://github.com/ianlewis/dotfiles/issues/661).

## `2025-12-31`

- Added Japanese friendly fonts for Ghostty
  ([#636](https://github.com/ianlewis/dotfiles/issues/636).

## `2025-12-28`

- Added [`buf`](https://github.com/bufbuild/buf) as a global CLI tool
  ([#613](https://github.com/ianlewis/dotfiles/issues/613).

## `2025-12-18`

- Added [`dysk`](https://github.com/Canop/dysk) as a global CLI tool
  ([#626](https://github.com/ianlewis/dotfiles/pull/625).

## `2025-12-16`

- Added [`goimports`](https://pkg.go.dev/golang.org/x/tools/cmd/goimports) and
  [`gci`](https://github.com/daixiang0/gci) as a global CLI tools
  ([#623](https://github.com/ianlewis/dotfiles/pull/623).

## `2025-12-04`

- Added [`crictl`](https://github.com/kubernetes-sigs/cri-tools) as a global CLI
  tool ([#603](https://github.com/ianlewis/dotfiles/pull/603).

## `2025-12-02`

- Added the `aws` CLI and `gcloud` CLI as global CLI tools
  ([#602](https://github.com/ianlewis/dotfiles/pull/602)).

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
