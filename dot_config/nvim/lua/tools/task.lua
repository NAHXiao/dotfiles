local M = {}
---@alias tasks task[]

---@class task
---@field name string
---@field cmd string[]
---@field type tasktype
---@field filetypes string[]|nil nil=>{}
---@field mode taskmode|nil  nil=>"debug"
---@field opts jobopts|nil nil=>{detach=false,cwd="$(VIM_ROOT)",clear_env=false}

---@class jobopts|nil
---@field on_exit fun(job: integer, code: number, event: string,term_buf:integer)|nil
---@field on_stdout fun(job: integer, data: string[], event: string,term_buf:integer)|nil
---@field on_stderr fun(job: integer, data: string[], event: string,term_buf:integer)|nil
---@field cwd string|nil
---@field detach boolean|nil
---@field clear_env boolean|nil
---@field env table<string, string>|nil

---@alias tasktype ("file"|"project")
---@alias taskmode ("debug"|"release")

--M.run时这些filetypes不构成过滤
M.ignore_filetypes = {
    "",
    "qf",
    "neo-tree",
    "alpha",
    "toggleterm",
    "TerminalPanel",
    "trouble",
    "markdown",
    "dapui_scopes",
    "snacks_terminal",
    "lazy",
    "mason",
    "TelescopePrompt",
    "dropbar_menu",
}

M.localtask_path = function()
    return vim.fs.abspath(vim.fs.joinpath(vim.g.projroot or vim.fn.getcwd(), ".tasks.lua"))
end

M.default_task_template = {
    filetypes = {},
    mode = "debug",
    opts = {
        detach = false,
        cwd = "$(VIM_ROOT)",
        clear_env = false,
    },
}
M.run_wrapper = "cmd_wrapper"
--只存储file task和所有文件通用task
---@type tasks
local globaltasks = {
    --general
    {
        name = "run",
        cmd = { "$(VIM_FILEPATH)" },
        filetypes = {},
        type = "file",
    },
    --project-create
    {
        name = "mvn-create",
        cmd = {
            "mvn",
            "archetype:generate",
            "-DgroupId=$(-group:com.example)",
            "-DartifactId=$(-artifactname:hello-world)",
            "-DarchetypeArtifactId=maven-archetype-quickstart",
            "-DinteractiveMode=false",
        },
        filetypes = {},
        type = "project",
    },
    {
        name = "cargo-create",
        cmd = { "cargo", "new", "$(-name)", "--bin" },
        filetypes = {},
        type = "project",
    },
    {
        name = "cmake-create",
        cmd = { "cmake_create", "$(-name:)" },
        filetypes = {},
        type = "project",
    },
    --c/cpp
    {
        name = "build",
        cmd = {
            "gcc",
            "-O3",
            "--std=c23",
            "$(VIM_FILEPATH)",
            "-o",
            "$(VIM_FILEDIR)/$(VIM_FILENOEXT)",
        },
        filetypes = { "c" },
        type = "file",
        mode = "release",
    },
    {
        name = "build",
        cmd = {
            "gcc",
            "-O3",
            "--std=c23",
            "$(VIM_FILEPATH)",
            "-o",
            "$(VIM_FILEDIR)/$(VIM_FILENOEXT)",
            "--debug",
        },
        filetypes = { "c" },
        type = "file",
        mode = "debug",
    },
    {
        name = "build",
        cmd = {
            "g++",
            "-O3",
            "--std=c++23",
            "$(VIM_FILEPATH)",
            "-o",
            "$(VIM_FILEDIR)/$(VIM_FILENOEXT)",
        },
        filetypes = { "cpp" },
        type = "file",
        mode = "release",
    },
    {
        name = "build",
        cmd = {
            "g++",
            "-O3",
            "--std=c++23",
            "$(VIM_FILEPATH)",
            "-o",
            "$(VIM_FILEDIR)/$(VIM_FILENOEXT)",
            "--debug",
        },
        filetypes = { "cpp" },
        type = "file",
        mode = "debug",
    },
    {
        name = "run",
        cmd = {
            "$(VIM_PATHNOEXT)" .. (vim.g.is_win and ".exe" or ""),
        },
        filetypes = { "c", "cpp" },
        type = "file",
    },
    --java
    {
        name = "build",
        cmd = {
            "javac",
            "-d",
            "$(VIM_ROOT)/.build",
            "$(VIM_FILEPATH)",
        },
        filetypes = { "java" },
        type = "file",
    },
    {
        name = "run",
        cmd = {
            "java",
            "-cp",
            "$(VIM_ROOT)/.build",
            "$(VIM_FILENOEXT)",
        },
        filetypes = { "java" },
        type = "file",
    },
    --scripts
    {
        name = "run",
        cmd = {
            "lua",
            "$(VIM_FILEPATH)",
        },
        filetypes = { "lua" },
        type = "file",
    },
    {
        name = "run",
        cmd = {
            "python",
            "$(VIM_FILEPATH)",
        },
        filetypes = { "python" },
        type = "file",
    },
    {
        name = "run",
        cmd = {
            "node",
            "$(VIM_FILEPATH)",
        },
        filetypes = { "javascript" },
        type = "file",
    },
    {
        name = "run",
        cmd = {
            "powershell",
            "-file",
            "$(VIM_FILEPATH)",
        },
        filetypes = { "ps1" },
        type = "file",
    },
}
local template = {
    shell = {
        {
            name = "build",
            cmd = { "echo", "$(VIM_FILEPATH)" },
            type = "file",
            mode = "debug",
            filetypes = {},
        },
        {
            name = "run",
            cmd = { "echo", "$(VIM_FILEPATH)" },
            type = "file",
            mode = "debug",
            filetypes = {},
        },
        {
            name = "run",
            cmd = { "echo", "$(VIM_FILEPATH)" },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
    },
    cmake = {
        {
            name = "project-refresh-config",
            cmd = { "cmake", "--fresh", "-B", "build", "-S", "." },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
        {
            name = "build",
            cmd = { "cmake", "--build", "build" },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
        {
            name = "run",
            cmd = { "build/$(VIM_PRONAME)" },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
    },
    cargo = {
        {
            name = "build",
            cmd = { "cargo", "build" },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
        {
            name = "run",
            cmd = { "cargo", "run" },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
        {
            name = "project-test",
            cmd = { "cargo", "test" },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
    },
    mvn = {
        {
            name = "build",
            cmd = { "mvn", "compile" },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
        {
            name = "project-test",
            cmd = { "mvn", "test" },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
        {
            name = "run",
            cmd = { "mvn", "exec:java", "-Dexec.mainClass=$(-mainClass:)" },
            type = "project",
            mode = "debug",
            filetypes = {},
        },
    },
}
local localtasks = nil
M.globaltasks = function()
    local ret = {}
    for _, task in ipairs(globaltasks) do
        table.insert(ret, vim.tbl_deep_extend("force", M.default_task_template, task))
    end
    return ret
end
M.localtasks = function()
    if localtasks == nil then
        return {}
    end
    local ret = {}
    for _, task in ipairs(localtasks) do
        table.insert(ret, vim.tbl_deep_extend("force", M.default_task_template, task))
    end
    return ret
end
M.template_tasks = function()
    local ret = {}
    for field, tasks in pairs(template) do
        ret[field] = {}
        for _, task in ipairs(tasks) do
            table.insert(ret[field], vim.tbl_deep_extend("force", M.default_task_template, task))
        end
    end
    return ret
end

----------------------------------------------------------------------

---@return tasks
M.parsefile = function(filepath)
    local ok, result = pcall(dofile, filepath)
    if not ok then
        return {}
    end
    return result or {}
end

---@param tasks tasks
---@param name string|nil
---@param filetype string|string[]|nil string=> =/{} string[]=> =
---@param tasktype tasktype|nil
---@param mode taskmode|nil
---@return tasks
M.filter = function(tasks, name, filetype, tasktype, mode)
    local newtasks = {}
    for _, task in ipairs(tasks) do
        (function()
            if name ~= nil and task.name ~= name then
                return
            end
            if
                filetype ~= nil
                and type(filetype) == "string"
                and (next(task.filetypes) ~= nil or not getmetatable(task.filetypes) == getmetatable(
                    vim.empty_dict()
                ))
                and (not vim.list_contains(task.filetypes, filetype))
            then
                return
            end
            if
                filetype ~= nil
                and type(filetype) == "table"
                and not vim.deep_equal(filetype, task.filetypes)
            then
                return
            end
            if tasktype ~= nil and task.type ~= tasktype then
                return
            end
            if mode ~= nil and task.mode ~= mode then
                return
            end
            table.insert(newtasks, vim.deepcopy(task))
        end)()
    end
    return newtasks
end

---@param globaltaskss tasks|nil
---@param localtaskss tasks|nil
---@return  { global: boolean, index: number }[]
M.findmax = function(globaltaskss, localtaskss)
    globaltaskss = globaltaskss or {}
    localtaskss = localtaskss or {}
    if next(globaltaskss) == nil and next(localtaskss) == nil then
        return {}
    end

    local keylist = {}
    for i = 1, #globaltaskss do
        table.insert(keylist, { global = true, index = i })
    end
    for i = 1, #localtaskss do
        table.insert(keylist, { global = false, index = i })
    end
    if #keylist == 1 then
        return { keylist[1] }
    end

    local function get(key)
        if key.global == true then
            return globaltaskss[key.index]
        else
            return localtaskss[key.index]
        end
    end
    local eq = function(a, b)
        local x, y = get(a), get(b)
        local xmode = x.mode or "debug"
        local ymode = y.mode or "debug"
        return x.type == y.type
            and a.global == b.global
            and xmode == ymode
            and vim.deep_equal(x.filetypes, y.filetypes)
    end
    local gt = function(a, b)
        local x, y = get(a), get(b)
        if x.type ~= y.type then
            return x.type == "project"
        end
        if a.global ~= b.global then
            return a.global == false
        end
        if x.mode ~= y.mode then
            local xmode = x.mode or "debug"
            local ymode = y.mode or "debug"
            if xmode ~= ymode then
                return xmode == "debug"
            end
        end
        if not vim.deep_equal(x.filetypes, y.filetypes) then
            return (next(y.filetypes) == nil)
        end
        return false
    end
    table.sort(keylist, gt)

    local last = 1
    for i = 2, #keylist do
        if eq(keylist[i], keylist[i - 1]) then
            last = i
        else
            break
        end
    end
    return { unpack(keylist, 1, last) }
end

---@param rows taskattr[]
local function compute_width(rows)
    local w = { 8, 8, 8, 8, 8 }
    for _, row in ipairs(rows) do
        w[1] = math.max(w[1], #row.field)
        w[2] = math.max(w[2], #row.name)
        w[3] = math.max(w[3], #row.mode)
        w[4] = math.max(w[4], #row.type)
        local ft = table.concat(row.filetypes, ",")
        if ft == "" then
            ft = "*"
        end
        w[5] = math.max(w[5], #ft)
    end
    return w
end
local function draw_encode(field, task, mode, type_, filetypes, w)
    local ft = (#filetypes == 0) and "*" or table.concat(filetypes, ",")
    local row = { field, task, mode, type_, ft }
    for i = 1, 5 do
        row[i] = row[i] .. string.rep(" ", w[i] - #row[i])
    end
    return table.concat(row, " | ")
end
--内存储微缩tasks和其参数
local argv_cache = {}
---@param task task
---@return task|nil
---for cmd,cwd,env.value
---modify task itself
M.macro_replace = function(task)
    ---@param task1 task
    ---@param task2 task
    ---@return boolean
    local eq = function(task1, task2)
        return task1.name == task2.name
            and task1.type == task2.type
            and task1.mode == task2.mode
            and vim.deep_equal(task1.cmd, task2.cmd)
    end
    local map = {
        ["$(VIM_FILENAME)"] = function()
            return vim.fn.expand("%:t")
        end,
        ["$(VIM_FILENOEXT)"] = function()
            return vim.fn.expand("%:t:r")
        end,
        ["$(VIM_FILEEXT)"] = function()
            return vim.fn.expand("%:e")
        end,
        ["$(VIM_FILEPATH)"] = function()
            return vim.fn.expand("%:p")
        end,
        ["$(VIM_PATHNOEXT)"] = function()
            return vim.fn.expand("%:p:r")
        end,
        ["$(VIM_RELPATH)"] = function()
            return vim.fn.expand("%:p:.")
        end,
        ["$(VIM_FILEDIR)"] = function()
            return vim.fn.expand("%:p:h")
        end,
        ["$(VIM_DIRNAME)"] = function()
            return vim.fn.fnamemodify(vim.fn.expand("%:p:h"), ":t")
        end,
        ["$(VIM_ROOT)"] = function()
            return vim.g.projroot
        end,
        ["$(VIM_PRONAME)"] = function()
            return vim.fs.basename(vim.g.projroot)
        end,
    }
    local function replace_in_string(str)
        if type(str) ~= "string" then
            return str
        end
        for macro, func in pairs(map) do
            str = str:gsub(vim.pesc(macro), func())
        end
        str = str:gsub("%$%(%-([^:%)]+):?([^%)]*)%)", function(argname, default)
            local cache_key = "$(-" .. argname .. ":" .. default .. ")"
            local cached_value = nil
            for _, cache in ipairs(argv_cache) do
                if eq(cache.task, task) and cache.argvmap[cache_key] then
                    cached_value = cache.argvmap[cache_key]
                    break
                end
            end
            local input_value = nil
            vim.ui.input({
                prompt = "Enter value for " .. argname .. ": ",
                default = cached_value or default,
            }, function(value)
                input_value = value or default
            end)
            if input_value == nil or input_value == "" then
                error("please input value for " .. argname)
            end
            local found_cache = false
            for _, cache in ipairs(argv_cache) do
                if eq(cache.task, task) then
                    cache.argvmap[cache_key] = input_value
                    found_cache = true
                    break
                end
            end
            if not found_cache then
                table.insert(argv_cache, {
                    task = vim.deepcopy(task),
                    argvmap = { [cache_key] = input_value },
                })
            end

            return input_value
        end)
        return str
    end
    for i, cmd in ipairs(task.cmd) do
        local ok, result = pcall(replace_in_string, cmd)
        if ok then
            task.cmd[i] = result
        else
            vim.notify("[task]: " .. result, vim.log.levels.ERROR)
            return nil
        end
    end
    if task.opts and task.opts.cwd then
        local ok, result = pcall(replace_in_string, task.opts.cwd)
        if ok then
            task.opts.cwd = result
        else
            vim.notify("[task]: " .. result, vim.log.levels.ERROR)
            return nil
        end
    end
    if task.opts and task.opts.env then
        for k, v in pairs(task.opts.env) do
            local ok, result = pcall(replace_in_string, v)
            if ok then
                task.opts.env[k] = result
            else
                vim.notify("[task]: " .. result, vim.log.levels.ERROR)
                return nil
            end
        end
    end
    return task
end

local run_wrap = function(cmd, name, opts)
    if M.run_wrapper then
        cmd = { M.run_wrapper, unpack(cmd) }
    end
    require("tools.terminal").new(cmd, false, name, true, opts)
end

---@param taskname string 完全匹配
---@param type tasktype|nil nil=project>file
---@param mode taskmode|nil nil=debug>release
---@param opts jobopts|nil
M.run = function(taskname, type, mode, opts)
    --匹配task

    ---@type string|nil
    local ft = vim.bo.filetype or nil

    if vim.list_contains(M.ignore_filetypes, vim.bo.filetype) then
        ft = nil
    end
    if
        vim.api.nvim_get_option_value("buftype", { buf = 0 }) == ""
        and vim.fs.abspath(vim.api.nvim_buf_get_name(0)) == M.localtask_path()
    then
        ft = nil
    end

    M.refresh_local()
    local all_tasks = M.listtasks()
    local filtered_tasks = {
        globaltasks = M.filter(all_tasks.globaltasks, taskname, ft, type, mode),
        localtasks = M.filter(all_tasks.localtasks, taskname, ft, type, mode),
    }

    local found_tasks_index = M.findmax(filtered_tasks.globaltasks, filtered_tasks.localtasks)
    local found_tasks = {}
    for _, idx in ipairs(found_tasks_index) do
        table.insert(
            found_tasks,
            filtered_tasks[idx.global == true and "globaltasks" or "localtasks"][idx.index]
        )
    end
    local exec = function(task)
        task.opts = vim.tbl_deep_extend("force", task.opts or {}, opts or {})
        task = M.macro_replace(task)
        if task == nil then
            return
        end
        run_wrap(task.cmd, task.name, task.opts)
        vim.notify(string.format("[task]: %s cmd:%s", taskname, vim.inspect(task.cmd)))
    end
    if #found_tasks == 0 then
        vim.notify("[task]: Task not found: " .. taskname, vim.log.levels.ERROR)
        return
    elseif #found_tasks == 1 then
        exec(found_tasks[1])
    elseif #found_tasks > 1 then
        vim.ui.select(found_tasks, {
            prompt = "Select task:",
            format_item = function(item)
                return table.concat(item.cmd, " ")
            end,
        }, function(choice)
            if choice == nil then
                return
            end
            exec(choice)
        end)
    end
end

--刷新M.localtasks
M.refresh_local = function()
    local filepath = M.localtask_path()
    if vim.fn.filereadable(filepath) == 1 then
        localtasks = M.parsefile(filepath)
    else
        localtasks = nil
    end
end

---@return {globaltasks:tasks[],localtasks:tasks[]}
---return a new table
M.listtasks = function()
    M.refresh_local()
    return {
        globaltasks = M.globaltasks(),
        localtasks = M.localtasks(),
    }
end

M.template_config = [[
---@alias tasks task[]

---@class task
---@field name string
---@field cmd string[]
---@field type tasktype
---@field filetypes string[]|nil nil=>{}
---@field mode taskmode|nil  nil=>"debug"
---@field opts jobopts|nil nil=>{detach=false,cwd="$(VIM_ROOT)",clear_env=false}

---@class jobopts|nil
---@field on_exit fun(job: job, code: number, event: string)|nil
---@field on_stdout fun(job: job, data: string[], event: string)|nil
---@field on_stderr fun(job: job, data: string[], event: string)|nil
---@field cwd string|nil
---@field detach boolean|nil
---@field clear_env boolean|nil
---@field env table<string, string>|nil

---@alias tasktype ("file"|"project")
---@alias taskmode ("debug"|"release")

--$(VIM_FILENAME)  - 文件名
--$(VIM_FILENOEXT) - 文件去扩展名
--$(VIM_FILEEXT)   - 文件扩展名

--$(VIM_FILEPATH)  - 文件路径
--$(VIM_PATHNOEXT) - 去扩展的文件路径
--$(VIM_RELPATH)   - 相对文件路径
--$(VIM_FILEDIR)   - 文件所在目录路径
--$(VIM_DIRNAME)   - 文件所在目录名

--$(VIM_ROOT)  - 项目路径
--$(VIM_PRONAME)   - 项目名

--$(-argvname)
--$(-argvname:) 记住上次输入
--$(-argvname:default) 以default为默认值

---@type task[]
local tasks = {}
---@param task task
local function new(task)
    table.insert(tasks,task)
end
return tasks
]]

---@return string
M.template_appendtask = function(str, task)
    local return_pos = str:find("return tasks")
    if not return_pos then
        vim.notify("[task]: 'return tasks' not found", vim.log.levels.ERROR)
        return str
    end
    local line_start = str:sub(1, return_pos):find("\n[^\n]*$")
    if not line_start then
        line_start = 1
    else
        line_start = line_start + 1
    end
    local clean_task = vim.deepcopy(task)
    if clean_task.opts then
        clean_task.opts.on_exit = nil
        clean_task.opts.on_stdout = nil
        clean_task.opts.on_stderr = nil
    end
    local insert_code = string.format("new(%s)\n", vim.inspect(clean_task))
    return str:sub(1, line_start - 1) .. insert_code .. str:sub(line_start)
end

M.edit_task = function()
    local all_tasks = vim.tbl_extend("error", { global = M.globaltasks() }, M.template_tasks())
    local function is_empty_buffer(bufnrr)
        local byte_size = vim.api.nvim_buf_get_offset(bufnrr, vim.api.nvim_buf_line_count(bufnrr))
        return byte_size == 0 or byte_size == 1
    end
    ---@param args {bufnr:integer,filepath:string}
    local select_and_write = function(args)
        assert(args.bufnr ~= nil or args.filepath ~= nil)
        M.select_task(all_tasks, function(result)
            local bufnr = args.bufnr
                or (function()
                    vim.cmd("edit " .. args.filepath)
                    return vim.api.nvim_get_current_buf()
                end)()

            local content
            if is_empty_buffer(bufnr) then
                content = M.template_config
            else
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                content = table.concat(lines, "\n")
            end

            for _, task in ipairs(result) do
                content = M.template_appendtask(content, task)
            end
            local lines = vim.split(content, "\n")
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        end, "Select task to add", true)
    end
    local filepath = M.localtask_path()
    local bufnr = vim.fn.bufnr(filepath)
    local buf_exists = bufnr ~= -1
    local win_exists = buf_exists and vim.fn.bufwinnr(bufnr) ~= -1
    local is_focused = buf_exists and vim.api.nvim_get_current_buf() == bufnr
    local file_exists = vim.fn.filereadable(filepath) == 1

    if buf_exists and win_exists and not is_focused then
        vim.cmd("buffer " .. bufnr)
    elseif buf_exists and not win_exists and not is_focused then
        vim.cmd("edit " .. filepath)
    elseif buf_exists and win_exists and is_focused then
        select_and_write({ bufnr = bufnr })
    elseif not buf_exists and not file_exists then
        select_and_write({ filepath = filepath })
    elseif not buf_exists and file_exists then
        vim.cmd("edit " .. filepath)
    end
    M.refresh_local()
end

---@alias field string

---@class taskattr
---@field field field
---@field name string
---@field mode taskmode
---@field type tasktype
---@field filetypes string[]

---@param all_tasks table<field,tasks>
---@param callback fun(task:tasks)
---@param prompt string|nil
---@param field_option boolean default false
M.select_task = function(all_tasks, callback, prompt, field_option)
    field_option = field_option or false
    local items = {}
    local insert = function(field, tasks)
        if field_option then
            table.insert(items, {
                field = field,
                name = "all",
                mode = "",
                type = "",
                filetypes = {},
                all = true,
            })
        end
        for _, task in ipairs(tasks) do
            table.insert(
                items,
                vim.tbl_deep_extend("force", task, {
                    field = field,
                })
            )
        end
    end
    local hasglobal = false --Global置后
    for field, tasks in pairs(all_tasks) do
        if field == "global" then
            hasglobal = true
        else
            insert(field, tasks)
        end
    end
    if hasglobal then
        insert("global", all_tasks.global)
    end
    local w = compute_width(items)
    vim.ui.select(items, {
        prompt = prompt or "Select task",
        format_item = function(item)
            return draw_encode(item.field, item.name, item.mode, item.type, item.filetypes, w)
        end,
    }, function(choice)
        local result = {}
        if choice == nil then
            return
        end
        if choice.all then
            result = all_tasks[choice.field]
        else
            result = M.filter(
                all_tasks[choice.field],
                choice.name,
                choice.filetypes,
                choice["type"],
                choice.mode
            )
            if #result > 1 then
                vim.notify(
                    string.format(
                        "[task]: %s.%s(%s:%s) for %s matched multi tasks",
                        choice.field,
                        choice.name,
                        choice.mode,
                        choice["type"],
                        #choice.filetypes ~= 0 and table.concat(choice.filetypes, ",") or "*"
                    ),
                    vim.log.levels.ERROR
                )
                return
            end
        end
        callback(result)
    end)
end
M.select_and_run = function()
    local all_tasks = M.listtasks()
    all_tasks = { --FILTER
        global = M.filter(all_tasks.globaltasks, nil, vim.bo.filetype),
        locall = M.filter(all_tasks.localtasks, nil, vim.bo.filetype),
    }
    M.select_task(all_tasks, function(tasks)
        assert(#tasks == 1)
        ---@type task|nil
        local task = tasks[1]
        assert(task)
        task = M.macro_replace(task)
        if task == nil then
            return
        end
        run_wrap(task.cmd, task.name, task.opts)
        vim.notify(string.format("[task]: %s cmd:%s", task.name, vim.inspect(task.cmd)))
    end, "Select task to run", false)
end

---@type taskmode|nil ("debug">"release")
M.task_mode = nil
---@type tasktype|nil ("project">"file")
M.task_type = nil
function M.switch_taskmode()
    if M.task_mode == nil then
        M.task_mode = "debug"
    elseif M.task_mode == "debug" then
        M.task_mode = "release"
    elseif M.task_mode == "release" then
        M.task_mode = nil
    end
    vim.cmd(string.format(
        [[
				echohl Number
				echo "Current task_mode: %s"
				echohl None
                ]],
        M.task_mode
    ))
end
function M.switch_tasktype()
    if M.task_type == nil then
        M.task_type = "project"
    elseif M.task_type == "project" then
        M.task_type = "file"
    elseif M.task_type == "file" then
        M.task_type = nil
    end
    vim.cmd(string.format(
        [[
				echohl Number
				echo "Current task_type: %s"
				echohl None
                ]],
        M.task_type
    ))
end
M.setkeymap = function()
    local map = require("utils").map
    map("n", "<F9>", function()
        M.run("build", M.task_type, M.task_mode)
    end, { desc = "Build" })
    map("n", "<F10>", function()
        M.run("run", M.task_type, M.task_mode)
    end, { desc = "Run" })
    map("n", "<F11>", M.switch_taskmode, { desc = "TaskToggleDebugRelease" })
    map(
        "n",
        vim.g.is_win and "<S-F11>" or "<F23>",
        M.switch_tasktype,
        { desc = "TaskToggleProjFile" }
    )
    map("n", "<F12>", function()
        M.select_and_run()
    end, { desc = "TaskSelectAndRun" })
    map("n", vim.g.is_win and "<S-F12>" or "<F24>", function()
        M.edit_task()
    end, { desc = "TaskEdit" })
end
M.createcmds = function()
    vim.api.nvim_create_user_command("TaskEdit", M.edit_task, {})
    vim.api.nvim_create_user_command("TaskSelectAndRun", M.select_and_run, {})
    vim.api.nvim_create_user_command("TaskToggleDebugRelease", M.switch_taskmode, {})
    vim.api.nvim_create_user_command("TaskToggleProjFile", M.switch_tasktype, {})
end
M.setup = function()
    M.setkeymap()
    M.createcmds()
end
return M
