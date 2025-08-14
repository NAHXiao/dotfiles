local lsp_diagnostic_float_winid = {}
return {
    {
        -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        version = "*",
        lazy = false,
        event = "UIEnter",
        keys = {
            {
                "<leader>\\d",
                function()
                    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
                end,
                desc = "Toggle diagnostic show"
            },
            --[] + (d|w|e|i|h)
            --g + c|s|w|d|D|r
            --ca K <leader>rn <leader>ca <leader>i
            {
                "[w",
                function()
                    vim.diagnostic.jump({
                        count = -1,
                        float = true,
                        severity = vim.diagnostic.severity.WARN,
                    })
                end,
                mode = "n",
                desc = "goto prev diagnostic(WARN)",
            },
            {
                "]w",
                function()
                    vim.diagnostic.jump({
                        count = 1,
                        float = true,
                        severity = vim.diagnostic.severity.WARN,
                    })
                end,
                mode = "n",
                desc = "goto next diagnostic(WARN)",
            },
            {
                "[e",
                function()
                    vim.diagnostic.jump({
                        count = -1,
                        float = true,
                        severity = vim.diagnostic.severity.ERROR,
                    })
                end,
                mode = "n",
                desc = "goto prev diagnostic(ERROR)",
            },
            {
                "]e",
                function()
                    vim.diagnostic.jump({
                        count = 1,
                        float = true,
                        severity = vim.diagnostic.severity.ERROR,
                    })
                end,
                mode = "n",
                desc = "goto next diagnostic(ERROR)",
            },
            {
                "[i",
                function()
                    vim.diagnostic.jump({
                        count = -1,
                        float = true,
                        severity = vim.diagnostic.severity.INFO,
                    })
                end,
                mode = "n",
                desc = "goto prev diagnostic(INFO)",
            },
            {
                "]i",
                function()
                    vim.diagnostic.jump({
                        count = 1,
                        float = true,
                        severity = vim.diagnostic.severity.INFO,
                    })
                end,
                mode = "n",
                desc = "goto next diagnostic(INFO)",
            },
            {
                "[h",
                function()
                    vim.diagnostic.jump({
                        count = -1,
                        float = true,
                        severity = vim.diagnostic.severity.HINT,
                    })
                end,
                mode = "n",
                desc = "goto prev diagnostic(HINT)",
            },
            {
                "]h",
                function()
                    vim.diagnostic.jump({
                        count = 1,
                        float = true,
                        severity = vim.diagnostic.severity.HINT,
                    })
                end,
                mode = "n",
                desc = "goto next diagnostic(HINT)",
            },
            {
                "[d",
                function()
                    vim.diagnostic.jump({ count = -1, float = true })
                end,
                mode = "n",
                desc = "goto prev diagnostic",
            },
            {
                "]d",
                function()
                    vim.diagnostic.jump({ count = 1, float = true })
                end,
                mode = "n",
                desc = "goto next diagnostic",
            },

            { "gs", vim.lsp.buf.document_symbol,  mode = "n", desc = "list document_symbol" },
            { "gw", vim.lsp.buf.workspace_symbol, mode = "n", desc = "query workspace_symbol" },

            { "gd", vim.lsp.buf.definition,       mode = "n", desc = "goto definition" },
            { "gr", vim.lsp.buf.references,       mode = "n", desc = "goto references" },
            { "gi", vim.lsp.buf.incoming_calls,   mode = "n", desc = "list incoming_calls" },

            { "gD", vim.lsp.buf.declaration,      mode = "n", desc = "goto declaration" },

            { "K",  vim.lsp.buf.hover,            mode = "n", desc = "show hover doc" }, --TODO: gd...close
            -- { "<C-K>",       vim.lsp.buf.signature_help,   mode = "n" ,desc="show signature_help"},
            { "cn", vim.lsp.buf.rename,           mode = "n", desc = "symbol rename" },
            {
                "ca",
                vim.lsp.buf.code_action,
                mode = { "n", "v" },
                desc = "list code action",
            },
            {
                "<leader>i", -- 切换浮动诊断窗口显示
                function()
                    local bufid = vim.api.nvim_get_current_buf()
                    local winid = lsp_diagnostic_float_winid[bufid]
                    if winid and vim.api.nvim_win_is_valid(winid) then
                        if vim.api.nvim_get_current_win() == winid then
                            vim.api.nvim_win_close(winid, true)
                        else
                            vim.api.nvim_set_current_win(winid)
                        end
                    else
                        local retbufid, newwinid =
                            vim.diagnostic.open_float(nil, { focusable = true })
                        if retbufid and newwinid then
                            lsp_diagnostic_float_winid[retbufid] = newwinid
                        end
                    end
                end,
                mode = "n",
                desc = "toggle diagnostic float window",
            },
        },
        dependencies = {
            "williamboman/mason.nvim",
            "onsails/lspkind.nvim",
        },
        config = function()
            local _open_floating_preview = vim.lsp.util.open_floating_preview
            vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
                opts = opts or {}
                opts.border = opts.border
                    or {
                        { "╭", "FloatBorder" },
                        { "─", "FloatBorder" },
                        { "╮", "FloatBorder" },
                        { "│", "FloatBorder" },
                        { "╯", "FloatBorder" },
                        { "─", "FloatBorder" },
                        { "╰", "FloatBorder" },
                        { "│", "FloatBorder" },
                    }
                local bufnr, winid = _open_floating_preview(contents, syntax, opts)
                -- For RenderMarkdown
                vim.api.nvim_set_option_value(
                    "winhighlight",
                    "RenderMarkdownCode:TRANSPARENT",
                    { win = winid }
                )
                return bufnr, winid
            end
            local diagnostic = vim.diagnostic
            local icons = require("tools.icons")
            diagnostic.config({
                virtual_text = true,
                signs = {
                    text = {
                        [diagnostic.severity.ERROR] = icons.diagnostics.error[1],
                        [diagnostic.severity.WARN] = icons.diagnostics.warn[1],
                        [diagnostic.severity.INFO] = icons.diagnostics.info[1],
                        [diagnostic.severity.HINT] = icons.diagnostics.hint[1],
                    },
                    numhl = {
                        [diagnostic.severity.ERROR] = "",
                        [diagnostic.severity.WARN] = "",
                        [diagnostic.severity.HINT] = "",
                        [diagnostic.severity.INFO] = "",
                    },
                },
                update_in_insert = true,
                underline = true,
                severity_sort = true,
                float = {
                    source = "if_many",
                    header = "",
                    prefix = "- ",
                    border = "rounded",
                },
            })
            local kinds = vim.lsp.protocol.CompletionItemKind
            local lspkind = require("lspkind")
            for i, kind in ipairs(kinds) do
                kinds[i] = lspkind.symbolic(kind, { mode = "symbol" }) or kind
            end
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        event = "UIEnter",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = require("tools.config.lsp").mason_ensure_install,
                automatic_enable = false
            })
            --jdtls?
        end,
    }
}
