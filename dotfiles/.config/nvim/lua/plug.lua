-- [[ plug.lua ]]

-- [[ Plugins Go Here ]]
return require('packer').startup(function(use)
    ----------------------
    -- Base
    ----------------------
    --use { 'neoclide/coc.nvim', branch = 'release' }
    use 'wbthomason/packer.nvim'                                             -- Packer package manager
    use 'hrsh7th/vim-vsnip'                                                  -- Snippet engine
    use { 'kyazdani42/nvim-tree.lua',                                        -- Filesystem navigation
        requires = 'kyazdani42/nvim-web-devicons' }                          -- Filesystem icons
    use 'lewis6991/impatient.nvim'                                           -- Makes neovim faster ???
    use 'numToStr/FTerm.nvim'                                                -- Terminal in Lu-a
    use 'nvim-treesitter/nvim-treesitter'                                    -- better syntax
    use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' } -- good folding 代码折叠
    use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }     -- git quick diff
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
    --[[ use 'tpope/vim-commentary' ]]
    use 'folke/trouble.nvim'                                         -- Summarizes issues 诊断?
    use 'folke/todo-comments.nvim'                                   -- Todo comments
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- Make telescope faster
    use 'nvim-telescope/telescope.nvim'                              -- Fuzzy finder
    use 'nvim-telescope/telescope-media-files.nvim'                  -- image files preview in telescope
    use 'BurntSushi/ripgrep'                                         -- Telescope grep
    use 'sharkdp/fd'                                                 -- Finder
    ----------------------
    -- Build and Debug
    ----------------------
    use 'simrat39/rust-tools.nvim' -- rust-analyzer hints and more!
    use 'saecki/crates.nvim'       -- Help managing crates dependencies
    use 'nvim-lua/popup.nvim'      -- Poup for telescope
    use 'nvim-lua/plenary.nvim'    -- Collection of Lua functions
    use 'puremourning/vimspector'  -- Debugger
    use 'mfussenegger/nvim-dap'    -- Debugger
    ----------------------
    --Appearance
    ----------------------
    use 'm-demare/hlargs.nvim'         -- Highlight argument definitions and usages
    use "rebelot/kanagawa.nvim"
    use { 'nvim-lualine/lualine.nvim', -- Statusline
        requires = { 'kyazdani42/nvim-web-devicons', opt = true } }
    use 'xiyaowong/nvim-transparent'   -- enable transparency , useless in wezterm ???
    use 'lukas-reineke/headlines.nvim' -- highlights headlines for markdown, other txt files
    use 'tanvirtin/monokai.nvim'       -- Color scheme
    use {
        'goolord/alpha-nvim',          -- 首页?
        config = function()
            require 'alpha'.setup(require 'alpha.themes.dashboard'.config)
        end
    }
    use 'RRethy/vim-illuminate'               -- Highlight other uses of word under cursor (光标下的word高亮)
    use "lukas-reineke/indent-blankline.nvim" -- ident lines 缩进线条???
    ----------------------
    -- LSP
    ----------------------
    use 'williamboman/mason.nvim'           -- Manage LSPs and DAPs !
    use 'williamboman/mason-lspconfig.nvim' -- closes gaps with mason
    use 'neovim/nvim-lspconfig'             -- Collection of common configurations for the Nvim LSP client
    use 'j-hui/fidget.nvim'                 -- sho status of nvim-lsp progress
    ----------------------
    -- cmp
    ----------------------
    use 'hrsh7th/cmp-nvim-lsp'     -- LSP completion source for nvim-cmp
    use 'onsails/lspkind.nvim'     -- shows icons in cmp
    use 'hrsh7th/cmp-buffer'       -- Useful completion sources
    use 'hrsh7th/cmp-path'         -- Useful completion sources
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-emoji'        --输入: 可以显示表情
    use 'saadparwaiz1/cmp_luasnip' -- snippets for completion'
    use "hrsh7th/cmp-cmdline"
    use 'L3MON4D3/LuaSnip'         -- snippets for completion 右下角processing提示
    use 'hrsh7th/nvim-cmp'         -- Completion framework
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-vsnip'        -- Snippet completion source for nvim-cmp
    use 'petertriho/cmp-git'
    --[[ use 'zbirenbaum/copilot.lua'
    use {
        "zbirenbaum/copilot-cmp",
        after = { "copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end
    } ]]
    ----------------------
    -- Little Tools
    ----------------------
    use 'github/copilot.vim'
    use 'simrat39/symbols-outline.nvim' -- enable symbols tab
    use {
        "max397574/better-escape.nvim",
        config = function()
            require("better_escape").setup()
        end,
    }
    use 'jiangmiao/auto-pairs'
    --[[ use {
        "windwp/nvim-autopairs", -- Autocomplete (), {}, []
        config = function() require("nvim-autopairs").setup {} end
    } ]]
    use 'tpope/vim-surround'                  -- Add "", '', (), hello=>"hello"=><q>hello</q>
    use { 'phaazon/hop.nvim', branch = 'v2' } -- Navitage to any word in the file 快速跳转
end)                                          -- init.lua
