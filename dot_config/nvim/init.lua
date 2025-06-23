--[[ init.lua ]]
-- LEADER
vim.g.mapleader = " "
vim.g.localleader = " "
vim.o.timeoutlen = 800
vim.cmd([[
set mousemodel=popup
aunmenu PopUp.How-to\ disable\ mouse
aunmenu PopUp.-2-
]])
vim.api.nvim_set_hl(0, "TRANSPARENT", { bg = "NONE" })
-- IMPORTS
require("vars")
require("utils")
require("opts")
require("keys")
require("etc")
require("lazyinit")
