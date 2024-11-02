return {
    "folke/trouble.nvim",
    version = "*",
    --map("n", "<leader>e", ":TroubleToggle<cr>")
    keys = {
        { "<leader>e", ":TroubleToggle<cr>" },
    },
    cmd="TroubleToggle",
    lazy = true,
    config = function()
    end,
}
