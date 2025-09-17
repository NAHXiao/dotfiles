local M = {}
local path = vim.fn.stdpath("data") .. package.config:sub(1, 1) .. "nvim_transparent_cache"
---@type boolean
M.transparent_enabled = nil
---@type boolean
M.use_lightbg = nil
function M.read_config()
    local exists, lines = pcall(vim.fn.readfile, path)
    M.transparent_enabled = exists and #lines > 0 and vim.trim(lines[1]) == "true"
    M.use_lightbg = exists and #lines > 1 and vim.trim(lines[2]) == "true"
end
function M.save_config()
    assert(M.transparent_enabled ~= nil and M.use_lightbg ~= nil)
    vim.fn.writefile({ tostring(M.transparent_enabled), tostring(M.use_lightbg) }, path)
end

---@type table<string,HighlightTable|fun():HighlightTable>
M.colorscheme_idi = {
    FoldColumn = { link = "Normal" },
}

---@type table<string,HighlightTable|fun():HighlightTable>
M.transparent_idi = {
    Linenr = { fg = "Normal.fg" },
    CursorLineNr = { fg = { transform = "lighten", from = "Normal.fg", amount = 5 } },
    Visual = { bg = { transform = "lighten", from = "Visual.bg", amount = 0.2 } },
    LspInlayHint = {
        bg = { transform = "darken", from = { "Cursor.bg", "Normal.fg" }, amount = 0.15 },
        fg = { "Cursor.fg", "Normal.bg" },
    },
}
---@type table<string>
M.transparent_groups_idi = {
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

    "FloatBorder",
    "FloatFooter",
    "FloatTitle",

    "NormalFloat",
    "Pmenu",
    "PmenuExtra",
}
M.read_config()
M.save_config()
return M
