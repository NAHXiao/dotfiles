return {
    "folke/todo-comments.nvim",
    version = "*",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<leader>qf", ":TodoQuickFix<cr>", mode = "n" },
        {
            "]t",
            function() require('todo-comments').jump_next() end,
            mode = "n",
            desc = "Next todo comment"
        },
        {
            "[t",
            function() require('todo-comments').jump_prev() end,
            mode = "n",
            desc = "Previous todo comment"
        },
        {
            "<leader>ft",
            "<cmd>TodoTelescope<cr>",
            mode = "n",
            desc = "Toggle todo comment"
        }
    },
    config = function()
        require("todo-comments").setup()
    end,
}
