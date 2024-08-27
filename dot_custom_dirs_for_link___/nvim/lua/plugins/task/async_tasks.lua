return {
    "skywind3000/asynctasks.vim",
    version = "*",
    keys = {
        { "<F6>", "<cmd>AsyncTask build<cr>",     desc = "build" },
        { "<F7>", "<cmd>AsyncTask run<cr>",       desc = "run" },
        { "<F8>", "<cmd>AsyncTask run_input<cr>", desc = "run_input" },
        {
            "<leader>fp",
            ":lua Findtasks()<cr>",
            desc = "find project tasks",
            noremap = true
        },
        {
            "<C-p>",
            ":lua Findtasks()<cr>",
            desc = "find project tasks",
            noremap = true
        },
    },
    lazy = true,
    dependencies = {
        "skywind3000/asyncrun.vim",
    },
    config = function()
        vim.g.asynctasks_extra_config = {
            vim.fn.stdpath("config") .. "/lua/plugins/task/asynctasks.ini",
        }
        vim.g.asynctasks_term_rows = 10
        vim.g.asynctasks_confirm = 0

        --自定义pos(runner) wt=WindowsTerminal
        local function run_wt(opts)
            local process = function(str)
                str = str:gsub('&', '"&"')
                while str:find('&""&') do
                    str = str:gsub('&""&', '&&')
                end
                str = str:gsub('|', '"|"')
                while str:find('|""|') do
                    str = str:gsub('|""|', '||')
                end
                return str
            end
            local cwd = vim.fn.getcwd()
            if vim.g.is_win then
                vim.fn.system(
                    'wt.exe -d ' .. cwd ..
                    ' cmd.exe /K \' ' ..
                    opts.cmd .. '&echo. & pause & exit \''
                )
            elseif vim.g.is_wsl then
                local cachedir = vim.fn.stdpath('cache') .. '/asynctask'
                if vim.fn.isdirectory(cachedir) == 0 then
                    if 0 == vim.fn.mkdir(cachedir, 'p') then
                        -- DebugToFile("mkdir" .. cachedir .. " failed")
                        return
                    end
                end
                local f = io.popen("mktemp -p " .. cachedir .. " asynctask-XXXXXX")
                if f == nil then
                    -- DebugToFile("mktemp failed")
                    return
                end
                local file = f:read("*a")
                file = file:gsub("\n", "")
                f:close()
                -- DebugToFile("tmp file: " .. file)
                local tmp = io.open(file, 'w')
                if tmp == nil then
                    -- DebugToFile("open " .. file .. "failed")
                    return
                end
                tmp:write("cd " .. cwd .. "||exit 1;" .. "\n"
                    .. opts.cmd .. "\n"
                    -- .. [[printf %s%s%s $([ $? == 0 ] && echo -n '\033[32m' || echo -n '\033[31m') "[progess return $?]" $'\033[0m']].."\n"
                    .. "CODE=$?\n"
                    .. [[echo -ne "$([ $CODE == 0 ] && echo -n '\033[32m' || echo -n '\033[31m')[progess return $CODE]\033[0m"]]
                    .. "\n"
                    .. "sleep 0.05\n" --避免颜色未恢复就退出
                    .. "exit 255\n"   --保证wt出现[已退出进程，代码为 255 (0x000000ff)] 现在可以使用Ctrl+D关闭此终端，或按 Enter 重新启动。
                )
                tmp:close()
                local commandline =
                    'PATH=$PATH:$WINPATH wt.exe wsl bash ' .. file
                -- DebugToFile(commandline)
                vim.fn.system(commandline)
            elseif vim.g.is_nix then
                vim.notify('fallback to asyncrun', 'warn')
                vim.cmd('AsyncRun -mode=term -save=2 -pos=bottom' ..
                    ' -rows=' .. tostring(vim.g.asynctasks_term_rows) ..
                    ' ' .. opts.cmd)
            end
        end
        vim.g.asyncrun_runner = vim.g.asyncrun_runner or {}
        vim.g.asyncrun_runner = vim.tbl_extend('force', vim.g.asyncrun_runner or {}, { wt = run_wt })

        --自定义pos(runner) togterm=toggleterm.nvim NOTE:效果不咋地
        local function run_togterm(opts)
            local cwd = vim.fn.getcwd()
            vim.cmd('1TermExec cmd=\'' .. opts.cmd .. '\' dir=\'' .. cwd .. '\'\n')
        end
        vim.g.asyncrun_runner = vim.g.asyncrun_runner or {}
        vim.g.asyncrun_runner = vim.tbl_extend('force', vim.g.asyncrun_runner or {}, { togterm = run_togterm })



        -- Finder
        do
            local actions = require('telescope.actions')
            local finders = require('telescope.finders')
            local pickers = require('telescope.pickers')
            local sorters = require('telescope.sorters')
            local state = require('telescope.actions.state')

            --
            -- require('telescope').register_extension {
            --     exports = {
            Findtasks = function(opts)
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

                pickers.new(opts, {
                    prompt_title    = 'Tasks',
                    finder          = finders.new_table {
                        results = tasks_formatted
                    },
                    sorter          = sorters.get_generic_fuzzy_sorter(),
                    attach_mappings = function(prompt_bufnr, map)
                        local start_task = function()
                            local selection = state.get_selected_entry(prompt_bufnr)
                            actions.close(prompt_bufnr)

                            local task_name = tasks[selection.index][1]

                            local cmd = table.concat({ "AsyncTask", task_name }, " ")

                            vim.cmd(cmd)
                        end

                        map('i', '<CR>', start_task)
                        map('n', '<CR>', start_task)

                        return true
                    end
                }):find()
            end
            --     }
            -- }
        end
    end,
}
