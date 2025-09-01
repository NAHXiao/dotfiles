local Node = require("tools.term.node.node")
local utils = require("tools.term.utils")
local panel = require("tools.term.panel")
local BijectionMap = require("libs.BijectionMap")
---@class GroupNode :NNode
---@field classname string
---@field children NNode[]
---@field expanded boolean
---@field uniqnameMap BijectionMap<NNode,string>
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
    obj.uniqnameMap = BijectionMap.new()
    obj.new = utils.unreachable
    return obj
end

function GroupNode:display()
    return (self.expanded and "" or "") .. " " .. self.name
end
---@param uniqname string
function GroupNode:getNodeByUniqueName(uniqname)
    return self.uniqnameMap:getByValue(uniqname)
end
---@param node NNode
function GroupNode:getUniqueNameByNode(node)
    return self.uniqnameMap:getByKey(node)
end
---@param on? boolean
---@return boolean
---true for changed
function GroupNode:toggle_expand(on)
    if on == nil then
        self.expanded = not self.expanded
        panel.update_data_by_node(self, true)
        return true
    elseif self.expanded ~= on then
        self.expanded = on
        panel.update_data_by_node(self, true)
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
        panel.update_data_by_node(self, true) --TODO:更细的粒度
        return true
    end
    return false
end
---@private Called externally will cause uniqnameMap inconsistent
---@param child NNode|number
---@param node NNode
function GroupNode:replace(child, node)
    ---@type NNode?
    local childNode
    ---@type number
    local index
    if type(child) == "number" then
        childNode = self.children[child]
        index = child
    else
        childNode = child
        for i, n in ipairs(self.children) do
            if n == child then
                index = i
                break
            end
        end
    end
    if not childNode or not index then
        return
    end
    node.prev, node.next, node.parent = childNode.prev, childNode.next, self
    self.children[index] = node
    panel.update_data_by_node(self, true)
    panel.update_termwinbuf()
end

---@generic T:NNode
---@param node T
---@param uniqname? string
---@return T
function GroupNode:addnode(node, uniqname)
    if uniqname then
        if self.uniqnameMap:getByValue(uniqname) then
            self:replace(self.uniqnameMap:getByValue(uniqname), node)
            self.uniqnameMap:setKey(uniqname, node)
            return node
        else
            self.uniqnameMap:set(node, uniqname)
        end
    end
    node.parent = self
    node.prev = self.children[#self.children]
    if self.children[#self.children] then
        self.children[#self.children].next = node
    end
    self.children[#self.children + 1] = node
    panel.update_data_by_node(self, true) --TODO:更细的粒度
    return node
end

function GroupNode:clean()
    for _, child in ipairs(self.children) do
        child:clean()
    end
end
---@param node NNode
---@return boolean
function GroupNode:delnode(node)
    if node.prev then
        node.prev.next = node.next
    end
    if node.next then
        node.next.prev = node.prev
    end
    for pos, child in ipairs(self.children) do
        if child == node then
            table.remove(self.children, pos):drop()
            -- panel.update_data_by_node(self, true)
            panel.del_data_by_node(node)
            return true
        end
    end
    utils.log_notify(("%s.delnode: find node %s failed: "):format(self:tostring(), node:tostring()))
    return false
end
---Delete All Children
function GroupNode:clear()
    for idx = #self.children, 1, -1 do
        self.children[idx]:drop()
        table.remove(self.children, idx)
    end
    panel.update_data_by_node(self, true)
end
return GroupNode
