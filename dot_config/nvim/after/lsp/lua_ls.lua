-- local function get_library()
--     local runtime_files = vim.api.nvim_get_runtime_file("", true)
--     local patheq = function(a, b)
--         return vim.fs.normalize(a) == vim.fs.normalize(b)
--     end
--     for k, v in ipairs(runtime_files) do
--         if
--             patheq(v, vim.fn.stdpath("config") .. "/after")
--             or patheq(v, vim.fn.stdpath("config"))
--         then
--             table.remove(runtime_files, k)
--         end
--     end
--     return runtime_files
-- end
return {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            workspace = {
                -- checkThirdParty = false,
                -- library = get_library(),
            },
        },
    },
    -- on_init = function()
        -- vim.api.nvim_create_user_command("LspLualsUpdateVimRuntime", function()
        --     local cfg = vim.lsp.config.lua_ls
        --     cfg.settings = vim.tbl_deep_extend('force', cfg.settings, {
        --         Lua = {
        --             runtime = {
        --                 version = "LuaJIT",
        --             },
        --             workspace = {
        --                 checkThirdParty = false,
        --                 library = get_library(),
        --             },
        --         },
        --     })
        -- end, {})
    -- end
}
