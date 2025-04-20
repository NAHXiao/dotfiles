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
            mode = "i",
            desc = "Toggle BlinkCmp",
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
            ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
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
                                    icon = lspkind.symbolic(ctx.kind, {
                                        mode = "symbol",
                                    })
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
                prefetch_on_insert = false,
            },
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
            providers = {
                path = {
                    opts = {
                        get_cwd = function(_)
                            return vim.b.projroot
                        end,
                    },
                },
            },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        signature = {
            enabled = true,
            window = { border = "rounded" },
        },
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
        require("blink.cmp").setup(opts)
    --     local success, copilot = pcall(require, "copilot.suggestion")
    --     if success then
    --         vim.api.nvim_create_autocmd("User", {
    --             pattern = "BlinkCmpMenuOpen",
    --             callback = function()
    --                 copilot.dismiss()
    --                 vim.b.copilot_suggestion_hidden = true
    --             end,
    --         })
    --
    --         vim.api.nvim_create_autocmd("User", {
    --             pattern = "BlinkCmpMenuClose",
    --             callback = function()
    --                 vim.b.copilot_suggestion_hidden = false
    --             end,
    --         })
    --     end
    end,
}
