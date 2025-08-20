--[[ vars.lua ]]
local g = vim.g
local uv = vim.uv
-- 256 色
g.t_co = 256
g.background = "dark"
--自定义变量
Globals = {}
---@type fun()[]
Globals.cleanui_funcs = {
    function()
        vim.cmd.doautocmd("CursorMoved")
        vim.cmd.doautocmd("CursorMovedI")
        vim.cmd.noh()
        vim.snippet.stop()
    end
}
Globals.cleanui = function()
    for _, f in ipairs(Globals.cleanui_funcs) do
        f()
    end
    vim.cmd("redraw!")
    vim.cmd("nohlsearch")
end
local osname = uv.os_uname().sysname
Globals.is_win = false

Globals.is_nix = false

Globals.is_mac = false

Globals.is_wsl = false
Globals.is_android = false
if osname == "Linux" or osname == "Darwin" then
    if osname == "Linux" then
        if os.getenv("WSL_DISTRO_NAME") then
            Globals.is_wsl = true
        elseif os.getenv("ANDROID_ROOT") then
            Globals.is_android = true
        end
    elseif osname == "Darwin" then
        Globals.is_mac = true
    end
    Globals.is_nix = true
elseif osname == "Windows_NT" then
    Globals.is_win = true
end

vim.env.PATH = vim.env.PATH
    .. (Globals.is_nix and ":" or ";")
    .. (vim.fs.joinpath(vim.fn.stdpath("config"), "bin"))

-- obsidian
do
    local obsidianpath
    if osname == "Windows_NT" then
        obsidianpath = "E:/Obsidian/main"
    elseif osname == "Linux" then
        if Globals.is_wsl then
            obsidianpath = "/mnt/e/Obsidian/main"
        else
            obsidianpath = os.getenv("HOME") .. "/.local/Obsidian/main"
        end
    else
        obsidianpath = nil
    end
    if obsidianpath ~= nil and uv.fs_stat(obsidianpath) then
        Globals.obsidianPath = obsidianpath
    end
end
Globals.lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy/lazy.nvim")
---@param expand_home? boolean default not
function Globals.lazy_plugin_path(plugin_full_name, expand_home)
    local path = vim.fs.joinpath(vim.fs.dirname(Globals.lazypath), plugin_full_name)
    if not expand_home then
        path = require("utils").prefix_replace(path, vim.uv.os_homedir(), "~")
    end
    return path
end
Globals.mason_install_root_dir = vim.fs.joinpath(vim.fn.stdpath "data", "mason")
