local M = {}
local utils = require("utils")
local compact = require("utils").list_compact
local machine = vim.uv.os_uname().machine
---@generic T
---@param val T
---@param fallback? T
---@return T
local function ifArch(arch, val, fallback)
    return machine == arch and val or fallback
end
---@generic T
---@param val T
---@param fallback? T
---@return T
local function notArch(arch, val, fallback)
    return machine ~= arch and val or fallback
end
---@class LspNamesMethod
local keys_method = {
    ---@generic T
    ---@param self T
    ---@param exclude table<string>
    ---@return T
    exclude = function(self, exclude)
        local p = 1
        for q, it in ipairs(self) do
            self[q] = nil
            if not vim.list_contains(exclude, it) then
                self[p] = it
                p = p + 1
            end
        end
        return self
    end,
    ---@generic T
    ---@param self T
    ---@param only table<string>
    ---@return T
    only = function(self, only)
        local p = 1
        for q, it in ipairs(self) do
            self[q] = nil
            if vim.list_contains(only, it) then
                self[p] = it
                p = p + 1
            end
        end
        return self
    end,
    ---@generic T
    ---@param self T
    ---@param appendlist table<string>
    ---@return T
    append = function(self, appendlist)
        for _, item in ipairs(appendlist) do
            self[#self + 1] = item
        end
        return self
    end,
}
local function keys(...)
    local allkeys = {}
    for _, tbl in ipairs { ... } do
        vim.list_extend(allkeys, vim.tbl_keys(tbl))
    end
    setmetatable(allkeys, {
        __index = keys_method,
    })
    ---@class LspNames : LspNamesMethod
    return allkeys
end
---@type table<string,vim.lsp.Config>
M.override = {}
---@type table<string,vim.lsp.Config>
M.extend = {
    clangd = {
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
    },
    lua_ls = {
        settings = {
            Lua = {
                hint = {
                    enable = true,
                },
                runtime = {
                    version = "LuaJIT",
                },
                workspace = {
                    -- checkThirdParty = false,
                    -- library = get_library(),
                },
                type = {
                    infer = true,
                    inferTableSize = 10,
                },
            },
        },
    },
    jsonls = {
        settings = { json = { validate = { enable = true } } },
        on_attach = function(client)
            client.config.settings.json.schemas = require("schemastore").json.schemas()
        end,
    },
    yamlls = {
        settings = {
            yaml = {
                schemaStore = { enabled = false, url = "" },
                validate = { enable = true },
                yamlVersion = 1.2,
                format = { enable = true },
                hover = true,
                completion = true,
            },
            redhat = { telemetry = { enabled = false } },
        },
        on_attach = function(client)
            client.config.settings.yaml.schemas = require("schemastore").yaml.schemas()
        end,
    },
    taplo = {},
    basedpyright = {
        settings = { basedpyright = { analysis = { typeCheckingMode = "recommended" } } },
    },
    neocmake = {},
    cmake = {},
    bashls = {
        filetypes = {
            "sh",
            "bash",
            "zsh",
            "fish",
            "ksh",
            "csh",
            "tcsh",
            "bashrc",
            "bash_profile",
        },
    },
    rust_analyzer = {},
    jdtls = {},
    dockerls = {},
    cssls = {},
    tailwindcss = {},
    superhtml = {},
    html = {},
    vue_ls = { init_options = { vue = { hybridMode = true } } },
    vtsls = {
        filetypes = {
            "typescript",
            "typescriptreact",
            "typescript.tsx",
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "vue",
            "astro",
        },
        settings = {
            vtsls = {
                tsserver = {
                    globalPlugins = {
                        {
                            name = "@vue/typescript-plugin",
                            location = vim.fn.exepath("vue-language-server"),
                            languages = { "vue" },
                            configNamespace = "typescript",
                            enableForWorkspaceTypeScriptVersions = true,
                        },
                    },
                },
            },
        },
    },
    marksman = {},
    gopls = {
        settings = {
            gopls = {
                analyses = {
                    ST1003 = true,
                    fieldalignment = false,
                    fillreturns = true,
                    nilness = true,
                    nonewvars = true,
                    shadow = true,
                    undeclaredname = true,
                    unreachable = true,
                    unusedparams = true,
                    unusedwrite = true,
                    useany = true,
                },
                codelenses = {
                    generate = true,
                    run_govulncheck = true,
                    regenerate_cgo = true,
                    test = true,
                    tidy = true,
                    upgrade_dependency = true,
                    vendor = true,
                },
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
                buildFlags = { "-tags", "integration" },
                completeUnimported = true,
                diagnosticsDelay = "500ms",
                gofumpt = true,
                matcher = "Fuzzy",
                semanticTokens = true,
                staticcheck = true,
                symbolMatcher = "fuzzy",
                usePlaceholders = true,
            },
        },
    },
    sqls = {},
}
M.auto_enable = keys(M.extend, M.override):exclude(compact {
    "jdtls",
    "rust_analyzer",
    ifArch("aarch64", "neocmake", "cmake"),
})
M.mason_ensure_install_lsp = keys(M.extend, M.override):exclude(compact {
    ifArch("aarch64", "clangd"),
    jit.os == "Windows" and "clangd" or nil, --mason's clangd(official) prefer MSVS otherthan MINGW
    ifArch("aarch64", "lua_ls"),
    ifArch("aarch64", "rust_analyzer"),
    ifArch("aarch64", "basedpyright"), --npm install -g basedpyright
    vim.fn.executable("go") == 0 and "gopls" or nil,
    vim.fn.executable("go") == 0 and "sqls" or nil,
    ifArch("aarch64", "neocmake", "cmake"),
})
M.mason_ensure_install_dap = {
    "cpptools",
    "codelldb",
    "debugpy",
}
M.mason_ensure_install_extra = {
    "stylua",
    "asmfmt",
    "clang-format",
    "google-java-format",
    "pyink",
    "standardjs",
    "yamlfmt",
    "beautysh",
}
M.mason_install_root_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "mason")

-----------------------------------------------------------
---@type vim.lsp.Config
M.lsp_default_config = {}
M.ulsp_config_path = function()
    return vim.fs.joinpath(utils.get_rootdir() or vim.fn.getcwd(), ".vim", "lsp.lua")
end
---@type lsp_config
M.ulsp_config = nil
M.ulsp_config_tmpl = ([[---vim will attempt to prevent vim.lsp.enable() for all LSPs that are in the disable list but not in disable_exclude.
---You need to restart vim to apply the changes.
---@type {disable?:table<string>|true,disable_exclude?:table<string>,extend?:table<string,vim.lsp.Config>,override?:table<string,vim.lsp.Config>}
---See [%s]
return {}]]):format(vim.fs.joinpath(require("lazy").lazy_plugin_path("nvim-lspconfig"), "lsp"))
return M
