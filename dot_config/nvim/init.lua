--[[ init.lua ]]
-- LEADER
vim.g.mapleader = " "
vim.o.timeoutlen = 800
vim.cmd([[clearjumps]])
vim.api.nvim_set_hl(0, "TRANSPARENT", { bg = "NONE" })
-- IMPORTS
require("vars")
require("utils")
require("opts")
require("keys")
require("autocmds")
require("lazyinit")
