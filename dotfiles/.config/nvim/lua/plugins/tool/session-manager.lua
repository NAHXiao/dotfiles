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
    },
    config = function()
        -- local config = require "session_manager.config"
        require("session_manager").setup({
            -- autoload_mode = config.AutoloadMode.Disabled,
            autosave_last_session = false,
        })

        -- Convert the cwd to a simple file name
        -- local function get_cwd_as_name()
        --     local dir = vim.fn.getcwd(0)
        --     return dir:gsub("[^A-Za-z0-9]", "%")
        -- end

        -- vim.api.nvim_create_autocmd("User", {
        --     pattern = "SessionSavePre",
        --     desc = "Save overseer tasks",
        --     callback = function()
        -- local overseer = require "overseer"
        -- local task_name = get_cwd_as_name()
        --
        -- -- Remove the task if it exists
        -- if vim.tbl_contains(overseer.list_task_bundles(), task_name) then
        --     overseer.delete_task_bundle(task_name)
        -- end
        --
        -- overseer.save_task_bundle(
        --     get_cwd_as_name(),
        --     overseer.list_tasks {
        --         status = "RUNNING",
        --     },
        --     { on_conflict = "overwrite" }
        -- )
        -- end,
        -- })

        -- vim.api.nvim_create_autocmd("User", {
        -- pattern = "SessionLoadPost",
        -- desc = "Load overseer tasks",
        -- callback = function()
        -- local overseer = require "overseer"
        -- local gitsigns = require "gitsigns"

        -- overseer.load_task_bundle(get_cwd_as_name(), { ignore_missing = true })
        -- gitsigns.refresh()
        -- end,
        -- })
    end,
}
