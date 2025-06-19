return {
    "skywind3000/asyncrun.vim",
    version = "*",
    keys = {
        -- { "<F1>", '<cmd>AsyncRun -mode=term -rows=10 echo "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)"<cr>' }, --c/cpp build and run

        -- copen打开quickfix窗口
        -- :AsyncRun gcc "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)"
        -- :AsyncRun g++ -O3 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" -lpthread
        -- :AsyncRun make
        -- :AsyncRun make -f makefile
        -- :AsyncRun -cwd=$(VIM_FILEDIR) -mode=term -pos=TAB
        -- $(VIM_FILEPATH)  - 当前 buffer 的文件名全路径
        -- $(VIM_FILENAME)  - 当前 buffer 的文件名（没有前面的路径）
        -- $(VIM_FILEDIR)   - 当前 buffer 的文件所在路径
        -- $(VIM_FILEEXT)   - 当前 buffer 的扩展名
        -- $(VIM_FILENOEXT) - 当前 buffer 的主文件名（没有前面路径和后面扩展名）
        -- $(VIM_PATHNOEXT) - 带路径的主文件名（$VIM_FILEPATH 去掉扩展名）
        -- $(VIM_CWD)       - 当前 Vim 目录
        -- $(VIM_RELDIR)    - 相对于当前路径的文件名
        -- $(VIM_RELNAME)   - 相对于当前路径的文件路径
        -- $(VIM_ROOT)      - 当前 buffer 的项目根目录
        -- $(VIM_CWORD)     - 光标下的单词
        -- $(VIM_CFILE)     - 光标下的文件名
        -- $(VIM_GUI)       - 是否在 GUI 下面运行？
        -- $(VIM_VERSION)   - Vim 版本号
        -- $(VIM_COLUMNS)   - 当前屏幕宽度
        -- $(VIM_LINES)     - 当前屏幕高度
        -- $(VIM_SVRNAME)   - v:servername 的值
        -- $(VIM_PRONAME)   - 项目名称（projroot 目录的名称）
        -- $(VIM_DIRNAME)   - 当前目录的名称
        -- 同名环境变量也会被初始化，比如 $VIM_FILENAME 这样的，可以被命令进程读取??
        -- <cwd>   - 当前路径
        -- <cword> - 光标下的单词
        -- <cfile> - 光标下的文件名
        -- <root>  - 当前 buffer 的项目根目录
    },
    cmd = {
        "AsyncRun",
        "AsyncStop",
        "AsyncReset",
    },
    lazy = true,
    config = function()
        -- vim.b.asyncrun_root = "/xxxx/path-to-the-project-root"
        vim.g.asynctasks_term_rows = 10
        vim.g.asyncrun_open = 6 --告诉 asyncrun 运行时自动打开高度为 6 的 quickfix 窗口
        -- vim.g.asynctasks_term_pos = 'bottom'
        -- let g:asynctasks_term_pos = 'bottom'
        -- let g:asyncrun_open = 6
        vim.api.nvim_create_autocmd("User", {
            pattern = "AsyncRunStop",
            callback = function(args)
                vim.notify(vim.inspect(args))
            end,
        })
    end,
}
