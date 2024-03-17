return {
    "folke/todo-comments.nvim",
    version = "*",
    lazy = true,
    -- map("n", "<leader>qf", ":TodoQuickFix<cr>")
    keys = {
        { "<leader>qf", ":TodoQuickFix<cr>", mode = "n" },
    },
    config = function()
    end,
}
