local ERROR = vim.log.levels.ERROR
local noop = function(...) end
local log_notify = require("utils").log {
    src = false,
    name = true,
    time = false,
    callback = function(lines)
        vim.notify(table.concat(lines, "\n"))
    end,
}
local log = require("utils").log {
    src = false,
    name = true,
    time = false,
}
log_notify = noop
log = noop

local shell_cmds
if jit.os == "Windows" then
    for _, sh in ipairs { { "pwsh", "-nologo" }, { "powershell" }, { "cmd" } } do
        if vim.fn.executable(sh[1]) then
            shell_cmds = sh
            shell_cmds[1] = vim.fn.exepath(shell_cmds[1])
            break
        end
    end
end
if not shell_cmds then
    shell_cmds = { vim.o.shell }
end

local function pmsgcall(...)
    local ok, result_or_errmsg = pcall(...)
    if not ok then
        local info = debug.getinfo(2, "nSl")
        if info then
            result_or_errmsg = ("%s:%d %s(): "):format(info.short_src, info.currentline, info.name)
                .. result_or_errmsg
        end
        vim.notify("[Terminal]: " .. result_or_errmsg, ERROR)
    end
end
local function validbuf(bufnr) --strict
    return bufnr
        and vim.fn.bufexists(bufnr)
        and vim.api.nvim_buf_is_valid(bufnr)
        and vim.api.nvim_buf_is_loaded(bufnr)
end
local unreachable = function(...)
    assert(false)
end
local function visual_selection()
    local mode = vim.fn.mode():byte()
    local line_start, column_start, line_end, column_end
    if mode == 118 then --v
        local pos = vim.fn.getpos("v")
        line_start, column_start = pos[2], pos[3]
        pos = vim.fn.getpos(".")
        line_end, column_end = pos[2], pos[3]
    elseif mode == 86 then --v line
        local pos = vim.fn.getpos("v")
        line_start, _ = pos[2], pos[3]
        pos = vim.fn.getpos(".")
        line_end, _ = pos[2], pos[3]
    else
        return false
    end
    if
        (vim.fn.line2byte(line_start) + (column_start or 0))
        > (vim.fn.line2byte(line_end) + (column_end or 0))
    then
        line_start, column_start, line_end, column_end =
            line_end, column_end, line_start, column_start
    end
    local lines = vim.fn.getline(line_start, line_end)
    if type(lines) == "string" then
        lines = { lines }
    end
    if #lines == 0 then
        return false
    end
    if mode == 118 then
        lines[#lines] = string.sub(lines[#lines], 1, column_end)
        lines[1] = string.sub(lines[1], column_start)
    end
    return lines
end
return {
    unreachable = unreachable,
    validbuf = validbuf,
    pmsgcall = pmsgcall,
    log_notify = log_notify,
    log = log,
    visual_selection = visual_selection,
    ---@type string[]
    default_shell = shell_cmds,
}
