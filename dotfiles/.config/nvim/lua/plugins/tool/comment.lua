return {
    "numToStr/Comment.nvim",
    version = "*",
    lazy = true,
    --   -- Comment.nvim configuration
    -- -- current line
    -- vim.keymap.set('n', '<C-/>', '<Plug>(comment_toggle_linewise_current)')
    -- vim.keymap.set('v', '<C-.>', '<Plug>(comment_toggle_blockwise_current)')
    --
    -- -- Toggle in VISUAL mode
    -- vim.keymap.set('x', '<C-/>', '<Plug>(comment_toggle_linewise_visual)')
    -- vim.keymap.set('x', '<C-.>', '<Plug>(comment_toggle_blockwise_visual)')
    --
    -- vim.keymap.set('n', 'cc', '<Plug>(comment_toggle_linewise_current)')
    -- vim.keymap.set('n', 'cb', '<Plug>(comment_toggle_blockwise_current)')
    keys = {
        { "<C-/>", "<Plug>(comment_toggle_linewise_current)",   mode = "n" },
        { "<C-.>", "<Plug>(comment_toggle_blockwise_current)",  mode = "v" },
        { "<C-/>", "<Plug>(comment_toggle_linewise_visual)",    mode = "x" },
        { "<C-.>", "<Plug>(comment_toggle_blockwise_visual)",   mode = "x" },
        { "cc",    "<Plug>(comment_toggle_linewise_current)",   mode = "n" },
        { "cc",    "<Plug>(comment_toggle_linewise_current)",   mode = "x" },
        { "cc",    "<Plug>(comment_toggle_linewise_current)",   mode = "v" },
        { "cb",    "<Plug>(comment_toggle_blockwise_current)",  mode = "n" },
        { "cb",    "<Plug>(comment_toggle_blockwise_current)",  mode = "x" },
        { "cb",    "<Plug>(comment_toggle_blockwise_current)",  mode = "v" },
    },
    config = function()
        require('Comment').setup()
    end,
}
