local map = require("utils").map
-- [[ keys.lua ]]

--文本操作
map(
    "n",
    "<leader>;<CR>",
    "<cmd>%s#\\r\\n#\\r#g<CR>",
    { silent = true, desc = "Replace \\r\\n with \\r" }
)
map(
    "n",
    "<leader>;u",
    [[<cmd>:%s/\\u\(\x\{4,6\}\)/\=nr2char(str2nr(submatch(1), 16))/g<cr>]],
    { silent = true, desc = "Decode unicode \\uxxxx / \\uxxxxxx" }
)
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

---NOTE: Flash+gi/go
---LIMIT: Single Char
map("v", "gi", function()
    if vim.fn.mode():byte() ~= 118 then
        return
    end
    local begin_row, begin_col, cur_row, cur_col
    local pos = vim.fn.getpos("v")
    begin_row, begin_col = pos[2], pos[3]
    pos = vim.fn.getpos(".")
    cur_row, cur_col = pos[2], pos[3]
    local pairs = {
        ["{"] = { "{", "", "}" },
        ["("] = { "(", "", ")" },
        ["["] = { "\\[", "", "\\]" },
        ["<"] = { "<", "", ">" },
        ["}"] = { "{", "", "}" },
        [")"] = { "(", "", ")" },
        ["]"] = { "\\[", "", "\\]" },
        [">"] = { "<", "", ">" },

        ["'"] = { "'", "", "'" },
        ['"'] = { '"', "", '"' },
        ["`"] = { "`", "", "`" },
    }
    local begin_in_front = true
    if vim.fn.line2byte(begin_row) + begin_col > vim.fn.line2byte(cur_row) + cur_col then
        begin_in_front = false
    end
    local recover = function() end
    if not begin_in_front then
        vim.api.nvim_feedkeys("o", "x", false) --reverse
        recover = function()
            vim.api.nvim_feedkeys("o", "x", false) --reverse
        end
        begin_row, begin_col, cur_row, cur_col = cur_row, cur_col, begin_row, begin_col
    end
    -----
    --stylua: ignore
    local cur_char = (vim.api.nvim_buf_get_lines(0, cur_row - 1, cur_row, true)[1]):sub( cur_col, cur_col)
    local p = pairs[cur_char]
    if not p then
        recover()
        return --if reverse reverse
    end
    local begin_row_, begin_col_ = unpack(vim.fn.searchpairpos(p[1], p[2], p[3], "bnW"))
    if
        (begin_row_ == 0 and begin_col_ == 0)
        or begin_row ~= begin_row_
        or begin_col ~= begin_col_
    then
        recover()
        return --if reverse reverse
    end
    if begin_col == vim.fn.col { begin_row, "$" } - 1 then
        begin_row, begin_col = begin_row + 1, 1
    else
        begin_col = begin_col + 1
    end
    if
        cur_col == 1
        or vim.api.nvim_get_current_line():sub(1, cur_col - 1):match("^%s*$") ~= nil
    then
        cur_row = cur_row - 1
        cur_col = vim.fn.col { cur_row, "$" } - 1
    else
        cur_col = cur_col - 1
    end
    if vim.fn.line2byte(begin_row) + begin_col > vim.fn.line2byte(cur_row) + cur_col then
        recover()
        return -- if reverse reverse
    end
    vim.api.nvim_win_set_cursor(0, { cur_row, cur_col - 1 })
    vim.api.nvim_feedkeys("o", "x", false)
    vim.api.nvim_win_set_cursor(0, { begin_row, begin_col - 1 })
    vim.api.nvim_feedkeys("o", "x", false)
    -----
    recover()
end, { desc = "select inner for {}/[]/()/``/<>/''/\"\"" })
map("v", "go", function()
    if vim.fn.mode():byte() ~= 118 then
        return
    end
    local begin_row, begin_col, cur_row, cur_col
    local pos = vim.fn.getpos("v")
    begin_row, begin_col = pos[2], pos[3]
    pos = vim.fn.getpos(".")
    cur_row, cur_col = pos[2], pos[3]
    local pairs = {
        ["}"] = { "{", "", "}" },
        [")"] = { "(", "", ")" },
        ["]"] = { "\\[", "", "\\]" },
        [">"] = { "<", "", ">" },

        ["'"] = { "'", "", "'" },
        ['"'] = { '"', "", '"' },
        ["`"] = { "`", "", "`" },
    }
    local begin_in_front = true
    if vim.fn.line2byte(begin_row) + begin_col > vim.fn.line2byte(cur_row) + cur_col then
        begin_in_front = false
    end
    local recover = function() end
    if not begin_in_front then
        vim.api.nvim_feedkeys("o", "x", false)
        recover = function()
            vim.api.nvim_feedkeys("o", "x", false)
        end
        begin_row, begin_col, cur_row, cur_col = cur_row, cur_col, begin_row, begin_col
    end
    -----
    local nextchar_row, nextchar_col = unpack(vim.fn.searchpos("\\S", "n"))
    if nextchar_row == 0 or nextchar_col == 0 then
        recover()
        return
    end
    local nextchar = (vim.api.nvim_buf_get_lines(0, nextchar_row - 1, nextchar_row, true)[1]):sub(
        nextchar_col,
        nextchar_col
    )
    local p = pairs[nextchar]
    if not p then
        recover()
        return
    end
    vim.api.nvim_win_set_cursor(0, { nextchar_row, nextchar_col - 1 })
    local nextchar_pair_row, nextchar_pair_col =
        unpack(vim.fn.searchpairpos(p[1], p[2], p[3], "bnW"))
    vim.api.nvim_feedkeys("o", "x", false)
    local prevchar_row, prevchar_col = unpack(vim.fn.searchpos("\\S", "nb"))
    if
        prevchar_row == 0
        or prevchar_col == 0
        or (prevchar_row ~= nextchar_pair_row or prevchar_col ~= nextchar_pair_col)
    then
        vim.api.nvim_feedkeys("o", "x", false)
        vim.api.nvim_win_set_cursor(0, { cur_row, cur_col - 1 })
        recover()
        return
    end
    vim.api.nvim_win_set_cursor(0, { nextchar_pair_row, nextchar_pair_col - 1 })
    vim.api.nvim_feedkeys("o", "x", false)
    -----
    recover()
end, { desc = "select outer for {}/[]/()/``/<>/''/\"\"" })
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
--Nop
-- map("i", "<C-i>", "<Nop>") --C-i和Tab的键码是同一个.?
map("*", "<F1>", "<Nop>")
map("v", "K", "<Nop>")

map("i", "<C-h>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_get_current_line()
    local first_non_blank = line:find("%S") or 1
    vim.api.nvim_win_set_cursor(0, { row, first_non_blank - 1 })
end, { desc = "<HOME>" })

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

map("i", "<C-l>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_get_current_line()
    local line_length = #line
    vim.api.nvim_win_set_cursor(0, { row, line_length })
end, { desc = "<END>" })
map({ "i", "s" }, "<C-j>", function()
    if vim.snippet.active { direction = 1 } then
        vim.snippet.jump(1)
    end
end, { desc = "snippet next" })
map({ "i", "s" }, "<C-k>", function()
    if vim.snippet.active { direction = -1 } then
        vim.snippet.jump(-1)
    end
end, { desc = "snippet prev" })
map({ "i", "s" }, "<esc>", "<cmd>lua vim.snippet.stop()<cr><esc>", { silent = true })
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
        if
            type == "file"
            or (type == "link" and vim.uv.fs_stat(vim.fs.joinpath(dir, name)).type == "file")
        then
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
map("n", "<C-l>", function()
    vim.g.cleanui()
end)
map(
    "n",
    "<leader>qq",
    ":if empty(filter(getwininfo(), 'v:val.quickfix')) | botright copen | else | cclose | endif<CR>",
    { desc = "QuickFix: toggle", silent = true }
)
vim.keymap.set(
    "n",
    "<leader>ql",
    ":if empty(filter(getwininfo(), 'v:val.loclist')) | botright lopen | else | lclose | endif<CR>",
    { desc = "LocList: toggle", silent = true }
)

vim.keymap.del("o", "gc")
vim.keymap.del("x", "gc")
vim.keymap.del("n", "gcc")
-- Fix common typos
vim.cmd([[
cnoreabbrev W w

cnoreabbrev W! w!
cnoreabbrev w1 w!
cnoreabbrev W1 w!

cnoreabbrev Q q

cnoreabbrev Q! q!
cnoreabbrev q1 q!
cnoreabbrev Q1 q!

cnoreabbrev WQ wq
cnoreabbrev Wq wq
cnoreabbrev wQ wq

cnoreabbrev WQ! wq!
cnoreabbrev Wq! wq!
cnoreabbrev wQ! wq!
cnoreabbrev WQ1 wq!
cnoreabbrev Wq1 wq!
cnoreabbrev wQ1 wq!
cnoreabbrev wq1 wq!

cnoreabbrev WA wa
cnoreabbrev Wa wa
cnoreabbrev wA wa

cnoreabbrev WA! wa!
cnoreabbrev Wa! wa!
cnoreabbrev wA! wa!
cnoreabbrev WA1 wa!
cnoreabbrev Wa1 wa!
cnoreabbrev wA1 wa!
cnoreabbrev wa1 wa!

cnoreabbrev QA qa
cnoreabbrev Qa qa
cnoreabbrev qA qa

cnoreabbrev QA! qa!
cnoreabbrev Qa! qa!
cnoreabbrev qA! qa!
cnoreabbrev QA1 qa!
cnoreabbrev Qa1 qa!
cnoreabbrev qA1 qa!
cnoreabbrev qa1 qa!

cnoreabbrev WQA wqa
cnoreabbrev WQa wqa
cnoreabbrev WqA wqa
cnoreabbrev Wqa wqa
cnoreabbrev wQA wqa
cnoreabbrev wQa wqa
cnoreabbrev wqA wqa

cnoreabbrev WQA! wqa!
cnoreabbrev WQa! wqa!
cnoreabbrev WqA! wqa!
cnoreabbrev Wqa! wqa!
cnoreabbrev wQA! wqa!
cnoreabbrev wQa! wqa!
cnoreabbrev wqA! wqa!
cnoreabbrev WQA1 wqa!
cnoreabbrev WQa1 wqa!
cnoreabbrev WqA1 wqa!
cnoreabbrev Wqa1 wqa!
cnoreabbrev wQA1 wqa!
cnoreabbrev wQa1 wqa!
cnoreabbrev wqA1 wqa!
cnoreabbrev wqa1 wqa!

cnoreabbrev Lua lua
]])
vim.cmd([[
    cnoreabbrev b! botright split new \| r!
]])
