local map = require("utils").map
-- [[ keys.lua ]]
-- map('n','<C-c>','<Esc>')
-- map('v','<C-c>','<Esc>')
-- map('c','<C-c>','<Esc>')
map("i", "<C-c>", "<Esc>", { remap = true })

-- format encoding? (\r\n -> \n)
map("n", "<leader>fe", ":%s#\\r##g<CR>", { silent = true })
-- 翻页
map({ "n", "i" }, "<C-f>", "<PageDown>")
map({ "n", "i" }, "<C-b>", "<PageUp>")

map("n", "<leader>P", "ggVGp")
map("v", "p", function()
    vim.cmd("normal! P")
end, { remap = true })
map("v", "P", function()
    vim.cmd("normal! p")
end, { remap = true })
map("v", "<C-S-V>", "p")
map("v", "<C-S-C>", "y")
map({ "n", "v" }, "<C-S-V>", "p")
map({ "c", "i" }, "<C-S-V>", '<C-R>"')
map("v", "<C-S-C>", "y")

-- vnew
map("n", "<C-w>N", ":vnew<CR>")
map("n", "<A-s>", ":new<CR>")
map("n", "<A-v>", ":vnew<CR>")
--normal窗口 A-hjkl
map("n", "<A-h>", "<C-w>h")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-l>", "<C-w>l")
-- 终端A-hjkl c-[
map("t", "<A-h>", "<C-\\><C-n><C-w>h")
map("t", "<A-j>", "<C-\\><C-n><C-w>j")
map("t", "<A-k>", "<C-\\><C-n><C-w>k")
map("t", "<A-l>", "<C-\\><C-n><C-w>l")
map("t", "<C-[>", "<C-\\><C-n>")
--禁用H
map("n", "H", "h")
--禁用F1
map({ "n", "i" }, "<F1>", "<Nop>")

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
-- Navigate Brother Files
local function switch_file(direction)
    local current = vim.api.nvim_buf_get_name(0)
    if current == "" then
        return
    end
    local dir = vim.fs.dirname(current)
    local current_name = vim.fs.basename(current)
    local files = {}
    for name, type in vim.fs.dir(dir) do
        if type == "file" then
            table.insert(files, name)
        end
    end
    if #files <= 1 then
        return
    end
    table.sort(files)
    local current_idx
    for i, name in ipairs(files) do
        if name == current_name then
            current_idx = i
            break
        end
    end
    if not current_idx then
        return
    end
    local next_idx
    if direction > 0 then
        next_idx = current_idx == #files and 1 or current_idx + 1
    else
        next_idx = current_idx == 1 and #files or current_idx - 1
    end
    local next_file = vim.fs.joinpath(dir, files[next_idx])
    if next_file ~= current then
        vim.cmd.edit(next_file)
    end
end
map("n", "[f", function()
    switch_file(-1)
end)
map("n", "]f", function()
    switch_file(1)
end)
-- Fix common typos
vim.cmd([[
    cnoreabbrev W! w!
    cnoreabbrev W1 w!
    cnoreabbrev w1 w!
    cnoreabbrev Q! q!
    cnoreabbrev Q1 q!
    cnoreabbrev q1 q!
    
    cnoreabbrev qa1 qa!
    cnoreabbrev Qa qa
    cnoreabbrev Qa! qa!
    cnoreabbrev Qall qall
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
