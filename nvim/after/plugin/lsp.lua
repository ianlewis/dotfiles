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
		vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, bufopts)
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
	mapping = cmp.mapping.preset.insert({
		-- <C-n> = next
		-- <C-p> = previous
		-- <C-e> = aboriut
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
local markdownlint = require("efmls-configs.linters.markdownlint")
local selene = require("efmls-configs.linters.selene")
local yamllint = require("efmls-configs.linters.yamllint")
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
			javascript = { prettier },
			json = { prettier },
			json5 = { prettier },
			markdown = { prettier, markdownlint },
			lua = { stylua, selene },
			terraform = { tofuFmt },
			typescript = { prettier },
			yaml = { prettier, yamllint },
			["yaml.ghaction"] = { prettier, actionlint, yamllint },
		},
	},
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
			-- NOTE: The staticcheck setting is experimental and may be deleted.
			--       https://github.com/golang/tools/blob/master/gopls/doc/settings.md#staticcheck-bool
			staticcheck = true,
			gofumpt = true,
		},
	},
})
-- }}}

--{{{ pylsp
lspconfig.pylsp.setup({
	settings = {
		pylsp = {
			plugins = {
				-- pycodestyle, pyflakes, mccabe, autopep8, and yapf are disabled by ruff.
				ruff = {
					enabled = true,
					-- Enable all rules and exclude rules explicitly.
					-- https://docs.astral.sh/ruff/rules/
					select = { "ALL" },
				},
				pycodestyle = {
					-- Use ruff's max line length.
					maxLineLength = 88,
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
