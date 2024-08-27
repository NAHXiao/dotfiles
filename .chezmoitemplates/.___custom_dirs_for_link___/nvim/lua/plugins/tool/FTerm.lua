return {
    "numToStr/FTerm.nvim",
    version = "*",
    lazy = true,
    enable = false,
    cond = false,
    -- vim.keymap.set('t', '<Esc>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
    -- vim.keymap.set('n', '<c-space>', '<CMD>lua require("FTerm").toggle()<CR>')
    -- vim.keymap.set('t', '<c-space>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
    -- map('i', "<C-space>", "<C-[>")
    --
    -- -- windows似乎发送不了ctrl-space,用ctrl-\代替
    -- vim.keymap.set('n', '<c-\\>', '<CMD>lua require("FTerm").toggle()<CR>')
    -- vim.keymap.set('t', '<c-\\>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
    -- vim.keymap.set('i', "<C-\\>", "<C-[>")
    --
    --
    --
    -- map('t', "<F1>", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>")
    -- map('n', "<F1>", ":lua CompileAndRunning() <CR>")
    -- map('n', "<F13>", ":lua CompileAndRunningRelease() <CR>")
    --
    keys = {
        { "<Esc>",     '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', mode = 't' },
        { "<c-space>", '<CMD>lua require("FTerm").toggle()<CR>',            mode = 'n' },
        { "<c-space>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', mode = 't' },
        { "<c-\\>",    '<CMD>lua require("FTerm").toggle()<CR>',            mode = 'n' },
        { "<c-\\>",    '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', mode = 't' },
        -- { "<F1>",      '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', mode = 't' },
        -- { "<F1>",      ':lua CompileAndRunning() <CR>',                     mode = 'n' },
        -- { "<F13>",     ':lua CompileAndRunningRelease() <CR>',              mode = 'n' },
    },
    config = function()
        local oscmd
        local os = vim.loop.os_uname().sysname;
        if os == 'Windows_NT' then
            oscmd = "bash"
        elseif os == "Linux" then
            oscmd = "zsh"
        else
            -- oscmd = "zsh"
            oscmd = os.getenv("SHELL")
        end
        require('FTerm').setup({
            border     = 'single',
            -- cmd = os.getenv('SHELL'),
            cmd        = oscmd,
            blend      = 0,
            dimensions = {
                height = 0.9,
                width = 0.9,
            },
        })
    end,
}
