return {
    "lukas-reineke/indent-blankline.nvim",
    version = "*",
    main='ibl',
    lazy = true,
    ft={'cpp','rust','lua','python','vim','sh','yaml','json','html','css','javascript','typescript','vue','svelte','markdown','yaml','toml','dockerfile','lua','vim','sh','zsh','bash','fish','yaml','json','html','css','javascript','typescript','vue','svelte','markdown','yaml','toml','dockerfile'},
    config = function()
        require("ibl").setup()
    end,
}
