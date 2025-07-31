return {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    keys = {
        { "<leader>\\i", "<cmd>InlayHintsToggle<cr>", desc = "Toggle inlayhints" },
    },
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        require("inlay-hints").setup()
        require("tools.hl").regist_transparent({
            LspInlayHint = {
                bg = {
                    transform = "lighten",
                    from = "LspInlayHint.bg",
                    amount = 0.3,
                },
            },
        })
    end,
}
