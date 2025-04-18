return {
    "max397574/better-escape.nvim",
    version = "*",
    lazy = true,
    dependencies = {},
    event = { "InsertEnter", "TermEnter" },
    config = function()
        require("better_escape").setup({
            timeout = vim.o.timeoutlen,
            default_mappings = false,
            mappings = {
                i = {
                    j = {
                        -- These can all also be functions
                        k = "<Esc>",
                        j = "<Esc>",
                    },
                },
                c = {
                    j = {
                        k = "<Esc>",
                        j = "<Esc>",
                    },
                },
                t = {
                    j = {
                        k = "<C-\\><C-n>",
                    },
                },
                v = {
                    -- j = {
                    --     k = "<Esc>",
                    -- },
                },
                s = {
                    j = {
                        k = "<Esc>",
                    },
                },
            },
        })
    end,
}
