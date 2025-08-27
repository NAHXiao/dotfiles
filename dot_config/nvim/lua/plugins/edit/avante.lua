return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    cond = false,
    opts = {
        provider = "deepseek",
        vendors = {
            deepseek = {
                __inherited_from = "openai",
                api_key_name = "DEEPSEEK_API_KEY",
                endpoint = "https://api.deepseek.com",
                model = "deepseek-coder",
                proxy = os.getenv("HTTP_PROXY") or os.getenv("HTTPS_PROXY") or nil,
                timeout = 3000, -- Timeout in milliseconds, increase this for reasoning models
            },
        },
        -- provider = "copilot",
        -- copilot = {
        --     model = "claude-3.5-sonnet",
        -- },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = jit.os == "Windows"
            and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "echasnovski/mini.pick", -- for file_selector provider mini.pick
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
        "ibhagwan/fzf-lua", -- for file_selector provider fzf
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        "zbirenbaum/copilot.lua", -- for providers='copilot'
        {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                -- recommended settings
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    -- required for Windows users
                    use_absolute_path = true,
                },
            },
        },
        {
            -- Make sure to set this up properly if you have lazy=true
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
