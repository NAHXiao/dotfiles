return {
    "williamboman/mason-lspconfig.nvim",
    version = "*",
    lazy = false,
    event = "UIEnter",
    dependencies = {
        "williamboman/mason.nvim",
    },
    config = function()
        local ensure_installed
        local arch = vim.loop.os_uname().machine
        if arch == "x86_64" then
            ensure_installed =
                { "lua_ls", "rust_analyzer", "clangd", "bashls", "jdtls", "cmake", "pyright" }
        elseif arch == "aarch64" then
            ensure_installed = { "bashls", "jdtls", "cmake", "pyright" }
        else
            -- ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "bashls", "lua_ls", "jdtls", "cmake", "pyright" };
        end
        require("mason-lspconfig").setup({
            ensure_installed = ensure_installed,
        })
        local default_lsp_settings = {
            root_dir = function()
                return vim.b.projroot or vim.g.projroot
            end,
        }
        require("mason-lspconfig").setup_handlers({
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
                    },
                }))
            end,
            ["lua_ls"] = function()
                require("lspconfig").lua_ls.setup(vim.tbl_extend("force", default_lsp_settings, {
                    on_init = function(client)
                        if client.workspace_folders then
                            local path = client.workspace_folders[1].name
                            if path == vim.fn.stdpath("config") then
                                client.config.settings.Lua =
                                    vim.tbl_deep_extend("force", client.config.settings.Lua, {
                                        runtime = {
                                            version = "LuaJIT",
                                        },
                                        workspace = {
                                            checkThirdParty = false,
                                            library = (function(runtime_files)
                                                local patheq = function(a, b)
                                                    return vim.fs.normalize(a)
                                                        == vim.fs.normalize(b)
                                                end
                                                for k, v in ipairs(runtime_files) do
                                                    if
                                                        patheq(
                                                            v,
                                                            vim.fn.stdpath("config") .. "/after"
                                                        )
                                                        or patheq(v, vim.fn.stdpath("config"))
                                                    then
                                                        table.remove(runtime_files, k)
                                                    end
                                                end
                                                return runtime_files
                                            end)(
                                                vim.api.nvim_get_runtime_file("", true)
                                            ),
                                        },
                                    })
                            end
                        end
                    end,
                    settings = {
                        Lua = {},
                    },
                }))
            end,
        })
    end,
}
