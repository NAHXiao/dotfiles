local utils = require("tools.term.utils")
local log = utils.log
local log_notify = utils.log_notify
local BijectionMap = require("libs.BijectionMap")
local win_autocmd_group = vim.api.nvim_create_augroup("term.wins.autocmd", { clear = true })
local minimal_win_opts = {
    number = false,
    relativenumber = false,
    foldcolumn = "0",
    signcolumn = "no",
    statuscolumn = "",
    spell = false,
    list = false,
    fillchars = "eob: ",
}
local function setup_termwin(winid)
    for option, value in pairs(minimal_win_opts) do
        vim.wo[winid][option] = value
    end
    vim.wo[winid].winfixbuf = true
end
local function setup_panelwin(winid)
    for option, value in pairs(minimal_win_opts) do
        vim.wo[winid][option] = value
    end
    vim.wo[winid].winfixbuf = true
    vim.wo[winid].cursorlineopt = "line"
end
local function create_panelbuf()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].buflisted = false
    vim.bo[bufnr].bufhidden = "hide"
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].buftype = "nofile"
    vim.bo[bufnr].filetype = "TerminalPanel"
    vim.api.nvim_buf_set_name(bufnr, "TerminalPanel")
    return bufnr
end
local function create_fbtermbuf()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(
        bufnr,
        0,
        -1,
        false,
        { "Fallback Term Bufnr", "You Should Create A TermBuf Now" }
    )
    vim.bo[bufnr].filetype = "TerminalBuf"
    vim.bo[bufnr].buftype = "nofile"
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].buflisted = false

    local keymaps = require("tools.term.keymaps").termbuf
    require("tools.term.keymaps").map(keymaps, nil, bufnr)
    return bufnr
end
---@param range {[1]:number,[2]:number} [start,finish] 1-based
---@param lines string[]
---@param bufnr number
local function set_lines(range, lines, bufnr)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        log_notify(("invalid bufnr: %s"):format(tostring(bufnr)))
        return
    end
    vim.bo[bufnr].modifiable = true
    local start_line, end_line = range[1], range[2]
    vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, lines)
    vim.bo[bufnr].modifiable = false
end
local M = {
    ---@type BijectionMap<NNode,number>
    data = nil,
    ---@type GroupNode
    root = nil,

    ---@type number
    panelbuf = nil,
    ---@type number?
    panelwin = nil,
    ---@type number?
    termwin = nil,
    ---@type number
    fallback_termbuf = nil,

    ---@type TermNode|TaskTermNode|nil
    curnode = nil,
    ---@type boolean
    opened = false,
}
---@return number
function M.get_panelbuf()
    M.init_or_repair("panelbuf")
    return M.panelbuf
end
---@return number
function M.get_termbuf()
    local curnode = M.get_cur_node()
    if curnode and curnode.bufnr and vim.api.nvim_buf_is_valid(curnode.bufnr) then
        return curnode.bufnr
    else
        M.init_or_repair("fallback_termbuf")
        return M.get_fallback_termbuf()
    end
end
function M.update_termwinbuf()
    if M.opened then
        log_notify("update_termwinbuf")
        local termbuf = M.get_termbuf()
        if termbuf ~= vim.api.nvim_win_get_buf(M.termwin) then
            vim.wo[M.termwin].winfixbuf = false
            vim.api.nvim_win_set_buf(M.termwin, M.get_termbuf())
        end
        vim.wo[M.termwin].winfixbuf = true
    end
end
---@return number?
function M.get_panelwin()
    return M.opened and M.panelwin or nil
end
---@return number?
function M.get_termwin()
    return M.opened and M.termwin or nil
end
---@return number
function M.get_fallback_termbuf()
    if utils.validbuf(M.fallback_termbuf) then
        return M.fallback_termbuf
    else
        if M.fallback_termbuf and vim.fn.bufexists(M.fallback_termbuf) then
            vim.api.nvim_buf_delete(M.fallback_termbuf, { force = true })
        end
        M.fallback_termbuf = create_fbtermbuf()
        return M.fallback_termbuf
    end
end
---@param node GroupNode|TaskSetNode
---@return number? start [start,finish] 1-based ; when node isnot displayed,return nil
---@return number? finish
local function get_lines_range_by_node(node)
    local linenum = M.data:getByKey(node)
    if not linenum then
        return nil, nil
    end
    local startline = linenum
    local finishline = linenum
    if node.classname == "GroupNode" or node.classname == "TaskSetNode" then
        local curnode
        repeat
            curnode = M.data:getByValue(finishline + 1)
            log("get_lines_range_by_node: repeat: ", curnode)
            assert(not curnode or curnode.name ~= "Root")
            if curnode and curnode:parents_has(node) then
                finishline = finishline + 1
            else
                break
            end
        until false
    end
    log(("get_lines_range_by_node: startline:%d finishline:%d"):format(startline, finishline))
    return startline, finishline
end
---@param node NNode
---@param recurse boolean?
function M.update_data_by_node(node, recurse)
    log_notify("update_data_by_node: ", node.name, "recurse:", recurse)
    log("update_data_by_node: ", node, "recurse:", recurse)
    local panelbuf = M.get_panelbuf()
    local indent = 0
    local parent = node.parent
    while parent do
        indent = indent + 1
        parent = parent.parent
    end
    if recurse and node.classname == "GroupNode" or node.classname == "TaskSetNode" then
        ---@cast node GroupNode|TaskSetNode
        local startline, finishline = get_lines_range_by_node(node)
        if not startline then
            return
        end
        local new_lines = {}
        local stack = { { node, indent } }
        local nodes = {}
        while #stack > 0 do
            local top = table.remove(stack, #stack)
            local topnode, topindent = top[1], top[2]
            new_lines[#new_lines + 1] = string.rep(" ", topindent) .. topnode:display()
            nodes[#nodes + 1] = topnode
            if topnode.classname == "GroupNode" or topnode.classname == "TaskSetNode" then
                ---@cast topnode GroupNode|TaskSetNode
                if topnode.expanded then
                    for i = #topnode.children, 1, -1 do
                        stack[#stack + 1] = { topnode.children[i], topindent + 1 }
                    end
                end
            end
        end
        local after_nodes = {}
        for linenum = startline, finishline do
            M.data:delByValue(linenum)
        end
        for linenum = finishline + 1, math.huge do
            local n = M.data:getByValue(linenum)
            if not n then
                break
            end
            M.data:delByValue(linenum)
            after_nodes[#after_nodes + 1] = n
        end
        for idx, n in ipairs(nodes) do
            M.data:set(n, startline + idx - 1)
            log_notify(("set node %s line %d"):format(n.name, startline + idx - 1))
        end
        for idx, n in ipairs(after_nodes) do
            M.data:set(n, startline + #nodes - 1 + idx)
            log_notify(("set node %s line %d"):format(n.name, startline + #nodes - 1 + idx))
        end
        log("data", M.data)
        log_notify(("update_data_by_node: [%d,%d] -> "):format(startline, finishline), new_lines)
        set_lines({ startline, finishline }, new_lines, panelbuf)
    else
        local linenum = M.data:getByKey(node)
        if not linenum then
            return
        end
        set_lines({ linenum, linenum }, { string.rep(" ", indent) .. node:display() }, panelbuf)
    end
end
function M.del_data_by_node(node)
    if M.get_cur_node() == node then
        M.set_cur_node(nil)
    end
    local panelbuf = M.get_panelbuf()
    local startline, finishline = get_lines_range_by_node(node)
    if startline then
        vim.notify(("del_data_by_node [%d,%d]"):format(startline, finishline))
        set_lines({ startline, finishline }, {}, panelbuf)
        for i = startline, finishline do
            M.data:delByValue(i)
        end
        for linenum = finishline + 1, math.huge do
            local n = M.data:getByValue(linenum)
            if not n then
                break
            end
            M.data:setValue(n, linenum - (finishline - startline + 1))
        end
    end
end
function M.panel_follow_curnode(opts)
    local curnode = M.get_cur_node()
    if curnode then
        M.panel_follow_node(curnode, opts)
    end
end
---@param node NNode
---@param opts { expand:boolean?, always:boolean?}
---- expand: default `true`
---- always: follow even when the focus is on the panelwin.default `false`
function M.panel_follow_node(node, opts)
    opts = vim.tbl_extend("force", { expand = true, always = false }, opts)
    if M.opened and (opts.always or (not M.is_focused("panel"))) then
        local row = M.data:getByKey(node)
        if row then
            vim.api.nvim_win_set_cursor(M.panelwin, { row, 0 })
        elseif opts.expand then
            local parent = node.parent
            while parent do
                parent:toggle_expand(true)
                parent = parent.parent
            end
            row = M.data:getByKey(node)
            if row then
                vim.api.nvim_win_set_cursor(M.panelwin, { row, 0 })
            else
                log_notify("数据不一致", M.data)
            end
        end
    end
end
---@return TaskTermNode|TermNode|nil
function M.get_cur_node()
    return M.curnode
end
function M.get_root()
    M.init_or_repair("root")
    return M.root
end
function M.get_data()
    M.init_or_repair("data")
    return M.data
end
---@param node TermNode|TaskTermNode|nil
function M.set_cur_node(node)
    if not node or node.classname == "TermNode" or node.classname == "TaskTermNode" then
        M.curnode = node
        M.update_termwinbuf()
        M.panel_follow_curnode { expand = false, always = false }
        log_notify("set curnode to " .. (node and node.name or "nil"))
    else
        log_notify("set_cur_node arg error: ", node and node:tostring())
    end
end
---@param who? "term"|"panel"
function M.is_focused(who)
    local winid = vim.api.nvim_get_current_win()
    return M.opened
        and (
            ((not who or who == "term") and winid == M.get_termwin())
            or ((not who or who == "panel") and winid == M.get_panelwin())
        )
end
---@param who? "term"|"panel" default term
function M.focus(who)
    log("focus")
    if not M.opened then
        M.open(true)
    end
    if not who or who == "term" then
        local termwin = M.get_termwin()
        if termwin then
            vim.api.nvim_set_current_win(termwin)
        end
    else
        local panelwin = M.get_panelwin()
        if panelwin then
            vim.api.nvim_set_current_win(panelwin)
        end
    end
end
function M.toggle()
    if not M.opened then
        M.open(true)
    elseif not M.is_focused() then
        M.focus()
    else
        M.close()
    end
end
---ensure data,root,panelbuf,fallback_termbuf
---@param who? "root"|"data"|"panelbuf"|"fallback_termbuf"
function M.init_or_repair(who)
    if not who or who == "data" then
        if M.data == nil then
            M.data = BijectionMap.new()
        end
    end
    if not who or who == "root" then
        M.init_or_repair("data")
        if M.root == nil then
            M.data:clear()
            M.root = require("tools.term.node.groupnode"):new { name = "Root" }
            M.data:set(M.root, 1)
        end
    end
    if not who or who == "panelbuf" then
        if not M.panelbuf or not utils.validbuf(M.panelbuf) then
            if M.panelbuf and vim.fn.bufexists(M.panelbuf) then
                vim.api.nvim_buf_delete(M.panelbuf, { force = true })
            end
            M.panelbuf = create_panelbuf()
            local keymaps = require("tools.term.keymaps").panelbuf
            assert(M.panelbuf)
            require("tools.term.keymaps").map(keymaps, function()
                local row = vim.api.nvim_win_get_cursor(0)[1]
                log_notify("get row : " .. row)
                return M.data:getByValue(row)
            end, M.panelbuf)
            local g = vim.api.nvim_create_augroup("tools.terminal.panelbufcxt", { clear = true })
            vim.api.nvim_create_autocmd("WinLeave", {
                group = g,
                pattern = "TerminalPanel",
                callback = function()
                    M.panel_follow_curnode { expand = true, always = true }
                end,
            })
        end
    end
    if not who or who == "fallback_termbuf" then
        if not M.fallback_termbuf or not utils.validbuf(M.fallback_termbuf) then
            M.fallback_termbuf = create_fbtermbuf()
        end
    end
end
---@param focus boolean?
function M.open(focus)
    log(("open: focus: %s"):format(tostring(focus)))
    M.init_or_repair()
    if M.opened then
        return
    end
    local origin_winid = vim.api.nvim_get_current_win()
    --if root.children len==0 then root.addnode
    if #M.root.children == 0 then
        local node = require("tools.term.node.termnode"):new(
            { name = vim.fn.fnamemodify(utils.default_shell[1], ":t:r") },
            { cmds = utils.default_shell, opts = {} },
            true
        )
        M.root:addnode(node)
        M.set_cur_node(node)
    end
    local panelbuf = M.get_panelbuf()
    local termbuf = M.get_termbuf()
    --split,vsplit(binded to buf)
    vim.cmd(("botright %dsplit | buffer %d"):format(math.floor(vim.o.lines / 3), termbuf)) --height
    M.termwin = vim.api.nvim_get_current_win()
    setup_termwin(M.termwin)
    vim.cmd(
        ("%dvsplit | buffer %d"):format(
            math.floor(vim.api.nvim_win_get_width(M.termwin) / 5),
            panelbuf
        )
    ) --width
    M.panelwin = vim.api.nvim_get_current_win()
    setup_panelwin(M.panelwin)
    vim.api.nvim_create_autocmd("WinClosed", {
        group = win_autocmd_group,
        pattern = table.concat({ M.termwin, M.panelwin }, ","),
        callback = function()
            log("WinClosed")
            M:close()
        end,
    })
    vim.api.nvim_create_autocmd("WinResized", {
        group = win_autocmd_group,
        -- pattern = table.concat({ M.termwin, M.panelwin }, ","),
        callback = function()
            vim.api.nvim_win_set_width(
                M.panelwin,
                math.min(
                    vim.api.nvim_win_get_width(M.panelwin),
                    math.floor(vim.api.nvim_win_get_width(M.termwin) / 4)
                )
            )
        end,
    })
    --if not focus then return origin window else focus termwin
    if not focus then
        vim.api.nvim_set_current_win(origin_winid)
    else
        vim.api.nvim_set_current_win(M.termwin)
    end
    M.opened = true

    M.panel_follow_curnode { expand = true, always = false }
end
function M.close()
    log("close")
    if not M.opened then
        return
    end
    if M.termwin and vim.api.nvim_win_is_valid(M.termwin) then
        vim.api.nvim_win_close(M.termwin, true)
        M.termwin = nil
    end
    if M.panelwin and vim.api.nvim_win_is_valid(M.panelwin) then
        vim.api.nvim_win_close(M.panelwin, true)
        M.panelwin = nil
    end
    vim.api.nvim_clear_autocmds { group = win_autocmd_group }
    M.opened = false
end
---@param lines string[]
---@param node TaskTermNode|TermNode
---@param extra_cr number? default 2
---@return boolean
function M.send_feedkey(lines, node, extra_cr)
    extra_cr = extra_cr or 2
    if node == nil then
        vim.notify("You can not send to nil", vim.log.levels.ERROR)
        return false
    end
    local ok, pid = pcall(vim.fn.jobpid, node.jobinfo.jobid)
    if ok and vim.uv.kill(pid, 0) == 0 then
        local origin_win = vim.api.nvim_get_current_win()
        if M.get_cur_node() ~= node then
            M.set_cur_node(node)
        end
        M.focus()
        vim.cmd.stopinsert()
        local old = vim.fn.getreginfo("a")
        vim.fn.setreg("a", table.concat(lines, "\n"), "c")
        vim.api.nvim_feedkeys('"ap', "n", false)
        vim.schedule(function()
            vim.fn.setreg("a", old.value, old.regtype)
            for _ = 1, extra_cr do
                vim.fn.chansend(node.jobinfo.jobid, "\r")
            end
            vim.api.nvim_set_current_win(origin_win)
            vim.cmd.stopinsert()
        end)
        return true
    end
    return false
end

---@param lines string[]
---@param node TaskTermNode|TermNode
---@param extra_cr number? default 2
---@return boolean
function M.send_chansend(lines, node, extra_cr)
    if node == nil then
        vim.notify("You can not send to nil", vim.log.levels.ERROR)
        return false
    end
    local ok, pid = pcall(vim.fn.jobpid, node.jobinfo.jobid)
    if ok and vim.uv.kill(pid, 0) == 0 then
        pcall(vim.fn.chansend, node.jobinfo.jobid, lines)
        for _ = 1, extra_cr do
            pcall(vim.fn.chansend, node.jobinfo.jobid, "\r")
        end
    end
    return true
end

---@class panel
---@field get_panelbuf fun():number ShouldBe ReadOnly
---@field get_termbuf fun():number ShouldBe ReadOnly
---@field get_panelwin fun():number ShouldBe ReadOnly
---@field get_termwin fun():number ShouldBe ReadOnly
---@field get_cur_node fun():TermNode|TaskTermNode|nil ShouldBe ReadOnly
---@field get_root fun():GroupNode ShouldBe ReadOnly
---@field getdata fun():BijectionMap<NNode,number> ShouldBe ReadOnly
---
---@field update_data_by_node fun(node:NNode,recurse?:boolean) WriteAble
---@field del_data_by_node fun(node:NNode) WriteAble
---@field update_termwinbuf fun() WriteAble
---@field set_cur_node fun(node:TermNode|TaskTermNode|nil) WriteAble ButShouldOnlyUsedInKeyMap
---
---@field open fun() Expose
---@field close fun() Expose
---@field is_focused fun():boolean Expose
---@field focus fun(who?:"term"|"panel") Expose default term
---@field toggle fun() Expose
---@field panel_follow_node fun(node:NNode,opts:{ expand:boolean?, always:boolean?})
---@field send_feedkey fun(lines:string[], node:TaskTermNode|TermNode, extra_cr?:number) Expose
---@field send_chansend fun(lines:string[], node:TaskTermNode|TermNode, extra_cr?:number) Expose
return {
    get_panelbuf = M.get_panelbuf,
    get_termbuf = M.get_termbuf,
    get_panelwin = M.get_panelwin,
    get_termwin = M.get_termwin,
    get_cur_node = M.get_cur_node,
    get_root = M.get_root,
    getdata = M.get_data,
    update_data_by_node = M.update_data_by_node,
    del_data_by_node = M.del_data_by_node,
    update_termwinbuf = M.update_termwinbuf,
    panel_follow_node = M.panel_follow_node,
    set_cur_node = M.set_cur_node,
    open = M.open,
    close = M.close,
    is_focused = M.is_focused,
    focus = M.focus,
    toggle = M.toggle,
    send_feedkey = M.send_feedkey,
    send_chansend = M.send_chansend,
}
