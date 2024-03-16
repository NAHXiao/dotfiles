return {
    'simrat39/symbols-outline.nvim',
    version = "*",
    lazy = false,
    dependencies = {
    },
    config = function()
        require("symbols-outline").setup {
            show_guides = false,
            position = 'left',
            width = 30,
            wrap = false,
            keymaps = { fold = "h", unfold = "l", fold_all = "zM", unfold_all = "zR" },
            symbols = {
                File = { icon = "", hl = "@text.uri" },
                Module = { icon = "全", hl = "@namespace" },
                Namespace = { icon = "凜", hl = "@namespacee" },
                Package = { icon = "", hl = "@namespacee" },
                Class = { icon = "", hl = "@type" },
                Method = { icon = "", hl = "@method" },
                Property = { icon = "", hl = "@method" },
                Field = { icon = "", hl = "@field" },
                Constructor = { icon = "", hl = "@constructor" },
                Enum = { icon = "", hl = "@type" },
                Interface = { icon = "ﰮ", hl = "@type" },
                Function = { icon = "", hl = "@function" },
                Variable = { icon = "", hl = "@constant" },
                Constant = { icon = "", hl = "@constant" },
                String = { icon = "", hl = "@string" },
                Number = { icon = "#", hl = "@number" },
                Boolean = { icon = "⊨", hl = "@boolean" },
                Array = { icon = "", hl = "@constant" },
                Object = { icon = "", hl = "@type" },
                Key = { icon = "🔐", hl = "@type" },
                Null = { icon = "ﳠ", hl = "@type" },
                EnumMember = { icon = "", hl = "@field" },
                Struct = { icon = "", hl = "@type" },
                Event = { icon = "🗲", hl = "@type" },
                Operator = { icon = "+", hl = "@operator" },
                TypeParameter = { icon = "", hl = "@parameter" }
            },
        }
    end,
}
