-- 一次性:首次调用则加载Telescope
function vim.ui.select(...)
    if not Is_plugin_loaded("telescope.nvim") then
        -- vim.ui.select = _uiselect
        require("lazy").load({ plugins = "telescope.nvim" })
        vim.ui.select(...)
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
                require("telescope.builtin").find_files({
                    find_command = find_command,
                    no_ignore = true,
                    hidden = true,
                })
            end),
            desc = "Find files",
        },
        {
            "<leader>fF",
            clean_call("Find Files", function()
                require("telescope.builtin").find_files({
                    find_command = find_command,
                    no_ignore = true,
                    hidden = true,
                })
            end),
            desc = "Find files(clean)",
        },
        {
            "<leader>fg",
            resume_call("Find Grep", function()
                require("telescope.builtin").live_grep({
                    additional_args = { "--follow" },
                })
            end),
            desc = "Find word",
        },
        {
            "<leader>fG",
            clean_call("Find Grep", function()
                require("telescope.builtin").live_grep({
                    additional_args = { "--follow" },
                })
            end),
            desc = "Find word(clean)",
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
            desc = "Find treesitter symbols in current buffer(clean)"
        },
        {
            "<leader>fw",
            resume_call("Find Workspace Syml",function()
               require("telescope.builtin").lsp_dynamic_workspace_symbols()
            end),
            desc="Find Workspace Symbol"
        },
        {
            "<leader>fW",
            clean_call("Find Workspace Syml",function()
               require("telescope.builtin").lsp_dynamic_workspace_symbols()
            end),
            desc="Find Workspace Symbol(clean)"
        },
        {
            "<leader>fb",
            function()
                require("telescope.builtin").buffers()
            end,
            desc = "Find buffers",
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
        {
            "<leader>fn",
            function()
                require("telescope").extensions.notify.notify()
            end,
            desc = "Find Notify",
        },
    },
    cmd = "Telescope",
    config = function()
        require("telescope").setup({
            defaults = {
                cache_picker = {
                    num_pickers = 1,
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
