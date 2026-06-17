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

local default_config = require("lualine.config").get_config()

-- wordcount_ext is a custom extension for lualine that adds a word count and
-- character count to the statusline for markdown and text files.
-- NOTE: Adding sections to an extension overwrites all sections in the default
--       configuration so we need to merge with the defaults.
local wordcount_ext = {
	sections = vim.tbl_deep_extend("force", default_config.sections, {
		lualine_y = vim.list_extend({
			function()
				local wc = vim.fn.wordcount()
				return string.format("%d:%d", wc.words, wc.chars)
			end,
		}, default_config.sections.lualine_y),
	}),
	filetypes = {
		"markdown",
		"text",
	},
}

require("lualine").setup({
	options = {
		theme = "tokyonight",
	},
	extensions = {
		-- trouble is a built-in extension that shows the trouble "mode" in the
		-- statusline for trouble buffers.
		"trouble",
		wordcount_ext,
	},
})
