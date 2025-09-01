if vim.env.NVIM_XDG_ROOT then
    local root = vim.fn.fnamemodify(vim.env.NVIM_XDG_ROOT, ":p"):gsub("[\\/]$", "")
    for _, name in ipairs { "data", "state", "cache" } do
        vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
    end
end
--[[ init.lua ]]
-- LEADER
vim.g.mapleader = " "
vim.o.timeoutlen = 800
vim.cmd([[clearjumps]])
vim.api.nvim_set_hl(0, "TRANSPARENT", { bg = "NONE" })
vim.g.lazy_path = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy/lazy.nvim")
-- IMPORTS
require("vars")
require("utils")
require("opts")
require("keys")
require("autocmds")
require("lazyinit")
