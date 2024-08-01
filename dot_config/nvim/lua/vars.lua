--[[ vars.lua ]]
local g = vim.g
-- 256 色
g.t_co = 256
g.background = "dark"
--自定义变量
local osname = vim.loop.os_uname().sysname;

g.is_win = false

g.is_nix = false

g.is_mac = false

g.is_wsl = false
g.is_android = false
if osname == 'Linux' or osname == 'Darwin' then
    if osname == 'Linux' then
        if os.getenv("WSL_DISTRO_NAME") then
            g.is_wsl = true
        elseif os.getenv("ANDROID_ROOT") then
            g.is_android = true
        end
    elseif osname == 'Darwin' then
        g.is_mac = true
    end
    g.is_nix = true
elseif osname == 'Windows_NT' then
    g.is_win = true
end
g.ProjectRoot = vim.fn.getcwd()
--递归向上寻找.git .svn .hg .project .root .vscode .idea
g.ProjectRootTag = { -- File or Dir
    ".git",
    ".svn",
    ".hg",
    ".project",
    ".root",
    ".vscode",
    ".idea"
}
local function find_root(path)
    local cwd = path
    for _, tag in ipairs(g.ProjectRootTag) do
        local path = cwd .. "/" .. tag
        if vim.fn.isdirectory(path) == 1 or vim.fn.filereadable(path) == 1 then
            return cwd
        end
    end
    local parent = vim.fn.fnamemodify(cwd, ":h")
    if parent == cwd then
        return nil
    end
    return find_root(parent)
end
g.ProjectRoot = find_root(g.ProjectRoot) or g.ProjectRoot
