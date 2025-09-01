--TODO: disable for binary file
return {
    "folke/flash.nvim",
    opts = {
        modes = {
            search = {
                enabled = true,
                highlight = {
                    backdrop = true,
                },
            },
            char = {
                enabled = false,
            },
            treesitter = {
                highlight = {
                    backdrop = true,
                },
            },
        },
    },
    lazy = true,
    event = "CmdlineEnter",
    keys = {
        {
            "s",
            mode = { "n" },
            function()
                require("flash").treesitter()
            end,
            desc = "Select Treesitter Node",
        },
        {
            "S",
            mode = { "n" },
            function()
                require("flash").treesitter_search()
            end,
            desc = "Search Treesitter Node",
        },
        {
            "<leader>\\s",
            "<cmd>lua require('flash').toggle()<cr>",
            desc = "Toggle Flash Search",
        },
    },
    config = function(_, opts)
        require("flash").setup(opts)
        require("tools.hl").register({
            FlashLabel = {
                fg = "FlashLabel.fg",
                bg = { transform = "darken", from = "FlashLabel.fg", amount = 0.5 },
            },
            FlashMatch = {
                fg = "FlashMatch.fg",
                bg = { transform = "darken", from = "FlashMatch.fg", amount = 0.5 },
            },
        }, {
            dependency = "outer<-outer",
            type = "transparent",
        })
    end,
}
