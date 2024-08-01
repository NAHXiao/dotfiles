--[[ opts.lua ]]
local opt = vim.opt
-- [[ Context ]]
opt.colorcolumn = "0"     -- str:  Show col for max line length
opt.number = true         -- bool: Show line numbers
opt.relativenumber = true -- bool: Show relative line numbers
opt.scrolloff = 4         -- int:  Min num lines of context
opt.signcolumn = "yes"    -- str:  Show the sign column

-- [[ Filetypes ]]
opt.encoding = "utf8" -- str:  String encoding to use
-- opt.fileencoding = "utf8" -- str:  File encoding to use
vim.cmd([[set fileencodings=ucs-bom,utf-8,cp936]])
-- [[ Theme ]]
opt.syntax = "ON"        -- str:  Allow syntax highlighting 语法高亮
opt.termguicolors = true -- bool: If term supports ui color then enable 真彩色

-- [[ Search ]]
opt.ignorecase = true -- bool: Ignore case in search patterns
opt.smartcase = true  -- bool: Override ignorecase if search contains capitals
opt.incsearch = true  -- bool: Use incremental search
opt.hlsearch = false  -- bool: Highlight search matches

-- [[ Whitespace ]]
opt.expandtab = true -- bool: Use spaces instead of tabs
opt.shiftwidth = 4   -- num:  Size of an indent 自动缩进空格数
opt.softtabstop = 4  -- num:  Number of spaces tabs count for in insert mode
opt.tabstop = 4      -- num:  Number of spaces tabs count for
-- [[ Splits ]]
opt.splitright = true -- bool: Place new window to right of current one
opt.splitbelow = true -- bool: Place new window below the current one
opt.clipboard = 'unnamedplus'
-- vim.cmd([[
--     let g:clipboard = {
--                 \   'name': 'WslClipboard',
--                 \   'copy': {
--                 \      '+': 'clip.exe',
--                 \      '*': 'clip.exe',
--                 \    },
--                 \   'paste': {
--                 \      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
--                 \      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
--                 \   },
--                 \   'cache_enabled': 0,
--                 \ }
-- ]])
--折叠
opt.hidden = true
opt.foldenable = true
--[[跨文件搜索]]
vim.cmd("set path+=$PWD/**")
opt.updatetime = 100
vim.opt.shortmess:append('c')

-- Spell check:
vim.cmd([[
set spelllang=en_us
]])
-- 自动保存光标位置
vim.cmd([[
" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
]])
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
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

-- R语言shiftwidth=2
vim.cmd([[
augroup FileTypeIndent
  autocmd!
  autocmd FileType r setlocal shiftwidth=2 | setlocal tabstop=2
augroup END
]])
