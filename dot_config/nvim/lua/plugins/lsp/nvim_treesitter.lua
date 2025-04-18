return {
    "nvim-treesitter/nvim-treesitter",
    version = "*",
    lazy = true,
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
                "hcl",
                "html",
                "http",
                "java",
                "javascript",
                "json",
                "lua",
                "make",
                "markdown",
                "markdown_inline",
                "python",
                "r",
                "regex",
                "ruby",
                "rust",
                "toml",
                "vim",
                "yaml",
                "zig",
            },
            -- TODO if true  some .d will open failed
            auto_install = true,
            highlight = {
                enable = true,
                -- 打开会导致python缩进异常/markdown <span>标签键入title时闪退
                disable = { "markdown", "python" },
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<S-Tab>", -- normal mode
                    node_incremental = "<Tab>", -- visual mode
                    node_decremental = "<S-Tab", -- visual mode
                },
            },
            -- ident = { enable = true },
            rainbow = {
                enable = true,
            },
        })
    end,
}
