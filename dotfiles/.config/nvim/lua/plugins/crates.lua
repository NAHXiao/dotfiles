--rust crates.io
return {
    "saecki/crates.nvim",
    version = "*",
    lazy = true,
    ft='toml',
    config = function()
        require('crates').setup({})
    end,
}
