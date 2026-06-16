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

require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

-- Update the commentstring option to use ts_context_commentstring
-- https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#native-commenting-in-neovim-010
local get_option = vim.filetype.get_option
-- selene: allow(incorrect_standard_library_use)
---@diagnostic disable-next-line: duplicate-set-field
vim.filetype.get_option = function(filetype, option)
	return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
		or get_option(filetype, option)
end
