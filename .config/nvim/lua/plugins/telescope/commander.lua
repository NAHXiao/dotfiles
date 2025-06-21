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
                -- "KEYS",
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
        require("commander").add({
            {
                cmd = "<cmd>lua require('utils').proj:save()<cr>",
                desc = "Save as Project",
                cat = "project",
            },
            {
                cmd = "<cmd>lua require('utils').proj:update()<cr>",
                desc = "Update Project",
                cat = "project",
            },
            {
                cmd = "<cmd>lua require('utils').proj:select_and_load()<cr>",
                desc = "Load Project",
                cat = "project",
            },
            {
                cmd = "<cmd>lua require('utils').proj:select_and_del()<cr>",
                desc = "Forget Project",
                cat = "project",
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
    end,
}
