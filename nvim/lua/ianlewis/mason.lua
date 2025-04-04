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

-- Install python-lsp-server plugins automatically.
require("mason-registry"):on("package:install:success", function(pkg)
	if pkg.name ~= "python-lsp-server" then
		return
	end

	local venv = pkg:get_install_path() .. "/venv"
	local job = require("plenary.job")

	print(venv .. "/bin/pip")
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

require("mason-lspconfig").setup({
	-- Ensure LSP servers are installed.
	ensure_installed = {
		-- bash-language-server
		"bashls",

		-- efm-langserver
		"efm",

		-- Go
		"gopls",

		-- Lua
		-- TODO(#98): Setup Lua language server
		-- "lua_ls",

		-- Python
		"pylsp",

		-- Rust
		"rust_analyzer",

		-- TypeScript/JavaScript
		-- TODO(#99): Setup eslint language server.
		-- "eslint",
		"ts_ls",
	},
})

require("mason-tool-installer").setup({
	-- Ensure linting/formatting tools are installed.
	-- Some of these are used by efm-langserver
	ensure_installed = {
		"actionlint",
		"flake8",
		"markdownlint",
		"prettier",
		-- TODO(#116): Add ripgrep to mason-registry
		-- "ripgrep",
		"ruff",
		"stylua",
		"selene",
		"shellcheck",
		"shfmt",
		"yamllint",
		-- TODO(#95): install terraform with Aqua
	},
})
