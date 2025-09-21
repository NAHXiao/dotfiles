return {
    "nvimdev/lspsaga.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    event = "LspAttach",
    opts = {
        code_action = {
            extend_gitsigns = true,
            show_server_name = true,
        },
        diagnostic = {
            diagnostic_only_current = false,
        },
        lightbulb = {
            sign = false,
            virtual_text = false,
        },
        outline = {
            keys = {
                toggle_or_jump = "o",
                quit = "q",
                jump = "<CR>",
            },
        },
        symbol_in_winbar = {
            enable = false,
        },
        hover = {
            enable = false,
        },
        ui = {
            border = "rounded",
        },
    },
    keys = {
        -- { "<Leader>lc", "<Cmd>Lspsaga incomping_calls<CR>", mode = "n", desc = "Callers" },
        -- { "<Leader>lC", "<Cmd>Lspsaga outgoing_calls<CR>", mode = "n", desc = "Callees" },
        -- { "<Leader>ld", "<Cmd>Lspsaga peek_definition<CR>", mode = "n", desc = "Lspsaga peek_definition" },
        -- { "<Leader>lh", "<Cmd>Lspsaga hover_doc<CR>", mode = "n", desc = "Lspsaga hover_doc" },
        -- { "<Leader>s", "<Cmd>Lspsaga outline<CR>", mode = "n", desc = "Lspsaga outline" },
        -- { "<Leader>lr", "<Cmd>Lspsaga rename<CR>", mode = "n", desc = "Lspsaga rename" },
    },
}
