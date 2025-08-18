---From https://github.com/brglng/dotfiles/blob/master/config/nvim/lua/brglng/hl.lua

local color = require("libs.color")
---@alias color_type string | number
---@param hl_fallback_list color_type | color_type[]
---Example
---```lua
---local fg = get_attr({"Visual.fg","CursorLine.fg","red","#ff0000",16113884})
---```
local function get_color_attr(hl_fallback_list)
    if type(hl_fallback_list) == "string" or type(hl_fallback_list) == "number" then
        hl_fallback_list = { hl_fallback_list }
    end
    for _, hl_fallback in ipairs(hl_fallback_list) do
        if type(hl_fallback) == "string" then
            local name, attr = hl_fallback:match("^([^%.]+)%.([^%.]+)$")
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
                not hl_fallback:find(".", 1, true)
                and vim.api.nvim_get_color_by_name(hl_fallback) ~= -1
            then
                return vim.api.nvim_get_color_by_name(hl_fallback)
            else
                error("Invalid highlight color: " .. hl_fallback)
            end
        elseif type(hl_fallback) == "number" then
            return hl_fallback
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
---@field from? color_type|color_type[]
---@field fg? color_type|color_type[]
---@field bg? color_type|color_type[]
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
    local transform = opts.transform
    if transform == "lighten" then
        assert(type(opts.from) == "string" or type(opts.from) == "number" or type(opts.from) == "table",
            "lighten requires `from`")
        assert(type(opts.amount) == "number", "lighten requires `amount`")
        return color.lighten(get_color_attr(opts.from), opts.amount)
    elseif transform == "darken" then
        assert(type(opts.from) == "string" or type(opts.from) == "number" or type(opts.from) == "table",
            "darken requires `from`")
        assert(type(opts.amount) == "number", "darken requires `amount`")
        return color.darken(get_color_attr(opts.from), opts.amount)
    elseif transform == "emboss" then
        assert(type(opts.from) == "string" or type(opts.from) == "number" or type(opts.from) == "table",
            "emboss requires `from`")
        assert(type(opts.amount) == "number", "emboss requires `amount`")
        return color.emboss(get_color_attr(opts.from), opts.amount)
    elseif transform == "deboss" then
        assert(type(opts.from) == "string" or type(opts.from) == "number" or type(opts.from) == "table",
            "deboss requires `from`")
        assert(type(opts.amount) == "number", "deboss requires `amount`")
        return color.deboss(get_color_attr(opts.from), opts.amount)
    elseif transform == "interpolate" then
        assert(type(opts.from) == "table" and #opts.from == 2, "interpolate requires `from`")
        assert(type(opts.mix) == "number", "interpolate requires `mix`")
        return color.interpolate(get_color_attr(opts.from[1]), get_color_attr(opts.from[2]), opts.mix)
    elseif transform == "middle" then
        assert(type(opts.from) == "table" and #opts.from == 2, "middle requires `from` as table and `#from` should == 2")
        assert(type(opts.mix) == "number", "middle requires `mix`")
        return color.middle(get_color_attr(opts.from[1]), get_color_attr(opts.from[2]))
    elseif transform == "blend" then
        assert(
            (type(opts.fg) == "string" or type(opts.fg) == "number" or type(opts.fg) == "table")
            and (type(opts.bg) == "string" or type(opts.fg) == "number" or type(opts.bg) == "table"),
            "blend requires `fg` and `bg`"
        )
        assert(type(opts.opacity) == "number", "blend requires `opacity`")
        return color.blend(get_color_attr(opts.fg), get_color_attr(opts.bg), opts.opacity)
    else
        error("Invalid highlight transform: " .. vim.inspect(opts))
    end
end
---sp,default,ctermfg,ctermebg,cterm not support
---@alias HighlightTransformDef string | number | (string|number)[] | HighlightTransform
---@alias HighlightTable HighlightTransformTable|vim.api.keyset.get_hl_info
---@class HighlightTransformTable
---@field  fg? (HighlightTransformDef | fun():HighlightTransformDef)
---@field  bg? (HighlightTransformDef | fun():HighlightTransformDef)
---@field  blend? integer
---@field  bold? boolean
---@field  standout? boolean
---@field  underline? boolean
---@field  undercurl? boolean
---@field  underdouble? boolean
---@field  underdotted? boolean
---@field  underdashed? boolean
---@field  strikethrough? boolean | string
---@field  italic? boolean
---@field  reverse? boolean | string
---@field  nocombine? boolean | string
---@field  link? string
---@alias HighlightTransformRegistMap table<string, HighlightTable |fun():HighlightTable>
---@param tbl HighlightTransformRegistMap
---@return fun():table<string,string> err
local function __mk_handle(tbl)
    return function()
        local keys = {}
        for k, _ in pairs(tbl) do
            keys[#keys + 1] = k
        end
        table.sort(keys)
        local errs = {}
        for _, hl_name in ipairs(keys) do
            local set = function()
                local hl_opts = tbl[hl_name]
                local result = {}
                if type(hl_opts) == "function" then
                    hl_opts = hl_opts()
                end
                ---@cast hl_opts HighlightTransformTable
                for attr, opts in pairs(hl_opts or {}) do
                    if attr == "fg" or attr == "bg" then
                        if type(opts) == "function" then
                            opts = opts()
                        end
                        ---@cast opts string | string[] | HighlightTransform
                        if type(opts) == "table" and opts.transform then
                            ---@cast opts HighlightTransform
                            result[attr] = transform_one(opts)
                        else
                            result[attr] = get_color_attr(opts)
                        end
                    else
                        result[attr] = opts
                    end
                end
                result.force = true
                vim.api.nvim_set_hl(0, hl_name, result)
            end
            local ok, err = pcall(set)
            if not ok then
                errs[hl_name] = err
            end
        end
        return errs
    end
end
return {
    get_color_attr = get_color_attr,
    transform_one = transform_one,
    mkhandle = __mk_handle,
}
