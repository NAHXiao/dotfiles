return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "LiadOz/nvim-dap-repl-highlights",
        "nvim-neotest/nvim-nio",
    },
    lazy = true,
    keys = {
        {
            "<leader>du",
            function()
                require("dapui").toggle({ layout = 1 })
            end,
            desc = "Debug: Toggle UI sidebar",
        },
        {
            "<leader>dU",
            function()
                require("dapui").toggle({})
            end,
            desc = "Debug: Toggle UI",
        },
        {
            "<leader>dc",
            function()
                require("dapui").toggle({ layout = 2 })
            end,
            desc = "Debug: Toggle console",
        },
        {
            "<leader>dk",
            -- "<M-k>",
            function()
                require("dapui").eval()
            end,
            desc = "Debug: Evaluate expression",
            mode = { "n", "v" },
        },
    },
    config = function()
        local opts = {
            floating = {
                -- border = custom.border,
                border = "rounded",
            },
            layouts = {
                {
                    elements = {
                        {
                            id = "scopes",
                            size = 0.25,
                        },
                        {
                            id = "breakpoints",
                            size = 0.25,
                        },
                        {
                            id = "stacks",
                            size = 0.25,
                        },
                        {
                            id = "watches",
                            size = 0.25,
                        },
                    },
                    position = "left",
                    size = 30,
                },
                {
                    elements = {
                        {
                            id = "repl",
                            size = 0.5,
                        },
                        {
                            id = "console",
                            size = 0.5,
                        },
                    },
                    position = "bottom",
                    size = 15,
                },
            },
        }
        require("dapui").setup(opts)
        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
        --注册命令DapuiClose,DapuiOpen
        vim.cmd("command! DapUiToggle lua require('dapui').toggle()")
    end,
}
