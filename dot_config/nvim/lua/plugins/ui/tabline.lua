return {
    "mg979/tabline.nvim",
    init = function()
        vim.o.showtabline = 2
    end,
    lazy = true,
    event = "BufEnter",
    opts = {},
    config = function(_, opts)
        local tabline = require "tabline.setup"

        tabline.setup(opts)
        tabline.mappings(true)
    end,
}
