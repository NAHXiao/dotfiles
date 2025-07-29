local utils = require("utils")
local g = vim.g
local uv = vim.uv or vim.loop
local osname = uv.os_uname().sysname
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
    g.projroot = utils.findfile_any({
        filelist = g.root_marker,
        startpath = vim.fn.getcwd(),
        use_first_found = false,
        return_dirname = true,
    }) or vim.fn.getcwd()
end
set_global_project_root()
vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
        set_global_project_root()
    end,
})
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    callback = function()
        local buftype = vim.bo.buftype
        local name = vim.api.nvim_buf_get_name(0)
        if buftype == "" and name ~= "" then
            vim.b.projroot = utils.findfile_any({ -- For Common Buffer : it's projroot or it's parent dir ; For Other : nil
                filelist = vim.g.root_marker,
                startpath = vim.fn.fnamemodify(name, ":p:h"),
                use_first_found = false,
                return_dirname = true,
            }) or vim.fn.fnamemodify(name, ":p:h")
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
if vim.g.is_wsl or vim.g.is_win then
    vim.api.nvim_create_augroup("IME_Control", { clear = true })
    local im_select = vim.fs.normalize(vim.fn.stdpath("config") .. "/bin/im-select.exe")
    local im_select_mspy = vim.fs.normalize(vim.fn.stdpath("config") .. "/bin/im-select-mspy.exe")
    ---@type "英语"|"英语模式"|"中文模式"
    local insert_imemode
    local inited
    local pending_jobid = {
        en_leave = nil,
        en_enter = nil,
    }
    local function stop(jobid)
        if jobid and vim.fn.jobwait({ jobid }, 0)[1] == -1 then
            vim.fn.jobstop(jobid)
        end
    end
    local function assert_in(str, list)
        for _, it in ipairs(list) do
            if it == str then
                return
            end
        end
        assert(false, str .. "not in" .. vim.inspect(list))
    end
    vim.api.nvim_create_autocmd("VimEnter", {
        group = "IME_Control",
        callback = function()
            vim.schedule(function()
                local after_mode
                vim.fn.jobstart({ im_select_mspy, "英语模式" }, {
                    on_stdout = function(_, data, _)
                        for _, line in ipairs(data) do
                            line = require("utils").trim(line)
                            if #line ~= 0 then
                                insert_imemode, after_mode = line:match("^(.-)%-%>(.-)$")
                                assert_in(insert_imemode, {
                                    "英语",
                                    "英语模式",
                                    "中文模式",
                                })
                                assert_in(after_mode, { "英语", "英语模式" })
                                return
                            end
                        end
                    end,
                    on_exit = function(_, code, _)
                        assert(code == 0)
                        assert_in(after_mode, { "英语", "英语模式" })
                        if after_mode == "英语" then
                            vim.fn.jobstart({ im_select, "2052" }, {
                                on_exit = function(_, code, _)
                                    assert(code == 0)
                                    vim.fn.jobstart({ im_select_mspy, "英语模式" }, {
                                        on_exit = function(_, code, _)
                                            assert(code == 0)
                                            inited = true
                                        end,
                                    })
                                end,
                            })
                        else
                            inited = true
                        end
                    end,
                })
            end)
        end,
    })
    vim.api.nvim_create_autocmd("ModeChanged", {
        callback = function(ev)
            if inited then
                vim.schedule(function()
                    local o, n = ev.match:match("^([^:]+):([^:]+)$")
                    assert(type(o) == "string" and type(n) == "string")
                    local o_en = not o:match("^[iRt]")
                    local n_en = not n:match("^[iRt]")
                    if o_en ~= n_en then
                        if o_en then --en->cn: Resume(?->EN/PY.?)
                            stop(pending_jobid.en_enter)
                            if insert_imemode == "英语" then --?->EN
                                pending_jobid.en_leave = vim.fn.jobstart({ im_select, "1033" }, {
                                    on_exit = function()
                                        pending_jobid.en_leave = nil
                                    end,
                                })
                            else --?->PY.?
                                local after_mode
                                pending_jobid.en_leave = vim.fn.jobstart( --Assume ?=PY.?
                                    { im_select_mspy, insert_imemode },
                                    {
                                        on_stdout = function(_, data, _)
                                            for _, line in ipairs(data) do
                                                line = require("utils").trim(line)
                                                if #line ~= 0 then
                                                    _, after_mode = line:match("^(.-)%-%>(.-)$")
                                                    assert_in(
                                                        _,
                                                        { "英语", "英语模式", "中文模式" }
                                                    )
                                                    assert_in(
                                                        after_mode,
                                                        { "英语", "英语模式", "中文模式" }
                                                    )
                                                    return
                                                end
                                            end
                                        end,
                                        on_exit = function(_, code, _)
                                            pending_jobid.en_leave = nil
                                            if code ~= 0 then --stop->stop
                                                return
                                            end
                                            assert_in(
                                                after_mode,
                                                { "英语", "英语模式", "中文模式" }
                                            )
                                            if after_mode == "英语" then --Assume ?=PY.? Failed, ?=EN
                                                pending_jobid.en_leave = vim.fn.jobstart(
                                                    { im_select, "2052" },
                                                    {
                                                        on_exit = function(_, code, _)
                                                            pending_jobid.en_leave = nil
                                                            if code ~= 0 then
                                                                return
                                                            end
                                                            --NOTE:此处可能出现并发问题
                                                            pending_jobid.en_leave = vim.fn.jobstart(
                                                                { im_select_mspy, insert_imemode },
                                                                {
                                                                    on_exit = function()
                                                                        pending_jobid.en_leave = nil
                                                                    end,
                                                                }
                                                            )
                                                        end,
                                                    }
                                                )
                                            end
                                        end,
                                    }
                                )
                            end
                        elseif n_en then --cn->en: Save->(PY.?->PY.EN)/(EN->PY.EN)
                            stop(pending_jobid.en_leave)
                            local after_mode
                            pending_jobid.en_enter = vim.fn.jobstart( --Try PY.?->PY.EN
                                { im_select_mspy, "英语模式" },
                                {
                                    on_stdout = function(_, data, _)
                                        for _, line in ipairs(data) do
                                            line = require("utils").trim(line)
                                            if #line ~= 0 then
                                                insert_imemode, after_mode =
                                                    line:match("^(.-)%-%>(.-)$")
                                                assert_in(
                                                    insert_imemode,
                                                    { "英语", "英语模式", "中文模式" }
                                                )
                                                assert_in(after_mode, { "英语", "英语模式" })
                                                return
                                            end
                                        end
                                    end,
                                    on_exit = function(_, code, _)
                                        pending_jobid.en_enter = nil --NOTE:此处可能出现并发问题
                                        if code ~= 0 then --stop->stop
                                            return
                                        end
                                        assert_in(after_mode, { "英语", "英语模式" })
                                        if after_mode == "英语" then --PY.?->PY.EN Failed,Try ?->EN->PY.EN
                                            pending_jobid.en_enter = vim.fn.jobstart(
                                                { im_select, "2052" },
                                                {
                                                    on_exit = function(_, code, _)
                                                        pending_jobid.en_enter = nil
                                                        if code ~= 0 then
                                                            return
                                                        end
                                                        --NOTE:此处可能出现并发问题
                                                        pending_jobid.en_enter = vim.fn.jobstart(
                                                            { im_select_mspy, "英语模式" },
                                                            {
                                                                on_exit = function()
                                                                    pending_jobid.en_enter = nil
                                                                end,
                                                            }
                                                        )
                                                    end,
                                                }
                                            )
                                        end
                                    end,
                                }
                            )
                        end
                    end
                end)
            end
        end,
    })
    --RESUME(WAIT)
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = "IME_Control",
        pattern = "*",
        callback = function()
            if insert_imemode == "英语" then
                vim.system({ im_select, "1033" }):wait()
            else
                vim.system({ im_select_mspy, insert_imemode }):wait()
            end
        end,
    })
end

-- 终端终止时自动进入normal模式
vim.api.nvim_create_autocmd("TermClose", {
    callback = function(ctx)
        if vim.api.nvim_get_current_buf() == ctx.buf then
            vim.cmd("stopinsert")
        end
    end,
})
--对于已终止的term禁止进入term-insert模式
vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        vim.api.nvim_create_autocmd("ModeChanged", {
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
vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local bufnr = vim.api.nvim_win_get_buf(win)
            local ft = vim.fn.getbufvar(bufnr, "&ft")
            local bt = vim.fn.getbufvar(bufnr, "&bt")
            -- require("utils").log("ft:", ft, "bt:", bt, "name:", vim.api.nvim_buf_get_name(bufnr))
            -- if not (vim.list_contains(fts, ft) or bt == "nofile") then
            if not vim.list_contains(fts, ft) then
                return
            end
        end
        vim.cmd("qa!")
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = fts,
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
    end,
})
