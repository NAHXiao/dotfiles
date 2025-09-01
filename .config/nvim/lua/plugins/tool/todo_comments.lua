-- TODO:
-- HACK:
-- WARN:
-- PERF:
-- NOTE:
-- TEST:
-- 注意:必须带:

return {
    "folke/todo-comments.nvim",
    version = "*",
    lazy = true,
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    keys = {
        { "<leader>qt", "<cmd>TodoQuickFix<cr>", mode = "n", desc = "QuickFix: Todo" },
        {
            "]t",
            function()
                require("todo-comments").jump_next()
            end,
            mode = "n",
            desc = "Next todo comment",
        },
        {
            "[t",
            function()
                require("todo-comments").jump_prev()
            end,
            mode = "n",
            desc = "Previous todo comment",
        },
        {
            "<leader>ft",
            "<cmd>TodoTelescope<cr>",
            mode = "n",
            desc = "Find todo comment",
        },
    },
    config = function()
        require("todo-comments").setup {
            keywords = {
                FIX = {
                    icon = " ", -- icon used for the sign, and in search results
                    color = "error", -- can be a hex color, or a named color (see below)
                    alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
                    -- signs = false, -- configure signs for some keywords individually
                },

                TODO = { icon = "✖ ", color = "info" },
                DONE = { icon = "✔ ", color = "info" }, --
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
                TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
            search = {
                command = "rg",
                args = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--follow",
                },
                pattern = [[\b(KEYWORDS):]],
            },
        }
    end,
}
