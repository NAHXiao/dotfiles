return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        delay = vim.o.timeoutlen / 2,
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
    config = function(_, opts)
        require("which-key").setup(opts)
        require("which-key").add({
            { "<leader>a",        group = "Aider" },
            { "<leader>b",        group = "Buffer" },
            { "<leader>d",        group = "Debug" },
            { "<leader>f",        group = "Find" },
            { "<leader>l",        group = "Lsp" },
            { "<leader>g",        group = "GitSigns" },
            { "<leader>t",        group = "Trouble" },
            { "<leader>\\",       group = "Switch" },
            { "<leader><leader>", group = "Buffer Local Keymaps" },
        })
    end,
}
