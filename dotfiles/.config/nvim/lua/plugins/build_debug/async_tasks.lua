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
    },
    lazy = true,
    dependencies = {
        "skywind3000/asyncrun.vim",
    },
    config = function()
        vim.g.asynctasks_extra_config = {
            vim.fn.stdpath("config") .. "/lua/plugins/build_debug/asynctasks.ini",
        }
        vim.g.asynctasks_term_rows = 10
        vim.g.asynctasks_confirm = 0

        --自定义pos(runner) wt=WindowsTerminal
        local function run_wt(opts)
            local cwd = vim.fn.getcwd()
            local osname = vim.loop.os_uname().sysname;
            if osname == 'Windows_NT' then
                vim.fn.system(
                    'wt.exe -d ' .. cwd ..
                    ' cmd.exe /K \'' ..
                    opts.cmd .. '&echo. & pause & exit \''
                )
            elseif osname == "Linux" then
                -- 'wt.exe -d $(' .. 'wslpath -w ' .. cwd .. ')' ..
                local cmd =
                    'wt.exe ' .. 'cmd.exe /K \'' ..
                    'wsl.exe --cd ' .. cwd .. ' ' ..
                    opts.cmd .. '& echo. & pause & exit \''
                vim.fn.system(cmd)
            end
        end
        vim.g.asyncrun_runner = vim.g.asyncrun_runner or {}
        vim.g.asyncrun_runner = vim.tbl_extend('force', vim.g.asyncrun_runner or {}, { wt = run_wt })

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
