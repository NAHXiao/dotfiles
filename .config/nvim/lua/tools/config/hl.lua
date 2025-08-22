local M = {}
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
return M
