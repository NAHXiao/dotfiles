-- Highlight other uses of word under cursor (光标下的word高亮)
return {
    "RRethy/vim-illuminate",
    version = "*",
    lazy = true,
    -- cond=
    event = "VeryLazy",
    config = function()
        require("illuminate").configure({
            providers = {
                "lsp",
                -- 'treesitter',
                "regex",
            },
            delay = 100,
            under_cursor = true,
            max_file_lines = 3000,
            should_enable = function(bufnr)
                require("utils").is_bigfile(bufnr)
            end,
        })
    end,
}
