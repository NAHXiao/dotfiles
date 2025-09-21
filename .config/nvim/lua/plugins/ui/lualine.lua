local icons = require("tools.icons")
local shorten_path = function(filepath)
    return require("utils").shorten_path(filepath, math.floor(vim.o.columns / 4))
end
local replace_home = function(filepath)
    return require("utils").prefix_replace(
        vim.fs.normalize(filepath),
        vim.fs.normalize(vim.uv.os_homedir()--[[@as string]]),
        "~"
    )
end
local use_global_root = true
---@return string|nil
local display_root = function()
    if use_global_root then
        local root = require("utils").get_rootdir()
        if root then
            return replace_home(root)
        end
    else
        local root = require("utils").get_rootdir(0)
        if root then
            return replace_home(root)
        end
    end
end
local use_shorten_path = true
local diaplay_path = function()
    local root = display_root()
    local buf_path = vim.api.nvim_buf_get_name(0)
    if not root then
        if use_shorten_path then
            return shorten_path(replace_home(buf_path))
        else
            return replace_home(buf_path)
        end
    else
        local relpath = replace_home(vim.fs.relpath(root, buf_path) or buf_path)
        if use_shorten_path then
            return shorten_path(relpath)
        else
            return relpath
        end
    end
end

local colors = {
    yellow = "#ECBE7B",
    cyan = "#008080",
    green = "#98be65",
    magenta = "#c678dd",
    red = "#ec5f67",
    orange = "#ff9e64",
    blue = "#6daaba",
}
return {
    "nvim-lualine/lualine.nvim",
    version = "*",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
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
        local refresh = function()
            require("lualine").refresh()
        end
        require("lualine").setup {
            options = {
                ignore_focus = { "neo-tree" }, --be drawn as inactive statusline
                component_separators = "",
                section_separators = { left = "", right = "" },
                globalstatus = true,
                refresh = {
                    refresh_time = 100, -- ~10fps
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {
                    {
                        "branch",
                        icon = "",
                        color = { fg = colors.magenta, gui = "bold" },
                    },
                },
                lualine_c = {
                    {
                        "filetype",
                        colored = true,
                        icon_only = true,
                        padding = { right = 0, left = 1 },
                        cond = function()
                            return (vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= "")
                                or vim.bo.buftype == "terminal"
                        end,
                        on_click = function()
                            vim.api.nvim_feedkeys(
                                ":set ft=" .. (vim.bo.filetype and vim.bo.filetype or ""),
                                "nt",
                                false
                            )
                        end,
                    },
                    {
                        function()
                            local padding = vim.bo.filetype and #vim.bo.filetype ~= 0 and "" or " "
                            if vim.bo.buftype == "terminal" then
                                return vim.api.nvim_buf_get_name(0)
                            end
                            return padding .. diaplay_path()
                        end,
                        padding = { right = 0, left = 0 },
                        cond = function()
                            return (vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= "")
                                or vim.bo.buftype == "terminal"
                        end,
                        on_click = function()
                            use_shorten_path = not use_shorten_path
                            refresh()
                        end,
                    },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = {
                            error = icons.diagnostics.error[1],
                            warn = icons.diagnostics.warn[1],
                            info = icons.diagnostics.info[1],
                        },
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
                        -- Lsp server name
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
                            clients = vim.tbl_filter(function(it)
                                return it ~= "copilot"
                            end, clients)
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
                        function()
                            return require("noice").api.status.command.get()
                        end,
                        cond = function()
                            return package.loaded.noice
                                and require("noice").api.status.command.has()
                        end,
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
                    {
                        function()
                            local disabled = "`̸"
                            local enabled = " "
                            return require("copilot.client").is_disabled() and disabled or enabled
                        end,
                        padding = { left = 0, right = 0 },
                        cond = function()
                            return require("lazy").is_loaded("copilot.lua")
                        end,
                    },
                },
                lualine_y = {
                    {
                        "progress",
                        color = { fg = colors.magenta },
                        padding = { left = 1, right = 1 },
                        fmt = vim.trim,
                    },
                    {
                        "location",
                        color = { fg = colors.magenta },
                        padding = { left = 0, right = 1 },
                        fmt = vim.trim,
                    },
                    {
                        "filesize",
                        color = { fg = colors.magenta },
                        cond = conditions.buffer_not_empty,
                        padding = { left = 0, right = 1 },
                        fmt = vim.trim,
                    },
                },
                lualine_z = {
                    {
                        "encoding",
                        fmt = string.upper,
                        on_click = function()
                            vim.cmd.stopinsert()
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
                            local root = display_root()
                            if root and use_global_root then
                                return root .. " "
                            end
                            return root or ""
                        end,
                        on_click = function(_, key, _)
                            if key == "l" then
                                use_global_root = not use_global_root
                            else
                                if use_global_root then
                                    require("utils").select_root()
                                else
                                    require("utils").select_root(0)
                                end
                            end
                        end,
                    },
                },
                lualine_y = {},
                lualine_z = {},
            },
        }
    end,
}
