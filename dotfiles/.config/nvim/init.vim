"###插件安装
call plug#begin('~/.local/share/nvim/plugged')
    Plug 'itchyny/lightline.vim'
	Plug 'rakr/vim-one'
	Plug 'liuchengxu/vim-which-key',{ 'on': ['WhichKey', 'WhichKey!'] }
	Plug 'junegunn/fzf.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'preservim/nerdtree'
	Plug 'skywind3000/asyncrun.vim'  
	Plug 'skywind3000/asyncrun.extra'
	Plug 'jiangmiao/auto-pairs'
	Plug 'rmagatti/auto-session'
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
	Plug 'github/copilot.vim'
	Plug 'tpope/vim-commentary'
	Plug 'mhartington/formatter.nvim'
    Plug 'nvim-tree/nvim-tree.lua'
	Plug 'nvim-tree/nvim-web-devicons'
	Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
	Plug 'ellisonleao/gruvbox.nvim'
call plug#end()
function! s:setup_auto_session() abort
    execute 'lua << EOF'
    execute 'require("auto-session").setup {
                log_level = "error",
				auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" }
            }'
    execute 'EOF'
endfunction

"###普通配置
"
"

" 设置为molokai配色
" colorscheme molokai  
set background=dark " or light if you want light mode
" colorscheme gruvbox
let g:mapleader="\<Space>"
set tabstop=4
set softtabstop=4
set autoindent
set hidden 
syntax on

set encoding=UTF-8
set fileencodings=ucs-bom,utf-8,cp936

set nu
augroup relative_numbser 
autocmd! InsertEnter * :set norelativenumber 
autocmd! InsertLeave * :set relativenumber 
augroup END

"### 剪贴板
"+寄存器
"set clipboard=unnamed
set clipboard=unnamedplus 
"#set clipboard+=autoselect

"###折叠
set foldmethod=syntax
"manual 手动  syntax 语法 indent 缩进
set nofoldenable



""###主题
"取消注释以使用One配色方案,dark/light
"let g:airline_theme='one'
"colorscheme one
"set background=dark


"###插件配置
"let g:fzf_default_command = 'cd ' . expand('%:p:h') . ' && rg --files --no-ignore --hidden --follow --glob "!.git/*"'

"### auto session
let g:auto_session_root_dir = '~/.local/share/nvim/sessions'



set timeoutlen=800

"@find使用该path
set path+=$PWD/**

"@netrw内置文件浏览器
set nocp
filetype plugin on

"@将Grep替换为Rg
set grepprg=rg\ --vimgrep\ --smart-case\ --follow

"@coc补全
set signcolumn=yes
"set nobackup
"set nowritebackup
set updatetime=100
set shortmess+=c
"同词高亮
autocmd CursorHold * silent call CocActionAsync('highlight')

"按键映射#####################################################################################

"@搜索
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <Leader>f :Rg<CR>
"@补全
"inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"inoremap <expr> <C-Tab> pumvisible() ? "\<C-p>\<C-n>" : "\<Tab>"
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
"改变<CR>?
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction



"<c-space>打开补全在任意位置
if has('nvim')
inoremap <silent><expr> <c-space> coc#refresh()
else
inoremap <silent><expr> <c-@> coc#refresh()
endif

"跳转到下/上一个报错位置
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
"跳转定义与调用
" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

"显示文档
" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
if CocAction('hasProvider', 'hover')
call CocActionAsync('doHover')
else
call feedkeys('K', 'in')
endif
endfunction
"变量/函数等重命名
nmap <leader>rn <Plug>(coc-rename)
"格式化代码
" Formatting selected code
" xmap <leader>fo  <Plug>(coc-format-selected)
vnoremap <leader>fo  <Plug>(coc-format-selected)
nnoremap <silent> <leader>fo :Format<CR>
"注释
"@编译
"c/c++
nnoremap <F5> :wa <CR> :AsyncRun -mode=terminal -cwd=<root> -rows=10 c++ ${VIM_ROOT}/*.cpp -o ${VIM_ROOT}/${VIM_FILENOEXT} && chmod +x ${VIM_ROOT}/${VIM_FILENOEXT}&& echo -e '\n-----' && ${VIM_ROOT}/${VIM_FILENOEXT} <CR>
nnoremap <leader>cc :AsyncRun -mode=terminal -cwd=<root> -rows=10 c++ ${VIM_ROOT}/${VIM_FILENAME} -o ${VIM_ROOT}/${VIM_FILENOEXT} && chmod +x ${VIM_ROOT}/${VIM_FILENOEXT}&& echo -e '\n-----' && ${VIM_ROOT}/${VIM_FILENOEXT}<CR>
nnoremap <leader>rr :wa<CR>:AsyncRun -mode=terminal -cwd=<root> -rows=10  cargo run <CR>
nnoremap <leader>cr :AsyncRun -mode=terminal -cwd=<root> -rows=10 c++ ${VIM_ROOT}/*.cpp -o ${VIM_ROOT}/${VIM_FILENOEXT} && chmod +x ${VIM_ROOT}/${VIM_FILENOEXT}&& echo -e '\n-----' && ${VIM_ROOT}/${VIM_FILENOEXT} <CR>
nnoremap <leader>sr :AsyncRun -mode=terminal -cwd=<root> -rows=10 chmod +x  ${VIM_FILEPATH} ; echo -e '\n-----' && ${VIM_FILEPATH}<CR>
nnoremap <leader>ar :AsyncRun -mode=terminal -cwd=<root> -rows=10 ${VIM_ROOT}/build.sh<CR>
"@目录树
" map <C-n> :NERDTreeToggle<CR>
map <C-n> :NvimTreeToggle<CR>
nnoremap<silent> <Leader><Tab> :bn<CR>
nnoremap<silent> <Leader>j :bn<CR>
nnoremap<silent> <Leader>k :bp<CR>
" nnoremap<silent> <Leader>c :bdelete<CR>
"@终端
" nnoremap<silent> <Leader>t :AsyncRun -mode=terminal -cwd=<root> -rows=10 powershell bash <CR>
nnoremap<silent> <Leader>t :AsyncRun -mode=terminal -cwd=<root> -rows=10 zsh <CR>
"@模板
nnoremap <silent> L :call LoadTemplate()<CR>
function! LoadTemplate()
let userInput = input("请输入要插入的模板: ")
execute "r " "$HOME/template/". userInput
endfunction
"禁用H
noremap <silent> H h
tnoremap <C-[><C-[>  <C-\><C-n>:q<CR>
nnoremap <C-[><C-[>  :q<CR>
tnoremap <C-[>  <C-\><C-n>
tnoremap <C-w><C-h> <C-\><C-n><C-w><C-h><CR>
tnoremap <C-w><C-j> <C-\><C-n><C-w><C-j><CR>
tnoremap <C-w><C-k> <C-\><C-n><C-w><C-k><CR>
tnoremap <C-w><C-l> <C-\><C-n><C-w><C-l><CR>
"@插入模式
"#inoremap <C-]> <C-[>o

"转到本行结尾/开头
" noremap <C-a> <C-[>I
inoremap <C-,> <C-[>I
" noremap <C-e> <C-[>A
inoremap <C-.> <C-[>A

"向下开新行<C-j>
" noremap <C-j>  <C-[>o
inoremap <C-j>  <C-[>o<C-[>I
"noremap <S-Enter> <C-[>o

"向上开新行<C-k>
" noremap <C-k>  <C-[>O
inoremap <C-k>  <C-[>O<C-[>I
"转到下一行末尾 <S-Enter>
"noremap <leader><Enter> <C-[>jA

" noremap <S-Enter>  <C-[>jA
inoremap <S-Enter>  <C-[>jA

"转到下一行开头 <C-Enter>
"noremap <leader><S-Enter> <C-[>jI

" noremap <C-Enter>  <C-[>jI
inoremap <C-Enter>  <C-[>jI

"%用于跳转到匹配的括号

"注释(/)
"noremap <C-/> :s#^#//<CR>:noh<CR>
"inoremap <C-/> :s#^#//<CR>:noh<CR>
"noremap <C-?> :s#^#//<CR>:noh<CR>
" inoremap <C-?> :s#^#//<CR>:noh<CR>
noremap  <C-/> :Commentary<CR>
inoremap  <C-/> <C-[>:Commentary<CR>a
"保存
noremap <C-s> <C-[>:wa<CR>
inoremap <C-s> <C-[>:wa<CR>a


   

"Leader键尽量不用于编辑时常用的操作
"重载vim配置source vim 
" nnoremap <leader>sv :source $HOME/AppData/Local/nvim/init.vim <CR> 
" nnoremap <leader>sv :source $XDG_CONFIG_HOME/nvim/init.vim <CR> 
nnoremap <leader>sv :source $HOME/.config/nvim/init.vim <CR> 
" nnoremap <leader>sw  \
" let fp =  :echo 
"  :source $HOME/.config/nvim/init.lua <CR>

"Tab标签配置
" In your init.lua or init.vim
set termguicolors


lua require"bufferline".setup()  
"表示引入



lua<<EOF
   require("bufferline").setup {}
local bufferline = require("bufferline")
bufferline.setup { 
		  options = { 
            mode = "buffer", -- set to "tabs" to only show tabpages instead
            style_preset = bufferline.style_preset.default, -- or bufferline.style_preset.minimal,
            numbers =  "ordinal",
            close_command = "bdelete! %d",       -- can be a string | function, | false see "Mouse actions"
			--TODO
            right_mouse_command = "bdelete! %d", -- can be a string | function | false, see "Mouse actions"
            left_mouse_command = "buffer %d",    -- can be a string | function, | false see "Mouse actions"
			--TODO
            middle_mouse_command = nil,          -- can be a string | function, | false see "Mouse actions"
			indicator = {
                icon = '|', -- this should be omitted if indicator style is not 'icon'
                style = 'icon' ,
            },
            buffer_close_icon = '󰅖',
            modified_icon = '●',
            close_icon = '',
            left_trunc_marker = '',
            right_trunc_marker = '',
			--TODO
            name_formatter = function(buf)  -- buf contains:
			end,
            max_name_length =10,
            tab_size = 10,
			--TODO
            diagnostics =  "coc",
			--TODO
            diagnostics_indicator = function(count, level, diagnostics_dict, context)
                return "("..count..")"
            end,
			--TODO
            custom_filter = function(buf_number, buf_numbers)
			 -- filter out filetypes you don't want to see
                if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
                    return true
                end
                -- filter out by buffer name
                if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
                    return true
                end
                -- filter out based on arbitrary rules
                -- e.g. filter out vim wiki buffer from tabline in your work repo
                if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
                    return true
                end
                -- filter out by it's index number in list (don't show first buffer)
                if buf_numbers[1] ~= buf_number then
                    return true
                end
			end,
			--TODO
			offsets = {
                {
                    filetype = "NvimTree",
                    --TODO text = "File Explorer" | function ,
                    --TODO text_align = "left" | "center" | "right"
                    separator = true
                }
            },
            color_icons = true ,-- whether or not to add the filetype icon highlights
			--TODO
            get_element_icon = function(element)
              -- element consists of {filetype: string, path: string, extension: string, directory: string}
              -- This can be used to change how bufferline fetches the icon
              -- for an element e.g. a buffer or a tab.
              -- e.g.
              local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
              return icon, hl
              -- or
              --local custom_map = {my_thing_ft: {icon = "my_thing_icon", hl}}
              --return custom_map[element.filetype]
            end,
            show_buffer_icons = true ,-- disable filetype icons for buffers
            show_buffer_close_icons = true ,
            show_close_icon = true ,
			--TODO What is this? 
            show_tab_indicators =  true,
			--TODO
            show_duplicate_prefix = true , -- whether to show duplicate buffer prefix
			--TODO
            persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
			--TODO
            move_wraps_at_ends = false, -- whether or not the move command "wraps" at the first or last position
            separator_style = "thick",
			--TODO
            enforce_regular_tabs = false,
			--TODO
            always_show_bufferline = true ,
			--TODO
            hover = {
                enabled = true,
                delay = 200,
                reveal = {'close'}
            },
			--TODO
            sort_by = 'insert_after_current', 
		}
} 
EOF

lua << EOF
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})
EOF


"autocmd! VimEnter * :source $HOME/AppData/Local/nvim/init.vim

" autocmd! VimEnter * :source $XDG_CONFIG_HOME/nvim/init.vim 
autocmd! VimEnter * :source $HOME/.config/nvim/init.vim 
