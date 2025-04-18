return {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    keys = {
        -- { "<leader>fn", "<cmd>Telescope notify<cr>" },
    },
    cond = vim.version.cmp(vim.version(), "0.10.0") >= 0,
    config = function()
        local notify = require("notify")
        notify.setup({
            render = "minimal",
            stages = "static", --"fade",
            top_down = false,
        })
        vim.notify = notify
    end,
}
