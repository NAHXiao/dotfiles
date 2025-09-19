return {
    "lukas-reineke/indent-blankline.nvim",
    version = "*",
    main = "ibl",
    event = "UIEnter",
    lazy = true,
    ---@module "ibl"
    ---@type ibl.config
    opts = {
        indent = { char = "▏" },
    },
    config = function(_, opts)
        local hooks = require("ibl.hooks")
        hooks.register(hooks.type.ACTIVE, function(bufnr)
            return not require("utils").is_bigfile(bufnr)
        end)
        require("ibl").setup(opts)
    end,
    keys = {
        {
            "<leader>\\b",
            function()
                local enabled = require("ibl.config").get_config(-1).enabled
                require("ibl").update { enabled = not enabled }
                require("utils").vim_echo("IBL: " .. (enabled and "Disabled" or "Enabled"))
            end,
            desc = "Toggle IBL",
        },
    },
}
