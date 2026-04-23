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

local M = {}

function xdg_dir(name, def)
	return os.getenv(name) or def
end

function xdg_home_dir(name)
	local xdg_map = {
		XDG_CONFIG_HOME = "/.config",
		XDG_DATA_HOME = "/.local/share",
		XDG_CACHE_HOME = "/.cache",
	}

	return xdg_dir(name, os.getenv("HOME") .. xdg_map[name])
end

M.config_home = function()
	return xdg_home_dir("XDG_CONFIG_HOME")
end

return M
