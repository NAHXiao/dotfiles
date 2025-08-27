---TODO: <rtp>? keymap | runnable->term.lua |
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
    return {
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

                map("n", "<leader><leader>d", function()
                    vim.cmd.RustLsp("debuggables")
                end, "Rust Show Debuggables")
                map("n", "<leader><leader>D", function()
                    vim.cmd.RustLsp { "debuggables", bang = true }
                end, "Rust Run Last Debuggables")
                map("n", "<leader><leader>r", function()
                    vim.cmd.RustLsp("runnables")
                end, "Rust Show Runnables")
                map("n", "<leader><leader>R", function()
                    vim.cmd.RustLsp { "runnables", bang = true }
                end, "Rust Run Last Runnables")
                map("n", "<leader><leader>t", function()
                    vim.cmd.RustLsp("testables")
                end, "Rust Show Testables")
                map("n", "<leader><leader>T", function()
                    vim.cmd.RustLsp { "testables", bang = true }
                end, "Rust Run Last Testables")

                map("n", "<leader><leader>me", function()
                    vim.cmd.RustLsp("expandMacro")
                end, "Rust Expand Macro")
                map("n", "<leader><leader>mb", function()
                    vim.cmd.RustLsp("rebuildProcMacros")
                end, "Rust Rebuild ProcMacros")

                map("n", "<leader><leader>ca", function()
                    vim.cmd.RustLsp("codeAction")
                end, "Rust codeAction")

                map("n", "<leader><leader>cd", function()
                    vim.cmd.RustLsp("relatedDiagnostics")
                end, "Rust relatedDiagnostics(quickfix)")
                -- vim.cmd.RustAnalyzer { 'config', '{ checkOnSave = false }' }
            end,
        })
    end,
}
