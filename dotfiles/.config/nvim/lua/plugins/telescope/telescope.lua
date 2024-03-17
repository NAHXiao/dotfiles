return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    lazy = false,
    -- Telescope
    -- map("n", "<leader>ff", ":lua require('telescope.builtin').find_files()<cr>")
    -- map("n", "<leader>fm", ":Telescope media_files<cr>")
    -- map("n", "<leader>fg", ":lua require('telescope.builtin').live_grep()<cr>")
    -- map("n", "<leader>fb", ":lua require('telescope.builtin').buffers()<cr>")
    -- map("n", "<leader>fh", ":lua require('telescope.builtin').help_tags()<cr>")
    -- map("n", "<leader>fd", ":lua require('telescope.builtin').diagnostics()<cr>")
    -- map("n", "<leader>fs", ":lua require('telescope.builtin').lsp_workspace_symbols()<cr>") --
    -- map("n", "<leader>fr", ":lua require('telescope.builtin').lsp_references()<cr>")
    -- map("n", "<leader>fi", ":lua require('telescope.builtin').lsp_implementations()<cr>")
    -- map("n", "<leader>fl", ":lua require('telescope.builtin').treesitter()<cr>")
    -- map("n", "<leader>fk", ":lua require('telescope.builtin').keymaps()<cr>")
    --
    -- map("n", "<leader>fc", ":lua require('telescope.builtin').commands()<cr>")
    -- map("n", "<leader>fmp", ":lua require('telescope.builtin').man_pages()<cr>")
    -- map("n", "<leader>fgc", ":lua require('telescope.builtin').git_commits()<cr>")
    -- map("n", "<leader>fgb", ":lua require('telescope.builtin').git_branches()<cr>")
    --
    dependencies = {
        { "nvim-lua/popup.nvim" },
        { "nvim-lua/plenary.nvim" },
        { 'nvim-telescope/telescope-fzf-native.nvim' },
        { "nvim-telescope/telescope-media-files.nvim", build = 'make' },
        -- { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    cmd = "Telescope",
    keys = {
        { "<leader>ff",  "<cmd>lua require('telescope.builtin').find_files()<cr>" },
        { "<leader>fm",  "<cmd>lua require('telescope.builtin').media_files()<cr>" },

        { "<leader>fgw", "<cmd>lua require('telescope.builtin').live_grep()<cr>" },
        { "<leader>fg",  "<cmd>lua require('telescope.builtin').live_grep()<cr>" },
        { "<leader>fw",  "<cmd>lua require('telescope.builtin').live_grep()<cr>" },

        { "<leader>fb",  "<cmd>lua require('telescope.builtin').buffers()<cr>" },
        { "<leader>fh",  "<cmd>lua require('telescope.builtin').help_tags()<cr>" },
        { "<leader>fd",  "<cmd>lua require('telescope.builtin').diagnostics()<cr>" },
        { "<leader>fs",  "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>" },
        { "<leader>fr",  "<cmd>lua require('telescope.builtin').lsp_references()<cr>" },
        { "<leader>fi",  "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>" },
        { "<leader>fl",  "<cmd>lua require('telescope.builtin').treesitter()<cr>" },
        { "<leader>fk",  "<cmd>lua require('telescope.builtin').keymaps()<cr>" },
        { "<leader>fc",  "<cmd>lua require('telescope.builtin').commands()<cr>" },
        { "<leader>fmp", "<cmd>lua require('telescope.builtin').man_pages()<cr>" },
        { "<leader>fgc", "<cmd>lua require('telescope.builtin').git_commits()<cr>" },
        { "<leader>fgb", "<cmd>lua require('telescope.builtin').git_branches()<cr>" },
        { "<leader>fch", "<cmd>lua require('telescope.builtin').command_history()<cr>" },
        { "<leader>fsh", "<cmd>lua require('telescope.builtin').search_history()<cr>" },
        {
            "<leader>fn",
            function()
                require("telescope").extensions.notify.notify()
            end,
            desc = "Notify",
        },
    },
    -- map("n", "<leader>fch", ":lua require('telescope.builtin').command_history()<cr>")
    -- map("n", "<leader>fsh", ":lua require('telescope.builtin').search_history()<cr>")
    config = function()
        --- Telescope ---
        require('telescope').setup {}
    end,
}
