return {
    "phaazon/hop.nvim",
    version = "*",
    lazy = true,
    keys = {
        { "HH", "<cmd>HopWordMW<cr>", desc = "jump to word" },
        { "HF", "<cmd>HopPattern<cr>", desc = "jump to pattern" },
        { "HL", "<cmd>HopLineStart<cr>", desc = "jump to line" },
    },
    config = function()
        require("hop").setup()
    end,
}
