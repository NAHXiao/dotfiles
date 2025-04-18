return {
    "simrat39/rust-tools.nvim",
    version = "*",
    lazy = true,
    ft = "rust",
    config = function()
        require("mason-lspconfig").setup_handlers({
            ["rust_analyzer"] = function()
                require("rust-tools").setup({})
            end,
        })
    end,
}
