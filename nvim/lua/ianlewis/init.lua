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

require("ianlewis.mason")
require("ianlewis.globals")
require("ianlewis.options")
require("ianlewis.colors")
require("ianlewis.remap")

vim.filetype.add({
	pattern = {
		-- Add a special file type extension to indicate a GitHub Actions
		-- workflow. This is used to run GitHub Actions linters.
		[".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
	},
})

-- Autoformat
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		vim.lsp.buf.format()
	end,
})
