return {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = true,
    version = "*",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    keys = {
        {
            "<leader>\\m",
            function()
                if require("render-markdown").get() then
                    require("render-markdown").set(false)
                else
                    require("render-markdown").set(true)
                end
                local enable = require("render-markdown").get()
                require("utils").vim_echo(("RenderMarkdown: %s"):format(enable and "On" or "Off"))
            end,
        },
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        on = {
            initial = function(ctx)
                if vim.api.nvim_win_get_config(ctx.win).relative ~= "" then
                    local height = vim.api.nvim_win_text_height(ctx.win, {}).all
                    vim.api.nvim_win_set_height(ctx.win, math.max(2, height))
                    local width = vim.api.nvim_win_get_width(ctx.win)
                    vim.api.nvim_win_set_width(ctx.win, math.max(10, width))
                end
            end,
        },
        completions = {
            blink = { enabled = true },
            lsp = { enabled = true },
        },
        filetype = {
            "markdown",
            "vimviki",
        },
        latex = {
            enable = false,
        },
        checkbox = {
            enabled = true,
            -- Additional modes to render checkboxes.
            render_modes = false,
            -- Render the bullet point before the checkbox.
            bullet = false,
            right_pad = 1,
            unchecked = {
                icon = "󰄱 ",
                highlight = "RenderMarkdownUnchecked",
                scope_highlight = nil,
            },
            checked = {
                icon = "󰱒 ",
                highlight = "RenderMarkdownChecked",
                scope_highlight = nil,
            },
            -- | scope_highlight | optional highlight for item associated with custom checkbox |
            custom = {
                todo = {
                    raw = "[-]",
                    rendered = "󰥔 ",
                    highlight = "RenderMarkdownTodo",
                    scope_highlight = nil,
                },
                warn = {
                    raw = "[!]",
                    rendered = " ",
                    highlight = "RenderMarkdownWarn",
                    scope_highlight = nil,
                },
            },
        },
        link = {
            -- Turn on / off inline link icon rendering.
            enabled = true,
            -- Additional modes to render links.
            render_modes = false,
            -- How to handle footnote links, start with a '^'.
            footnote = {
                -- Turn on / off footnote rendering.
                enabled = true,
                -- Replace value with superscript equivalent.
                superscript = true,
                -- Added before link content.
                prefix = "",
                -- Added after link content.
                suffix = "",
            },
            -- Inlined with 'image' elements.
            image = "󰥶 ",
            -- Inlined with 'email_autolink' elements.
            email = "󰀓 ",
            -- Fallback icon for 'inline_link' and 'uri_autolink' elements.
            hyperlink = "󰌹 ",
            -- Applies to the inlined icon as a fallback.
            highlight = "RenderMarkdownLink",
            -- Applies to WikiLink elements.
            wiki = {
                icon = "󱗖 ",
                body = function()
                    return nil
                end,
                highlight = "RenderMarkdownWikiLink",
                scope_highlight = nil,
            },
            -- Define custom destination patterns so icons can quickly inform you of what a link
            -- contains. Applies to 'inline_link', 'uri_autolink', and wikilink nodes. When multiple
            -- patterns match a link the one with the longer pattern is used.
            -- The key is for healthcheck and to allow users to change its values, value type below.
            -- | pattern   | matched against the destination text                            |
            -- | icon      | gets inlined before the link text                               |
            -- | kind      | optional determines how pattern is checked                      |
            -- |           | pattern | @see :h lua-patterns, is the default if not set       |
            -- |           | suffix  | @see :h vim.endswith()                                |
            -- | priority  | optional used when multiple match, uses pattern length if empty |
            -- | highlight | optional highlight for 'icon', uses fallback highlight if empty |
            custom = {
                web = { pattern = "^http", icon = "󰖟 " },
                discord = { pattern = "discord%.com", icon = "󰙯 " },
                github = { pattern = "github%.com", icon = "󰊤 " },
                gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
                google = { pattern = "google%.com", icon = "󰊭 " },
                neovim = { pattern = "neovim%.io", icon = " " },
                reddit = { pattern = "reddit%.com", icon = "󰑍 " },
                stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
                wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
                youtube = { pattern = "youtube%.com", icon = "󰗃 " },
            },
        },
    },
    config = function(_, opts)
        require("render-markdown").setup(opts)
        vim.treesitter.language.register("markdown", "vimwiki")
    end,
}
