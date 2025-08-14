local utils = require("utils")
local M = {}
local compact = require("utils").list_compact
---@diagnostic disable-next-line: undefined-field
local machine = vim.uv.os_uname().machine
local function ifArch(arch, val)
    return machine == arch and val or nil
end
local function notArch(arch, val)
    return machine ~= arch and val or nil
end
---@type vim.lsp.Config
M.lsp_default_config = {
    root_markers = { ".git" }
}
M.ulsp_config_path = function() return vim.fs.joinpath(utils.get_rootdir(), ".vim", "lsp.lua") end
M.ulsp_config_tmpl =
    ([[---vim will attempt to prevent vim.lsp.enable() for all LSPs that are in the disable list but not in disable_exclude.
---You need to restart vim to apply the changes.
---@type {disable?:table<string>|true,disable_exclude?:table<string>,extend?:table<string,vim.lsp.Config>,override?:table<string,vim.lsp.Config>}
---See [%s]
return {}]]):format(vim.fs.joinpath(GVars.lazy_plugin_path("nvim-lspconfig"), "lsp"))
M.mason_ensure_install = compact {
    notArch("aarch64", "clangd"),
    notArch("aarch64", "lua_ls"),
    notArch("aarch64", "rust_analyzer"),
    "bashls",
    "jdtls",
    "cmake",
    "pyright",
}
M.auto_enable = compact {
    "clangd",
    "lua_ls",
    -- "rust_analyzer", --rustaceanvim
    "bashls",
    -- "jdtls", --nvim_jdtls
    "cmake",
    "pyright",
}
---@type table<string,vim.lsp.Config>
M.extend = {}
---@type table<string,vim.lsp.Config>
M.override = {}
---@type lsp_config
M.ulsp_config = nil
return M
