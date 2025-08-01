-- Highlight other uses of word under cursor (光标下的word高亮)
return {
    "RRethy/vim-illuminate",
    version = "*",
    lazy = true,
    event = "VeryLazy",
    keys = {
        {
            "<leader>\\w",
            "<cmd>IlluminateToggle<cr>",
            desc = "Toggle Illuminate(Same Word Highlight)",
        },
    },
    init = function()
        require("tools.hl").regist_transparent({
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
