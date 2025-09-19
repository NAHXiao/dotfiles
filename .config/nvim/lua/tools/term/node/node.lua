local utils = require("tools.term.utils")
local panel = require("tools.term.panel")
---@type table<string,NNode>
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
function Node:tostring()
    return ("%s(%s)-%p"):format(self.name, self.classname, self)
end

function Node:rename(name)
    self.name = name
    panel.update_data_by_node(self)
end
---@generic T
---@param T `T`
---@return fun(...):T
local function abstract_unreachable(T)
    return function(...)
        assert(false, "abstract method,unreachable")
    end
end
---@generic T
---@param T `T`
---@return fun(...):T
local function dropped_unreachable(T)
    return function(...)
        assert(false, "attempt to call method on a dropped Node")
    end
end
Node.display = abstract_unreachable("string")
Node.restart = abstract_unreachable("nil")
Node.start = abstract_unreachable("nil")
Node.clean = abstract_unreachable("nil")

---clean + panel.del + parent,prev... = nil
---@protected called externeall will cause tree structure inconsistent
function Node:drop()
    self.parent = nil
    self.prev = nil
    self.next = nil
    self.name = self.name .. "(Droped)"
    self:clean()
    self.clean = dropped_unreachable("nil")
    self.restart = dropped_unreachable("nil")
    self.start = dropped_unreachable("nil")
    panel.del_data_by_node(self)
end
---static shouldn't be override
function Node:toggle_pin()
    self.pinned = not self.pinned
end

---@param node NNode
function Node:parents_has(node)
    if self.parent == nil then
        return false
    end
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

---static
---@protected
---@alias newnode_opts {name:string,parent?:GroupNode|TaskSetNode, next?:NNode, prev?:NNode, pinned?:boolean}
---@generic T : NNode
---@param self T
---@return T
function Node:_new(newnode_opts)
    local obj = {
        _new = utils.unreachable,
        name = newnode_opts.name,
        next = newnode_opts.next,
        prev = newnode_opts.prev,
        pinned = newnode_opts.pinned,
        parent = newnode_opts.parent,
    }
    setmetatable(obj, self)
    return obj
end
return Node
