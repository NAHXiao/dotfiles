return {
    name = "java build",
    builder = function()
        -- Full path to current file (see :help expand())
        local file = vim.fn.expand("%:p")
        return {
            cmd = { "javac" },
            args = {
                "-d",
                vim.fn.expand("%:p:h") .. "/build",
                file,
            },
            components = {
                {
                    "on_output_quickfix",
                    open = true,
                    close = true
                },
                "default"
            },
        }
    end,
    condition = {
        filetype = { "java" },
    },
}
