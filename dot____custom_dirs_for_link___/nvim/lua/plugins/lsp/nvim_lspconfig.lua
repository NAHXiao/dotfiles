vim.cmd('vnoremap K <Nop>')
return {
    "neovim/nvim-lspconfig",
    version = "*",
    lazy = false,
    event = 'UIEnter',
    commander = {
        { cmd = "<cmd>LspStart", desc = "Lsp Start" },
        { cmd = "<cmd>LspRestart", desc = "Lsp Restart" },
        { cmd = "<cmd>LspStop",  desc = "Lsp Stop" },
        { cmd = "<cmd>LspInfo",  desc = "Lsp Info" },
        { cmd = "<cmd>LspLog",   desc = "Lsp Log" },
    },
    keys = {
        { "[d",         vim.diagnostic.goto_prev,     mode = "n",          desc = "goto prev diagnostic" },
        { "]d",         vim.diagnostic.goto_next,     mode = "n",          desc = "goto next diagnostic" },
        { "g[",         vim.diagnostic.goto_prev,     mode = "n",          desc = "goto prev diagnostic" },
        { "g]",         vim.diagnostic.goto_next,     mode = "n",          desc = "goto next diagnostic" },

        { "ca",         vim.lsp.buf.code_action,      mode = "n",          desc = "list code action" },
        { "gc",         vim.lsp.buf.incoming_calls,   mode = "n",          desc = "list incoming_calls" },
        { "gs",         vim.lsp.buf.document_symbol,  mode = "n",          desc = "list document_symbol" },
        { "gw",         vim.lsp.buf.workspace_symbol, mode = "n",          desc = "query workspace_symbol" },

        { "gD",         vim.lsp.buf.declaration,      mode = "n",          desc = "goto declaration" },
        { "gd",         vim.lsp.buf.definition,       mode = "n",          desc = "goto definition" },
        { "gr",         vim.lsp.buf.references,       mode = "n",          desc = "goto references" },

        { "K",          vim.lsp.buf.hover,            mode = "n",          desc = "show hover doc" },
        -- { "<C-K>",       vim.lsp.buf.signature_help,   mode = "n" ,desc="show signature_help"},
        { "<leader>rn", vim.lsp.buf.rename,           mode = "n",          desc = "symbol rename" },
        { "<leader>ca", vim.lsp.buf.code_action,      mode = { "n", "v" }, desc = "list code action" },
        {
            "<leader>i", -- 切换浮动诊断窗口显示
            function()
                local if_hasfloat_then_close = function()
                    local found_float = false
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if vim.api.nvim_win_get_config(win).relative ~= '' then
                            vim.api.nvim_win_close(win, true)
                            found_float = true
                        end
                    end
                    return found_float
                end
                if not if_hasfloat_then_close() then
                    vim.diagnostic.open_float(nil, { focusable = false })
                    return
                end
            end,
            mode = "n",
            desc = "toggle diagnostic float window",
        },
    },
    dependencies = {
        "williamboman/mason.nvim",
    },
    config = function()
        -- vim.api.nvim_create_autocmd('LspAttach', {
        --     group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        --     callback = function(ev)
        --         vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        --     end,
        -- })
        local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or {
                { "╭", "FloatBorder" },
                { "─", "FloatBorder" },
                { "╮", "FloatBorder" },
                { "│", "FloatBorder" },
                { "╯", "FloatBorder" },
                { "─", "FloatBorder" },
                { "╰", "FloatBorder" },
                { "│", "FloatBorder" },
            }
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
        end

        local diagnostic = vim.diagnostic
        diagnostic.config({
            virtual_text = true,
            signs = {
                text = {
                    [diagnostic.severity.ERROR] = " ",
                    [diagnostic.severity.WARN] = " ",
                    [diagnostic.severity.INFO] = "󰋼 ",
                    [diagnostic.severity.HINT] = "󰌵 ",
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
                border = 'single',
                source = 'always',
                header = '',
                prefix = '- ',
            },
        })

        local icons = {
            Class = "",
            Color = "C",
            Constant = "",
            Constructor = "",
            Enum = "",
            EnumMember = "",
            Field = "",
            File = "",
            Folder = "",
            Function = "",
            Interface = "",
            Keyword = "K",
            Method = "ƒ",
            Module = "",
            Property = "",
            Snippet = "",
            Struct = "",
            Text = "",
            Unit = "",
            Value = "V",
            Variable = ""
        }
        local kinds = vim.lsp.protocol.CompletionItemKind
        for i, kind in ipairs(kinds) do
            kinds[i] = icons[kind] or kind
        end
    end,
}
