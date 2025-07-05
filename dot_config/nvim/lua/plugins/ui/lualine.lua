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
                ignore_focus = { "neo-tree" }, --be drawn as inactive statusline
                component_separators = "",
                section_separators = { left = "", right = "" },
                globalstatus = true,
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {},
                lualine_c = {
                    {
                        "filesize",
                        cond = conditions.buffer_not_empty,
                    },
                    -- {
                    --     "filename",
                    --     cond = conditions.buffer_not_empty,
                    --     color = { fg = colors.magenta, gui = "bold" },
                    -- },
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
                        function()
                            return "recording @" .. vim.fn.reg_recording()
                        end,
                        cond = function()
                            return vim.fn.reg_recording() ~= ""
                        end,
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
                            local clients = vim.lsp.get_clients()
                            local buf = vim.api.nvim_get_current_buf()
                            clients = vim.iter(clients)
                                :filter(function(client)
                                    return client.attached_buffers[buf]
                                end)
                                :map(function(client)
                                    return client.name
                                end)
                                :totable()
                            if #clients == 0 then
                                return "No Active Lsp"
                            else
                                local info = table.concat(clients, ", ")
                                return info
                            end
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
                        function()
                            return "sw=" .. vim.o.shiftwidth
                        end,
                        cond = conditions.hide_in_width,
                        color = { fg = colors.green, gui = "bold" },
                        padding = { left = 1, right = 0 },
                        on_click = function(num, btn, mod)
                            local old = vim.o.shiftwidth
                            if btn == "l" then
                                vim.o.shiftwidth = (old - 1) > 0 and (old - 1) or 1
                            elseif btn == "r" then
                                vim.o.shiftwidth = old + 1
                            elseif btn == "m" then
                                vim.cmd([[stopinsert]])
                                vim.api.nvim_feedkeys(":set shiftwidth=", "nt", false)
                            end
                        end,
                    },
                    {
                        function()
                            return "ts=" .. vim.o.tabstop
                        end,
                        cond = conditions.hide_in_width,
                        color = { fg = colors.green, gui = "bold" },
                        padding = { left = 1, right = 0 },
                        on_click = function(num, btn, mod)
                            local old = vim.o.tabstop
                            if btn == "l" then
                                vim.o.tabstop = (old - 1) > 0 and (old - 1) or 1
                            elseif btn == "r" then
                                vim.o.tabstop = old + 1
                            elseif btn == "m" then
                                vim.cmd([[stopinsert]])
                                vim.api.nvim_feedkeys(":set tabstop=", "nt", false)
                            end
                        end,
                    },
                    {
                        function()
                            return "et=" .. (vim.o.expandtab and "on" or "off")
                        end,
                        cond = conditions.hide_in_width,
                        padding = { left = 1, right = 1 },
                        color = { fg = colors.green, gui = "bold" },
                        on_click = function()
                            local old = vim.o.expandtab
                            vim.o.expandtab = not old
                        end,
                    },
                    {
                        "encoding",
                        cond = conditions.hide_in_width,
                        color = { fg = colors.green, gui = "bold" },
                        on_click = function()
                            vim.cmd([[stopinsert]])
                            vim.api.nvim_feedkeys(":set fileencoding=", "nt", false)
                        end,
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
                lualine_a = {},
                lualine_b = {
                    -- { "tabs", use_mode_colors = false },
                    "filename",
                },
                lualine_c = {},
                lualine_x = {},
                lualine_y = { "buffers" },
                lualine_z = {},
            },
        })
    end,
}
