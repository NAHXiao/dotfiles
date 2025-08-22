local opt = vim.opt
--  Context
opt.colorcolumn = "0"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 4
opt.signcolumn = "yes"

--  Filetypes
opt.encoding = "utf8"
vim.cmd([[set fileencodings=ucs-bom,utf-8,cp936]])
--  Theme
opt.syntax = "ON"
opt.termguicolors = true

--  Search
opt.ignorecase = true
opt.smartcase = true
-- opt.incsearch = true
-- opt.hlsearch = false

--  Whitespace
opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
--  Splits
opt.splitright = true
opt.splitbelow = true
opt.clipboard = "unnamedplus"
if vim.env.SSH_CLIENT ~= nil then
    vim.g.clipboard = {
        name = "osc52",
        copy = {
            ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
            ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
        },
        paste = {
            ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
            ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
        },
    }
end

--折叠
opt.hidden = true
opt.foldenable = false
--跨文件搜索
-- vim.cmd("set path+=$PWD/**")
opt.updatetime = 100
vim.opt.shortmess:append("c")
--CursorLineNr
opt.cursorline = true
opt.cursorlineopt = "number"
-- Spell check:
vim.cmd([[
set spelllang=en_us
]])
vim.opt.exrc = true --autoload $(cwd)/.nvim.lua
vim.o.sessionoptions =
    "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
--[[
set viminfo=%,<800,'10,/50,:100,h,f0,n~/.vim/cache/.viminfo
"           | |    |   |   |    | |  + viminfo file path
"           | |    |   |   |    | + file marks 0-9,A-Z 0=NOT stored
"           | |    |   |   |    + disable 'hlsearch' loading viminfo
"           | |    |   |   + command-line history saved
"           | |    |   + search history saved
"           | |    + files marks saved
"           | + lines saved each register (old name for <, vi6.2)
"           + save/restore buffer list
]]

-- vim.opt.conceallevel = 1 -- Hide *concealed* text

-- vim.o.winborder = "rounded"
