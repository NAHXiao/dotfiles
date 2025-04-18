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
                local last_line = vim.api.nvim_buf_line_count(bufnr)
                -- 获取最后一行结束的偏移量,即为整个buffer的大小(字节)
                local size = vim.api.nvim_buf_get_offset(bufnr, last_line)
                return (size / 1024) <= 500 --NOTE: <=500k则True
            end,
        })
    end,
}
