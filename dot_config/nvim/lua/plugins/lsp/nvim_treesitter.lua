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
                    require('utils').is_bigfile(buf)
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
        vim.o.foldmethod = "expr"
        vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client:supports_method("textDocument/foldingRange") then
                    local win = vim.api.nvim_get_current_win()
                    vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
                end
            end,
        })
    end,
}
