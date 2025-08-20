local key = Globals.is_win and "<c-\\>" or "<c-space>"
return {
    "akinsho/toggleterm.nvim",
    version = "*",
    lazy = true,
    keys = {
        {
            key,
            "<CMD>ToggleTerm<CR>",
            mode = { "n", "t" },
            { noremap = true, silent = true },
            desc = "Toggle the float terminal",
        },
    },
    cmd = {
        "ToggleTerm",
    },
    config = function()
        local start_in_insert = true
        require("toggleterm").setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            start_in_insert = start_in_insert,
            insert_mappings = true,
            terminal_mappings = true,
            persist_size = true,
            persist_mode = true,
            direction = "float",
            close_on_exit = false,
            shell = vim.o.shell,
            auto_scroll = true,
            float_opts = {
                border = "curved",
                -- winblend = 3,
                title_pos = "center",
            },
        })

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
                        if start_in_insert then
                            vim.api.nvim_feedkeys("i", "n", false)
                        end
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
                        if start_in_insert then
                            vim.api.nvim_feedkeys("i", "n", false)
                        end
                        break
                    end
                end
            end
        end
        vim.api.nvim_create_autocmd("TermOpen", {
            pattern = "term://*",
            callback = function(args)
                local bufname = vim.api.nvim_buf_get_name(args.buf)
                if bufname:match("^term://.*;#toggleterm#%d+$") then
                    vim.keymap.set({ "n", "t", "v" }, "<A-n>", focus_next_term, { buffer = 0 })
                    vim.keymap.set({ "n", "t", "v" }, "<A-p>", focus_prev_term, { buffer = 0 })
                end
            end,
        })

        for i = 1, 9 do
            vim.keymap.set(
                "n",
                tostring(i) .. key,
                "<CMD>" .. tostring(i) .. "ToggleTerm<CR>",
                { noremap = true, silent = true }
            )
        end
    end,
}
