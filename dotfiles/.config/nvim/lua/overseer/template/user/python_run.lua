return {
    name = "python run",
    builder = function()
        -- Full path to current file (see :help expand())
        local file = vim.fn.expand("%:p")
        -- local execfile= vim.fn.expand("%:t")
        return {
            cmd = {
                "python",
            },
            args = {
                file,
            },
            components = {
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
        filetype = { "python" },
    },
}
