return {
    "williamboman/mason.nvim",
    version = "*",
    lazy = false,
    event = "UIEnter",
    dependencies = {},
    config = function()
        require("mason").setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })
    end,
}
