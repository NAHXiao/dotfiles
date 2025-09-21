--[[ vars.lua ]]
local uv = vim.uv
-- 256 色
vim.g.t_co = 256
---@type fun()[]
vim.g.cleanui_funcs = {
    function()
        vim.cmd.doautocmd("CursorMoved")
        vim.cmd.doautocmd("CursorMovedI")
        vim.cmd.noh()
        vim.snippet.stop()
    end,
}
vim.g.cleanui = function()
    for _, f in ipairs(vim.g.cleanui_funcs) do
        vim.notify(tostring(_))
        f()
    end
    vim.cmd("redraw!")
    vim.cmd("nohlsearch")
end
vim.env.PATH = vim.env.PATH
    .. (jit.os ~= "Windows" and ":" or ";")
    .. (vim.fs.joinpath(vim.fn.stdpath("config"), "bin"))

-- obsidian
do
    local obsidianpath
    if jit.os == "Windows" then
        obsidianpath = "E:/Obsidian/main"
    elseif jit.os == "Linux" then
        obsidianpath = os.getenv("HOME") .. "/.local/Obsidian/main"
    else
        obsidianpath = nil
    end
    if obsidianpath ~= nil and uv.fs_stat(obsidianpath) then
        vim.g.obsidianPath = obsidianpath
    end
end
