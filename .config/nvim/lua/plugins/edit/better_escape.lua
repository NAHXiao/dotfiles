return {
    "max397574/better-escape.nvim",
    version = "*",
    lazy = true,
    dependencies = {},
    event = { "InsertEnter", "TermEnter" },
    config = function()
        local esc = function()
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                "m",
                true
            )
        end
        require("better_escape").setup {
            timeout = vim.o.timeoutlen,
            default_mappings = false,
            mappings = {
                i = {
                    j = {
                        k = esc,
                        j = esc,
                    },
                },
                -- c= {
                --     j = {
                --         k = esc,
                --         j = esc,
                --     },
                -- },
                -- t = {
                --     j = {
                --         k = "<C-\\><C-n>",
                --     },
                -- },
                -- v = {
                --     j = {
                --         k = "<Esc>",
                --     },
                -- },
                -- s = {
                --     j = {
                --         k = esc,
                --         j = esc,
                --     },
                -- },
            },
        }
    end,
}
