return {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    keys = {
        -- { "<leader>fn", "<cmd>Telescope notify<cr>" },
    },
    config = function()
        local notify = require "notify"
        notify.setup {
            render = "minimal",
            stages = "static", --"fade",
            top_down = false,
        }
        vim.notify = notify
    end,
}
