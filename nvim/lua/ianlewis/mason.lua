-- vim:foldmethod=marker:
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

require("mason").setup({
	registries = {
		-- Pin the registry so that packages are not updated automatically.
		"github:mason-org/mason-registry@2025-04-01-smelly-mora",
	},
})

-- Install python-lsp-server plugins automatically {{{
require("mason-registry"):on("package:install:success", function(pkg)
	if pkg.name ~= "python-lsp-server" then
		return
	end

	local venv = pkg:get_install_path() .. "/venv"
	local job = require("plenary.job")

	job:new({
		command = venv .. "/bin/pip",
		args = {
			"--disable-pip-version-check",
			"install",
			"-U",
			"python-lsp-ruff==2.2.2",
		},
		cwd = venv,
		env = { VIRTUAL_ENV = venv },
		on_exit = function(_, return_val)
			vim.schedule(function()
				if return_val == 0 then
					vim.notify("Finished installing pylsp modules.")
				else
					vim.notify("Failed installing pylsp modules.")
				end
			end)
		end,
		on_start = function()
			vim.schedule(function()
				vim.notify("Installing pylsp modules...")
			end)
		end,
	}):start()
end)
-- }}}

-- mason-lspconfig {{{
require("mason-lspconfig").setup({
	-- Ensure LSP servers are installed.
	ensure_installed = {
		-- bash-language-server
		"bashls",

		-- Go
		"gopls",

		-- lua-language-server
		"lua_ls",

		-- Python
		"pylsp",

		-- TypeScript/JavaScript
		"eslint",
		"ts_ls",
	},
})
-- }}}

-- mason-tool-installer {{{
require("mason-tool-installer").setup({
	-- Ensure linting/formatting tools are installed.
	-- Some of these are used by efm-langserver
	ensure_installed = {
		"flake8",
		"markdownlint",
		"prettier",
		"stylelint",
		"yamllint",
		-- TODO(#95): install terraform with Aqua
	},
})
-- }}}
