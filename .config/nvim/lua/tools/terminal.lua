--for all
-- <M-`>: toggle
-- <M-;>: new a terminal
-- <M-'>: new a terminal with specific cmd
-- <M-q>: delete the current terminal
-- <M-r>: rename the current terminal
-- <M-,>: move the current terminal backwards
-- <M-.>: move the current terminal forwards

--for panel
--<CR>:  jump to the terminal
--<M-p>: unique the terminal

--for term
-- <M-n>: jump to the next terminal
-- <M-p>: jump to the previous terminal
-- <M-1> ... <M-9>: jump to terminal #i

local M = {}

local term_icon = ""
local pinned_icon = "📌"

local default_terminal_cmd = (function()
    if vim.g.is_win then
        local options = {
            { "pwsh", "-nologo" },
            { "powershell" },
            { "cmd" },
        }
        for _, cmd in ipairs(options) do
            if vim.fn.executable(cmd[1]) then
                return cmd
            end
        end
    end
    return vim.o.shell
end)()

local state = {
    -- Current terminal
    cur_index = nil,

    term_win = nil,
    term_height = math.floor(vim.o.lines / 3),

    -- Side panel showing the list of terminals
    panel_buf = nil,
    panel_win = nil,
    panel_width = math.floor(vim.o.columns / 10),

    ---@class terminal
    ---@field jobid integer
    ---@field bufnr integer
    ---@field jobinfo table
    ---@field name string
    ---@field unique boolean
    ---@type terminal[]
    terminals = {},

    unique_name = {}, --设置unique后,后来的同名unique job将顶替前面的
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

---pinned term
local default_sendterm_name = nil

local panel_buf_hl_clearfunc = {}
local ns = vim.api.nvim_create_namespace("tools.terminal")

local send_strategy = {
    --无需open
    chansend = function(index, lines)
        lines[#lines + 1] = ""
        M.switch(index, true, false)
        vim.fn.chansend(state.terminals[index].jobid, lines)
    end,
    --需要open
    paste = function(index, lines)
        M.switch(index, true, false)
        local originwin = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(state.term_win)
        vim.cmd.stopinsert()
        local old_reg = vim.fn.getreg("a")
        local old_regtype = vim.fn.getregtype("a")
        vim.fn.setreg("a", table.concat(lines, "\n"), "c")
        vim.api.nvim_feedkeys('"ap', "nm", false)
        vim.schedule(
            function() --NOTE:若无vim.schedule set_win,setreg 会在粘贴开始前被调用
                vim.api.nvim_set_current_win(originwin)
                vim.fn.setreg("a", old_reg, old_regtype)
                vim.fn.chansend(state.terminals[index].jobid, "\r\r")
            end
        )
    end,
    file = function(_, _)
        vim.notify("unimplement", vim.log.levels.ERROR)
    end,
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

--- v/V
local function visual_election()
    local mode = vim.fn.mode()
    local line_start, column_start, line_end, column_end
    if mode == "v" then --ok
        local pos = vim.fn.getpos("v")
        line_start, column_start = pos[2], pos[3]
        pos = vim.fn.getpos(".")
        line_end, column_end = pos[2], pos[3]
    else
        -- local pos = vim.fn.getpos("'<")
        local pos = vim.fn.getpos("v")
        line_start, column_start = pos[2], pos[3]
        -- pos = vim.fn.getpos("'>")
        pos = vim.fn.getpos(".")
        line_end, column_end = pos[2], pos[3]
    end
    if
        (vim.fn.line2byte(line_start) + column_start)
        > (vim.fn.line2byte(line_end) + column_end)
    then
        line_start, column_start, line_end, column_end =
            line_end, column_end, line_start, column_start
    end

    local lines = vim.fn.getline(line_start, line_end)
    assert(type(lines) == "table")
    if #lines == 0 then
        return {}
    end
    if mode == "v" then
        lines[#lines] = string.sub(lines[#lines], 1, column_end)
        lines[1] = string.sub(lines[1], column_start)
    end
    local noemptylines = {}
    local trim = require("utils").trim
    for _, line in ipairs(lines) do
        if trim(line) ~= "" then
            table.insert(noemptylines, line)
        end
    end
    return noemptylines
end
---------------------------------------------------------------------
-- local space_num = 1
local function line_unpack(line)
    local num, text = line:match("^%[(%d+)%]%s+" .. term_icon .. "%s+(.*)")
    return tonumber(num), tostring(text)
end
local function line_pack(id, text)
    return string.format(
        "[%d]%s%s %s",
        id,
        string.rep(" ", #tostring(#state.terminals) + 1 - #tostring(id)),
        term_icon,
        text or "Terminal"
    )
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
-- Set the window to minimal style
local function set_win_minimal(winid)
    for option, value in pairs(minimal_win_opts) do
        vim.wo[winid][option] = value
    end
end
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
    vim.api.nvim_create_augroup("tools.terminal.whenopen", { clear = true })
    -- Remember its size if terminal window gets resized
    vim.api.nvim_create_autocmd("WinResized", {
        group = "tools.terminal.whenopen",
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
        group = "tools.terminal.whenopen",
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
    vim.api.nvim_create_autocmd("WinLeave", {
        group = "tools.terminal.whenopen",
        pattern = "TerminalPanel",
        callback = function()
            if panel_buf_hl_clearfunc["TermCursorLine"] then
                panel_buf_hl_clearfunc["TermCursorLine"]()
                panel_buf_hl_clearfunc["TermCursorLine"] = nil
            end
        end,
    })
end

----------------------------------------------------------------------

local function update_panelbuf()
    local panel_buf = state.panel_buf
    assert(panel_buf ~= nil)
    vim.bo[panel_buf].modifiable = true
    local lines = {}
    for i, term in ipairs(state.terminals) do
        table.insert(lines, line_pack(i, term.name))
    end
    vim.api.nvim_buf_set_lines(panel_buf, 0, -1, false, lines)
    if panel_buf_hl_clearfunc["TermCurIndex"] then
        panel_buf_hl_clearfunc["TermCurIndex"]()
        panel_buf_hl_clearfunc["TermCurIndex"] = nil
    end
    local _, clear = vim.hl.range(
        panel_buf,
        ns,
        "TermCurIndex",
        { state.cur_index - 1, 0 },
        { state.cur_index - 1, -1 },
        { priority = 100, timeout = 1e7 }
    )
    panel_buf_hl_clearfunc["TermCurIndex"] = clear
    vim.bo[panel_buf].modifiable = false
end
local function update_cursor_panelwin(index)
    index = index or state.cur_index
    local winid = state.panel_win
    if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_set_cursor(winid, { index, 0 })
    else
        assert(0)
    end
end

---@param indexfunc fun():integer
local function set_buf_keymap(bufnr, indexfunc)
    local function map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true })
    end
    local mode = bufnr == state.panel_buf and { "n", "v" } or { "n", "t" }
    map(mode, "<M-/>", function()
        vim.notify(vim.inspect(state.terminals[indexfunc()]))
    end)

    map(mode, "<M-;>", function()
        require("tools.terminal").new()
    end)
    map(mode, "<M-'>", function()
        local cmds = {}
        local i = 1
        while true do
            local prompt = ("Enter value for cmd[%d]"):format(i)
                .. (i ~= 1 and ": " .. (table.concat(cmds, " ")) or "")
            local done = false
            vim.ui.input({ prompt = prompt }, function(input)
                if input == nil then
                    cmds = nil
                    done = true
                elseif input == "" then
                    done = true
                else
                    cmds[i] = input
                    i = i + 1
                end
            end)
            if done then
                break
            end
        end
        if cmds ~= nil and #cmds ~= 0 then
            require("tools.terminal").new(cmds)
        end
    end)
    -- Delete the current terminal
    map(mode, "<M-q>", function()
        local idx = indexfunc()
        local pinned = state.unique_name[state.terminals[idx].name]
        if pinned then
            vim.notify("Pinned terminal cannot be delete", vim.log.levels.WARN)
        else
            require("tools.terminal").delete(indexfunc())
        end
    end)
    -- Rename
    map(mode, "<M-r>", function()
        require("tools.terminal").rename(indexfunc())
    end)

    -- Move the current terminal backwards or forwards
    map(mode, "<M-,>", function()
        require("tools.terminal").move(-1, indexfunc())
    end)
    map(mode, "<M-.>", function()
        require("tools.terminal").move(1, indexfunc())
    end)
end
local function setup_panelbuf(bufnr)
    vim.bo[bufnr].filetype = "TerminalPanel"
    vim.b[bufnr].buftype = "nofile"
    vim.bo[bufnr].modifiable = false
    vim.api.nvim_buf_set_name(bufnr, "TerminalPanel")
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = "tools.terminal.panelbuf",
        buffer = bufnr,
        callback = function()
            if is_opened() and vim.api.nvim_get_current_buf() == bufnr then
                local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
                if panel_buf_hl_clearfunc["TermCursorLine"] then
                    panel_buf_hl_clearfunc["TermCursorLine"]()
                    panel_buf_hl_clearfunc["TermCursorLine"] = nil
                end
                if state.cur_index ~= row then
                    local _, clear = vim.hl.range(
                        bufnr,
                        ns,
                        "TermCursorLine",
                        { row - 1, 0 },
                        { row - 1, -1 },
                        { priority = 100, timeout = 1e7 }
                    )
                    panel_buf_hl_clearfunc["TermCursorLine"] = clear
                end
            end
        end,
    })
    local function map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true })
    end
    local function getindex()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        local text = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
        local index, _ = line_unpack(text)
        return index
    end
    map("n", "<CR>", function()
        M.switch(getindex())
        vim.api.nvim_set_current_win(state.term_win)
    end)
    map("n", "<2-LeftMouse>", function()
        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        M.switch(row)
        vim.api.nvim_set_current_win(state.term_win)
    end)
    map({ "n", "v" }, "<M-p>", function()
        require("tools.terminal").toggle_unique(getindex())
    end)
    map({ "n", "v" }, "<M-n>", "")
    set_buf_keymap(bufnr, getindex)
end

local function setup_termbuf(bufnr)
    vim.bo[bufnr].bufhidden = "hide"
    vim.bo[bufnr].filetype = "Terminal"
    vim.api.nvim_buf_set_name(bufnr, vim.api.nvim_buf_get_name(bufnr) .. ";#Terminal")

    vim.api.nvim_create_autocmd("BufEnter", {
        buffer = bufnr,
        callback = function()
            if vim.fn.jobwait({ state.terminals[get_index_by_bufnr(bufnr)].jobid }, 0)[1] == -1 then
                vim.cmd.startinsert()
                vim.defer_fn(function()
                    if vim.api.nvim_get_current_buf() ~= bufnr then
                        vim.cmd.stopinsert()
                    end
                end, 1)
            else
                vim.cmd.stopinsert()
            end
        end,
    })
    vim.api.nvim_create_autocmd("ModeChanged", {
        buffer = bufnr,
        callback = function()
            local mode = vim.fn.mode()
            if vim.fn.jobwait({ state.terminals[get_index_by_bufnr(bufnr)].jobid }, 0)[1] ~= -1 then
                if mode == "t" then
                    vim.cmd.stopinsert()
                end
            end
        end,
    })
    local function map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
    end
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
    set_buf_keymap(bufnr, function()
        return state.cur_index
    end)
end

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
    table.remove(state.terminals, index)
    if index < state.cur_index then
        state.cur_index = state.cur_index - 1
    elseif index == state.cur_index then
        local target_index = index > #state.terminals and index - 1 or index
        state.cur_index = target_index
        if is_opened() then
            bind_buf_to_win(state.term_win, state.terminals[state.cur_index].bufnr)
        end
    end
    delete_buf(bufnr)
    update_panelbuf()
    if is_opened() then
        local curwin = vim.api.nvim_get_current_win()
        if curwin == state.panel_win then
            local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
            update_cursor_panelwin(row > #state.terminals and #state.terminals or row)
        elseif curwin == state.term_win then
            update_cursor_panelwin()
        end
    end
end

---@param cmd string[]
---@param name string|nil
---@return table|nil
local function create_terminal_buf(cmd, name, opts)
    local term_buf = vim.api.nvim_create_buf(false, true)
    local _on_stdout = opts and opts.on_stdout
    local _on_stderr = opts and opts.on_stderr
    local _on_exit = opts and opts.on_exit

    local newopts = vim.tbl_deep_extend("force", {
        term = true,
    }, opts or {})
    local scroll = function()
        if
            is_opened()
            and vim.api.nvim_win_get_buf(state.term_win) == term_buf
            and vim.api.nvim_get_current_buf() ~= term_buf
        then
            vim.api.nvim_buf_call(term_buf, function()
                local last_line = vim.api.nvim_buf_line_count(term_buf)
                vim.api.nvim_win_set_cursor(state.term_win, { last_line, 0 })
            end)
        end
    end
    newopts.on_stdout = function(jobid, data, event)
        vim.schedule(scroll)
        if type(_on_stdout) == "function" then
            _on_stdout(jobid, data, event, term_buf)
        end
    end
    newopts.on_stderr = function(jobid, data, event)
        vim.schedule(scroll)
        if type(_on_stderr) == "function" then
            _on_stderr(jobid, data, event, term_buf)
        end
    end
    newopts.on_exit = function(jobid, exitcode, event)
        if type(_on_exit) == "function" then
            _on_exit(jobid, exitcode, event, term_buf)
        end
    end

    local jobid
    local success
    vim.api.nvim_buf_call(term_buf, function()
        local ok, result = pcall(vim.fn.jobstart, cmd, newopts)
        if ok then
            success = true
            jobid = result
        else
            success = false
            vim.notify(
                "[terminal]: create terminal error:" .. tostring(result),
                vim.log.levels.ERROR
            )
        end
    end)
    if success == false then
        return nil
    end
    setup_termbuf(term_buf)
    return {
        jobid = jobid,
        bufnr = term_buf,
        jobinfo = {
            cmd = cmd,
            opts = newopts,
        },
        name = name,
    }
end

---@param cmd nil|string|string[]
---@param name string|nil
---@param unique boolean|nil
---@return boolean success
local function new_terminal(cmd, name, unique, opts)
    cmd = cmd or default_terminal_cmd
    cmd = (type(cmd) == "string" and { cmd } or cmd)
    assert(type(cmd) == "table")
    assert(cmd[1] ~= "")
    name = name == nil and (vim.fn.fnamemodify(cmd[1], ":t:r")) or name
    assert(name ~= nil)

    unique = (unique == nil) and false or unique
    name = (unique == true) and (pinned_icon .. name) or name
    local new_term = create_terminal_buf(cmd, name, opts)
    if new_term == nil then
        return false
    end
    local target_index = unique and (get_index_by_jobid(state.unique_name[name]) or 1)
        or #state.terminals + 1
    table.insert(state.terminals, target_index, new_term)
    state.cur_index = target_index
    bind_buf_to_win(state.term_win, new_term.bufnr)
    if unique == true then
        if state.unique_name[name] ~= nil then
            delete_term(get_index_by_jobid(state.unique_name[name]))
        end
        state.unique_name[name] = new_term.jobid
    end
    update_panelbuf()
    update_cursor_panelwin()
    return true
end
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
    vim.api.nvim_win_set_hl_ns(state.term_win, ns)
    -- Window for panel
    vim.cmd(state.panel_width .. "vsplit")
    state.panel_win = vim.api.nvim_get_current_win()
    set_win_minimal(state.panel_win)
    vim.api.nvim_win_set_hl_ns(state.panel_win, ns)
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
---@param open boolean|nil
---@param focus boolean|nil true => open=true
M.switch = function(index, open, focus)
    state.cur_index = index
    update_panelbuf()
    if open then
        M.open()
    end
    if is_opened() then
        bind_buf_to_win(state.term_win, state.terminals[state.cur_index].bufnr)
        update_cursor_panelwin()
        if focus then
            vim.api.nvim_set_current_win(state.term_win)
        end
    end
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
M.toggle_unique = function(index)
    index = index or state.cur_index
    local is_unique = state.unique_name[state.terminals[index].name] ~= nil
    if is_unique then
        state.unique_name[state.terminals[index].name] = nil
        state.terminals[index].name =
            state.terminals[index].name:match("^" .. pinned_icon .. "(.*)")
    else
        state.terminals[index].name = pinned_icon .. state.terminals[index].name
        state.unique_name[state.terminals[index].name] = state.terminals[index].jobid
    end
    update_panelbuf()
end
M.select_default_sendterm = function()
    if #state.unique_name then
        local options = { { name = "default", jobid = 0 } }
        for name, jobid in pairs(state.unique_name) do
            table.insert(options, { name = name, jobid = jobid })
        end
        vim.ui.select(options, {
            prompt = "Select Default SendTerm",
            format_item = function(item)
                return item.name
            end,
        }, function(choice)
            if choice == nil then
                return
            end
            if choice.name == "default" and choice.jobid == 0 then
                default_sendterm_name = nil
            else
                default_sendterm_name = choice.name
            end
        end)
    end
end
---@param lines string[]
---@param term {uniquename:string|nil,jobid:integer|nil,bufnr:integer|nil,index:integer|nil}|nil 任取其一,否则取default_sendterm or cur_index
---@param strategy ("paste"|"chansend"|"file")|nil 默认"paste"
---@return boolean success
M.send = function(lines, term, strategy)
    strategy = strategy or "paste"
    if #state.terminals == 0 then
        vim.notify("[terminal]: no terminal opened", vim.log.levels.ERROR)
        return false
    end
    local jobid
    local index
    if term then
        if term.uniquename then
            jobid = state.unique_name[term.uniquename]
            index = get_index_by_jobid(jobid)
        elseif term.jobid then
            jobid = jobid
            index = get_index_by_jobid(jobid)
        elseif term.bufnr then
            index = get_index_by_bufnr(term.bufnr)
            jobid = state.terminals[index].jobid
        elseif term.index then
            index = term.index
            jobid = state.terminals[index].jobid
        end
    else
        if default_sendterm_name then
            jobid = state.unique_name[default_sendterm_name]
            if jobid ~= nil then
                index = get_index_by_jobid(jobid)
            else
                vim.notify("[terminal]: Default sendterm doesn't exist", vim.log.levels.WARN)
            end
        end
        if not index then
            index = state.cur_index
            jobid = state.terminals[state.cur_index].jobid
        end
    end
    if jobid == nil then
        vim.notify("[terminal]: opts error", vim.log.levels.ERROR)
        return false
    end
    send_strategy[strategy](index, lines)
    return true
end
--- Rename the current terminal
M.rename = function(index)
    index = index or state.cur_index
    local is_unique = state.unique_name[state.terminals[index].name] ~= nil
    if is_unique then
        vim.notify(
            "[terminal]: Renaming a Unique Buffer will cancel its ‘unique’ status",
            vim.log.levels.WARN
        )
    end
    vim.ui.input({ prompt = "[Terminal] Enter name: " }, function(input)
        if not input or input == "" then
            vim.notify("[terminal]: Terminal name cannot be empty", vim.log.levels.ERROR)
            return
        end
        assert(type(input) == "string")
        -- forbid name start with pinned_icon
        if input:sub(1, 2) == pinned_icon then
            vim.notify(
                "[terminal]: Terminal name cannot start with " .. pinned_icon,
                vim.log.levels.ERROR
            )
            return
        end
        if is_unique then
            state.unique_name[state.terminals[index].name] = nil
        end
        state.terminals[index].name = input
        update_panelbuf()
    end)
end

-- Move the current terminal to the previous or next position in the list
M.move = function(direction, index)
    index = index or state.cur_index
    local target_index = index + direction
    if target_index > #state.terminals or target_index < 1 then
        return
    end
    list_swap(state.terminals, index, target_index)
    if index == state.cur_index then
        M.switch(target_index)
    elseif target_index == state.cur_index then
        state.cur_index = index
        update_panelbuf()
        if is_opened() then
            update_cursor_panelwin(target_index)
        end
    end
end

-- Create a new terminal
---@param cmd string|string[]|nil
---@param focus boolean|nil nil=true
---@param name string|nil
---@param unique boolean|nil
M.new = function(cmd, focus, name, unique, opts)
    focus = focus == nil and true or focus
    local before_opened
    if not is_opened() then
        before_opened = false
        open_wins(focus)
        set_autocmd()
    else
        before_opened = true
    end
    --notopen and n=0 => close
    --notopen and n~=0 => close
    --opened and n=0 close
    --opened and n~=0 return
    if new_terminal(cmd, name, unique, opts) == false then
        if before_opened and #state.terminals ~= 0 then
            return
        else
            M.close()
            return
        end
    end
    update_panelbuf()
    update_cursor_panelwin()
end

---
M.open = function()
    if is_opened() then
        return
    end
    open_wins()
    set_autocmd()
    if
        not state.cur_index or not vim.api.nvim_buf_is_valid(state.terminals[state.cur_index].bufnr)
    then
        assert(new_terminal() == true)
    end
    bind_buf_to_win(state.term_win, state.terminals[state.cur_index].bufnr)
end

--- Close the terminal window along with the side panel
M.close = function()
    close_win(state.term_win)
    close_win(state.panel_win)
    panel_buf_hl_clearfunc = {}
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

M.setup = function()
    local function sethl()
        local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
        local visual = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.api.nvim_set_hl(ns, "TermCurIndex", cursorline)
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.api.nvim_set_hl(ns, "TermCursorLine", visual)
    end
    vim.api.nvim_create_augroup("tools.terminal", { clear = true })
    vim.api.nvim_create_augroup("tools.terminal.panelbuf", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = "tools.terminal",
        pattern = "*",
        callback = sethl,
    })
    sethl()
    vim.api.nvim_create_user_command("TermSelectDefaultSendTerm", M.select_default_sendterm, {})
    -- Toggle
    vim.keymap.set({ "n", "t" }, "<M-`>", function()
        require("tools.terminal").toggle()
    end)
    vim.keymap.set("v", "<CR>", function()
        if M.send(visual_election()) then
            vim.cmd("normal! \28\14")
        end
    end)
end
return M
