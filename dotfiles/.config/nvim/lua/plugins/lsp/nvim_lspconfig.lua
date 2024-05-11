return {
    "neovim/nvim-lspconfig",
    version = "*",
    lazy = false,
    event = 'UIEnter',
    keys = {
        { "<leader>lsa", "<cmd>LspStart<cr>" },
        { "<leader>lst", "<cmd>LspStart<cr>" },
        { "<leader>lrs", "<cmd>LspRestart<cr>" },
        { "<leader>q",   vim.diagnostic.open_float,    mode = "n" },
        { "[d",          vim.diagnostic.goto_prev,     mode = "n" },
        { "]d",          vim.diagnostic.goto_next,     mode = "n" },
        { "ca",          vim.lsp.buf.code_action,      mode = "n" },
        { "gc",          vim.lsp.buf.incoming_calls,   mode = "n" },
        { "gs",          vim.lsp.buf.document_symbol,  mode = "n" },
        { "gw",          vim.lsp.buf.workspace_symbol, mode = "n" },
        { "g[",          vim.diagnostic.goto_prev,     mode = "n" },
        { "g]",          vim.diagnostic.goto_next,     mode = "n" },
        -- { '<leader>i', function() vim.diagnostic.open_float(nil, { focus = true, scope = "cursor" }) end, mode = 'n' },
        {
            "<leader>i", -- 关闭浮动窗口(用于关闭vim.diagnostic_float)
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
            mode = "n"
        },
    },
    dependencies = {
        "williamboman/mason.nvim",
    },
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                vim.keymap.set('n', '<space>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, opts)
                vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', '<space>fo', function() -- f->fo
                    vim.lsp.buf.format { async = true }
                end, opts)
            end,
        })
        vim.cmd('vnoremap K <Nop>')
        ----------------------------------------
        --        为hover文档添加边框       -----
        ----------------------------------------
        -- local curved = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
        local border = {
            { "╭", "FloatBorder" }, --1 🭽
            { "─", "FloatBorder" }, --2 ▔
            { "╮", "FloatBorder" }, --3 🭾
            { "│", "FloatBorder" }, --4 ▕
            { "╯", "FloatBorder" }, --5 🭿
            { "─", "FloatBorder" }, --6 ▁
            { "╰", "FloatBorder" }, --7 🭼
            { "│", "FloatBorder" }, --8 ▏
        }
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
        vim.lsp.buf.hover({
            border = border,
        })

        -- LSP Diagnostics Options Setup
        local sign = function(opts)
            vim.fn.sign_define(opts.name, {
                texthl = opts.name,
                text = opts.text,
                numhl = ''
            })
        end
        sign({ name = 'DiagnosticSignError', text = '' }) --''
        sign({ name = 'DiagnosticSignWarn', text = '' })
        sign({ name = 'DiagnosticSignHint', text = 'H' }) --
        sign({ name = 'DiagnosticSignInfo', text = '' })
        vim.diagnostic.config({
            virtual_text = true,
            -- virtual_text = {
            --     format = function(diagnostic)
            --         if diagnostic.severity == vim.diagnostic.severity.ERROR then
            --             return "" .. diagnostic.message
            --         elseif diagnostic.severity == vim.diagnostic.severity.WARN then
            --             return "" .. diagnostic.message
            --         elseif diagnostic.severity == vim.diagnostic.severity.INFO then
            --             return "" .. diagnostic.message
            --         else
            --             return "H" .. diagnostic.message
            --         end
            --     end
            -- },
            signs = true,
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

        ----------------------------------------
        --        LSP Diagnostics Float    -----
        ----------------------------------------
        -- vim.cmd([[
        -- autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
        -- ]])


        ----------------------------------------
        --      Format on Save 自动格式化  -----
        ----------------------------------------
        -- vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
    end,
}
