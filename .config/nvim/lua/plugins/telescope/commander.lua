return {
    "FeiyouG/commander.nvim",
    lazy = true,
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
        {
            "<C-p>",
            function()
                -- TeleMultiplexSearch(require("commander").show, {}, "Commands Panel")
                require("commander").show()
            end,
            desc = "show commands panel",
        },
    },

    config = function()
        -- local Commander = require("commander.model.Command")
        -- function Commander:default_add_opts()
        --     return {
        --         cat = "custom",
        --         set = true,
        --         show = true,
        --     }
        -- end
        require("commander").setup({
            -- Specify what components are shown in the prompt;
            -- Order matters, and components may repeat
            components = {
                "CAT",
                "DESC",
                "CMD",
                "KEYS",
            },

            -- Specify by what components the commands is sorted
            -- Order does not matter
            sort_by = {
                "CAT",
                "DESC",
                "CMD",
                "KEYS",
            },
            -- Change the separator used to separate each component
            separator = " ",
            auto_replace_desc_with_cmd = true,
            prompt_title = "Commands Panel",

            integration = {
                telescope = {
                    enable = true,
                    theme = require("telescope.themes").commander,
                },
                lazy = {
                    enable = true,
                    set_plugin_name_as_cat = true,
                },
            },
        })
        require("commander").add({
            {
                cmd = "<cmd>set bg=dark<cr>",
                desc = "Dark Theme",
                cat = "theme(background)",
            },
            {
                cmd = "<cmd>set bg=light<cr>",
                desc = "Light Theme",
                cat = "theme(background)",
            },
        })

        if vim.g.neovide then
            require("commander").add({
                {
                    cmd = function()
                        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
                    end,
                    desc = "Toggle Fullscreen",
                    cat = "neovide",
                },
                {
                    cmd = function()
                        vim.g.neovide_input_ime = not vim.g.neovide_input_ime
                    end,
                    desc = "Toggle InputIME",
                    cat = "neovide",
                },
            })
        end

        local ok, proj = pcall(require, "tools.proj")
        if ok then
            require("commander").add({
                {
                    cmd = function()
                        proj:save()
                    end,
                    desc = "Save as Project",
                    cat = "project",
                },
                {
                    cmd = function()
                        proj:update()
                    end,
                    desc = "Update Project",
                    cat = "project",
                },
                {
                    cmd = function()
                        proj:select_and_load()
                    end,
                    desc = "Load Project",
                    cat = "project",
                },
                {
                    cmd = function()
                        proj:select_and_del()
                    end,
                    desc = "Forget Project",
                    cat = "project",
                },
            })
        end
        local ok1, t = pcall(require, "tools.task")
        if ok1 then
            require("commander").add({
                {
                    cmd = function()
                        t.run("build", t.task_type, t.task_mode)
                    end,
                    desc = "Build",
                    cat = "Task",
                },
                {
                    cmd = function()
                        t.run("run", t.task_type, t.task_mode)
                    end,
                    desc = "Run",
                    cat = "Task",
                },
                {
                    cmd = function()
                        t.switch_taskmode()
                    end,
                    desc = "TaskToggleDebugRelease",
                    cat = "Task",
                },
                {
                    cmd = function()
                        t.switch_tasktype()
                    end,
                    desc = "TaskToggleProjFile",
                    cat = "Task",
                },
                {
                    cmd = function()
                        t.select_and_run()
                    end,
                    desc = "TaskSelectAndRun",
                    cat = "Task",
                },
                {
                    cmd = function()
                        t.edit_task()
                    end,
                    desc = "TaskEdit/Add",
                    cat = "Task",
                },
            })
        end
        local ok2, term = pcall(require, "tools.terminal")
        if ok2 then
            require("commander").add({
                {
                    cmd = function()
                        term.select_default_sendterm()
                    end,
                    desc = "select default pinned term for send",
                    cat = "Term",
                },
            })
        end
    end,
}
