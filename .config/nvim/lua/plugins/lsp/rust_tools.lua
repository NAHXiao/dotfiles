vim.g.rustaceanvim = function()
    local extension_path = vim.fs.joinpath(
        require("tools.config.lsp").mason_install_root_dir,
        "packages/codelldb/extension"
    )
    local codelldb_path = extension_path .. "adapter/codelldb"
    local liblldb_path = extension_path .. "lldb/lib/liblldb"
    -- The path is different on Windows
    if jit.os == "Windows" then
        codelldb_path = extension_path .. "adapter\\codelldb.exe"
        liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
    else
        -- The liblldb extension is .so for Linux and .dylib for MacOS
        liblldb_path = liblldb_path .. (jit.os == "Linux" and ".so" or ".dylib")
    end

    local cfg = require("rustaceanvim.config")
    ---@type rustaceanvim.Executor
    local executor = {
        execute_command = function(command, args, cwd, opts)
            local cmds = require("rustaceanvim.shell").make_command_from_args(command, args)
            require("tools.term").newtask(
                table.concat(
                    require("utils").list_compact {
                        command,
                        args and args[1] or nil,
                        #args > 1 and "..." or nil,
                        "(rustacea)",
                    },
                    " "
                ),
                { cmds = cmds, opts = { env = opts.env, cwd = cwd } },
                false,
                true,
                "PLUGIN:rustaceanvim CMD:" .. cmds
            )
        end,
    }
    return {
        ---@type rustaceanvim.tools.Opts
        tools = {
            executor = executor,
            test_executor = executor,
            crate_test_executor = executor,
        },
        ---@type rustaceanvim.lsp.ClientOpts
        server = {},
        ---@type rustaceanvim.dap.Opts
        dap = {
            adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },
    }
end
return {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
    dependencies = {
        "mfussenegger/nvim-dap",
    },
    config = function()
        require("utils").auc("FileType", {
            pattern = { "rust" },
            callback = function(ev)
                local map = function(mode, lhs, rhs, desc)
                    require("utils").map(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
                end

                map("n", "<localleader>d", function()
                    vim.cmd.RustLsp("debuggables")
                end, "Rust Show Debuggables")
                map("n", "<localleader>D", function()
                    vim.cmd.RustLsp { "debuggables", bang = true }
                end, "Rust Run Last Debuggables")
                map("n", "<localleader>r", function()
                    vim.cmd.RustLsp("runnables")
                end, "Rust Show Runnables")
                map("n", "<localleader>R", function()
                    vim.cmd.RustLsp { "runnables", bang = true }
                end, "Rust Run Last Runnables")
                map("n", "<localleader>t", function()
                    vim.cmd.RustLsp("testables")
                end, "Rust Show Testables")
                map("n", "<localleader>T", function()
                    vim.cmd.RustLsp { "testables", bang = true }
                end, "Rust Run Last Testables")

                map("n", "<localleader>me", function()
                    vim.cmd.RustLsp("expandMacro")
                end, "Rust Expand Macro")
                map("n", "<localleader>mb", function()
                    vim.cmd.RustLsp("rebuildProcMacros")
                end, "Rust Rebuild ProcMacros")

                map("n", "<localleader>ca", function()
                    vim.cmd.RustLsp("codeAction")
                end, "Rust codeAction")

                map("n", "<localleader>cd", function()
                    vim.cmd.RustLsp("relatedDiagnostics")
                end, "Rust relatedDiagnostics(quickfix)")
                -- vim.cmd.RustAnalyzer { 'config', '{ checkOnSave = false }' }
            end,
        })
    end,
}
