return {
    "xiyaowong/nvim-transparent",
    version = "*",
    lazy = false,
    cmd = { "TransparentToggle" },
    keys = {
        { "<leader>\\", ":TransparentToggle<CR>", mode = "n", silent = true },
    },
    init = function()
        vim.g.transparent_groups_map = vim.tbl_extend("force", vim.g.transparent_groups_map or {}, {
            Linenr = { fg = "#ffffff" },
            CursorLineNr = { fg = "#ffffff" },
            Visual = { bg = "#5c5f75" },
        })
    end,
    config = function()
        local function on_clear()
            for k, v in pairs(vim.g.transparent_groups_map) do
                vim.api.nvim_set_hl(0, k, v)
            end
        end
        if vim.g.is_win then
            require("utils").wrapmetaable_newindex(vim.g, "transparent_enabled", true, function()
                vim.defer_fn(on_clear, 100)
            end)
        end
        require("transparent").setup({
            exclude_groups = {
                "CursorLine",
            },
            on_clear = on_clear, -- Not work on windows
        })
    end,
}
