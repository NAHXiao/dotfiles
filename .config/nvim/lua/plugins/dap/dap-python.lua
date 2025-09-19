return {
    "mfussenegger/nvim-dap-python",
    lazy = true,
    ft = { "python" },
    config = function()
        if require("mason-registry").is_installed("debugpy") then
            require("dap-python").setup(
                vim.fs.joinpath(vim.fn.expand("$MASON"), "packages", "debugpy", "venv/bin/python")
            )
        else
            vim.notify("debugpy is not installed,try MasonInstall debugpy", vim.log.levels.WARN)
        end
    end,
    keys = {
        {
            "<leader>dtm",
            function()
                require("dap-python").test_method()
            end,
            desc = "Test method",
            ft = { "python" },
        },
        {
            "<leader>dtc",
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
