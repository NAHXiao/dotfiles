-- [[ plugsetup.lua ]]
-- NvimTree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

-- o open/close dir
-- a add
-- r rename
-- x cut
-- c copy
-- p paste
-- d delete
-- <C-]> cd
require("nvim-tree").setup({
    diagnostics = {
        enable = true,
    },
    sort = {
        sorter = "case_sensitive",
    },
    view = {
        width = 25,
        number = true,
        relativenumber = true,
    },
    renderer = {
        group_empty = true,
        --add_trailing=true,--文件夹=>文件夹/
        highlight_diagnostics = true,
    },
    filters = {
        dotfiles = true,
    },
})



----------------------------------------
--             lualine              ----
----------------------------------------
-- Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir
do
    local lualine = require("lualine")
    -- Color table for highlights
    -- stylua: ignore
    local colors = {
        bg       = '#202328',
        fg       = '#bbc2cf',
        yellow   = '#ECBE7B',
        cyan     = '#008080',
        darkblue = '#081633',
        green    = '#98be65',
        orange   = '#FF8800',
        violet   = '#a9a1e1',
        magenta  = '#c678dd',
        blue     = '#51afef',
        red      = '#ec5f67',
    }

    local conditions = {
        buffer_not_empty = function()
            return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
        end,
        hide_in_width = function()
            return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
            local filepath = vim.fn.expand('%:p:h')
            local gitdir = vim.fn.finddir('.git', filepath .. ';')
            return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
    }

    -- Config
    local config = {
        options = {
            -- Disable sections and component separators
            component_separators = '',
            section_separators = '',
            theme = {
                -- We are going to use lualine_c an lualine_x as left and
                -- right section. Both are highlighted by c theme .  So we
                -- are just setting default looks o statusline
                normal = { c = { fg = colors.fg, bg = colors.bg } },
                inactive = { c = { fg = colors.fg, bg = colors.bg } },
            },
        },
        sections = {
            -- these are to remove the defaults
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            -- These will be filled later
            lualine_c = { require('auto-session.lib').current_session_name }, -- Plua auto-session
            lualine_x = {},
        },
        inactive_sections = {
            -- these are to remove the defaults
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            lualine_c = {},
            lualine_x = {},
        },

    }

    -- Inserts a component in lualine_c at left section
    local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
    end

    -- Inserts a component in lualine_x at right section
    local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
    end

    ins_left {
        function()
            return '▊'
        end,
        color = { fg = colors.blue },      -- Sets highlighting of component
        padding = { left = 0, right = 1 }, -- We don't need space before this
    }

    ins_left {
        -- mode component
        function()
            return ''
        end,
        color = function()
            -- auto change color according to neovims mode
            local mode_color = {
                n = colors.red,
                i = colors.green,
                v = colors.blue,
                [''] = colors.blue,
                V = colors.blue,
                c = colors.magenta,
                no = colors.red,
                s = colors.orange,
                S = colors.orange,
                [''] = colors.orange,
                ic = colors.yellow,
                R = colors.violet,
                Rv = colors.violet,
                cv = colors.red,
                ce = colors.red,
                r = colors.cyan,
                rm = colors.cyan,
                ['r?'] = colors.cyan,
                ['!'] = colors.red,
                t = colors.red,
            }
            return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { right = 1 },
    }

    ins_left {
        -- filesize component
        'filesize',
        cond = conditions.buffer_not_empty,
    }

    ins_left {
        'filename',
        cond = conditions.buffer_not_empty,
        color = { fg = colors.magenta, gui = 'bold' },
    }

    ins_left { 'location' }

    ins_left { 'progress', color = { fg = colors.fg, gui = 'bold' } }

    ins_left {
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        symbols = { error = ' ', warn = ' ', info = ' ' },
        diagnostics_color = {
            color_error = { fg = colors.red },
            color_warn = { fg = colors.yellow },
            color_info = { fg = colors.cyan },
        },
    }

    -- Insert mid section. You can make any number of sections in neovim :)
    -- for lualine it's any number greater then 2
    ins_left {
        function()
            return '%='
        end,
    }

    ins_left {
        -- Lsp server name .
        function()
            local msg = 'No Active Lsp'
            local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
            local clients = vim.lsp.get_active_clients()
            if next(clients) == nil then
                return msg
            end
            for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                end
            end
            return msg
        end,
        icon = ' LSP:',
        color = { fg = '#ffffff', gui = 'bold' },
    }

    -- Add components to right sections
    ins_right {
        'o:encoding',       -- option component same as &encoding in viml
        fmt = string.upper, -- I'm not sure why it's upper case either ;)
        cond = conditions.hide_in_width,
        color = { fg = colors.green, gui = 'bold' },
    }

    ins_right {
        'fileformat',
        fmt = string.upper,
        icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
        color = { fg = colors.green, gui = 'bold' },
    }

    ins_right {
        'branch',
        icon = '',
        color = { fg = colors.violet, gui = 'bold' },
    }

    ins_right {
        'diff',
        -- Is it me or the symbol for modified us really weird
        symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
        diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.orange },
            removed = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
    }

    ins_right {
        function()
            return '▊'
        end,
        color = { fg = colors.blue },
        padding = { left = 1 },
    }

    -- Now don't forget to initialize lualine
    lualine.setup(config)
end
-- Symbols Outline (new tagbar)
-- Esc
-- C-Space
-- Kr
-- a
-- h
-- l
-- W
-- E
-- R
-- ?
require("symbols-outline").setup {
    show_guides = false,
    position = 'left',
    width = 30,
    wrap = false,
    keymaps = { fold = "h", unfold = "l", fold_all = "zM", unfold_all = "zR" },
    symbols = {
        File = { icon = "", hl = "@text.uri" },
        Module = { icon = "全", hl = "@namespace" },
        Namespace = { icon = "凜", hl = "@namespacee" },
        Package = { icon = "", hl = "@namespacee" },
        Class = { icon = "", hl = "@type" },
        Method = { icon = "", hl = "@method" },
        Property = { icon = "", hl = "@method" },
        Field = { icon = "", hl = "@field" },
        Constructor = { icon = "", hl = "@constructor" },
        Enum = { icon = "", hl = "@type" },
        Interface = { icon = "ﰮ", hl = "@type" },
        Function = { icon = "", hl = "@function" },
        Variable = { icon = "", hl = "@constant" },
        Constant = { icon = "", hl = "@constant" },
        String = { icon = "", hl = "@string" },
        Number = { icon = "#", hl = "@number" },
        Boolean = { icon = "⊨", hl = "@boolean" },
        Array = { icon = "", hl = "@constant" },
        Object = { icon = "", hl = "@type" },
        Key = { icon = "🔐", hl = "@type" },
        Null = { icon = "ﳠ", hl = "@type" },
        EnumMember = { icon = "", hl = "@field" },
        Struct = { icon = "", hl = "@type" },
        Event = { icon = "🗲", hl = "@type" },
        Operator = { icon = "+", hl = "@operator" },
        TypeParameter = { icon = "", hl = "@parameter" }
    },
}

-- Better escape
require("better_escape").setup {
    mapping = { "jk", "kj" },   -- a table with mappings to use
    timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
    clear_empty_lines = false,  -- clear line after escaping if there is only whitespace
    keys = "<Esc>",             -- keys used for escaping, if it is a function will use the result everytime
}

-- FTerm
require('FTerm').setup({
    border     = 'single',
    -- cmd = os.getenv('SHELL'),
    cmd        = 'zsh',
    blend      = 0,
    dimensions = {
        height = 0.9,
        width = 0.9,
    },
})


----------------------------------------
-- TREE-SITTER Setup                ----
----------------------------------------
require('nvim-treesitter.configs').setup {
    ensure_installed = { "bash", "c", "cmake", "css", "dockerfile", "go", "gomod", "gowork", "hcl", "html",
        "http", "javascript", "json", "lua", "make", "markdown", "python", "regex", "ruby", "rust", "toml", "vim", "yaml",
        "zig" },
    -- TODO if true  some .d will open failed
    auto_install = false,
    -- highlight = {
    -- -- 打开会导致python缩进异常
    --     enable = true,
    -- },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<S-Tab>",  -- normal mode
            node_incremental = "<Tab>",  -- visual mode
            node_decremental = "<S-Tab", -- visual mode
        },
    },
    ident = { enable = true },
    rainbow = {
        enable = true,
    }
}

-- Headlines for Markdown
require "headlines".setup()


------------------------------------
-- Nvim UFO - GOOD FOLDING      ----
--https://github.com/kevinhwang91/nvim-ufo
-- ---------------------------------
-- TODO 代码折叠
do
    vim.cmd([[
augroup MyColors
autocmd!
augroup end
]])

    vim.o.foldcolumn = '1'
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
    -- Option 3: treesitter as a main provider instead
    -- Only depend on `nvim-treesitter/queries/filetype/folds.scm`,
    -- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
    -- require('ufo').setup({
    --     provider_selector = function(bufnr, filetype, buftype)
    --         return {'treesitter', 'indent'}
    --     end
    -- })
    local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('   %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
                table.insert(newVirtText, chunk)
            else
                chunkText = truncate(chunkText, targetWidth - curWidth)
                local hlGroup = chunk[2]
                table.insert(newVirtText, { chunkText, hlGroup })
                chunkWidth = vim.fn.strdisplaywidth(chunkText)
                -- str width returned from truncate() may less than 2nd argument, need padding
                if curWidth + chunkWidth < targetWidth then
                    suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                end
                break
            end
            curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
    end

    -- global handler
    require('ufo').setup({
        fold_virt_text_handler = handler,

        provider_selector = function(bufnr, filetype, buftype)
            return { 'treesitter', 'indent' }
        end
    })
    -- buffer scope handler
    -- will override global handler if it is existed
    local bufnr = vim.api.nvim_get_current_buf()
    require('ufo').setFoldVirtTextHandler(bufnr, handler)

    -- Hide foldcolumn for transparency
    vim.opt.foldcolumn = '0'
end

------------------------------------
-- DIFFVIEW                     ----
-- -https://github.com/sindrets/diffview.nvim
-- --------------------------------
-- Lua
-- Vim 的 diff 模式相当不错，但是没有方便的方法可以快速调出 diffsplit 中所有修改过的文件。该插件旨在提供一个简单、统一的单页界面，让您轻松查看任何 git rev 的所有更改文件。
do
    local actions = require("diffview.actions")

    require("diffview").setup({
    })
    require("transparent").setup({ -- Optional, you don't have to run setup.
        groups = {                 -- table: default groups
            'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
            'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
            'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
            'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
            'EndOfBuffer',
        },
        extra_groups = {},   -- table: additional groups that should be cleared
        exclude_groups = {}, -- table: groups you don't want to clear
    })
end

require 'hop'.setup()
----------------------------------------
--            nvim-lspconfig        ----
--           manson.nvim--LSP       ----
--         manson-lspconfig.nvim    ----
----------------------------------------
do
    require("mason").setup({
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            }
        }
    })
    require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer","clangd","bashls","lua_ls" ,"jdtls","cmake","pyright"},
    })
    require("mason-lspconfig").setup_handlers {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function(server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup {}
        end,
        -- Next, you can provide a dedicated handler for specific servers.
        -- For example, a handler override for the `rust_analyzer`:
        ["rust_analyzer"] = function()
            require("rust-tools").setup {}
        end,
        -- ["clangd"] = function()
        --     require("clang-format").setup {
        --         provideFormatter = false
        --     }
        -- end
    }
    -- 修复clangd warning: multiple different client offset_encodings detected for buffer, this is not supported yet 错误
    require("lspconfig").clangd.setup {
        -- on_attach = on_attach,
        --capabilities = cmp_nvim_lsp.default_capabilities(),
        cmd = {
            "clangd",
            "--offset-encoding=utf-16",
        },
    }
    -- require("lspconfig").efm.setup {
    --     filetypes = { "c", "cpp" },
    --     init_options = {
    --         documentFormatting = false
    --     }
    -- }
end

--[[ vim.diagnostic.config({
    underline = true,
    signs = true,
    virtual_text = false,
    float = {
        show_header = true,
        source = 'if_many',
        border = 'rounded',
        focusable = false,
    },
    update_in_insert = false, -- default to false
    severity_sort = false,    -- default to false
}) ]]


----------------------------------------
--             Coc                 -----
----------------------------------------
--require("cocconfig")
--
----------------------------------------
--             cmp                  ----
----------------------------------------
--require("cmpconfig")
-- require('cmp_vsnip').setup()
require("cmpconfig")

----------------------------------------
--          vimspector             -----
----------------------------------------
vim.g.vimspector_enable_mappings = 'HUMAN'
vim.cmd("packadd! vimspector")
vim.cmd([[let g:vimspector_base_dir=expand( '$HOME/.local/share/nvim/site/pack/packer/start/vimspector' ) ]])
vim.cmd("let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools','CodeLLDB']")

----------------------------------------
--          hlargs                 -----
----------------------------------------
require('hlargs').setup()
----------------------------------------
--          copilot                -----
----------------------------------------
--  require("copilot").setup({
--     suggestion = { enabled = true },
--     panel = { enabled = false },
-- })

-- vim.g.copilot_filetypes = {
--     ["*"] = false,
--     ["javascript"] = true,
--     ["typescript"] = true,
--     ["lua"] = true,
--     ["rust"] = true,
--     ["c"] = true,
--     ["cpp"] = true,
--     ["c++"] = true,
--     ["c#"] = true,
--     ["go"] = true,
--     ["python"] = true,
-- }



-- crates
require('crates').setup({})



config = function() require("nvim-autopairs").setup {} end


--- auto session ---
-- let g:auto_session_root_dir = path/to/my/custom/dir
do
    local opts = {
        log_level = 'info',
        auto_session_enable_last_session = false,
        auto_session_root_dir = vim.fn.stdpath('data') .. "/sessions/",
        auto_session_enabled = true,
        auto_save_enabled = false,
        auto_restore_enabled = false,
        auto_session_use_git_branch = false,
        -- the configs below are lua only
        auto_session_suppress_dirs = nil,
        bypass_session_save_file_types = nil,
        session_lens = {
            -- If load_on_setup is set to false, one needs to eventually call `require("auto-session").setup_session_lens()` if they want to use session-lens.
            buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
            load_on_setup = true,
            theme_conf = { border = true },
            previewer = false,
        },
    }

    require('auto-session').setup(opts)
    -- ⚠️ This will only work if Telescope.nvim is installed
    -- vim.keymap.set("n", "<leader>s", require("auto-session.session-lens").search_session, {
    --     noremap = true,
    -- })
end


--- Telescope ---
require('telescope').setup {
    defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        mappings = {
            i = {
                -- map actions.which_key to <C-h> (default: <C-/>)
                -- actions.which_key shows the mappings for your picker,
                -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                -- ["<C-h>"] = "which_key"
            }
        }
    },
    pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
    },
    extensions = {
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
    }
}
