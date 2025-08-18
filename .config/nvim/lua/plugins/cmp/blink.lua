local events = {
    "InsertEnter",
    "CmdlineEnter",
}
return {
    "saghen/blink.cmp",
    dependencies = {
        "rafamadriz/friendly-snippets",

        "zbirenbaum/copilot.lua",
        "kyazdani42/nvim-web-devicons",
        "onsails/lspkind.nvim",

        "fang2hou/blink-copilot",
    },
    lazy = true,
    event = events,
    keys = {
        {
            "<c-space>",
            function()
                local cmp = require("blink.cmp")
                if cmp.is_visible() then
                    cmp.hide()
                else
                    cmp.show()
                end
            end,
            mode = { "i", "c" },
            desc = "Toggle BlinkCmp Completion",
        },
    },
    version = "*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = "none",
            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<S-Tab>"] = { "select_prev", "fallback" },
            ["<Tab>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            ["<C-o>"] = { "show_signature", "hide_signature", "fallback" },
        },

        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            documentation = {
                auto_show = true,
                window = { border = "rounded" },
            },
            list = {
                selection = { preselect = false, auto_insert = false },
            },
            menu = {
                draw = {
                    columns = {
                        { "kind_icon", "label", "label_description", gap = 1 },
                        { "kind" },
                    },
                    treesitter = { "lsp" },
                    components = {
                        kind_icon = {
                            text = function(ctx)
                                local lspkind = require("lspkind")
                                local nvim_web_devicons = require("nvim-web-devicons")
                                local icon = ctx.kind_icon
                                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                    local dev_icon, _ = nvim_web_devicons.get_icon(ctx.label)
                                    if dev_icon then
                                        icon = dev_icon
                                    end
                                else
                                    local dev_icon = lspkind.symbolic(ctx.kind, {
                                        mode = "symbol",
                                    })
                                    if dev_icon then
                                        icon = dev_icon
                                    end
                                end

                                return icon .. ctx.icon_gap
                            end,
                            highlight = function(ctx)
                                local nvim_web_devicons = require("nvim-web-devicons")
                                local hl = ctx.kind_hl
                                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                    local dev_icon, dev_hl = nvim_web_devicons.get_icon(ctx.label)
                                    if dev_icon then
                                        hl = dev_hl
                                    end
                                end
                                return hl
                            end,
                        },
                    },
                },
                border = "rounded",
            },
            trigger = {
                -- prefetch_on_insert = false,
            },
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { "lazydev", "lsp", "path", "snippets", "buffer", "copilot" },
            providers = {
                path = { -- ./
                    opts = {
                        get_cwd = function(_)
                            return require("utils").get_rootdir(0)
                        end,
                    },
                },
                copilot = {
                    name = "copilot",
                    module = "blink-copilot",
                    score_offset = 100,
                    async = true,
                },
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    -- make lazydev completions top priority (see `:h blink.cmp`)
                    score_offset = 100,
                },
            },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        signature = {
            enabled = true,
            window = { border = "rounded" },
        },
        cmdline = {
            keymap = {
                preset = "inherit",
                ["<CR>"] = { "fallback" },
            },
            completion = {
                menu = { auto_show = true },
                list = {
                    selection = { preselect = false, auto_insert = true },
                },
            },
        },
        snippets = {},
    },
    config = function(_, opts)
        require("blink.cmp").setup(opts)
        vim.api.nvim_create_autocmd("User", {
            pattern = "BlinkCmpMenuOpen",
            callback = function()
                vim.b.copilot_suggestion_hidden = true
                vim.cmd("doautocmd CursorMovedI")
            end,
        })
        vim.api.nvim_create_autocmd("User", {
            pattern = "BlinkCmpMenuClose",
            callback = function()
                vim.b.copilot_suggestion_hidden = false
                vim.cmd("doautocmd CursorMovedI")
            end,
        })
        require("tools.hl").register_transparent({ "BlinkCmpMenuBorder" }, {
            type = "transparent",
            dependency =
            "outer<-outer"
        })
        require("tools.hl").register({
            BlinkCmpMenuSelection = {
                link = "CursorLine"
                -- bg = {
                --     transform = "lighten",
                --     from = "BlinkCmpMenuSelection.bg",
                --     amount = 0.3
                -- }
            }
        }, { dependency = "outer<-inner", type = "colorscheme" })
    end,
}
