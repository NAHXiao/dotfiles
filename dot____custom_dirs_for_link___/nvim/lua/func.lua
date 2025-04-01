DebugToFile = function(log)
    if log == nil then
        return
    end
    local file = io.open((os.getenv('HOME') or os.getenv('USERPROFILE'):gsub([[\]], [[\\]])) .. '/nvim.log', 'a')
    if file ~= nil then
        file:write(os.date("%Y-%m-%d %H:%M:%S", os.time()) .. ' ' .. tostring(log) .. '\n')
        file:close()
    else
        vim.notify('DebugToFile:' .. 'Failed to open log file (' .. file .. '),\nlog:[' .. log .. ']', vim.log.levels
        .ERROR)
    end
end

vim.cmd([[
function! CloseSystemClipboard()
set clipboard=
endfunction
command! CloseSystemClipboard call CloseSystemClipboard()
function! OpenSystemClipboard()
set clipboard=unnamedplus
endfunction
command! OpenSystemClipboard call OpenSystemClipboard()
]])

function ToggleClipboard()
    --TODO 兼容性问题
    local current_clipboard = vim.opt.clipboard:get()[1]
    if current_clipboard == "unnamedplus" then
        vim.opt.clipboard = ""
        print("Clipboard set to empty")
    else
        vim.opt.clipboard = "unnamedplus"
        print("Clipboard set to 'unnamedplus'")
    end
end

vim.cmd("command! ToggleClipboard lua ToggleClipboard()")
function Async_run(cmd, callback)
    local handle
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    handle = vim.loop.spawn(cmd, {
        stdio = { nil, stdout, stderr },
    }, function(code, signal)
        stdout:read_stop()
        stderr:read_stop()
        stdout:close()
        stderr:close()
        handle:close()

        if callback then
            callback(code, signal)
        end
    end)

    local stdout_data = ""
    local stderr_data = ""

    stdout:read_start(function(err, data)
        assert(not err, err)
        if data then
            stdout_data = stdout_data .. data
        end
    end)

    stderr:read_start(function(err, data)
        assert(not err, err)
        if data then
            stderr_data = stderr_data .. data
        end
    end)
    return stdout_data, stderr_data
end

-- local function find_program_path(program)
--     local command
--     if package.config:sub(1, 1) == '\\' then
--         command = 'where ' .. program
--     else
--         command = 'which ' .. program
--     end
--     local handle = io.popen(command)
--     if handle == nil then return end
--     local result = handle:read("*a")
--     handle:close()
--     result = result:gsub("^%s*(.-)%s*$", "%1")
--     if result == '' then
--         return nil
--     end
--     return result
-- end

function ParseVersion(version)
    local vstr = tostring(version)
    local a, b, c = vstr:match("(%d+)%.(%d+)%.(%d+)")
    return { tonumber(a), tonumber(b), tonumber(c) }
end

-- 比较两个版本 {a, b, c}
function VersionIsGreaterEq(v1, v2)
    for i = 1, 3 do
        if v1[i] > v2[i] then
            return true
        elseif v1[i] < v2[i] then
            return false
        end
    end
    return true -- 版本相等
end
-- VersionIsGreaterEq(ParseVersion(vim.version()),ParseVersion("0.9.5"))
