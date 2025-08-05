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
local lazy = require("lazy")
---@param plugin_full_name string e.g. copilot.lua surround.vim
function lazy.is_loaded(plugin_full_name)
    local plugin = require("lazy.core.config").plugins[plugin_full_name]
    return plugin ~= nil and plugin._.loaded ~= nil
end
require("tools.hl").setup()
lazy.setup(
    (function(dir)
        local result = {}
        local uv = vim.loop or vim.uv
        local handle = uv.fs_scandir(dir)
        if not handle then
            vim.notify("directory doesn't exist: " .. dir, vim.log.levels.WARN)
            return result
        end
        while true do
            local name, type = uv.fs_scandir_next(handle)
            if not name then
                break
            end
            if type == "directory" then
                table.insert(result, { import = vim.fs.basename(dir) .. "." .. name })
            end
        end
        return result
    end)(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "plugins")),
    {
        checker = {
            enable = true,
            frequency = 240, -- 10days
        },
    }
)
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        require("tools.term").setup()
        require("tools.task").setup()
        -- require("tools.proj"):setup()
    end,
})
