return {
    "williamboman/mason-lspconfig.nvim",
    version = "*",
    lazy = false,
    event = 'UIEnter',
    dependencies = {
        "williamboman/mason.nvim",
    },
    config = function()
        local ensure_installed;
        local arch = vim.loop.os_uname().machine
        if arch == "x86_64" then
            ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "bashls", "lua_ls", "jdtls", "cmake", "pyright" };
        elseif arch == "aarch64" then
            ensure_installed = { "bashls", "jdtls", "cmake", "pyright" };
        else
            -- ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "bashls", "lua_ls", "jdtls", "cmake", "pyright" };
        end
        require("mason-lspconfig").setup({
            ensure_installed = ensure_installed,
        })
        require("mason-lspconfig").setup_handlers {
            -- The first entry (without a key) will be the default handler
            -- and will be called for each installed server that doesn't have
            -- a dedicated handler.
            function(server_name) -- default handler (optional)
                require("lspconfig")[server_name].setup {}
            end,
            -- Next, you can provide a dedicated handler for specific servers.
        }
        require("lspconfig").clangd.setup {
            cmd = {
                "clangd",
                "--offset-encoding=utf-16", -- 解决warning: multiple different client offset_encodings detected for buffer, this is not supported yet
                "--fallback-style=webkit",
                "--enable-config",
                "--print-options",
                "--background-index",
                "--clang-tidy",
                "--pch-storage=memory",
                -- "--header-insertion=never",
                -- "--header-insertion-decorators",
                "--all-scopes-completion",
                "--completion-style=detailed",
                "--log=verbose",
                "-j=4",
            },
        }
        require('lspconfig').sqlls.setup {
            -- capabilities = capabilities,
            filetypes = { 'sql' },
            root_dir = function(_)
                return vim.loop.cwd()
            end,
        }
    end,
}
