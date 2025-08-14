---From https://github.com/brglng/dotfiles/blob/master/config/nvim/lua/brglng/hl.lua

local color = require("libs.color")

---@param hl_fallback_list string | string[]
---Example
---```lua
---local fg = get_attr({"Visual.fg","CursorLine.fg"})
---local fg = get_attr({"Visual.fg","#ffffaa","Red"})
---```
local function get_attr(hl_fallback_list)
    if type(hl_fallback_list) == "string" then
        hl_fallback_list = { hl_fallback_list }
    end
    for _, hl_fallback in ipairs(hl_fallback_list) do
        for _, hl_name_dot_attr in ipairs(vim.split(hl_fallback, ",", { trimempty = true })) do
            local name, attr = hl_name_dot_attr:match("^([^%.]+)%.([^%.]+)$")
            if name and attr then
                local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
                if hl.reverse == true and attr == "fg" and hl.fg then
                    return hl.bg
                elseif hl.reverse == true and attr == "bg" and hl.bg then
                    return hl.fg
                elseif hl[attr] then
                    return hl[attr]
                end
            elseif ---"Red" "#ffffaa"
                not hl_name_dot_attr:find(".", 1, true)
                and vim.api.nvim_get_color_by_name(hl_name_dot_attr) ~= -1
            then
                return vim.api.nvim_get_color_by_name(hl_name_dot_attr)
            else
                error("Invalid highlight color: " .. hl_name_dot_attr)
            end
        end
    end
end

---HighlightTransform Example:
---type: `lighten`|`darken`|`emboss`|`deboss`
---```lua
---local tf1= {
--- transform="lighten",
--- amount=10,
--- from="Visual.bg"
---}
---```
---type: `interpolate` | `middle`
---```lua
---local tf2= {
--- transform="interpolate" ,
--- from={[1]="Visual.bg",[2]="CursorLine.bg"} --len==2
---}
---```
---type: `blend`
---```lua
---local tf3= {
--- transform="blend",
--- fg="Visual.bg",
--- bg="Visual.bg",
--- opacity=0.5
---}
---```
---Tips: use {"Visual.bg","fallback.bg"} for fallback
---@class HighlightTransform
---@field transform HighlightTransformType
---@field from? string | string[]
---@field fg? string | string[]
---@field bg? string | string[]
---@field amount? number
---@field mix? number,
---@field opacity? number

---@alias HighlightTransformType "lighten" | "darken" | "emboss" | "deboss" | "interpolate" | "middle" | "blend"
---@param opts HighlightTransform | fun(): HighlightTransform
---@return integer
local function transform_one(opts)
    if type(opts) == "function" then
        opts = opts()
    end

    local count = 0
    for _, t in ipairs({ "lighten", "darken", "emboss", "deboss", "interpolate", "middle", "blend" }) do
        if opts.transform == t then
            count = count + 1
        end
    end
    if count > 1 then --TODO:?
        error("Multiple transforms is not supported: " .. vim.inspect(opts))
    end

    local transform = opts.transform or opts[1]
    if transform == "lighten" then
        assert(type(opts.from) == "string" or type(opts.from) == "table", "lighten requires `from`")
        assert(type(opts.amount) == "number", "lighten requires `amount`")
        return color.lighten(get_attr(opts.from), opts.amount)
    elseif transform == "darken" then
        assert(type(opts.from) == "string" or type(opts.from) == "table", "darken requires `from`")
        assert(type(opts.amount) == "number", "darken requires `amount`")
        return color.darken(get_attr(opts.from), opts.amount)
    elseif transform == "emboss" then
        assert(type(opts.from) == "string" or type(opts.from) == "table", "emboss requires `from`")
        assert(type(opts.amount) == "number", "emboss requires `amount`")
        return color.emboss(get_attr(opts.from), opts.amount)
    elseif transform == "deboss" then
        assert(type(opts.from) == "string" or type(opts.from) == "table", "deboss requires `from`")
        assert(type(opts.amount) == "number", "deboss requires `amount`")
        return color.deboss(get_attr(opts.from), opts.amount)
    elseif transform == "interpolate" then
        assert(type(opts.from) == "table" and #opts.from >= 2, "interpolate requires `from`")
        assert(type(opts.mix) == "number", "interpolate requires `mix`")
        return color.interpolate(get_attr(opts.from[1]), get_attr(opts.from[2]), opts.mix)
    elseif transform == "middle" then
        assert(type(opts.from) == "table" and #opts.from >= 2, "middle requires `from` as table and `#from` should >= 2")
        assert(type(opts.mix) == "number", "middle requires `mix`")
        return color.middle(get_attr(opts.from[1]), get_attr(opts.from[2]))
    elseif transform == "blend" then
        assert(
            (type(opts.fg) == "string" or type(opts.fg) == "table")
            and (type(opts.bg) == "string" or type(opts.bg) == "table"),
            "blend requires `fg` and `bg`"
        )
        assert(type(opts.opacity) == "number", "blend requires `opacity`")
        return color.blend(get_attr(opts.fg), get_attr(opts.bg), opts.opacity)
    else
        error("Invalid highlight transform: " .. vim.inspect(opts))
    end
end
---@alias HighlightTransformRegistMap table<string, HighlightTransformTable |fun():HighlightTransformTable>
---@alias HighlightTransformDef string | string[] | HighlightTransform
---@class HighlightTransformTable
---@field  fg? (HighlightTransformDef | fun():HighlightTransformDef)
---@field  bg? (HighlightTransformDef | fun():HighlightTransformDef)
---@field  link? string
---@field  bold? boolean | string
---@field  italic? boolean | string
---@field  underline? boolean | string
---@field  undercurl? boolean | string
---@field  strikethrough? boolean | string
---@param tbl HighlightTransformRegistMap
---@return fun()
---string:字典序赋值
local function __mk_handle(tbl)
    return function()
        local keys = {}
        for k, _ in pairs(tbl) do
            keys[#keys + 1] = k
        end
        table.sort(keys)
        for _, hl_name in ipairs(keys) do
            local hl_opts = tbl[hl_name]
            local result = {}
            if type(hl_opts) == "function" then
                hl_opts = hl_opts()
            end
            if hl_opts then
                for attr, opts in pairs(hl_opts) do
                    if type(opts) == "function" then
                        opts = opts()
                    end
                    --type(opts)==boolean/string/string[]/HighlightTransform
                    if type(opts) == "table" and #opts == 0 then
                        --HighlightTransform
                        result[attr] = transform_one(opts)
                    elseif
                        (type(opts) == "string" and attr ~= "link")
                        or ((attr == "fg" or attr == "bg") and type(opts) == "table" and #opts ~= 0)
                    then
                        --string/string[]
                        result[attr] = get_attr(opts)
                    else
                        --boolean
                        result[attr] = opts
                    end
                end
                result.force = true
                vim.api.nvim_set_hl(0, hl_name, result)
            end
        end
    end
end
return {
    get_attr = get_attr,
    transform_one = transform_one,
    mkhandle = __mk_handle,
}
