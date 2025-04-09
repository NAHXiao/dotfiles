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

-- print(vim.version.gt(vim.version(),{0,9,0}))

function Encode_path(path)
    if not path then
        return ""
    end
    return path:gsub("[<>:\"/\\|?*%s%c]", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

function Decode_path(encoded_path)
    if not encoded_path then
        return ""
    end
    return encoded_path:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

function Findfile_any(opt)
    local default_opt = {
        filelist = {},
        startpath = vim.loop.cwd(),
        use_first_found = false,
        type = { "file", "directory" },
        return_dirname = false
    }
    opt = vim.tbl_deep_extend("force", default_opt, opt or {})
    local startpath = vim.fs.normalize(opt.startpath)
    startpath = vim.fn.fnamemodify(startpath, ':p')
    local current_path = startpath
    local result = nil
    local check_all_types = false
    for _, t in ipairs(opt.type) do
        if t == "*" then
            check_all_types = true
            break
        end
    end
    local type_lookup = {}
    if not check_all_types then
        for _, t in ipairs(opt.type) do
            type_lookup[t] = true
        end
    end
    while true do
        for _, filename in ipairs(opt.filelist) do
            local filepath = vim.fs.joinpath(current_path, filename)
            local stat = vim.loop.fs_stat(filepath)
            if stat then
                local valid_type = check_all_types or type_lookup[stat.type]
                if valid_type then
                    if opt.return_dirname then
                        local return_path = current_path
                        if opt.use_first_found then
                            return return_path
                        else
                            result = return_path
                        end
                    else
                        if opt.use_first_found then
                            return filepath
                        else
                            result = filepath
                        end
                    end
                end
            end
        end
        local parent_path = vim.fn.fnamemodify(current_path, ':h')
        if parent_path == current_path then
            break
        end
        current_path = parent_path
    end
    return result
end

function Findfile_all(opt)
    local default_opt = {
        filelist = {},
        startpath = vim.loop.cwd(),
        use_first_found = false,
        type = { "file", "directory" }
    }
    opt = vim.tbl_deep_extend("force", default_opt, opt or {})
    local startpath = vim.fs.normalize(opt.startpath)
    startpath = vim.fn.fnamemodify(startpath, ':p')
    local results = {}
    for _, filename in ipairs(opt.filelist) do
        results[filename] = nil
    end
    local check_all_types = false
    for _, t in ipairs(opt.type) do
        if t == "*" then
            check_all_types = true
            break
        end
    end
    local type_lookup = {}
    if not check_all_types then
        for _, t in ipairs(opt.type) do
            type_lookup[t] = true
        end
    end

    local current_path = startpath

    while true do
        for _, filename in ipairs(opt.filelist) do
            local filepath = vim.fs.joinpath(current_path, filename)
            local stat = vim.loop.fs_stat(filepath)
            if stat then
                local valid_type = check_all_types or type_lookup[stat.type]
                if valid_type then
                    if opt.use_first_found then
                        if not results[filename] then
                            results[filename] = filepath
                        end
                    else
                        results[filename] = filepath
                    end
                end
            end
        end

        local parent_path = vim.fn.fnamemodify(current_path, ':h')
        if parent_path == current_path then
            break
        end
        current_path = parent_path
    end

    return results
end

-- print(vim.inspect(Findfile_any({ filelist={".git"}, startpath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h"), })))

