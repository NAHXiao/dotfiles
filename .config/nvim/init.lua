--[[ init.lua ]]
-- LEADER
vim.g.mapleader = " "
vim.g.localleader = " "
vim.o.timeoutlen = 800
-- IMPORTS
require("utils")
require("vars")
require("opts")
require("keys")
require("ect")
require("lazyinit")
