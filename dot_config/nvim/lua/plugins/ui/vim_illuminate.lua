-- Highlight other uses of word under cursor (光标下的word高亮)
return {
    "RRethy/vim-illuminate",
    version = "*",
    lazy = true,
    event = "VeryLazy",
    init = function()
        vim.g.transparent_groups_map = vim.tbl_extend("force", vim.g.transparent_groups_map or {}, {
            IlluminatedWordWrite = { underline = true },
            IlluminatedWordText = { underline = true },
            IlluminatedWordRead = { underline = true },
        })
    end,
    config = function()
        require("illuminate").configure({
            providers = {
                "treesitter",
                "lsp",
                "regex",
            },
            delay = 100,
            under_cursor = true,
            filetypes_denylist = {
                "neo-tree",
            },
            should_enable = function(bufnr)
                return not require("utils").is_bigfile(bufnr)
            end,
            disable_keymaps = true,
        })
    end,
}
