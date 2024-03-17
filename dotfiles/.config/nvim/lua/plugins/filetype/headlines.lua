return {
    "lukas-reineke/headlines.nvim",
    version = "*",
    lazy = true,
    ft='markdown',
    config = function()
        require "headlines".setup()
    end,
}
