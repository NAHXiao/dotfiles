return {
    "nvim-treesitter/nvim-treesitter",
    version = "*",
    lazy = true,
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    config = function()
        require('nvim-treesitter.configs').setup {
            ensure_installed = { "bash", "c", "cmake", "css", "dockerfile", "go", "gomod", "gowork", "hcl", "html",
                "http", "javascript", "json", "lua", "make", "markdown", "python", "regex", "ruby", "rust", "toml", "vim", "yaml",
                "zig" },
            -- TODO if true  some .d will open failed
            auto_install = false,
            -- highlight = {
            -- -- 打开会导致python缩进异常
            --     enable = true,
            -- },
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
            }
        }
    end,
}
