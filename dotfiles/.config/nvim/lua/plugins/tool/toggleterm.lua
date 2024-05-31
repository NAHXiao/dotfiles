return {
    'akinsho/toggleterm.nvim',
    version = "*",
    lazy = true,
    keys = {
        { "<c-space>", "<CMD>ToggleTerm<CR>", { noremap = true, silent = true } },
        -- {"<c-\\>", "<CMD>ToggleTerm<CR>", {noremap = true, silent = true}},
    },
    dependencies = {
        "telescope.nvim",
    },
    config = function()
        local start_in_insert = true
        require("toggleterm").setup {
            -- size can be a number or function which is passed the current terminal
            -- size = 20 | function(term)
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            -- open_mapping = [[<c-\>]],
            open_mapping = [[<c-space>]],
            -- open_mapping = { [[<c-\>]], [[c-space]] },
            -- on_create = fun(t: Terminal), -- function to run when the terminal is first created
            -- on_open = fun(t: Terminal), -- function to run when the terminal opens
            -- on_close = fun(t: Terminal), -- function to run when the terminal closes
            -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
            -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
            -- on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
            -- hide_numbers = true, -- hide the number column in toggleterm buffers
            hide_numbers = false, -- hide the number column in toggleterm buffers
            shade_filetypes = {},
            -- autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
            autochdir = true, -- when neovim changes it current directory the terminal will change it's own when next it's opened
            -- highlights = {
            --   -- highlights which map to a highlight group name and a table of it's values
            --   -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
            --   Normal = {
            --     guibg = "<VALUE-HERE>",
            --   },
            --   NormalFloat = {
            --     link = 'Normal'
            --   },
            --   FloatBorder = {
            --     guifg = "<VALUE-HERE>",
            --     guibg = "<VALUE-HERE>",
            --   },
            -- },
            shade_terminals = true,   -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
            shading_factor = -30,     -- the percentage by which to lighten terminal background, default: -30 (gets multiplied by -3 if background is light)
            start_in_insert = start_in_insert,
            insert_mappings = true,   -- whether or not the open mapping applies in insert mode
            terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
            persist_size = true,
            persist_mode = true,      -- if set to true (default) the previous terminal mode will be remembered
            -- direction = 'vertical' | 'horizontal' | 'tab' | 'float',
            -- direction = 'float',
            direction = 'float',
            close_on_exit = true, -- close the terminal window when the process exits
            -- Change the default shell. Can be a string or a function returning a string
            shell = vim.o.shell,
            -- shell = "bash",
            auto_scroll = true, -- automatically scroll to the bottom on terminal output
            -- This field is only relevant if direction is set to 'float'
            float_opts = {
                -- The border key is *almost* the same as 'nvim_open_win'
                -- see :h nvim_open_win for details on borders however
                -- the 'curved' border is a custom border type
                -- not natively supported but implemented in this plugin.
                -- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
                -- border = 'single',
                border = 'curved',
                -- like `size`, width, height, row, and col can be a number or function which is passed the current terminal
                -- width = 100,
                -- height = 50,
                -- row = <value>,
                -- col = <value>,
                winblend = 3,
                -- zindex = <value>,
                -- title_pos = 'left' | 'center' | 'right', position of the title of the floating window
                title_pos = 'center',
            },
            winbar = {
                enabled = false,
                name_formatter = function(term) --  term: Terminal
                    return term.name
                end
            },
        }
        local focus_next_term = function()
            local term = require("toggleterm.terminal")
            local focusid = term.get_focused_id()
            if focusid then
                local terms = term.get_all(true)
                if #terms == 1 then
                    return
                end
                local next = -1
                for i, t in ipairs(terms) do
                    if t.id == focusid then
                        if i == #terms then
                            next = terms[1].id
                        else
                            next = terms[i + 1].id
                        end
                        require("toggleterm").toggle(next)
                        if start_in_insert then vim.api.nvim_feedkeys('i', 'n', false) end
                        break
                    end
                end
            end
        end
        local focus_prev_term = function()
            local term = require("toggleterm.terminal")
            local focusid = term.get_focused_id()
            if focusid then
                local terms = term.get_all(true)
                if #terms == 1 then
                    return
                end
                local next = -1
                for i, t in ipairs(terms) do
                    if t.id == focusid then
                        if i == 1 then
                            next = terms[#terms].id
                        else
                            next = terms[i - 1].id
                        end
                        require("toggleterm").toggle(next)
                        if start_in_insert then vim.api.nvim_feedkeys('i', 'n', false) end
                        break
                    end
                end
            end
        end
        vim.keymap.set("n", "<A-n>", focus_next_term)
        vim.keymap.set("t", "<A-n>", focus_next_term)
        vim.keymap.set("v", "<A-n>", focus_next_term)

        vim.keymap.set("n", "<A-p>", focus_prev_term)
        vim.keymap.set("t", "<A-p>", focus_prev_term)
        vim.keymap.set("v", "<A-p>", focus_prev_term)
    end
}
