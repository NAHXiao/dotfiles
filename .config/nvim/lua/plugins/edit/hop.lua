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
        vim.g.transparent_groups = vim.list_extend(vim.g.transparent_groups or {}, {
            "HopUnmatched",
            "HopNextKey",
            "HopNextKey1",
            "HopNextKey2",
        })
    end,
}
