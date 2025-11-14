-- Copyright 2025 Ian Lewis
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

-- e.g. `~/.local/share/nvim/treesitter`
local parser_dir = vim.fn.stdpath("data") .. "/treesitter"

-- NOTE: Tree-sitter parser directory must be added to the runtime path.
vim.opt.runtimepath:append(parser_dir)

require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"(the listed parsers MUST always be
	-- installed)
	ensure_installed = {
		"bash",
		"c",
		"cpp",
		"css",
		"csv",
		"dockerfile",
		"gitcommit",
		"gitignore",
		"go",
		"html",
		"htmldjango",
		"ini",
		"javascript",
		"json",
		"json5",
		"latex",
		"liquid",
		"lua",
		"make",
		"markdown",
		"markdown_inline",
		"proto",
		"python",
		"query",
		"requirements", -- pip requirements.txt
		"rust",
		"scss",
		"sql",
		"terraform",
		"textproto",
		"toml",
		"typescript",
		"vim",
		"vimdoc",
		"xml",
		"yaml",
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	-- Path to the Tree-sitter parser directory.
	parser_install_dir = parser_dir,

	highlight = {
		enable = true,

		-- Setting this to true will run `:h syntax` and Tree-sitter at the same
		-- time. Set this to `true` if you depend on 'syntax' being enabled
		-- (like for indentation). Using this option may slow down your editor,
		-- and you may see some duplicate highlights. Instead of true it can
		-- also be a list of languages
		additional_vim_regex_highlighting = false,

		disable = {
			-- TODO(#540): re-enable when `tree-sitter-dockerfile` parser is fixed.
			"dockerfile",
		},
	},
})
