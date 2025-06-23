local nope = function() end
return {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim", lazy = true },
        { "MunifTanjim/nui.nvim", lazy = true },
        {
            "s1n7ax/nvim-window-picker",
            version = "2.*",
            config = function()
                require("window-picker").setup({
                    filter_rules = {
                        include_current_win = false,
                        autoselect_one = true,
                        -- filter using buffer options
                        bo = {
                            -- if the file type is one of following, the window will be ignored
                            filetype = { "neo-tree", "neo-tree-popup", "notify" },
                            -- if the buffer type is one of following, the window will be ignored
                            buftype = { "terminal", "quickfix" },
                        },
                    },
                })
            end,
        },
    },
    lazy = false,
    cmd = "Neotree",
    keys = {
        { "<C-n>", "<Cmd>Neotree toggle<CR>", desc = "Toggle Explorer", mode = "n" },
        {
            "<leader>t",
            "<Cmd>Neotree document_symbols action=show toggle=true<CR>",
            desc = "Toggle Explorer",
            mode = "n",
        },
    },
    config = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        vim.g.loaded_netrwSettings = 1
        vim.g.loaded_netrwFileHandlers = 1
        require("neo-tree").setup({
            sources = {
                "filesystem",
                "buffers",
                "git_status",
                "document_symbols",
            },
            close_if_last_window = false,
            default_source = "filesystem",
            enable_diagnostics = true,
            enable_git_status = true,
            enable_modified_markers = true,
            enable_opened_markers = true,
            enable_refresh_on_write = true,
            open_files_in_last_window = true, -- false = open files in top left window
            open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy" }, -- when opening files, do not use windows containing these filetypes or buftypes
            popup_border_style = "rounded", -- "NC","double", "none", "rounded", "shadow", "single" or "solid"
            sort_case_insensitive = false, -- used when sorting files and directories in the tree
            sort_function = nil, -- uses a custom function for sorting files and directories in the tree
            use_popups_for_input = true, -- If false, inputs will use vim.ui.input() instead of custom floats.
            use_default_mappings = true,
            source_selector = {
                winbar = true,
                statusline = false, -- TODO: Not Work?
                show_scrolled_off_parent_node = true,
                sources = {
                    { source = "filesystem", display_name = " 󰉓 File " },
                    { source = "buffers", display_name = " 󰈚 Buf " },
                    { source = "document_symbols", display_name = "  Sym " },
                    { source = "git_status", display_name = " 󰊢 Git " },
                },
                highlight_tab = "NeoTreeTabInactive",
                highlight_tab_active = "NeoTreeTabActive",
                highlight_background = "NeoTreeTabInactive",
                highlight_separator = "NeoTreeTabSeparatorInactive",
                highlight_separator_active = "NeoTreeTabSeparatorActive",
            },
            default_component_configs = {
                git_status = {
                    symbols = {
                        added = "󰬈",
                        modified = "󰬔",
                        deleted = "󰬋",
                        renamed = "󰬙",
                        -- Status type
                        untracked = "UN",
                        ignored = "󰬐",
                        unstaged = "󰬜",
                        staged = "󰬚",
                        conflict = "󰬊",
                    },
                },
                container = {
                    enable_character_fade = true,
                    width = "100%",
                    right_padding = 0,
                },
                symlink_target = {
                    enabled = true,
                },
            },
            window = {
                position = "left",
                width = 40,
                height = 15,
                auto_expand_width = false,
                popup = {
                    size = {
                        height = "80%",
                        width = "50%",
                    },
                    position = "50%", -- 50% means center it
                    title = function(state) -- format the text that appears at the top of a popup window
                        return "Neo-tree " .. state.name:gsub("^%l", string.upper)
                    end,
                },
                mapping_options = {
                    noremap = true,
                    nowait = true,
                },
                mappings = {
                    ["1"] = function()
                        vim.api.nvim_exec("Neotree focus filesystem left", true)
                    end,
                    ["2"] = function()
                        vim.api.nvim_exec("Neotree focus buffers left", true)
                    end,
                    ["3"] = function()
                        vim.api.nvim_exec("Neotree focus document_symbols left", true)
                    end,
                    ["4"] = function()
                        vim.api.nvim_exec("Neotree focus git_status left", true)
                    end,
                },
            },
            filesystem = {
                bind_to_cwd = true, -- true creates a 2-way binding between vim's cwd and neo-tree's root
                check_gitignore_in_search = true,
                -- find_command = "fd",
                -- find_args = {
                --     fd = {
                --         "--exclude", ".git",
                --         "--exclude", "node_modules",
                --     }
                -- },
                follow_current_file = {
                    enabled = true,
                    leave_dirs_open = true,
                },
                hijack_netrw_behavior = "open_current",
                window = {
                    mappings = {
                        ["."] = function(state)
                            local node = state.tree:get_node()
                            if not node:get_parent_id() then
                                require("neo-tree.sources.filesystem").navigate(
                                    state,
                                    vim.fn.fnamemodify(state.path, ":h"),
                                    nil,
                                    nil,
                                    false
                                )
                            else
                                require("neo-tree.sources.filesystem.commands").set_root(state)
                            end
                        end,
                        ["<cr>"] = function(state)
                            local node = state.tree:get_node()
                            if node.type ~= "message" then
                                state.commands["open"](state)
                            else
                                state.commands["toggle_hidden"](state)
                            end
                            -- hidden files
                        end,
                    },
                },
            },
            buffers = {
                bind_to_cwd = true,
                follow_current_file = {
                    enabled = true,
                    leave_dirs_open = false,
                },
                group_empty_dirs = true,
                -- terminals_first = true, --在无file buf打开时ToggleTerm不会刷新buflist
                window = {
                    mappings = {
                        ["<cr>"] = function(state)
                            --在buf已有对应window时自动focus到该window而不是新开一个
                            local node = state.tree:get_node()
                            -- vim.notify(vim.inspect(node))
                            local target_bufnr = node.extra and node.extra.bufnr
                            if target_bufnr then
                                for _, win in ipairs(vim.api.nvim_list_wins()) do
                                    if vim.api.nvim_win_get_buf(win) == target_bufnr then
                                        vim.api.nvim_set_current_win(win)
                                        return
                                    end
                                end
                            end
                            --适配toggleterm
                            local pattern = "^term://.*;#toggleterm#(%d+)$"
                            if node.type == "terminal" then
                                local termid = tonumber(string.match(node.name, pattern))
                                if termid and termid >= 1 and termid <= 9 then
                                    vim.cmd(tostring(termid) .. "ToggleTerm")
                                    return
                                end
                            end
                            state.commands["open"](state)
                        end,
                    },
                },
            },
            git_status = {
                window = {
                    mappings = {
                        ["A"] = "git_add_all",
                        ["gu"] = "git_unstage_file",
                        ["ga"] = "git_add_file",
                        ["gr"] = "git_revert_file",
                        ["gc"] = "git_commit",
                        ["gp"] = "git_push",
                        ["gg"] = "git_commit_and_push",
                        ["i"] = "show_file_details", -- see `:h neo-tree-file-actions` for options to customize the window.
                        ["b"] = "rename_basename",
                        ["o"] = {
                            "show_help",
                            nowait = false,
                            config = { title = "Order by", prefix_key = "o" },
                        },
                        ["oc"] = { "order_by_created", nowait = false },
                        ["od"] = { "order_by_diagnostics", nowait = false },
                        ["om"] = { "order_by_modified", nowait = false },
                        ["on"] = { "order_by_name", nowait = false },
                        ["os"] = { "order_by_size", nowait = false },
                        ["ot"] = { "order_by_type", nowait = false },
                    },
                },
            },
            document_symbols = {
                follow_cursor = true, -- 易BUG
                window = {
                    mappings = {
                        ["y"] = nope,
                        ["m"] = nope,
                        ["a"] = nope,
                        ["d"] = nope,
                        ["x"] = nope,
                        ["A"] = nope,
                        ["p"] = nope,
                        ["c"] = nope,
                    },
                },
            },
        })

        vim.g.transparent_groups = vim.list_extend(vim.g.transparent_groups or {}, {
            "NeoTreeNormalNC",
            "NeoTreeNormal",
            "NeoTreeTabActive",
            "NeoTreeTabInactive",
            "NeoTreeTabSeparatorActive",
            "NeoTreeTabSeparatorInactive",
            "NeoTreeWinSeparator",
        })
    end,
}
