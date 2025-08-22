return {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = true,
    version = "*",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    config = function()
        require("render-markdown").setup {
            on = {
                initial = function(ctx)
                    if vim.api.nvim_win_get_config(ctx.win).relative ~= "" then
                        local height = vim.api.nvim_win_text_height(ctx.win, {}).all
                        vim.api.nvim_win_set_height(ctx.win, math.max(3, height))
                        local width = vim.api.nvim_win_get_width(ctx.win)
                        vim.api.nvim_win_set_width(ctx.win, math.max(10, width))
                    end
                end,
            },
            completions = {
                blink = { enabled = true },
                lsp = { enabled = true },
            },
            filetype = {
                "markdown",
                "vimviki",
            },
            latex = {
                enable = false,
            },
        }
        vim.treesitter.language.register("markdown", "vimwiki")
    end,
}
