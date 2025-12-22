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

-- Dvorak keymappings
-- Remap default movement keys to Dvorak right-hand home keys.
vim.keymap.set({ "n", "v", "o" }, "n", "j")
vim.keymap.set({ "n", "v", "o" }, "t", "k")
vim.keymap.set({ "n", "v", "o" }, "s", "l")
-- NOTE: We still use the 'h' key for left movement even for Dvorak.

-- Close the current buffer in a split without closing the split itself.
-- This switches to the "previously opened buffer" before closing the original
-- buffer so it could be better as sometimes there isn't really a "previously
-- opened buffer".
vim.keymap.set({ "n", "v", "o" }, "<leader>bd", ":bp|sp|bn|bd<cr>")

-- Open files in the directory of the currently opened file.
vim.keymap.set({ "n", "v", "o" }, "<leader>e", ":e %:h/")

-- Remap the 'n' key to 'l' because 'n' on the Dvorak home row. Maintain cursor
-- in the center of the screen.
vim.keymap.set({ "n", "v", "o" }, "l", "nzzzv")
vim.keymap.set({ "n", "v", "o" }, "L", "Nzzzv")

-- Use tab to move between open and close braces.
vim.keymap.set({ "n", "v" }, "<tab>", "%")

-- Terminal friendly visual block shortcut for the terminal. This is an escape
-- hatch for when Ctrl-v doesn't work in some terminals.
vim.keymap.set({ "n", "v", "o" }, "vb", "<C-v>")

-- Drag selected lines up and down.
vim.keymap.set("v", "N", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "T", ":m '<-2<CR>gv=gv")

-- Append next line at the end of current line and move cursor to where the
-- lines were joined.
vim.keymap.set("n", "j", "J")
-- Append next line at the end of current line while maintaining cursor
-- position.
vim.keymap.set("n", "J", "mzJ`z")

-- Page up and down without moving cursor position on screen.
vim.keymap.set("n", "<C-n>", "<C-d>zz")
vim.keymap.set("n", "<C-t>", "<C-u>zz")

-- Move the cursor left and right by word.
vim.keymap.set("n", "<C-h>", "b")
vim.keymap.set("n", "<C-s>", "w")

-- Paste over currently selected value without overwriting the paste buffer.
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Yank into system clipboard.
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- Yank the line to the system clipboard.
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Replace the current word under the cursor.
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Search for the word under the cursor.
vim.keymap.set("n", "<leader>l", [[/<C-r><C-w><Enter>]])
vim.keymap.set("n", "<leader>?", [[?<C-r><C-w><Enter>]])

vim.keymap.set({ "n", "v", "o" }, "<leader>af", function()
	vim.b.autoformat = not vim.b.autoformat
	if vim.b.autoformat then
		vim.notify("Enabled auto-formatting for this buffer", vim.log.levels.INFO)
	else
		vim.notify("Disabled auto-formatting for this buffer", vim.log.levels.WARN)
	end
end)
