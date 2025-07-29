vim.cmd("vnoremap K <Nop>")
local diagnostic_float_winid = {}
return {
    "neovim/nvim-lspconfig",
    version = "*",
    lazy = false,
    event = "UIEnter",
    commander = {
        { cmd = "<cmd>LspStart<cr>", desc = "Lsp Start" },
        { cmd = "<cmd>LspRestart<cr>", desc = "Lsp Restart" },
        { cmd = "<cmd>LspStop<cr>", desc = "Lsp Stop" },
        { cmd = "<cmd>LspInfo<cr>", desc = "Lsp Info" },
        { cmd = "<cmd>LspLog<cr>", desc = "Lsp Log" },
    },
    keys = {
        --( [|] ) + (w|e|i|h)
        --g ( [|]|c|s|w|d|D|r )
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
            "g[",
            function()
                vim.diagnostic.jump({ count = -1, float = true })
            end,
            mode = "n",
            desc = "goto prev diagnostic",
        },
        {
            "g]",
            function()
                vim.diagnostic.jump({ count = 1, float = true })
            end,
            mode = "n",
            desc = "goto next diagnostic",
        },

        { "ca", vim.lsp.buf.code_action, mode = "n", desc = "list code action" },
        { "gc", vim.lsp.buf.incoming_calls, mode = "n", desc = "list incoming_calls" },
        { "gs", vim.lsp.buf.document_symbol, mode = "n", desc = "list document_symbol" },
        { "gw", vim.lsp.buf.workspace_symbol, mode = "n", desc = "query workspace_symbol" },

        { "gD", vim.lsp.buf.declaration, mode = "n", desc = "goto declaration" },
        { "gd", vim.lsp.buf.definition, mode = "n", desc = "goto definition" },
        { "gr", vim.lsp.buf.references, mode = "n", desc = "goto references" },

        { "K", vim.lsp.buf.hover, mode = "n", desc = "show hover doc" },
        -- { "<C-K>",       vim.lsp.buf.signature_help,   mode = "n" ,desc="show signature_help"},
        { "<leader>rn", vim.lsp.buf.rename, mode = "n", desc = "symbol rename" },
        { "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "v" }, desc = "list code action" },
        {
            "<leader>i", -- 切换浮动诊断窗口显示
            function()
                local bufid = vim.api.nvim_get_current_buf()
                local winid = diagnostic_float_winid[bufid]
                if winid and vim.tbl_contains(vim.api.nvim_list_wins(), winid) then
                    if vim.api.nvim_get_current_win() == winid then
                        vim.api.nvim_win_close(winid, true)
                    else
                        vim.api.nvim_set_current_win(winid)
                    end
                else
                    local retbufid, newwinid = vim.diagnostic.open_float(nil, { focusable = true })
                    if retbufid and newwinid then
                        diagnostic_float_winid[retbufid] = newwinid
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
        -- vim.api.nvim_create_autocmd('LspAttach', {
        --     group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        --     callback = function(ev)
        --         vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        --     end,
        -- })
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
            return bufnr,winid
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
}
