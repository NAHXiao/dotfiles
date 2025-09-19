local Node = require("tools.term.node.node")
local utils = require("tools.term.utils")
local panel = require("tools.term.panel")
local pmsgcall = require("tools.term.utils").pmsgcall
---@param node TermNode
local function scroll(node)
    ---NOTE: vim.fn.jobwait Cannnot be used in interactive program,that will causes block
    -- local is_running = vim.fn.jobwait({ vim.b[].terminal_job_id, })[1] == -1
    if not node.auto_scroll then
        return
    end
    local is_running = vim.uv.kill(vim.b[node.bufnr].terminal_job_pid, 0) == 0
    local winid = panel.get_termwin()
    local is_focused = vim.api.nvim_get_current_buf() == node.bufnr
        and vim.api.nvim_get_current_win() == winid
    if winid ~= nil and is_running and not is_focused then
        vim.api.nvim_win_call(winid, function()
            local last = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(winid))
            vim.api.nvim_win_set_cursor(winid, { last, 0 })
        end)
    end
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
                        ("[Terminal]: jobid:%s,pid:%s is still running after kill-9"):format(
                            tostring(jobid),
                            tostring(pid)
                        )
                    )
                end
            end, 3000)
        end, 3000)
    end
end
local function onBufNrChanged(node)
    local curnode = panel.get_cur_node()
    if curnode == node then
        panel.update_termwinbuf()
    end
end
---@class TermNode : NNode
---@field auto_scroll boolean
---@field bufnr number
---@field jobinfo jobinfo
---@field _setupbuf fun(bufnr)
---@field repeat_left_times? number
---@field repeat_timer? uv.uv_timer_t
---@field cleaning boolean
local TermNode = {
    classname = "TermNode",
    name = "TermNode",

    auto_scroll = true,

    bufnr = -1,
    jobinfo = { opts = { term = true, detach = false }, jobid = -1 },
    repeat_left_times = nil,
    repeat_timer = nil,
}
TermNode.__index = TermNode
setmetatable(TermNode, Node)
---@private
function TermNode:setup_termbuf()
    local bufnr = self.bufnr
    vim.bo[bufnr].filetype = "TerminalBuf"
    vim.bo[bufnr].buflisted = false
    vim.api.nvim_create_autocmd("BufEnter", {
        buffer = bufnr,
        callback = function()
            vim.schedule(function()
                if self.bufnr ~= bufnr then
                    return
                end
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
                if self.bufnr ~= bufnr then
                    return
                end
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
    vim.api.nvim_create_autocmd("BufUnload", {
        buffer = bufnr,
        callback = function()
            if not self.cleaning then --用户强制删除buffer
                vim.schedule(function()
                    if self.parent then
                        self.parent:delnode(self)
                    end
                end)
            end
        end,
    })
    local keymaps = require("tools.term.keymaps").termbuf
    require("tools.term.keymaps").map(keymaps, self, bufnr)
end

---static
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
                pmsgcall(ujobinfo.opts.before_start, node)
            end,
            on_stdout = function(jobid, data, event, node)
                buffered_stdout = vim.list_extend(buffered_stdout, data)
                pmsgcall(scroll, node)
                pmsgcall(TermNode.jobinfo.opts.on_stdout, jobid, data, event, node)
                pmsgcall(ujobinfo.opts.on_stdout, jobid, data, event, node)
            end,
            on_stderr = function(jobid, data, event, node)
                buffered_stderr = vim.list_extend(buffered_stderr, data)
                pmsgcall(scroll, node)
                pmsgcall(TermNode.jobinfo.opts.on_stderr, jobid, data, event, node)
                pmsgcall(ujobinfo.opts.on_stderr, jobid, data, event, node)
            end,
            on_exit = function(jobid, code, event, node)
                pmsgcall(TermNode.jobinfo.opts.on_exit, jobid, code, event, node)
                pmsgcall(ujobinfo.opts.on_exit, jobid, code, event, node)
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
                    pmsgcall(after_finish, jobid, code, node)
                else
                    assert(repeat_opts and node.repeat_left_times > 0)
                    local timer = vim.uv.new_timer()
                    if timer then
                        node.repeat_timer = timer
                        timer:start(1000 * repeat_opts.timeinterval, 0, function()
                            vim.schedule(function()
                                obj:restart()
                            end)
                        end)
                    end
                end
            end,
            on_start = function(...)
                buffered_stdout = {}
                buffered_stderr = {}
                pmsgcall(TermNode.jobinfo.opts.on_start, ...)
                pmsgcall(ujobinfo.opts.on_start, ...)
            end,
        },
    })
    setmetatable(obj, self)
    if startnow then
        obj:start()
    end
    obj.new = utils.unreachable
    return obj
end

---@param full boolean? full-restart will reset repeat_lefttimes
function TermNode:restart(full)
    self:clean()
    if full then
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

function TermNode:clean()
    self.cleaning = true
    if self.jobinfo.jobid ~= -1 then
        jobstop(self.jobinfo.jobid)
    end
    self.jobinfo.jobid = -1
    if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
        local bufnr = self.bufnr
        self.bufnr = nil
        onBufNrChanged(self)
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
    self.cleaning = false
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
                "[Terminal]: create terminal error:" .. tostring(result),
                vim.log.levels.ERROR
            )
        end
    end)
    if success then
        self.bufnr = bufnr
        self:setup_termbuf()
        self.jobinfo.jobid = jobid
        onBufNrChanged(self)
    else
        vim.notify(("[Terminal.%s]: start error"):format(self.classname), vim.log.levels.ERROR)
    end
    return success
end

---@return string
function TermNode:display()
    return " " .. self.name
end

return TermNode
