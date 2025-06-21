return {
    "xiyaowong/nvim-transparent",
    version = "*",
    lazy = false,
    cmd = { "TransparentToggle" },
    keys = {
        { "<leader>\\", ":TransparentToggle<CR>", mode = "n", silent = true },
    },
    config = function()
        require("utils").wrapmetaable_newindex(vim.g, "transparent_enabled", true, function()
            vim.defer_fn(function()
                for k, v in pairs({
                    Linenr = { fg = "#ffffff" },
                    CursorLineNr = { fg = "#ffffff" },
                    Visual = { bg = "#5c5f75" },
                }) do
                    vim.api.nvim_set_hl(0, k, v)
                end
            end, 10)
        end)
        require("transparent").setup({
            exclude_groups = {
                "CursorLine",
            },
        })
    end,
}
