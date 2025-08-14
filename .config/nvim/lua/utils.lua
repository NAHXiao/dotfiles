local M = {}
local uv = vim.uv
M.map_func = {}
---@param mode string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
---@param lhs string|string[]           Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---@param opts? vim.keymap.set.Opts
function M.map(mode, lhs, rhs, opts)
    if mode == "*" then
        mode = { "i", "n", "s", "v", "t", "o" }
    end
    local options = vim.tbl_extend("force", { silent = true }, opts or {})
    if type(lhs) == "string" then
        lhs = { lhs }
    end
    for _, l in ipairs(lhs) do
        vim.keymap.set(mode, l, rhs, options)
    end
end

---@param keys {
---[1]:string|string[],
---[2]:string|(fun():string?)?,
---mode?:string|string[],
---desc?:string,
---noremap?:boolean,
---expr?:boolean,
---nowiat?:boolean,
---ft?:string|string[]}[]
function M.lazy_keymap(keys)
    local ret = {}
    for _, key in ipairs(keys) do
        if type(key[1]) == "string" then
            table.insert(ret, key)
        elseif type(key[1]) == "table" then
            for _, k in ipairs(key[1]) do
                table.insert(ret, vim.tbl_extend("force", key, { [1] = k }))
            end
        end
    end
    return ret
end

M.log = function(...)
    local args = { ... }
    local info = debug.getinfo(2, "nSl")
    local pretext = ("[%s]"):format(os.date("%Y-%m-%d %H:%M:%S", os.time()))
    if info then
        pretext = pretext .. (" %s:%d %s(): "):format(info.short_src, info.currentline, info.name)
    else
        pretext = pretext .. ": "
    end
    local lines = { pretext }
    local i = 1
    for k, arg in pairs(args) do
        if i ~= k then
            for j = i, k - 1 do
                lines[#lines + 1] = ("[%d]:"):format(j)
            end
        end
        lines[#lines + 1] = ("[%d]:%s"):format(k, vim.inspect(arg))
        i = k + 1
    end
    lines = vim.split(table.concat(lines, "\n"), "\r?\n")
    if #lines == 2 then
        lines[1] = lines[1] .. lines[2]
        lines[2] = nil
    end
    if -1 == vim.fn.writefile(lines, vim.fs.joinpath(uv.os_homedir(), "nvim_config.log"), "sa") then
        error("write log failed")
    end
end
---@param groupname string
---@param clear? boolean
function M.aug(groupname, clear)
    return vim.api.nvim_create_augroup(groupname, { clear = clear })
end

M.auc = vim.api.nvim_create_autocmd
function M.vim_echo(str, hlgroup)
    vim.cmd(string.format(
        [[
				echohl %s
				echo "%s"
				echohl None
        ]],
        hlgroup or "Number",
        str
    ))
end

---@param opt {
---line_limit?:number,
---size_limit?:number,
---avg_linesize_limit?:number}
function M.is_bigfile(bufnr, opt)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    opt = vim.tbl_extend("force", {
        line_limit = 5000,
        size_limit = 10 * 1024 * 1024,   -- 10MB
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

function M.encode_path(path)
    if not path then
        return ""
    end
    return path:gsub('[<>:"/\\|?*%s%c]', function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

function M.decode_path(encoded_path)
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
M.relpath = vim.fs.relpath
    or function(base, target)
        local function normalize_path(path)
            if not path then
                return nil
            end
            local expanded = vim.fn.expand(path)
            local absolute = vim.fn.fnamemodify(expanded, ":p")
            if absolute:match("/$") and #absolute > 1 then
                absolute = absolute:sub(1, -2)
            end
            return absolute
        end
        local function split_path(path)
            local parts = {}
            for part in path:gmatch("[^/]+") do
                table.insert(parts, part)
            end
            return parts
        end
        local norm_base = normalize_path(base)
        local norm_target = normalize_path(target)
        if not norm_base or not norm_target then
            return nil
        end
        local base_parts = split_path(norm_base)
        local target_parts = split_path(norm_target)
        for i = 1, #base_parts do
            if base_parts[i] ~= target_parts[i] then
                return nil
            end
        end
        if #target_parts <= #base_parts then
            return nil
        end
        local rel_parts = {}
        for i = #base_parts + 1, #target_parts do
            table.insert(rel_parts, target_parts[i])
        end
        return table.concat(rel_parts, "/")
    end

---valuetype_cond 将过滤key和value类型都是(number|string|boolean)的item
---table_cond将过滤key类型是(number|string|boolean),value类型是table的item
---nullkeys将含有这些键的item去除
---valuetype_cond, table_cond保证了这些键出现时必须满足条件或与给定值相等
---nullkeys保证了这些键不能出现
---@generic T
---@param list T[]
---@param valuetype_cond table<(number|string|boolean),(number|string|boolean)|(number|string|boolean)[]|fun(value:(number|string|boolean),item:table):boolean>|nil
---@param table_cond table<(number|string|boolean),fun(value:table,item:table):boolean>|nil
---@param nullkeys (number|string|boolean)[]|nil
---@return T[]
function M.list_filter(list, valuetype_cond, table_cond, nullkeys)
    local filtered = {}
    for _, item in ipairs(list) do
        if valuetype_cond then
            for k, v in pairs(valuetype_cond) do
                if item[k] then
                    if type(v) == "table" then
                        local bypass = false
                        for _, bypassv in ipairs(v) do
                            if bypassv == item[k] then
                                bypass = true
                                break
                            end
                        end
                        if not bypass then
                            goto next
                        end
                    elseif type(v) == "function" then
                        if not v(item[k], item) then
                            goto next
                        end
                    else
                        if v ~= item[k] then
                            goto next
                        end
                    end
                end
            end
        end
        if table_cond then
            for k, f in pairs(table_cond) do
                local x = f(item[k], item)
                if true ~= x then
                    goto next
                end
            end
        end
        if nullkeys then
            for _, k in ipairs(nullkeys) do
                if item[k] then
                    goto next
                end
            end
        end
        table.insert(filtered, item)
        ::next::
    end
    return filtered
end

---原地修改
function M.list_compact(list)
    local p = 1
    for q, it in pairs(list) do
        if type(q) == "number" then
            list[q] = nil
            if it ~= nil then
                list[p] = it
                p = p + 1
            end
        end
    end
    return list
end

-- 总是tbl.key=wrap(assign_value)
-- NOTEST:tbl with metatable
---@generic T value_type
---@param wrap fun(T):T
function M.watch_assign_key(tbl, key, wrap)
    local mt = getmetatable(tbl) or {}
    local watchers = mt.____watchers or {}
    local orig_newindex = mt.__newindex
    local orig_index = mt.__index
    local data = mt.____data or {}
    if not mt.____data then
        for k, v in pairs(tbl) do
            data[k] = v
            tbl[k] = nil
        end
    end
    watchers[key] = watchers[key] or {}
    table.insert(watchers[key], wrap)
    mt.__index = function(t, k)
        if data[k] ~= nil then
            return data[k]
        elseif orig_index then
            if type(orig_index) == "function" then
                return orig_index(t, k)
            else
                return orig_index[k]
            end
        end
    end
    mt.__newindex = function(t, k, v)
        if watchers[k] then
            for _, watcher in ipairs(watchers[k]) do
                v = watcher(v)
            end
            data[k] = v
        else
            if orig_newindex then
                if type(orig_newindex) == "function" then
                    orig_newindex(t, k, v)
                else
                    orig_newindex[k] = v
                end
            else
                data[k] = v
            end
        end
    end
    mt.____watchers = watchers
    mt.____data = data
    setmetatable(tbl, mt)
end

function M.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function M.prefix_replace(str, prefix, replacement)
    if str:sub(1, #prefix) == prefix then
        return replacement .. str:sub(#prefix + 1)
    end
    return str
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

function M.index_of(tbl, obj)
    for i, o in ipairs(tbl) do
        if o == obj then
            return i
        end
    end
end

---@class utils.FindRoot.Opt
---@field startpath string?         # default cwd()
---@field use_first_found boolean? # default true
---@field exclude_dirs string[]?    # default { homedir }
---@field return_matchpath boolean?# default false
---@param names string[]
---@param opt utils.FindRoot.Opt?
---@return string|nil
function M.FindRoot(names, opt)
    opt = opt or {}
    local opts = {
        startpath = opt.startpath or uv.cwd(),
        use_first_found = opt.use_first_found ~= nil and opt.use_first_found or false,
        exclude_dirs = opt.exclude_dirs or { uv.os_homedir() },
        return_matchpath = opt.return_matchpath ~= nil and opt.return_matchpath or false,
    }
    local results = vim.fs.find(names, {
        path = opts.startpah,
        limit = opts.use_first_found and 1 or math.huge,
        -- follow = false, --似乎对upward没用?
        upward = true,
    })
    local result
    for _, path in ipairs(results) do
        if not vim.list_contains(opts.exclude_dirs, vim.fs.dirname(path)) then
            result = path
        end
    end
    if result and not opts.return_matchpath then
        result = vim.fs.dirname(result)
    end
    return result
end

---- bufnr:filebuf
---bufferProjRoot
---fallback:
---belong to globalProjRoot => globalProjRoot
---otherwise => nil
---- bufnr:other/nil
---globalProjRoot
---@param bufnr? number
---@return string|nil
function M.get_rootdir(bufnr)
    if bufnr and vim.bo[bufnr].buftype == "" then
        local root_dir = vim.b[bufnr].projroot
        if not root_dir and M.file_parents_has(vim.api.nvim_buf_get_name(bufnr), vim.g.projroot) then
            root_dir = vim.g.projroot
        end
        return root_dir
    else
        return vim.g.projroot
    end
end

function M.file_parents_has(file, parent)
    for dir in vim.fs.parents(file) do
        if dir == vim.fs.normalize(parent) then
            return true
        end
    end
    return false
end

---@alias bufnr integer
---@alias winid integer
---@param filepath string
---@param new_content? string|string[]
---@param split? fun(bufnr?:number,filepath?:string):bufnr,winid
---@return integer bufnr
---@return integer winid
---@return boolean already_focused
---@return boolean newfile
function M.focus_or_new(filepath, new_content, split)
    vim.validate("filepath", filepath, "string")
    filepath = vim.fs.normalize(filepath)
    if type(new_content) == "table" then
        new_content = table.concat(new_content, "\r\n")
    elseif type(new_content) == "nil" then
        new_content = ""
    end
    ---@diagnostic disable-next-line: redefined-local
    split = split or function(bufnr, filepath)
        vim.validate("focus_or_new: split args", { bufnr = bufnr, filepath = filepath }, function(it)
            return (type(it.bufnr) == "number" and vim.api.nvim_buf_is_valid(it.bufnr)) or
                (type(it.filepath) == "string" and it.filepath ~= "")
        end)
        if bufnr then
            vim.cmd("botright vsplit #" .. bufnr)
        else
            vim.cmd("botright vsplit " .. filepath)
        end
        return vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
    end
    local lines = vim.split(new_content, "\r?\n") or { "" }
    local bufnr = vim.fn.bufnr(filepath)
    local buf_exists = bufnr and bufnr ~= -1
    local winid = buf_exists and vim.fn.bufwinid(bufnr) or nil
    local win_exists = winid and winid ~= -1
    local is_focused = buf_exists and vim.api.nvim_get_current_buf() == bufnr
    local file_exists = vim.fn.filereadable(filepath) == 1
    if file_exists or buf_exists then
        if buf_exists then
            if win_exists then
                ---@cast winid integer
                if is_focused then
                    return bufnr, winid, true, false
                else
                    vim.api.nvim_set_current_win(winid)
                    return bufnr, winid, false, false
                end
            else
                _, winid = split(bufnr, nil)
                return bufnr, winid, false, false
            end
        else
            bufnr, winid = split(nil, filepath)
            return bufnr, winid, false, false
        end
    else
        bufnr, winid = split(nil, filepath)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        return bufnr, winid, false, true
    end
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
