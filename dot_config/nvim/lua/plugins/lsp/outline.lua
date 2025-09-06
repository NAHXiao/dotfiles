return {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
        { "<leader>s", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
        outline_items = {
            show_symbol_details = false,
            show_symbol_lineno = true,
        },
        prividers = {
            lsp = {
                blacklist_clients = {
                    "marksman",
                },
            },
        },
        symbols = {
            icon_source = "lspkind",
        },
    },
}
