return {
    "xiyaowong/nvim-transparent",
    version = "*",
    lazy = true,
    keys = {
        { "<leader>\\", ":TransparentToggle<CR>", mode = "n" },
    },
    config = function()
        -- require("transparent").setup({
        --     groups = {
        --         "NormalFloat",
        --     },
        -- })
    end,
}
