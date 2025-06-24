vim.g.asynctasks_config = "auto" --CUSTOM

local default_asynctasks_extra_config = {
    vim.fn.stdpath("config") .. "/lua/plugins/task/asynctasks.ini",
}

local default_asynctasks_environ = {}
------------------VSCODE TASK.JSON-------------------
local function wrap_env(env)
    if vim.g.is_win then
        return "%" .. env .. "%"
    else
        return "$" .. env
    end
end
local env_map = {
    ["${cwd}"] = "$(VIM_CWD)",
    ["${fileBasenameNoExtension}"] = "$(VIM_FILENOEXT)",
    ["${fileBasename}"] = "$(VIM_FILENAME)",
    ["${fileDirname}"] = "$(VIM_FILEDIR)",
    ["${fileExtname}"] = "$(VIM_FILEEXT)",
    ["${fileWorkspaceFolder}"] = "$(VIM_ROOT)",
    ["${file}"] = "$(VIM_FILEPATH)",
    ["${workspaceFolderBasename}"] = "$(VIM_PRONAME)",
    ["${workspaceFolder}"] = "$(VIM_ROOT)",

    ["${lineNumber}"] = wrap_env("VIM_VSC_lineNumber"),
    ["${pathSeparator}"] = wrap_env("VIM_VSC_pathSeparator"),
    ["${relativeFileDirname}"] = wrap_env("VIM_VSC_relativeFileDirname"),
    ["${relativeFile}"] = wrap_env("VIM_VSC_relativeFile"),
    ["${selectedText}"] = wrap_env("VIM_VSC_selectedText"),
    ["${userHome}"] = wrap_env("VIM_VSC_Home"),
}
local env_map_func = {
    VIM_VSC_lineNumber = function()
        return vim.fn.line(".")
    end,
    VIM_VSC_pathSeparator = function()
        return vim.g.is_win and "\\" or "/"
    end,
    VIM_VSC_relativeFileDirname = function()
        local filepath = vim.api.nvim_buf_get_name(0)
        if vim.version.cmp(vim.version(), { 0, 11, 0 }) >= 0 then
            return vim.fn.fnamemodify(
                vim.fs.relpath(filepath, (vim.b.projroot or vim.g.projroot)),
                ":h"
            )
        end
        return vim.fn.fnamemodify(filepath, ":h") -- FIXME:
    end,
    VIM_VSC_relativeFile = function()
        local filepath = vim.api.nvim_buf_get_name(0)
        if vim.version.cmp(vim.version(), { 0, 11, 0 }) >= 0 then
            return vim.fs.relpath(filepath, (vim.b.projroot or vim.g.projroot))
        end
        return filepath -- FIXME:
    end,
    VIM_VSC_selectedText = function()
        local mode = vim.fn.mode()
        if mode == "v" or mode == "V" or mode == "\22" then -- \22 是 CTRL-V 的ASCII码
            local old_reg = vim.fn.getreg('"')
            local old_regtype = vim.fn.getregtype('"')
            vim.cmd('normal! "xy')
            local selected_text = vim.fn.getreg("x")
            vim.fn.setreg('"', old_reg, old_regtype)
            return selected_text
        else
            return ""
        end
    end,
    VIM_VSC_Home = function()
        return vim.loop.os_homedir()
    end,
}

local function convert_taskjson2cmd(filepath)
    if vim.fn.filereadable(filepath) == 1 then
        local content = table.concat(vim.fn.readfile(filepath) or {}, "\n")
        content = content:gsub("/%*.-*%/", "") --/**/
        content = content:gsub("//.-\n", "\n") --//
        content = content:gsub(",(%s*})", "%1") --{{},}
        content = content:gsub(",(%s*])", "%1") --{[],}
        local status, tasks_data = pcall(vim.fn.json_decode, content)
        if not status then
            vim.notify("Error parsing " .. filepath .. ": " .. tasks_data)
            return
        end
        if
            not tasks_data
            or not tasks_data.tasks
            or type(tasks_data.tasks) ~= "table"
            or #tasks_data.tasks == 0
        then
            vim.notify("No tasks found in " .. filepath)
            return
        end

        local result = {}
        for _, task in ipairs(tasks_data.tasks) do
            if task.label and (task.type == "shell" or task.type == "process") then
                local cmd = ""
                if task.command then
                    cmd = task.command
                    if task.args and #task.args > 0 then
                        for _, arg in ipairs(task.args) do
                            cmd = cmd .. " " .. arg
                        end
                    end
                    for vsc_var, vim_var in pairs(env_map) do
                        cmd = cmd:gsub(vim.pesc(vsc_var), vim_var)
                    end
                    table.insert(result, {
                        taskname = task.label,
                        cmd = cmd,
                    })
                end
            end
        end
        return result
    else
        return
    end
end

local function write_tasks_to_file(tasks)
    local task_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "asynctasks")
    if vim.fn.isdirectory(task_dir) == 0 then
        vim.fn.mkdir(task_dir, "p")
    end

    local timestamp = os.time()
    local random_part = math.random(1000, 9999)
    local filename = string.format("%s/vsc_tasks_%d_%d.ini", task_dir, timestamp, random_part)
    while vim.fn.filereadable(filename) == 1 do
        random_part = math.random(1000, 9999)
        filename = string.format("%s/vsc_tasks_%d_%d.ini", task_dir, timestamp, random_part)
    end

    local content = {}
    for _, task in ipairs(tasks) do
        table.insert(content, string.format("[vsc_%s]", task.taskname))
        table.insert(content, string.format("command=%s", task.cmd))
        table.insert(content, "cwd=$(VIM_ROOT)")
        table.insert(content, "output=terminal")
        table.insert(content, "pos=bottom")
        table.insert(content, "save=2")
    end
    vim.fn.writefile(content, filename)
    return filename
end

local update_vsctask_for_buf = function()
    vim.g.asynctasks_environ = default_asynctasks_environ
    vim.g.asynctasks_extra_config = default_asynctasks_extra_config

    local filepath = vim.fs.joinpath((vim.b.projroot or vim.g.projroot), ".vscode", "tasks.json")
    local valid = vim.fn.filereadable(filepath) == 1
    local vsc_tasks = convert_taskjson2cmd(filepath) or {}
    local filename = write_tasks_to_file(vsc_tasks)
    if valid == 1 and #vsc_tasks ~= 0 and filename then
        local env_map = {}
        for k, v in pairs(env_map_func) do
            env_map[k] = v()
        end
        vim.g.asynctasks_environ = vim.tbl_deep_extend("force", vim.g.asynctasks_environ, env_map)
        local new_config = vim.deepcopy(default_asynctasks_extra_config)
        table.insert(new_config, filename)
        vim.g.asynctasks_extra_config = new_config
    end
end
local function setup_telescope()
    do
        local actions = require("telescope.actions")
        local finders = require("telescope.finders")
        local pickers = require("telescope.pickers")
        local sorters = require("telescope.sorters")
        local state = require("telescope.actions.state")
        Findtasks = function(opts)
            update_vsctask_for_buf()
            opts = opts or {}
            local tasks = vim.api.nvim_call_function("asynctasks#source", { 50 })
            if vim.tbl_isempty(tasks) then
                return
            end

            local tasks_formatted = {}

            for i = 1, #tasks do
                local current_task = table.concat(tasks[i], " | ")
                table.insert(tasks_formatted, current_task)
            end

            pickers
                .new(opts, {
                    prompt_title = "Tasks",
                    finder = finders.new_table({
                        results = tasks_formatted,
                    }),
                    sorter = sorters.get_generic_fuzzy_sorter(),
                    attach_mappings = function(prompt_bufnr, map)
                        local start_task = function()
                            local selection = state.get_selected_entry(prompt_bufnr)
                            actions.close(prompt_bufnr)

                            local task_name = tasks[selection.index][1]

                            local cmd = table.concat({ "AsyncTask", task_name }, " ")

                            vim.cmd(cmd)
                        end

                        map("i", "<CR>", start_task)
                        map("n", "<CR>", start_task)

                        return true
                    end,
                })
                :find()
        end
        --注册TaskListAsync
        vim.api.nvim_create_user_command("TaskListAsync", Findtasks, {
            desc = "Find project tasks",
        })
    end
end

return {
    "skywind3000/asynctasks.vim",
    version = "*",
    keys = {
        {
            "<F9>",
            function()
                if vim.g.asynctasks_config == "auto" then -- project-build -> file-build
                    local tasks = vim.api.nvim_call_function("asynctasks#source", { 50 })
                    local taskname = (function()
                        local file_build = false
                        local trim = require("utils").trim
                        for _, task in ipairs(tasks) do
                            local name = trim(task[1])
                            if name == "project-build" then
                                return "project-build"
                            end
                            if name == "file-build" then
                                file_build = true
                            end
                        end
                        if file_build == true then
                            return "file-build"
                        end
                    end)()
                    if taskname then
                        vim.cmd("AsyncTask " .. taskname)
                    else
                        vim.notify(
                            "Error: not find tasks [project-build,file-build]",
                            vim.log.levels.ERROR
                        )
                    end
                elseif vim.g.asynctasks_config == "project" then
                    vim.cmd("AsyncTask " .. "project-build")
                elseif vim.g.asynctasks_config == "file" then
                    vim.cmd("AsyncTask " .. "file-build")
                end
            end,
            desc = "build",
        },
        {
            "<F10>",
            function()
                if vim.g.asynctasks_config == "auto" then -- project-run -> file-run
                    local tasks = vim.api.nvim_call_function("asynctasks#source", { 50 })
                    local taskname = (function()
                        local file_run = false
                        local trim = require("utils").trim
                        for _, task in ipairs(tasks) do
                            local name = trim(task[1])
                            if name == "project-run" then
                                return "project-run"
                            end
                            if name == "file-run" then
                                file_run = true
                            end
                        end
                        if file_run == true then
                            return "file-run"
                        end
                    end)()
                    if taskname then
                        vim.cmd("AsyncTask " .. taskname)
                    else
                        vim.notify(
                            "Error: not find tasks [project-run,file-run]",
                            vim.log.levels.ERROR
                        )
                    end
                elseif vim.g.asynctasks_config == "project" then
                    vim.cmd("AsyncTask " .. "project-run")
                elseif vim.g.asynctasks_config == "file" then
                    vim.cmd("AsyncTask " .. "file-run")
                end
            end,
            desc = "run",
        },
        {
            "<F11>",
            function()
                vim.cmd(
                    "AsyncTaskProfile "
                        .. (vim.g.asynctasks_profile == "debug" and "release" or "debug")
                )
            end,
            desc = "toggle profile(release/debug)",
        },
        {
            "<F23>",
            function()
                local old = vim.g.asynctasks_config
                vim.g.asynctasks_config = (function(o)
                    if o == "auto" then
                        return "project"
                    elseif o == "project" then
                        return "file"
                    else
                        return "auto"
                    end
                end)(old)
                vim.cmd(string.format(
                    [[
				echohl Number
				echo "Current config: %s" 
				echohl None
                ]],
                    vim.g.asynctasks_config
                ))
            end,
            desc = "toggle profile(project/file/auto) <Shift-F11>",
        },
        {
            "<F12>",
            "<cmd>TaskListAsync<cr>",
            desc = "select project tasks",
            noremap = true,
        },
    },
    cmd = {
        "AsyncRun",
        "AsyncStop",
        "AsyncTask",
        "AsyncReset",
        "AsyncTaskEdit",
        "AsyncTaskLast",
        "AsyncTaskList",
        "AsyncTaskMacro",
        "AsyncTaskEnviron",
        "AsyncTaskProfile",

        "TaskListAsync",
    },
    lazy = true,
    dependencies = {
        "skywind3000/asyncrun.vim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        vim.g.asynctasks_extra_config = default_asynctasks_extra_config
        vim.g.asynctasks_term_rows = 10
        vim.g.asynctasks_term_pos = 'bottom'
        vim.g.asynctasks_confirm = 0
        vim.g.asynctasks_template = vim.fn.stdpath("config")
            .. "/lua/plugins/task/asynctask_template.ini"
        vim.g.asynctasks_template_ask = 1
        vim.g.asynctasks_term_reuse = 1
        vim.g.asynctasks_term_focus = 0
        vim.g.asynctasks_term_hidden = 1
        vim.g.asynctasks_term_listed = 0
        setup_telescope()
    end,
}
