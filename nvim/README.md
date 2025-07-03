# Neovim Configuration

This directory contains my Neovim configuration. It gets symbolically linked to
`~/.config/nvim`.

![Neovim](./nvim.png)

## Features

- [Tokyo Night](https://github.com/folke/tokyonight.nvim) color scheme.
- Auto-formatting code on save.
- Auto-installation and configuration of required linting tools, formatting
  tools, and LSP servers via [Mason](https://github.com/mason-org/mason.nvim)
  and
  [`mason-lspconfig.nvim`](https://github.com/mason-org/mason-lspconfig.nvim).
- LSP server support for:
    - [`efm-langserver`](https://github.com/mattn/efm-langserver) (formatting,
      linting): `css`, `html`, `javascript`, `json`, `json5`, `markdown`,
      `liquid`, `lua`, `scss`, `terraform`, `typescript`, `yaml`, and GitHub
      Actions workflows (YAML).
    - [`eslint-language-server`](https://github.com/hrsh7th/vscode-langservers-extracted):
      Linting and auto-fixing for `javascript` and `typescript`.
    - [`gopls`](https://github.com/golang/tools/tree/master/gopls): LSP server
      for Go.
    - [`lua-language-server`](https://github.com/luals/lua-language-server): LSP
      server for Lua.
    - [`python-lsp-server`](https://github.com/python-lsp/python-lsp-server):
      LSP server for Python.
    - [`rust-analyzer`](https://rust-analyzer.github.io/): LSP server for Rust.
    - [`typescript-language-server`](https://github.com/typescript-language-server/typescript-language-server):
      LSP server for TypeScript.

- Convenient [key mappings](./lua/ianlewis/remap.lua) for common actions.
- Language specific file type settings in [`after/ftplugin`](./after/ftplugin).
- Status line by [`lualine.nvim`](https://github.com/nvim-lualine/lualine.nvim).
- Syntax highlighting and language introspection support via
  [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter).
- Linting error diagnostic visualization support via
  [`trouble.nvim`](https://github.com/folke/trouble.nvim).
- File searching via
  [`telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim).
- Undo management via [`undotree`](https://github.com/mbbill/undotree).

## Requirements

- [Neovim](https://neovim.io) 0.11.1 or later (it may work with earlier
  versions, but it has not been tested).
- A C compiler (e.g., `gcc` or `clang`) to build some plugins (e.g.
  [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter)).

## Installation

All tools required for plugins should be installed automatically at startup.

You do need to compile the `telescope-fzf-native.nvim` plugin manually.

```shell
$ cd nvim/pack/nvim/start/telescope-fzf-native.nvim
$ make
mkdir -p build
cc -O3 -Wall -fpic -std=gnu99 -shared src/fzf.c -o build/libfzf.so
```

## Layout

### `after/plugin`

This directory contains files that configure various plugins.

### `after/ftplugin`

`after/ftplugin/` contains files that set file type specific options.

### `lua/ianlewis`

`lua/ianlewis` contains setup for mason packages, global options, filetypes,
colors, key remappings, etc.

### `pack/nvim/start`

`pack/nvim/start` contains git submodules for the various plugins that I use.
These are loaded automatically at startup. The plugins are then configured by
code in `after/plugin`.

## LSP Servers

LSP Servers are installed as
[`mason.nvim`](https://github.com/williamboman/mason.nvim) packages via
[`mason-lspconfig`](https://github.com/williamboman/mason-lspconfig.nvim). This
configures the servers to work with
[`nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig).

- `bash-language-server`
- `efm-langserver`
- `gopls`
- `lua-language-server`
- `python-lsp-server`
- `rust_analyzer`
- `vscode-eslint-language-server`
- `typescript-language-server`
- [`undotree`](https://github.com/mbbill/undotree)
