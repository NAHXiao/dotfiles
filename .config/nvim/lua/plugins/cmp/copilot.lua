return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    version = "*",
    lazy = true,
    dependencies = {},
    config = function()
        require("copilot").setup({
            panel = {
                enabled = true,
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
                enabled = true,
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
