return {
    'rmagatti/auto-session',
    version = "*",
    lazy = false,
    -- module = false,
    -- event = { "VeryLazy" },
    cmd = "Telescope",
    -- map('n', '<leader>se', ':lua require("auto-session.session-lens").search_session<cr>')
    -- map('n', '<leader>ss', ":SessionSave<cr>")
    -- map('n', '<leader>sd', ":SessionDelete<cr>")

    keys = {
        { "<leader>se", ":lua require('auto-session.session-lens').search_session()<cr>" },
        { "<leader>ss", ":SessionSave<cr>" },
        { "<leader>sd", ":SessionDelete<cr>" },
    },
    dependencies = {
        -- "nvim-telescope/telescope.nvim",
    },
    init = function()
        local opts = {
            log_level = 'info',
            auto_session_enable_last_session = false,
            auto_session_root_dir = vim.fn.stdpath('data') .. "/sessions/",
            auto_session_enabled = false,
            auto_save_enabled = false,
            auto_restore_enabled = false,
            auto_session_use_git_branch = false,
            -- the configs below are lua only
            auto_session_suppress_dirs = { "~/", "~/workspace", "~/Downloads", "/", "~/workspace/*", "~/workspace/*/*", "~/workspace/*/*/*" },
            -- auto_session_suppress_dirs = true,
            bypass_session_save_file_types = nil,
            session_lens = {
                -- If load_on_setup is set to false, one needs to eventually call `require("auto-session").setup_session_lens()` if they want to use session-lens.
                buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
                load_on_setup = true,
                theme_conf = { border = true },
                previewer = false,
            },
        }
        require('auto-session').setup(opts)
    end,
    -- priority = 999, --解决偶发的telescope session_lens命令失败
    config = function()
        require("telescope").load_extension "session-lens"
        vim.keymap.set("n", "<leader>se", require("auto-session.session-lens").search_session, {
            noremap = true,
        })
    end,
}
