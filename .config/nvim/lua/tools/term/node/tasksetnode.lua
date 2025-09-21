local panel = require("tools.term.panel")
local GroupNode = require("tools.term.node.groupnode")
local TaskTermNode = require("tools.term.node.tasktermnode")
local utils = require("tools.term.utils")
local log_notify = require("tools.term.utils").log_notify
local pmsgcall = require("tools.term.utils").pmsgcall
---@alias start_nodes_item {bg:TaskTermNode[],fg:{node:TaskTermNode,ignore_error:boolean?}}
---@class TaskSetNode :GroupNode
---@field status "uninit"|"waitting"|"running"|"error"|"success"
---@field seq boolean
---@field break_on_err boolean
---@field tasks {name:string,jobinfo:ujobinfo,bg:boolean|nil,ignore_error:boolean|nil}[]
---@field after_finish_all fun()
---
---@field start_nodes_seq? start_nodes_item[]
---@field children TaskTermNode[]
---
---@field expanded boolean
---@field break_at TaskTermNode?
---@field still_follow boolean
---@field last_follow_node TaskTermNode?
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
    still_follow = false,
}
TaskSetNode.__index = TaskSetNode
setmetatable(TaskSetNode, GroupNode)

---static
---after_finish_all: TaskSetNode,status,param
---@param newnode_opts newnode_opts
---@param tasks {name:string,jobinfo:ujobinfo,ignore_error:boolean,bg:boolean}[]
---@param seq boolean default true
---@param break_on_err boolean default true
---@param after_finish_all fun()
function TaskSetNode:new(newnode_opts, tasks, seq, break_on_err, after_finish_all, startnow)
    local obj = GroupNode.new(self, newnode_opts)
    setmetatable(obj, self)
    obj.addnode = utils.unreachable
    obj.delnode = utils.unreachable
    obj.tasks = tasks
    obj.seq = seq
    obj.break_on_err = break_on_err
    obj.status = "waitting"
    obj.after_finish_all = function()
        --Class
        pmsgcall(TaskSetNode.after_finish_all)
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
        --Param
        pmsgcall(after_finish_all)
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

function TaskSetNode:restart(full)
    self.break_at = nil
    if self.start_nodes_seq == nil then
        self:generate_nodes()
    end
    self:clean()
    if full then
        for _, child in ipairs(self.children) do
            if child.jobinfo.opts and child.jobinfo.opts.repeat_opts then
                child.repeat_left_times = child.jobinfo.opts.repeat_opts.time
            end
        end
    end
    for _, node in ipairs(self.start_nodes_seq[1].bg) do
        node:start()
    end
    if self.start_nodes_seq[1].fg then
        self.start_nodes_seq[1].fg.node:start()
    end
    self.status = "running"
    panel.update_data_by_node(self, false)
end
---@param self TaskSetNode
---@param node TaskTermNode
local function follow(self, node)
    if not self.still_follow then
        return
    end
    if self.last_follow_node and panel.get_cur_node() ~= self.last_follow_node then
        self.still_follow = false
        self.last_follow_node = nil
        return
    end
    assert(node.classname == "TaskTermNode" and self.classname == "TaskSetNode")
    if #self.start_nodes_seq == 1 and self.start_nodes_seq[1].fg == nil then --- abcdefg
        self.last_follow_node = node
        panel.set_cur_node(node)
    else ---abCdEfg / abCdefG
        for _, item in ipairs(self.start_nodes_seq) do
            if item.fg and item.fg.node == node then
                self.last_follow_node = node
                panel.set_cur_node(node)
                return
            end
        end
    end
end
---@private start_nodes_seq,children
---NOTE:the code surrounded by `NOTE` shouldn't be called when TaskTermNode is not started by TaskSetNode
function TaskSetNode:generate_nodes()
    if self.start_nodes_seq ~= nil or #self.children ~= 0 then
        return
    end
    for _, task in ipairs(self.tasks) do
        local _on_start = task.jobinfo.opts.on_start
        task.jobinfo.opts.on_start = function(job, node)
            pmsgcall(_on_start, job, node)
            ----NOTE:
            if self.status ~= "running" then
                return
            end
            ---@cast node TaskTermNode
            follow(self, node)
            ----NOTE:
        end
    end
    ---@type start_nodes_item[]
    local start_nodes_seq = {}
    local function ifFinishedThenCallFinishedCallback()
        for _, item in ipairs(start_nodes_seq) do
            for _, bg in ipairs(item.bg) do
                if bg.status ~= "error" and bg.status ~= "success" then
                    return
                end
            end
            if item.fg then
                if item.fg.node.status ~= "error" and item.fg.node.status ~= "success" then
                    return
                end
                if item.fg.node == self.break_at then
                    break
                end
            end
        end
        log_notify(("[TermSetNode]: all tasks in %s finished"):format(self:tostring()))
        self.after_finish_all()
        self.still_follow = false
        self.last_follow_node = nil
    end
    local p
    if self.seq then
        for i, task in ipairs(self.tasks) do
            local _after_finish = task.jobinfo.opts.after_finish
            if not p then
                p = i
            end
            if task.bg == nil or task.bg == false or i == #self.tasks then
                ---When encountering a foreground task or the last task,pack the task from p to i as item and push it to start_nodes_seq
                ---At this time, all tasks except the task with index i are background tasks
                ---@type start_nodes_item
                local item = { bg = {} }
                local itemidx = #start_nodes_seq + 1
                for idx = p, i do
                    local t = self.tasks[idx]
                    if t.bg == false then
                        ---For foreground task's after_finish,start nexts tasks and check finish
                        t.jobinfo.opts.after_finish = function(jobid, code, node)
                            pmsgcall(_after_finish, jobid, code, node)
                            ----NOTE:
                            if self.status ~= "running" then
                                return
                            end
                            if self.break_on_err == false or code == 0 or t.ignore_error then
                                log_notify(
                                    ("[TermSetNode]: start next task after %s finished"):format(
                                        node:tostring()
                                    )
                                )
                                local nextitem = start_nodes_seq[itemidx + 1]
                                if nextitem then
                                    for _, bgs in ipairs(nextitem.bg) do
                                        bgs:start()
                                    end
                                    nextitem.fg.node:start()
                                end
                            else ---Break
                                log_notify(("[TermSetNode]: break at %s"):format(node:tostring()))
                                self.break_at = node
                            end
                            ifFinishedThenCallFinishedCallback()
                            ----NOTE:
                        end
                        item.fg = {
                            node = TaskTermNode:new(
                                { name = t.name, parent = self },
                                t.jobinfo,
                                false
                            ),
                            ignore_error = not not t.ignore_error,
                        }
                        self.children[#self.children + 1] = item.fg.node
                    else
                        ---For foreground task's after_finish,just check finish
                        t.jobinfo.opts.after_finish = function(jobid, code, node)
                            pmsgcall(_after_finish, jobid, code, node)
                            ----NOTE:
                            if self.status ~= "running" then
                                return
                            end
                            ifFinishedThenCallFinishedCallback()
                            ----NOTE:
                        end
                        item.bg[#item.bg + 1] =
                            TaskTermNode:new({ name = t.name, parent = self }, t.jobinfo, false)
                        self.children[#self.children + 1] = item.bg[#item.bg]
                    end
                end
                start_nodes_seq[#start_nodes_seq + 1] = item
                p = nil
            end
        end
    else
        ---@type TaskTermNode[]
        local nodes = {}
        for _, task in ipairs(self.tasks) do
            local _after_finish = task.jobinfo.opts.after_finish
            task.jobinfo.opts.after_finish = function(jobid, code, node)
                pmsgcall(_after_finish, jobid, code, node)
                ----NOTE:
                if self.status ~= "running" then
                    return
                end
                ifFinishedThenCallFinishedCallback()
                ----NOTE:
            end
            nodes[#nodes + 1] =
                TaskTermNode:new({ name = task.name, parent = self }, task.jobinfo, false)
        end
        start_nodes_seq[1] = { bg = nodes }
    end
    for i, child in ipairs(self.children) do
        child.prev = self.children[i - 1]
        child.next = self.children[i + 1]
    end
    self.start_nodes_seq = start_nodes_seq
    panel.update_data_by_node(self, true)
end
function TaskSetNode:start_follow()
    if not self.start_nodes_seq or #self.start_nodes_seq == 0 then
        return
    end
    if self.status ~= "waitting" and self.status ~= "running" then
        return
    end
    local first_follow_node
    if #self.start_nodes_seq == 1 and self.start_nodes_seq[1].fg == nil then --- abcdefg
        for _, node in ipairs(self.start_nodes_seq[1].bg) do
            if node.has_been_started then
                first_follow_node = node
                break
            end
        end
    else ---abCdEfg / abCdefG
        for _, item in ipairs(self.start_nodes_seq) do
            if item.fg and item.fg.node then
                if item.fg.node.has_been_started then
                    first_follow_node = item.fg.node
                end
            end
        end
    end
    if first_follow_node then
        self.last_follow_node = first_follow_node
        panel.set_cur_node(first_follow_node)
    end
    self.still_follow = true
    local group = vim.api.nvim_create_augroup("TermSetNodeFollowLatestNode", { clear = true })
    vim.api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = function(args)
            if args.buf == panel.get_termbuf() then
                self.still_follow = false
                self.last_follow_node = nil
                vim.api.nvim_del_augroup_by_id(group)
            end
        end,
    })
end

function TaskSetNode:start()
    self:restart(true)
end

return TaskSetNode
