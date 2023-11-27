-- [[ keys.lua ]]
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- [[ surround ]]
-- cs"'
-- cs"<q>
-- ds"
-- ysiw]
-- cs]{
-- yss)
-- ds{ds(
-- ysiw)

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
map('n', '<C-f>', ':Files<CR>', { silent = true })
map('n', '<leader>-f', ':Rg<CR>', { silent = true })
map('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })

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
tnoremap <C-[><C-[>  <C-\><C-n>:q<CR>
nnoremap <C-[><C-[>  :q<CR>
tnoremap <C-[>  <C-\><C-n>
tnoremap <C-w><C-h> <C-\><C-n><C-w><C-h><CR>
tnoremap <C-w><C-j> <C-\><C-n><C-w><C-j><CR>
tnoremap <C-w><C-k> <C-\><C-n><C-w><C-k><CR>
tnoremap <C-w><C-l> <C-\><C-n><C-w><C-l><CR>

noremap <A-h> <C-[><C-w><C-h><CR>
noremap <A-j> <C-[><C-w><C-j><CR>
noremap <A-k> <C-[><C-w><C-k><CR>
noremap <A-l> <C-[><C-w><C-l><CR>

tnoremap <A-h> <C-\><C-n><C-w><C-h><CR>
tnoremap <A-j> <C-\><C-n><C-w><C-j><CR>
tnoremap <A-k> <C-\><C-n><C-w><C-k><CR>
tnoremap <A-l> <C-\><C-n><C-w><C-l><CR>
]])
map('i', "<C-space>", "<C-[>")
map('i', "<C-,>", "<C-[>I")
map('i', "<C-.>", "<C-[>A")
map('i', "<C-j>", "<C-[>o")
map('i', "<C-k>", "<C-[>O")
map('i', "<S-Enter>", "<C-[>jA")
map('i', "<C-Enter>", "<C-[>jI")
-- map('n', "<C-/>", ":Commentary<CR>")
-- map('i', "<C-/>", "<C-[>:Commentary<CR>")
-- map('v', "<C-/>", "<C-[>:Commentary<CR>")

-- Comment.nvim configuration
-- current line
vim.keymap.set('n', '<C-/>', '<Plug>(comment_toggle_linewise_current)')
vim.keymap.set('n', '<C-/>', '<Plug>(comment_toggle_blockwise_current)')

-- Toggle in VISUAL mode
vim.keymap.set('x', '<C-/>', '<Plug>(comment_toggle_linewise_visual)')
vim.keymap.set('x', '<C-/>', '<Plug>(comment_toggle_blockwise_visual)')



map('i', "<C-s>", "<C-[>:wa<CR>")
map('n', "<C-s>", "<C-[>:wa<CR>")


--
map("n", "sv", ":luafile ~/.config/nvim/init.lua<cr>")

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
map("n", "<leader>fs", ":lua require('telescope.builtin').lsp_workspace_symbols()<cr>")
map("n", "<leader>fr", ":lua require('telescope.builtin').lsp_references()<cr>")
map("n", "<leader>fi", ":lua require('telescope.builtin').lsp_implementations()<cr>")
map("n", "<leader>fl", ":lua require('telescope.builtin').treesitter()<cr>")
map("n", "<leader>fk", ":lua require('telescope.builtin').keymaps()<cr>")

map("n", "<leader>fc", ":lua require('telescope.builtin').commands()<cr>")
map("n", "<leader>fch", ":lua require('telescope.builtin').command_history()<cr>")
map("n", "<leader>fsh", ":lua require('telescope.builtin').search_history()<cr>")
map("n", "<leader>fmp", ":lua require('telescope.builtin').man_pages()<cr>")
map("n", "<leader>fgc", ":lua require('telescope.builtin').git_commits()<cr>")
map("n", "<leader>fgb", ":lua require('telescope.builtin').git_branches()<cr>")




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
vim.cmd([[
nmap <F5> <cmd>call vimspector#Launch()<cr>
nmap <F10> <cmd>call vimspector#StepOver()<cr>
nmap <F6> <cmd>call vimspector#Reset()<cr>
nmap <F11> <cmd>call vimspector#StepOut()<cr>")
nmap <F9> <cmd>call vimspector#StepInto()<cr>")
]])
map('n', "<F3>", ":call vimspector#ToggleBreakpoint()<cr>")
map('n', "<F4>", ":call vimspector#AddWatch()<cr>")
map('n', "<F7>", ":call vimspector#Evaluate()<cr>")
-- Run
-- 判断当前缓冲区文件扩展名的函数
function is_file_extension(extensions)
    local current_extension = vim.fn.expand('%:e'):lower()
    for _, ext in ipairs(extensions) do
        if current_extension == ext then
            return true
        end
    end
    return false
end

function CompileAndRunning()
    local current_file = vim.fn.expand('%:p')
    local current_file_without_extension = vim.fn.expand('%:t:r')
    local cpp_extensions = { 'cpp', 'cxx', 'CPP' }
    local echo_gaps = [[(echo;printf '%*s\n' "$(tput cols)" | tr ' ' '-';echo)]]
    local echo_gaps_twice =
    [[(echo;printf '%*s\n' "$(tput cols)" | tr ' ' '-';printf '%*s\n' "$(tput cols)" | tr ' ' '-';echo)]]

    if is_file_extension(cpp_extensions) then
        require('FTerm').run({ echo_gaps })
        require('FTerm').run({ 'g++', current_file, '-o', current_file_without_extension, '&&',
            echo_gaps_twice, '&&', './' ..
        current_file_without_extension })
    elseif is_file_extension({ 'rs' }) then
        require('FTerm').run({ echo_gaps })
        require('FTerm').run({ 'cargo', 'build', '&&', echo_gaps_twice
        , '&&', 'cargo run' })
    elseif is_file_extension({ 'py' }) then
        require('FTerm').run({ echo_gaps_twice })
        require('FTerm').run({ 'python', current_file })
    end
end

map('n', "<F2>", ":lua CompileAndRunning() <CR>")


-- LSP Navigation
-- Code Actions
map('n', "ca", ":lua vim.lsp.buf.code_action()<CR>")
vim.cmd([[
nnoremap <silent> <c-]>     <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <c-k>     <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> K         <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi        <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gc        <cmd>lua vim.lsp.buf.incoming_calls()<CR>
nnoremap <silent> gd        <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr        <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gn        <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> gs        <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gw        <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
]])

vim.cmd([[
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>
]])


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
]])

-- Comment.nvim configuration
-- current line
vim.keymap.set('n', 'cc', '<Plug>(comment_toggle_linewise_current)')
vim.keymap.set('n', 'cb', '<Plug>(comment_toggle_blockwise_current)')

-- Toggle in VISUAL mode
vim.keymap.set('x', 'cc', '<Plug>(comment_toggle_linewise_visual)')
vim.keymap.set('x', 'cb', '<Plug>(comment_toggle_blockwise_visual)')
