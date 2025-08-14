return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    version = "*",
    lazy = true,
    keys = {
        {
            "<leader>\\a",
            function()
                local disabled = require("copilot.client").is_disabled()
                if disabled then
                    require("copilot.command").enable()
                else
                    vim.b.copilot_suggestion_hidden = false
                    vim.cmd("doautocmd CursorMovedI")
                    require("copilot.command").disable()
                end
                require("utils").vim_echo(
                    ("Copilot: %s"):format(
                        require("copilot.client").is_disabled() and "Disabled" or "Enabled"
                    )
                )
            end,
            desc = "Toggle Copilot(AI Completion)",
        },
    },
    config = function()
        require("copilot").setup({
            panel = {
                enabled = false, -- NOTE: blink.cmp 函数补全
                auto_refresh = false,
                keymap = {
                    jump_prev = "[[",
                    jump_next = "]]",
                    accept = "<CR>",
                    refresh = "gr",
                    open = "<M-CR>",
                },
                layout = {
                    position = "bottom", -- | top | left | right
                    ratio = 0.4,
                },
            },
            suggestion = {
                enabled = true, -- NOTE: blink.cmp 函数补全
                auto_trigger = true,
                debounce = 75,
                keymap = {
                    -- accept = "<Tab>",
                    accept = false,
                    accept_word = false,
                    accept_line = false,
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            filetypes = {
                java = true,
                yaml = false,
                markdown = false,
                help = false,
                gitcommit = false,
                gitrebase = false,
                hgcommit = false,
                svn = false,
                cvs = false,
                ["."] = false,
            },
            copilot_node_command = "node", -- Node.js version must be > 18.x
            server_opts_overrides = {},
        })
        local wrap_uiselect = function(old_uiselect)
            return function(items, opts, on_choice)
                if
                    opts
                    and opts.prompt
                    and type(opts.prompt) == "string"
                    and string.match(opts.prompt, [[^.*reached.*limit.*Copilot.*$]])
                then
                    local year, month, day = opts.prompt:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
                    vim.notify(
                        "Copilot: "
                        .. opts.prompt:match(".*limit%.")
                        .. ("(Will be reset on %d-%d-%d)"):format(year, month, day),
                        vim.log.levels.ERROR
                    )
                    require("copilot.command").disable()
                else
                    old_uiselect(items, opts, on_choice)
                end
            end
        end
        local _select = vim.ui.select
        vim.ui.select = wrap_uiselect(_select)
        require("utils").watch_assign_key(vim.ui, "select", wrap_uiselect)

        -- https://github.com/zbirenbaum/copilot.lua/issues/91
        vim.keymap.set("i", "<Tab>", function()
            if require("copilot.suggestion").is_visible() then
                require("copilot.suggestion").accept()
                vim.snippet.stop()
            else
                vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
                    "n",
                    false
                )
            end
        end, { silent = true })
    end,
}
