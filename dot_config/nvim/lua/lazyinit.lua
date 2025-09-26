local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy/lazy.nvim")
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)
local lazy = require("lazy")
---NOTE:DIRTY
---@param plugin_full_name string e.g. copilot.lua surround.vim
function lazy.is_loaded(plugin_full_name)
    local plugin = require("lazy.core.config").plugins[plugin_full_name]
    return plugin ~= nil and plugin._.loaded ~= nil
end
---@param expand_home? boolean default not
function lazy.lazy_plugin_path(plugin_full_name, expand_home)
    local path = vim.fs.joinpath(vim.fs.dirname(lazypath), plugin_full_name)
    if not expand_home then
        path = require("utils").prefix_replace(path, vim.uv.os_homedir(), "~")
    end
    return path
end
require("tools.hl").setup()
require("tools.lsp").setup()
lazy.setup({
    { import = "plugins.cmp" },
    { import = "plugins.dap" },
    { import = "plugins.edit" },
    { import = "plugins.filetype" },
    { import = "plugins.lib" },
    { import = "plugins.lsp" },
    { import = "plugins.telescope" },
    { import = "plugins.tool" },
    { import = "plugins.ui" },
}, {
    checker = {
        enable = true,
        frequency = 240,
    },
    ui = {
        border = "rounded",
    },
    rocks = {
        enabled = false,
    },
})
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        require("tools.term").setup()
        require("tools.task").setup()
    end,
})
