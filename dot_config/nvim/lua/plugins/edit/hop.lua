return {
    "phaazon/hop.nvim",
    version = "*",
    lazy = true,
    keys = {
        { "HH", "<cmd>HopWordMW<cr>", desc = "jump to word" },
        { "HF", "<cmd>HopPattern<cr>", desc = "jump to pattern" },
        { "HL", "<cmd>HopLineStart<cr>", desc = "jump to line" },
    },
    init = function()
        require("tools.hl").add_transparent_groups({
            "HopUnmatched",
            "HopNextKey",
            "HopNextKey1",
            "HopNextKey2",
        })
    end,
    config = function()
        require("hop").setup()
    end,
}
