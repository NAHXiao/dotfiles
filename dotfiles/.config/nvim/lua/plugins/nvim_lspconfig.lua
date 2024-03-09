return {
    "neovim/nvim-lspconfig",
    version = "*",
    lazy = false,
    event='UIEnter',
    dependencies = {
        "williamboman/mason.nvim",
    },
    -- config = function()
    --     require("lspconfig").clangd.setup {
    --         -- on_attach = on_attach,
    --         --capabilities = cmp_nvim_lsp.default_capabilities(),
    --         cmd = {
    --             "clangd",
    --             "--offset-encoding=utf-8",
    --         },
    --     }
    -- end,
}
