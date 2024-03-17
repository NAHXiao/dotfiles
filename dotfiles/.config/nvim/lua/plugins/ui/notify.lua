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
            stages = "static",
            top_down = true,
        }
        vim.notify = notify
    end,
}
