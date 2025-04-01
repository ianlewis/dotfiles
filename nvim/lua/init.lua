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

--{{{ package configs
require("remap") -- key remappings
require("treesitter") -- nvim-treesitter config
--}}}

-- {{{ nvim-surround
local surround = require("nvim-surround")
surround.setup()
-- }}}

-- LSP {{{
local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

-- completion {{{
local cmp = require("cmp")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

cmp.setup({
    sources = {
        {
            name = 'nvim_lsp'
        },
    },
    mapping = cmp.mapping.preset.insert({
        -- <C-n> = next
        -- <C-p> = previous 
        -- <C-e> = aboriut
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
})

cmp_capabilities = cmp_nvim_lsp.default_capabilities()
-- }}}

-- efm-langserver {{{

-- formatters {{{
local prettier = {
    -- TODO(#16): Support passing textwidth to prettier
    --            See: https://github.com/mattn/efm-langserver/issues/144
    formatCommand = "prettier --stdin-filepath ${INPUT} --print-width 79 --tab-width 2",
    formatStdin = true,
}

local black = {
    -- TODO(#16): Support passing textwidth to prettier
    --            See: https://github.com/mattn/efm-langserver/issues/144
    formatCommand = "black --quiet --line-length l79 -",
    formatStdin = true,
}

local rustFmt = {
    formatCommand = "rustfmt",
    formatStdin = true,
}

local terraformFmt = {
    formatCommand = "terraform fmt -",
    formatStdin = true,
}

local tofuFmt = {
    formatCommand = "tofu fmt -",
    formatStdin = true,
}
-- }}}

-- linters {{{
local eslint = {
    -- NOTE: We use a script wrapper because eslint is huge PITA to use directly.
    lintCommand = "eslint-efm ${INPUT}",
    lintStdin = true,
    lintIgnoreExitCode = true,
    lintFormats = {
        "%f(%l,%c): %m",
    },
}

local markdownlint = {
    lintCommand = "markdownlint --stdin --config %USERPROFILE%.config/markdownlint.yaml",
    lintStdin = true,
    lintFormats = {
        "%f:%l %m",
        "%f:%l:%c %m",
        "%f: %l: %m",
    },
}

local flake8 = {
    lintCommand = "flake8 --stdin-display-name ${INPUT} -",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
}

local yamllint = {
    lintCommand = "yamllint -f parsable -",
    lintStdin = true,
}
-- }}}

lspconfig.efm.setup({
    init_options = { documentFormatting = true },
    settings = {
        rootMarkers = {".git/"},

        languages = {
            -- NOTE: Go is handled by gopls server.
            --       golangci-lint isn't used because I usually have specific
            --       configuration per-project and checks analysis tools built
            --       into gopls are usually good enough for normal editing.
            -- TODO(#16): Formatting/linting support for SQL
            -- TODO(#16): Formatting/linting support for shell with shfmt,shellcheck
            javascript = { prettier, eslint },
            json = { prettier, eslint },
            json5 = { prettier, eslint },
            markdown = { prettier, markdownlint },
            python = { black, flake8 },
            -- TODO(#21): Support lua-format
            -- lua = {
            --     {formatCommand = "lua-format -i", formatStdin = true}
            -- }
            terraform = { terraformFmt, tofuFmt },
            typescript = { prettier, eslint },
            yaml = { prettier, yamllint },
        }
    }
})
-- }}}

-- gopls {{{
lspconfig.gopls.setup({
    capabilities = cmp_capabilities,
    filetypes = {
        "go",
        "gomod",
        "gowork",
        "gotmpl",
    },
    settings = {
        gopls = {
            analyses = {
                shadow = true,
                unusedvariable = true,
                useany = true,
            },
            staticcheck = true,
            gofumpt = true,
        },
    },
})
-- }}}

-- rust-analyzer {{{
lspconfig.rust_analyzer.setup({
    capabilities = cmp_capabilities,
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            cargo = {
                buildScripts = {
                    enable = true,
                },
            },
            procMacro = {
                enable = true
            },
            check = {
                command = "clippy"
            },
        }
    }
})
-- }}}

-- }}}

-- Autoformat {{{
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
-- }}}
