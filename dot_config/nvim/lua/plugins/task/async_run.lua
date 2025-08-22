return {
    "skywind3000/asyncrun.vim",
    version = "*",
    cmd = {
        "AsyncRun",
        "AsyncStop",
        "AsyncReset",
    },
    lazy = true,
    cond = false,
    config = function()
        vim.g.asyncrun_open = 6 --告诉 asyncrun 运行时自动打开高度为 6 的 quickfix 窗口
        vim.g.asyncrun_wrapper = "cmd_wrapper"
        vim.g.asyncrun_save = 2
    end,
}
