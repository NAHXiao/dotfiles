return {
    "neovim/nvim-lspconfig",
    version = "*",
    lazy = false,
    event = 'UIEnter',
    --     vim.keymap.set('n', '<leader>q', vim.diagnostic.open_float)
    -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    -- vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    --[[
vim.keymap.set('n', '<leader>i', function()
    -- If we find a floating window, close it.
    local found_float = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= '' then
            vim.api.nvim_win_close(win, true)
            found_float = true
        end
    end

    if found_float then
        return
    end

    vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor' })
end, { desc = 'Toggle Diagnostics' }) ]]

    --
    -- Code Actions
    -- map('n', "ca", ":lua vim.lsp.buf.code_action()<CR>")
    -- vim.cmd([[
    -- nnoremap <silent> gc        <cmd>lua vim.lsp.buf.incoming_calls()<CR>
    -- nnoremap <silent> gs        <cmd>lua vim.lsp.buf.document_symbol()<CR>
    -- nnoremap <silent> gw        <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
    -- nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
    -- nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>
    -- ]])
    --
    keys = {
        { "<leader>q", vim.diagnostic.open_float,    mode = "n" },
        { "[d",        vim.diagnostic.goto_prev,     mode = "n" },
        { "]d",        vim.diagnostic.goto_next,     mode = "n" },
        { "ca",        vim.lsp.buf.code_action,      mode = "n" },
        { "gc",        vim.lsp.buf.incoming_calls,   mode = "n" },
        { "gs",        vim.lsp.buf.document_symbol,  mode = "n" },
        { "gw",        vim.lsp.buf.workspace_symbol, mode = "n" },
        { "g[",        vim.diagnostic.goto_prev,     mode = "n" },
        { "g]",        vim.diagnostic.goto_next,     mode = "n" },
        {
            "<leader>i",
            function()
                -- If we find a floating window, close it.
                local found_float = false
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_config(win).relative ~= '' then
                        vim.api.nvim_win_close(win, true)
                        found_float = true
                    end
                end

                if found_float then
                    return
                end

                vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor' })
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

        --     require("lspconfig").clangd.setup {
        --         -- on_attach = on_attach,
        --         --capabilities = cmp_nvim_lsp.default_capabilities(),
        --         cmd = {
        --             "clangd",
        --             "--offset-encoding=utf-8",
        --         },
        --     }
    end,
}
