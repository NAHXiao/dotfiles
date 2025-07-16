return {
    "mfussenegger/nvim-dap-python",
    lazy = true,
    cond=false,
    ft = { "python" },
    config = function()
        if require("mason-registry").is_installed("debugpy") then
            require("dap-python").setup(
                vim.fs.joinpath(
                    require("mason-registry").get_package("debugpy"):get_install_path(),
                    "venv/bin/python"
                )
            )
        else
            vim.notify("debugpy is not installed,try MasonInstall debugpy", vim.log.levels.WARN)
        end
    end,
    keys = {
        {
            "<leader>dn",
            function()
                require("dap-python").test_method()
            end,
            desc = "Test method",
            ft = { "python" },
        },
        {
            "<leader>df",
            function()
                require("dap-python").test_class()
            end,
            desc = "Test class",
            ft = { "python" },
        },
        {
            "<leader>ds",
            function()
                require("dap-python").debug_selection()
            end,
            mode = "v",
            desc = "Debug selection",
            ft = { "python" },
        },
    },
}

