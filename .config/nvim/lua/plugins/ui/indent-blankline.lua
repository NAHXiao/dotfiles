local enable
return {
    "lukas-reineke/indent-blankline.nvim",
    version = "*",
    main = "ibl",
    lazy = true,
    -- cond=false,
    ft = {
        "cpp",
        "rust",
        "lua",
        "python",
        "vim",
        "sh",
        "yaml",
        "json",
        "html",
        "css",
        "javascript",
        "typescript",
        "vue",
        "svelte",
        "markdown",
        "yaml",
        "toml",
        "dockerfile",
        "lua",
        "vim",
        "sh",
        "zsh",
        "bash",
        "fish",
        "yaml",
        "json",
        "html",
        "css",
        "javascript",
        "typescript",
        "vue",
        "svelte",
        "markdown",
        "yaml",
        "toml",
        "dockerfile",
    },
    config = function()
        local hooks = require("ibl.hooks")
        hooks.register(hooks.type.ACTIVE, function(bufnr)
            return not require("utils").is_bigfile(bufnr)
        end)
        require("ibl").setup()
    end,
    keys = {
        {
            "<leader>\\ib",
            function()
                local enabled = require("ibl.config").get_config(-1).enabled
                require("ibl").update({ enabled = not enabled })
                require("utils").vim_echo("IBL: " .. (enabled and "Disabled" or "Enabled"))
            end,
        },
    },
}
