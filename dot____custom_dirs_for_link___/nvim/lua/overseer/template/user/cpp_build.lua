return {
    name = "g++ build release",
    builder = function()
        -- Full path to current file (see :help expand())
        local file = vim.fn.expand("%:p")

        local outfile;
        if vim.loop.os_uname().sysname == 'Windows_NT' then
            outfile = vim.fn.expand("%:p:r") .. ".exe"
        else
            outfile = vim.fn.expand("%:p:r")
        end
        return {
            cmd = { "g++" },
            args = { file
            , "--std=c++23"
            , "-o", outfile,
                "-O3"
            },
            components = {
                { "on_output_quickfix", open = true, close = true },
                "default"
            },
            -- strategy = {
            -- "toggleterm",
            -- name = "g++ build release"
            -- },
        }
    end,
    condition = {
        filetype = { "cpp" },
    },
}
