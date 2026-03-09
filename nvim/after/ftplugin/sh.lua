-- Copyright 2026 Ian Lewis
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

-- sh-specific options.

-- If the shell flavor is detected as bash, set the filetype to bash. This
-- triggers other bash-specific options and plugins, such as tree-sitter and
-- linters.
if vim.b.is_bash and not vim.b.is_sh then
	vim.api.nvim_set_option_value("filetype", "bash", { buf = 0 })
end
