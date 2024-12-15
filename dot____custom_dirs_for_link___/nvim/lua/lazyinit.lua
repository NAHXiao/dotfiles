local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
-- Hook
local old_require = require
_G.require = setmetatable({}, {
    __call = function(_, modname)
        -- DebugToFile("require: " .. modname)
        local ret = old_require(modname)
        if modname == 'obsidian.util' then
            -- DebugToFile("Inject obsidian.util")
            ret.ANCHOR_LINK_PATTERN = "#[%w%d\u{4e00}-\u{9fff}][^#]*"
        elseif modname == 'obsidian' then
            -- DebugToFile("Inject obsidian")
            ret.util.ANCHOR_LINK_PATTERN = "#[%w%d\u{4e00}-\u{9fff}][^#]*"
        end
        return ret
    end
})
vim.opt.rtp:prepend(lazypath)
require("lazy").setup(
    {
        { import = "plugins.cmp" },
        { import = "plugins.edit" },
        { import = "plugins.filetype" },
        { import = "plugins.lib" },
        { import = "plugins.lsp" },
        { import = "plugins.tool" },
        { import = "plugins.ui" },
        { import = "plugins.telescope" },
        { import = "plugins.task" },
        { import = "plugins.dap" },
    },
    {
        checker = {
            enable = true,
            frequency = 240, -- 10days
        }
    }
)
