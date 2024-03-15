-- [[ keys.lua ]]
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- format encoding? (\r\n -> \n)
map('n','<leader>fe',':%s#\\r##g<CR>',{ silent = true })
-- [[ surround ]]
-- cs"'
-- cs"<q>
-- ds"
-- ysiw]
-- cs]{
-- yss)
-- ds{ds(
-- ysiw)
--重启lsp
map('n', '<leader>rl', ':LspRestart<CR>')
map('n', '<leader>sl', ':LspStop<CR>')
-- 翻页
map('n', '<C-f>', '<PageDown>')
map('n', '<C-b>', '<PageUp>')
--local map = vim.api.nvim_set_keymap

-- remap the key used to leave insert mode
-- map("i", "jk", "", {})
--map('n', 'n', [[:NvimTreeToggle]], {})
map('n', '<leader>P', "ggVGp")
--vim.cmd([[
--" " Copy to clipboard
--vnoremap  <leader>y  "+y
--nnoremap  <leader>Y  "+yg_
--nnoremap  <leader>y  "+y
--nnoremap  <leader>yy  "+yy
--" " Paste from clipboard
--nnoremap <leader>p "+p
--nnoremap <leader>P "+P
--vnoremap <leader>p "+p
--vnoremap <leader>P "+P
--]])
--map('n', '<C-f>', ':Files<CR>', { silent = true })
map('n', '<leader>-f', ':Rg<CR>', { silent = true })
map('n', '<c-n>', '<cmd>NvimTreeToggle<CR>')
map('n', '<leader>n', '<cmd>NvimTreeToggle<CR>')

--@模板
vim.cmd([[
nnoremap <silent> L :call LoadTemplate()<CR>
function! LoadTemplate()
let userInput = input("请输入要插入的模板: ")
execute "r " "$HOME/template/". userInput
endfunction
]])

vim.cmd([[
"禁用F1
noremap <F1> <Nop>
inoremap <F1> <Nop>
"禁用H
noremap <silent> H h
"tnoremap <C-[><C-[>  <C-\><C-n>:q<CR>
nnoremap <C-[><C-[>  :q<CR>
"tnoremap <C-[>  <C-\><C-n>
tnoremap <C-w><C-h> <C-\><C-n><C-w><C-h><CR>
tnoremap <C-w><C-j> <C-\><C-n><C-w><C-j><CR>
tnoremap <C-w><C-k> <C-\><C-n><C-w><C-k><CR>
tnoremap <C-w><C-l> <C-\><C-n><C-w><C-l><CR>

noremap <A-h> <C-[><C-w><C-h><CR>
noremap <A-j> <C-[><C-w><C-j><CR>
noremap <A-k> <C-[><C-w><C-k><CR>
noremap <A-l> <C-[><C-w><C-l><CR>
"切换系统剪贴板
noremap <A-y> :ToggleClipboard<CR>

tnoremap <A-h> <C-\><C-n><C-w><C-h><CR>
tnoremap <A-j> <C-\><C-n><C-w><C-j><CR>
tnoremap <A-k> <C-\><C-n><C-w><C-k><CR>
tnoremap <A-l> <C-\><C-n><C-w><C-l><CR>
]])
map('i', "<C-,>", "<C-[>I")
map('i', "<C-.>", "<C-[>A")
map('i', "<C-h>", "<C-[>I")
map('i', "<C-l>", "<C-[>A")
map('t', "<leader><c-[>", "<C-\\><C-n>")
-- map('i', "<C-j>", "<C-[>o")
-- map('i', "<C-k>", "<C-[>O")


vim.api.nvim_command([[
  function! GotoNextEnd()
    let lnum = line('.')
    let nlines = line('$')
    if lnum == nlines
      call append(lnum, '')
    endif
      call cursor(lnum + 1, col([lnum + 1, '$']))
  endfunction
]])
vim.api.nvim_command([[
  function! GotoNextBegin()
    let lnum = line('.')
    let nlines = line('$')
    if lnum == nlines
      call append(lnum, '')
    endif
      call cursor(lnum + 1, col([lnum + 1, 1]))
  endfunction
]])
map('i', '<C-CR>', [[<Esc>:call GotoNextBegin()<CR>i]], { noremap = true, silent = true })
map('i', '<S-CR>', [[<Esc>:call GotoNextEnd()<CR>a]], { noremap = true, silent = true })

-- map('n', "<C-/>", ":Commentary<CR>")
-- map('i', "<C-/>", "<C-[>:Commentary<CR>")
-- map('v', "<C-/>", "<C-[>:Commentary<CR>")

-- Comment.nvim configuration
-- current line
vim.keymap.set('n', '<C-/>', '<Plug>(comment_toggle_linewise_current)')
vim.keymap.set('v', '<C-.>', '<Plug>(comment_toggle_blockwise_current)')

-- Toggle in VISUAL mode
vim.keymap.set('x', '<C-/>', '<Plug>(comment_toggle_linewise_visual)')
vim.keymap.set('x', '<C-.>', '<Plug>(comment_toggle_blockwise_visual)')



map('i', "<C-s>", "<C-[>:wa<CR>")
map('n', "<C-s>", "<C-[>:wa<CR>")


--
map("n", "sv",
[[
:luafile ~/.config/nvim/init.lua<cr>
:luafile ~/.config/nvim/lua/cmpconfig.lua<cr>
]])

-- Hop
--map("n", "HH", ":HopWord<cr>")
map("n", "HH", ":HopWordMW<cr>")
map("n", "HF", ":HopPattern<cr>")
map("n", "HL", ":HopLineStart<cr>")
-- Telescope
map("n", "<leader>ff", ":lua require('telescope.builtin').find_files()<cr>")
map("n", "<leader>fm", ":Telescope media_files<cr>")
map("n", "<leader>fg", ":lua require('telescope.builtin').live_grep()<cr>")
map("n", "<leader>fb", ":lua require('telescope.builtin').buffers()<cr>")
map("n", "<leader>fh", ":lua require('telescope.builtin').help_tags()<cr>")
map("n", "<leader>fd", ":lua require('telescope.builtin').diagnostics()<cr>")
map("n", "<leader>fs", ":lua require('telescope.builtin').lsp_workspace_symbols()<cr>") --
map("n", "<leader>fr", ":lua require('telescope.builtin').lsp_references()<cr>")
map("n", "<leader>fi", ":lua require('telescope.builtin').lsp_implementations()<cr>")
map("n", "<leader>fl", ":lua require('telescope.builtin').treesitter()<cr>")
map("n", "<leader>fk", ":lua require('telescope.builtin').keymaps()<cr>")

map("n", "<leader>fc", ":lua require('telescope.builtin').commands()<cr>")
-- map("n", "<leader>fch", ":lua require('telescope.builtin').command_history()<cr>")
-- map("n", "<leader>fsh", ":lua require('telescope.builtin').search_history()<cr>")
map("n", "<leader>fmp", ":lua require('telescope.builtin').man_pages()<cr>")
map("n", "<leader>fgc", ":lua require('telescope.builtin').git_commits()<cr>")
map("n", "<leader>fgb", ":lua require('telescope.builtin').git_branches()<cr>")
-- session
-- map('n', '<leader>se', ":Telescope session-lens theme=get_dropdown<cr>")
-- 
-- map('n', '<leader>se', ":Telescope session-lens<cr>")
map('n', '<leader>se', ':lua require("auto-session.session-lens").search_session<cr>')
map('n', '<leader>ss', ":SessionSave<cr>")
map('n', '<leader>sd', ":SessionDelete<cr>")
-- map('n', '<leader>s', ":Telescope session-lens <cr>")


-- Todo List
map("n", "<leader>qf", ":TodoQuickFix<cr>")

-- Trouble
map("n", "<leader>e", ":TroubleToggle<cr>")

-- Nvim Tree
map("n", "<leader>nt", ":NvimTreeToggle<CR>")

-- Transparency
map("n", "<leader>\\", ":TransparentToggle<CR>")

-- Toggle colored column at 81
map('n', '<leader>|', ':execute "set colorcolumn=" . (&colorcolumn == "" ? "81" : "")<CR>')

-- Navigate buffers
map('n', '<leader>bp', ':bprevious<CR>', {})
map('n', '<leader>bn', ':bnext<CR>', {})
map('n', '<leader>bf', ':bfirst<CR>', {})
map('n', '<leader>bl', ':blast<CR>', {})
map('n', '<leader>bd', ':bdelete<CR>', {})


-- Tagbar Toggle
-- map('n', "<leader>tt", ":TagbarToggle<CR>");
map('n', "<leader>t", ":SymbolsOutline<CR>");


-- Vimspector
-- vim.cmd([[
-- nmap <F5> <cmd>call vimspector#Launch()<cr>
-- nmap <F10> <cmd>call vimspector#StepOver()<cr>
-- nmap <F6> <cmd>call vimspector#Reset()<cr>
-- nmap <F11> <cmd>call vimspector#StepOut()<cr>")
-- nmap <F9> <cmd>call vimspector#StepInto()<cr>")
-- ]])
-- map('n', "<F3>", ":call vimspector#ToggleBreakpoint()<cr>")
-- map('n', "<F4>", ":call vimspector#AddWatch()<cr>")
-- map('n', "<F7>", ":call vimspector#Evaluate()<cr>")



-- Crates Nvim
vim.cmd([[
nnoremap <silent> <leader>ct :lua require('crates').toggle()<cr>
nnoremap <silent> <leader>cr :lua require('crates').reload()<cr>

nnoremap <silent> <leader>cv :lua require('crates').show_versions_popup()<cr>
nnoremap <silent> <leader>cf :lua require('crates').show_features_popup()<cr>
nnoremap <silent> <leader>cd :lua require('crates').show_dependencies_popup()<cr>

nnoremap <silent> <leader>cu :lua require('crates').update_crate()<cr>
vnoremap <silent> <leader>cu :lua require('crates').update_crates()<cr>
nnoremap <silent> <leader>ca :lua require('crates').update_all_crates()<cr>
nnoremap <silent> <leader>cU :lua require('crates').upgrade_crate()<cr>
vnoremap <silent> <leader>cU :lua require('crates').upgrade_crates()<cr>
nnoremap <silent> <leader>cA :lua require('crates').upgrade_all_crates()<cr>

nnoremap <silent> <leader>cH :lua require('crates').open_homepage()<cr>
nnoremap <silent> <leader>cR :lua require('crates').open_repository()<cr>
nnoremap <silent> <leader>cD :lua require('crates').open_documentation()<cr>
nnoremap <silent> <leader>cC :lua require('crates').open_crates_io()<cr>
]])




-- Fix common typos
vim.cmd([[
    cnoreabbrev W! w!
    cnoreabbrev W1 w!
    cnoreabbrev w1 w!
    cnoreabbrev Q! q!
    cnoreabbrev Q1 q!
    cnoreabbrev q1 q!
    cnoreabbrev Qa! qa!
    cnoreabbrev Qall! qall!
    cnoreabbrev Wa wa
    cnoreabbrev Wq wq
    cnoreabbrev wQ wq
    cnoreabbrev WQ wq
    cnoreabbrev wq1 wq!
    cnoreabbrev Wq1 wq!
    cnoreabbrev wQ1 wq!
    cnoreabbrev WQ1 wq!
    cnoreabbrev W w
    cnoreabbrev Q q
    cnoreabbrev Qa qa
    cnoreabbrev Qall qall
    cnoreabbrev WQA wqa
    cnoreabbrev WQa wqa
    cnoreabbrev WqA wqa
    cnoreabbrev Wqa wqa
    cnoreabbrev wQA wqa
    cnoreabbrev wQa wqa
    cnoreabbrev wqA wqa
]])

-- Comment.nvim configuration
-- current line
vim.keymap.set('n', 'cc', '<Plug>(comment_toggle_linewise_current)')
vim.keymap.set('n', 'cb', '<Plug>(comment_toggle_blockwise_current)')

-- Toggle in VISUAL mode
vim.keymap.set('x', 'cc', '<Plug>(comment_toggle_linewise_visual)')
vim.keymap.set('x', 'cb', '<Plug>(comment_toggle_blockwise_visual)')


-- FTerm
--[[ vim.keymap.set('n', 't', '<CMD>lua require("FTerm").toggle()<CR>') ]]
vim.keymap.set('t', '<Esc>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('n', '<c-space>', '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('t', '<c-space>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
map('i', "<C-space>", "<C-[>")

-- windows似乎发送不了ctrl-space,用ctrl-\代替
vim.keymap.set('n', '<c-\\>', '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('t', '<c-\\>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('i', "<C-\\>", "<C-[>")



map('t', "<F1>", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>")
map('n', "<F1>", ":lua CompileAndRunning() <CR>")
map('n', "<F13>", ":lua CompileAndRunningRelease() <CR>")
-- cargo test
-- CargoTest = function()
--     require('FTerm').run({ 'cargo', 'test' })
-- end
-- map('n', "<F50>", [[:lua CargoTest() <CR>]])
-- map('n', "<F1>", [[:lua CargoTest() <CR>]])


-- lsp

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>q', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
-- 诊断列表->TroubleToggle
--[[ vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist) ]]
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
end, { desc = 'Toggle Diagnostics' })


-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
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
-- LSP Navigation
-- Code Actions
map('n', "ca", ":lua vim.lsp.buf.code_action()<CR>")
vim.cmd([[
nnoremap <silent> gc        <cmd>lua vim.lsp.buf.incoming_calls()<CR>
nnoremap <silent> gs        <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gw        <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>
]])



--copilot
-- vim.cmd([[
--         inoremap <silent><script><expr> <leader><tab> copilot#Accept("\<CR>")
--         "imap <silent><script><expr> <c-j> copilot#Accept("\<c-j>")
--         let g:copilot_no_tab_map = v:true
-- ]])


-- Leetcode
-- nnoremap <leader>ll :LeetCodeList<cr>
-- nnoremap <leader>lt :LeetCodeTest<cr>
-- nnoremap <leader>ls :LeetCodeSubmit<cr>
-- nnoremap <leader>li :LeetCodeSignIn<cr>
-- map('n', "<leader>ll", ":LeetCodeList<cr>")
-- map('n', "<leader>lt", ":LeetCodeTest<cr>")
-- map('n', "<leader>ls", ":LeetCodeSubmit<cr>")
-- map('n', "<leader>li", ":LeetCodeSignIn<<cr>")
