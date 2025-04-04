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

-- TODO(#62): Revisit remaps
-- TODO(#67): Convert init.vim to lua

-- Dvorak keymappings
do
	-- Remap default movement keys to Dvorak home row.
	vim.keymap.set({ "n", "v", "o" }, "n", "j")
	vim.keymap.set({ "n", "v", "o" }, "t", "k")
	vim.keymap.set({ "n", "v", "o" }, "s", "l")
	vim.keymap.set({ "n", "v", "o" }, "j", "l")

	-- Remap the 'n' key to 'l' because it's on the Dvorak home row.
	vim.keymap.set({ "n", "v", "o" }, "l", "n")
end

do
	-- Use tab to move between open and close braces.
	vim.keymap.set({ "n", "v" }, "<tab>", "%")

	-- Terminal friendly visual block shortcut for the terminal. This is an escape
	-- hatch for when Ctrl-v doesn't work in some terminals.
	vim.keymap.set({ "n", "v", "o" }, "vb", "<C-v>")
end
