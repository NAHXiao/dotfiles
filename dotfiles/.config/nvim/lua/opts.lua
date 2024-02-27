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
-- vim.cmd([[
-- augroup FileTypeIndent
--   autocmd!
--   autocmd FileType make setlocal noexpandtab | setlocal tabstop=4 | setlocal shiftwidth=4
-- augroup END
-- ]])
-- [[ Splits ]]
opt.splitright = true -- bool: Place new window to right of current one
opt.splitbelow = true -- bool: Place new window below the current one
-- [[ ]]
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
--@netrw内置文件浏览器
--opt.cp = false
--vim.cmd("filetype plugin on")
--opt.grepprg = 'rg --vimgrep --smart-case --follow'
--Coc
opt.signcolumn = "yes"
opt.updatetime = 100
vim.opt.shortmess:append('c')

-- Spell check:
vim.cmd([[
set spelllang=en_us
]])


-- Format on Save 自动格式化
-- vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

-- Vimspector
vim.cmd([[
let g:vimspector_sidebar_width = 45
let g:vimspector_bottombar_height = 15
let g:vimspector_terminal_maxwidth = 70
let g:vimspector_terminal_mixwidth = 50
let g:vimspector_code_mixwidth =50
]])




-- TODO LSP Diagnostics Options Setup
local sign = function(opts)
    vim.fn.sign_define(opts.name, {
        texthl = opts.name,
        text = opts.text,
        numhl = ''
    })
end
sign({ name = 'DiagnosticSignError', text = '' })
sign({ name = 'DiagnosticSignWarn', text = '' })
sign({ name = 'DiagnosticSignHint', text = '' })
sign({ name = 'DiagnosticSignInfo', text = '' })

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = true,
    underline = false,
    severity_sort = true,
    float = {
        border = 'single',
        source = 'always',
        header = '',
        prefix = '- ',
    },
})
-- Fixed column for diagnostics to appear
-- Show autodiagnostic popup on cursor hover_range
-- Goto previous / next diagnostic warning / error
-- Show inlay_hints more frequently
vim.o.updatetime = 350
vim.o.signcolumn = 'yes'
vim.cmd([[
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
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
--vim.cmd("colorscheme kanagawa")
--
--
-- vim.api.nvim_set_option('viminfo', "%,'1000,<5000,s100,h,n~/.cache/.viminfo")
-- vim.cmd([[set nocompatible]])
-- vim.api.nvim_set_option('viminfo', "%,<800,'10,/50,:100,h,f0,n~/.vim/cache/.viminfo")


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
