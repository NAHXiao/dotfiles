---@class UserTask
---@field name string
---@field label? string
---@field cmds string[]|string
---@field filetypes? string[]|"*"
---@field with_shell? boolean
---@field with_cmd_wrapper? boolean
---@field with_tmpfile? table<string,string>
---@field cwd? string
---@field clear_env? boolean
---@field env? table<string,string>
---@field detach? boolean
---@field stdin_file? string
---@field stdin_pipe? string
---@field before_start? fun()
---@field on_start? fun(jobid,code,event)
---@field on_exit? fun(jobid,code,event)
---@field after_finish? fun(jobid,code)
---@field repeat_opts? {time?:number,timeinterval?:number,stop_cond?:fun(code,stdout,stderr):boolean}
---@class Task
---@field classname "Task"
---@field name string
---@field label? string
---@field field string
---@field cmds string[]|string
---@field filetypes? string[]|"*"
---@field with_shell boolean
---@field with_cmd_wrapper boolean
---@field with_tmpfile? table<string,string>
---@field cwd string
---@field clear_env? boolean
---@field env? table<string,string>
---@field detach? boolean
---@field stdin_file? string
---@field stdin_pipe? string
---@field before_start? fun()
---@field on_start? fun(jobid,code,event)
---@field on_exit? fun(jobid,code,event)
---@field after_finish? fun(jobid,code)
---@field repeat_opts? {time:number,timeinterval:number,stop_cond:fun(code,stdout,stderr):boolean}
---@class UserTaskSet
---@field name string
---@field break_on_err? boolean
---@field seq? boolean
---@field filetypes? string[]|"*"
---@field [number] string|{name:string,field?:string,label?:string}|UserTask|{
---[1]:string|{name:string,field?:string,label?:string}|UserTask,
---bg?:boolean,
---ignore_err?:boolean,
---repeat_opts?:{
---time:number,
---timeinterval:number,
---stop_cond:fun(code,stdout,stderr):boolean}}
---@class TaskSet
---@field classname "TaskSet"
---@field name string
---@field break_on_err boolean
---@field seq boolean
---@field filetypes? string[]|"*"
---@field field boolean
---@field [number] {task:Task,opts?:{ bg?:boolean, ignore_err?:boolean}}

---@param cmds string|string[]
---@param with_shell? boolean default false
---@param stdin_file? string
local function cmd_wrapper(cmds, with_shell, stdin_file)
    if with_shell then
        --stylua: ignore
        return vim.v.progpath
            .." ".. "-u NONE -l"
            .." ".. vim.fs.joinpath(vim.fn.stdpath("config"), "bin", "cmd_wrapper.lua")
            .." ".. (stdin_file and ("--stdin-file=" .. stdin_file) or "")
            .." ".. "--print-cmds --expand-env --cmds "
            .." ".. (type(cmds) == "string" and cmds or cmds[1])
    else
        local cmds_final = {
            vim.v.progpath,
            "-u",
            "NONE",
            "-l",
            vim.fs.joinpath(vim.fn.stdpath("config"), "bin", "cmd_wrapper.lua"),
            "--print-cmds",
            "--expand-env",
            "--cmds",
        }
        if stdin_file then
            cmds_final[#cmds_final + 1] = "--stdin-file=" .. stdin_file
        end
        if type(cmds) == "string" then
            cmds_final[#cmds_final + 1] = cmds
        else
            vim.list_extend(cmds_final, cmds)
        end
        return cmds_final
    end
end
local T = {
    data = {}, --这里的global即field,下面的locall等也是
}
---@alias TypeNames "number" |"string" |"boolean" |"table" |"function" |"thread" | "userdata"|"nil"
---@generic T
---@param name string
---@param value T
---@param validator TypeNames|TypeNames[]|fun(it:T):boolean|string
---@param msg? string
local function validate(name, value, validator, msg)
    local valid_types
    if type(validator) == "string" then
        valid_types = { validator }
    end
    if type(validator) == "table" then
        valid_types = validator
    end
    if type(validator) ~= "function" then
        validator = function(it)
            for _, tp in ipairs(valid_types) do
                if type(it) == tp then
                    return true
                end
            end
            return false
        end
    end
    local ok_or_msg = validator(value)
    if ok_or_msg ~= true then
        local errmsg = "\nError:"
        if type(msg) == "string" then
            errmsg = errmsg .. msg
        end
        errmsg = errmsg .. "\nname:" .. name
        if valid_types then
            errmsg = errmsg .. ("\nexpect %s,but got %s"):format(table.concat(valid_types, "|"))
        end
        if type(ok_or_msg) == "string" then
            errmsg = errmsg .. "\nmsg:" .. ok_or_msg
        end
        errmsg = errmsg .. "\nvalue:" .. vim.inspect(value)
        error(errmsg, 2)
    end
end
---@param utask UserTask
---@param field string
---@return boolean
---@return string|nil
function T.ensure_valid_utask(utask, field)
    local ok, err = pcall(function()
        for _, args in ipairs {
            { "utask", utask, "table" },
            { "utask.name", utask.name, "string" },
            {
                "utask.cmds",
                utask.cmds,
                function(v)
                    return type(v) == "string" or (type(v) == "table" and #v > 0)
                end,
                "string or non-empty table",
            },
            { "utask.label", utask.label, { "string", "nil" } },
            {
                "utask.duplicated",
                utask,
                function(it)
                    for _, existing_task in ipairs(T.data[field].tasks) do
                        if existing_task.name == it.name and existing_task.label == it.label then
                            return false
                        end
                    end
                    return true
                end,
                "duplicated",
            },
            {
                "utask.filetypes",
                utask.filetypes,
                function(it)
                    return not it or (type(it) == "table" and #it ~= 0) or it == "*"
                end,
                "utask.filetypes should be one of NonEmpty table<string>|*|nil",
            },
            { "utask.with_shell", utask.with_shell, { "boolean", "nil" } },
            {
                "utask.with_shell",
                utask,
                function(it)
                    if it.with_shell == true and type(it.cmds) == "table" and #it.cmds ~= 1 then
                        return false
                    end
                    return true
                end,
                "utask.with_shell could be set to true only when utask.cmds is string or #utask.cmds==1",
            },
            { "utask.with_cmd_wrapper", utask.with_cmd_wrapper, { "boolean", "nil" } },
            { "utask.with_tmpfile", utask.with_tmpfile, { "table", "nil" } },
            { "utask.cwd", utask.cwd, { "string", "nil" } },
            { "utask.clear_env", utask.clear_env, { "boolean", "nil" } },
            { "utask.env", utask.env, { "table", "nil" } },
            { "utask.on_exit", utask.on_exit, { "function", "nil" } },
            { "utask.after_finish", utask.after_finish, { "function", "nil" } },
            { "utask.detach", utask.detach, { "boolean", "nil" } },
            {
                "utask.stdin_file",
                utask.stdin_file,
                { "string", "nil" },
            },
            { "utask.stdin_pipe", utask.stdin_pipe, { "string", "nil" } },
            {
                "utask.stdin",
                utask,
                function(it)
                    if it.stdin_file ~= nil and it.stdin_pipe ~= nil then
                        return false
                    end
                    return true
                end,
                "stdin_file and stdin_pipe cannot coexist",
            },
            {
                "utask.repeat_opts",
                utask.repeat_opts,
                function(it)
                    if it == nil then
                        return true
                    end
                    if type(it) == "table" then
                        return (not it.time or type(it.time) == "number")
                            and (not it.stop_cond or type(it.stop_cond) == "function")
                            and (not it.timeinterval or type(it.timeinterval) == "number")
                    end
                    return false
                end,
            },
        } do
            validate(args[1], args[2], args[3], args[4])
        end
    end)
    if not ok then
        return false, err
    end
    return true, nil
end
---@param utaskset UserTaskSet
---@param field string
---@return boolean
---@return string|nil
---每个taskset的name唯一,在同一个field具有唯一性,addtaskset不得添加重复taskset
---会vim.validate,extend验证utaskset
function T.ensure_valid_utaskset(utaskset, field)
    local ok, err = pcall(function()
        for _, args in ipairs {
            { "utaskset", utaskset, "table" },
            { "utaskset.name", utaskset.name, "string" },
            {
                "utaskset.name unique",
                utaskset,
                function(us)
                    for _, existing in ipairs(T.data[field].tasksets) do
                        if existing.name == us.name then
                            return false
                        end
                    end
                    return true
                end,
                "duplicated taskset name",
            },
            { "utaskset.break_on_err", utaskset.break_on_err, { "boolean", "nil" } },
            { "utaskset.seq", utaskset.seq, { "boolean", "nil" } },
            {
                "utaskset.filetypes",
                utaskset.filetypes,
                function(it)
                    return not it or (type(it) == "table" and #it ~= 0) or it == "*"
                end,
                "utaskset.filetypes should be one of NonEmpty table<string>|*|nil",
            },
        } do
            validate(args[1], args[2], args[3], args[4])
        end
        for idx, utask in ipairs(utaskset) do
            local string_type = function(it)
                if type(it) == "string" then
                    -- vim.notify("string_type")
                    return true
                end
                return false
            end
            local tbl_type = function(it) --{name:string,field?:string,label?:string}
                if type(it) == "table" and (it[1] == nil) and it.name and not it.cmds then
                    -- vim.notify("tbl_type")
                    return true
                end
                return false
            end
            local with_opts_type = function(it) --{ [1]:string|{name:string,field?:string,label?:string}|UserTask ...}
                if type(it) == "table" and it[1] ~= nil then
                    -- vim.notify("with_opts_type")
                    return true
                end
                return false
            end
            local task_type = function(it)
                if not string_type(it) and not tbl_type(it) and not with_opts_type(it) then
                    -- vim.notify("task_type")
                    return true
                else
                    return false
                end
            end
            validate("utaskset.tasks", utask, function(utask) --string/tbl not expand,task expand
                ---@type {name:string,field?:string,label?:string}
                local anchor = {}
                ---@type Task (copy,not ref)
                local task
                local opts
                if string_type(utask) then
                    ---@cast utask string
                    anchor.name = utask
                elseif tbl_type(utask) then
                    ---@cast utask {name:string,field?:string,label?:string}
                    anchor = utask
                elseif with_opts_type(utask) then
                    opts = utask
                    validate("opts.bg", opts.bg, { "boolean", "nil" })
                    validate("opts.ignore_err", opts.ignore_err, { "boolean", "nil" })
                    if opts.repeat_opts then
                        validate(
                            "opts.repeat_opts.time",
                            opts.repeat_opts.time,
                            { "nil", "number" }
                        )
                        validate(
                            "opts.repeat_opts.timeinterval",
                            opts.repeat_opts.timeinterval,
                            { "nil", "number" }
                        )
                        validate(
                            "opts.repeat_opts.stop_cond",
                            opts.repeat_opts.stop_cond,
                            { "nil", "function" }
                        )
                    end
                    local utask_1 = utask[1]
                    if string_type(utask_1) then
                        ---@cast utask_1 string
                        anchor = { name = utask_1 }
                    elseif tbl_type(utask_1) then
                        ---@cast utask_1 {name:string,field?:string,label?:string}
                        anchor = utask_1
                    elseif task_type(utask_1) then
                        ---@cast utask_1 UserTask
                        task = T.extend_task(utask_1, field)
                    else
                        assert(false, "unreachable")
                    end
                elseif task_type(utask) then
                    ---@cast utask UserTask
                    task = T.extend_task(utask, field)
                else
                    assert(false, "unreachable")
                end
                if not task then
                    local match = function(it)
                        if anchor.label then
                            return it.label == anchor.label and it.name == anchor.name
                        else
                            return it.name == anchor.name
                        end
                    end
                    if anchor.field then
                        local field_matched =
                            vim.iter(T.data[anchor.field].tasks):filter(match):totable()
                        if #field_matched == 0 then
                            return (vim.inspect(anchor) .. " not found")
                        end
                        if #field_matched > 1 then
                            return (vim.inspect(anchor) .. " occurred multiple times")
                        end
                        task = vim.deepcopy(field_matched[1])
                    else
                        local field_matched = vim.iter(T.data[field].tasks):filter(match):totable()
                        local global_matched = vim.iter(T.data.global.tasks):filter(match):totable()
                        if #field_matched == 0 and #global_matched == 0 then
                            return (vim.inspect(anchor) .. " not found")
                        end
                        if
                            (#field_matched > 1)
                            or (#field_matched == 0 and #global_matched > 1)
                        then
                            return (vim.inspect(anchor) .. " occurred multiple times")
                        end
                        task = vim.deepcopy(
                            (#field_matched == 1 and field_matched[1] or global_matched[1])
                        )
                    end
                end
                ---@cast opts {bg?:boolean, ignore_err?:boolean, repeat_opts?:{ time:number, timeinterval:number, stop_cond:fun(code,stdout,stderr):boolean}}
                assert(task ~= nil)
                if opts then
                    opts[1] = nil
                end
                ---@cast utaskset TaskSet
                utaskset[idx] = {
                    task = task,
                    opts = opts,
                }
                if opts and opts.repeat_opts then
                    task.repeat_opts = vim.tbl_extend("force", task.repeat_opts, opts.repeat_opts)
                    opts.repeat_opts = nil
                end
                return true
            end)
        end
    end)
    if not ok then
        return false, err
    end
    return true, nil
end
---@param utask UserTask
---@param field string
---@return Task
function T.extend_task(utask, field)
    local task = vim.tbl_extend("force", {
        with_shell = false,
        with_cmd_wrapper = true,
        cwd = "$(VIM_ROOT)",
        classname = "Task",
    }, utask)
    task.field = field
    task.repeat_opts = utask.repeat_opts
            and vim.tbl_extend("force", {
                time = math.huge,
                stop_cond = function(code, stdout, stderr)
                    return code == 0
                end,
                timeinterval = 1,
            }, utask.repeat_opts)
        or nil
    return task
end
---@param utaskset UserTaskSet
---@param field string
---@return TaskSet
function T.extend_taskset(utaskset, field)
    local taskset = vim.tbl_extend("force", {
        break_on_err = true,
        seq = true,
        classname = "TaskSet",
    }, utaskset)
    taskset.field = field
    return taskset
end
---@param utask UserTask
---@param field string
---add_task将先valid task合理性后进行extend,再添加到T.data.field.task中
function T:add_task(utask, field)
    local ok, err = T.ensure_valid_utask(utask, field)
    if ok then
        table.insert(T.data[field].tasks, T.extend_task(utask, field))
    else
        vim.notify("Failed to add task:\n" .. err, vim.log.levels.ERROR)
        return false
    end
    return true
end
---@param utaskset UserTaskSet
---@param field string
---add_taskset将先valid taskset合理性后进行extend,再添加到T.data.field.taskset中
function T:add_taskset(utaskset, field)
    local ok, err = T.ensure_valid_utaskset(utaskset, field)
    if ok then
        table.insert(T.data[field].tasksets, T.extend_taskset(utaskset, field))
    else
        vim.notify("Failed to add taskset:\n" .. err, vim.log.levels.ERROR)
        return false
    end
    return true
end
---require("tools.config.task")得到table<string,{task:utask[],taskset[]}>,将先添加所有field的tasks再添加tasksets(因为一个tasksets可能引用其他field的task)
function T:loadconfig()
    ---@type table<string,{tasks:UserTask[],tasksets:UserTaskSet[]}>
    local config = require("tools.config.task")
    for _, field_data in pairs(T.data) do
        field_data.tasks = {}
        field_data.tasksets = {}
    end
    for field_name, _ in pairs(config) do
        if not T.data[field_name] then
            T.data[field_name] = {
                tasks = {},
                tasksets = {},
            }
        end
    end
    for field_name, field_config in pairs(config) do
        if field_config.tasks then
            for _, utask in ipairs(field_config.tasks) do
                if not T:add_task(utask, field_name) then
                    return
                end
            end
        end
    end
    for field_name, field_config in pairs(config) do
        if field_config.tasksets then
            for _, utaskset in ipairs(field_config.tasksets) do
                if not T:add_taskset(utaskset, field_name) then
                    return
                end
            end
        end
    end
end
---T.data.locall置空,并重新dofile (function()return vim.fs.joinpath(require("utils").get_rootdir(),".vim","task.lua") end)()得到{tasks:utask[],tasksets:utaskset[]},然后先add tasks再add tasksets(到field locall)
---@return boolean
function T:refresh_local()
    T.data.locall = {
        tasks = {},
        tasksets = {},
    }
    local config_file = vim.fs.joinpath(require("utils").get_rootdir(), ".vim", "task.lua")
    if 0 == vim.fn.filereadable(config_file) then
        return false
    end
    local ok, config = pcall(dofile, config_file)
    if not ok or type(config) ~= "table" then
        vim.notify(
            "Failed to load local task config: " .. (config or "Invalid config format"),
            vim.log.levels.ERROR
        )
        return false
    end
    if config.tasks then
        for _, utask in ipairs(config.tasks) do
            if not T:add_task(utask, "locall") then
                return false
            end
        end
    end
    if config.tasksets then
        for _, utaskset in ipairs(config.tasksets) do
            if not T:add_taskset(utaskset, "locall") then
                return false
            end
        end
    end
    return true
end

---@param data {[string]:{tasks:Task[],tasksets:TaskSet[]}}
---@param prompt string
---@param callback fun(items:(Task|TaskSet)[]|(Task|TaskSet)|nil)
---@param field_option boolean
---@return nil
function T:select(data, prompt, callback, field_option)
    field_option = field_option or false
    ---@alias field_option {field:string,below:("tasksets"|"tasks"),classname:"FieldOption"}
    ---@type (field_option|Task|TaskSet)[]
    local options = {}
    local draw = { 8, 8, 8, 0, 0, colnum = 5 }
    ---@param item Task|TaskSet
    function draw:update(item)
        draw[1] = math.max(draw[1], #item.field)
        draw[3] = math.max(draw[3], #item.name)
        draw[4] = math.max(draw[4], item.label ~= nil and #item.label + 1 or 0)
        if item.filetypes == "*" then
            draw[5] = math.max(draw[5], 1)
        elseif type(item.filetypes) == "table" then
            draw[5] =
                math.max(draw[5], #item.filetypes ~= 0 and #table.concat(item.filetypes, ",") or 1)
        end
    end

    function draw:calculate_final()
        local width = vim.o.columns * 0.5
        self.colnum = 5
        if self[5] == 0 then
            self.colnum = self.colnum - 1
            if self[4] == 0 then
                self.colnum = self.colnum - 1
            end
        end
        local current_total = 0
        for i = 1, self.colnum do
            current_total = current_total + self[i]
        end
        if current_total < width then
            local extra_width = width - current_total
            for _ = 1, extra_width do
                local min_idx = 1
                for i = 2, self.colnum do
                    if self[i] < self[min_idx] then
                        min_idx = i
                    end
                end
                self[min_idx] = self[min_idx] + 1
            end
        end
    end
    function draw:draw(item)
        local row
        if item.classname == "FieldOption" then
            if self.colnum == 5 then
                row = { item.field, item.below, "", "", "" }
            elseif self.colnum == 4 then
                row = { item.field, item.below, "", "" }
            elseif self.colnum == 3 then
                row = { item.field, item.below, "" }
            end
        elseif item.classname == "Task" or item.classname == "TaskSet" then
            local ftstr
            if type(item.filetypes) == "table" then
                ftstr = table.concat(item.filetypes, ",")
            elseif item.filetypes == "*" then
                ftstr = "*"
            else
                assert(item.filetypes == nil, "unreachable")
                ftstr = ""
            end
            row = {
                item.field,
                item.classname:lower(),
                item.name,
            }
            if self.colnum >= 4 then
                row[#row + 1] = item.label or ""
            end
            if self.colnum == 5 then
                row[#row + 1] = ftstr
            end
        end
        for i = 1, self.colnum do
            row[i] = row[i] .. string.rep(" ", self[i] - #row[i])
        end
        return table.concat(row, " | ")
    end

    local function process_tbl(field, tbl)
        if not tbl then
            return
        end
        if tbl.tasksets and #tbl.tasksets ~= 0 then
            if field_option then
                options[#options + 1] = { field = field, below = "tasksets" }
            end
            for _, taskset in ipairs(tbl.tasksets) do
                options[#options + 1] = taskset
                draw:update(taskset)
            end
        end
        if tbl.tasks and #tbl.tasks ~= 0 then
            if field_option then
                options[#options + 1] = { field = field, below = "tasks" }
            end
            for _, task in ipairs(tbl.tasks) do
                options[#options + 1] = task
                draw:update(task)
            end
        end
    end
    process_tbl("locall", data.locall)
    process_tbl("global", data.global)
    for field, tbl in pairs(data) do
        if field ~= "global" and field ~= "locall" then
            process_tbl(field, tbl)
        end
    end
    draw:calculate_final()
    vim.ui.select(options, {
        prompt = prompt,
        format_item = function(item)
            local ret = draw:draw(item)
            return ret
        end,
    }, function(choice)
        if not choice then
            callback(nil)
            return
        end
        if field_option then
            if choice.classname == "FieldOption" then
                callback(data[choice.field][choice.below])
            else
                callback { choice }
            end
        else
            callback(choice)
        end
    end)
end
---@type table<Task,table<string,string>>
local input_cache = setmetatable({}, {
    __index = function(t, k)
        if k.classname == "Task" then
            local key = "F:" .. k.field .. "N:" .. k.name
            if k.label then
                key = key .. ":L" .. k.label
            end
            return rawget(t, key)
        end
        assert(false, "k should be Task")
    end,
    __newindex = function(t, k, v)
        if k.classname == "Task" then
            local key = "F:" .. k.field .. "N:" .. k.name
            if k.label then
                key = key .. ":L" .. k.label
            end
            rawset(t, key, v)
            return
        end
        assert(false, "k should be Task")
    end,
})
---@param task Task
---cmds,env,after_finish
local function macro_repalce(task)
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
            return require("utils").get_rootdir()
        end,
        ["$(VIM_PRONAME)"] = function()
            return vim.fs.basename(vim.g.projroot)
        end,
    }
    for macro_name, content in pairs(task.with_tmpfile or {}) do
        vim.fn.mkdir(vim.fs.joinpath(vim.fn.stdpath("cache"), "task"), ":p")
        local fd, path_or_msg = vim.uv.fs_mkstemp(
            vim.fs.joinpath(vim.fn.stdpath("cache"), "task", macro_name .. "-XXXXXXX")
        )
        if fd then
            vim.uv.fs_write(fd, content)
            vim.uv.fs_close(fd)
            map["$(" .. macro_name .. ")"] = function()
                return path_or_msg
            end
            local _before_start = task.before_start
            task.before_start = function()
                if 0 == vim.fn.filereadable(path_or_msg) then
                    fd = vim.uv.fs_open(path_or_msg, "w", tonumber("644", 8))
                    if fd then
                        vim.uv.fs_write(fd, content)
                        vim.uv.fs_close(fd)
                    end
                end
                if _before_start then
                    _before_start()
                end
            end
            local _after_finish = task.after_finish
            task.after_finish = function(...)
                vim.fn.delete(path_or_msg)
                if _after_finish then
                    _after_finish(...)
                end
            end
        else
            error()
        end
    end
    -- vim.notify(vim.inspect(map))
    local function replace_in_string(str)
        if type(str) ~= "string" then
            return str
        end
        for macro, func in pairs(map) do
            str = str:gsub(vim.pesc(macro), func())
        end
        ---$(-argname) | $(-argname:default)
        str = str:gsub("%$%(%-([^:%)]+):?([^%)]*)%)", function(argname, default)
            local cache_key = "$(-" .. argname .. ":" .. default .. ")"
            local cached_value = nil
            if input_cache[task] and input_cache[task][cache_key] then
                cached_value = input_cache[task][cache_key]
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
            input_cache[task] = input_cache[task] or {}
            input_cache[task][cache_key] = input_value
            return input_value
        end)
        return str
    end
    if type(task.cmds) == "string" then
        task.cmds = replace_in_string(task.cmds)
    elseif type(task.cmds) == "table" then
        for idx, cmd in ipairs(task.cmds) do
            task.cmds[idx] = replace_in_string(cmd)
        end
    end
    if type(task.cwd) == "string" then
        task.cwd = replace_in_string(task.cwd)
    end
    if type(task.env) == "table" then
        for k, v in pairs(task.env) do
            task.env[k] = replace_in_string(v)
        end
    end
    return task
end
local function on_start_stdin_pipe(jobid, stdin_pipe)
    -- vim.notify("task.on_start (stdin_pipe)")
    if stdin_pipe then
        vim.schedule(function()
            pcall(vim.fn.chansend, jobid, stdin_pipe)
        end)
    end
end
---@param task Task
local function run_task(task)
    local task_final = macro_repalce(vim.deepcopy(task))
    if task_final.with_cmd_wrapper then
        task_final.cmds = cmd_wrapper(task_final.cmds, task_final.with_shell, task_final.stdin_file)
    end
    local name = task_final.name
    if task_final.label then
        name = ("%s(%s)"):format(name, task_final.label)
    end
    local args = {
        name,
        {
            cmds = task_final.cmds,
            opts = {
                clear_env = task_final.clear_env,
                detach = task_final.detach,
                repeat_opts = task_final.repeat_opts,
                cwd = task_final.cwd,
                env = task_final.env,
                before_start = task_final.before_start,
                on_start = task_final.stdin_pipe and function(job)
                    on_start_stdin_pipe(job, task_final.stdin_pipe)
                end,
                on_exit = task_final.on_exit,
                after_finish = task_final.after_finish,
            },
        },
        false,
        true,
        name .. "F:" .. task.field,
    }
    require("tools.term").newtask(unpack(args))
end
---@param taskset TaskSet
local function run_taskset(taskset)
    local taskset_final = vim.deepcopy(taskset)
    for idx, item in ipairs(taskset_final) do
        taskset_final[idx].task = macro_repalce(item.task)
        if taskset_final[idx].task.with_cmd_wrapper then
            taskset_final[idx].task.cmds = cmd_wrapper(
                taskset_final[idx].task.cmds,
                taskset_final[idx].task.with_shell,
                taskset_final[idx].task.stdin_file
            )
        end
    end
    ---@type {jobinfo:ujobinfo,bg:boolean|nil,ignore_error:boolean|nil}[]
    local tasks = {}
    for _, item in ipairs(taskset_final) do
        tasks[#tasks + 1] = {
            name = item.task.name .. (item.task.label and ("(" .. item.task.label .. ")") or ""),
            jobinfo = {
                cmds = item.task.cmds,
                opts = {
                    clear_env = item.task.clear_env,
                    detach = item.task.detach,
                    cwd = item.task.cwd,
                    env = item.task.env,
                    before_start = item.task.before_start,
                    on_start = item.task.stdin_pipe and function(job)
                        on_start_stdin_pipe(job, item.task.stdin_pipe)
                    end,
                    on_exit = item.task.on_exit,
                    after_finish = item.task.after_finish,
                    repeat_opts = item.task.repeat_opts,
                },
            },
            bg = item.opts and item.opts.bg or false,
            ignore_error = item.opts and item.opts.ignore_err or false,
        }
    end
    local args = {
        taskset_final.name,
        tasks,
        taskset_final.seq,
        taskset_final.break_on_err,
        false,
        true,
        nil,
        taskset_final.name .. "F:" .. taskset_final.field,
    }
    require("tools.term").newtaskset(unpack(args))
end
local default_build, default_run, default_test
local tmpl = ([[---@module 'tools.task'
---@type {tasks:UserTask[],tasksets:UserTaskSet[]}
---See [%s]
---$(MACRO)/$(-argname)/$(-argname:default)/${ENV}
return {
	tasks = {},
	tasksets = {},
}]]):format(
    require("utils").prefix_replace(
        vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "tools", "config", "task.lua"),
        vim.uv.os_homedir(),
        "~"
    )
)
function T.setup()
    T:loadconfig()
    T:refresh_local()
    require("utils").auc({ "BufWritePost", "FileWritePost" }, {
        pattern = vim.fs.joinpath(require("utils").get_rootdir(), ".vim", "task.lua"),
        group = require("utils").aug("tools.task.refresh_when_save_task.lua", true),
        callback = function()
            if T:refresh_local() then
                vim.notify("[task]: refresh_local ok")
            end
        end,
    })
    require("utils").auc("User", {
        pattern = "ProjRootChanged",
        callback = function()
            if T:refresh_local() then
                vim.notify("[task]: refresh_local ok")
            end
            require("utils").auc({ "BufWritePost", "FileWritePost" }, {
                pattern = vim.fs.joinpath(require("utils").get_rootdir(), ".vim", "task.lua"),
                group = require("utils").aug("tools.task.refresh_when_save_task.lua", true),
                callback = function()
                    if T:refresh_local() then
                        vim.notify("[task]: refresh_local ok")
                    end
                end,
            })
        end,
    })
    local map = require("utils").map
    local function get_filetype()
        if
            vim.list_contains({
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
            }, vim.bo.filetype)
            or vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= ""
            or (
                vim.api.nvim_get_option_value("buftype", { buf = 0 }) == ""
                and vim.fs.dirname(vim.api.nvim_buf_get_name(0))
                    == vim.fs.joinpath(require("utils").get_rootdir(), ".vim")
            )
        then
            return nil
        end
        return vim.bo.filetype
    end
    ---@param it Task|TaskSet
    local function run(it)
        if it.classname == "Task" then
            run_task(it)
        elseif it.classname == "TaskSet" then
            run_taskset(it)
        else
            assert(false, "unreachable")
        end
    end
    ---@param who? "build"|"run"|"test"
    ---@param ft string|nil
    local function select_run_set_default(who, ft)
        local filter = function(it)
            return (not who or it.name:lower():find(who:lower()) ~= nil)
                and (
                    (ft == nil and it.filetypes == nil)
                    or it.filetypes == "*"
                    or (type(it.filetypes) == "table" and vim.list_contains(it.filetypes, ft))
                )
        end
        local sum = 0
        local data = vim.iter(T.data)
            :map(function(k, v)
                local tasks = vim.iter(v.tasks):filter(filter):totable()
                local tasksets = vim.iter(v.tasksets):filter(filter):totable()
                sum = sum + #tasks
                sum = sum + #tasksets
                return k,
                    {
                        tasks = tasks,
                        tasksets = tasksets,
                    }
            end)
            :fold({}, function(tbl, k, v)
                tbl[k] = v
                return tbl
            end)
        if sum == 0 then
            vim.notify(("No %stask/taskset Found"):format(who and (who .. " ") or ""))
            return
        end
        T:select(
            data,
            "Task" .. (who and (" : " .. who .. " ") or "") .. "(select, run and set default)",
            function(it)
                if it then
                    if who == "build" then
                        default_build = it
                    elseif who == "run" then
                        default_run = it
                    elseif who == "test" then
                        default_test = it
                    end
                    run(it)
                end
            end,
            false
        )
    end
    map("n", "<F9>", function()
        if default_build then
            run(default_build)
        else
            select_run_set_default("build", get_filetype())
        end
    end, { desc = "Task: build (run default)" })
    map("n", "<F10>", function()
        if default_run then
            run(default_run)
        else
            select_run_set_default("run", get_filetype())
        end
    end, { desc = "Task: run (run default)" })
    map("n", "<F11>", function()
        if default_test then
            run(default_test)
        else
            select_run_set_default("test", get_filetype())
        end
    end, { desc = "Task: test (run default)" })
    map("n", { "<S-F9>", "<F21>" }, function()
        select_run_set_default("build", get_filetype())
    end, { desc = "Task: build (select,run and set default)" })
    map("n", { "<S-F10>", "<F22>" }, function()
        select_run_set_default("run", get_filetype())
    end, { desc = "Task: run (select,run and set default)" })
    map("n", { "<S-F11>", "<F23>" }, function()
        select_run_set_default("test", get_filetype())
    end, { desc = "Task: test (select,run and set default)" })
    map("n", "<F12>", function()
        select_run_set_default(nil, get_filetype())
    end, { desc = "Task: select and run" })
    map("n", { "<F24>", "<S-F12>" }, function()
        if T:refresh_local() then
            vim.notify("[task]: refresh_local ok")
        end
        if default_build and default_build.field == "locall" then
            default_build = nil
        end
        if default_run and default_run.field == "locall" then
            default_run = nil
        end
        if default_test and default_test.field == "locall" then
            default_test = nil
        end
    end, { desc = "Task: refresh local" })
    map("n", "<leader>et", function()
        require("utils").focus_or_new(
            vim.fs.joinpath(require("utils").get_rootdir(), ".vim", "task.lua"),
            tmpl
        )
    end, { desc = "Edit: Task" })
end
return T
