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
-- -- Hook
-- local old_require = require
-- _G.require = setmetatable({}, {
-- 	__call = function(_, modname)
-- 		local ret = old_require(modname)
-- 		if modname == "obsidian.util" then
-- 			ret.ANCHOR_LINK_PATTERN = "#[%w%d\u{4e00}-\u{9fff}][^#]*"
-- 		elseif modname == "obsidian" then
-- 			ret.util.ANCHOR_LINK_PATTERN = "#[%w%d\u{4e00}-\u{9fff}][^#]*"
-- 		end
-- 		return ret
-- 	end,
-- })
vim.opt.rtp:prepend(lazypath)
function Is_plugin_loaded(plugin_name)
    local plugin = require("lazy.core.config").plugins[plugin_name]
    return plugin and plugin._.loaded
end
require("lazy").setup({
    { import = "plugins.cmp" },
    { import = "plugins.edit" },
    { import = "plugins.filetype" },
    { import = "plugins.lsp" },
    { import = "plugins.tool" },
    { import = "plugins.ui" },
    { import = "plugins.telescope" },
    { import = "plugins.task" },
    { import = "plugins.dap" },
}, {
    checker = {
        enable = true,
        frequency = 240, -- 10days
    },
})
