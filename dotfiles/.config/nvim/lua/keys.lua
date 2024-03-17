-- [[ keys.lua ]]
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- format encoding? (\r\n -> \n)
map('n','<leader>fe',':%s#\\r##g<CR>',{ silent = true })
--重启lsp
map('n', '<leader>rl', ':LspRestart<CR>')
map('n', '<leader>sl', ':LspStop<CR>')
-- 翻页
map('n', '<C-f>', '<PageDown>')
map('n', '<C-b>', '<PageUp>')
map('n', '<leader>P', "ggVGp")
--@模板
vim.cmd([[
nnoremap <silent> L :call LoadTemplate()<CR>
function! LoadTemplate()
let userInput = input("请输入要插入的模板: ")
execute "r " "$HOME/template/". userInput
endfunction
]])

vim.cmd([[
"禁用F1
noremap <F1> <Nop>
inoremap <F1> <Nop>
"禁用H
noremap <silent> H h
tnoremap <C-w><C-h> <C-\><C-n><C-w><C-h><CR>
tnoremap <C-w><C-j> <C-\><C-n><C-w><C-j><CR>
tnoremap <C-w><C-k> <C-\><C-n><C-w><C-k><CR>
tnoremap <C-w><C-l> <C-\><C-n><C-w><C-l><CR>

noremap <A-h> <C-[><C-w><C-h><CR>
noremap <A-j> <C-[><C-w><C-j><CR>
noremap <A-k> <C-[><C-w><C-k><CR>
noremap <A-l> <C-[><C-w><C-l><CR>
"切换系统剪贴板
noremap <A-y> :ToggleClipboard<CR>

tnoremap <A-h> <C-\><C-n><C-w><C-h><CR>
tnoremap <A-j> <C-\><C-n><C-w><C-j><CR>
tnoremap <A-k> <C-\><C-n><C-w><C-k><CR>
tnoremap <A-l> <C-\><C-n><C-w><C-l><CR>
]])
map('i', "<C-,>", "<C-[>I")
map('i', "<C-.>", "<C-[>A")
map('i', "<C-h>", "<C-[>I")
map('i', "<C-l>", "<C-[>A")
map('t', "<leader><c-[>", "<C-\\><C-n>")


vim.api.nvim_command([[
  function! GotoNextEnd()
    let lnum = line('.')
    let nlines = line('$')
    if lnum == nlines
      call append(lnum, '')
    endif
      call cursor(lnum + 1, col([lnum + 1, '$']))
  endfunction
]])
vim.api.nvim_command([[
  function! GotoNextBegin()
    let lnum = line('.')
    let nlines = line('$')
    if lnum == nlines
      call append(lnum, '')
    endif
      call cursor(lnum + 1, col([lnum + 1, 1]))
  endfunction
]])
map('i', '<C-CR>', [[<Esc>:call GotoNextBegin()<CR>i]], { noremap = true, silent = true })
map('i', '<S-CR>', [[<Esc>:call GotoNextEnd()<CR>a]], { noremap = true, silent = true })
--ctrl s保存
map('i', "<C-s>", "<C-[>:wa<CR>")
map('n', "<C-s>", "<C-[>:wa<CR>")
-- Toggle colored column at 81
-- map('n', '<leader>|', ':execute "set colorcolumn=" . (&colorcolumn == "" ? "81" : "")<CR>')

-- Navigate buffers
map('n', '<leader>bp', ':bprevious<CR>', {})
map('n', '<leader>bn', ':bnext<CR>', {})
map('n', '<leader>bf', ':bfirst<CR>', {})
map('n', '<leader>bl', ':blast<CR>', {})
map('n', '<leader>bd', ':bdelete<CR>', {})
-- Fix common typos
vim.cmd([[
    cnoreabbrev W! w!
    cnoreabbrev W1 w!
    cnoreabbrev w1 w!
    cnoreabbrev Q! q!
    cnoreabbrev Q1 q!
    cnoreabbrev q1 q!
    cnoreabbrev Qa! qa!
    cnoreabbrev Qall! qall!
    cnoreabbrev Wa wa
    cnoreabbrev Wq wq
    cnoreabbrev wQ wq
    cnoreabbrev WQ wq
    cnoreabbrev wq1 wq!
    cnoreabbrev Wq1 wq!
    cnoreabbrev wQ1 wq!
    cnoreabbrev WQ1 wq!
    cnoreabbrev W w
    cnoreabbrev Q q
    cnoreabbrev Qa qa
    cnoreabbrev Qall qall
    cnoreabbrev WQA wqa
    cnoreabbrev WQa wqa
    cnoreabbrev WqA wqa
    cnoreabbrev Wqa wqa
    cnoreabbrev wQA wqa
    cnoreabbrev wQa wqa
    cnoreabbrev wqA wqa
]])
--vim.cmd([[
--" " Copy to clipboard
--vnoremap  <leader>y  "+y
--nnoremap  <leader>Y  "+yg_
--nnoremap  <leader>y  "+y
--nnoremap  <leader>yy  "+yy
--" " Paste from clipboard
--nnoremap <leader>p "+p
--nnoremap <leader>P "+P
--vnoremap <leader>p "+p
--vnoremap <leader>P "+P
--]])
