vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "Constant", linehl = "debugPC" })
vim.fn.sign_define("DapBreakpointRejected", { text = "" })
return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "williamboman/mason.nvim",
            "theHamsta/nvim-dap-virtual-text",

            "jay-babu/mason-nvim-dap.nvim", -- ensure dap configurated by mason-nvim-dap
            "rcarriga/nvim-dap-ui", -- ensure dap-ui loaded when dap
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
                "<F5>", --TODO: Edit
                function()
                    local dap = require("dap")
                    local root = vim.g.projroot
                    local paths = {
                        root .. "/.nvim/dap.lua",
                        root .. "/.vim/dap.lua",
                        root .. "/dap.lua",
                    }
                    local ok = false
                    local config = nil
                    for _, path in pairs(paths) do
                        ok, config = pcall(dofile, path)
                        if ok then
                            dap.configurations[vim.o.filetype] = config
                            break
                        end
                    end
                    dap.continue()
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
    },

    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        lazy = true,
        config = function()
            --见列表: https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
            require("mason-nvim-dap").setup({
                ensure_installed = { "python", "cppdbg", "bash", "codelldb" },
                automatic_installation = true,
                handlers = {
                    function(config)
                        -- config = { name = "调试器名", adapters = {调试器配置}, configurations = {{启动方式;启动设置}}, filetypes = {} },
                        require("mason-nvim-dap").default_setup(config)
                    end,
                    python = function() end, --python用别的
                },
            })
        end,
    },
}
