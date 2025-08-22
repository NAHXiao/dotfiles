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
        -- {
        --     "<leader>s",
        --     "<cmd>Trouble symbols toggle focus=false<cr>",
        --     desc = "Symbols (Trouble)",
        -- },
    },
    cmd = "Trouble",
    lazy = true,
    config = function()
        require("trouble").setup()
        require("tools.hl").register(
            { TroubleNormal = { link = "Normal" } },
            { dependency = "outer<-inner", type = "transparent" }
        )
    end,
}
--[[
+q+w+e+r*t*y-u-i-o-p
+a+s+d+f+g*h-j-k-l-;
-z-x-c-v-b-n-m
abdfg
]]
