local panel = require("tools.term.panel")
local GroupNode = require("tools.term.node.groupnode")
local TaskTermNode = require("tools.term.node.tasktermnode")
local utils = require("tools.term.utils")
---@class TaskSetNode :GroupNode
---@field status "uninit"|"waitting"|"running"|"error"|"success"
---@field seq boolean
---@field break_on_err boolean
---@field tasks {name:string,jobinfo:ujobinfo,bg:boolean|nil,ignore_error:boolean|nil}[]
---@field start_nodes? TaskTermNode[]
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

---static
---after_finish_all: TaskSetNode,status,param
---@param newnode_opts newnode_opts
---@param tasks {name:string,jobinfo:ujobinfo,ignore_err:boolean,bg:boolean}[]
---@param seq boolean default true
---@param break_on_err boolean default true
---@param after_finish_all fun()
function TaskSetNode:new(newnode_opts, tasks, seq, break_on_err, after_finish_all, startnow)
    local obj = GroupNode.new(self, newnode_opts)
    setmetatable(obj, self)
    obj.addnode = utils.unreachable
    obj.delnode = utils.unreachable
    obj.tasks = tasks
    obj.seq = seq or true
    obj.break_on_err = break_on_err or true
    obj.status = "waitting"
    obj.after_finish_all = function()
        utils.log_notify("12tasksetnode after_finish_all")
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
        panel.update_data_by_node(obj)
        --Self
        if after_finish_all then
            after_finish_all()
        end
    end
    panel.update_data_by_node(obj)
    if startnow then
        obj:start()
    end
    return obj
end

function TaskSetNode:display()
    return "" .. " " .. self.name
end

function TaskSetNode:clean()
    GroupNode.clean(self)
    self.status = "waitting"
    panel.update_data_by_node(self)
end

function TaskSetNode:restart(reset_repeat)
    if self.start_nodes == nil then
        vim.notify("[Terminal]: You cannot restart a node which has not been started once", utils.ERROR)
        return
    end
    self:clean()
    for _, child in ipairs(self.children) do
        if reset_repeat and child.jobinfo.opts and child.jobinfo.opts.repeat_opts then
            child.repeat_left_times = child.jobinfo.opts.repeat_opts.time
        end
    end
    for _, node in ipairs(self.start_nodes) do
        node:start()
    end
end

---@private start_nodes,children
function TaskSetNode:generate_nodes()
    if self.start_nodes ~= nil then
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
        local next_tasks = {}
        for i = #self.tasks, 1, -1 do
            local task = self.tasks[i]
            local after_finish
            if task.bg then
                after_finish = function(_, code, _)
                    utils.log_notify("13TaskSetNode.start after_finish")
                    if self.break_on_err == false or code == 0 or task.ignore_error then
                        chk_all_finished()
                    else
                        chk_started_finished()
                    end
                end
            else
                local nexts = next_tasks
                next_tasks = {}
                after_finish = function(_, code, _)
                    utils.log_notify("14TaskSetNode.start after_finish")
                    if self.break_on_err == false or code == 0 or task.ignore_error then
                        for _, nxt in ipairs(nexts) do
                            nxt:start()
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
            local node = TaskTermNode:new(
                { name = self.tasks[i].name, parent = self },
                self.tasks[i].jobinfo,
                false
            )
            self.children[i] = node
            table.insert(next_tasks, node)
        end
        self.start_nodes = next_tasks
    else
        local start_nodes_seq = {}
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
            start_nodes_seq[#start_nodes_seq + 1] = node
        end
        self.start_nodes = start_nodes_seq
    end
    for i, child in ipairs(self.children) do
        child.prev = self.children[i - 1]
        child.next = self.children[i + 1]
    end
    panel.update_data_by_node(self, true)
end

function TaskSetNode:start()
    if self.start_nodes == nil then
        self:generate_nodes()
    end
    for _, node in ipairs(self.start_nodes) do
        node:start()
    end
    self.status = "running"
    panel.update_data_by_node(self, false)
end

return TaskSetNode
