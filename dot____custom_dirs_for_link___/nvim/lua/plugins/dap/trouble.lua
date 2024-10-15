return {
    "folke/trouble.nvim",
    version = "*",
    --map("n", "<leader>e", ":TroubleToggle<cr>")
    keys = {
        { "<leader>e", ":TroubleToggle<cr>" },
    },
    lazy = true,
    config = function()
    end,
}
