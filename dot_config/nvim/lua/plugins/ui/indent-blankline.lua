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
}
