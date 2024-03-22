--[[ init.lua ]]
-- LEADER
vim.g.mapleader = " "
vim.g.localleader = " "
vim.o.timeoutlen = 800

-- Highlight colors
vim.cmd([[
hi CursorLineNr guifg=#7e9cd8
" hi FoldColumn guifg=#4a4f54 guibg=#26292c
hi GitSignsAdd guibg=#193549 guifg=#3ad900
hi GitSignsChange guibg=#193549 guifg=#ffc600
hi GitSignsDelete guibg=#193549 guifg=#ff2600
hi ColorColumn guifg=NONE guibg=#204563 gui=NONE
"报错背景透明
hi Pmenu ctermfg=15 ctermbg=9 guifg=Red guibg=NONE
]])
--禁用保存后的提示
vim.cmd("autocmd BufWritePost * silent! !clear")
----------------------------------------
--        为透明文档添加边框       -----
----------------------------------------
local border = {
    { "🭽", "FloatBorder" },
    { "▔", "FloatBorder" },
    { "🭾", "FloatBorder" },
    { "▕", "FloatBorder" },
    { "🭿", "FloatBorder" },
    { "▁", "FloatBorder" },
    { "🭼", "FloatBorder" },
    { "▏", "FloatBorder" },
}
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.buf.hover({
    border = border,
})
-- IMPORTS
require('func')
require("vars")      -- Variables
require("opts")      -- Options
require("keys")      -- Keymaps
require("lazyinit")

