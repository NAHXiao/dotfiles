---- Example
---```lua
------@type BijectionMap<string,number>
---local m = BijectionMap.new()
---```
---@class BijectionMap<K,V>:{
---delByKey:fun(self,key:K),
---delByValue:fun(self,value:V),
---set:fun(self,key:K,value:V),
---setKey:fun(self,value:V,key:K):(boolean),
---setValue:fun(self,key:K,value:V):(boolean),
---getByKey:fun(self,key:K):(V),
---getByValue:fun(self,value:V):(K),
---pairs:fun(self):(fun():K,V),
---ipairs:fun(self):(fun():number,{key:K,value:V})}
---@field private _key_to_value table<any,any>
---@field private _value_to_key table<any,any>
---@field private _order {key:any,value:any}[]
local BijectionMap = {}
function BijectionMap.new()
    local obj = {
        _key_to_value = {},
        _value_to_key = {},
        _order = {}, -- 按添加顺序存储 {key=k, value=v}
        _count = 0,
    }
    setmetatable(obj, BijectionMap)

    local mt = getmetatable(obj)
    mt.__len = function(t)
        return t._count
    end
    mt.__index = function(t, k)
        --Method
        if type(k) == "string" and BijectionMap[k] then
            return BijectionMap[k]
        end

        --NumberIndex
        if type(k) == "number" then
            if k >= 1 and k <= t._count and t._order[k] then
                return { key = t._order[k].key, value = t._order[k].value }
            end
            return nil
        end

        --{key/value}Index
        if type(k) == "table" then
            if k.key ~= nil and k.value == nil then
                return t._key_to_value[k.key]
            elseif k.value ~= nil and k.key == nil then
                return t._value_to_key[k.value]
            else
                print("error: invalid read form")
                return nil
            end
        end

        print("error: invalid read form")
        return nil
    end

    mt.__newindex = function(t, k, v)
        --NumberIndex
        if type(k) == "number" then
            if type(v) == "table" and v.key ~= nil and v.value ~= nil then
                if k >= 1 and k <= t._count then
                    local old_item = t._order[k]
                    if old_item then
                        t._key_to_value[old_item.key] = nil
                        t._value_to_key[old_item.value] = nil
                    end

                    if t._key_to_value[v.key] ~= nil or t._value_to_key[v.value] ~= nil then
                        print("error: uniqueness conflict")
                        return
                    end

                    t._key_to_value[v.key] = v.value
                    t._value_to_key[v.value] = v.key
                    t._order[k] = { key = v.key, value = v.value }
                else
                    print("error: invalid write form")
                end
            else
                print("error: invalid write form")
            end
            return
        end

        --{key/value}Index
        if type(k) == "table" then
            if k.key ~= nil and k.value == nil then
                -- m[{key=K}] = V
                t:_setByKey(k.key, v)
            elseif k.value ~= nil and k.key == nil then
                -- m[{value=V}] = K
                t:_setByValue(k.value, v)
            else
                print("error: invalid write form")
            end
            return
        end

        print("error: invalid write form")
    end

    return obj
end

function BijectionMap:_setByKey(key, value)
    if value == nil then
        self:delByKey(key)
        return
    end

    local existing_value = self._key_to_value[key]
    local existing_key = self._value_to_key[value]

    if existing_key ~= nil and existing_key ~= key then
        print("error: uniqueness conflict")
        return
    end

    if existing_value ~= nil then
        self:delByKey(key)
    end

    if existing_key ~= nil and existing_key ~= key then
        self:delByKey(existing_key)
    end

    self._key_to_value[key] = value
    self._value_to_key[value] = key

    self._count = self._count + 1
    self._order[self._count] = { key = key, value = value }
end

function BijectionMap:_setByValue(value, key)
    if key == nil then
        self:delByValue(value)
        return
    end

    local existing_key = self._value_to_key[value]
    local existing_value = self._key_to_value[key]

    if existing_value ~= nil and existing_value ~= value then
        print("error: uniqueness conflict")
        return
    end

    if existing_key ~= nil then
        self:delByValue(value)
    end

    if existing_value ~= nil and existing_value ~= value then
        self:delByValue(existing_value)
    end

    self._key_to_value[key] = value
    self._value_to_key[value] = key

    self._count = self._count + 1
    self._order[self._count] = { key = key, value = value }
end
function BijectionMap:clear()
    self._key_to_value = {}
    self._value_to_key = {}
    self._order = {}
    self._count = 0
end
---@type nil
function BijectionMap:set(key, value)
    self:_setByKey(key, value)
end
---@type nil
function BijectionMap:setKey(value, key)
    local old_key = self._value_to_key[value]
    if old_key == nil then
        print("error: value not found")
        return false
    end

    if old_key == key then
        return true
    end

    local existing_value = self._key_to_value[key]
    if existing_value ~= nil and existing_value ~= value then
        print("error: uniqueness conflict")
        return false
    end

    self._key_to_value[old_key] = nil
    self._key_to_value[key] = value
    self._value_to_key[value] = key

    for i = 1, self._count do
        if self._order[i] and self._order[i].value == value then
            self._order[i].key = key
            break
        end
    end

    return true
end
---@type nil
function BijectionMap:setValue(key, value)
    local old_value = self._key_to_value[key]
    if old_value == nil then
        print("error: key not found")
        return false
    end

    if old_value == value then
        return true
    end

    local existing_key = self._value_to_key[value]
    if existing_key ~= nil and existing_key ~= key then
        print("error: uniqueness conflict")
        return false
    end

    self._value_to_key[old_value] = nil
    self._value_to_key[value] = key
    self._key_to_value[key] = value

    for i = 1, self._count do
        if self._order[i] and self._order[i].key == key then
            self._order[i].value = value
            break
        end
    end

    return true
end
---@type nil
function BijectionMap:getByKey(key)
    return self._key_to_value[key]
end

---@type nil
function BijectionMap:getByValue(value)
    return self._value_to_key[value]
end

---@type nil
function BijectionMap:delByKey(key)
    local value = self._key_to_value[key]
    if value == nil then
        return
    end

    self._key_to_value[key] = nil
    self._value_to_key[value] = nil

    for i = 1, self._count do
        if self._order[i] and self._order[i].key == key then
            for j = i, self._count - 1 do
                self._order[j] = self._order[j + 1]
            end
            self._order[self._count] = nil
            self._count = self._count - 1
            break
        end
    end
end

---@type nil
function BijectionMap:delByValue(value)
    local key = self._value_to_key[value]
    if key == nil then
        return
    end

    self._key_to_value[key] = nil
    self._value_to_key[value] = nil

    for i = 1, self._count do
        if self._order[i] and self._order[i].value == value then
            for j = i, self._count - 1 do
                self._order[j] = self._order[j + 1]
            end
            self._order[self._count] = nil
            self._count = self._count - 1
            break
        end
    end
end

---@type nil
function BijectionMap:pairs()
    local i = 0
    return function()
        i = i + 1
        if i <= self._count and self._order[i] then
            return self._order[i].key, self._order[i].value
        end
        return nil
    end
end

---@type nil
function BijectionMap:ipairs()
    local i = 0
    return function()
        i = i + 1
        if i <= self._count and self._order[i] then
            return i, { key = self._order[i].key, value = self._order[i].value }
        end
        return nil
    end
end
return BijectionMap
