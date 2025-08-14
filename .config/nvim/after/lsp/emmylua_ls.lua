return {
    settings = {
        emmylua = {
            completion = {
                callSnippet = "Both",
                keywordSnippet = "Both",
            },
            workspace = {
                checkThirdParty = false,
                library = (function(runtime_files)
                    local patheq = function(a, b)
                        return vim.fs.normalize(a) == vim.fs.normalize(b)
                    end
                    for k, v in ipairs(runtime_files) do
                        if
                            patheq(v, vim.fn.stdpath("config") .. "/after")
                            or patheq(v, vim.fn.stdpath("config"))
                        then
                            table.remove(runtime_files, k)
                        end
                    end
                    return runtime_files
                end)(vim.api.nvim_get_runtime_file("", true)),
            },
            runtime = {
                version = "LuaJIT",
                path = vim.list_extend(vim.split(package.path, ";"), {
                    "lua/?.lua",
                    "lua/?/init.lua",
                }),
            },
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
}
