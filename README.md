# Ian's dotfiles

[![tests](https://github.com/ianlewis/dotfiles/actions/workflows/pre-submit.units.yml/badge.svg)](https://github.com/ianlewis/dotfiles/actions/workflows/pre-submit.units.yml) [![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/ianlewis/dotfiles/badge)](https://securityscorecards.dev/viewer/?uri=github.com%2Fianlewis%2Fdotfiles)

These dotfiles were originally based on [Armin Ronacher's
dotfiles](https://github.com/mitsuhiko/dotfiles) where the many ideas were
copied shamelessly. Files are symbolically linked from the git checkout into the
home directory which makes it easy to test out configuration.

<table>
  <tr>
    <td>
        <img src="nvim/nvim.png" alt="Neovim Screenshot" width="300"/>
    </td>
    <td>
        <img src="tmux/tmux.png" alt="Tmux Screenshot" width="530"/>
    </td>
   </tr>
</table>

## Install

Dotfiles are installed using a simple Makefile in the root directory.

```shell
$ make
dotfiles Makefile
Usage: make [COMMAND]

  help                      Print all Makefile targets (this message).
  all                       Install and configure everything.
  configure-all             Configure all tools.
  install-all               Install all tools.
Tools
  license-headers           Update license headers.
Formatting
  format                    Format all files
  json-format               Format JSON files.
  lua-format                Format Lua files.
  md-format                 Format Markdown files.
  shfmt                     Format bash files.
  yaml-format               Format YAML files.
Linting
  lint                      Run all linters.
  actionlint                Runs the actionlint linter.
  zizmor                    Runs the zizmor linter.
  markdownlint              Runs the markdownlint linter.
  renovate-config-validator Validate Renovate configuration.
  selene                    Runs the selene (Lua) linter.
  textlint                  Runs the textlint linter.
  yamllint                  Runs the yamllint linter.
  shellcheck                Runs the shellcheck linter.
Base Tools
  install-bin               Install binary scripts.
  configure-bash            Configure bash.
  configure-aqua            Configure aqua.
  configure-efm-langserver  Configure efm-langserver.
  configure-nvim            Configure neovim.
  configure-tmux            Configure tmux.
  configure-git             Configure git.
Install Tools
  install-slsa-verifier     Install slsa-verifier
  install-aqua              Install aqua and aqua-managed CLI tools
Language Runtimes
  install-go                Install the Go runtime.
  install-node              Install the Node.js runtime.
Maintenance
  clean                     Delete temporary files.
```

Run `make all` to install tools and configuration files.

## Tools

It is necessary to distinguish between tools like linters and formatters used
for linting and formatting files in the `dotfiles` project directory, and those
installed globally for general use.

### Project-local tools

Project-local tools are installed and run in the project directory via the `make
lint`, `make format`, and `make license-header` commands.

### General use tools

Tools like language runtimes, linters, and formatters installed for general use
can be installed via the respective `make` targets. For example, `make
install-yamllint`.

Tools are installed in several places.

- Tools installed via Python like `yamllint` are installed in a Python venv in
  the home directory under `~/.local/share/venv`.
- Tools written in JavaScript/TypeScript are installed globally by `npm`.
- Pre-compiled binary tools are installed via
  [`Aqua`](https://aquaproj.github.io/) to the `.local/share/aquaproj-aqua`
  directory.

## Language Runtimes

Language runtimes are installed in the `~/opt` directory. Their binaries
directory is added to the `$PATH`.

## Bash

`.bashrc` and `.bash_profile` scripts are included in the [`bash`](./bash)
directory. Various scripts for different purposes are broken into separate
files, such as `.bash_aliases` and `.bash_completion`.

## Neovim

Neovim configuration is contained in the [`nvim`](./nvim) directory.

## Tmux

Tmux configuration is contained in the [`tmux`](./tmux) directory.

## Compatibility

The scripts here should work on Linux. I have tested them mostly on Debian-based
systems. YMMV.
