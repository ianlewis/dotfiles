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

-- TODO(#94): Install python-lsp-server plugins automatically.
-- require("mason-registry"):on("package:install:success", function(pkg)
--     if pkg.name ~= "python-lsp-server" then
--         return
--     end

--     local notify = require("mason-lspconfig.notify")
--     local pip3 = require("mason-core.managers.pip3")
--     local process = require("mason-core.process")
--     local spawn = require("mason-core.spawn")

--     local plugins = {
--         "python-lsp-black",
--     }
--     local plugins_str = table.concat(plugins, ", ")
--     notify(("Installing %s..."):format(plugins_str))
--     local result = spawn.pip {
--         "install",
--         "-U",
--         "--disable-pip-version-check",
--         plugins,
--         stdio_sink = process.simple_sink(),
--         with_paths = { pip3.venv_path(install_dir) },
--     }
--     if vim.in_fast_event() then
--         a.scheduler()
--     end
--     result
--         :on_success(function()
--             notify(("Successfully installed pylsp plugins %s"):format(plugins_str))
--         end)
--         :on_failure(function()
--             notify("Failed to install requested pylsp plugins.", vim.log.levels.ERROR)
--         end)
-- end)

require("mason-lspconfig").setup({
	-- Ensure LSP servers are installed.
	ensure_installed = {
		-- efm-langserver
		"efm",

		-- Go
		"gopls",

		-- Lua
		-- TODO(#98): Setup Lua language server
		-- "lua_ls",

		-- Python
		-- TODO(#94): Use python-lsp-server
		-- "pylsp",

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
		"black",
		"flake8",
		"markdownlint",
		"prettier",
		"stylua",
		"selene",
		"yamllint",
		-- TODO(#95): install terraform with Aqua
	},
})
