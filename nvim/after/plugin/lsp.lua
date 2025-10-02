-- vim:foldmethod=marker:
-- Copyright 2024 Ian Lewis
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local lspconfig = require("lspconfig")

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Jump to definition even if in another file.
		local bufopts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
		vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, bufopts)
		vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, bufopts)
	end,
})

-- completion {{{
local cmp = require("cmp")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

cmp.setup({
	sources = {
		{
			name = "nvim_lsp",
		},
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		-- <C-n> = next
		-- <C-p> = previous
		-- <C-e> = abort
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
})

local cmp_capabilities = cmp_nvim_lsp.default_capabilities()
-- }}}

-- {{{ bash-language-server
lspconfig.bashls.setup({
	capabilities = cmp_capabilities,
	-- TODO(#109): Use a local explainshell instance.
	-- settings = {
	-- 	bashIde = {
	-- 		explainshellEndpoint = "https://explainshell.com",
	-- 	},
	-- },
})
-- }}}

-- efm-langserver {{{

-- formatters {{{
local prettier = require("efmls-configs.formatters.prettier")
local stylua = require("efmls-configs.formatters.stylua")
local tofuFmt = {
	formatCommand = "tofu fmt -",
	formatStdin = true,
}
-- }}}

-- linters {{{
local actionlint = require("efmls-configs.linters.actionlint")
local hadolint = require("efmls-configs.linters.hadolint")
local markdownlint = require("efmls-configs.linters.markdownlint")
local selene = require("efmls-configs.linters.selene")
local stylelint = require("efmls-configs.linters.stylelint")
local yamllint = require("efmls-configs.linters.yamllint")

local todos = {
	prefix = "todos",
	lintCommand = "todos",
	lintStdin = false,
	lintIgnoreExitCode = true,
	lintSeverity = 2, -- 2 = warning
	lintFormats = {
		"%f:%l:%m",
	},
}
-- }}}

lspconfig.efm.setup({
	init_options = { documentFormatting = true },
	settings = {
		rootMarkers = { ".git/" },

		languages = {
			-- NOTE: Go is handled by gopls server.
			--       golangci-lint isn't used because I usually have specific
			--       configuration per-project and checks analysis tools built
			--       into gopls are usually good enough for normal editing.
			sh = { todos },
			bash = { todos },
			conf = { todos },
			css = { prettier, stylelint, todos },
			dockerfile = { hadolint, todos },
			gitignore = { todos },
			go = { todos },
			html = { prettier, todos },
			javascript = { prettier, todos },
			json = { prettier, todos },
			json5 = { prettier, todos },
			markdown = { prettier, markdownlint, todos },
			-- NOTE: The @shopify/prettier-plugin-liquid plugin is required in
			-- the target project. Install it with:
			--
			--	 npm install --save-dev @shopify/prettier-plugin-liquid
			--
			-- Add the following to the project's
			-- package.json:
			--
			--   {
			--     "prettier": {
			--       "plugins": [
			--         "@shopify/prettier-plugin-liquid"
			--       ]
			--     }
			--   }
			--
			liquid = { prettier, todos },
			lua = { stylua, selene, todos },
			python = { todos },
			rust = { todos },
			scss = { prettier, stylelint, todos },
			terraform = { tofuFmt, todos },
			typescript = { prettier, todos },
			yaml = { prettier, yamllint, todos },
			["yaml.ghaction"] = { prettier, actionlint, yamllint, todos },
		},
	},
})
-- }}}

-- eslint-language-server {{{
lspconfig.eslint.setup({
	on_attach = function(_, bufnr)
		-- Fix all fixable problems on write.
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
})
-- }}}

-- gopls {{{
lspconfig.gopls.setup({
	capabilities = cmp_capabilities,
	filetypes = {
		"go",
		"gomod",
		"gowork",
		"gotmpl",
	},
	settings = {
		gopls = {
			analyses = {
				shadow = true,
				useany = true,
			},
			-- NOTE: The staticcheck setting is experimental and may be
			-- deleted.
			-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#staticcheck-bool
			staticcheck = true,
			gofumpt = true,
		},
	},
})
-- }}}

-- harper {{{
lspconfig.harper_ls.setup({})
-- }}}

-- lua_ls {{{
lspconfig.lua_ls.setup({
	format = {
		-- Disable CppCXY/EmmyLuaCodeStyle in favor of stylua via
		-- efm-langserver.
		enable = false,
	},
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					"${3rd}/luv/library", -- for vim.uv
					-- Depending on the usage, you might want to add additional
					-- paths here.
					-- "${3rd}/busted/library",
				},
				-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
				-- and will cause issues when working on your own configuration
				-- (see https://github.com/neovim/nvim-lspconfig/issues/3189)
				-- library = vim.api.nvim_get_runtime_file("", true)
			},
		})
	end,
	settings = {
		Lua = {},
	},
})
-- }}}

--{{{ pylsp
lspconfig.pylsp.setup({
	settings = {
		pylsp = {
			plugins = {
				-- `pycodestyle`, `pyflakes`, `mccabe`, `autopep8`, and `yapf`
				-- are disabled by ruff.
				ruff = {
					enabled = true,
					-- Enable all rules and exclude rules explicitly.
					-- https://docs.astral.sh/ruff/rules/
					select = { "ALL" },
					-- Rules that are marked as fixable by ruff that should be
					-- fixed when running `textDocument/formatting`.
					format = { "I" },
					-- Ignore `flake8-fixme` rules. These are handled by
					-- `todos`.
					ignore = { "FIX" },
				},
			},
		},
	},
})
--}}}
-- rust-analyzer {{{
lspconfig.rust_analyzer.setup({
	capabilities = cmp_capabilities,
	settings = {
		["rust-analyzer"] = {
			check = {
				-- Use clippy instead of check for more suggestions.
				command = "clippy",
			},
		},
	},
})
-- }}}

-- {{{ typescript-language-server
lspconfig.ts_ls.setup({
	capabilities = cmp_capabilities,
})
-- }}}
