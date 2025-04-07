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
g.ProjectRootTag = {
    -- 版本控制
    ".git", ".svn", ".hg", ".bzr", "_darcs", ".fslckout",
    -- 构建系统
    "Makefile", "CMakeLists.txt", "Cargo.toml", "pyproject.toml",
    "pom.xml", "build.gradle", "package.json", "go.mod",
    -- IDE/编辑器
    ".project", ".root", ".vscode", ".idea", ".projectile",
    -- 工具配置
    "compile_commands.json", ".clang-format", ".editorconfig",
    -- 其他
    ".repo", ".gitignore"
}
local function find_root(path)
    local current = path
    while true do
        for _, tag in ipairs(g.ProjectRootTag) do
            local target = current .. "/" .. tag
            if vim.fn.isdirectory(target) == 1 or vim.fn.filereadable(target) == 1 then
                return current
            end
        end
        local parent = vim.fn.fnamemodify(current, ":h")
        if parent == current then
            return nil
        end
        current = parent
    end
end
g.ProjectRoot = find_root(g.ProjectRoot) or g.ProjectRoot

do
    local obsidianpath;

    local osname = vim.loop.os_uname().sysname;
    if osname == 'Windows_NT' then
        obsidianpath = "E:/Obsidian/main";
    elseif osname == "Linux" then
        if g.is_wsl then
            obsidianpath = "/mnt/e/Obsidian/main";
        else
            obsidianpath = os.getenv("HOME") .. "/.local/Obsidian/main";
        end
    else
        obsidianpath = nil;
    end
    if obsidianpath ~= nil and vim.loop.fs_stat(obsidianpath) then
        g.obsidianPath = obsidianpath;
    end
end
