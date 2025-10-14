# Neovim Configuration

This directory contains my Neovim configuration. It gets symbolically linked to
`~/.config/nvim`.

![Neovim](./nvim.png)

## Features

- [Tokyo Night](https://github.com/folke/tokyonight.nvim) color scheme.
- Auto-formatting code on save and completion via LSP servers.
- LSP server support for:
    - [`bash-language-server`](https://github.com/bash-lsp/bash-language-server):
      LSP server for Bash supporting `shellcheck` and `shfmt`.
    - [`efm-langserver`](https://github.com/mattn/efm-langserver): Formatting
      and linting for a variety languages via CLI tools.
    - [`eslint-language-server`](https://github.com/hrsh7th/vscode-langservers-extracted):
      Linting and auto-fixing for `javascript` and `typescript`.
    - [`gopls`](https://github.com/golang/tools/tree/master/gopls): LSP server
      for Go.
    - [`harper-ls`](https://writewithharper.com/docs/integrations/language-server):
      LSP server for the [Harper](https://writewithharper.com/) grammar and
      spelling checker.
    - [`lua-language-server`](https://github.com/luals/lua-language-server): LSP
      server for Lua.
    - [`python-lsp-server`](https://github.com/python-lsp/python-lsp-server):
      LSP server for Python.
    - [`rust-analyzer`](https://rust-analyzer.github.io/): LSP server for Rust.
    - [`typescript-language-server`](https://github.com/typescript-language-server/typescript-language-server):
      LSP server for TypeScript.
- Convenient [key mappings](./lua/ianlewis/remap.lua) for common actions.
- Language specific filetype settings in [`after/ftplugin`](./after/ftplugin).
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

All tools required for plugins should be installed via the Makefile. See the
root [`README.md`](../README.md#install) for details.

After installation, you do need to compile the `telescope-fzf-native.nvim`
plug-in manually to get improved performance for search.

```shell
$ cd nvim/pack/nvim/start/telescope-fzf-native.nvim
$ make
mkdir -p build
cc -O3 -Wall -fpic -std=gnu99 -shared src/fzf.c -o build/libfzf.so
```

## Layout

### `after/plugin`

[`after/plugin`](after/plugin/) contains files that configure various plugins.

### `after/ftplugin`

[`after/ftplugin/`](after/ftplugin/) contains files that set filetype specific
options.

### `lua/ianlewis`

[`lua/ianlewis`](lua/ianlewis/) contains configuration for global options,
filetypes, colors, key remappings, etc.

### `pack/nvim/start`

[`pack/nvim/start`](pack/nvim/start) contains git submodules for the various
plugins that I use. These are loaded automatically at startup. The plugins are
then configured by code in `after/plugin`.
