return {
    name = "cpp run",
    builder = function()
        -- Full path to current file (see :help expand())
        -- local execfile= vim.fn.expand("%:t")
        local file;
        if vim.loop.os_uname().sysname == 'Windows_NT' then
            file = vim.fn.expand("%:p:r") .. ".exe"
        else
            file = vim.fn.expand("%:p:r")
        end
        return {
            cmd = { file },
            args = {},
            components = {
                {
                    "dependencies",
                    task_names = {
                        'g++ build release',
                    },
                    sequential = true
                },
                {
                    "on_output_quickfix",
                    open = true,
                    open_height = 10,
                },
                "default"
            },
            -- strategy = {
            --     "terminal"
            --     -- "toggleterm"
            -- },
        }
    end,
    condition = {
        filetype = { "cpp" },
    },
}
