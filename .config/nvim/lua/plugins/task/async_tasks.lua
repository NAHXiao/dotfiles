-- createtask()
return {
    "skywind3000/asynctasks.vim",
    version = "*",
    keys = {
        { "<F6>", "<cmd>AsyncTask build<cr>", desc = "build" },
        { "<F7>", "<cmd>AsyncTask run<cr>", desc = "run" },
        { "<F8>", "<cmd>AsyncTask run_input<cr>", desc = "run_input" },
        {
            "<leader>fp",
            "<cmd>TaskListAsync<cr>",
            desc = "find project tasks",
            noremap = true,
        },
    },
    commander = {
        {
            cmd = function()
                local content = [[
#可替换宏/环境变量
#$(VIM_FILEPATH)  - 当前 buffer 的文件名全路径
#$(VIM_FILENAME)  - 当前 buffer 的文件名（没有前面的路径）
#$(VIM_FILEDIR)   - 当前 buffer 的文件所在路径
#$(VIM_FILEEXT)   - 当前 buffer 的扩展名
#$(VIM_FILENOEXT) - 当前 buffer 的主文件名（没有前面路径和后面扩展名）
#$(VIM_PATHNOEXT) - 带路径的主文件名（$VIM_FILEPATH 去掉扩展名）
#$(VIM_CWD)       - 当前 Vim 目录
#$(VIM_RELDIR)    - 相对于当前路径的文件名
#$(VIM_RELNAME)   - 相对于当前路径的文件路径
#$(VIM_ROOT)      - 当前 buffer 的项目根目录
#$(VIM_CWORD)     - 光标下的单词
#$(VIM_CFILE)     - 光标下的文件名
#$(VIM_GUI)       - 是否在 GUI 下面运行？
#$(VIM_VERSION)   - Vim 版本号
#$(VIM_COLUMNS)   - 当前屏幕宽度
#$(VIM_LINES)     - 当前屏幕高度
#$(VIM_SVRNAME)   - v:servername 的值
#$(VIM_PRONAME)   - 项目名称（projroot 目录的名称）
#$(VIM_DIRNAME)   - 当前目录的名称

#e.g. 

#default build task
#[build:debug]
# ForAllFile
#command=echo "$(VIM_FILEPATH)"
#ForOnlyC
#command:c=gcc -O3 --std=c23 --debug "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" -lm

#default run task
#[run]
#command="$(VIM_FILEPATH)"
]]
                local taskfile = vim.fn.fnamemodify(vim.fs.joinpath(vim.g.projroot, ".tasks"),":p")
                vim.fn.mkdir(vim.fn.fnamemodify(taskfile, ":h"), "p")
                if not vim.uv.fs_stat(taskfile) then
                    local file = io.open(taskfile, "a")
                    if not file then
                        vim.notify("Failed to open or create task file", vim.log.levels.ERROR)
                        return
                    end
                    file:write(content)
                    file:close()
                end
                local wins = vim.api.nvim_list_wins()
                for _, win in ipairs(wins) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    local buf_path = vim.api.nvim_buf_get_name(buf)
                    if vim.fn.fnamemodify(buf_path, ":p") == taskfile then
                        vim.api.nvim_set_current_win(win)
                        return
                    end
                end
                vim.cmd("vsplit " .. vim.fn.fnameescape(taskfile))
            end,
            desc = "Create Task",
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
        local default_asynctasks_extra_config = {
            vim.fn.stdpath("config") .. "/lua/plugins/task/asynctasks.ini",
        }
        local default_asynctasks_environ = {}

        -- NOTE:VSCODE task.json 支持,仅在TaskListAsync使用

        -- ret{{taskname:"",cmd:""}}
        ------------------VSCODE TASK.JSON-------------------
        local function convert_taskjson2cmd(filepath)
            local map_notwin = {
                ["${cwd}"] = "$(VIM_CWD)",
                ["${fileBasenameNoExtension}"] = "$(VIM_FILENOEXT)",
                ["${fileBasename}"] = "$(VIM_FILENAME)",
                ["${fileDirname}"] = "$(VIM_FILEDIR)",
                ["${fileExtname}"] = "$(VIM_FILEEXT)",
                ["${fileWorkspaceFolder}"] = "$(VIM_ROOT)",
                ["${file}"] = "$(VIM_FILEPATH)",
                ["${lineNumber}"] = "$VIM_VSC_lineNumber",
                ["${pathSeparator}"] = "$VIM_VSC_pathSeparator",
                ["${relativeFileDirname}"] = "$VIM_VSC_relativeFileDirname",
                ["${relativeFile}"] = "$VIM_VSC_relativeFile",
                ["${selectedText}"] = "$VIM_VSC_selectedText",
                ["${userHome}"] = "$VIM_VSC_Home",
                ["${workspaceFolderBasename}"] = "$(VIM_PRONAME)",
                ["${workspaceFolder}"] = "$(VIM_ROOT)",
            }
            local map_win = vim.deepcopy(map_notwin)
            map_win["${lineNumber}"] = "%VIM_VSC_lineNumber%"
            map_win["${pathSeparator}"] = "%VIM_VSC_pathSeparator%"
            map_win["${relativeFileDirname}"] = "%VIM_VSC_relativeFileDirname%"
            map_win["${relativeFile}"] = "%VIM_VSC_relativeFile%"
            map_win["${selectedText}"] = "%VIM_VSC_selectedText%"
            map_win["${userHome}"] = "%VIM_VSC_Home%"
            local map = vim.g.is_win and map_win or map_notwin
            local file, err = io.open(filepath, "r")
            if not file then
                print("Error opening file: " .. (err or "Unknown error"))
                return {}
            end
            local content = file:read("*all")
            file:close()
            content = content:gsub("/%*.-*%/", "")
            content = content:gsub("//.-\n", "\n")
            content = content:gsub(",(%s*})", "%1")
            content = content:gsub(",(%s*])", "%1")
            local status, tasks_data = pcall(vim.fn.json_decode, content)
            if not status then
                print("asynctasks.lua: Error parsing JSON: " .. vim.inspect(tasks_data))
                return {}
            end
            if not tasks_data.tasks or type(tasks_data.tasks) ~= "table" then
                print("asynctasks.lua: No tasks found in the file")
                return {}
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
                        for vsc_var, vim_var in pairs(map) do
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
        end
        local function write_tasks_to_file(tasks)
            local cache_dir = vim.fn.stdpath("cache")
            local task_dir = cache_dir .. "/asynctask"
            if vim.fn.isdirectory(task_dir) == 0 then
                vim.fn.mkdir(task_dir, "p")
            end
            local timestamp = os.time()
            local random_part = math.random(1000, 9999)
            local filename =
                string.format("%s/vsc_tasks_%d_%d.ini", task_dir, timestamp, random_part)
            while vim.fn.filereadable(filename) == 1 do
                random_part = math.random(1000, 9999)
                filename = string.format("%s/vsc_tasks_%d_%d.ini", task_dir, timestamp, random_part)
            end
            local content = ""
            for _, task in ipairs(tasks) do
                content = content .. string.format("[vsc_%s]\n", task.taskname)
                content = content .. string.format("command=%s\n", task.cmd)
                content = content .. "output=terminal\n"
                content = content .. "pos=bottom\n"
                content = content .. "cwd=$(VIM_ROOT)\n"
                content = content .. "save=2\n\n"
            end
            local file, err = io.open(filename, "w")
            if not file then
                vim.notify("asynctasks.lua: Error creating file: " .. (err or "Unknown error"))
                return nil
            end
            file:write(content)
            file:close()
            return filename
        end

        local envfunc_runtime = {
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
        local update_for_buf = function()
            vim.g.asynctasks_environ = default_asynctasks_environ
            vim.g.asynctasks_extra_config = default_asynctasks_extra_config

            local filepath = (vim.b.projroot or vim.g.projroot) .. "/.vscode/tasks.json"
            local valid = vim.fn.filereadable(filepath)
            if not valid then
                return
            end
            -- local buftype = vim.bo.buftype
            -- local name = vim.api.nvim_buf_get_name(0)
            -- if buftype ~= "" or name == "" then
            --     return
            -- end

            local env_runtime = {}
            for k, v in pairs(envfunc_runtime) do
                env_runtime[k] = v()
            end
            vim.g.asynctasks_environ =
                vim.tbl_deep_extend("force", vim.g.asynctasks_environ, env_runtime)

            local vsc_tasks = convert_taskjson2cmd(filepath)
            -- vim.notify(vim.inspect(vsc_tasks))
            if #vsc_tasks == 0 then
                return
            end
            local filename = write_tasks_to_file(vsc_tasks)
            if filename == nil then
                return
            end
            -- vim.notify(vim.inspect(filename))
            local new_config = vim.deepcopy(default_asynctasks_extra_config)
            table.insert(new_config, filename)
            vim.g.asynctasks_extra_config = new_config
            -- vim.notify(vim.inspect(vim.g.asynctasks_extra_config))
        end

        vim.g.asynctasks_extra_config = default_asynctasks_extra_config
        vim.g.asynctasks_term_rows = 10
        vim.g.asynctasks_confirm = 0

        -- Finder
        do
            local actions = require("telescope.actions")
            local finders = require("telescope.finders")
            local pickers = require("telescope.pickers")
            local sorters = require("telescope.sorters")
            local state = require("telescope.actions.state")
            Findtasks = function(opts)
                update_for_buf()
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
    end,
}
