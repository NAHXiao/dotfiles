-- local _uiselect = vim.ui.select -- For Telescope , No used
function vim.ui.select(...)
    if not Is_plugin_loaded("telescope.nvim") then
        -- vim.ui.select = _uiselect
        require("lazy").load({ plugins = "telescope.nvim" })
        return vim.ui.select(...)
    end
end

local find_command = (function()
    if 1 == vim.fn.executable("rg") then
        return { "rg", "--files", "--color", "never", "--follow" }
    elseif 1 == vim.fn.executable("fd") then
        return { "fd", "--type", "f", "--color", "never", "--follow" }
    elseif 1 == vim.fn.executable("fdfind") then
        return { "fdfind", "--type", "f", "--color", "never", "--follow" }
    elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
        return { "find", ".", "-type", "f" }
    elseif 1 == vim.fn.executable("where") then
        return { "where", "/r", ".", "*" }
    end
end)()

local _latest_func_map = {}
function TeleMultiplexSearch(func, funcopts, prompt_title, ctxfunc)
    local ctx = ctxfunc and ctxfunc() or nil
    local same_opt_and_ctx = _latest_func_map[func]
        and vim.deep_equal(_latest_func_map[func].funcopts, funcopts)
        and vim.deep_equal(_latest_func_map[func].ctx, ctx)
    if not same_opt_and_ctx then
        _latest_func_map[func] = { funcopts = vim.deepcopy(funcopts), ctx = ctx }
        return func(vim.deepcopy(funcopts))
    end
    local latestindex = (function(query)
        local cached_pickers = require("telescope.state").get_global_key("cached_pickers")
        if cached_pickers == nil or vim.tbl_isempty(cached_pickers) then
            return 0
        end
        local ret = math.huge
        for i, v in ipairs(cached_pickers) do
            if v.prompt_title == query then
                ret = math.min(ret, i)
            end
        end
        if ret == math.huge then
            return 0
        end
        return ret
    end)(prompt_title)
    if latestindex == 0 then
        _latest_func_map[func] = { funcopts = vim.deepcopy(funcopts), ctx = ctx }
        return func(vim.deepcopy(funcopts))
    end
    require("telescope.builtin").resume({ cache_index = latestindex })
end

-- NOTE: telescope normal模式 `?` => show key map
return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    lazy = true,
    dependencies = {
        { "nvim-lua/popup.nvim" },
        { "nvim-lua/plenary.nvim" },
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            -- build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
            build = "make",
        },
        { "nvim-telescope/telescope-ui-select.nvim" },
    },
    -- NOTE: 仅lsp相关/文件相关复用
    keys = {
        {
            "<leader>ff",
            function()
                TeleMultiplexSearch(
                    require("telescope.builtin").find_files,
                    {
                        find_command = find_command,
                        no_ignore = true,
                        hidden = true,
                    },
                    "Find Files",
                    function() -- cwd
                        return vim.fn.getcwd()
                    end
                )
            end,
            desc = "Find files",
        },
        {
            "<leader>fw",
            function()
                TeleMultiplexSearch(
                    require("telescope.builtin").live_grep,
                    {
                        additional_args = { "--follow" },
                    },
                    "Live Grep",
                    function() -- cwd
                        return vim.fn.getcwd()
                    end
                )
            end,
            desc = "Find word",
        },
        {
            "<leader>fow",
            function()
                TeleMultiplexSearch(
                    require("telescope.builtin").live_grep,
                    {
                        additional_args = { "--follow" },
                        grep_open_files = true,
                    },
                    "Live Grep",
                    function() -- opened buf files
                        local bufs = vim.api.nvim_list_bufs()
                        local file_bufs = {}
                        for _, buf in ipairs(bufs) do
                            if
                                vim.api.nvim_buf_is_loaded(buf)
                                and vim.api.nvim_buf_get_option(buf, "buftype") == ""
                            then
                                local name = vim.api.nvim_buf_get_name(buf)
                                if name ~= "" then
                                    table.insert(file_bufs, name)
                                end
                            end
                        end
                        return file_bufs
                    end
                )
            end,
            desc = "Find word in open files",
        },
        {
            "<leader>fb",

            function()
                TeleMultiplexSearch(
                    require("telescope.builtin").buffers,
                    {},
                    "Buffers",
                    vim.api.nvim_list_bufs
                )
            end,
            desc = "Find buffers",
        },
        {
            "<leader>fd",
            function()
                TeleMultiplexSearch(
                    require("telescope.builtin").diagnostics,
                    {},
                    "Workspace Diagnostics",
                    function() -- projroot
                        return vim.b.projroot
                    end
                )
            end,
            desc = "Find diagnostics in project root",
        },
        {
            "<leader>fr",

            function()
                TeleMultiplexSearch(
                    require("telescope.builtin").lsp_references,
                    {},
                    "LSP References",
                    function() -- word
                        local cursor0 = vim.api.nvim_win_get_cursor(0)
                        vim.cmd.normal("lb")
                        local cursor = vim.api.nvim_win_get_cursor(0)
                        local word = vim.call("expand", "<cword>")
                        vim.api.nvim_win_set_cursor(0, cursor0)
                        return { cursor, word }
                    end
                )
            end,
            desc = "Find references of word under cursor",
        },
        {
            "<leader>fi",
            function()
                TeleMultiplexSearch(
                    require("telescope.builtin").lsp_implementations,
                    {},
                    "FIXME",
                    function() -- word
                        local cursor0 = vim.api.nvim_win_get_cursor(0)
                        vim.cmd.normal("li")
                        local cursor = vim.api.nvim_win_get_cursor(0)
                        local word = vim.call("expand", "<cword>")
                        vim.api.nvim_win_set_cursor(0, cursor0)
                        return { cursor, word }
                    end
                )
            end,
            desc = "Find implementations of symbol under cursor",
        },
        {
            "<leader>fs",
            function()
                TeleMultiplexSearch(
                    require("telescope.builtin").treesitter,
                    {},
                    "Treesitter Symbols",
                    function()
                        vim.api.nvim_buf_get_name(0)
                    end
                )
            end,
            desc = "Find treesitter symbols in current buffer",
        },
        {
            "<leader>fh",
            "<cmd>lua require('telescope.builtin').search_history()<cr>",
            desc = "Find search history",
        },
        {
            "<leader>fk",
            "<cmd>lua require('telescope.builtin').keymaps()<cr>",
            desc = "Find keymaps",
        },
        {
            "<leader>fc",
            "<cmd>lua require('telescope.builtin').commands()<cr>",
            desc = "Find commands",
        },
        {
            "<leader>fmp",
            "<cmd>lua require('telescope.builtin').man_pages()<cr>",
            desc = "Find man pages",
        },
        {
            "<leader>fgc",
            "<cmd>lua require('telescope.builtin').git_commits()<cr>",
            desc = "Find git commits",
        },
        {
            "<leader>fgb",
            "<cmd>lua require('telescope.builtin').git_branches()<cr>",
            desc = "Find git branches",
        },
        {
            "<leader>fn",
            function()
                require("telescope").extensions.notify.notify()
            end,
            desc = "Notify",
        },
    },
    cmd = "Telescope",
    config = function()
        require("telescope").setup({
            defaults = {
                cache_picker = {
                    num_pickers = 20,
                },
            },
            pickers = {
                search_history = { cache_picker = false },
                keymaps = { cache_picker = false },
                commands = { cache_picker = false },
                man_pages = { cache_picker = false },
                git_commits = { cache_picker = false },
                git_branches = { cache_picker = false },
            },
            extensions = {
                fzf = {
                    fuzzy = true, -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true, -- override the file sorter
                    case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
                },
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown({
                        layout_config = { anchor = "N" },
                    }),
                },
            },
        })
        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("fzf")

        local _select = vim.ui.select
        function vim.ui.select(items, opts, on_choice)
            if
                opts
                and opts.prompt
                and type(opts.prompt) == "string"
                and string.match(opts.prompt, [[^You've reached.*limit.*Upgrade.*$]])
            then
                vim.notify("Copilot: " .. opts.prompt, vim.log.levels.ERROR)
                vim.cmd("Copilot disable")
            else
                return _select(items, opts, on_choice)
            end
        end
    end,
}
