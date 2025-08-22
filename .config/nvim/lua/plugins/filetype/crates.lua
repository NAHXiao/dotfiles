--rust crates.io
return {
    "saecki/crates.nvim",
    version = "*",
    lazy = true,
    event = { "BufRead Cargo.toml" },
    config = function()
        require("crates").setup {
            lsp = {
                enabled = true,
                on_attach = function(client, bufnr)
                    -- the same on_attach function as for your other language servers
                    -- can be ommited if you're using the `LspAttach` autocmd
                end,
                actions = true,
                completion = true,
                -- completion = false,
                hover = true,
            },
            curl_args = { "-sL", "--retry", "5" },
            -- completion = {
            --     blink = {
            --         enabled = true,
            --         use_custom_kind = true,
            --         kind_text = {
            --             version = "Version",
            --             feature = "Feature",
            --         },
            --         kind_highlight = {
            --             version = "BlinkCmpKindVersion",
            --             feature = "BlinkCmpKindFeature",
            --         },
            --         kind_icon = {
            --             version = " ",
            --             feature = " ",
            --         },
            --     },
            -- }
        }
    end,
}
