return {
    name = "java run",
    builder = function()
        return {
            cmd = { 
                "java"
            },
            args = {
                "-cp",
                vim.fn.expand("%:p:h").."/build",
                vim.fn.expand("%:t:r")
            },
            components = {
                {
                    "dependencies",
                    task_names = {
                        'java build',
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
        filetype = { "java" },
    },
}
