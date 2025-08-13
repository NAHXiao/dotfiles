--[[ vars.lua ]]
local g = vim.g
local uv = vim.uv
-- 256 色
g.t_co = 256
g.background = "dark"
--自定义变量
local osname = uv.os_uname().sysname
CC.is_win = false

CC.is_nix = false

CC.is_mac = false

CC.is_wsl = false
CC.is_android = false
if osname == "Linux" or osname == "Darwin" then
    if osname == "Linux" then
        if os.getenv("WSL_DISTRO_NAME") then
            CC.is_wsl = true
        elseif os.getenv("ANDROID_ROOT") then
            CC.is_android = true
        end
    elseif osname == "Darwin" then
        CC.is_mac = true
    end
    CC.is_nix = true
elseif osname == "Windows_NT" then
    CC.is_win = true
end

vim.env.PATH = vim.env.PATH
    .. (CC.is_nix and ":" or ";")
    .. (vim.fs.joinpath(vim.fn.stdpath("config"), "bin"))

-- obsidian
do
    local obsidianpath
    if osname == "Windows_NT" then
        obsidianpath = "E:/Obsidian/main"
    elseif osname == "Linux" then
        if CC.is_wsl then
            obsidianpath = "/mnt/e/Obsidian/main"
        else
            obsidianpath = os.getenv("HOME") .. "/.local/Obsidian/main"
        end
    else
        obsidianpath = nil
    end
    if obsidianpath ~= nil and uv.fs_stat(obsidianpath) then
        CC.obsidianPath = obsidianpath
    end
end
