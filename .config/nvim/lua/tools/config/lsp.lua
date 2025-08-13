local utils = require("utils")
local M = {}
local compact = require("utils").list_compact
---@diagnostic disable-next-line: undefined-field
local machine = vim.uv.os_uname().machine
local function ifarch(arch, val)
    return machine == arch and val or nil
end
local function ifnoarch(arch, val)
    return machine == arch and val or nil
end
M.ulsp_config_path = function() return vim.fs.joinpath(utils.get_rootdir(), ".vim", "lsp.lua") end
M.ulsp_config_tmpl =
[[
---vim will attempt to prevent vim.lsp.enable() for all LSPs that are in the disable list but not in disable_exclude.
---You need to restart vim to apply the changes.
---@type {disable?:table<string>|true,disable_exclude?:table<string>,extend?:table<string,vim.lsp.Config>,override?:table<string,vim.lsp.Config>}
return {}
]]
M.mason_ensure_install = compact {
    ifnoarch("aarch64", "clangd"),
    "lua_ls",
    "rust_analyzer",
    "bashls",
    "jdtls",
    "cmake",
    "pyright",
}
M.auto_enable = vim.list_extend(M.mason_ensure_install, {
    "clangd"
})

M.extend = {}
M.override = {}
---@type lsp_config
M.ulsp_config = nil
return M
