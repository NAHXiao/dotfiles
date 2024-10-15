return {
    'phaazon/hop.nvim',
    version = "*",
    lazy = true,
    dependencies = {
    },
    keys = {
        { "HH", "<cmd>HopWordMW<cr>" },
        { "HF", "<cmd>HopPattern<cr>" },
        { "HL", "<cmd>HopLineStart<cr>" },
    },
    -- cmd = {
    --     "HopoWordMW",
    --     "HopPattern",
    --     "HopLineStart"
    -- },
    config = function()
        require 'hop'.setup()
    end,
}
