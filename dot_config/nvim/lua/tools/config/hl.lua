local M = {}
M.transparent_groups = {
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

M.transparent_extra_groups = {}
M.transparent_group_prefix_list = {}
---@type HighlightTransformRegistMap
M.color_trans_tbl = {}
---@type HighlightTransformRegistMap
M.color_transparent_trans_tbl = {
    Linenr = { fg = "Normal.fg" },
    CursorLineNr = { fg = { transform = "lighten", from = "Normal.fg", amount = 5 } },
    Visual = { bg = { transform = "lighten", from = "Visual.bg", amount = 0.2 } },
    LspInlayHint = {
        bg = { transform = "darken", from = "Cursor.bg", amount = 0.1, },
        fg = "Cursor.fg",
    },
}
return M
