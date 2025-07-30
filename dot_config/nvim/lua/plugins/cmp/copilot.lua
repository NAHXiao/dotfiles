-- local logger = require("copilot.logger")
-- local _notify = logger.notify
-- logger.notify = function(msg, ...)
--     require("utils").log(msg)
--     _notify(msg, ...)
-- end
-- logger.notify="hello"
-- vim.fn.writefile()
return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    version = "*",
    lazy = true,
    keys = {
        { "<leader>\\a", "<cmr>Copilot toggle<cr>", desc = "Toggle Copilot(AI Completion)" },
    },
    init = function() end,
    config = function()
        local _select = vim.ui.select
        function vim.ui.select(items, opts, on_choice)
            if
                opts
                and opts.prompt
                and type(opts.prompt) == "string"
                and string.match(opts.prompt, [[^You've reached.*limit.*Upgrade.*$]])
            then
                vim.notify("Copilot: " .. opts.prompt, vim.log.levels.ERROR)
                vim.cmd("Copilot disable")
            else
                _select(items, opts, on_choice)
            end
        end

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
        -- https://github.com/zbirenbaum/copilot.lua/issues/91
        vim.keymap.set("i", "<Tab>", function()
            if require("copilot.suggestion").is_visible() then
                require("copilot.suggestion").accept()
            else
                vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
                    "n",
                    false
                )
            end
        end, {
            silent = true,
        })
    end,
}
