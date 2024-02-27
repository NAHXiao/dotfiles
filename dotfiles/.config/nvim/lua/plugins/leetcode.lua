return {
    "ianding1/leetcode.vim",
    -- "mbledkowski/neuleetcode.vim",
    version = "*",
    lazy = true,
    keys = {
        { "<leader>ll", ":LeetCodeList<cr>" },
        { "<leader>lt", ":LeetCodeTest<cr>" },
        { "<leader>ls", ":LeetCodeSubmit<cr>" },
        { "<leader>li", ":LeetCodeSignIn<cr>" },
    },
    config = function()
        -- vim.cmd([[
        local g = vim.g
        g.leetcode_china = 1
        g.leetcode_solution_filetype = 'cpp'
        g.leetcode_browser = 'chrome'
        --]])
    end,
}
