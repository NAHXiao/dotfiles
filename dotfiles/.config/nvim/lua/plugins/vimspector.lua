--TODO
return {
    "puremourning/vimspector",
    version = "*",
    lazy = true,
    keys = {
        --1 run
        --S-1 run-release
        --2 breakpoint
        --3 watch
        --4 eval
        --5 debug
        --S-5 stop
        --C-S-5 restart
        --6
        --7
        --8
        --9
        --10 step over
        --11 step into
        --S-11 step out
        { "<F2>",  "<cmd>call vimspector#ToggleBreakpoint()<cr>" },
        { "<F3>",  "<cmd>call vimspector#AddWatch()<cr>" },
        { "<F4>",  "<cmd>call vimspector#Evaluate()<cr>" },
        { "<F5>",  "<cmd>call vimspector#Launch()<cr>" },

        { "<F17>", "<cmd>call vimspector#Stop()<cr>" },
        { "<F41>", "<cmd>call vimspector#Restart()<cr>" },
        -- { "<F6>",      "<cmd>NvimTreeToggle<cr>" },
        -- { "<F7>",      "<cmd>NvimTreeToggle<cr>" },
        -- { "<F8>",      "<cmd>NvimTreeToggle<cr>" },
        -- { "<F9>",      "<cmd>NvimTreeToggle<cr>" },
        { "<F10>", "<cmd>call vimspector#StepOver()<cr>" },     --逐过程
        { "<F11>", "<cmd>call vimspector#StepInto()<cr>" },     --逐语句
        { "<F23>", "<cmd>call vimspector#StepOut()<cr>" },      --跳出(ShiftF11)
    },
    config = function()
        vim.g.vimspector_enable_mappings = 'HUMAN'
        -- vim.cmd("packadd! vimspector")
        -- local vimspector_base_dir=vim.fn.stdpath("data") .. "/lazy/vimspector"
        -- vim.cmd("let g:vimspector_base_dir="..vimspector_base_dir..") ")
        vim.cmd("let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools','CodeLLDB']")
    end,
}
