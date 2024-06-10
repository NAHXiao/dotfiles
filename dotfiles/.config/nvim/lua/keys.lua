-- [[ keys.lua ]]
local function map(mode, lhs, rhs, opts)
    local options = { silent = true, noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- format encoding? (\r\n -> \n)
map('n', '<leader>fe', ':%s#\\r##g<CR>', { silent = true })
-- 翻页
map('n', '<C-f>', '<PageDown>')
map('n', '<C-b>', '<PageUp>')
map('i', '<C-f>', '<PageDown>')
map('i', '<C-b>', '<PageUp>')

map('n', '<leader>P', "ggVGp")

--normal窗口 A-hjkl
map('n', '<A-h>', '<C-w>h')
map('n', '<A-j>', '<C-w>j')
map('n', '<A-k>', '<C-w>k')
map('n', '<A-l>', '<C-w>l')
-- 终端A-hjkl
map('t', '<A-h>', '<C-\\><C-n><C-w>h')
map('t', '<A-j>', '<C-\\><C-n><C-w>j')
map('t', '<A-k>', '<C-\\><C-n><C-w>k')
map('t', '<A-l>', '<C-\\><C-n><C-w>l')
map('t', '<A-q>', '<C-\\><C-n>')
map('t', 'jk', '<C-\\><C-n>')
--系统剪贴板切换
map('n', '<A-y>', ':ToggleClipboard<CR>')
--禁用H
map('n', 'H', 'h')
--禁用F1
map('n', '<F1>', '<Nop>')
map('i', '<F1>', '<Nop>')

map('i', "<C-,>", "<C-[>I")
map('i', "<C-.>", "<C-[>A")
map('i', "<C-h>", "<C-[>I")
map('i', "<C-l>", "<C-[>A")
-- map('i', "<C-h>", "<home>")
-- map('i', "<C-l>", "<end>")
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

if vim.g.is_wsl or vim.g.is_win then
    local function execute_cmd(cmd)
        local handle = io.popen(cmd)
        if handle == nil then return end
        local result = handle:read("*a")
        handle:close()
        return result
    end
    local function is_job_done(job_id)
        local status = vim.fn.jobwait({ job_id }, 0) -- 0 表示立即返回，不等待
        return status[1] == -1
    end
    local imeselect = vim.fn.stdpath('config') .. '/bin/im-select.exe'
    local InsertLeavePre_JobId = nil
    local InsertEnter_JobId = nil
    Async_run(execute_cmd(imeselect .. ' 1033'), nil)
    vim.api.nvim_create_augroup('IME', { clear = true })
    vim.api.nvim_create_autocmd('InsertLeavePre', {
        group = 'IME',
        pattern = '*',
        callback = function()
            if InsertEnter_JobId and not is_job_done(InsertEnter_JobId) then vim.fn.jobstop(InsertEnter_JobId) end
            InsertLeavePre_JobId = vim.fn.jobstart(imeselect .. ' ' .. '1033')
        end,
    })
    vim.api.nvim_create_autocmd('InsertEnter', {
        group = 'IME',
        pattern = '*',
        callback = function()
            if InsertLeavePre_JobId and not is_job_done(InsertLeavePre_JobId) then vim.fn.jobstop(InsertLeavePre_JobId) end
            InsertEnter_JobId = vim.fn.jobstart(imeselect .. ' ' .. '2052')
        end,
    })

    vim.api.nvim_create_autocmd('VimLeavePre', {
        group = 'IME',
        pattern = '*',
        callback = function()
            if InsertEnter_JobId and not is_job_done(InsertEnter_JobId) then vim.fn.jobstop(InsertEnter_JobId) end
            if InsertLeavePre_JobId and not is_job_done(InsertLeavePre_JobId) then vim.fn.jobstop(InsertLeavePre_JobId) end
            Async_run(execute_cmd(imeselect .. ' 2052'), nil)
        end,
    })
end
