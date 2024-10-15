return {
    'kyazdani42/nvim-tree.lua',
    version = "*",
    lazy = false,
    dependencies = {
        'kyazdani42/nvim-web-devicons'
    },
    keys = {
        { "<C-n>",     "<cmd>NvimTreeToggle<cr>" },
        { "<leader>n", "<cmd>NvimTreeToggle<cr>" },
    },
    cmd = "NvimTreeToggle",
    config = function()
        --禁用默认的netrw
        vim.g.loaded_netrw             = 1
        vim.g.loaded_netrwPlugin       = 1
        -- o open/close dir
        -- a add
        -- r rename
        -- x cut
        -- c copy
        -- p paste
        -- d delete
        -- <C-]> cd
        -- g? help
        vim.g.loaded_netrw             = 1
        vim.g.loaded_netrwPlugin       = 1
        vim.g.loaded_netrwSettings     = 1
        vim.g.loaded_netrwFileHandlers = 1

        require("nvim-tree").setup({
            diagnostics = {
                enable = true,
            },
            sort = {
                sorter = "case_sensitive",
            },
            view = {
                width = 25,
                number = true,
                relativenumber = true,
            },
            renderer = {
                group_empty = true,
                --add_trailing=true,--文件夹=>文件夹/
                highlight_diagnostics = true,
            },
            filters = {
                dotfiles = true,
            },
        })
    end,
}
