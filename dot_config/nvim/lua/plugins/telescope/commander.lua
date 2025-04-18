return {
    "FeiyouG/commander.nvim",
    lazy = true,
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
        {
            "<C-p>",
            function()
                TeleMultiplexSearch(require("commander").show, {}, "Commands Panel")
            end,
            desc = "show commands panel",
        },
    },

    config = function()
        require("commander").setup({
            -- Specify what components are shown in the prompt;
            -- Order matters, and components may repeat
            components = {
                "CAT",
                "DESC",
                "CMD",
                -- "KEYS",
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
    end,
}
