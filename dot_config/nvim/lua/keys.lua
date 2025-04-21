-- [[ keys.lua ]]
local function map(mode, lhs, rhs, opts)
    local options = { silent = true, noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end
-- vim.keymap.set

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
map("n", "<A-q>", function()
    if vim.bo.buftype ~= "" then
        return
    end
    local wins = vim.api.nvim_tabpage_list_wins(0)
    local file_win_count = 0
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
        if buftype == "" then
            file_win_count = file_win_count + 1
        end
    end
    if file_win_count > 1 then
        vim.cmd("close")
    end
end)
-- 终端A-hjkl c-[
map("t", "<A-h>", "<C-\\><C-n><C-w>h")
map("t", "<A-j>", "<C-\\><C-n><C-w>j")
map("t", "<A-k>", "<C-\\><C-n><C-w>k")
map("t", "<A-l>", "<C-\\><C-n><C-w>l")
map("t", "<C-[>", "<C-\\><C-n>")
--禁用H
map("n", "H", "h")
--禁用F1
map("n", "<F1>", "<Nop>")
map("i", "<F1>", "<Nop>")

map("i", "<C-h>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_get_current_line()
    local first_non_blank = line:find("%S") or 1
    vim.api.nvim_win_set_cursor(0, { row, first_non_blank - 1 })
end)
-- map('i', "<C-h>", "<home>")
map("i", "<C-l>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_get_current_line()
    local line_length = #line
    vim.api.nvim_win_set_cursor(0, { row, line_length })
end)
-- map('i', "<C-l>", "<end>")

local function jump_next_line(where)
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local total_lines = vim.api.nvim_buf_line_count(0)
    if row == total_lines then
        vim.api.nvim_buf_set_lines(0, row, row, true, { "" })
    end
    if where == "start" then
        vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
    elseif where == "end" then
        local next_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
        vim.api.nvim_win_set_cursor(0, { row + 1, #next_line })
    else
        vim.notify(
            "Invalid argument to jump_next_line (expected 'start' or 'end')",
            vim.log.levels.ERROR
        )
    end
end
map("i", "<C-CR>", function()
    jump_next_line("start")
end, { noremap = true, silent = true })
map("i", "<S-CR>", function()
    jump_next_line("end")
end, { noremap = true, silent = true })
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
