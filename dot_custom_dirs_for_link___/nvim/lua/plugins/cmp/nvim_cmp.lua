--TODO
return {
    'hrsh7th/nvim-cmp',
    version = "*",
    lazy = true,
    event = "InsertEnter",
    dependencies = {
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-buffer',
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-emoji",
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-nvim-lua',
        "jalvesaq/cmp-nvim-r",
        'hrsh7th/cmp-vsnip',
    },
    config = function()
        require('func')
        local lspkind = require("lspkind")
        -- return comparators
        -- package.path=package.path ..';'..vim.fn.stdpath("data").."/site/pack/packer/opt/compilot-cmp/lua/?.lua"
        -- 曲线救国(require("copilot_cmp.comparators").prioritize加载不出来就手动把代码搬过来)
        -- local cop_comparators = {
        --    score = function (entry1, entry2)
        --   if entry1.score and entry2.score then
        --     return entry1.score > entry2.score
        --   end
        --   end,
        --   prioritize = function (entry1, entry2)
        --   if entry1.copilot and not entry2.copilot then
        --     return true
        --   elseif entry2.copilot and not entry1.copilot then
        --     return false
        --   end
        --   end
        -- }

        --   פּ ﯟ   some other good icons
        --
        -- local kind_icons = {
        --     Text = "",
        --     Method = "m",
        --     Function = "",
        --     Constructor = "",
        --     Field = "",
        --     Variable = "",
        --     Class = "",
        --     Interface = "",
        --     Module = "",
        --     Property = "",
        --     Unit = "",
        --     Value = "",
        --     Enum = "",
        --     Keyword = "",
        --     Snippet = "",
        --     Color = "",
        --     File = "",
        --     Reference = "",
        --     Folder = "",
        --     EnumMember = "",
        --     Constant = "",
        --     Struct = "",
        --     Event = "",
        --     Operator = "",
        --     TypeParameter = "",
        --     Copilot = "",
        -- }
        local kind_icons = {
            Text = "",
            Method = "ƒ",
            Function = "",
            Constructor = "",
            Field = "",
            Variable = "",
            Class = "",
            Interface = "",
            Module = "",
            Property = "",
            Unit = "",
            Enum = "",
            Keyword = "K",
            Value = "V",
            Snippet = "",
            Color = "C",
            File = "",
            Reference = "",
            Folder = "",
            EnumMember = "",
            Constant = "",
            Struct = "",--
            Event = "",--
            Operator = "",
            TypeParameter = "",
            Copilot = "",
        }
        -- find more here: https://www.nerdfonts.com/cheat-sheet

        local t = function(str)
            return vim.api.nvim_replace_termcodes(str, true, true, true)
        end
        local cmp = require("cmp")

        local has_words_before = function()
            if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
            -- local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
            local cursor = vim.api.nvim_win_get_cursor(0)
            local line   = cursor[1]
            local col    = cursor[2]
            return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
        end

        cmp.setup({
            preselect = cmp.PreselectMode.None,
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                    -- vim.fn["vsnip#anonymous"](args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = {
                ["<Tab>"] = cmp.mapping({
                    c = function()
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            cmp.complete()
                        end
                    end,
                    i = vim.schedule_wrap(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end
                    )
                }),
                ["<S-Tab>"] = cmp.mapping({
                    c = function()
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            cmp.complete()
                        end
                    end,
                    i = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end,
                }),
                ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
                ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
                ["<C-n>"] = cmp.mapping({
                    c = function()
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            vim.api.nvim_feedkeys(t("<Down>"), "n", true)
                        end
                    end,
                    i = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end,
                }),
                ["<C-p>"] = cmp.mapping({
                    c = function()
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            vim.api.nvim_feedkeys(t("<Up>"), "n", true)
                        end
                    end,
                    i = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end,
                }),
                ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                --['<C-e>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
                --['<C-e>'] = cmp.mapping({ i = cmp.mapping.close(), c = cmp.mapping.close() }),
                --mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ["<C-e>"] = cmp.mapping.abort(),

                --[[ ['<CR>'] = cmp.mapping({
            i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
            c = function()
                if cmp.visible() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                end
            end,
        }), ]]
            },

            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    -- Kind icons
                    vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
                    vim_item.menu = ({
                        copilot = "[Copilot]",
                        nvim_lsp = "[LSP]",
                        luasnip = "[LuaSnip]",
                        buffer = "[Buffer]",
                        path = "[Path]",
                        emoji = "[Emoji]"
                    })[entry.source.name]
                    return vim_item
                end,
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                -- { name = "copilot" },
                -- { name = "vsnip" },
                { name = "luasnip" },
                { name = "emoji" },
                { name = 'nvim_lsp_signature_help' },
            }, {
                { name = "buffer" },
                { name = "path" },
            }),
            sorting = {
                priority_weight = 2,
                comparators = {
                    -- cop_comparators,
                    -- Below is the default comparitor list and order for nvim-cmp
                    -- require("copilot_cmp.comparators").prioritize,
                    cmp.config.compare.offset,
                    -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.locality,
                    cmp.config.compare.kind,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                },
            },
        })

        -- Set configuration for specific filetype.
        cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
                { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
            }, {
                { name = "buffer" },
            }),
        })

        -- Use buffer source foj `/` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline("/", {
            completion = { autocomplete = false },
            sources = {
                { name = "buffer" },
            },
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(":", {
            completion = { autocomplete = false },
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
            mapping = {
                ["<Tab>"] = cmp.mapping({
                    c = function()
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                        else
                            cmp.complete()
                        end
                    end,
                    i = vim.schedule_wrap(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                        else
                            fallback()
                        end
                    end
                    )
                }),
                ["<S-Tab>"] = cmp.mapping({
                    c = function()
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                        else
                            cmp.complete()
                        end
                    end,
                    i = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                        else
                            fallback()
                        end
                    end,
                }),
            }
        })
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on(
            'confirm_done',
            cmp_autopairs.on_confirm_done()
        )
    end,
}
