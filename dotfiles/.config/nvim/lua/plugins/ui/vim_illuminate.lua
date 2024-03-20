-- Highlight other uses of word under cursor (光标下的word高亮)
return {
    "RRethy/vim-illuminate",
    version = "*",
    lazy = true,
    event='VeryLazy',
    config = function()
        require('illuminate').configure({
            providers = {
                'lsp',
                -- 'treesitter',
                'regex',
            },

        })
    end,
}
