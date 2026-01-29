local utils = require("utils")
local g = vim.g
local uv = vim.uv
local osname = uv.os_uname().sysname
local group = vim.api.nvim_create_augroup("user.config", { clear = true })
---@param opts vim.api.keyset.create_autocmd
local aucmd = function(event, opts)
    vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", opts, { group = group }))
end
-- stylua: ignore
local english = {
    --start with n
    "n", "no", "nov", "noV", "noCTRL‑V", "niI", "niR", "niV", "nt", "ntT",
    "v", "vs", "V", "Vs", "CTRL‑V", "CTRL‑Vs",
    "s", "S", "CTRL‑S",
    "c", "cr", "cv", "cvr",
    "r", "rm", "r?", "!"
}
-- stylua: ignore
local multilingual = {
    "i", "ic", "ix",
    "R", "Rc", "Rx", "Rv", "Rvc", "Rvx",
    "t"
}
-- keyboard
--VIMEnter/zh->en: getmode savemode PY.EN
--en->zh/VimLeavePre: resume mode
local im_select_mspy = vim.fs.normalize(vim.fn.stdpath("config") .. "/bin/im-select-mspy.exe")
local stat = vim.uv.fs_stat(im_select_mspy)
if
    (vim.fn.has("wsl") and stat and stat.type == "file" and require("bit").band(stat.mode, 73) ~= 0)
    or (jit.os == "Windows" and stat and stat.type == "file")
then
    local enabled = true
    require("utils").aug("IME_Control", true)
    local locked = false
    local latest_call = nil
    local __lock_jobid

    local function stop()
        if __lock_jobid and vim.fn.jobwait({ __lock_jobid }, 0)[1] == -1 then
            vim.defer_fn(function()
                pcall(vim.fn.jobstop, __lock_jobid)
            end, 1000 * 3)
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
    ---@type "0"|"1"|"2"
    local insert_imemode
    local function to_normal() --normal
        __lock_jobid = vim.fn.jobstart({ im_select_mspy, "2" }, {
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
    --RESUME(WAIT)
    aucmd("VimLeavePre", {
        group = "IME_Control",
        pattern = "*",
        callback = function()
            if enabled then
                vim.system({ im_select_mspy, "2" }, { detach = true })
            end
        end,
    })
    require("utils").map("n", "<leader>\\k", function()
        enabled = not enabled
        require("utils").vim_echo(("AutoSwitch Keyboard: %s"):format(enabled and "On" or "Off"))
    end, { desc = "Toggle autoswitch keyboard" })
    require("utils").map("n", "gQ", function()
        local filename = vim.fn.input("FilePath")
        while true do
            if enabled then
                insert_imemode = "1"
                to_insert()
            end
            local input = vim.fn.input("Ex-insert")
            if input == "visual" or input == ":visual" then
                break
            end
            if input ~= "" then
                vim.fn.writefile({ input }, filename, "a")
                -- local last_line = vim.fn.line("$")
                -- vim.fn.append(last_line, input)
                -- vim.cmd("normal! G")
            end
        end
    end, { desc = "Enter Ex-insert mode" })
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
    "Outline",
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
        vim.ui.input({ prompt = "Exit?" }, function(input)
            if input and not string.find(input:lower(), "^n") then
                vim.cmd("wa!")
                vim.cmd("qa!")
            end
        end)
    end,
})
-- 自动恢复光标位置
vim.cmd([[
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
]])
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
