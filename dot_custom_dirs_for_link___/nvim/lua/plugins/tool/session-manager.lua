return {
    "Shatur/neovim-session-manager",
    lazy = true,
    event = "VeryLazy",
    -- enable=false,
    -- cond=false,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        { "<leader>sl", "<cmd>SessionManager load_session<CR>",         desc = "Session Load selected" },
        { "<leader>sd", "<cmd>SessionManager delete_session<CR>",       desc = "Session Delete" },
        { "<leader>ss", "<cmd>SessionManager save_current_session<CR>", desc = "Session Save" },
        { "<leader>sm", "<cmd>SessionManager <CR>",                     desc = "Session Manager" },
    },
    config = function()
        local Path = require('plenary.path')
        local path_replacer = '\t'
        local colon_replacer = '\b'
        local config = {
            autosave_last_session = false,
            sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
        }
        config.session_filename_to_dir = function(filename)
            local dir = filename:sub(#tostring(config.sessions_dir) + 2)
            dir = dir:gsub(colon_replacer, ':')
            dir = dir:gsub(path_replacer, Path.path.sep)
            return Path:new(dir)
        end
        config.dir_to_session_filename = function(dir)
            local filename = dir:gsub(':', colon_replacer)
            filename = filename:gsub(Path.path.sep, path_replacer)
            return Path:new(config.sessions_dir):joinpath(filename)
        end
        require("session_manager").setup(config)

        vim.api.nvim_create_autocmd("User", {
            pattern = "SessionSavePost",
            desc = "notify",
            callback = function()
                vim.notify("Session save success")
            end
        })
    end,
}
