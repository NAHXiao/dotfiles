return {
    'stevearc/overseer.nvim',
    opts = {},
    cond = false,
    enable = false,
    lazy = true,
    keys = {
        { '<leader>or', '<cmd>OverseerRun<CR>' },
        { '<leader>ot', '<cmd>OverseerToggle<CR>' },
        { '<leader>oa', '<cmd>OverseerQuickAction<CR>' },
        { '<c-p>',      '<cmd>OverseerRun<CR><cr>' },
    },
    config = function()
        require('overseer').setup({
            templates = {
                "builtin",
                "user.cpp_build",
                "user.cpp_build_debug",
                "user.cpp_run",
                "user.java_build",
                "user.java_run",
                "user.python_run"
            }
        })
    end,
}
