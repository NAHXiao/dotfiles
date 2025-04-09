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
g.ProjectRoot = Findfile_any({
    filelist = g.ProjectRootTag,
    startpath = g.ProjectRoot,
    use_first_found = false,
    return_dirname = true
}) or g.ProjectRoot

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
vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost" }, {
    callback = function()
        -- vim.notify("start setting projroot")
        local buftype = vim.bo.buftype
        local name = vim.api.nvim_buf_get_name(0)
        if buftype == "" and name ~= "" then
            vim.b.projroot = Findfile_any({
                filelist = vim.g.ProjectRootTag,
                startpath = vim.fn.fnamemodify(name, ":p:h"),
                use_first_found = false,
                return_dirname = true
            }) or vim.fn.fnamemodify(name, ":p:h")
            -- For asyncrun
            vim.b.asyncrun_root = vim.b.projroot
            -- vim.notify("setting " .. name .. ".projroot to" .. vim.b.projroot)
        end
    end,
})
