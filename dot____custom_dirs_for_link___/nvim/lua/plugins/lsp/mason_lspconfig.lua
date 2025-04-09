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
        local default_lsp_settings = {
            root_dir = function()
                return vim.b.projroot or vim.g.ProjectRoot
            end
        }
        require("mason-lspconfig").setup_handlers {
            function(server_name) -- default handler (optional)
                require("lspconfig")[server_name].setup(default_lsp_settings)
            end,
            ["clangd"] = function()
                require("lspconfig").clangd.setup(vim.tbl_extend("force", default_lsp_settings, {
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
                    }
                }))
            end

        }
    end,
}
