return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    lazy = false,
    -- cmd='Telescope',
    -- event='VeryLazy',
    dependencies={
    'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
        --- Telescope ---
        require('telescope').setup{}
    end,
}
