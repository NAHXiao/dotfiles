-- [[ keys.lua ]]
local function map(mode, lhs, rhs, opts)
    local options = { silent = true, noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map("i", "<C-c>", "<Esc>")
-- map('n','<C-c>','<Esc>')
-- map('v','<C-c>','<Esc>')
-- map('c','<C-c>','<Esc>')

-- format encoding? (\r\n -> \n)
map("n", "<leader>fe", ":%s#\\r##g<CR>", { silent = true })
-- 翻页
map("n", "<C-f>", "<PageDown>")
map("n", "<C-b>", "<PageUp>")
map("i", "<C-f>", "<PageDown>")
map("i", "<C-b>", "<PageUp>")

map("n", "<leader>P", "ggVGp")

-- vnew
map("n", "<C-w>N", ":vnew<CR>")
map("n", "<A-n>", ":new<CR>")
map("n", "<A-N>", ":vnew<CR>")
--normal窗口 A-hjkl
map("n", "<A-h>", "<C-w>h")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-l>", "<C-w>l")
-- 终端A-hjkl
map("t", "<A-h>", "<C-\\><C-n><C-w>h")
map("t", "<A-j>", "<C-\\><C-n><C-w>j")
map("t", "<A-k>", "<C-\\><C-n><C-w>k")
map("t", "<A-l>", "<C-\\><C-n><C-w>l")
map("t", "<A-q>", "<C-\\><C-n>")
-- map('t', 'jk', '<C-\\><C-n>')
--系统剪贴板切换
map("n", "<A-y>", ":ToggleClipboard<CR>")
--禁用H
map("n", "H", "h")
--禁用F1
map("n", "<F1>", "<Nop>")
map("i", "<F1>", "<Nop>")

map("i", "<C-,>", "<C-[>I")
map("i", "<C-.>", "<C-[>A")
map("i", "<C-h>", "<C-[>I")
map("i", "<C-l>", "<C-[>A")
-- map('i', "<C-h>", "<home>")
-- map('i', "<C-l>", "<end>")
map("t", "<leader><c-[>", "<C-\\><C-n>")

vim.api.nvim_command([[
  function! GotoNextEnd()
    let lnum = line('.')
    let nlines = line('$')
    if lnum == nlines
      call append(lnum, '')
    endif
      call cursor(lnum + 1, col([lnum + 1, '$']))
  endfunction
  function! GotoNextBegin()
    let lnum = line('.')
    let nlines = line('$')
    if lnum == nlines
      call append(lnum, '')
    endif
      call cursor(lnum + 1, col([lnum + 1, 1]))
  endfunction
]])
map("i", "<C-CR>", [[<Esc>:call GotoNextBegin()<CR>i]], { noremap = true, silent = true })
map("i", "<S-CR>", [[<Esc>:call GotoNextEnd()<CR>a]], { noremap = true, silent = true })
--ctrl s保存
map("i", "<C-s>", "<C-[>:wa<CR>")
map("n", "<C-s>", "<C-[>:wa<CR>")
-- Toggle colored column at 81
-- map('n', '<leader>|', ':execute "set colorcolumn=" . (&colorcolumn == "" ? "81" : "")<CR>')

-- Navigate buffers
map("n", "<leader>bp", ":bprevious<CR>", {})
map("n", "<leader>bn", ":bnext<CR>", {})
map("n", "<leader>bf", ":bfirst<CR>", {})
map("n", "<leader>bl", ":blast<CR>", {})
map("n", "<leader>bd", ":bdelete<CR>", {})
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
