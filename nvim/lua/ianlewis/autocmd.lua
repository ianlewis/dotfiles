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

-- Autoformat {{{
local buf_autoformat = vim.api.nvim_create_augroup("BufAutoformat", {
	clear = true,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = buf_autoformat,
	callback = function()
		vim.lsp.buf.format()
		-- Reopen the fold at the cursor position. The result is that formatting
		-- the file will close all folds other that the one at the cursor
		-- position.
		if vim.opt.foldenable then
			vim.cmd("normal! zv")
		end
	end,
})
-- }}}

-- Format Options {{{
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		-- This is a sequence of letters which describes how automatic
		-- formatting is to be done.
		-- default is "tcqj"
		-- https://neovim.io/doc/user/options.html#'formatoptions'
		vim.opt.formatoptions = {
			-- Auto-wrap text using 'textwidth'
			t = true,
			-- Auto-wrap comments using 'textwidth', inserting the current
			-- comment leader automatically.
			c = true,

			-- Automatically insert the current comment leader after hitting
			-- <Enter> in Insert mode.
			r = true,
			-- Allow formatting of comments with "gq".
			q = true,
			-- When formatting text, recognize numbered lists.
			n = true,
			-- Where it makes sense, remove a comment leader when joining lines.
			j = true,

			-- Disabled formatoptions
			-- (a) Automatic formatting of paragraphs.
			-- (o) Automatically insert the current comment leader after
			--     hitting 'o' or 'O' in Normal mode.
			-- (2) When formatting text, use the indent of the second line of a
			--     paragraph for the rest of the paragraph, instead of the
			-- 	   indent of the first line.
		}
	end,
})
-- }}}
