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

local lspconfig = require("lspconfig")
lspconfig.gopls.setup({
settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

lspconfig.efm.setup({
    init_options = {documentFormatting = true},
    settings = {
        rootMarkers = {".git/"},
        languages = {
            -- TODO(#16): Formatting/linting support for markdown
            -- TODO(#16): Formatting/linting support for TypeScript
            -- TODO(#16): Formatting/linting support for YAML
            python = {
                -- TODO(#16): Support passing textwidth to black
                --            See: https://github.com/mattn/efm-langserver/issues/144
                -- TODO(#16): flake8 linter.
                {formatCommand = "black -q -", formatStdin = true},
            },
            -- TODO(#16): golangci-lint.
            -- TODO(#21): Support lua-format
            -- lua = {
            --     {formatCommand = "lua-format -i", formatStdin = true}
            -- }
            terraform = {
                {formatCommand = "terraform fmt -", formatStdin = true},
                {formatCommand = "tofu fmt -", formatStdin = true}
            },
        }
    }
})

-- Autoformat files on save.
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        local mode = vim.api.nvim_get_mode().mode
        -- TODO(#16): Does this need to check if it's a normal file buffer?
        if vim.bo.modified == true and mode == 'n' then
            vim.cmd('lua vim.lsp.buf.format()')
        else
        end
    end
})
