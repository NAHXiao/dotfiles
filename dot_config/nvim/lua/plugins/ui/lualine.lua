local shorten_path = require("utils").shorten_path
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
                lualine_b = {
                    {
                        "branch",
                        icon = "",
                        color = { fg = colors.violet, gui = "bold" },
                    },
                },
                lualine_c = {
                    {
                        "filesize",
                        cond = conditions.buffer_not_empty,
                    },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = { error = " ", warn = " ", info = " " },
                        diagnostics_color = {
                            color_error = { fg = colors.red },
                            color_warn = { fg = colors.yellow },
                            color_info = { fg = colors.cyan },
                        },
                        cond = conditions.hide_in_width,
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
                        "diff",
                        symbols = { added = " ", modified = "󰝤 ", removed = " " },
                        diff_color = {
                            added = { fg = colors.green },
                            modified = { fg = colors.orange },
                            removed = { fg = colors.red },
                        },
                        cond = conditions.hide_in_width,
                    },
                    {
                        function()
                            local str
                            if
                                (vim.o.softtabstop == vim.o.tabstop)
                                and (vim.o.tabstop == vim.o.shiftwidth)
                            then
                                str = tostring(vim.o.tabstop)
                            elseif vim.o.softtabstop == vim.o.tabstop then
                                str = tostring(vim.o.shiftwidth) .. ":" .. tostring(vim.o.tabstop)
                            else
                                str = tostring(vim.o.softtabstop)
                                    .. ":"
                                    .. tostring(vim.o.tabstop)
                                    .. ":"
                                    .. tostring(vim.o.shiftwidth)
                            end
                            return "Tab:" .. str
                        end,
                        on_click = function(num, btn, mod)
                            vim.cmd([[stopinsert]])
                            vim.api.nvim_feedkeys(
                                string.format(
                                    ":set softtabstop=%d tabstop=%d shiftwidth=%d",
                                    vim.o.softtabstop,
                                    vim.o.tabstop,
                                    vim.o.shiftwidth
                                ),
                                "nt",
                                false
                            )
                        end,
                    },
                },
                lualine_y = {
                    {
                        "progress",
                        color = { fg = colors.violet },
                    },
                    {
                        "location",
                        color = { fg = colors.violet },
                    },
                },
                lualine_z = {
                    {
                        "encoding",
                        fmt = string.upper,
                        on_click = function()
                            vim.cmd([[stopinsert]])
                            vim.api.nvim_feedkeys(":set fileencoding=", "nt", false)
                        end,
                    },
                },
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
                lualine_b = {},
                lualine_c = { { "buffers" } },
                lualine_x = {
                    {
                        function()
                            return shorten_path(vim.g.projroot, math.floor(vim.o.columns / 3))
                        end,
                    },
                },
                lualine_y = {},
                lualine_z = {},
            },
        })
    end,
}
