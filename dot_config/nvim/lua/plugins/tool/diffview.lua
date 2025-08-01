return {
    "sindrets/diffview.nvim",
    version = "*",
    lazy = true,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    init=function()
    end,
    config = function()
        local actions = require("diffview.actions")
        require("diffview").setup({
            require("transparent").setup({ -- Optional, you don't have to run setup.
                groups = { -- table: default groups
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
                    "CursorLine",
                    "CursorLineNr",
                    "StatusLine",
                    "StatusLineNC",
                    "EndOfBuffer",
                },
                extra_groups = {}, -- table: additional groups that should be cleared
                exclude_groups = {}, -- table: groups you don't want to clear
            }),
        })
    end,
}
