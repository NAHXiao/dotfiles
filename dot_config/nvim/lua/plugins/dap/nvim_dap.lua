vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "Constant", linehl = "debugPC" })
vim.fn.sign_define("DapBreakpointRejected", { text = "" })
return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "jay-babu/mason-nvim-dap.nvim",
        "LiadOz/nvim-dap-repl-highlights",
        "theHamsta/nvim-dap-virtual-text",
        "rcarriga/nvim-dap-ui",
    },
    lazy = true,
    keys = {
        {
            "<F2>",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Debug: Toggle breakpoint",
        },
        {
            vim.g.is_win and "<S-F2>" or "<F14>",
            function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            desc = "Debug: Set breakpoint" .. (vim.g.is_win and "" or " <Shift-F2>"),
        },
        {
            vim.g.is_win and "<C-F2>" or "<F26>",
            function()
                require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
            end,
            desc = "Debug: Set log point" .. (vim.g.is_win and "" or " <Ctrl-F2>"),
        },

        {
            "<F3>",
            function()
                require("dap").repl.toggle()
            end,
            desc = "Debug: Toggle REPL",
        },

        {
            "<F4>",
            function()
                require("dap").run_last()
            end,
            desc = "Debug: Run last",
        },

        {
            "<F5>",
            function()
                local continue = function()
                    if
                        1
                        == vim.fn.filereadable(
                            vim.fs.joinpath(vim.g.projroot, ".vscode/launch.json")
                        )
                    then
                        require("dap.ext.vscode").load_launchjs(nil, { cppdbg = { "c", "cpp" } })
                    end
                    require("dap").continue()
                end
                continue()
            end,
            desc = "Debug: Continue",
        },

        {
            "<F6>",
            function()
                require("dap").step_into()
            end,
            desc = "Debug: Step into Function/Method",
        },
        {
            "<F7>",
            function()
                require("dap").step_over()
            end,
            desc = "Debug: Step over",
        },
        {
            "<F8>",
            function()
                require("dap").step_out()
            end,
            desc = "Debug: Step out Function/Method",
        },
    },
    config = function()
        require("mason").setup()
        require("mason-nvim-dap").setup({
            --见列表: https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
            ensure_installed = { "python", "cppdbg", "bash", "codelldb" },
            automatic_installation = true,
            -- automatic_installation = { exclude = { "python", "delve" } },
            handlers = {
                codelldb = function(config)
                    config.adapters = {
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = vim.fn.exepath("codelldb"),
                            args = {
                                "--port",
                                "${port}",
                                "--settings",
                                vim.json.encode({
                                    showDisassembly = "never", -- 不显示反汇编
                                }),
                            },
                            deteched = vim.g.is_win == false,
                        },
                    }
                    require("mason-nvim-dap").default_setup(config)
                end,
                python = function() end, --python用别的
                -- delve = function() end,
            },
        })
        require("nvim-dap-repl-highlights").setup()
        -- local dap = require("dap")
        -- dap.configurations.cpp = {
        --     {
        --         name = "Launch file",
        --         type = "codelldb",
        --         request = "launch",
        --         program = function()
        --             return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        --         end,
        --         cwd = '${workspaceFolder}',
        --         stopOnEntry = false,
        --     },
        -- }
        -- dap.configurations.c = dap.configurations.cpp
        -- dap.configurations.rust = dap.configurations.cpp
    end,
}
