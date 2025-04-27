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
            sync_install = false,
            ignore_install = {},
            modules = {},
            auto_install = true,
            highlight = {
                enable = true,
                disable = function(lang, buf)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<S-Tab>", -- normal mode
                    node_incremental = "<Tab>", -- visual mode
                    node_decremental = "<S-Tab>", -- visual mode
                },
            },
            indent = { enable = true },
        })
    end,
}
