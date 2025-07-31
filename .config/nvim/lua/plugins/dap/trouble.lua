return {
    "folke/trouble.nvim",
    version = "*",
    keys = {
        {
            "<leader>ta",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>tb",
            "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<leader>s",
            "<cmd>Trouble symbols toggle focus=false<cr>",
            desc = "Symbols (Trouble)",
        },
    },
    commander = {
        {
            cmd = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
            desc = "LSP Definitions / references / ... (Trouble)",
        },
        {
            cmd = "<cmd>Trouble loclist toggle<cr>",
            desc = "Location List (Trouble)",
        },
        {
            cmd = "<cmd>Trouble qflist toggle<cr>",
            desc = "Quickfix List (Trouble)",
        },
    },
    cmd = "Trouble",
    lazy = true,
    init = function()
        require("tools.hl").regist({ TroubleNormal = { link = "Normal" } })
    end,
    config = function()
        require("trouble").setup()
    end,
}
