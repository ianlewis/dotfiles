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

do
	vim.g.mapleader = " "

	vim.g.markdown_fenced_languages = {
		"bash",
		"go",
		"html",
		"java",
		"javascript",
		"python",
		"rust",
		"sh",
		"shell=sh",
		"typescript",
	}

	-- Disable unnecessary language providers.
	-- These providers allow the use of remote plugins written in other
	-- languages but I don't use any that require them.
	vim.g.loaded_node_provider = 0
	vim.g.loaded_perl_provider = 0
	vim.g.loaded_python3_provider = 0
	vim.g.loaded_ruby_provider = 0
end
