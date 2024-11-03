return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
        { "nvim-lua/popup.nvim" },
        { "nvim-lua/plenary.nvim" },
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build =
            'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    cmd = "Telescope",
    keys = {
        { "<leader>ff",  "<cmd>lua require('telescope.builtin').find_files()<cr>" },

        { "<leader>fw",  "<cmd>lua require('telescope.builtin').live_grep()<cr>" },

        { "<leader>fb",  "<cmd>lua require('telescope.builtin').buffers()<cr>" },
        { "<leader>fh",  "<cmd>lua require('telescope.builtin').help_tags()<cr>" },
        { "<leader>fd",  "<cmd>lua require('telescope.builtin').diagnostics()<cr>" },
        -- { "<leader>fs",  "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>" },
        { "<leader>fs",  "<cmd>lua require('telescope.builtin').treesitter()<cr>" },
        { "<leader>fr",  "<cmd>lua require('telescope.builtin').lsp_references()<cr>" },
        { "<leader>fi",  "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>" },
        { "<leader>fk",  "<cmd>lua require('telescope.builtin').keymaps()<cr>" },

        { "<leader>fc",  "<cmd>lua require('telescope.builtin').commands()<cr>" },
        -- { "<C-p>",       "<cmd>lua require('telescope.builtin').commands()<cr>" },

        { "<leader>fmp", "<cmd>lua require('telescope.builtin').man_pages()<cr>" },

        { "<leader>fgc", "<cmd>lua require('telescope.builtin').git_commits()<cr>" },
        { "<leader>fgb", "<cmd>lua require('telescope.builtin').git_branches()<cr>" },
        { "<leader>fsh", "<cmd>lua require('telescope.builtin').search_history()<cr>" },
        {
            "<leader>fn",
            function()
                require("telescope").extensions.notify.notify()
            end,
            desc = "Notify",
        },
        -- {
        --     "<leader>ft",
        --     function()
        --         require("telescope.builtin").colorscheme()
        --     end,
        --     desc = "Colorscheme",
        -- },
    },
    cmd = "Telescope",
    config = function()
        --- Telescope ---
        require('telescope').setup {
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {
                        -- even more opts
                    }

                    -- pseudo code / specification for writing custom displays, like the one
                    -- for "codeactions"
                    -- specific_opts = {
                    --   [kind] = {
                    --     make_indexed = function(items) -> indexed_items, width,
                    --     make_displayer = function(widths) -> displayer
                    --     make_display = function(displayer) -> function(e)
                    --     make_ordinal = function(e) -> string
                    --   },
                    --   -- for example to disable the custom builtin "codeactions" display
                    --      do the following
                    --   codeactions = false,
                    -- }
                },
                fzf = {
                    fuzzy = true,                   -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true,    -- override the file sorter
                    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
                }
            }
        }
        require("telescope").load_extension("ui-select")
        require('telescope').load_extension('fzf')
        -- do
            -- local actions = require('telescope.actions')
            -- local finders = require('telescope.finders')
            -- local pickers = require('telescope.pickers')
            -- local utils = require('telescope.utils')
            -- local make_entry = require "telescope.make_entry"
            -- local conf = require("telescope.config").values
            -- local action_state = require "telescope.actions.state"
            -- vim.g.ShowCommandPanel = function(opts)
            --     opts = opts or {}
            --     opts.modes = vim.F.if_nil(opts.modes, { "n", "i", "c", "x" })
            --
            --     local keymap_encountered = {} -- used to make sure no duplicates are inserted into keymaps_table
            --     local keymaps_table = {}
            --     local max_len_lhs = 0         --右手边(执行的操作)字符串长度最大值
            --
            --     -- helper function to populate keymaps_table and determine max_len_lhs
            --     local function extract_keymaps(keymaps)
            --         for _, keymap in pairs(keymaps) do
            --             local keymap_key = keymap.buffer ..
            --                 keymap.mode .. keymap.lhs -- should be distinct for every keymap
            --             if not keymap_encountered[keymap_key] then
            --                 keymap_encountered[keymap_key] = true
            --                 table.insert(keymaps_table, keymap)
            --                 max_len_lhs = math.max(max_len_lhs, #utils.display_termcodes(keymap.lhs)) -- display_termcodes: =><Space> ^F=><Ctrl-F> 9=><Tab>
            --             end
            --         end
            --     end
            --
            --     for _, mode in pairs(opts.modes) do
            --         local global = vim.api.nvim_get_keymap(mode)
            --         local buf_local = vim.api.nvim_buf_get_keymap(0, mode)
            --         extract_keymaps(global)
            --         extract_keymaps(buf_local)
            --     end
            --     opts.width_lhs = max_len_lhs + 1
            --     DebugToFile(vim.inspect(keymaps_table))
            --     DebugToFile(vim.inspect(opts))
            --     opts = vim.tbl_extend('force', opts, {
            --         prompt_title = "Commands Panel",
            --         theme = require("telescope._extensions.commander.theme"),
            --         -- sort_by = { "desc", "keymaps_str", "cmd_str", "cat" },
            --         -- sorting_strategy = "ascending",
            --         layout_strategy = "center",
            --         layout_config = {
            --             anchor = "N",
            --             preview_cutoff = 0,
            --             prompt_position = "top",
            --             height = 30,
            --             width = 150,
            --         },
            --     })
            --     pickers
            --         .new(opts, {
            --             prompt_title = opts.prompt_title,
            --             finder = finders.new_table {
            --                 results = keymaps_table,
            --                 entry_maker = function(entry)
            --                     return {
            --                         value = entry,
            --                         display = function(tbl)
            --                             return (tbl.lhs or "") .. "|" .. (tbl.cmd or "") .. "|" .. (tbl.desc or "")
            --                         end,                               --- 显示函数
            --                         ordinal = entry.desc or entry.rhs, --- SortBy(排序键)
            --
            --                         mode = entry.mode,
            --                         lhs = entry.lhs:gsub(string.char(9), "<TAB>"):gsub("", "<C-F>"):gsub(" ", "<Space>"),
            --                         desc = entry.desc,
            --                         cmd = entry.rhs,
            --                         valid = entry ~= "",
            --                     }
            --                 end
            --             },
            --             sorter = conf.generic_sorter(opts),
            --             attach_mappings = function(prompt_bufnr)
            --                 actions.select_default:replace(function()
            --                     local selection = action_state.get_selected_entry()
            --                     if selection == nil then
            --                         utils.__warn_no_selection "builtin.keymaps"
            --                         return
            --                     end
            --
            --                     vim.api.nvim_feedkeys(
            --                         vim.api.nvim_replace_termcodes(selection.value.lhs, true, false, true), "t", true)
            --                     return actions.close(prompt_bufnr)
            --                 end)
            --                 return true
            --             end,
            --         })
            --         :find()
            -- end
    end,
}
