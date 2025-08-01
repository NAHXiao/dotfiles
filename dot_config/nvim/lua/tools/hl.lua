local M = {}
local __mk_handle = require("libs.hl").mkhandle
local path = vim.fn.stdpath("data") .. package.config:sub(1, 1) .. "nvim_transparent_cache"
local transparent_enabled
---@type HighlightTransformRegistMap
local __color_trans_tbl = {}
---@type HighlightTransformRegistMap
local __transparent_trans_tbl = {
    Linenr = { fg = "Normal.fg" },
    CursorLineNr = { fg = { transform = "lighten", from = "Normal.fg", amount = 5 } },
    Visual = { bg = { transform = "lighten", from = "Visual.bg", amount = 0.2 } },
}
local function readswitch()
    local exists, lines = pcall(vim.fn.readfile, path)
    transparent_enabled = exists and #lines > 0 and vim.trim(lines[1]) == "true"
end
local function writeswitch()
    vim.fn.writefile({ tostring(transparent_enabled) }, path)
end
local transparent_groups = {
    "Normal",
    "NormalNC",
    "Comment",
    "Constant",
    "Special",
    "Identifier",
    "Statement",
    "PreProc",
    "Type",
    "Underlined",
    "Todo",
    "String",
    "Function",
    "Conditional",
    "Repeat",
    "Operator",
    "Structure",
    "LineNr",
    "NonText",
    "SignColumn",
    -- "CursorLine",
    "CursorLineNr",
    "StatusLine",
    "StatusLineNC",
    "EndOfBuffer",
}
local transparent_extra_groups = {}
local transparent_group_prefix_list = {}
---@param group string|string[]
local function clear_group(group)
    local groups = type(group) == "string" and { group } or group
    ---@cast groups string[]
    for _, v in ipairs(groups) do
        local ok, prev_attrs = pcall(vim.api.nvim_get_hl_by_name, v, true)
        if ok and (prev_attrs.background or prev_attrs.bg or prev_attrs.ctermbg) then
            local attrs = vim.tbl_extend("force", prev_attrs, { bg = "NONE", ctermbg = "NONE" })
            attrs[true] = nil
            vim.api.nvim_set_hl(0, v, attrs)
        end
    end
end
local function clear()
    clear_group(transparent_groups)
    clear_group(transparent_extra_groups)
    for _, prefix in ipairs(transparent_group_prefix_list) do
        clear_group(vim.fn.getcompletion(prefix, "highlight"))
    end
end
---@param groups string[]
function M.add_transparent_groups(groups)
    for _, group in ipairs(groups) do
        if not vim.list_contains(transparent_extra_groups, group) then
            transparent_extra_groups[#transparent_extra_groups + 1] = group
        end
    end
    if transparent_enabled then
        clear_group(transparent_extra_groups)
    end
end
---@param prefixs string[]
function M.add_transparent_groupprefix(prefixs)
    for _, prefix in ipairs(prefixs) do
        if not vim.list_contains(transparent_group_prefix_list, prefix) then
            transparent_group_prefix_list[#transparent_group_prefix_list + 1] = prefix
        end
    end
    if transparent_enabled then
        for _, prefix in ipairs(transparent_group_prefix_list) do
            clear_group(vim.fn.getcompletion(prefix, "highlight"))
        end
    end
end
function M.regist(tbl)
    for hlname, hlopts in pairs(tbl) do
        __color_trans_tbl[hlname] = hlopts
    end
    __mk_handle(tbl)()
end
function M.regist_transparent(tbl)
    for hlname, hlopts in pairs(tbl) do
        __transparent_trans_tbl[hlname] = hlopts
    end
    if transparent_enabled then
        __mk_handle(tbl)()
        clear()
    end
end
local __running
local __handle = function()
    if __running then
        return
    end
    __running = true
    if vim.g.colors_name then
        pcall(vim.cmd.colorscheme, vim.g.colors_name)
    end
    __mk_handle(__color_trans_tbl)()
    if transparent_enabled then
        __mk_handle(__transparent_trans_tbl)()
        clear()
    end
    __running = false
end
---@return boolean
function M.get_transparent()
    return transparent_enabled or false
end
---@param on? boolean
function M.toggle_transparent(on)
    if on then
        transparent_enabled = on
    else
        transparent_enabled = not transparent_enabled
    end
    writeswitch()
    __handle()
end
function M.setup()
    readswitch()
    writeswitch()
    vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
        callback = __handle,
    })
    vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        callback = __handle,
    })
    require("utils").map("n", "<leader>\\\\", function()
        M.toggle_transparent()
        require("utils").vim_echo(("Transparent: %s"):format(M.get_transparent() and "On" or "Off"))
    end, { desc = "Toggle transparent" })
end
return M
