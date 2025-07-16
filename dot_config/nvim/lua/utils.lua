local M = {}
local uv = vim.loop or vim.uv
function M.map(mode, lhs, rhs, opts)
    local options = { silent = true, noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end
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
function M.is_bigfile(bufnr, opt)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    opt = vim.tbl_extend("force", {
        line_limit = 5000,
        size_limit = 10 * 1024 * 1024, -- 10MB
        avg_linesize_limit = 100 * 1024, -- 平均每行 100 KB
    }, opt or {})

    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count > opt.line_limit then
        return true
    end

    local filepath = vim.api.nvim_buf_get_name(bufnr)
    if filepath == "" then
        return false
    end

    local stat = uv.fs_stat(filepath)
    if stat then
        if stat.size > opt.size_limit then
            return true
        end
        -- 计算平均行大小，防止极端文件短行但超大
        local avg = stat.size / math.max(line_count, 1)
        if avg > opt.avg_linesize_limit then
            return true
        end
    end

    return false
end
-- 当tbl.trigger_key = trigger_value时，执行trigger_func
function M.wrapmetaable_newindex(tbl, trigger_key, trigger_value, trigger_func)
    local mt = getmetatable(tbl) or {}
    local old_newindex = mt.__newindex
    mt.__newindex = function(t, key, value)
        if old_newindex then
            old_newindex(t, key, value)
        else
            rawset(t, key, value)
        end
        if key == trigger_key and value == trigger_value then
            trigger_func()
        end
    end
    setmetatable(tbl, mt)
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
local function shorten_path(path, maxlen)
    if not path or path == "" then
        return ""
    end
    local normalized_path = path:gsub("\\", "/")
    if #normalized_path <= maxlen then
        return normalized_path
    end
    local is_absolute = normalized_path:sub(1, 1) == "/"
    local segments = {}
    for segment in normalized_path:gmatch("[^/]+") do
        table.insert(segments, segment)
    end
    if #segments == 0 then
        return "/"
    end
    local basename = segments[#segments]
    local dirname_segments = {}
    for i = 1, #segments - 1 do
        table.insert(dirname_segments, segments[i])
    end
    if #basename > maxlen then
        local truncated_len = maxlen - 3
        if truncated_len <= 0 then
            return "..."
        end
        return "..." .. basename:sub(-truncated_len)
    end
    if maxlen - #basename == 8 then
        if #dirname_segments > 0 then
            local first_seg = dirname_segments[1]
            if is_absolute then
                local prefix_len = math.min(2, #first_seg)
                return "/" .. first_seg:sub(1, prefix_len) .. "/.../" .. basename
            else
                local prefix_len = math.min(3, #first_seg)
                return first_seg:sub(1, prefix_len) .. "/.../" .. basename
            end
        else
            return is_absolute and ("/" .. basename) or basename
        end
    elseif maxlen - #basename < 8 then
        return basename
    end
    local function build_path(dir_segments, base)
        local result = ""
        if is_absolute then
            result = "/"
        end
        if #dir_segments > 0 then
            result = result .. table.concat(dir_segments, "/")
            if base and base ~= "" then
                result = result .. "/" .. base
            end
        else
            if base and base ~= "" then
                result = result .. base
            end
        end
        return result
    end
    if #dirname_segments == 0 then
        return build_path({}, basename)
    end
    local function compress_segments(segs)
        if #segs == 0 then
            return segs
        end
        local compressed = {}
        for i, seg in ipairs(segs) do
            compressed[i] = seg
        end
        local current_path = build_path(compressed, basename)
        if #current_path <= maxlen then
            return compressed
        end
        local length_groups = {}
        for i, seg in ipairs(compressed) do
            local len = #seg
            if not length_groups[len] then
                length_groups[len] = {}
            end
            table.insert(length_groups[len], { index = i, segment = seg })
        end
        local lengths = {}
        for len, _ in pairs(length_groups) do
            table.insert(lengths, len)
        end
        table.sort(lengths, function(a, b)
            return a > b
        end)
        for len_idx, current_len in ipairs(lengths) do
            local group = length_groups[current_len]
            if #group > 0 then
                local next_len = len_idx < #lengths and lengths[len_idx + 1] or 1
                local test_path = build_path(compressed, basename)
                local excess = #test_path - maxlen
                if excess > 0 then
                    local total_reduction_needed = excess
                    local reduction_per_segment = math.ceil(total_reduction_needed / #group)
                    for _, item in ipairs(group) do
                        local target_len = math.max(next_len, current_len - reduction_per_segment)
                        local min_len = item.segment:sub(1, 1) == "." and 2 or 1
                        target_len = math.max(target_len, min_len)
                        if target_len < #item.segment then
                            compressed[item.index] = item.segment:sub(1, target_len)
                        end
                    end
                    local new_path = build_path(compressed, basename)
                    if #new_path <= maxlen then
                        return compressed
                    end
                end
            end
        end
        for i, seg in ipairs(compressed) do
            local min_len = seg:sub(1, 1) == "." and 2 or 1
            if #seg > min_len then
                compressed[i] = seg:sub(1, min_len)
            end
        end
        return compressed
    end
    local compressed_segments = compress_segments(dirname_segments)
    local compressed_path = build_path(compressed_segments, basename)
    if #compressed_path <= maxlen then
        return compressed_path
    end
    local function remove_segments(segs)
        if #segs <= 1 then
            return segs
        end
        for remove_start = 2, #segs - 1 do
            local new_segs = {}
            table.insert(new_segs, segs[1])
            table.insert(new_segs, "...")
            if #segs > remove_start then
                table.insert(new_segs, segs[#segs])
            end
            local test_path = build_path(new_segs, basename)
            if #test_path <= maxlen then
                return new_segs
            end
        end
        return { segs[1], "..." }
    end
    if #compressed_segments > 1 then
        local final_segments = remove_segments(compressed_segments)
        local final_path = build_path(final_segments, basename)
        if #final_path <= maxlen then
            return final_path
        end
    end
    local min_path = is_absolute and "/" or ""
    if #compressed_segments > 0 then
        local first_seg = compressed_segments[1]
        local min_len = first_seg:sub(1, 1) == "." and 2 or 1
        min_path = min_path .. first_seg:sub(1, min_len) .. "/.../" .. basename
    else
        min_path = min_path .. basename
    end
    if #min_path <= maxlen then
        return min_path
    end
    assert(false, "unreachable code")
end
local shorten_path_cache = {}
M.shorten_path = function(path, maxlen)
    if shorten_path_cache[path] and shorten_path_cache[path][tostring(maxlen)] then
        return shorten_path_cache[path][tostring(maxlen)]
    end
    local ret = shorten_path(path, maxlen)
    if shorten_path_cache[path] == nil then
        shorten_path_cache[path] = {}
    end
    shorten_path_cache[path][tostring(maxlen)] = ret
    return ret
end

function M.trim(s)
    return s:match("^%s*(.-)%s*$")
end
function M.range(...)
    local args = { ... }
    local start, end_, step
    if #args == 1 then
        start, end_, step = 1, args[1], 1
    elseif #args == 2 then
        start, end_, step = args[1], args[2], 1
    elseif #args == 3 then
        start, end_, step = args[1], args[2], args[3]
    else
        error("range() takes 1-3 arguments")
    end
    local result = {}
    local idx = 1
    if step > 0 then
        for i = start, end_ - 1, step do
            result[idx] = i
            idx = idx + 1
        end
    else
        for i = start, end_ + 1, step do
            result[idx] = i
            idx = idx + 1
        end
    end
    return result
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
-------------------------------------------

return M
