return {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = true,
    ft = { "markdown", "vimwiki" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    config = function()
        -- Create Once Autocmd (InsertEnter)
        -- vim.api.nvim_create_autocmd("InsertEnter", {
        --     callback = function()
        --         vim.defer_fn(function()
        require("render-markdown").setup({
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
        })
        vim.treesitter.language.register("markdown", "vimwiki")
        --         end, 100)
        --     end,
        --     once = true,
        -- })
    end,
}
