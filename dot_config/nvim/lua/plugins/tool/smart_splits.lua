local function cond() -- not float
    local cfg = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win())
    return not ((cfg.relative ~= "" and cfg.relative ~= nil) or cfg.external == true)
end

return {
    "mrjones2014/smart-splits.nvim",
    lazy = true,
    keys = {
        {
            "<A-S-h>",
            function()
                return cond() and require("smart-splits").resize_left()
            end,
            desc = "Resize split left",
            mode = { "n", "t" },
        },
        {
            "<A-S-j>",
            function()
                return cond() and require("smart-splits").resize_down()
            end,
            desc = "Resize split down",
            mode = { "n", "t" },
        },
        {
            "<A-S-k>",
            function()
                return cond() and require("smart-splits").resize_up()
            end,
            desc = "Resize split up",
            mode = { "n", "t" },
        },
        {
            "<A-S-l>",
            function()
                return cond() and require("smart-splits").resize_right()
            end,
            desc = "Resize split right",
            mode = { "n", "t" },
        },
    },
    config = function()
        require("smart-splits").setup {
            ignored_buftypes = {
                "prompt",
            },
            ignored_filetypes = {},
            default_amount = 3,
            at_edge = "stop",
        }
    end,
}
