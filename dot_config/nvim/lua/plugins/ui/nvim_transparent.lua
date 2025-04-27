return {
    "xiyaowong/nvim-transparent",
    version = "*",
    lazy = false,
    cmd = { "TransparentToggle" },
    keys = {
        { "<leader>\\", ":TransparentToggle<CR>", mode = "n" },
    },
    config = function()
        require("transparent").setup({
            exclude_groups = {
                "CursorLine",
                "CursorLine",
            },
        })
    end,
}
