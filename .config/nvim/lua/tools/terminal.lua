--
-- <M-`>: toggle
-- <M-;>: new a terminal
-- <M-q>: delete the current terminal
-- <M-n>: jump to the next terminal
-- <M-p>: jump to the previous terminal
-- <M-1> ... <M-9>: jump to terminal #i
-- <leader>rn: rename the current terminal
-- <M-,>: move the current terminal backwards
-- <M-.>: move the current terminal forwards
--

local M = {}

local term_icon = ""
local pinned_icon = "📌"
local state = {
    -- Current terminal
    cur_index = nil,

    term_win = nil,
    term_height = math.floor(vim.o.lines / 3),

    -- Side panel showing the list of terminals
    panel_buf = nil,
    panel_win = nil,
    panel_width = math.floor(vim.o.columns / 10),

    terminals = {}, --jobid,burnr,cmd,name

    unique_name = {}, --设置unique后,后来的同名job将顶替前面的
}

local minimal_win_opts = {
    number = false,
    relativenumber = false,
    foldcolumn = "0",
    signcolumn = "no",
    statuscolumn = "",
    spell = false,
    list = false,
}
---------------------------------------------------------------------
local function get_max_line_display_width(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local maxlen = 0
    for _, line in ipairs(lines) do
        local len = vim.fn.strdisplaywidth(line)
        if len > maxlen then
            maxlen = len
        end
    end
    return maxlen
end
local function set_buf_hl_line(bufnr, line, hl_group)
    vim.api.nvim_buf_clear_namespace(bufnr, 0, 0, -1)
    vim.api.nvim_buf_add_highlight(bufnr, 0, hl_group, line - 1, 0, -1)
end
local function line_unpack(line)
    local num, text = line:match("^%[(%d+)%]%s+" .. term_icon .. "%s+(.*)")
    return tonumber(num), tostring(text)
end
local function line_pack(id, text)
    return string.format("[%d] %s %s", id, term_icon, text or "Terminal")
end

local function close_win(winid)
    if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, true)
    end
end

local function delete_buf(bufnr)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
end
local function bind_buf_to_win(winid, bufnr)
    vim.wo[winid].winfixbuf = false
    vim.api.nvim_win_set_buf(winid, bufnr)
    vim.wo[winid].winfixbuf = true
end
-- Swap any two items in a list
local function list_swap(list, i, j)
    if i >= 1 and i <= #list and j >= 1 and j <= #list and i ~= j then
        list[i], list[j] = list[j], list[i]
    end
end

-- Swap any two lines in the side pane
local function panel_lines_swap(i, j)
    local i_line = vim.api.nvim_buf_get_lines(state.panel_buf, i - 1, i, false)[1]
    local j_line = vim.api.nvim_buf_get_lines(state.panel_buf, j - 1, j, false)[1]
    i_line = i_line:gsub("^%[(%d+)%]", "[" .. j .. "]")
    j_line = j_line:gsub("^%[(%d+)%]", "[" .. i .. "]")
    vim.api.nvim_buf_set_lines(state.panel_buf, i - 1, i, false, { j_line })
    vim.api.nvim_buf_set_lines(state.panel_buf, j - 1, j, false, { i_line })
end

local function get_index_by_jobid(jobid)
    for i, term in ipairs(state.terminals) do
        if term.jobid == jobid then
            return i
        end
    end
end
local function get_index_by_bufnr(bufnr)
    for i, term in ipairs(state.terminals) do
        if term.bufnr == bufnr then
            return i
        end
    end
end
local function is_opened()
    return state.term_win and vim.api.nvim_win_is_valid(state.term_win)
end
---------------------------------------------------------------------
-- Delete all buffers and windows, reset state
local function reset()
    close_win(state.term_win)
    close_win(state.panel_win)
    for _, term in ipairs(state.terminals) do
        delete_buf(term.bufnr)
    end
    delete_buf(state.panel_buf)
    state.term_win = nil
    state.cur_index = nil
    state.panel_win = nil
    state.panel_buf = nil
    state.terminals = {}
    state.unique_name = {}
end

---keep term_height and panel_width sync with displayed
local function set_autocmd()
    vim.api.nvim_create_augroup("tools.terminal", { clear = true })
    -- Remember its size if terminal window gets resized
    vim.api.nvim_create_autocmd("WinResized", {
        group = "tools.terminal",
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                if win == state.term_win then
                    state.term_height = vim.api.nvim_win_get_height(state.term_win)
                end
                if win == state.panel_win then
                    local panel_width = vim.api.nvim_win_get_width(state.panel_win)
                    local panel_max_width = get_max_line_display_width(state.panel_buf) + 3
                    if panel_width > panel_max_width then
                        vim.api.nvim_win_set_width(state.panel_win, panel_max_width)
                    end
                    state.panel_width = vim.api.nvim_win_get_width(state.panel_win)
                end
            end
        end,
    })
    -- Make the terminal window and the side panel can be closed together
    vim.api.nvim_create_autocmd("WinClosed", {
        group = "tools.terminal",
        pattern = table.concat({ state.term_win, state.panel_win }, ","),
        callback = function(args)
            local closed_win = tonumber(args.match)
            if closed_win == state.term_win then
                close_win(state.panel_win)
            elseif closed_win == state.panel_win then
                close_win(state.term_win)
            end
        end,
    })
end

local function setup_panelbuf(bufnr)
    vim.bo[bufnr].filetype = "TerminalPanel"
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "", {
        noremap = true,
        silent = true,
        callback = function()
            local lnum = vim.api.nvim_win_get_cursor(0)[1]
            local text = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
            M.switch(line_unpack(text))
            vim.cmd("stopinsert")
            vim.api.nvim_set_current_win(state.term_win)
        end,
    })
    --create autocmd: mode, i=>n
    vim.api.nvim_create_autocmd("ModeChanged", {
        buffer = bufnr,
        callback = function()
            local mode = vim.fn.mode()
            if mode == "i" then
                vim.cmd("stopinsert")
            end
        end,
    })
end

local function setup_termbuf(bufnr)
    vim.api.nvim_create_autocmd("BufEnter", {
        buffer = bufnr,
        callback = function()
            if vim.fn.jobwait({ state.terminals[get_index_by_bufnr(bufnr)].jobid }, 0)[1] == -1 then
                vim.cmd("startinsert")
            end
        end,
    })
    --TODO:
    -- vim.api.nvim_create_autocmd({ "BufUnload", "BufDelete", "BufWipeout" }, {
    --     callback = function(args)
    --          -- args.buf
    --     end,
    -- })

    local function map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
    end

    -- New terminal
    map({ "n", "t" }, "<M-;>", function()
        require("tools.terminal").new()
    end)

    -- Delete the current terminal
    map({ "n", "t" }, "<M-q>", function()
        require("tools.terminal").delete()
    end)

    -- Jump to the next or previous
    map({ "n", "t" }, "<M-p>", function()
        require("tools.terminal").jump(-1)
    end)
    map({ "n", "t" }, "<M-n>", function()
        require("tools.terminal").jump(1)
    end)

    -- Jump to terminal #i
    for i = 1, 10 do
        local lhs = "<M-" .. i .. ">"
        map({ "n", "t" }, lhs, function()
            require("tools.terminal").switch(i)
        end)
    end

    -- Rename
    map({ "n", "t" }, "<leader>rn", function()
        require("tools.terminal").rename()
    end)

    -- Move the current terminal backwards or forwards
    map({ "n", "t" }, "<M-,>", function()
        require("tools.terminal").move(-1)
    end)
    map({ "n", "t" }, "<M-.>", function()
        require("tools.terminal").move(1)
    end)
end

-- Set the window to minimal style
local function set_win_minimal(winid)
    for option, value in pairs(minimal_win_opts) do
        vim.wo[winid][option] = value
    end
end
----------------------------------------------------------------------

----@param index number|number[]
---@param index number
local function delete_term(index)
    local bufnr = state.terminals[index].bufnr
    local jobid = state.terminals[index].jobid
    local name = state.terminals[index].name
    if state.unique_name[name] ~= nil then
        state.unique_name[name] = nil
    end
    vim.fn.jobstop(jobid)
    if #state.terminals == 1 then
        reset()
        return
    end
    -- Update the side panel
    local lines = vim.api.nvim_buf_get_lines(state.panel_buf, index, -1, false)
    for i, line in ipairs(lines) do
        lines[i] = line_pack(line_unpack(line) - 1)
    end
    vim.api.nvim_buf_set_lines(state.panel_buf, index - 1, -2, false, lines)
    vim.api.nvim_buf_set_lines(state.panel_buf, -2, -1, false, {})

    table.remove(state.terminals, index)

    if index < state.cur_index then
        state.cur_index = state.cur_index - 1
        vim.api.nvim_win_set_cursor(state.panel_win, { state.cur_index, 0 })
    elseif index == state.cur_index then
        local target_index = index > #state.terminals and index - 1 or index
        M.switch(target_index)
    end

    delete_buf(bufnr)
end

---@param cmd string|string[]
---@param name string
---terminals:append
---panel_buf:newline,hl
---other:unique
local function create_terminal_buf(cmd, name, opts)
    cmd = (type(cmd) == "string" and { cmd } or cmd)
    opts = vim.tbl_deep_extend("force", {
        term = true,
    }, opts or {})
    assert(type(cmd) == "table")
    local term_buf = vim.api.nvim_create_buf(false, true)
    setup_termbuf(term_buf)
    local jobid
    vim.api.nvim_buf_call(term_buf, function()
        if not vim.fn.executable(cmd[1]) then
            cmd = { vim.o.shell }
            vim.notify(
                tostring(cmd[1] .. "is not executable") .. ",fallback to " .. vim.o.shell,
                vim.log.levels.ERROR
            )
        end
        jobid = vim.fn.jobstart(cmd, opts)
    end)
    return {
        jobid = jobid,
        bufnr = term_buf,
        cmd = vim.deepcopy(cmd),
        name = name,
    }
end

---@param cmd nil|string|string[]
---@param name string|nil
---@param unique boolean|nil
local function new_terminal(cmd, name, unique, opts)
    cmd = cmd or vim.o.shell
    unique = (unique == nil) and false or unique
    name = name or "Terminal"
    name = (unique == true) and (pinned_icon .. name) or name
    local new_term = create_terminal_buf(cmd, name, opts)
    state.terminals[#state.terminals + 1] = new_term
    if unique == true then
        if state.unique_name[name] ~= nil then
            delete_term(get_index_by_jobid(state.unique_name[name]))
        end
        state.unique_name[name] = new_term.jobid
    end
    -- Update the panel
    local count = #state.terminals
    vim.api.nvim_buf_set_lines(state.panel_buf, count - 1, count, false, { line_pack(count, name) })
    set_buf_hl_line(state.panel_buf, count, "Visual")
end
-- new_terminal()
---term_win:create minmal
---panel_win:create minmal
---panel_buf:create when first , bind to panel_win
---focus:origin->panel_win->term_win/origin
---@param focus boolean|nil nil=true
local function open_wins(focus)
    focus = focus == nil and true or focus
    local origin_win = vim.api.nvim_get_current_win()

    -- Window for terminal
    vim.cmd("botright " .. state.term_height .. "split")
    state.term_win = vim.api.nvim_get_current_win()
    set_win_minimal(state.term_win)
    -- Window for panel
    vim.cmd(state.panel_width .. "vsplit")
    state.panel_win = vim.api.nvim_get_current_win()
    set_win_minimal(state.panel_win)
    if not state.panel_buf or not vim.api.nvim_buf_is_valid(state.panel_buf) then
        state.panel_buf = vim.api.nvim_create_buf(false, true)
        setup_panelbuf(state.panel_buf)
    end
    bind_buf_to_win(state.panel_win, state.panel_buf)

    if focus then
        vim.api.nvim_set_current_win(state.term_win)
    else
        vim.api.nvim_set_current_win(origin_win)
    end
end

---------------------------------------------------------------------

-- Delete the given terminal
M.delete = function(index)
    index = index or state.cur_index
    delete_term(index)
end
M.getstate = function()
    return state
end

-- Switch to the i-th terminal
M.switch = function(index)
    state.cur_index = index
    bind_buf_to_win(state.term_win, state.terminals[state.cur_index].bufnr)

    vim.api.nvim_win_set_cursor(state.panel_win, { index, 0 })
    set_buf_hl_line(state.panel_buf, index, "Visual")
end

-- Jump to the previous or next terminal
M.jump = function(direction)
    local cur_index = state.cur_index
    if direction == -1 and cur_index ~= 1 then
        M.switch(cur_index - 1)
    elseif direction == 1 and cur_index ~= vim.tbl_count(state.terminals) then
        M.switch(cur_index + 1)
    end
end

--- Rename the current terminal
M.rename = function()
    vim.ui.input({ prompt = "[Terminal] Enter name: " }, function(input)
        if not input or input == "" then
            vim.notify("Terminal name cannot be empty", vim.log.levels.ERROR)
            return
        end
        assert(type(input) == "string")
        -- forbid name start with pinned_icon
        if input:sub(1, 2) == pinned_icon then
            vim.notify("Terminal name cannot start with " .. pinned_icon, vim.log.levels.ERROR)
            return
        end
        local cur_index = state.cur_index
        vim.api.nvim_buf_set_lines(state.panel_buf, cur_index - 1, cur_index, false, {
            line_pack(cur_index, input),
        })
    end)
end

-- Move the current terminal to the previous or next position in the list
M.move = function(direction)
    local target_index = state.cur_index + direction
    if target_index > #state.terminals or target_index < 1 then
        return
    end
    panel_lines_swap(state.cur_index, target_index)
    list_swap(state.terminals, state.cur_index, target_index)
    state.cur_index = target_index
    M.switch(target_index)
end

-- Create a new terminal
---@param cmd string|string[]|nil
---@param open boolean|nil
---@param focus boolean|nil nil=true
---@param name string|nil
---@param unique boolean|nil
M.new = function(cmd, open, focus, name, unique, opts)
    open = open == nil and true or open
    focus = focus == nil and true or focus
    if open and not is_opened() then
        open_wins(focus)
        set_autocmd()
    end
    new_terminal(cmd, name, unique, opts)
    state.cur_index = #state.terminals
    bind_buf_to_win(state.term_win, state.terminals[state.cur_index].bufnr)
    vim.api.nvim_win_set_cursor(state.panel_win, { #state.terminals, 0 })
    if focus then
        vim.api.nvim_set_current_win(state.term_win)
    else
        vim.cmd("stopinsert")
    end
end

---
M.open = function()
    open_wins()
    set_autocmd()
    if
        not state.cur_index or not vim.api.nvim_buf_is_valid(state.terminals[state.cur_index].bufnr)
    then
        new_terminal()
        state.cur_index = #state.terminals
    end
    bind_buf_to_win(state.term_win, state.terminals[state.cur_index].bufnr)
end

--- Close the terminal window along with the side panel
M.close = function()
    close_win(state.term_win)
    close_win(state.panel_win)
    vim.api.nvim_clear_autocmds({ group = "tools.terminal" })
end

---
M.toggle = function()
    if is_opened() then
        M.close()
    else
        M.open()
    end
end

-- Toggle
vim.keymap.set({ "n", "t" }, "<M-`>", function()
    require("tools.terminal").toggle()
end)

return M

--TEST:
--1. operater through keymap Ok
--2. F12 run F12 run j(auto enter innsert ? and bug: Cursor position outside buffer)
--require("tools.terminal").new({""}) Ok
--3.
