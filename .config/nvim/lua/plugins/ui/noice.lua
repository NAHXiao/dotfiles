local enable
return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        {
            "rcarriga/nvim-notify",
            event = "VeryLazy",
            keys = {
                -- { "<leader>fn", "<cmd>Telescope notify<cr>" },
            },
            cond = vim.version.cmp(vim.version(), "0.10.0") >= 0,
            config = function()
                local notify = require("notify")
                notify.setup({
                    render = "minimal",
                    stages = "static", --"fade",
                    top_down = false,
                })
                local old_notify = notify.notify
                local new_notify = function(msg, level, opts)
                    if
                        string.match(
                            string.lower(tostring(msg)),
                            "^.*copilot.*not authenticated.*$"
                        )
                    then
                        vim.cmd("Copilot disable")
                    end
                    return old_notify(msg, level, opts)
                end
                notify.notify = new_notify
                vim.notify = notify
            end,
        },
    },
    opts = {
        presets = {
            bottom_search = true, -- use a classic bottom cmdline for search
            command_palette = true, -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false, -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = true, -- add a border to hover docs and signature help
        },
        lsp = {
            signature = {
                enabled = false,
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
                    vim_echo("Noice: Disabled")
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
}
