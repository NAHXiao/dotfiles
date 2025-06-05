local colors = {
    bg = "#202328",
    fg = "#bbc2cf",
    yellow = "#ECBE7B",
    cyan = "#008080",
    darkblue = "#081633",
    green = "#98be65",
    violet = "#a9a1e1",
    magenta = "#c678dd",
    red = "#ec5f67",
    white = "#cdd6f4",
    icy_aqua = "#83d2e1",
    orange = "#ff9e64",
    blue = "#6daaba",
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
        require("lualine").setup({
            options = {
                -- Disable sections and component separators
                component_separators = "",
                section_separators = "",
                theme = "catppuccin",
                ignore_focus = { "neo-tree" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {},
                lualine_c = {
                    {
                        "filesize",
                        cond = conditions.buffer_not_empty,
                    },
                    {
                        "filename",
                        cond = conditions.buffer_not_empty,
                        color = { fg = colors.magenta, gui = "bold" },
                    },
                    { "location" },
                    { "progress", color = { fg = colors.fg, gui = "bold" } },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = { error = " ", warn = " ", info = " " },
                        diagnostics_color = {
                            color_error = { fg = colors.red },
                            color_warn = { fg = colors.yellow },
                            color_info = { fg = colors.cyan },
                        },
                    },

                    {
                        require("noice").api.status.mode.get,
                        cond = require("noice").api.status.mode.has,
                        color = { fg = "#ff9e64" },
                    },
                    {
                        function()
                            return "%="
                        end,
                    },
                    {
                        -- Lsp server name .
                        function()
                            local msg = "No Active Lsp"
                            local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
                            local clients = (function()
                                return vim.lsp.get_clients({
                                    bufnr = vim.api.nvim_get_current_buf(),
                                })
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
                    },
                },

                lualine_x = {
                    {
                        require("noice").api.status.command.get,
                        cond = require("noice").api.status.command.has,
                        color = { fg = colors.orange },
                    },
                    {
                        require("noice").api.status.search.get,
                        cond = require("noice").api.status.search.has,
                        color = { fg = colors.blue },
                    },
                    {
                        "o:encoding", -- option component same as &encoding in viml
                        fmt = string.upper, -- I'm not sure why it's upper case either ;)
                        cond = conditions.hide_in_width,
                        color = { fg = colors.green, gui = "bold" },
                    },
                    {
                        "fileformat",
                        fmt = string.upper,
                        icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
                        color = { fg = colors.green, gui = "bold" },
                    },
                    {
                        "branch",
                        icon = "",
                        color = { fg = colors.violet, gui = "bold" },
                    },
                    {
                        "diff",
                        -- Is it me or the symbol for modified us really weird
                        symbols = { added = " ", modified = "󰝤 ", removed = " " },
                        diff_color = {
                            added = { fg = colors.green },
                            modified = { fg = colors.orange },
                            removed = { fg = colors.red },
                        },
                        cond = conditions.hide_in_width,
                    },
                },
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
                lualine_a = {
                    { "tabs", use_mode_colors = true },
                    "filename",
                },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = { "buffers" },
                lualine_z = {},
            },
        })
    end,
}
