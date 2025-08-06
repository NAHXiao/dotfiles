---@class picker
---@type table<string,picker>
local __cache_ctx = {}
local __save_id
local function save_aucmd(key, id)
    local id = id
    vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePickerClose",
        once = true,
        callback = function()
            if id == __save_id then
                local cached_pickers = require("telescope.state").get_global_key("cached_pickers")
                assert(#cached_pickers == 1)
                __cache_ctx[key] = cached_pickers[1]
            end
        end,
    })
end
---try to resume and update
---fallback: call and save
local function resume_call(key, func)
    return function()
        __save_id = {}
        save_aucmd(key, __save_id)
        if __cache_ctx[key] then
            require("telescope.state").set_global_key("cached_pickers", { __cache_ctx[key] })
            require("telescope.builtin").resume()
        else
            func()
        end
    end
end
---clean call
---save as latest
local function clean_call(key, func)
    return function()
        __save_id = {}
        save_aucmd(key, __save_id)
        func()
    end
end
return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    lazy = true,
    dependencies = {
        { "nvim-lua/popup.nvim" },
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        { "nvim-telescope/telescope-ui-select.nvim" },
    },
    keys = {
        {
            "<leader>ff",
            resume_call("Find Files", function()
                require("telescope.builtin").find_files()
            end),
            desc = "Find files",
        },
        {
            "<leader>fF",
            clean_call("Find Files", function()
                require("telescope.builtin").find_files()
            end),
            desc = "Find files(clean)",
        },
        {
            "<leader>fg",
            resume_call("Find Grep", function()
                require("telescope.builtin").live_grep()
            end),
            desc = "Find word",
        },
        {
            "<leader>fG",
            clean_call("Find Grep", function()
                require("telescope.builtin").live_grep()
            end),
            desc = "Find word(clean)",
        },
        {
            "<leader>fg",
            clean_call("Find Word", function()
                require("telescope.builtin").live_grep()
            end),
            desc = "Find word(Visual)",
            mode = "v",
        },
        {
            "<leader>fd",
            resume_call("Find Diagnostics", function()
                require("telescope.builtin").diagnostics()
            end),
            desc = "Find diagnostics in project root",
        },
        {
            "<leader>fD",
            clean_call("Find Diagnostics", function()
                require("telescope.builtin").diagnostics()
            end),
            desc = "Find diagnostics in project root(clean)",
        },
        {
            "<leader>fr",
            resume_call("Find LspRefs", function()
                require("telescope.builtin").lsp_references()
            end),
            desc = "Find references of word under cursor",
        },
        {
            "<leader>fR",
            clean_call("Find LspRefs", function()
                require("telescope.builtin").lsp_references()
            end),
            desc = "Find references of word under cursor(clean)",
        },
        {
            "<leader>fi",
            resume_call("Find Impls", function()
                require("telescope.builtin").lsp_implementations()
            end),
            desc = "Find implementations of symbol under cursor",
        },
        {
            "<leader>fI",
            clean_call("Find Impls", function()
                require("telescope.builtin").lsp_implementations()
            end),
            desc = "Find implementations of symbol under cursor(clean)",
        },
        {
            "<leader>fs",
            resume_call("Find TS Symbol", function()
                require("telescope.builtin").treesitter()
            end),
            desc = "Find treesitter symbols in current buffer",
        },
        {
            "<leader>fS",
            clean_call("Find TS Symbol", function()
                require("telescope.builtin").treesitter()
            end),
            desc = "Find treesitter symbols in current buffer(clean)",
        },
        {
            "<leader>fw",
            resume_call("Find Workspace Syml", function()
                require("telescope.builtin").lsp_dynamic_workspace_symbols()
            end),
            desc = "Find Workspace Symbol",
        },
        {
            "<leader>fW",
            clean_call("Find Workspace Syml", function()
                require("telescope.builtin").lsp_dynamic_workspace_symbols()
            end),
            desc = "Find Workspace Symbol(clean)",
        },
        {
            "<leader>fb",
            function()
                require("telescope.builtin").buffers()
            end,
            desc = "Find buffers",
        },
        {
            "<leader>fo",
            function()
                require("telescope.builtin").vim_options({
                    attach_mappings = function(_, map)
                        local function select_and_esc()
                            local selection =
                                require("telescope.actions.state").get_selected_entry()
                            if selection == nil then
                                return
                            end
                            local esc = ""
                            if vim.fn.mode() == "i" then
                                esc =
                                    vim.api.nvim_replace_termcodes("<esc><esc>", true, false, true)
                            end

                            vim.api.nvim_feedkeys(
                                string.format(
                                    "%s:set %s=%s",
                                    esc,
                                    selection.value.name,
                                    selection.value.value
                                ),
                                "m",
                                true
                            )
                        end
                        map("i", "<CR>", function()
                            select_and_esc()
                        end)
                        map("n", "<CR>", function()
                            select_and_esc()
                        end)
                        return true
                    end,
                })
            end,
            desc = "Find Vim Options",
        },
        {
            "<leader>fhs",
            "<cmd>lua require('telescope.builtin').search_history()<cr>",
            desc = "Find search history",
        },
        {
            "<leader>fhc",
            "<cmd>lua require('telescope.builtin').command_history()<cr>",
            desc = "Find command history",
        },
        {
            "<leader>fk",
            "<cmd>lua require('telescope.builtin').keymaps()<cr>",
            desc = "Find keymaps",
        },
        {
            "<leader>f;",
            "<cmd>lua require('telescope.builtin').commands()<cr>",
            desc = "Find commands",
        },
        {
            "<leader>f'",
            "<cmd>lua require('telescope.builtin').marks()<cr>",
            desc = "Find marks",
        },
        {
            "<leader>fc",
            "<cmd>lua require('telescope.builtin').colorscheme()<cr>",
            desc = "Find colorscheme",
        },
        {
            "<leader>fj",
            "<cmd>lua require('telescope.builtin').jumplist()<cr>",
            desc = "Find Jumplist",
        },
        {
            "<leader>fm",
            "<cmd>lua require('telescope.builtin').man_pages()<cr>",
            desc = "Find man pages",
        },
    },
    cmd = "Telescope",
    init = function()
        -- 一次性:首次调用则加载Telescope
        local _select = vim.ui.select
        function vim.ui.select(...)
            if not require("lazy").is_loaded("telescope.nvim") then
                vim.ui.select = _select
                require("lazy").load({ plugins = "telescope.nvim" })
                vim.ui.select(...)
            end
        end
    end,
    config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
            defaults = {
                cache_picker = {
                    num_pickers = 1,
                },
                sorting_strategy = "ascending",
                layout_config = {
                    prompt_position = "top",
                },
            },
            pickers = {
                search_history = { cache_picker = false },
                keymaps = { cache_picker = false },
                commands = { cache_picker = false },
                man_pages = { cache_picker = false },
                git_commits = { cache_picker = false },
                git_branches = { cache_picker = false },
                find_files = {
                    find_command = {
                        "fd",
                        "-H",
                        "-I",
                        "--exclude={.Trash-1000,.DS_Store,$RECYCLE.BIN,.git,.idea,.vscode,.sass-cache,.mypy_cache,node_modules,.gradle,build,.vscode-server,.virtualenvs,.cache,.ghcup,.conda,.rustup,.cargo,.local,target,.stfolder,.vs}",
                        "--strip-cwd-prefix",
                        "--follow",
                    },
                },
                live_grep = {
                    additional_args = { "--follow" },
                },
                vim_options = {
                    mappings = {
                        i = {
                            ["<CR>"] = actions.nop,
                        },
                        n = {
                            ["<CR>"] = actions.nop,
                        },
                    },
                },
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
                    -- require("telescope.themes").get_dropdown({
                    -- }),
                    layout_config = {
                        anchor = "N",
                        width = 0.6,
                        height = 0.5,
                    },
                },
            },
        })
        local picker = require("telescope.pickers")
        local _close_windows = picker._Picker.close_windows
        picker._Picker.close_windows = function(...)
            _close_windows(...)
            vim.api.nvim_exec_autocmds("User", {
                pattern = "TelescopePickerClose",
            })
        end
        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("fzf")
    end,
}
