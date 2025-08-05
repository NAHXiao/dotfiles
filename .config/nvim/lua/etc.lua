local utils = require("utils")
local g = vim.g
local uv = vim.uv or vim.loop
local osname = uv.os_uname().sysname
local group = vim.api.nvim_create_augroup("user.config", { clear = true })
---@param opts vim.api.keyset.create_autocmd
local aucmd = function(event, opts)
    vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", opts, { group = group }))
end
-- projroot TODO: Bind To LspAttach workspace_folders[1].name
g.projroot = nil
g.root_marker = {
    -- 版本控制
    ".git",
    ".svn",
    ".hg",
    ".bzr",
    "_darcs",
    ".fslckout",
    -- 构建系统
    "Makefile",
    "CMakeLists.txt",
    "Cargo.toml",
    "pyproject.toml",
    "pom.xml",
    "build.gradle",
    "package.json",
    "go.mod",
    -- IDE/编辑器
    ".project",
    ".root",
    ".vscode",
    ".idea",
    ".projectile",
    -- 工具配置
    "compile_commands.json",
    ".clang-format",
    ".editorconfig",
    ".stylua.toml",
    -- 其他
    ".repo",
    ".gitignore",
}
local function set_global_project_root()
    g.projroot = utils.GetRoot(g.root_marker, {
        startpath = vim.fn.getcwd(),
        use_first_found = false,
        return_dirname = true,
    }) or vim.fn.getcwd()
end
set_global_project_root()
aucmd("DirChanged", {
    callback = function()
        set_global_project_root()
    end,
})
aucmd({ "BufReadPre", "BufNewFile" }, {
    callback = function()
        local buftype = vim.bo.buftype
        if vim.api.nvim_buf_get_name(0) == "" then
            return
        end
        local bufpath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
        if buftype == "" and bufpath ~= "" then
            vim.b.projroot = utils.GetRoot(
                vim.g.root_marker,
                { -- For Common Buffer : it's projroot or it's parent dir ; For Other : nil
                    startpath = vim.fn.fnamemodify(bufpath, ":p:h"),
                    use_first_found = false,
                    return_dirname = true,
                }
            ) or vim.fn.fnamemodify(bufpath, ":p:h")
            -- For asyncrun
            vim.b.asyncrun_root = vim.b.projroot
        end
    end,
})
-- obsidian
do
    local obsidianpath
    if osname == "Windows_NT" then
        obsidianpath = "E:/Obsidian/main"
    elseif osname == "Linux" then
        if g.is_wsl then
            obsidianpath = "/mnt/e/Obsidian/main"
        else
            obsidianpath = os.getenv("HOME") .. "/.local/Obsidian/main"
        end
    else
        obsidianpath = nil
    end
    if obsidianpath ~= nil and uv.fs_stat(obsidianpath) then
        g.obsidianPath = obsidianpath
    end
end
-- stylua: ignore
local english = {
    --start with n
  "n","no","nov","noV","noCTRL‑V","niI","niR","niV","nt","ntT",
  "v","vs","V","Vs","CTRL‑V","CTRL‑Vs",
  "s","S","CTRL‑S",
  "c","cr","cv","cvr",
  "r","rm","r?","!"
}
-- stylua: ignore
local multilingual = {
  "i","ic","ix",
  "R","Rc","Rx","Rv","Rvc","Rvx",
  "t"
}
-- keyboard
--VIMEnter/zh->en: getmode savemode PY.EN
--en->zh/VimLeavePre: resume mode
local im_select_mspy = vim.fs.normalize(vim.fn.stdpath("config") .. "/bin/im-select-mspy.exe")
local stat = vim.uv.fs_stat(im_select_mspy)
if
    (vim.g.is_wsl or vim.g.is_win)
    and stat
    and stat.type == "file"
    and require("bit").band(stat.mode, 73) ~= 0
then
    local enabled = true
    require("utils").aug("IME_Control", true)
    local locked = false
    local latest_call = nil
    local __lock_jobid

    local function stop()
        if __lock_jobid and vim.fn.jobwait({ __lock_jobid }, 0)[1] == -1 then
            vim.fn.jobstop(__lock_jobid)
            __lock_jobid = nil
            return true
        end
    end
    local function get_lock_and_then(do_something)
        local this_call = {} -- Get Unique id
        latest_call = this_call
        local function try_get_lock()
            if this_call ~= latest_call then --这将保证不会有两个getlock同时执行
                return
            end
            if not locked then
                locked = true
                do_something()
            else
                stop()
                vim.defer_fn(try_get_lock, 1)
            end
        end
        try_get_lock()
    end
    ---@type "英语"|"英语模式"|"中文模式"
    local insert_imemode
    local function to_normal() --normal
        __lock_jobid = vim.fn.jobstart({ im_select_mspy, "英语模式" }, {
            on_stdout = function(_, data, _)
                for _, line in ipairs(data) do
                    line = require("utils").trim(line)
                    if #line ~= 0 then
                        insert_imemode, _ = line:match("^(.-)%-%>(.-)$")
                        return
                    end
                end
            end,
            on_exit = function()
                locked = false
            end,
        })
    end

    local function to_insert() --insert
        __lock_jobid = vim.fn.jobstart({ im_select_mspy, insert_imemode }, {
            on_exit = function()
                locked = false
            end,
        })
    end
    aucmd("VimEnter", {
        group = "IME_Control",
        callback = function()
            if enabled then
                get_lock_and_then(to_normal)
            end
        end,
    })
    aucmd("ModeChanged", {
        callback = function(ev)
            if enabled then
                local o, n = ev.match:match("^([^:]+):([^:]+)$")
                assert(type(o) == "string" and type(n) == "string")
                -- local o_en = not o:match("^[iRt]")
                -- local n_en = not n:match("^[iRt]")
                local o_en = not o:match("^[iR]")
                local n_en = not n:match("^[iR]")
                if o_en ~= n_en then
                    if o_en then --en->cn: Resume(?->EN/PY.?)
                        get_lock_and_then(to_insert)
                    elseif n_en then --cn->en: Save->(PY.?->PY.EN)/(EN->PY.EN)
                        get_lock_and_then(to_normal)
                    end
                end
            end
        end,
    })
    --TODO:WinEnter

    --RESUME(WAIT)
    aucmd("VimLeavePre", {
        group = "IME_Control",
        pattern = "*",
        callback = function()
            if enabled then
                vim.system({ im_select_mspy, insert_imemode }):wait()
            end
        end,
    })
    require("utils").map("n", "<leader>\\k", function()
        enabled = not enabled
        require("utils").vim_echo(("AutoSwitch Keyboard: %s"):format(enabled and "On" or "Off"))
    end, { desc = "Toggle autoswitch keyboard" })
end

-- 终端终止时自动进入normal模式
aucmd("TermClose", {
    callback = function(ctx)
        if vim.api.nvim_get_current_buf() == ctx.buf then
            vim.cmd("stopinsert")
        end
    end,
})
--对于已终止的term禁止进入term-insert模式
aucmd("TermOpen", {
    callback = function()
        aucmd("ModeChanged", {
            buffer = 0,
            callback = function()
                local mode = vim.fn.mode()
                if mode == "t" then
                    local status = vim.fn.jobwait({ vim.b.terminal_job_id }, 0)[1]
                    if status ~= -1 then
                        vim.cmd("stopinsert")
                    end
                end
            end,
        })
    end,
})

--禁用保存后的提示
vim.cmd("autocmd BufWritePost * silent! !clear")

-- popup
if vim.fn.has("nvim-0.11") == 1 then
    vim.cmd([[
set mousemodel=popup
aunmenu PopUp.How-to\ disable\ mouse
aunmenu PopUp.-2-
function! s:copy_to_clipboards(text)
  let cb = &clipboard
  if cb =~# 'unnamedplus'
    call setreg('+', a:text)
  endif
  if cb =~# 'unnamed'
    call setreg('*', a:text)
  endif
  call setreg('"', a:text)
endfunction
autocmd BufEnter * if expand('%:p') !=# '' |
      \ silent! aunmenu PopUp.Copy\ file\ path |
      \ silent! aunmenu PopUp.Copy\ file\ name |
      \ amenu PopUp.Copy\ file\ path <cmd>call <SID>copy_to_clipboards(expand('%:p'))<CR> |
      \ amenu PopUp.Copy\ file\ name <cmd>call <SID>copy_to_clipboards(expand('%:t'))<CR> |
      \ endif
]])
end
---仅剩这些window时将尝试:wqa
local fts = {
    "qf",
    "toggleterm",
    "TerminalPanel",
    "trouble",
    "dapui_scopes",
    "snacks_terminal",
    "lazy",
    "mason",
    "TelescopePrompt",
    "dropbar_menu",
    "TerminalBuf",
    "noice",
    -- "neo-tree",
    -- "neo-tree-popup",
    "notify",

    "netrw",
    "qf",
    "help",
    "man",
    "preview",
    "loclist",
    "popup",
}
aucmd("WinEnter", {
    callback = function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local bufnr = vim.api.nvim_win_get_buf(win)
            local ft = vim.fn.getbufvar(bufnr, "&ft")
            -- local bt = vim.fn.getbufvar(bufnr, "&bt")
            if not vim.list_contains(fts, ft) then
                return
            end
        end
        vim.cmd("wqa!")
    end,
})
aucmd("FileType", {
    pattern = fts,
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
    end,
})

-- aucmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
--     command = [[if &nu && mode() != 'i' | set rnu   | endif]],
-- })
--
-- aucmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
--     command = [[if &nu | set nornu | endif]],
-- })

-- Disable inserting comment leader after hitting o or O
-- aucmd("FileType", {
--     command = "set formatoptions-=o",
-- })

-- When saving a file, aucmdtomatically create the file's parent
aucmd({ "BufWritePre", "FileWritePre" }, {
    callback = function()
        local function is_dir(path)
            local stat = uv.fs_stat(path)
            return stat and stat.type == "directory"
        end
        local dir = vim.fn.expand("<afile>:p:h")
        if not is_dir(dir) then
            vim.fn.mkdir(dir, "p")
        end
    end,
})
