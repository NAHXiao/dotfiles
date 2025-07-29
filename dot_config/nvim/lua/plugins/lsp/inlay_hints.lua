return {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    keys = {
        { "<leader>\\in", "<cmd>InlayHintsToggle<cr>", desc = "Toggle inlayhints" },
    },
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        require("inlay-hints").setup()
    end,
}
