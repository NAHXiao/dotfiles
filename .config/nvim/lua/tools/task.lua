local log = require("utils").log
local list_filter = require("utils").list_filter
---@type table<"global"|string,{tasks:utask[],tasksets:utaskset[]}>
local config = {
    global = {
        tasks = {
            --project-create
            {
                name = "mvn-create",
                cmds = {
                    "mvn",
                    "archetype:generate",
                    "-DgroupId=$(-group:com.example)",
                    "-DartifactId=$(-artifactname:hello-world)",
                    "-DarchetypeArtifactId=maven-archetype-quickstart",
                    "-DinteractiveMode=false",
                },
                type = "project",
            },
            {
                name = "cargo-create",
                cmds = { "cargo", "new", "$(-name)", "--bin" },
                type = "project",
            },
            {
                name = "cmake-create",
                cmds = { "cmake_create", "$(-name:)" },
                type = "project",
            },
            --c/cpp
            {
                name = "build",
                cmds = {
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
                cmds = {
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
                cmds = {
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
                cmds = {
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
                cmds = {
                    "$(VIM_PATHNOEXT)" .. (CC.is_win and ".exe" or ""),
                },
                filetypes = { "c", "cpp" },
                type = "file",
            },
            --java
            {
                name = "build",
                cmds = {
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
                cmds = {
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
                cmds = {
                    "lua",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "lua" },
                type = "file",
            },
            {
                name = "run(nvim)",
                cmds = {
                    "nvim",
                    "-u",
                    "NONE",
                    "-l",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "lua" },
                type = "file",
            },
            {
                name = "run",
                cmds = {
                    "python",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "python" },
                type = "file",
            },
            {
                name = "run",
                cmds = {
                    "node",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "javascript" },
                type = "file",
            },
            {
                name = "run",
                cmds = {
                    "powershell",
                    "-file",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "ps1" },
                type = "file",
            },
        },
        tasksets = {
            {
                name = "build_and_run(cpp release)",
                break_on_err = true,
                seq = true,
                "build(file:release)[cpp]",
                "run(file)[cpp,c]",
            },
            {
                name = "build_and_run(cpp debug)",
                break_on_err = true,
                seq = true,
                { "build(file:debug)[cpp]" },
                "run(file)[cpp,c]",
            },
        },
    },
    template = {
        tasks = {
            {
                name = "build",
                cmds = { "echo", "${CC}" },
                type = "project",
                mode = "debug",
                opts = {
                    clear_env = false,
                    cwd = "$(VIM_ROOT)",
                    env = {
                        CC = "clang",
                    },
                },
            },
            {
                name = "run",
                cmds = { "echo", "${CC}" },
                type = "project",
                mode = "debug",
                opts = {
                    clear_env = false,
                    cwd = "$(VIM_ROOT)",
                    env = {
                        CC = "clang",
                    },
                },
            },
        },
        tasksets = {
            {
                { "build(debug:project)" },
                "run(project:debug)",
                break_on_err = true,
                seq = true,
                name = "build and run",
            },
        },
    },
    cmake = {
        tasks = {
            {
                name = "project-refresh-config",
                cmds = { "cmake", "--fresh", "-B", "build", "-S", "." },
            },
            {
                name = "build",
                cmds = { "cmake", "--build", "build" },
            },
            {
                name = "run",
                cmds = { "build/$(VIM_PRONAME)" },
            },
        },
        tasksets = {},
    },
    cargo = {
        tasks = {
            {
                name = "build",
                cmds = { "cargo", "build" },
            },
            {
                name = "run",
                cmds = { "cargo", "run" },
            },
            {
                name = "project-test",
                cmds = { "cargo", "test" },
            },
        },
        tasksets = {},
    },
    mvn = {
        tasks = {
            {
                name = "build",
                cmds = { "mvn", "compile" },
            },
            {
                name = "project-test",
                cmds = { "mvn", "test" },
            },
            {
                name = "run",
                cmds = { "mvn", "exec:java", "-Dexec.mainClass=$(-mainClass:)" },
            },
        },
        tasksets = {},
    },
}

local T = {
    ---@type table<"global"|"locall"|string,{tasks:task[],tasksets:taskset[],str2taskmap:{[string]:task},str2setmap:{[string]:taskset}}>
    data = {
        global = {
            tasks = {},
            tasksets = {},
            str2taskmap = {},
            str2setmap = {},
        },
        locall = {
            tasks = {},
            tasksets = {},
            str2taskmap = {},
            str2setmap = {},
        },
    },
    task_base = {
        mode = "",
        type = "",
        filetypes = {},
        opts = {
            cwd = "$(VIM_ROOT)",
        },
    },
    taskset_base = { break_on_err = true, seq = true },
}
---@param utask utask
---@return task
function T:utask2task(utask, field)
    return vim.tbl_deep_extend("force", self.task_base, utask, { field = field })
end
---@param utaskset utaskset
---@return taskset
function T:utaskset2taskset(utaskset, field)
    ---@type utaskset
    local taskset = vim.tbl_deep_extend("force", self.taskset_base, utaskset, { field = field })
    for i, item in ipairs(taskset) do
        local taskname
        local bg = false --DEFAULT
        local ignore_err = false --DEFAULT
        if type(item) == "string" then
            taskname = item
        else
            taskname = item[1]
            bg = item.bg or bg
            ignore_err = item.ignore_err or ignore_err
        end
        assert(type(taskname) == "string")
        taskname = T:task2keys(T:keys2task(taskname))
        if
            T.data[field].str2taskmap[taskname] == nil
            and T.data.global.str2taskmap[taskname] == nil
        then
            assert(
                false,
                ("Your taskset %s called a not exist task %s"):format(taskset.name, taskname)
            )
        end
        taskset[i] = {
            [1] = taskname,
            bg = bg,
            ignore_err = ignore_err,
        }
    end
    ---return-type-mismatch
    return taskset
end
---@param utask utask
---@param field string
---@return task
function T:addtask(utask, field)
    assert(utask.name and utask.name ~= "" and utask.cmds and 0 ~= #utask.cmds)
    ---@type task
    local task = T:utask2task(utask, field)
    local str = self:task2keys(task)
    if self.data[field] == nil then
        self.data[field] = {
            tasks = {},
            tasksets = {},
            str2taskmap = {},
            str2setmap = {},
        }
    end
    if self.data[field].str2taskmap[str] then
        assert(false, ("The task %s has been defined"):format(task.name))
    end
    table.insert(self.data[field].tasks, task)
    self.data[field].str2taskmap[str] = task
    return task
end
---@param utaskset utaskset
---@param field string
function T:addtaskset(utaskset, field)
    local taskset = T:utaskset2taskset(utaskset, field)
    if self.data[field] == nil then
        self.data[field] = {
            tasks = {},
            tasksets = {},
            str2taskmap = {},
            str2setmap = {},
        }
    end
    if self.data[field].str2taskmap[taskset.name] then
        assert(false, ("The task %s has been defined"):format(taskset.name))
    end
    table.insert(self.data[field].tasksets, taskset)
    self.data[field].str2setmap[taskset.name] = taskset
    return taskset
end
---@param item task|taskset
---@param fts string[]
function T:item_valid_on_ft(item, fts)
    assert(fts)
    if self:istask(item) then
        if #item.filetypes == 0 then
            return true
        else
            for _, ft in ipairs(fts) do
                if vim.list_contains(item.filetypes, ft) then
                    return true
                end
            end
        end
    elseif self:istaskset(item) then
        return true
    end
end
---@param items items
function T:items2lines(items)
    ---@type string[]
    local lines = {}
    for _, item in ipairs(items) do
        if T:istask(item) then
            ---@cast item task
            lines[#lines + 1] = "new({"
            lines[#lines + 1] = ("    name = %s,"):format(vim.inspect(item.name))
            lines[#lines + 1] = ("    cmds = %s,"):format(vim.inspect(item.cmds))
            if item.mode ~= "" then
                lines[#lines + 1] = ("    mode = %s,"):format(vim.inspect(item.mode))
            end
            if item.type ~= "" then
                lines[#lines + 1] = ("    type = %s,"):format(vim.inspect(item.type))
            end
            if #item.filetypes ~= 0 then
                lines[#lines + 1] = ("    filetypes = %s,"):format(vim.inspect(item.filetypes))
            end
            local clear_env = item.opts.clear_env
            local cwd = item.opts.cwd ~= "$(VIM_ROOT)" and item.opts.cwd or nil
            local env = item.opts.env and next(item.opts.env) and item.opts.env or nil
            if cwd or env or clear_env then
                local optstr = "opts="
                    .. vim.inspect({
                        cwd = cwd,
                        clear_env = clear_env,
                        env = env,
                    })
                for _, line in ipairs(vim.split(optstr, "[\r\n]")) do
                    lines[#lines + 1] = "    " .. line
                end
            end
            lines[#lines + 1] = "})"
        elseif T:istaskset(item) then
            ---@cast item taskset
            lines[#lines + 1] = "new({"
            lines[#lines + 1] = ("    name = %s,"):format(vim.inspect(item.name))
            lines[#lines + 1] = ("    break_on_err = %s,"):format(tostring(item.break_on_err))
            lines[#lines + 1] = ("    seq = %s,"):format(tostring(item.seq))
            for _, task in ipairs(item) do
                lines[#lines + 1] = ("    { %s, bg = %s, ignore_err = %s },"):format(
                    vim.inspect(task[1]),
                    tostring(task.bg),
                    tostring(task.ignore_err)
                )
            end
            lines[#lines + 1] = "})"
        else
            assert(false)
        end
    end
    return lines
end
---@param task task|keys_tbl
---@return task_keys
function T:task2keys(task)
    local result = task.name
    if task.mode ~= "" then
        result = result .. "(" .. task.mode
    end
    if task.type ~= "" then
        result = result .. (task.mode ~= "" and ":" or "(") .. task.type
    end
    if task.mode ~= "" or task.type ~= "" then
        result = result .. ")"
    end
    table.sort(task.filetypes)
    if #task.filetypes > 0 then
        result = result .. "[" .. table.concat(task.filetypes, ",") .. "]"
    end
    return result
end
---@param str task_keys
---@return keys_tbl
function T:keys2task(str)
    local result = {
        name = "",
        mode = "",
        type = "",
        filetypes = {},
    }
    if not str or str == "" then
        return result
    end
    local working_str = str
    local bracket_start = working_str:match(".*()%[")
    if bracket_start then
        local bracket_content = working_str:match("%[(.*)%]$")
        if bracket_content then
            if bracket_content:match("^[%w#;+%-, ]*$") then
                local parts = {}
                for part in (bracket_content .. ","):gmatch("([^,]*),") do
                    table.insert(parts, part:match("^%s*(.-)%s*$"))
                end
                local has_empty = false
                for _, part in ipairs(parts) do
                    if part == "" then
                        has_empty = true
                        break
                    end
                end
                if #parts == 0 or has_empty then
                    result.name = str
                    return result
                else
                    result.filetypes = parts
                    table.sort(result.filetypes)
                    working_str = working_str:sub(1, bracket_start - 1)
                end
            end
        end
    end
    local paren_start = working_str:match(".*()%(")
    if paren_start then
        local paren_content = working_str:match("%((.*)%)$")
        if paren_content then
            local parts = {}
            for part in (paren_content .. ":"):gmatch("([^:]*):") do
                table.insert(parts, part)
            end
            local has_empty = false
            for _, part in ipairs(parts) do
                if part == "" then
                    has_empty = true
                    break
                end
            end
            if #parts == 0 or has_empty then
                result.name = working_str
                return result
            elseif #parts == 1 then
                local part = parts[1]
                if part == "debug" or part == "release" then
                    result.mode = part
                    working_str = working_str:sub(1, paren_start - 1)
                elseif part == "project" or part == "file" then
                    result.type = part
                    working_str = working_str:sub(1, paren_start - 1)
                else
                    result.name = working_str
                    return result
                end
            elseif #parts == 2 then
                local part1, part2 = parts[1], parts[2]
                local mode_found, type_found = false, false
                if part1 == "debug" or part1 == "release" then
                    result.mode = part1
                    mode_found = true
                elseif part1 == "project" or part1 == "file" then
                    result.type = part1
                    type_found = true
                end
                if part2 == "debug" or part2 == "release" then
                    if not mode_found then
                        result.mode = part2
                        mode_found = true
                    else
                        result.name = working_str
                        result.mode = ""
                        return result
                    end
                elseif part2 == "project" or part2 == "file" then
                    if not type_found then
                        result.type = part2
                        type_found = true
                    else
                        result.name = working_str
                        result.type = ""
                        return result
                    end
                end
                if mode_found and type_found then
                    working_str = working_str:sub(1, paren_start - 1)
                else
                    result.name = working_str
                    result.mode = ""
                    result.type = ""
                    return result
                end
            else
                result.name = working_str
                return result
            end
        end
    end
    result.name = working_str
    return result
end
function T:isutask(task)
    return task and #task == 0 and task.name and task.cmds
end
function T:isutaskset(taskset)
    return taskset and #taskset ~= 0 and taskset.name
end
function T:istask(task)
    return task
        and #task == 0
        and task.name
        and task.cmds
        and task.mode
        and task.type
        and task.filetypes
        and task.opts
end
function T:istaskset(taskset)
    return taskset
        and #taskset ~= 0
        and taskset.name
        and taskset.break_on_err ~= nil
        and taskset.seq ~= nil
        and taskset.field
end
function T:localtask_path()
    return vim.fs.abspath(vim.fs.joinpath(require("utils").get_rootdir(), ".tasks.lua"))
end
---@type task|taskset
local default_build
---@type task|taskset
local default_run
function T:refresh_local()
    self.data.locall = {
        tasks = {},
        tasksets = {},
        str2setmap = {},
        str2taskmap = {},
    }
    local filepath = self:localtask_path()
    if vim.fn.filereadable(filepath) == 1 then
        local ok, result = pcall(dofile, filepath)
        if not ok then
            vim.notify("[task]: load tasks failed: " .. vim.inspect(result), vim.log.levels.INFO)
            return
        end
        for _, it in ipairs(result) do
            if self:isutask(it) then
                local it = self:addtask(it, "locall")
                if it.default_build then
                    default_build = it
                end
                if it.default_run then
                    default_run = it
                end
            elseif self:isutaskset(it) then
                local it = self:addtaskset(it, "locall")
                if it.default_build then
                    default_build = it
                end
                if it.default_run then
                    default_run = it
                end
            end
        end
    end
end

-- stylua: ignore
---@type comp
local comp = {
    order = { "field", "isset", "tasktype", "taskmode" },
    field = function(a, _) return a == "locall" end,
    isset= function(a, _) return a == true end,
    taskmode = function(a, b) return a == "" or b == "release" end,
    tasktype = function(a, b) return a == "" or b == "file" end,
}
---locall>global
---taskset>task
---"">project>file
---"">debug>release
---@param items {tasks:task[],tasksets:taskset[]}|(task|taskset)[]
---@param _comp comp|nil
function T:findmax(items, _comp)
    if items == {} then
        return {}
    end
    _comp = _comp or comp
    local isset = {}
    local list
    if #items ~= 0 then
        for _, it in ipairs(items) do
            if self:istask(it) then
            elseif self:istaskset(it) then
                isset[it] = true
            else
                assert(false)
            end
        end
        list = items
    else
        list = {}
        for _, it in ipairs(items.tasks) do
            list[#list + 1] = it
        end
        for _, it in ipairs(items.tasksets) do
            isset[it] = true
            list[#list + 1] = it
        end
    end

    local gt = function(a, b)
        for _, cur in ipairs(comp.order) do
            if cur == "field" then
                if a.field ~= b.field then
                    return comp.field(a, b)
                end
            elseif cur == "isset" then
                if isset[a] ~= isset[b] then
                    return comp.isset(isset[a], isset[b])
                end
            elseif cur == "tasktype" then
                if a.type ~= b.type then
                    return comp.tasktype(a.type, b.type)
                end
            elseif cur == "taskmode" then
                if a.mode ~= b.mode then
                    return comp.taskmode(a.mode, b.mode)
                end
            end
        end
        return false
    end
    table.sort(list, gt)
    local eq = function(a, b)
        return a.field == b.field and isset[a] == isset[b] and a.type == b.type and a.mode == b.mode
    end
    local last = 1
    for i = 2, #list do
        if eq(list[i], list[i - 1]) then
            last = i
        else
            break
        end
    end
    return { unpack(list, 1, last) }
end
---@param data {[string]:{tasks:task[],tasksets:taskset[]}}
---@param prompt string
---@param callback fun(items:(task|taskset)[]|(task|taskset)|nil)
---@param field_option boolean
---@return nil
---items's type == [] only when field_option==true
function T:select(data, prompt, callback, field_option)
    field_option = field_option or false
    ---@alias field_options {field:string,below:("tasksets"|"tasks"|"all")}
    ---@type (field_options|task|taskset)[]
    local options = {}
    local draw = { 8, 8, 8, 0, 0, colnum = 5 }
    ---@param item task|taskset
    function draw:update(item)
        draw[1] = math.max(draw[1], #item.field)
        draw[3] = math.max(draw[3], #item.name)
        if T:istask(item) then
            draw[4] = math.max(draw[4], #item.mode + #item.type + 1)
            draw[5] =
                math.max(draw[5], #item.filetypes ~= 0 and #table.concat(item.filetypes, ",") or 1)
        end
    end
    function draw:calcute_rownum()
        if self[4] == 0 and self[5] == 0 then
            self.colnum = 3
        else
            self.colnum = 5
        end
    end
    function draw:draw(item)
        local row
        if item.below then
            if self.colnum == 5 then
                row = { item.field, item.below, "", "", "" }
            elseif self.colnum == 3 then
                row = { item.field, item.below, "" }
            end
        elseif T:istask(item) then
            assert(self.colnum == 5)
            row = {
                item.field,
                "task",
                item.name,
                table.concat(
                    { item.type ~= "" and item.type or nil, item.mode ~= "" and item.mode or nil },
                    ","
                ),
                #item.filetypes ~= 0 and table.concat(item.filetypes, ",") or "*",
            }
        elseif T:istaskset(item) then
            row = {
                item.field,
                "taskset",
                item.name,
            }
            if self.colnum == 5 then
                row[#row + 1] = ""
                row[#row + 1] = ""
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
    draw:calcute_rownum()
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
            if choice.below then
                callback(data[choice.field][choice.below])
            else
                callback({ choice })
            end
        else
            callback(choice)
        end
    end)
end
local M = {
    ignore_filetypes = {
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
    },
}
local function get_cur_ft()
    ---@type string|nil
    local ft = vim.bo.filetype or nil
    if vim.list_contains(M.ignore_filetypes, vim.bo.filetype) then
        ft = nil
    end
    if
        vim.api.nvim_get_option_value("buftype", { buf = 0 }) == ""
        and vim.fs.abspath(vim.api.nvim_buf_get_name(0)) == T:localtask_path()
    then
        ft = nil
    end
    return ft
end
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
            and vim.deep_equal(task1.cmds, task2.cmds) --更改cmd重置输入
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
    for i, cmd in ipairs(task.cmds) do
        local ok, result = pcall(replace_in_string, cmd)
        if ok then
            task.cmds[i] = result
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
---@param task task
local run_task = function(task, jobopts)
    local task = vim.deepcopy(task)
    M.macro_replace(task)
    require("tools.term").newtask(
        T:task2keys({ name = task.name, mode = task.mode, type = task.type, filetypes = {} }),
        { cmds = task.cmds, opts = vim.tbl_deep_extend("force", task.opts, jobopts or {}) },
        false,
        true,
        nil,
        "task." .. T:task2keys(task)
    )
end
---@param taskset taskset
local run_taskset = function(taskset)
    --vim.notify("run_taskset" .. vim.inspect(taskset))
    local tasks = {}
    for _, task_property in ipairs(taskset) do
        local task_key = task_property[1]
        local task = T.data.locall.str2taskmap[task_key] or T.data.global.str2taskmap[task_key]
        assert(task ~= nil)
        local task = vim.deepcopy(task)
        M.macro_replace(task)
        ---@cast task task
        tasks[#tasks + 1] = {
            name = T:task2keys({
                name = task.name,
                mode = task.mode,
                type = task.type,
                filetypes = {},
            }),
            jobinfo = {
                cmds = task.cmds,
                opts = task.opts,
            },
            bg = task_property.bg,
            ignore_err = task_property.ignore_err,
        }
    end
    require("tools.term").newtaskset(
        taskset.name,
        tasks,
        taskset.seq,
        taskset.break_on_err,
        false,
        true,
        nil,
        "taskset." .. taskset.name
    )
end
local function taskfilter(tasks, task_composite_keys)
    local eqmap = vim.deepcopy(task_composite_keys)
    eqmap.filetypes = nil
    local ret = list_filter(tasks, eqmap, {
        filetypes = task_composite_keys.filetypes and function(_, item)
            return T:item_valid_on_ft(item, task_composite_keys.filetypes)
        end or nil,
    })
    -- vim.notify("taskfilter ret:" .. vim.inspect(ret))
    return ret
end

M.run_name = function(name, ui_select)
    local fts = { get_cur_ft() }
    if #fts == 0 then
        fts = nil
    end
    local matches = {
        locall = {
            tasks = taskfilter(
                T.data.locall.tasks,
                { name = name, type = M.task_type, mode = M.task_mode, filetypes = fts }
            ),
            tasksets = list_filter(T.data.locall.tasksets, { name = name }),
        },
        global = {
            tasks = taskfilter(
                T.data.global.tasks,
                { name = name, type = M.task_type, mode = M.task_mode, filetypes = fts }
            ),
            tasksets = list_filter(T.data.global.tasksets, { name = name }),
        },
    }
    local matchnum = 0
    matchnum = matchnum + #matches.locall.tasks
    matchnum = matchnum + #matches.locall.tasksets
    matchnum = matchnum + #matches.global.tasks
    matchnum = matchnum + #matches.global.tasksets
    if matchnum == 0 then
        vim.notify("[task]: Task/TaskSet not found: " .. name, vim.log.levels.ERROR)
        return
    end
    local select_and_run = function(items)
        T:select(items, "Select And Run", function(item)
            if item ~= nil then
                if T:istask(item) then
                    run_task(item)
                elseif T:istaskset(item) then
                    run_taskset(item)
                end
            end
        end, false)
    end
    if matchnum ~= 1 and ui_select then
        select_and_run(matches)
    else
        local items = {}
        for _, tbl in pairs(matches) do
            for _, task in ipairs(tbl.tasks) do
                items[#items + 1] = task
            end
            for _, taskset in ipairs(tbl.tasksets) do
                items[#items + 1] = taskset
            end
        end
        local matchitems = T:findmax(items)
        if #matchitems ~= 1 then
            select_and_run(matches)
        else
            if T:istask(matchitems[1]) then
                run_task(matchitems[1])
            else
                run_taskset(matchitems[1])
            end
        end
    end
end
M.runtask = function(composite_keys, jobopts, uselect)
    local matches = {
        locall = {
            tasks = taskfilter(T.data.locall.tasks, composite_keys),
        },
        global = {
            tasks = taskfilter(T.data.global.tasks, composite_keys),
        },
    }
    if #matches == 0 then
        vim.notify("[task]: Task not found: " .. T:task2keys(composite_keys), vim.log.levels.ERROR)
        return
    end
    local select_and_run = function(items)
        T:select(items, "Select Task And Run", function(item)
            if item ~= nil then
                run_task(item, jobopts)
            end
        end, false)
    end
    if #matches ~= 1 and uselect then
        select_and_run(matches)
    else
        matches = T:findmax(matches)
        if #matches ~= 1 then
            select_and_run(matches)
        else
            run_task(matches[1], jobopts)
        end
    end
end
M.runtaskset = function(name, ui_select)
    local l = T.data.locall.str2setmap[name]
    local g = T.data.global.str2setmap[name]
    local matches = {
        locall = { tasksets = { l } },
        global = { tasksets = { g } },
    }
    if not l and not g then
        vim.notify("[task]: TaskSet not found: " .. name, vim.log.levels.ERROR)
        return
    end
    if l and g and ui_select then
        T:select(matches, "Select TaskSet And Run", function(item)
            if item ~= nil then
                run_taskset(item)
            end
        end, false)
    else
        run_taskset(l)
    end
end
M.run_select = function(fts)
    -- log()
    local items = {
        locall = {
            tasks = taskfilter(T.data.locall.tasks, { filetypes = fts }),
            tasksets = T.data.locall.tasksets,
        },
        global = {
            tasks = taskfilter(T.data.global.tasks, { filetypes = fts }),
            tasksets = T.data.global.tasksets,
        },
    }
    T:select(items, "Select And Run", function(item)
        if item then
            if T:istask(item) then
                run_task(item)
            elseif T:istaskset(item) then
                run_taskset(item)
            end
        end
    end, false)
end
M.edittask = function()
    local append_items = function(lines, items)
        local insert_before
        for i = #lines, 1, -1 do
            if lines[i]:match("^%s*return%s+items%s*$") then
                insert_before = i
                break
            end
        end
        if not insert_before then
            vim.notify("[task]: 'return items' not found", vim.log.levels.ERROR)
            return
        else
            for i, line in ipairs(T:items2lines(items)) do
                table.insert(lines, insert_before + i - 1, line)
            end
        end
    end
    local function is_empty_buffer(bufnrr)
        local byte_size = vim.api.nvim_buf_get_offset(bufnrr, vim.api.nvim_buf_line_count(bufnrr))
        return byte_size == 0 or byte_size == 1
    end
    local tmpl = [[
---@class task
---@field name string
---@field cmds string[]
---@field mode? ("debug"|"release"|"") default ""
---@field type? ("project"|"file"|"") default ""
---@field filetypes? string[]|{} default {}
---@field opts? table default opts.cwd="$(VIM_ROOT)"
---@field default_build? boolean
---@field default_run? boolean
---@class taskset
---@field name string
---@field break_on_err? boolean default true
---@field seq? boolean default true
---@field default_build? boolean
---@field default_run? boolean
---@field [integer] {[1]:string,ignore_err?:boolean,bg?:boolean}|string

---@MACRO: $(MACRO_NAME)
---VIM_FILENAME VIM_FILENOEXT VIM_FILEEXT VIM_FILEPATH VIM_PATHNOEXT VIM_RELPATH
---VIM_FILEDIR VIM_DIRNAME
---VIM_ROOT VIM_PRONAME
---@ARG: $(-argname:default)
---@ENV: ${ENVNAME} ${ENVNAME:+ - ? # ## % %% /// //}

---@type (task|taskset)[]
local items = {}
---@param it task|taskset
local function new(it)
    table.insert(items,it)
end
return items
]]
    ---@param args {bufnr:integer,filepath:string}
    local function select_and_write(args)
        assert(args.bufnr ~= nil or args.filepath ~= nil)
        local data =
            vim.tbl_deep_extend("force", T.data, { locall = { tasks = {}, tasksets = {} } })
        T:select(data, "Select To Add", function(items)
            if not items then
                return
            end
            local bufnr = args.bufnr
                or (function()
                    vim.cmd("botright vsplit " .. args.filepath)
                    return vim.api.nvim_get_current_buf()
                end)()
            local lines
            if is_empty_buffer(bufnr) then
                lines = vim.split(tmpl, "[\r\n]")
            else
                lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            end
            append_items(lines, items)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        end, true)
    end
    local filepath = T:localtask_path()
    local bufnr = vim.fn.bufnr(filepath)
    local buf_exists = bufnr ~= -1
    local win_exists = buf_exists and vim.fn.bufwinnr(bufnr) ~= -1
    local is_focused = buf_exists and vim.api.nvim_get_current_buf() == bufnr
    local file_exists = vim.fn.filereadable(filepath) == 1

    if buf_exists and win_exists and not is_focused then
        vim.api.nvim_set_current_win(vim.fn.bufwinnr(bufnr))
    elseif buf_exists and not win_exists and not is_focused then
        vim.cmd("botright vsplit #" .. bufnr)
    elseif buf_exists and win_exists and is_focused then
        select_and_write({ bufnr = bufnr })
    elseif not buf_exists and not file_exists then
        select_and_write({ filepath = filepath })
    elseif not buf_exists and file_exists then
        vim.cmd("botright vsplit " .. filepath)
    end
end

---new file:  global + template
---edit file: global + template
---run : global + locall

---@type ("debug"|"release"|""|nil)
M.task_mode = nil
---@type ("project"|"file"|""|nil)
M.task_type = nil
function M.switch_taskmode()
    local display
    if M.task_mode == nil then
        M.task_mode = "debug"
        display = "debug"
    elseif M.task_mode == "debug" then
        M.task_mode = "release"
        display = "release"
    elseif M.task_mode == "release" then
        M.task_mode = ""
        display = "common"
    elseif M.task_mode == "" then
        M.task_mode = nil
        display = "auto(common>debug>release)"
    end
    require("utils").vim_echo(("TaskMode: %s"):format(display))
end
function M.switch_tasktype()
    local display
    if M.task_type == nil then
        M.task_type = "project"
        display = "project"
    elseif M.task_type == "project" then
        M.task_type = "file"
        display = "file"
    elseif M.task_type == "file" then
        M.task_type = ""
        display = "common"
    elseif M.task_type == "" then
        M.task_type = nil
        display = "auto(common>project>file)"
    end
    require("utils").vim_echo(("TaskType: %s"):format(display))
end
M.setup = function()
    for field, tbl in pairs(config) do
        for _, task in ipairs(tbl.tasks) do
            T:addtask(task, field)
        end
        for _, taskset in ipairs(tbl.tasksets) do
            T:addtaskset(taskset, field)
        end
    end
    -- log(T.data)
    local map = require("utils").map
    map("n", "<F9>", function()
        T:refresh_local()
        if default_build then
            if T:istask(default_build) then
                run_task(default_build)
            elseif T:istaskset(default_build) then
                run_taskset(default_build)
            end
        else
            M.run_name("build", true)
        end
    end, { desc = "Build" })
    map("n", "<F10>", function()
        T:refresh_local()
        if default_run then
            if T:istask(default_run) then
                run_task(default_run)
            elseif T:istaskset(default_run) then
                run_taskset(default_run)
            end
        else
            M.run_name("run", true)
        end
    end, { desc = "Run" })
    map("n", "<F11>", M.switch_taskmode, { desc = "TaskToggleDebugRelease" })
    map(
        "n",
        vim.g.is_win and "<S-F11>" or "<F23>",
        M.switch_tasktype,
        { desc = "TaskToggleProjFile" }
    )
    map("n", "<F12>", function()
        T:refresh_local()
        M.run_select({ get_cur_ft() })
    end, { desc = "TaskSelectAndRun" })
    map("n", CC.is_win and "<S-F12>" or "<F24>", function()
        M.edittask()
    end, { desc = "TaskEdit" })
end
return M
