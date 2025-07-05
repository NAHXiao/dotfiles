return {
    "xiyaowong/nvim-transparent",
    version = "*",
    lazy = false,
    cmd = { "TransparentToggle" },
    keys = {
        { "<leader>\\", ":TransparentToggle<CR>", mode = "n", silent = true },
    },
    config = function()
        require("transparent").setup({
            exclude_groups = {
                "CursorLine",
            },
            on_clear = function()
                for k, v in pairs({
                    Linenr = { fg = "#ffffff" },
                    CursorLineNr = { fg = "#ffffff" },
                    Visual = { bg = "#5c5f75" },
                    IlluminatedWordWrite = { underline = true },
                    IlluminatedWordText = { underline = true },
                    IlluminatedWordRead = { underline = true },
                    TroubleNormal = { link = "Normal" },
                }) do
                    vim.api.nvim_set_hl(0, k, v)
                end
            end,
        })
    end,
}
