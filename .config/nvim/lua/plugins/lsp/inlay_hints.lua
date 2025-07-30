return {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    keys = {
        { "<leader>\\i", "<cmd>InlayHintsToggle<cr>", desc = "Toggle inlayhints" },
    },
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        require("inlay-hints").setup()
    end,
}
