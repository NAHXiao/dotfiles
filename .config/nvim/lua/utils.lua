local M = {}
local uv = vim.loop or vim.uv
M.log = function(log)
    if log == nil then
        return
    end
    local file = io.open(
        (os.getenv("HOME") or os.getenv("USERPROFILE"):gsub([[\]], [[\\]])) .. "/nvim.log",
        "a"
    )
    if file ~= nil then
        file:write(os.date("%Y-%m-%d %H:%M:%S", os.time()) .. " " .. tostring(log) .. "\n")
        file:close()
    else
        vim.notify(
            "DebugToFile:" .. "Failed to open log file (" .. file .. "),\nlog:[" .. log .. "]",
            vim.log.levels.ERROR
        )
    end
end
function M.decode_path(path)
    if not path then
        return ""
    end
    return path:gsub('[<>:"/\\|?*%s%c]', function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

function M.encode_path(encoded_path)
    if not encoded_path then
        return ""
    end
    return encoded_path:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

function M.findfile_any(opt)
    local default_opt = {
        filelist = {},
        startpath = uv.cwd(),
        use_first_found = false,
        type = { "file", "directory" },
        exclude_dirs = { uv.os_homedir() },
        return_dirname = false,
    }
    opt = vim.tbl_deep_extend("force", default_opt, opt or {})
    local startpath = vim.fs.normalize(opt.startpath)
    for i, exdirs in ipairs(opt.exclude_dirs) do
        opt.exclude_dirs[i] = vim.fs.normalize(exdirs)
    end
    startpath = vim.fn.fnamemodify(startpath, ":p")
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
        if (#opt.exclude_dirs == 0) or (not vim.list_contains(opt.exclude_dirs, current_path)) then
            for _, filename in ipairs(opt.filelist) do
                local filepath = vim.fs.joinpath(current_path, filename)
                local stat = uv.fs_stat(filepath)
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
        end
        local parent_path = vim.fs.normalize(vim.fn.fnamemodify(current_path, ":h"))
        if parent_path == current_path then
            break
        end
        current_path = parent_path
    end
    return result
end

function M.findfile_all(opt)
    local default_opt = {
        filelist = {},
        startpath = uv.cwd(),
        exclude_dirs = { uv.os_homedir() },
        use_first_found = false,
        type = { "file", "directory" },
    }
    opt = vim.tbl_deep_extend("force", default_opt, opt or {})
    local startpath = vim.fs.normalize(opt.startpath)
    startpath = vim.fn.fnamemodify(startpath, ":p")
    for i, exdirs in ipairs(opt.exclude_dirs) do
        opt.exclude_dirs[i] = vim.fs.normalize(exdirs)
    end
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
        if (#opt.exclude_dirs == 0) or (not vim.list_contains(opt.exclude_dirs, current_path)) then
            for _, filename in ipairs(opt.filelist) do
                local filepath = vim.fs.joinpath(current_path, filename)
                local stat = uv.fs_stat(filepath)
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
        end

        local parent_path = vim.fs.normalize(vim.fn.fnamemodify(current_path, ":h"))
        if parent_path == current_path then
            break
        end
        current_path = parent_path
    end

    return results
end
function M.is_vim_empty_dict(var)
    return type(var) == "table" and (getmetatable(var) == getmetatable(vim.empty_dict()))
end
function M.transparent_bg_test()
    local groups = vim.fn.getcompletion("", "highlight")
    local index = 1

    local function process_next()
        if index > #groups then
            return
        end

        local group = groups[index]
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })

        if hl.bg and hl.bg ~= 0 then
            local original_bg = hl.bg
            vim.api.nvim_set_hl(0, group, { bg = "none" })
            vim.notify(group)
            M.log(group)
            vim.defer_fn(function()
                vim.api.nvim_set_hl(0, group, { bg = original_bg })
                index = index + 1
                process_next()
            end, 1000)
        else
            index = index + 1
            process_next()
        end
    end

    process_next()
end
return M
