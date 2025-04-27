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
                "DESC",
                -- "KEYS",
                "CMD",
                "CAT",
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
            },
            {
                cmd = "<cmd>set bg=light<cr>",
                desc = "Light Theme",
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
    end,
}
