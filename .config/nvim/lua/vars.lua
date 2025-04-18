--[[ vars.lua ]]
local g = vim.g
local uv = vim.uv or vim.loop
-- 256 色
g.t_co = 256
g.background = "dark"
--自定义变量
local osname = uv.os_uname().sysname

g.is_win = false

g.is_nix = false

g.is_mac = false

g.is_wsl = false
g.is_android = false
if osname == "Linux" or osname == "Darwin" then
    if osname == "Linux" then
        if os.getenv("WSL_DISTRO_NAME") then
            g.is_wsl = true
        elseif os.getenv("ANDROID_ROOT") then
            g.is_android = true
        end
    elseif osname == "Darwin" then
        g.is_mac = true
    end
    g.is_nix = true
elseif osname == "Windows_NT" then
    g.is_win = true
end
