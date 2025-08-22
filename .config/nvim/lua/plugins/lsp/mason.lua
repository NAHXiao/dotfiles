return {
    "williamboman/mason.nvim",
    version = "*",
    lazy = true,
    cmd = "Mason",
    config = function()
        require("mason").setup {
            install_root_dir = Globals.mason_install_root_dir,
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
                border = "rounded",
            },
        }
    end,
}
