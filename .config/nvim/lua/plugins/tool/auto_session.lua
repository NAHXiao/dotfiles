return {
    "rmagatti/auto-session",
    version = "*",
    enable = false,
    cond = false,
    lazy = true,
    -- module = false,
    event = { "VeryLazy" }, --BufRead后
    keys = {
        {
            "<leader>se",
            function()
                require("auto-session.session-lens").search_session()
            end,
        },
        { "<leader>ss", ":SessionSave<cr>" },
        { "<leader>sd", ":SessionDelete<cr>" },
    },
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    init = function() end,
    config = function()
        local opts = {
            log_level = "info",
            auto_session_enable_last_session = false,
            auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
            auto_session_enabled = false,
            auto_save_enabled = false,
            auto_restore_enabled = false,
            auto_session_use_git_branch = false,
            -- the configs below are lua only
            auto_session_suppress_dirs = {
                "~/",
                "~/workspace",
                "~/Downloads",
                "/",
                "~/workspace/*",
                "~/workspace/*/*",
                "~/workspace/*/*/*",
            },
            -- auto_session_suppress_dirs = true,
            bypass_session_save_file_types = nil,
            session_lens = {
                -- If load_on_setup is set to false, one needs to eventually call `require("auto-session").setup_session_lens()` if they want to use session-lens.
                buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
                load_on_setup = false,
                theme_conf = { border = true },
                previewer = true,
            },
        }
        require("auto-session").setup(opts)
    end,
}
