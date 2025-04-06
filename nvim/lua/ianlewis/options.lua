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

-- Open new split panes below and to the right.
vim.opt.splitbelow = true
vim.opt.splitright = true

-- A real tabstop is 4. 2 is too short, and 8 is too long.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Use spaces instead of tabs by default.
-- This may be overridden by file type.
vim.opt.expandtab = true

-- Show the current line number. This with relativenumber=true shows the
-- absolute line number for the current line and relative line numbers for
-- other lines.
vim.opt.nu = true
vim.opt.relativenumber = true

-- Allow opening files with Japanese character encodings.
vim.opt.fileencodings = "iso-2002-jp,ucs-bom,utf-8,euc-jp,cp932,default,latin1"

-- Always use unix line endings, even on Windows.
vim.opt.fileformat = "unix"

-- The status line includes the filetype, fileformat, fileencoding
vim.opt.statusline =
	'%<%f %h%m%r%=%y(%{&ff}) %{"[".(&fenc==""?&enc:&fenc).((exists("+bomb") && &bomb)?",B":"")."] "}%k %-14.(%l,%c%V%) %P'

-- Do incremential search
vim.opt.incsearch = true

-- Always keep this many lines visible above and below the cursor.
vim.opt.scrolloff = 8

-- Always show the signcolumn so it's not jittering the screen when there
-- are errors in the file.
vim.opt.signcolumn = "yes"
