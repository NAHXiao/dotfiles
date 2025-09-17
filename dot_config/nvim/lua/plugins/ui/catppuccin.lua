return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        -- flavour = "auto" -- will respect terminal's background
        background = { -- :h background
            light = "latte",
            dark = "mocha",
        },
        transparent_background = false, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
            enabled = false, -- dims the background color of inactive window
            shade = "dark",
            percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        -- no_underline = false, -- Force no underline
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
            comments = { "italic" }, -- Change the style of comments
            conditionals = { "italic" },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
            -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        integrations = {
            blink_cmp = true,
            -- cmp = true,
            gitsigns = true,
            -- nvimtree = true,
            neotree = true,
            treesitter = true,
            hop = true,
            notify = true,
            render_markdown = true,
            alpha = true,
            dap = true,
            flash = true,
            telescope = {
                enabled = true,
                -- style = "nvchad"
                --
            },
            lsp_trouble = true,
            mini = {
                enabled = false,
                indentscope_color = "",
            },
            native_lsp = {
                enabled = true,
                virtual_text = {
                    errors = { "italic" },
                    hints = { "italic" },
                    warnings = { "italic" },
                    information = { "italic" },
                },
                underlines = {
                    errors = { "underline" },
                    hints = { "underline" },
                    warnings = { "underline" },
                    information = { "underline" },
                },
                inlay_hints = {
                    background = true,
                },
            },
            -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
    },
    config = function(_, opts)
        opts.custom_highlights = function(C)
            -- default transparent groups
            local transparent = {
                Pmenu = {
                    bg = C.none,
                    fg = C.overlay2,
                },
                -- PmenuSel = { bg = C.surface1, style = { "bold" } },
                -- PmenuThumb = { bg = C.overlay0 },
                -- PmenuSbar = { bg = C.surface1 },
                NormalFloat = {
                    fg = C.text,
                    bg = C.none,
                },
                LspSignatureActiveParameter = {
                    bg = C.none,
                    style = { "bold" },
                    underline = true,
                },
            }
            local render_markdown = {
                RenderMarkdownCode = {
                    bg = C.surface0,
                },
            }
            return vim.tbl_deep_extend("force", transparent, render_markdown)
        end
        opts.highlight_overrides = {
            latte = function(C)
                return {
                    CursorLine = {
                        bg = "#FFFFFF",
                    },
                }
            end,
        }
        require("catppuccin").setup(opts)
        local bg = require("tools.config.hl").use_lightbg and "light" or "dark"
        vim.cmd.colorscheme("catppuccin")
        vim.o.background = bg
    end,
}
