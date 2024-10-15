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

"                          config for nvim-qt                          "
if exists('g:GuiLoaded')
  " call GuiWindowMaximized(1)
  GuiTabline 0
  GuiPopupmenu 0
  GuiLinespace 2
  GuiFont! Hack\ NF:h10:l
endif
]])

--禁用保存后的提示
vim.cmd("autocmd BufWritePost * silent! !clear")
-- IMPORTS
require('func')
require("vars") -- Variables
require("opts") -- Options
require("keys") -- Keymaps
require("lazyinit")

-- 退出buffer自动关闭quickfix...类窗口
vim.cmd([[
function! s:CloseIfOnlyControlWinLeft()
  if winnr("$") != 1
    return
  endif
  if (exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1)
        \ || &buftype == 'quickfix'
    q
  endif
endfunction
augroup CloseIfOnlyControlWinLeft
  au!
  au BufEnter * call s:CloseIfOnlyControlWinLeft()
augroup END
]])
