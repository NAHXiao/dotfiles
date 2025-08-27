local ERROR = vim.log.levels.ERROR
local log = require("utils").log
local function log_notify(...)
    -- local msg = table.concat(log(...), "\n")
    -- vim.notify(msg)
end
local function pmsgcall(...)
    local ok, result_or_errmsg = pcall(...)
    if not ok then
        local info = debug.getinfo(2, "nSl")
        if info then
            result_or_errmsg = ("%s:%d %s(): "):format(info.short_src, info.currentline, info.name)
                .. result_or_errmsg
        end
        vim.notify(result_or_errmsg, ERROR)
    end
end
local function validbuf(bufnr) --scrict
    return bufnr
        and vim.fn.bufexists(bufnr)
        and vim.api.nvim_buf_is_valid(bufnr)
        and vim.api.nvim_buf_is_loaded(bufnr)
end
local ns = vim.api.nvim_create_namespace("tools.terminal")
vim.api.nvim_create_augroup("tools.terminal.global", { clear = true })
local function hlline(bufnr, linenum, hlgroup)
    if not validbuf(bufnr) then
        return
    end
    local end_col = #vim.api.nvim_buf_get_lines(bufnr, linenum - 1, linenum, false)[1]
    local mark_id = vim.api.nvim_buf_set_extmark(bufnr, ns, linenum - 1, 0, {
        end_row = linenum - 1,
        end_col = end_col,
        hl_group = hlgroup,
        hl_eol = true,
    })
    return function()
        if validbuf(bufnr) then
            vim.api.nvim_buf_del_extmark(bufnr, ns, mark_id)
        end
    end
end
local unreachable = function(...)
    assert(false)
end
---@class ujobinfo
---@field cmds string[]|string
---@field opts {
---clear_env?:boolean,
---detach?:boolean,
---cwd?:string,
---env?:table<string,string>,
---before_start?:fun(node:TermNode|TaskTermNode|TaskSetNode),
---on_start?:fun(job: number,node:TermNode|TaskTermNode|TaskSetNode),
---on_stdout?:fun(job: number, data: string[], event: string,node:TermNode|TaskTermNode|TaskSetNode),
---on_stderr?:fun(job: number, data: string[], event: string,node:TermNode|TaskTermNode|TaskSetNode),
---on_exit?:fun(job: number, code: number, event: string,node:TermNode|TaskTermNode|TaskSetNode),
---after_finish?:fun(jobid,code,node),
---repeat_opts?:{time?:number,timeinterval?:number,stop_cond?:fun(code,stdout,stderr):boolean}}

---@class jobinfo
---@field cmds string[]|string
---@field opts {
---clear_env:boolean,
---detach:boolean,
---cwd?:string,
---env?:table<string,string>,
---before_start?:fun(node:TermNode|TaskTermNode|TaskSetNode),
---on_start?:fun(job: number,node:TermNode|TaskTermNode|TaskSetNode),
---on_stdout?:fun(job: number, data: string[], event: string,node:TermNode|TaskTermNode|TaskSetNode),
---on_stderr?:fun(job: number, data: string[], event: string,node:TermNode|TaskTermNode|TaskSetNode),
---on_exit?:fun(job: number, code: number, event: string,node:TermNode|TaskTermNode|TaskSetNode),
---repeat_opts?:{time?:number,timeinterval?:number,stop_cond?:fun(code,stdout,stderr):boolean}}
---@field jobid integer
---jobid,clear_env,detach

---@class panelbufcxt
---@field displayed_data { [number]:{str:string,node:NNode}, [NNode]:{index:number,str:string},lines:string[],width:number}
---@field bufnr integer
---@field fallback_term_bufnr integer
---@field panel_buf_hl_curnode_clearfunc fun()|nil
---@field panel_buf_hl_cursornode_clearfunc fun()|nil
---@field root GroupNode tree
---@field _cursornode NNode(ref)
local panelbufcxt = { unique_map = {} }

---@param curnode NNode
local function verify_valid_curnode(curnode)
    if curnode == nil then
        return false, "node is nil"
    end
    if curnode.classname ~= "TaskTermNode" and curnode.classname ~= "TermNode" then
        return false, "node is a " .. curnode.classname
    end
    ---@cast curnode TaskTermNode|TermNode
    if curnode.bufnr == nil or not vim.api.nvim_buf_is_valid(curnode.bufnr) then
        return false, "node doesn't have a valid buf"
    end
    return true
end
---@return TermNode|TaskTermNode|nil
local function find_valid_curnode(node)
    if node.classname == "TermNode" or node.classname == "TaskTermNode" then
        if node.bufnr and vim.api.nvim_buf_is_valid(node.bufnr) then
            return node
        end
    elseif node.classname == "GroupNode" or node.classname == "TaskSetNode" then
        for _, child in ipairs(node.children) do
            local ret = find_valid_curnode(child)
            if ret then
                return ret
            end
        end
    else
        assert(false)
    end
end
---@class winmanager
---@field term_winid integer
---@field panel_winid integer
local winmanager = {}
local function panel_default_width()
    assert(panelbufcxt.displayed_data)
    return math.max(panelbufcxt.displayed_data.width, math.min(math.floor(vim.o.columns / 10), 15))
end

local function TermWinBufUpdate()
    winmanager:_update_termwin_bindbuf()
end
local panel_buf_lock = false
local function PanelCurHLUpdate()
    panelbufcxt:update_panelbuf_curnode_hl()
end
local function PanelCurSorHLUpdate()
    if winmanager:_is_opened() then
        local cursornode = panelbufcxt._cursornode
        local rowdata = panelbufcxt.displayed_data[cursornode]
        local row = rowdata.index
        vim.api.nvim_win_set_cursor(winmanager.panel_winid, { row, 0 })
        panelbufcxt:_update_panelbuf_cursornode_hl()
    end
end
local function PanelBufFullUpdate()
    if panel_buf_lock == true then
        vim.defer_fn(PanelBufFullUpdate, 1)
        return
    end
    panel_buf_lock = true
    panelbufcxt:update_displayed_data()
    local lines = {}
    for _, line in ipairs(panelbufcxt.displayed_data.lines) do
        lines[#lines + 1] = line
            .. string.rep(" ", panel_default_width() - vim.fn.strdisplaywidth(line))
    end
    vim.bo[panelbufcxt:get_panel_bufnr()].modifiable = true
    vim.api.nvim_buf_set_lines(panelbufcxt:get_panel_bufnr(), 0, -1, false, lines)
    vim.bo[panelbufcxt:get_panel_bufnr()].modifiable = false
    if winmanager:_is_opened() then
        vim.api.nvim_win_set_width(winmanager.panel_winid, panel_default_width())
    end
    PanelCurHLUpdate()
    PanelCurSorHLUpdate()
    panel_buf_lock = false
end
local function setup_termbuf(bufnr)
    vim.bo[bufnr].filetype = "TerminalBuf"
    vim.bo[bufnr].buflisted = false
    vim.api.nvim_create_autocmd("BufEnter", {
        buffer = bufnr,
        callback = function()
            vim.schedule(function()
                local is_running = vim.uv.kill(vim.b[bufnr].terminal_job_pid, 0) == 0
                if vim.api.nvim_get_current_buf() == bufnr then
                    if is_running then
                        vim.cmd.startinsert()
                    else
                        vim.cmd.stopinsert()
                    end
                end
            end)
        end,
    })
    vim.api.nvim_create_autocmd("ModeChanged", {
        buffer = bufnr,
        callback = function()
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(bufnr) then
                    return
                end
                local is_running = vim.uv.kill(vim.b[bufnr].terminal_job_pid, 0) == 0
                if
                    vim.fn.mode() == "t"
                    and not is_running
                    and vim.api.nvim_get_current_buf() == bufnr
                then
                    vim.cmd.stopinsert()
                end
            end)
        end,
    })
    local function map(mode, lhs, rhs, desc)
        vim.keymap.set(
            mode,
            lhs,
            rhs,
            { desc = desc, buffer = bufnr, noremap = true, silent = true }
        )
    end
    local curnode = function()
        return panelbufcxt._curnode
    end
    local append_node = function()
        local retnode = curnode()
        repeat
            if retnode.classname == "GroupNode" then
                return retnode
            else
                retnode = retnode.parent
                -- if retnode.classname ~= "TaskSetNode" then
                --     vim.notify("You cannot add node at TaskSetNode", ERROR)
                --     return nil
                -- end
                -- -- assert(retnode.classname ~= "TaskSetNode")
            end
        until retnode == nil
    end
    map({ "n", "t" }, "<M-;>", function()
        local apnode = append_node()
        if apnode then
            local node = panelbufcxt:append_default(apnode)
            panelbufcxt:switch(node)
        end
    end, "append default node")
    map({ "n", "t" }, "<M-'>", function()
        local apnode = append_node()
        if apnode then
            local node = panelbufcxt:append_userinput(apnode)
            panelbufcxt:switch(node)
        end
    end, "append node by input")
    map({ "n", "t" }, "<M-q>", function()
        panelbufcxt:delnode(curnode())
    end, "delete node")
    map({ "n", "t" }, "<M-n>", function()
        local next = curnode().next
        if next then
            panelbufcxt:switch(next)
        else
            if curnode().parent ~= panelbufcxt.root and curnode().parent.next then
                panelbufcxt:switch(curnode().parent.next)
            end
        end
    end, "switch to next node")
    map({ "n", "t" }, "<M-p>", function()
        local prev = curnode().prev
        if prev then
            panelbufcxt:switch(prev)
        else
            if curnode().parent ~= panelbufcxt.root and curnode().parent.prev then
                panelbufcxt:switch(curnode().parent.prev)
            end
        end
    end, "switch to prev node")
    map({ "n", "t" }, "<M-,>", function()
        panelbufcxt:swap(-1, curnode())
    end, "swap node with prev")
    map({ "n", "t" }, "<M-.>", function()
        panelbufcxt:swap(1, curnode())
    end, "swap node with next")
    map({ "n", "t" }, "<M-r>", function()
        panelbufcxt:rename(curnode())
    end, "rename node")
    map({ "n", "t" }, "<M-R>", function()
        panelbufcxt:restart(curnode(), true)
    end, "restart node")
    map({ "n", "t" }, "<M-P>", function()
        panelbufcxt:toggle_pin(curnode())
    end, "toggle node's pinned option")
end
local function setup_keymap_panel(bufnr)
    local function map(mode, lhs, rhs, desc)
        if type(lhs) == "string" then
            lhs = { lhs }
        end
        for _, l in ipairs(lhs) do
            vim.keymap.set(
                mode,
                l,
                rhs,
                { buffer = bufnr, noremap = true, silent = true, desc = desc }
            )
        end
    end
    local cursor_node = function()
        return panelbufcxt._cursornode
    end
    local curnode = function()
        return panelbufcxt._curnode
    end
    local append_node = function()
        local retnode = cursor_node()
        repeat
            if retnode.classname == "GroupNode" then
                return retnode
            else
                retnode = retnode.parent
                -- if retnode.classname ~= "TaskSetNode" then
                --     vim.notify("You cannot add node at TaskSetNode", ERROR)
                --     return nil
                -- end
                -- assert(retnode.classname ~= "TaskSetNode")
            end
        until retnode == nil
    end

    map("n", { "<M-;>", "a" }, function()
        local apnode = append_node()
        if apnode then
            local node = panelbufcxt:append_default(apnode)
            panelbufcxt:switch(node)
        end
    end, "append default node")
    map("n", { "<M-'>", "A" }, function()
        local apnode = append_node()
        if apnode then
            local node = panelbufcxt:append_userinput(apnode)
            panelbufcxt:switch(node)
        end
    end, "append node by input")
    map("n", { "<M-q>", "d" }, function()
        panelbufcxt:delnode(cursor_node())
    end, "delete node")
    map("n", { "<M-n>", "n" }, function()
        local next = curnode().next
        if next then
            panelbufcxt:switch(next)
        else
            if curnode().parent ~= panelbufcxt.root and curnode().parent.next then
                panelbufcxt:switch(curnode().parent.next)
            end
        end
    end, "switch to next node")
    map("n", { "<M-p>", "p" }, function()
        local prev = curnode().prev
        if prev then
            panelbufcxt:switch(prev)
        else
            if curnode().parent ~= panelbufcxt.root and curnode().parent.prev then
                panelbufcxt:switch(curnode().parent.prev)
            end
        end
    end, "switch to prev node")
    map("n", { "<M-,>", "h" }, function()
        panelbufcxt:swap(-1, cursor_node())
    end, "swap node with prev")
    map("n", { "<M-.>", "l" }, function()
        panelbufcxt:swap(1, cursor_node())
    end, "swap node with next")
    map("n", { "<M-r>", "r" }, function()
        panelbufcxt:rename(cursor_node())
    end, "rename node")
    map("n", { "<M-R>", "R" }, function()
        panelbufcxt:restart(cursor_node(), true)
    end, "restart node")
    map("n", { "<M-P>", "P" }, function()
        panelbufcxt:toggle_pin(cursor_node())
    end, "toggle node's pinned option")
    map("n", { "<M-/>" }, function()
        vim.notify(vim.inspect(cursor_node()))
    end, "inspect node")
    map("n", { "<CR>", "<2-LeftMouse>" }, function()
        local cursornode = cursor_node()
        if cursornode.classname == "GroupNode" or cursornode.classname == "TaskSetNode" then
            ---@cast cursornode GroupNode|TaskSetNode
            panelbufcxt:toggle_expand(cursornode)
        else
            panelbufcxt:switch(cursornode)
            winmanager:focus()
        end
    end, "switch/expand")
end
---@class NNode
---@field classname string
---@field pinned boolean
---@field name string
---@field next NNode
---@field prev NNode
---@field parent GroupNode|TaskSetNode
local Node = {
    classname = "Node",
    pinned = false,
    name = "Node",
}
Node.__index = Node
function Node:rename(name)
    self.name = name
end

Node._display = unreachable
Node.restart = unreachable
Node.start = unreachable
Node.clean = unreachable
function Node:_toggle_pin()
    self.pinned = not self.pinned
end

---@param node NNode
function Node:parents_has(node)
    assert(node.parent ~= nil)
    local cur = self
    repeat
        if cur.parent == node then
            return true
        else
            cur = cur.parent
        end
    until cur.parent == nil
    return false
end

---@alias newnode_opts {name:string, parent?:GroupNode|TaskSetNode, next?:NNode, prev?:NNode, pinned?:boolean}
---@generic T : NNode
---@param self T
---@return T
function Node:_new(newnode_opts)
    local obj = {
        _new = unreachable,
        name = newnode_opts.name,
        next = newnode_opts.next,
        prev = newnode_opts.prev,
        pinned = newnode_opts.pinned,
        parent = newnode_opts.parent,
    }
    setmetatable(obj, self)
    return obj
end

---@class TermNode : NNode
---@field bufnr number
---@field jobinfo jobinfo
---@field repeat_left_times? number
---@field repeat_timer? uv.uv_timer_t
---@field _setupbuf fun(bufnr)
local TermNode = {
    classname = "TermNode",
    name = "TermNode",

    bufnr = -1,
    jobinfo = { opts = { term = true, detach = false }, jobid = -1 },
    _setupbuf = setup_termbuf,
}
TermNode.__index = TermNode
setmetatable(TermNode, Node)
local scroll = function()
    local is_opened = winmanager:_is_opened()
    local is_focused = winmanager:_is_focused()
    if is_opened and not is_focused then
        local bufnr = vim.api.nvim_win_get_buf(winmanager.term_winid)
        ---NOTE: vim.fn.jobwait Cannnot be used in interactive binary,that will causes block
        -- local is_running = vim.fn.jobwait({ vim.b[].terminal_job_id, })[1] == -1
        local is_running = vim.uv.kill(vim.b[bufnr].terminal_job_pid, 0) == 0
        local winid = winmanager.term_winid
        if is_running then
            vim.api.nvim_win_call(winid, function()
                local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(winid))
                vim.api.nvim_win_set_cursor(winid, { last, 0 })
            end)
        end
    end
end
---@generic T : NNode
---@param self T
---@return T
---@param newnode_opts newnode_opts
---@param ujobinfo ujobinfo
---@param startnow? boolean
---default: startnow=false
---jobinfo:param>TermNode
---func: scroll,TermNode(nil),param.ujobinfo ...(repeat)...after_finish
function TermNode:new(newnode_opts, ujobinfo, startnow)
    local obj = Node._new(self, newnode_opts)
    ---@cast obj TermNode
    if ujobinfo.opts.repeat_opts then
        obj.repeat_left_times = ujobinfo.opts.repeat_opts.time
    end
    local after_finish = ujobinfo.opts.after_finish
    local buffered_stdout = {}
    local buffered_stderr = {}
    obj.jobinfo = vim.tbl_deep_extend("force", TermNode.jobinfo, ujobinfo, {
        opts = {
            before_start = function(node)
                if ujobinfo.opts.before_start then
                    pmsgcall(ujobinfo.opts.before_start, node)
                end
            end,
            on_stdout = function(jobid, data, event, node)
                log_notify("15scroll")
                buffered_stdout = vim.list_extend(buffered_stdout, data)
                pmsgcall(scroll)
                log_notify("16try TermNode.jobinfo.on_stdout")
                if TermNode.jobinfo.opts.on_stdout then
                    pmsgcall(TermNode.jobinfo.opts.on_stdout, jobid, data, event, node)
                end
                log_notify("17try ujobinfo.on_stdout")
                if ujobinfo.opts.on_stdout then
                    pmsgcall(ujobinfo.opts.on_stdout, jobid, data, event, node)
                end
            end,
            on_stderr = function(jobid, data, event, node)
                log_notify("18scroll")
                buffered_stderr = vim.list_extend(buffered_stderr, data)
                pmsgcall(scroll)
                log_notify("19try TermNode.jobinfo.on_stderr")
                if TermNode.jobinfo.opts.on_stderr then
                    pmsgcall(TermNode.jobinfo.opts.on_stderr, jobid, data, event, node)
                end
                log_notify("20trp ujobinfo.on_stderr")
                if ujobinfo.opts.on_stderr then
                    pmsgcall(ujobinfo.opts.on_stderr, jobid, data, event, node)
                end
            end,
            on_exit = function(jobid, code, event, node)
                log_notify("2try TermNode.on_exit")
                if TermNode.jobinfo.opts.on_exit then
                    pmsgcall(TermNode.jobinfo.opts.on_exit, jobid, code, event, node)
                end
                log_notify("3try ujobinfo.on_exit")
                if ujobinfo.opts.on_exit then
                    pmsgcall(ujobinfo.opts.on_exit, jobid, code, event, node)
                end
                if node.repeat_left_times and node.repeat_left_times > 0 then
                    node.repeat_left_times = node.repeat_left_times - 1
                end
                local repeat_opts = node.jobinfo.opts.repeat_opts
                local finished = not repeat_opts or node.repeat_left_times == 0
                if not finished then
                    assert(repeat_opts and node.repeat_left_times > 0)
                    local ok, result =
                        pmsgcall(repeat_opts.stop_cond, code, buffered_stdout, buffered_stderr)
                    if ok and result == true then
                        finished = true
                    end
                end
                if finished then
                    log_notify("1try after_finish")
                    if after_finish then
                        pmsgcall(after_finish, jobid, code, node)
                    end
                else
                    assert(repeat_opts and node.repeat_left_times > 0)
                    local timer = vim.uv.new_timer()
                    if timer then
                        node.repeat_timer = timer
                        timer:start(1000 * repeat_opts.timeinterval, 0, function()
                            vim.schedule(function()
                                log_notify("4restart")
                                panelbufcxt:restart(obj)
                            end)
                        end)
                    end
                end
            end,
            on_start = function(...)
                log_notify("5clear stdout/stderr buffer")
                buffered_stdout = {}
                buffered_stderr = {}
                log_notify("6try TermNode.on_start")
                if TermNode.jobinfo.opts.on_start then
                    pmsgcall(TermNode.jobinfo.opts.on_start, ...)
                end
                log_notify("7try ujobinfo.on_start")
                if ujobinfo.opts.on_start then
                    pmsgcall(ujobinfo.opts.on_start, ...)
                end
            end,
        },
    })
    setmetatable(obj, self)
    if startnow then
        obj:start()
    end
    return obj
end

function TermNode:restart(reset_repeat)
    self:clean()
    if reset_repeat then
        if self.jobinfo.opts and self.jobinfo.opts.repeat_opts then
            self.repeat_left_times = self.jobinfo.opts.repeat_opts.time
        end
        if self.repeat_timer then
            self.repeat_timer:stop()
            self.repeat_timer:close()
        end
    end
    self:start()
end
local function jobstop(jobid)
    vim.fn.jobstop(jobid)
    local ok, pid = pcall(vim.fn.jobpid, jobid)
    if ok then
        vim.defer_fn(function()
            local is_running = vim.uv.kill(pid, 0) == 0
            if is_running then
                vim.uv.kill(pid, 9)
            end
            vim.defer_fn(function()
                local still_running = vim.uv.kill(pid, 0) == 0
                if still_running then
                    vim.notify(
                        ("[term]: jobid:%s,pid:%s is still running after kill-9"):format(
                            tostring(jobid),
                            tostring(pid)
                        )
                    )
                end
            end, 3000)
        end, 3000)
    end
end

function TermNode:clean()
    if self.jobinfo.jobid ~= -1 then
        jobstop(self.jobinfo.jobid)
    end
    self.jobinfo.jobid = -1
    if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
    end
end

---@return boolean true=>success
function TermNode:start()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local success
    local jobid
    vim.api.nvim_buf_call(bufnr, function()
        local opts = next(self.jobinfo.opts) ~= nil and self.jobinfo.opts or nil
        local ok, result
        local on_start
        local before_start
        if opts then
            local on_exit = opts.on_exit
            local on_stdout = opts.on_stdout
            local on_stderr = opts.on_stderr
            on_start = opts.on_start
            opts.on_start = nil
            before_start = opts.before_start
            opts.before_start = nil
            opts.on_exit = on_exit
                    and function(job_id, code, event)
                        on_exit(job_id, code, event, self)
                    end
                or nil
            opts.on_stdout = on_stdout
                    and function(job_id, data, event)
                        on_stdout(job_id, data, event, self)
                    end
                or nil
            opts.on_stderr = on_stderr
                    and function(job_id, data, event)
                        on_stderr(job_id, data, event, self)
                    end
                or nil
            if before_start then
                before_start(self)
            end
            ok, result = pcall(vim.fn.jobstart, self.jobinfo.cmds, opts)
            opts.on_start = on_start
            opts.before_start = before_start
        else
            ok, result = pcall(vim.fn.jobstart, self.jobinfo.cmds)
        end
        if ok and result ~= 0 and result ~= -1 then
            success = true
            jobid = result
            if on_start then
                on_start(jobid, self)
            end
        else
            success = false
            vim.notify(
                "[terminal]: create terminal error:" .. tostring(result),
                vim.log.levels.ERROR
            )
        end
    end)
    if success then
        self._setupbuf(bufnr)
        self.bufnr = bufnr
        self.jobinfo.jobid = jobid
    end
    return success
end

---@return string
function TermNode:_display()
    return " " .. self.name
end

---@class GroupNode :NNode
---@field classname string
---@field children NNode[]
---@field expanded boolean
local GroupNode = {
    expanded = true,
    classname = "GroupNode",
    name = "GroupNode",
}
GroupNode.__index = GroupNode
setmetatable(GroupNode, Node)

---@generic T : GroupNode
---@param self T
---@param newnode_opts newnode_opts
---@return T
function GroupNode:new(newnode_opts)
    local obj = Node._new(self, newnode_opts)
    setmetatable(obj, self)
    obj.children = {}
    obj.new = unreachable
    return obj
end

function GroupNode:_display()
    return (self.expanded and "" or "") .. " " .. self.name
end

---@param on? boolean
---@return boolean
---true for changed
function GroupNode:toggle_expand(on)
    if on == nil then
        self.expanded = not self.expanded
        return true
    elseif self.expanded ~= on then
        self.expanded = on
        return true
    end
    return false
end

function GroupNode:restart(reset_repeat)
    for _, child in ipairs(self.children) do
        child:restart(reset_repeat)
    end
end

---@return boolean
---true=>swap occured and success
function GroupNode:swap(node, offset)
    assert(offset ~= 0)
    local swap_idx
    for i, child in ipairs(self.children) do
        if child == node then
            swap_idx = i
            break
        end
    end
    assert(type(swap_idx) == "number")
    local swapped_idx = swap_idx + offset
    if swapped_idx < 1 then
        swapped_idx = 1
    elseif swapped_idx > #self.children then
        swapped_idx = #self.children
    end
    if swapped_idx > swap_idx then
        swap_idx, swapped_idx = swapped_idx, swap_idx
    end

    if swapped_idx ~= swap_idx then
        --swapped_idx < swap_idx
        -- nil? x y nil?
        -- a b c d
        if swapped_idx + 1 == swap_idx then --相邻
            local a = self.children[swapped_idx - 1]
            local c = self.children[swapped_idx + 1]
            local b = self.children[swap_idx - 1]
            local d = self.children[swap_idx + 1]
            assert(b == self.children[swapped_idx])
            assert(c == self.children[swap_idx])
            if a then
                a.next = c
            end
            c.prev = a
            c.next = b
            b.prev = c
            b.next = d
            if d then
                d.prev = b
            end
        else
            --xp x xn...yp y yn
            local xp = self.children[swapped_idx - 1]
            local x = self.children[swapped_idx]
            local xn = self.children[swapped_idx + 1]
            local yp = self.children[swap_idx - 1]
            local y = self.children[swap_idx]
            local yn = self.children[swap_idx + 1]
            if xp then
                xp.next = y
            end
            assert(yp ~= nil)
            assert(xn ~= nil)
            x.prev = yp
            x.next = yn
            xn.prev = y
            yp.next = x
            y.prev = xp
            y.next = xn
            if yn then
                yn.prev = x
            end
        end

        self.children[swap_idx], self.children[swapped_idx] =
            self.children[swapped_idx], self.children[swap_idx]
        return true
    end
    return false
end

---@param node NNode
function GroupNode:addnode(node)
    node.parent = self
    node.prev = self.children[#self.children]
    if self.children[#self.children] then
        self.children[#self.children].next = node
    end
    self.children[#self.children + 1] = node
end

function GroupNode:clean()
    for _, child in ipairs(self.children) do
        child:clean()
    end
end

---@param node NNode
function GroupNode:delnode(node)
    if node.prev then
        node.prev.next = node.next
    end
    if node.next then
        node.next.prev = node.prev
    end
    for pos, child in ipairs(self.children) do
        if child == node then
            table.remove(self.children, pos):clean()
            return
        end
    end
    unreachable()
end

---@class TaskTermNode:TermNode
---@field status "uninit"|"waitting"|"running"|"error_retry_pending"|"success_retry_pending"|"error"|"success"
local TaskTermNode = {
    classname = "TaskTermNode",
    name = "TaskTermNode",
    status = "uninit",
}
TaskTermNode.__index = TaskTermNode
setmetatable(TaskTermNode, TermNode)
local taskterm_icons = {
    uninit = "?",
    waitting = "",
    running = "",
    error = "",
    success = "",
    success_retry_pending = "",
    error_retry_pending = "",
}
---@param newnode_opts newnode_opts
---@param ujobinfo ujobinfo
---@param startnow? boolean default false
---jobinfo:param>TaskTermNode>TermNode
---func: scroll,TermNode,(status,TaskTermNode,param) ...(repeat) after_finish
function TaskTermNode:new(newnode_opts, ujobinfo, startnow)
    ---@type ujobinfo
    ---@diagnostic disable-next-line: assign-type-mismatch
    local jobinfo = vim.tbl_deep_extend("force", TaskTermNode.jobinfo, ujobinfo, {
        opts = {
            before_start = function(...)
                if TaskTermNode.jobinfo.opts.before_start then
                    pmsgcall(TaskTermNode.jobinfo.opts.before_start, ...)
                end
                if ujobinfo.opts.before_start then
                    pmsgcall(ujobinfo.opts.before_start, ...)
                end
            end,
            on_start = function(jobid, node)
                self.status = "running"
                log_notify("8try TaskTermNode.on_start")
                if TaskTermNode.jobinfo.opts.on_start then
                    pmsgcall(TaskTermNode.jobinfo.opts.on_start, jobid, node)
                end
                log_notify("9try ujobinfo.on_start")
                if ujobinfo.opts.on_start then
                    pmsgcall(ujobinfo.opts.on_start, jobid, node)
                end
            end,
            on_stderr = function(...)
                log_notify("21try TaskTermNode.on_stderr")
                if TaskTermNode.jobinfo.opts.on_stderr then
                    pmsgcall(TaskTermNode.jobinfo.opts.on_stderr, ...)
                end
                log_notify("22try ujobinfo.on_stderr")
                if ujobinfo.opts.on_stderr then
                    pmsgcall(ujobinfo.opts.on_stderr, ...)
                end
            end,
            on_stdout = function(...)
                log_notify("23try TaskTermNode.on_stdout")
                if TaskTermNode.jobinfo.opts.on_stdout then
                    pmsgcall(TaskTermNode.jobinfo.opts.on_stdout, ...)
                end
                log_notify("24try ujobinfo.on_stdout")
                if ujobinfo.opts.on_stdout then
                    pmsgcall(ujobinfo.opts.on_stdout, ...)
                end
            end,
            on_exit = function(jobid, code, event, node)
                log_notify("10try TaskTermNode.on_exit")
                if TaskTermNode.jobinfo.opts.on_exit then
                    pmsgcall(TaskTermNode.jobinfo.opts.on_exit, jobid, code, event, node)
                end
                log_notify("11try ujobinfo.on_exit")
                if ujobinfo.opts.on_exit then
                    pmsgcall(ujobinfo.opts.on_exit, jobid, code, event, node)
                end
                assert(node.classname == "TaskTermNode")
                if code == 0 then
                    node.status = "success_retry_pending"
                else
                    node.status = "error_retry_pending"
                end
                PanelBufFullUpdate()
            end,
            after_finish = function(jobid, code, node)
                if node.status == "success_retry_pending" then
                    node.status = "success"
                else
                    node.status = "error"
                end
                if ujobinfo.opts.after_finish then
                    pmsgcall(ujobinfo.opts.after_finish, jobid, code, node)
                end
                PanelBufFullUpdate()
            end,
        },
    })
    local obj = TermNode.new(self, newnode_opts, jobinfo, false)
    setmetatable(obj, self)
    obj.new = unreachable
    obj.status = "waitting"
    if startnow then
        obj:start()
    end
    PanelBufFullUpdate()
    return obj
end

---override
---@return string
function TaskTermNode:_display()
    return taskterm_icons[self.status] .. " " .. self.name
end

---override
function TaskTermNode:restart(reset_repeat)
    self:clean()
    self.status = "waitting"
    if reset_repeat then
        if self.jobinfo.opts and self.jobinfo.opts.repeat_opts then
            self.repeat_left_times = self.jobinfo.opts.repeat_opts.time
        end
        if self.repeat_timer then
            self.repeat_timer:stop()
            self.repeat_timer:close()
        end
    end
    self:start()
end

---override
function TaskTermNode:start()
    if not TermNode.start(self) then
        vim.notify("TermNode start error", ERROR)
        return
    end
    PanelBufFullUpdate()
end

---@class TaskSetNode :GroupNode
---@field status "uninit"|"waitting"|"running"|"error"|"success"
---@field seq boolean
---@field break_on_err boolean
---@field tasks {name:string,jobinfo:ujobinfo,bg:boolean|nil,ignore_error:boolean|nil}[]
---@field children TaskTermNode[]
---@field expanded boolean
---@field after_finish_all fun()
local TaskSetNode = {
    classname = "TaskSetNode",
    name = "TaskSetNode",

    status = "uninit",
    seq = true,
    break_on_err = true,
    tasks = {},
    children = {},
    expanded = true,
    after_finish_all = function() end,
}
TaskSetNode.__index = TaskSetNode
setmetatable(TaskSetNode, GroupNode)
---@param newnode_opts newnode_opts
---@param tasks {name:string,jobinfo:ujobinfo,ignore_err:boolean,bg:boolean}[]
---@param seq boolean default true
---@param break_on_err boolean default true
---@param after_finish_all fun()
---after_finish_all: TaskSetNode,status,param
function TaskSetNode:new(newnode_opts, tasks, seq, break_on_err, after_finish_all, startnow)
    local obj = GroupNode.new(self, newnode_opts)
    setmetatable(obj, self)
    obj.addnode = unreachable
    obj.delnode = unreachable
    obj.tasks = tasks
    obj.seq = seq or true
    obj.break_on_err = break_on_err or true
    obj.status = "waitting"

    obj.after_finish_all = function()
        log_notify("12tasksetnode after_finish_all")
        --Class
        if TaskSetNode.after_finish_all then
            TaskSetNode.after_finish_all()
        end
        --Program
        local success = true
        for _, child in ipairs(obj.children) do
            if child.status ~= "success" then
                success = false
                break
            end
        end
        obj.status = success == true and "success" or "error"
        PanelBufFullUpdate()
        --Self
        if after_finish_all then
            after_finish_all()
        end
    end
    if startnow then
        obj:start()
    end
    return obj
end

function TaskSetNode:_display()
    return "" .. " " .. self.name
end

function TaskSetNode:clean()
    for _, child in ipairs(self.children) do
        child:clean()
        child.status = "waitting"
    end
end

function TaskSetNode:restart(reset_repeat)
    self:clean()
    self.status = "waitting"
    for _, child in ipairs(self.children) do
        if reset_repeat and child.jobinfo.opts and child.jobinfo.opts.repeat_opts then
            child.repeat_left_times = child.jobinfo.opts.repeat_opts.time
        end
    end
    if self._handles == nil then
        vim.notify("You cannot restart a node which has not been started once", ERROR)
        return
    end
    for _, f in ipairs(self._handles) do
        f()
    end
end

function TaskSetNode:start()
    if self._handles ~= nil then
        return
    end
    local chk_all_finished = function()
        for _, child in ipairs(self.children) do
            if child.status ~= "success" and child.status ~= "error" then
                return
            end
        end
        self.after_finish_all()
    end
    local chk_started_finished = function()
        for _, child in ipairs(self.children) do
            if
                child.status == "running"
                or child.status == "error_retry_pending"
                or child.status == "success_retry_pending"
            then
                return
            end
        end
        self.after_finish_all()
    end
    if self.seq then
        local handle_stack = {}
        for i = #self.tasks, 1, -1 do
            local task = self.tasks[i]
            local after_finish
            if task.bg then
                after_finish = function(_, code, _)
                    log_notify("13TaskSetNode.start after_finish")
                    if self.break_on_err == false or code == 0 or task.ignore_error then
                        chk_all_finished()
                    else
                        chk_started_finished()
                    end
                end
            else
                local nexts = handle_stack
                handle_stack = {}
                after_finish = function(_, code, _)
                    log_notify("14TaskSetNode.start after_finish")
                    if self.break_on_err == false or code == 0 or task.ignore_error then
                        for _, nxt in ipairs(nexts) do
                            nxt()
                        end
                        chk_all_finished()
                    else --break
                        chk_started_finished()
                    end
                end
            end
            local _after_finish = self.tasks[i].jobinfo.opts.after_finish
            self.tasks[i].jobinfo.opts.after_finish = function(...)
                after_finish(...)
                if _after_finish then
                    _after_finish(...)
                end
            end
            local node = TaskTermNode:new({
                name = self.tasks[i].name,
                parent = self,
            }, self.tasks[i].jobinfo, false)
            self.children[i] = node
            table.insert(handle_stack, function()
                node:start()
            end)
        end
        self._handles = handle_stack
    else
        local handles = {}
        for i, task in ipairs(self.tasks) do
            local _after_finish = task.jobinfo.opts.after_finish
            task.jobinfo.opts.after_finish = function(...)
                if _after_finish then
                    _after_finish(...)
                end
                chk_all_finished()
            end
            local node = TaskTermNode:new({ name = task.name, parent = self }, task.jobinfo, false)
            self.children[i] = node
            handles[#handles + 1] = function()
                node:start()
            end
        end
        self._handles = handles
    end
    for i, child in ipairs(self.children) do
        child.prev = self.children[i - 1]
        child.next = self.children[i + 1]
    end
    for _, handle in ipairs(self._handles) do
        handle()
    end
    self.status = "running"
    PanelBufFullUpdate()
end

--append_default
function panelbufcxt:get_termbuf()
    if not self._curnode or not vim.api.nvim_buf_is_valid(self._curnode.bufnr) then
        return self:get_fallback_termbufnr()
    end
    local curnode = self._curnode
    ---@cast curnode TaskTermNode|TermNode
    return curnode.bufnr
end

--
---@param node NNode
---@param parent? GroupNode default self.root
---@return NNode
function panelbufcxt:addnode(node, parent)
    parent = parent or self.root
    assert(parent ~= nil)
    parent:addnode(node)
    if self._curnode == nil then
        local target_curnode = find_valid_curnode(node)
        if target_curnode then
            self._curnode = target_curnode
        end
    end
    self._cursornode = self._cursornode or node
    assert(self._cursornode)
    PanelBufFullUpdate()
    TermWinBufUpdate()
    return node
end

--_switch_curnode,set_cursor
function panelbufcxt:delnode(delnode)
    if delnode.prev == nil and delnode.next == nil then
        vim.notify("cannot delete last node of group", ERROR)
        return
    end
    if delnode.parent.classname == "TaskSetNode" then
        vim.notify("You cannot delete a node belong to TaskSetNode", ERROR)
        return
    end
    assert(delnode.parent.classname == "GroupNode")
    local cur_in_children = self._curnode:parents_has(delnode)
    local cursor_in_children = self._cursornode:parents_has(delnode)
    if delnode == self._curnode or cur_in_children then
        local curnode = delnode.next or delnode.prev
        if curnode.classname == "TaskSetNode" then
            ---@cast curnode TaskSetNode
            curnode = curnode.children[1]
        elseif curnode.classname == "GroupNode" then
            assert(false, "unimplement")
        end
        self._curnode = curnode
        assert(verify_valid_curnode(self._curnode))
        TermWinBufUpdate()
    end
    if delnode == self._cursornode or cursor_in_children then
        self._cursornode = delnode.next or delnode.prev
        assert(self._cursornode)
    end
    delnode.parent:delnode(delnode)
    PanelBufFullUpdate()
end

function panelbufcxt:switch(n)
    if n == nil then
        vim.notify("You cannot switch curnode to nil", vim.log.levels.ERROR)
        return
    end
    --For GroupNode,switch to it's first child
    if n.classname == "GroupNode" or n.classname == "TaskSetNode" then
        ---@cast n GroupNode|TaskSetNode
        if #n.children ~= 0 then
            local target_curnode = find_valid_curnode(n)
            if target_curnode then
                self:switch(target_curnode)
            end
        end
        return
    end
    ---@cast n TermNode|TaskTermNode
    ---@type GroupNode|TaskSetNode
    local cur = n.parent
    local changed = false
    if cur.parent then
        repeat
            changed = changed or cur:toggle_expand(true)
            cur = cur.parent
        until cur == nil
    end
    local ok, msg = verify_valid_curnode(n)
    if not ok then
        vim.notify("[terminal]: switch error: " .. msg, ERROR)
        return
    end
    self._curnode = n
    if changed then
        PanelBufFullUpdate()
    else
        PanelCurHLUpdate()
        TermWinBufUpdate()
    end
end

--alias _addnode
function panelbufcxt:append_term_node(parent, name, ujobinfo, unique_key)
    local node = TermNode:new({ name = name, parent = parent }, ujobinfo, true)
    self:addnode(node)
    if unique_key then
        if self.unique_map[unique_key] then
            self:delnode(self.unique_map[unique_key])
        end
        self.unique_map[unique_key] = node
    end
    return node
end

--alias _addnode
function panelbufcxt:append_taskterm_node(parent, name, ujobinfo, unique_key)
    local node = TaskTermNode:new({ name = name, parent = parent }, ujobinfo, true)
    self:addnode(node)
    if unique_key then
        if self.unique_map[unique_key] then
            self:delnode(self.unique_map[unique_key])
        end
        self.unique_map[unique_key] = node
    end
    return node
end

--alias _addnode
function panelbufcxt:append_tasktermset_node(
    parent,
    name,
    tasks,
    unique_key,
    seq,
    break_on_err,
    after_finish_all
)
    local node = TaskSetNode:new(
        { name = name, parent = parent },
        tasks,
        seq,
        break_on_err,
        after_finish_all,
        true
    )
    self:addnode(node)
    if unique_key then
        if self.unique_map[unique_key] then
            self:delnode(self.unique_map[unique_key])
        end
        self.unique_map[unique_key] = node
    end
    return node
end

--alias _addnode
function panelbufcxt:append_default(parent)
    local cmds
    if jit.os == "Windows" then
        cmds = { "pwsh", "-nologo" }
    else
        cmds = { vim.o.shell }
    end
    return self:append_term_node(parent, vim.fs.basename(cmds[1]), { cmds = cmds, opts = {} })
end

--alias _addnode
function panelbufcxt:append_userinput(parent)
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
        return self:append_term_node(parent, cmds[1], { cmds = cmds, opts = {} })
    end
end

---@param node GroupNode|TaskSetNode
---@param on? boolean
function panelbufcxt:toggle_expand(node, on)
    if node:toggle_expand(on) then
        if self._cursornode:parents_has(node) then
            self._cursornode = node
            assert(self._cursornode)
        end
        PanelBufFullUpdate()
    end
end

---@param node NNode
---@param offset number
function panelbufcxt:swap(offset, node)
    if node.parent:swap(node, offset) then
        PanelBufFullUpdate()
    end
end

---@param node NNode
---@param name string|nil
function panelbufcxt:rename(node, name)
    if not name then
        vim.ui.input({ prompt = "[Terminal] Enter name: " }, function(input)
            if not input or input == "" then
                vim.notify("[terminal]: Terminal name cannot be empty", vim.log.levels.ERROR)
                return
            end
            assert(type(input) == "string")
            node:rename(input)
            PanelBufFullUpdate()
        end)
    else
        node:rename(name)
        PanelBufFullUpdate()
    end
end

--switch,set_cursor
---@param node NNode
---@param reset_repeat? boolean
function panelbufcxt:restart(node, reset_repeat)
    if node.classname == "TaskSetNode" or node.classname == "GroupNode" then
        ---@cast node TaskTermNode|GroupNode
        local cur_in_children = self._curnode:parents_has(node)
        local old_curnode = self._curnode
        if cur_in_children then
            self._curnode = nil
            TermWinBufUpdate()
        end
        ---@cast node GroupNode|TaskSetNode
        node:restart(reset_repeat)
        if cur_in_children then
            if
                old_curnode.bufnr
                and vim.api.nvim_buf_is_valid(old_curnode.bufnr)
                and self._curnode == nil
            then
                self._curnode = old_curnode
                TermWinBufUpdate()
            else
                local target_curnode = find_valid_curnode(node)
                assert(target_curnode)
                if self._curnode == nil then
                    self._curnode = target_curnode
                    TermWinBufUpdate()
                end
            end
        end
    else
        ---@cast node TaskTermNode|TermNode
        local cur_eq_delnode = self._curnode == node
        local old_curnode = self._curnode
        if cur_eq_delnode then
            self._curnode = nil
            TermWinBufUpdate()
        end
        node:restart(reset_repeat)
        if cur_eq_delnode then
            if
                old_curnode.bufnr
                and vim.api.nvim_buf_is_valid(old_curnode.bufnr)
                and self._curnode == nil
            then
                self._curnode = old_curnode
                TermWinBufUpdate()
            end
        end
    end
    PanelBufFullUpdate()
    TermWinBufUpdate() --当cur in children or cur == node时
end

---@param node NNode
function panelbufcxt:toggle_pin(node)
    node.pinned = not node.pinned
    PanelBufFullUpdate()
end

function panelbufcxt:update_displayed_data()
    local displayed_data = { lines = {} }
    local max_width = 0
    ---@param n NNode
    ---@param depth number
    local function walkroll(n, depth)
        local index = #displayed_data + 1
        local str = string.rep("│ ", depth - 1)
            .. string.rep((n.next == nil) and "└ " or "│ ", (depth > 0) and 1 or 0)
            .. n:_display()
        max_width = math.max(max_width, vim.fn.strdisplaywidth(str))
        displayed_data[index] = {
            str = str,
            node = n,
        }
        displayed_data[n] = {
            index = index,
            str = str,
        }
        displayed_data.lines[index] = str
        if n.classname == "GroupNode" or n.classname == "TaskSetNode" then
            ---@cast n GroupNode|TaskSetNode
            if n.expanded == true then
                for _, child in ipairs(n.children) do
                    walkroll(child, depth + 1)
                end
            end
        end
    end
    for _, n in ipairs(self.root.children) do
        walkroll(n, 0)
    end
    for idx, _ in ipairs(displayed_data) do
        local str = displayed_data.lines[idx]
            .. string.rep(" ", max_width - vim.fn.strdisplaywidth(displayed_data.lines[idx]))
        displayed_data.lines[idx] = str
        displayed_data[idx].str = str
        displayed_data[displayed_data[idx].node].str = str
    end
    displayed_data.width = max_width
    self.displayed_data = displayed_data
end

function panelbufcxt:update_panelbuf_curnode_hl()
    if self.panel_buf_hl_curnode_clearfunc then
        self.panel_buf_hl_curnode_clearfunc()
    end
    local curnode = self._curnode
    local curnodedata = self.displayed_data[curnode]
    if curnodedata then --curnode不被折叠时高亮
        local curindex = curnodedata.index
        local curnode_clearfunc = hlline(self:get_panel_bufnr(), curindex, "TermCurIndex")
        self.panel_buf_hl_curnode_clearfunc = curnode_clearfunc
    end
end

function panelbufcxt:_update_panelbuf_cursornode_hl()
    if self.panel_buf_hl_cursornode_clearfunc then
        self.panel_buf_hl_cursornode_clearfunc()
    end
    if
        vim.api.nvim_get_current_buf() == self:get_panel_bufnr()
        and self._cursornode ~= self._curnode
    then
        local cursor_index = self.displayed_data[self._cursornode].index
        local cursornode_clearfunc = hlline(self:get_panel_bufnr(), cursor_index, "TermCursorLine")
        self.panel_buf_hl_cursornode_clearfunc = cursornode_clearfunc
    end
end

local function create_fallback_termbuf()
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
    return bufnr
end
local function create_panelbuf()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].buflisted = false
    assert(bufnr and vim.api.nvim_buf_is_valid(bufnr))
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].buftype = "nofile"
    vim.bo[bufnr].filetype = "TerminalPanel"
    vim.api.nvim_buf_set_name(bufnr, "TerminalPanel")
    setup_keymap_panel(bufnr)
    return bufnr
end
--Root,Panelbuf,[CursorMoved->setcursor],[WinLeave->clearCursorHL]
function panelbufcxt:_init()
    if self.__inited then
        return
    end
    self.__inited = true
    --Root
    self.root = GroupNode:new { name = "Root" }
end
function panelbufcxt:get_fallback_termbufnr()
    if validbuf(self.fallback_term_bufnr) then
        return self.fallback_term_bufnr
    end
    self.fallback_term_bufnr = create_fallback_termbuf()
    return self.fallback_term_bufnr
end
function panelbufcxt:get_panel_bufnr()
    if validbuf(self.bufnr) then
        return self.bufnr
    end
    if self.bufnr and vim.fn.bufexists(self.bufnr) then
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
    end
    self.bufnr = create_panelbuf()
    vim.api.nvim_create_augroup("tools.terminal.panelbufcxt", { clear = true })
    --CursorMoved->setcursor
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = "tools.terminal.panelbufcxt",
        buffer = self.bufnr,
        callback = function()
            local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
            self._cursornode = self.displayed_data[row].node
            assert(self._cursornode)
            PanelCurSorHLUpdate()
        end,
    })
    --Leave清除Cursor高亮
    vim.api.nvim_create_autocmd("WinLeave", {
        group = "tools.terminal.panelbufcxt",
        pattern = "TerminalPanel",
        callback = function()
            if self.panel_buf_hl_cursornode_clearfunc then
                self.panel_buf_hl_cursornode_clearfunc()
            end
            self.panel_buf_hl_cursornode_clearfunc = nil
        end,
    })
    PanelBufFullUpdate()
    return self.bufnr
end

---@param bufnr number
function winmanager:_bind_buf_to_termwin(bufnr)
    vim.wo[self.term_winid].winfixbuf = false
    vim.api.nvim_win_set_buf(self.term_winid, bufnr)
    vim.wo[self.term_winid].winfixbuf = true
end

---@param bufnr number
function winmanager:_bind_buf_to_panelwin(bufnr)
    assert(
        vim.api.nvim_win_is_valid(self.panel_winid)
            and vim.api.nvim_buf_is_valid(bufnr)
            and vim.api.nvim_buf_is_loaded(bufnr)
    )
    vim.wo[self.panel_winid].winfixbuf = false
    vim.api.nvim_win_set_buf(self.panel_winid, bufnr)
    vim.wo[self.panel_winid].winfixbuf = true
end

function winmanager:_default_height()
    return math.floor(vim.o.lines / 3)
end

---@return boolean
function winmanager:_is_opened()
    if self.term_winid and not vim.api.nvim_win_is_valid(self.term_winid) then
        assert(false)
    end
    if self.panel_winid and not vim.api.nvim_win_is_valid(self.panel_winid) then
        assert(false)
    end

    return self.term_winid
        and self.panel_winid
        and vim.api.nvim_win_is_valid(self.term_winid)
        and vim.api.nvim_win_is_valid(self.panel_winid)
end

---@return boolean
function winmanager:_is_focused()
    local curwin = vim.api.nvim_get_current_win()

    return curwin == self.term_winid or curwin == self.panel_winid
end

function winmanager:focus()
    if not self:_is_opened() then
        self:open()
    end
    vim.api.nvim_set_current_win(self.term_winid)
end

---@param winid number
function winmanager._set_win_minimal(winid)
    for option, value in pairs {
        number = false,
        relativenumber = false,
        foldcolumn = "0",
        signcolumn = "no",
        statuscolumn = "",
        spell = false,
        list = false,
    } do
        vim.wo[winid][option] = value
    end
end

--panelbufcxt必须inited且有curnode
function winmanager:open()
    if #panelbufcxt.root.children == 0 then
        panelbufcxt:append_default()
    end
    if not self:_is_opened() then
        local origin_win = vim.api.nvim_get_current_win()
        vim.cmd("botright " .. self:_default_height() .. "split")
        self.term_winid = vim.api.nvim_get_current_win()
        vim.cmd(panel_default_width() .. "vsplit")
        self.panel_winid = vim.api.nvim_get_current_win()
        --SetupTermWin
        self._set_win_minimal(self.term_winid)
        vim.api.nvim_win_set_hl_ns(self.term_winid, ns)
        local termbuf = panelbufcxt:get_termbuf()
        assert(termbuf and vim.api.nvim_buf_is_valid(termbuf))
        self:_update_termwin_bindbuf()
        --SetupPanelWin
        self._set_win_minimal(self.panel_winid)
        vim.api.nvim_win_set_hl_ns(self.panel_winid, ns)
        self:_bind_buf_to_panelwin(panelbufcxt:get_panel_bufnr())
        vim.api.nvim_set_current_win(origin_win)
    end
    self:_setup_whenopen_autocmds()
end

function winmanager:close()
    assert(self.term_winid and vim.api.nvim_win_is_valid(self.term_winid))
    assert(self.panel_winid and vim.api.nvim_win_is_valid(self.panel_winid))
    if self.term_winid and vim.api.nvim_win_is_valid(self.term_winid) then
        vim.api.nvim_win_close(self.term_winid, true)
        self.term_winid = nil
    end
    if self.panel_winid and vim.api.nvim_win_is_valid(self.panel_winid) then
        vim.api.nvim_win_close(self.panel_winid, true)
        self.panel_winid = nil
    end
    self:_clear_whenopen_autocmds()
end

function winmanager:toggle()
    if not self:_is_opened() then
        self:open()
        self:focus()
    elseif not self:_is_focused() then
        self:focus()
    else
        self:close()
    end
end

function winmanager:_setup_autocmds() end

--panelwin大小限制
--win同时关闭
function winmanager:_setup_whenopen_autocmds()
    vim.api.nvim_create_augroup("tools.terminal.whenopen", { clear = true })
    vim.api.nvim_create_autocmd("WinResized", {
        group = "tools.terminal.whenopen",
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                if win == self.panel_winid then
                    local panel_width = vim.api.nvim_win_get_width(self.panel_winid)
                    local default_width = panel_default_width()
                    if panel_width > default_width then
                        vim.api.nvim_win_set_width(self.panel_winid, default_width)
                    end
                end
            end
        end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        group = "tools.terminal.whenopen",
        pattern = table.concat({ self.term_winid, self.panel_winid }, ","),
        callback = function(_args)
            self:close()
        end,
    })
end

function winmanager:_clear_whenopen_autocmds()
    vim.api.nvim_clear_autocmds { group = "tools.terminal.whenopen" }
end

function winmanager:_update_termwin_bindbuf()
    if self:_is_opened() then
        local termbuf = panelbufcxt:get_termbuf()
        if termbuf then
            if vim.api.nvim_win_get_buf(self.term_winid) ~= termbuf then
                self:_bind_buf_to_termwin(termbuf)
            end
        end
    end
end

local M = {}
---winmanager.open+ panelbufcxt.append_default if len=0 / close
function M.toggle()
    winmanager:toggle()
end

---@param name  string
---@param ujobinfo ujobinfo
---@param focus boolean|nil
---default: focus=true
---panelbufcxt._append_term_node + M.toggle if focus
function M.newterm(name, ujobinfo, focus, switch, unique_key)
    local node = panelbufcxt:append_term_node(nil, name, ujobinfo, unique_key)
    if switch then
        panelbufcxt:switch(node)
    end
    winmanager:open()
    if focus then
        winmanager:focus()
    end
end

---@param name  string
---@param ujobinfo ujobinfo
---@param focus boolean|nil
---@param switch boolean|nil
---@param unique_key string|nil
---default: focus=true
---panelbufcxt._append_taskterm_node
function M.newtask(name, ujobinfo, focus, switch, unique_key)
    local validate = vim.validate
    validate("name", name, "string")
    validate("ujobinfo", ujobinfo, "table")
    validate("ujobinfo.cmds", ujobinfo.cmds, function(it)
        return type(it) == "string"
            or (type(it) == "table" and #it > 0 and vim.fn.executable(it[1]) == 1)
    end)
    validate("switch", switch, "boolean", true)
    validate("unique_key", unique_key, "string", true)
    local node = panelbufcxt:append_taskterm_node(nil, name, ujobinfo, unique_key)
    if switch then
        panelbufcxt:switch(node)
    end
    winmanager:open()
    if focus then
        winmanager:focus()
    end
end

---@param name string
---@param tasks {name:string,jobinfo:ujobinfo,bg:boolean|nil,ignore_error:boolean|nil}[]
---@param seq boolean|nil
---@param break_on_err boolean|nil
---@param focus boolean|nil
---@param after_finish_all fun()|nil
---@param unique_key string|nil
function M.newtaskset(name, tasks, seq, break_on_err, focus, switch, after_finish_all, unique_key)
    local node = panelbufcxt:append_tasktermset_node(
        nil,
        name,
        tasks,
        unique_key,
        seq,
        break_on_err,
        after_finish_all
    )
    if switch then
        panelbufcxt:switch(node)
    end
    winmanager:open()
    if focus then
        winmanager:focus()
    end
end

local function visual_selection()
    local mode = vim.fn.mode():byte()
    local line_start, column_start, line_end, column_end
    if mode == 118 then --v
        local pos = vim.fn.getpos("v")
        line_start, column_start = pos[2], pos[3]
        pos = vim.fn.getpos(".")
        line_end, column_end = pos[2], pos[3]
    elseif mode == 86 then --v line
        local pos = vim.fn.getpos("v")
        line_start, _ = pos[2], pos[3]
        pos = vim.fn.getpos(".")
        line_end, _ = pos[2], pos[3]
    else
        return false
    end
    if
        (vim.fn.line2byte(line_start) + (column_start or 0))
        > (vim.fn.line2byte(line_end) + (column_end or 0))
    then
        line_start, column_start, line_end, column_end =
            line_end, column_end, line_start, column_start
    end
    local lines = vim.fn.getline(line_start, line_end)
    if #lines == 0 then
        return ""
    end
    if mode == 118 then
        lines[#lines] = string.sub(lines[#lines], 1, column_end)
        lines[1] = string.sub(lines[1], column_start)
    end
    return lines
end

function M.send(lines, node)
    if node == nil then
        vim.notify("You can not send to nil", ERROR)
        return
    end
    local origin_win = vim.api.nvim_get_current_win()
    panelbufcxt:switch(node)
    winmanager:focus()
    vim.cmd.stopinsert()
    local old = vim.fn.getreginfo("a")
    vim.fn.setreg("a", table.concat(lines, "\n"), "c")
    vim.api.nvim_feedkeys('"ap', "n", false)
    vim.schedule(function()
        vim.fn.setreg("a", old.value, old.regtype)
        vim.fn.chansend(node.jobinfo.jobid, "\r")
        vim.fn.chansend(node.jobinfo.jobid, "\r")
        vim.api.nvim_set_current_win(origin_win)
    end)
    return true
end

function M.setup()
    require("tools.hl").register({
        TermCurIndex = { link = "CursorLine" },
        TermCursorLine = { link = "Visual" },
    }, { dependency = "outer<-inner", type = "colorscheme" })
    vim.keymap.set({ "n", "t", "v" }, "<M-`>", function()
        M.toggle()
    end)
    vim.keymap.set("v", "<cr>", function()
        if M.send(visual_selection(), panelbufcxt._curnode) then
            vim.cmd("normal! \28\14")
        end
    end)
    panelbufcxt:_init()
end

function M.reset()
    if winmanager:_is_opened() then
        winmanager:close()
    end
    if panelbufcxt.root then
        panelbufcxt.root:clean()
    end
    panelbufcxt.root = nil
    panelbufcxt._curnode = nil
    panelbufcxt._cursornode = nil
    panelbufcxt.displayed_data = nil
    if panelbufcxt.panel_buf_hl_curnode_clearfunc then
        panelbufcxt.panel_buf_hl_curnode_clearfunc()
    end
    panelbufcxt.panel_buf_hl_curnode_clearfunc = nil
    if panelbufcxt.panel_buf_hl_cursornode_clearfunc then
        panelbufcxt.panel_buf_hl_cursornode_clearfunc()
    end
    panelbufcxt.panel_buf_hl_cursornode_clearfunc = nil
    panelbufcxt.unique_map = {}
    local bufnr = panelbufcxt:get_panel_bufnr()
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
    bufnr = panelbufcxt:get_fallback_termbufnr()
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
    vim.api.nvim_create_augroup("tools.terminal.panelbufcxt", { clear = true })
    panelbufcxt.__inited = false
    M.setup()
end

return M
