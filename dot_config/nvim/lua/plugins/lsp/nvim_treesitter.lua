-- local branch = vim.fn.has("0.11") and "main" or "master"
local branch = "master"
-- stylua: ignore
local ensure_install = { "bash", "c", "cpp", "cmake", "css", "dockerfile", "go", "gomod", "gowork", "html", "http", "java", "javascript", "json", "lua",  "make", "markdown", "markdown_inline", "python", "regex", "rust", "toml", "vim", "yaml", }

---@return boolean cursor_at_end,number begin_row,number begin_col,number end_row,number end_col 1-based
local function get_visual_select_range()
    if vim.fn.mode():byte() ~= 118 then
        error("get_visual_select_range can only be called in visual mode")
    end
    local begin_row, begin_col, end_row, end_col
    local pos = vim.fn.getpos("v")
    begin_row, begin_col = pos[2], pos[3]
    pos = vim.fn.getpos(".")
    end_row, end_col = pos[2], pos[3]
    local cursor_at_end = true
    if vim.fn.line2byte(begin_row) + begin_col > vim.fn.line2byte(end_row) + end_col then
        cursor_at_end = false
        begin_row, begin_col, end_row, end_col = end_row, end_col, begin_row, begin_col
    end
    return cursor_at_end, begin_row, begin_col, end_row, end_col
end
---@param cursor_at_end boolean
---@param begin_row number
---@param begin_col number
---@param end_row number
---@param end_col number
---- 1-based
local function set_visual_select_range(cursor_at_end, begin_row, begin_col, end_row, end_col)
    if vim.fn.mode():byte() ~= 118 then
        error("get_visual_select_range can only be called in visual mode")
    end
    if vim.fn.line2byte(begin_row) + begin_col > vim.fn.line2byte(end_row) + end_col then
        error("begin pos cannot be after end pos")
    end
    if cursor_at_end then
        vim.api.nvim_win_set_cursor(0, { begin_row, begin_col - 1 })
        vim.api.nvim_feedkeys("o", "x", false)
        vim.api.nvim_win_set_cursor(0, { end_row, end_col - 1 })
    else
        vim.api.nvim_win_set_cursor(0, { end_row, end_col - 1 })
        vim.api.nvim_feedkeys("o", "x", false)
        vim.api.nvim_win_set_cursor(0, { begin_row, begin_col - 1 })
    end
end
local function select_inner()
    local node = require("nvim-treesitter.ts_utils").get_node_at_cursor(0)
    if not node or node:child_count() < 3 then
        return
    end
    local pairs = {
        ["{"] = "}",
        ["("] = ")",
        ["["] = "]",
        ["<"] = ">",
        ["'"] = "'",
        ['"'] = '"',
        ["`"] = "`",
    }
    local start_node = node:child(0)
    local start_next_node = node:child(1)
    local end_node = node:child(node:child_count() - 1)
    local end_prev_node = node:child(node:child_count() - 2)
    if
        not start_node
        or not end_node
        or start_node == end_node
        or pairs[start_node:type()] == nil
        or pairs[start_node:type()] ~= end_node:type()
        or not start_next_node
        or not end_prev_node
    then
        return
    end
    local start_row, start_col, _, _ = start_next_node:range()
    local _, _, end_row, end_col = end_prev_node:range()
    start_row, start_col, end_row, end_col = start_row + 1, start_col + 1, end_row + 1, end_col
    if
        vim.api
            .nvim_buf_get_lines(0, start_row - 1, start_row, false)[1]
            :sub(1, start_col - 1)
            :match("^%s*$")
    then
        start_col = 1
        local prev_linenum = start_row - 1
        while
            prev_linenum >= 1
            and vim.api
                .nvim_buf_get_lines(0, prev_linenum - 1, prev_linenum, false)[1]
                :match("^%s*$")
        do
            start_row = start_row - 1
            prev_linenum = start_row - 1
        end
    end
    if
        vim.api
            .nvim_buf_get_lines(0, end_row - 1, end_row, false)[1]
            :sub(end_col + 1)
            :match("^%s*$")
    then
        end_col = #vim.api.nvim_buf_get_lines(0, end_row - 1, end_row, false)[1]
        local next_linenum = end_row + 1
        while
            next_linenum <= vim.api.nvim_buf_line_count(0)
            and vim.api
                .nvim_buf_get_lines(0, next_linenum - 1, next_linenum, false)[1]
                :match("^%s*$")
        do
            end_row = end_row + 1
            next_linenum = end_row + 1
        end
    end
    local suc, a, b, c, d, e = pcall(get_visual_select_range)
    if not suc then
        return
    end
    if not pcall(set_visual_select_range, a, start_row, start_col, end_row, end_col) then
        set_visual_select_range(a, b, c, d, e)
    end
end
local jmprefbuf = function(offset)
    local t = require("nvim-treesitter.ts_utils")
    local l = require("nvim-treesitter.locals")
    local bufnr = vim.api.nvim_get_current_buf()
    local node_at_point = t.get_node_at_cursor()
    if not node_at_point then
        return
    end
    local def_node, scope = l.find_definition(node_at_point, bufnr)
    local usages = l.find_usages(def_node, scope, bufnr)
    local index = require("utils").index_of(usages, node_at_point)
    if not index then
        return
    end
    local target_index = (index + offset + #usages - 1) % #usages + 1
    t.goto_node(usages[target_index])
end
return {
    {
        "nvim-treesitter/nvim-treesitter",
        version = "*",
        lazy = false,
        branch = branch,
        build = ":TSUpdate",
        keys = {
            {
                "]s",
                function()
                    jmprefbuf(1)
                end,
                desc = "Jump To Next Usage(Buffer)",
            },
            {
                "[s",
                function()
                    jmprefbuf(-1)
                end,
                desc = "Jump To Prev Usage(Buffer)",
            },
            {
                "<leader>\\th",
                "<cmd>TSBufToggle highlight<cr>",
                desc = "Toggle TreeSitter(Buffer highlight)",
            },
            {
                "<leader>\\ti",
                "<cmd>TSBufToggle indent<cr>",
                desc = "Toggle TreeSitter(Buffer indent)",
            },
            {
                "ii",
                select_inner,
                mode = "x",
                desc = "change selection to inner",
            },
        },
        config = function()
            if branch == "main" then
                -- require("nvim-treesitter").setup()
                require("nvim-treesitter").install(ensure_install)
                local enable_ts = function(buf, lang)
                    if require("utils").is_bigfile(buf) then
                        return
                    end
                    if
                        not vim.tbl_contains(
                            require("nvim-treesitter.config").get_available(),
                            lang
                        )
                    then
                        return
                    end
                    vim.wo.foldmethod = "expr"
                    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    if not vim.g.vscode then
                        vim.treesitter.start(buf, lang)
                    end
                end
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = "*",
                    group = require("utils").aug("ts_filetype"),
                    callback = function(event)
                        local filetype = event.match
                        local lang = vim.treesitter.language.get_lang(filetype)
                        if
                            not vim.tbl_contains(
                                require("nvim-treesitter.config").get_installed("parsers"),
                                lang
                            )
                        then
                            require("nvim-treesitter").install(lang):await(function()
                                enable_ts(event.buf, lang)
                            end)
                        else
                            enable_ts(event.buf, lang)
                        end
                    end,
                })
            else
                require("nvim-treesitter.configs").setup {
                    ensure_installed = ensure_install,
                    sync_install = false,
                    ignore_install = {},
                    modules = {},
                    auto_install = true,
                    highlight = {
                        enable = true,
                        disable = function(lang, buf)
                            require("utils").is_bigfile(buf)
                        end,
                    },
                    incremental_selection = {
                        enable = true,
                        keymaps = {
                            init_selection = "<S-Tab>", -- normal mode
                            node_incremental = "<Tab>", -- visual mode
                            node_decremental = "<S-Tab>", -- visual mode
                        },
                    },
                    indent = { enable = true },
                }
                vim.o.foldmethod = "expr"
                vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.api.nvim_create_autocmd("LspAttach", {
                    callback = function(args)
                        local client = vim.lsp.get_client_by_id(args.data.client_id)
                        if client and client:supports_method("textDocument/foldingRange") then
                            local win = vim.api.nvim_get_current_win()
                            vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
                        end
                    end,
                })
            end
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {
            max_lines = 1,
        },
        keys = {
            {
                "<leader>\\tc",
                "<cmd>TSContext toggle<cr>",
                desc = "Toggle TSContext",
            },
            {
                "gc",
                function()
                    require("treesitter-context").go_to_context(vim.v.count1)
                end,
                desc = "goto context (upwards)",
            },
        },
        config = function(_, opts)
            require("tools.hl").register({
                TreesitterContextLineNumber = { link = "CursorLineNr" },
                TreesitterContext = { link = "Normal" },
            }, { dependency = "outer<-inner", type = "colorscheme" })
            require("treesitter-context").setup(opts)
        end,
    },
    {
        "RRethy/nvim-treesitter-endwise",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {
            textobjects = {
                select = {
                    enable = true,
                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["af"] = { query = "@function.outer", desc = "function" },
                        ["if"] = { query = "@function.inner", desc = "inner function" },
                        ["ac"] = { query = "@class.outer", desc = "class" },
                        ["ic"] = { query = "@class.inner", desc = "inner class" },
                    },
                    include_surrounding_whitespace = true,
                },
                swap = {
                    enable = false,
                },
                move = {
                    enable = false,
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
