local utils = require("tools.term.utils")
local TermNode = require("tools.term.node.termnode")
local panel = require("tools.term.panel")
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
                    if TaskTermNode.jobinfo.opts.before_start then
                        utils.pmsgcall(TaskTermNode.jobinfo.opts.before_start, ...)
                    end
                    if ujobinfo.opts.before_start then
                        utils.pmsgcall(ujobinfo.opts.before_start, ...)
                    end
                end,
                on_start = function(jobid, node)
                    self.status = "running"
                    ---@cast node TaskTermNode
                    utils.log_notify("8try TaskTermNode.on_start")
                    if TaskTermNode.jobinfo.opts.on_start then
                        utils.pmsgcall(TaskTermNode.jobinfo.opts.on_start, jobid, node)
                    end
                    utils.log_notify("9try ujobinfo.on_start")
                    if ujobinfo.opts.on_start then
                        utils.pmsgcall(ujobinfo.opts.on_start, jobid, node)
                    end
                    panel.update_data_by_node(node, false)
                end,
                on_stderr = function(...)
                    utils.log_notify("21try TaskTermNode.on_stderr")
                    if TaskTermNode.jobinfo.opts.on_stderr then
                        utils.pmsgcall(TaskTermNode.jobinfo.opts.on_stderr, ...)
                    end
                    utils.log_notify("22try ujobinfo.on_stderr")
                    if ujobinfo.opts.on_stderr then
                        utils.pmsgcall(ujobinfo.opts.on_stderr, ...)
                    end
                end,
                on_stdout = function(...)
                    utils.log_notify("23try TaskTermNode.on_stdout")
                    if TaskTermNode.jobinfo.opts.on_stdout then
                        utils.pmsgcall(TaskTermNode.jobinfo.opts.on_stdout, ...)
                    end
                    utils.log_notify("24try ujobinfo.on_stdout")
                    if ujobinfo.opts.on_stdout then
                        utils.pmsgcall(ujobinfo.opts.on_stdout, ...)
                    end
                end,
                on_exit = function(jobid, code, event, node)
                    ---@cast node TaskTermNode
                    utils.log_notify("10try TaskTermNode.on_exit")
                    if TaskTermNode.jobinfo.opts.on_exit then
                        utils.pmsgcall(TaskTermNode.jobinfo.opts.on_exit, jobid, code, event, node)
                    end
                    utils.log_notify("11try ujobinfo.on_exit")
                    if ujobinfo.opts.on_exit then
                        utils.pmsgcall(ujobinfo.opts.on_exit, jobid, code, event, node)
                    end
                    assert(node.classname == "TaskTermNode")
                    if code == 0 then
                        node.status = "success_retry_pending"
                    else
                        node.status = "error_retry_pending"
                    end
                    panel.update_data_by_node(node, false)
                end,
                after_finish = function(jobid, code, node)
                    if ujobinfo.opts.after_finish then
                        utils.pmsgcall(ujobinfo.opts.after_finish, jobid, code, node)
                    end
                    ---@cast node TaskTermNode
                    if node.status == "success_retry_pending" then
                        node.status = "success"
                    else
                        node.status = "error"
                    end
                    panel.update_data_by_node(node, false)
                end,
            },
        }),
        false
    )
    setmetatable(obj, self)
    obj.new = utils.unreachable
    obj.status = "waitting"
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

---@protected
function TaskTermNode:clean()
    TermNode.clean(self)
    self.status = "waitting"
    panel.update_data_by_node(self, false)
end
return TaskTermNode
