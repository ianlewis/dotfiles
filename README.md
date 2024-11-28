# Ian's dotfiles

[![tests](https://github.com/ianlewis/dotfiles/actions/workflows/pre-submit.units.yml/badge.svg)](https://github.com/ianlewis/dotfiles/actions/workflows/pre-submit.units.yml)

These dotfiles are based on [Armin Ronacher's dotfiles](https://github.com/mitsuhiko/dotfiles)
where the many ideas were copied shamelessly.

## Install

Dotfiles are installed using a simple Makefile in the root directory. Just run
`make` to install the files.

## Tools

Tools like language runtimes, linters, and formatters can be installed via the
respective `make` targets. For example, `make install-shellcheck`. Tools are
installed in the `~/opt` directory. Supported tools are added to the path by
`.bashrc`.

## Compatibility

The scripts here should work on Linux. I have tested them mostly on
Debian-based systems. YMMV.
