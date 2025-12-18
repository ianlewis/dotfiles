# `AGENTS.md`

This file provides guidance to Coding Agents like Claude Code
([`claude.ai/code`](https://claude.ai/code)) or GitHub Copilot when working with
code in this repository.

## Overview

This is Ian's personal dotfiles repository for configuring development
environments on Linux and macOS. The repository uses symbolic links to install
configuration files from the git checkout into the home directory, making it
easy to test and update configurations.

## Common Commands

### Installation and Setup

```shell
# Install everything (tools, runtimes, and configuration)
make all

# Install only tools and runtimes
make install

# Configure only (create symlinks, no installation)
make configure
```

### Testing

```shell
# Run all tests (linting + unit + e2e)
make test

# Run only unit tests
make unit-test
make bats-unit

# Run only end-to-end tests
make e2e-test
make bats-e2e
make nvim-checkhealth

# Run specific test file
./bash/test/bats/bin/bats bash/test/unit/gnu-getopt.bats
./bash/test/bats/bin/bats bash/test/e2e/bash.bats
```

### Linting

```shell
# Run all linters
make lint

# Run specific linters
make shellcheck      # Shell scripts
make selene          # Lua files
make markdownlint    # Markdown files
make yamllint        # YAML files
make actionlint      # GitHub Actions workflows
make textlint        # Text/markdown prose
make checkmake       # Makefile
make commitlint      # Commit messages
```

### Formatting

```shell
# Format all files
make format

# Format specific file types
make shfmt           # Bash files
make lua-format      # Lua files (uses stylua)
make md-format       # Markdown files
make yaml-format     # YAML files
make json-format     # JSON files
make license-headers # Update license headers
```

### Installing Individual Components

```shell
# Install language runtimes
make install-go       # Go runtime to ~/opt/go
make install-python   # Python via pyenv
make install-node     # Node.js via nodenv
make install-ruby     # Ruby via rbenv

# Configure individual tools
make configure-bash
make configure-nvim
make configure-tmux
make configure-git
make configure-aqua
```

### Maintenance

```shell
# Show outstanding TODOs/FIXMEs
make todos

# Clean temporary build artifacts
make clean
```

## Architecture

### Makefile-Driven Installation

The entire installation and configuration system is driven by the root
`Makefile`. It handles:

- Platform detection (Linux/macOS, AMD64/ARM64)
- Downloading and verifying tools with checksums
- Creating proper XDG directory structure
- Symbolic linking configuration files
- Installing language runtimes with version managers

### Directory Structure

```text
bash/           # Bash configuration and prompt
  _bashrc       # Main bashrc loaded by Bash
  _bash_profile # Bash profile for login shells
  _bash_aliases # Shell aliases
  _bash_completion # Custom completions
  lib/          # Third-party Bash libraries
  test/         # Bats tests (unit + e2e)

nvim/           # Neovim configuration
  init.lua      # Entry point, loads lua/ianlewis/
  lua/ianlewis/ # Main Neovim config modules
  pack/nvim/start/ # Neovim plugins (git submodules)

tmux/           # Tmux configuration
  _tmux.conf    # Main tmux config
  _tmux/        # Tmux plugins

git/            # Git configuration
  _gitconfig    # Global git config

aqua/           # Aqua tool configuration
  aqua.yaml     # Aqua package definitions

bin/all/        # Custom scripts installed to ~/.local/bin

efm-langserver/ # EFM language server config for Neovim LSP
```

### Tool Installation Strategy

**Project-local tools** (for maintaining this dotfiles repository):

- Installed via `package.json` (Node), `requirements-dev.txt` (Python),
  `.aqua.yaml`
- Used by `make lint` and `make format`
- Not installed globally

**User tools** (for general development):

- Installed globally for everyday use
- Node.js tools: `nodenv/package.json` → `~/.local/share/node_modules`
- Python tools: `requirements.txt` → `pyenv virtualenv` named after `$USER`
- CLI tools: `aqua/aqua.yaml` → `~/.local/share/aquaproj-aqua/bin`

### Language Runtime Management

- **Go**: Installed to `~/opt/go-{VERSION}` with symlink at `~/opt/go`.
  `GOBIN=~/opt/go/bin`.
- **Python**: Managed by `pyenv` in `~/.local/share/pyenv`. Creates virtualenv
  named after `$USER`.
- **Node.js**: Managed by `nodenv` in `~/.local/share/nodenv`. Version from
  `.node-version`.
- **Ruby**: Managed by `rbenv` in `~/.local/share/rbenv`. Version from
  `.ruby-version`.

All runtime binaries are added to `$PATH` via bash configuration.

### Neovim Architecture

Entry: `nvim/init.lua` loads `lua/ianlewis/init.lua`

Modules loaded in order:

1. `globals.lua` - Global variables and functions
2. `filetype.lua` - Filetype detection
3. `options.lua` - Vim options (set commands)
4. `autocmd.lua` - Autocommands
5. `colors.lua` - Color scheme (Tokyo Night)
6. `remap.lua` - Key mappings

Plugins: Installed as git submodules in `nvim/pack/nvim/start/`. Each plugin
auto-loads on Neovim startup. Key plugins include:

- LSP: `nvim-lspconfig`, `efmls-configs-nvim`
- Completion: `nvim-cmp`, `cmp-nvim-lsp`
- Treesitter: `nvim-treesitter`
- Fuzzy finding: `telescope.nvim`, `telescope-fzf-native.nvim`
- Git: `diffview.nvim`
- UI: `lualine.nvim`, `trouble.nvim`, `tokyonight.nvim`
- Editing: `nvim-surround`, `Comment.nvim`, `copilot.vim`

### Testing Architecture

Tests use the [Bats](https://github.com/bats-core/bats-core) testing framework.

**Unit tests** (`bash/test/unit/`):

- Test individual Bash functions in isolation
- Run against current environment
- Execute with: `make bats-unit`

**End-to-end tests** (`bash/test/e2e/`):

- Test full installation in isolated temporary HOME directory
- Each test file validates a specific component (`bash`, `nvim`, `tmux`, etc.)
- Environment set up via `$(E2E_HOME)/.installed` target
- Execute with: `make bats-e2e`
- Special e2e test: `nvim-checkhealth` runs Neovim's `:checkhealth` in clean
  environment

### XDG Base Directory Compliance

The dotfiles follow XDG Base Directory specification:

- `XDG_CONFIG_HOME` (default: `~/.config`) - configuration files
- `XDG_DATA_HOME` (default: `~/.local/share`) - data files
- `XDG_STATE_HOME` (default: `~/.local/state`) - state files
- `XDG_BIN_HOME` (default: `~/.local/bin`) - user binaries

### Continuous Integration

GitHub Actions workflows in `.github/workflows/`:

- `pull_request.tests.yml` - Main PR checks (calls other `workflow_call.*.yml`
  files)
- `workflow_call.*.yml` - Reusable workflows for specific linters/tests
- `schedule.*.yml` - Scheduled tasks (stale issues, Scorecard, etc.)

Status checks must pass before PR merge. Most checks run the corresponding
`make` target.

## Development Guidelines

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code restructuring
- `style:` - Formatting changes
- `test:` - Test additions/fixes
- `ci:` - CI/CD changes

Include DCO sign-off: `git commit --signoff`

### Adding New Tools

1. For CLI tools: Add to `aqua/aqua.yaml` with version pinning
2. For Node.js tools: Add to appropriate `package.json` (project or global)
3. For Python tools: Add to appropriate `requirements.txt` with hash
4. Update checksums: `make aqua/aqua-checksums.json` or re-generate
   `package-lock.json`

### Modifying Bash Configuration

- Main logic goes in `bash/_bashrc`
- Keep functions prefixed with `_bashrc_` to avoid namespace pollution
- Test changes with `make bats-unit` and `make bats-e2e`
- Bash files must pass `shellcheck` with `--severity=style`

### Modifying Neovim Configuration

- Configuration changes go in `nvim/lua/ianlewis/*.lua`
- Plugin additions: Add as git submodule in `nvim/pack/nvim/start/`
- LSP configuration: Use `nvim-lspconfig` and `efmls-configs-nvim`
- Test with `make nvim-checkhealth` to verify no errors
- Lua files must pass `selene` linter

### Platform Compatibility

- Primary platforms: Debian-based Linux, macOS on Apple Silicon
- Use GNU tools (prefer `ggrep`, `gawk`, etc. on macOS via Homebrew)
- Check `uname -s` for OS detection, `uname -m` for architecture
- Test platform-specific code on both Linux and macOS if possible
