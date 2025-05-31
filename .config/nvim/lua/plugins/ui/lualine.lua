local colors = {
    bg = "#202328",
    fg = "#bbc2cf",
    yellow = "#ECBE7B",
    cyan = "#008080",
    darkblue = "#081633",
    green = "#98be65",
    orange = "#FF8800",
    violet = "#a9a1e1",
    magenta = "#c678dd",
    blue = "#51afef",
    red = "#ec5f67",
}
local mode_info = {
    ["n"] = { name = "Normal", color = colors.red },
    ["no"] = { name = "Operator Pending", color = colors.red },
    ["v"] = { name = "Visual", color = colors.blue },
    ["V"] = { name = "Visual Line", color = colors.blue },
    [""] = { name = "Visual Block", color = colors.blue },
    ["s"] = { name = "Select", color = colors.orange },
    ["S"] = { name = "Select Line", color = colors.orange },
    [""] = { name = "Select Block", color = colors.orange },
    ["i"] = { name = "Insert", color = colors.green },
    ["ic"] = { name = "Insert Completion", color = colors.yellow },
    ["ix"] = { name = "Insert Completion", color = colors.yellow },
    ["R"] = { name = "Replace", color = colors.violet },
    ["Rc"] = { name = "Replace", color = colors.violet },
    ["Rx"] = { name = "Replace", color = colors.violet },
    ["Rv"] = { name = "Virtual Replace", color = colors.violet },
    ["Rvc"] = { name = "Virtual Replace", color = colors.violet },
    ["Rvx"] = { name = "Virtual Replace", color = colors.violet },
    ["c"] = { name = "Command", color = colors.magenta },
    ["cv"] = { name = "Vim Ex", color = colors.red },
    ["ce"] = { name = "Ex", color = colors.red },
    ["r"] = { name = "Hit-Enter Prompt", color = colors.cyan },
    ["rm"] = { name = "More Prompt", color = colors.cyan },
    ["r?"] = { name = "Confirm Prompt", color = colors.cyan },
    ["!"] = { name = "Shell", color = colors.red },
    ["t"] = { name = "Terminal", color = colors.red },
}
return {
    "nvim-lualine/lualine.nvim",
    version = "*",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
        "kyazdani42/nvim-web-devicons",
    },
    config = function()
        -- ▊   8.3k  lualine.lua  237:46  93%   12        LSP: lua_ls          UTF-8  UNIX   main   6 󰝤 1  ▊
        -- local function sessionname()
        --     return nil
        --     -- if require("lazy.core.config").plugins["auto-session"]._.loaded then
        --     --     -- return require('auto-session.lib').current_session_name
        --     --     return nil
        --     -- else
        --     --     return nil
        --     -- end
        -- end
        local lualine = require("lualine")
        -- Color table for highlights
        -- stylua: ignore

        local conditions = {
            buffer_not_empty = function()
                return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
            end,
            hide_in_width = function()
                return vim.fn.winwidth(0) > 80
            end,
            check_git_workspace = function()
                local filepath = vim.fn.expand("%:p:h")
                local gitdir = vim.fn.finddir(".git", filepath .. ";")
                return gitdir and #gitdir > 0 and #gitdir < #filepath
            end,
        }

        -- Config
        local config = {
            options = {
                -- Disable sections and component separators
                component_separators = "",
                section_separators = "",
                theme = "catppuccin",
                -- theme = {
                --     -- We are going to use lualine_c an lualine_x as left and
                --     -- right section. Both are highlighted by c theme .  So we
                --     -- are just setting default looks o statusline
                --     normal = { c = { fg = colors.fg, bg = colors.bg } },
                --     inactive = { c = { fg = colors.fg, bg = colors.bg } },
                -- },
                ignore_focus = { "neo-tree" },
            },
            sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {},

                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {},

                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {
                lualine_a = {},
                -- lualine_b = { 'branch' },
                lualine_c = { "filename" },

                lualine_x = {},
                lualine_y = { "buffers" },
                -- lualine_z = { 'tabs' }
            },
        }
        local function insert_left(component)
            table.insert(config.sections.lualine_c, component)
        end
        local function insert_right(component)
            table.insert(config.sections.lualine_x, component)
        end

        insert_left({
            function()
                return "▊"
            end,
            color = { fg = colors.blue }, -- Sets highlighting of component
            padding = { left = 0, right = 1 }, -- We don't need space before this
        })

        
        insert_left({
            function()
                return mode_info[vim.api.nvim_get_mode().mode].name
            end,
            color = function()
                return { fg = mode_info[vim.api.nvim_get_mode().mode].color }
            end,
            padding = { right = 1 },
        })

        insert_left({
            "filesize",
            cond = conditions.buffer_not_empty,
        })

        insert_left({
            "filename",
            cond = conditions.buffer_not_empty,
            color = { fg = colors.magenta, gui = "bold" },
        })

        insert_left({ "location" })

        insert_left({ "progress", color = { fg = colors.fg, gui = "bold" } })

        insert_left({
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " " },
            diagnostics_color = {
                color_error = { fg = colors.red },
                color_warn = { fg = colors.yellow },
                color_info = { fg = colors.cyan },
            },
        })

        -- Insert mid section. You can make any number of sections in neovim :)
        -- for lualine it's any number greater then 2
        insert_left({
            function()
                return "%="
            end,
        })

        insert_left({
            -- Lsp server name .
            function()
                local msg = "No Active Lsp"
                local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
                local clients = (function()
                    if vim.lsp.get_clients then
                        return vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
                    else
                        return vim.lsp.get_active_clients() -- deprecated
                    end
                end)()
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
            icon = " LSP:",
            cond = function()
                return vim.bo.buftype == ""
            end,
        })

        -- Add components to right sections
        insert_right({
            "o:encoding", -- option component same as &encoding in viml
            fmt = string.upper, -- I'm not sure why it's upper case either ;)
            cond = conditions.hide_in_width,
            color = { fg = colors.green, gui = "bold" },
        })

        insert_right({
            "fileformat",
            fmt = string.upper,
            icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
            color = { fg = colors.green, gui = "bold" },
        })

        insert_right({
            "branch",
            icon = "",
            color = { fg = colors.violet, gui = "bold" },
        })

        insert_right({
            "diff",
            -- Is it me or the symbol for modified us really weird
            symbols = { added = " ", modified = "󰝤 ", removed = " " },
            diff_color = {
                added = { fg = colors.green },
                modified = { fg = colors.orange },
                removed = { fg = colors.red },
            },
            cond = conditions.hide_in_width,
        })

        insert_right({
            function()
                return "▊"
            end,
            color = { fg = colors.blue },
            padding = { left = 1 },
        })

        -- Now don't forget to initialize lualine
        lualine.setup(config)
    end,
}
