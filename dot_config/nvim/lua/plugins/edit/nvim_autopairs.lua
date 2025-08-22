return {
    "windwp/nvim-autopairs",
    version = "*",
    lazy = true,
    event = "InsertEnter",
    dependencies = {},
    config = function()
        require("nvim-autopairs").setup {}
    end,
}
