return {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
        code_lenses = true,
        sign = {
            enabled = false,
        },
        virtual_text = {
            enabled = true,
        },
        autocmd = {
            enabled = true,
            updatetime = -1,
            events = { "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" },
        },
        ignore = {
            ft = {
                "toggleterm",
                "neo-tree",
                "terminal",
            },
        },
    },
    config = function(_, opts)
        require("nvim-lightbulb").setup(opts)
        require("tools.hl").register_transparent({ "LightBulbVirtualText" }, {
            dependency = "outer<-outer",
            type =
            "transparent"
        })
    end,
}
