return {
    "nvim-treesitter/nvim-treesitter",
    version = "*",
    lazy = false,
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "bash",
                "c",
                "cpp",
                "cmake",
                "css",
                "dockerfile",
                "go",
                "gomod",
                "gowork",
                "html",
                "http",
                "java",
                "javascript",
                "json",
                "lua",
                -- "latex",
                "make",
                "markdown",
                "markdown_inline",
                "python",
                "regex",
                "rust",
                "toml",
                "vim",
                "yaml",
            },
            auto_install = true,
            highlight = {
                enable = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<S-Tab>", -- normal mode
                    node_incremental = "<Tab>", -- visual mode
                    node_decremental = "<S-Tab", -- visual mode
                },
            },
            ident = { enable = true },
            rainbow = {
                enable = true,
            },
        })
    end,
}
