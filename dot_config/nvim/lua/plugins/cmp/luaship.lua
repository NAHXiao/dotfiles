return {
    "L3MON4D3/LuaSnip",
    version = "*",
    lazy = true,
    cond = false,
    event = "InsertEnter",
    -- tag = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
        "rafamadriz/friendly-snippets",
    },
    config = function()
        -- $HOME/.local/share/nvim/lazy/friendly-snippets/snippets
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_vscode").lazy_load("global")
        require("luasnip").filetype_extend("cpp", { "cpp", "cppdoc" })
        require("luasnip").filetype_extend("c", { "c", "cdoc" })
        require("luasnip").filetype_extend("rs", { "rust", "rustdoc" })
        require("luasnip").filetype_extend("sh", { "shell", "shelldoc" })
        require("luasnip").filetype_extend("python", { "base", "pydoc", "python" })
        require("luasnip").filetype_extend("html", { "html" })
        require("luasnip").filetype_extend("make", { "make" })
        require("luasnip").filetype_extend("nix", { "nix" })
        require("luasnip").filetype_extend("sql", { "sql" })
        do
            local map = vim.api.nvim_set_keymap
            local opts = { noremap = true, silent = true }
            map("i", "<c-j>", "<cmd>lua require'luasnip'.jump(1)<CR>", opts)
            map("s", "<c-j>", "<cmd>lua require'luasnip'.jump(1)<CR>", opts)
            map("i", "<c-k>", "<cmd>lua require'luasnip'.jump(-1)<CR>", opts)
            map("s", "<c-k>", "<cmd>lua require'luasnip'.jump(-1)<CR>", opts)
        end
    end,
}
