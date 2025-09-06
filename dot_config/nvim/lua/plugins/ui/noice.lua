local enable
return {
    {
        "rcarriga/nvim-notify",
        event = "UIEnter",
        keys = {
            {
                "<leader>fn",
                function()
                    require("telescope").extensions.notify.notify()
                end,
                desc = "Find Notify",
            },
        },
        config = function()
            local notify = require("notify")
            notify.setup {
                render = "minimal",
                stages = "static", --"fade",
                top_down = true,
                merge_duplicates = true,
            }
            vim.notify = function(msg, ...)
                notify.notify(msg:gsub("\r\n", "\n"):gsub("\r", "\n"), ...)
            end
            vim.g.cleanui_funcs = vim.list_extend(vim.g.cleanui_funcs, {
                function()
                    require("notify").dismiss { pending = false, silent = true }
                end,
            })
        end,
    },
    {
        "folke/noice.nvim",
        event = "UIEnter",
        conf = false,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = false, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
            lsp = {
                signature = {
                    enabled = false,
                },
                hover = {
                    enabled = false,
                },
                progress = {
                    throttle = 1000 / 5, -- frequency to update lsp progress message
                },
                message = {
                    enabled = true,
                    view = "notify",
                    opts = {},
                },
            },
        },
        config = function(_, opts)
            local mod = require("noice")
            local vim_echo = require("utils").vim_echo
            mod.setup(opts)
            vim.schedule(function()
                enable = true
                local _enable = mod.enable
                local _disable = mod.disable
                mod.enable = function()
                    if not enable then
                        _enable()
                        enable = true
                        vim_echo("Noice: Enabled")
                    end
                end
                mod.disable = function()
                    if enable then
                        _disable()
                        enable = false
                    end
                end
                mod.toggle = function()
                    if enable then
                        mod.disable()
                    else
                        mod.enable()
                    end
                end
            end)
            vim.g.cleanui_funcs = vim.list_extend(vim.g.cleanui_funcs, {
                function()
                    vim.cmd("NoiceDismiss")
                end,
            })
        end,
        keys = {
            {
                "<leader>\\n",
                function()
                    require("noice").toggle()
                end,
                desc = "Toggle Noice",
            },
        },
    },
}
