return {
    "windwp/nvim-autopairs",
    version = "*",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
    },
    config = function()
        require("nvim-autopairs").setup {}
    end,
}
