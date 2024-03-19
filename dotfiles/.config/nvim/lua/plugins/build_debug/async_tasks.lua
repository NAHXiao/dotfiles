return {
    "skywind3000/asynctasks.vim",
    version = "*",
    keys = {
        { "<F8>", "<cmd>AsyncTask build<cr>" },
        { "<F7>", "<cmd>AsyncTask run<cr>" },
        { "<F6>", "<cmd>AsyncTask run_input<cr>" },
    },
    lazy = true,
    dependencies = {
        "skywind3000/asyncrun.vim",
    },
    config = function()
        vim.g.asynctasks_extra_config = {
            vim.fn.stdpath("config") .. "/lua/plugins/build_debug/asynctasks.ini",
        }
        vim.g.asynctasks_term_rows = 10
        vim.g.asynctasks_confirm = 0
        -- local tasks = vim.api.nvim_call_function('asynctasks#list("")');
    end,
}
