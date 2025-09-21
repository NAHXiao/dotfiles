local utils = require("tools.term.utils")
local TermNode = require("tools.term.node.termnode")
local panel = require("tools.term.panel")
local log_notify = require("tools.term.utils").log_notify
local pmsgcall = require("tools.term.utils").pmsgcall
---@class TaskTermNode:TermNode
---                     ╭──────Sleep,Restart(Clean) ───────────╮
---                     │                                      │
---                     │                          ╭───────────┴─────────╮          ╭───────╮
---                     │                  ╭─exit-→│ error_retry_pending │──finish-→│ error │
---                     ↓                  │       ╰─────────────────────╯          ╰───────╯
---╭──────╮        ╭────┴───╮          ╭───┴───╮
---│uninit│───new─→│waitting│───start─→│running│
---╰──────╯        ╰────┬───╯          ╰───┬───╯
---                     ↑                  │       ╭─────────────────────╮          ╭───────╮
---                     │                  ╰─exit-→│success_retry_pending│──finish-→│success│
---                     │                          ╰───────────┬─────────╯          ╰───────╯
---                     │                                      │
---                     ╰──────Sleep,Restart(Clean) ───────────╯
---@field status "uninit"|"waitting"|"running"|"error_retry_pending"|"success_retry_pending"|"error"|"success"
---@field has_been_started boolean
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
---static
---@param newnode_opts newnode_opts
---@param ujobinfo ujobinfo
---@param startnow? boolean default false
---jobinfo:param>TaskTermNode>TermNode
---func: scroll,TermNode,(status,TaskTermNode,param) ...(repeat) after_finish
function TaskTermNode:new(newnode_opts, ujobinfo, startnow)
    local obj = TermNode.new(
        self,
        newnode_opts,
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.tbl_deep_extend("force", TaskTermNode.jobinfo, ujobinfo, {
            opts = {
                before_start = function(...)
                    pmsgcall(TaskTermNode.jobinfo.opts.before_start, ...)
                    pmsgcall(ujobinfo.opts.before_start, ...)
                end,
                on_start = function(jobid, node)
                    node.status = "running"
                    node.has_been_started = true
                    ---@cast node TaskTermNode
                    pmsgcall(TaskTermNode.jobinfo.opts.on_start, jobid, node)
                    pmsgcall(ujobinfo.opts.on_start, jobid, node)
                    panel.update_data_by_node(node, false)
                end,
                on_stderr = function(...)
                    pmsgcall(TaskTermNode.jobinfo.opts.on_stderr, ...)
                    pmsgcall(ujobinfo.opts.on_stderr, ...)
                end,
                on_stdout = function(...)
                    pmsgcall(TaskTermNode.jobinfo.opts.on_stdout, ...)
                    pmsgcall(ujobinfo.opts.on_stdout, ...)
                end,
                on_exit = function(jobid, code, event, node)
                    ---@cast node TaskTermNode
                    pmsgcall(TaskTermNode.jobinfo.opts.on_exit, jobid, code, event, node)
                    assert(node.classname == "TaskTermNode")
                    if code == 0 then
                        node.status = "success_retry_pending"
                    else
                        node.status = "error_retry_pending"
                    end
                    panel.update_data_by_node(node, false)
                    pmsgcall(ujobinfo.opts.on_exit, jobid, code, event, node)
                end,
                after_finish = function(jobid, code, node)
                    ---@cast node TaskTermNode
                    if node.status == "success_retry_pending" then
                        node.status = "success"
                    else
                        node.status = "error"
                    end
                    panel.update_data_by_node(node, false)
                    pmsgcall(ujobinfo.opts.after_finish, jobid, code, node)
                end,
            },
        }),
        false
    )
    setmetatable(obj, self)
    obj.new = utils.unreachable
    obj.status = "waitting"
    obj.has_been_started = false
    if startnow then
        obj:start()
    end
    return obj
end

---override
---@return string
function TaskTermNode:display()
    return taskterm_icons[self.status] .. " " .. self.name
end

---@param full boolean? default false;full-restart will reset has_been_started
function TaskTermNode:restart(full)
    TermNode.restart(self, full)
    if full then
        self.status = "waitting"
        self.has_been_started = false
        panel.update_data_by_node(self, false)
    end
end

---@protected
function TaskTermNode:clean()
    TermNode.clean(self)
    self.status = "waitting"
    panel.update_data_by_node(self, false)
end
return TaskTermNode
