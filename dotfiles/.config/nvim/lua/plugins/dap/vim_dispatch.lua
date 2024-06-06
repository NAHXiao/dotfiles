return {
    "tpope/vim-dispatch",
    version = "*",
    --map("n", "<leader>e", ":TroubleToggle<cr>")
    keys={
    },
    lazy = false,
    enable=false,
    cond=false,
    config = function()
        vim.cmd([[
        autocmd FileType java let b:dispatch = 'javac %'
        autocmd FileType python let b:dispatch = 'python %'
        autocmd FileType c let b:dispatch = 'gcc % -o %<'
        autocmd FileType cpp let b:dispatch = 'g++ % -o %<'
        autocmd FileType lua let b:dispatch = 'lua %'
        autocmd FileType sh let b:dispatch = 'bash %'
        autocmd FileType go let b:dispatch = 'go run %'
        autocmd FileType rust let b:dispatch = 'cargo run'
        autocmd FileType javascript let b:dispatch = 'node %'
        autocmd FileType typescript let b:dispatch = 'ts-node %'
        autocmd FileType R let b:dispatch = 'Rscript %'
        ]])
    end,
}
