return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
        { "nvim-lua/popup.nvim" },
        { "nvim-lua/plenary.nvim" },
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build =
            'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    cmd = "Telescope",
    keys = {
        { "<leader>ff",  "<cmd>lua require('telescope.builtin').find_files()<cr>" },

        { "<leader>fgw", "<cmd>lua require('telescope.builtin').live_grep()<cr>" },
        { "<leader>fg",  "<cmd>lua require('telescope.builtin').live_grep()<cr>" },
        { "<leader>fw",  "<cmd>lua require('telescope.builtin').live_grep()<cr>" },

        { "<leader>fb",  "<cmd>lua require('telescope.builtin').buffers()<cr>" },
        { "<leader>fh",  "<cmd>lua require('telescope.builtin').help_tags()<cr>" },
        { "<leader>fd",  "<cmd>lua require('telescope.builtin').diagnostics()<cr>" },
        -- { "<leader>fs",  "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>" },
        { "<leader>fs",  "<cmd>lua require('telescope.builtin').treesitter()<cr>" },
        { "<leader>fr",  "<cmd>lua require('telescope.builtin').lsp_references()<cr>" },
        { "<leader>fi",  "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>" },
        { "<leader>fk",  "<cmd>lua require('telescope.builtin').keymaps()<cr>" },

        { "<leader>fc",  "<cmd>lua require('telescope.builtin').commands()<cr>" },
        -- { "<leader>fp",  "<cmd>lua require('telescope.builtin').commands()<cr>" },

        { "<leader>fmp", "<cmd>lua require('telescope.builtin').man_pages()<cr>" },
        { "<leader>fgc", "<cmd>lua require('telescope.builtin').git_commits()<cr>" },
        { "<leader>fgb", "<cmd>lua require('telescope.builtin').git_branches()<cr>" },
        { "<leader>fsh", "<cmd>lua require('telescope.builtin').search_history()<cr>" },
        {
            "<leader>fn",
            function()
                require("telescope").extensions.notify.notify()
            end,
            desc = "Notify",
        },
        -- {
        --     "<leader>ft",
        --     function()
        --         require("telescope.builtin").colorscheme()
        --     end,
        --     desc = "Colorscheme",
        -- },
    },
    config = function()
        --- Telescope ---
        require('telescope').setup {
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {
                        -- even more opts
                    }

                    -- pseudo code / specification for writing custom displays, like the one
                    -- for "codeactions"
                    -- specific_opts = {
                    --   [kind] = {
                    --     make_indexed = function(items) -> indexed_items, width,
                    --     make_displayer = function(widths) -> displayer
                    --     make_display = function(displayer) -> function(e)
                    --     make_ordinal = function(e) -> string
                    --   },
                    --   -- for example to disable the custom builtin "codeactions" display
                    --      do the following
                    --   codeactions = false,
                    -- }
                },
                fzf = {
                    fuzzy = true,                   -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true,    -- override the file sorter
                    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
                }
            }
        }
        require("telescope").load_extension("ui-select")
        require('telescope').load_extension('fzf')
    end,
}
