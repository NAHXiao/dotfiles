return {
    "williamboman/mason.nvim",
    version = "*",
    lazy = false,
    event = "UIEnter",
    dependencies = {},
    config = function()
        require("mason").setup({
            install_root_dir = GVars.mason_install_root_dir,
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
