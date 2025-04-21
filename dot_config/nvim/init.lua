--[[ init.lua ]]
-- LEADER
vim.g.mapleader = " "
vim.g.localleader = " "
vim.o.timeoutlen = 800
-- IMPORTS
require("vars")
require("utils")
require("opts")
require("keys")
require("etc")
require("lazyinit")
