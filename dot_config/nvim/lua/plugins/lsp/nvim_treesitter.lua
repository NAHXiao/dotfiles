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
local function node_at_cursor(buf)
    local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf })
    if ok then
        return node
    end
end

local function select_inner()
    local node = node_at_cursor(0)
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

return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "main",
        build = ":TSUpdate",
        keys = {
            {
                "ii",
                select_inner,
                mode = "x",
                desc = "change selection to inner",
            },
        },
        config = function()
            local treesitter = require("nvim-treesitter")
            -- vim.notify(vim.inspect(treesitter))
            treesitter.setup()
            -- vim.notify(vim.inspect(treesitter))
            treesitter.install(ensure_install)
            local available = treesitter.get_available()

            --启动对某个buf的ts,忽略大文件
            local function enable_ts(buf, lang)
                if require("utils").is_bigfile(buf) then
                    return
                end
                vim.wo.foldmethod = "expr"
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                if not vim.b[buf].ts_indent then
                    vim.b[buf].ts_indent_saved = vim.bo[buf].indentexpr
                end
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                vim.b[buf].ts_indent = true
                if not vim.g.vscode and not vim.b[buf].ts_highlight then
                    vim.treesitter.start(buf, lang)
                    vim.b[buf].ts_highlight = true
                end
            end
            --进入Buf -> 已安装ts则启动,未安装则安装 (安装后启动了吗?)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                group = require("utils").aug("ts_filetype"),
                callback = function(event)
                    local buf = event.buf
                    local filetype = vim.bo[buf].filetype
                    if filetype == "" then
                        return
                    end
                    local lang = vim.treesitter.language.get_lang(filetype) or filetype
                    if vim.treesitter.language.add(lang) then
                        enable_ts(buf, lang)
                    else
                        if vim.tbl_contains(available, lang) then
                            treesitter.install(lang)
                        end
                    end
                end,
            })

            --折叠函数,TODO: 不是有ufo吗?
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client:supports_method("textDocument/foldingRange") then
                        local win = vim.api.nvim_get_current_win()
                        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
                    end
                end,
            })
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
        branch = "main",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        init = function()
            vim.g.no_plugin_maps = true
        end,
        opts = {
            select = {
                lookahead = true,
                include_surrounding_whitespace = true,
                selection_modes = {
                    ["@function.outer"] = "V",
                    ["@class.outer"] = "V",
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter-textobjects").setup(opts)
            local select = require("nvim-treesitter-textobjects.select")
            vim.keymap.set({ "x", "o" }, "af", function()
                select.select_textobject("@function.outer", "textobjects")
            end, { desc = "function outer" })
            vim.keymap.set({ "x", "o" }, "if", function()
                select.select_textobject("@function.inner", "textobjects")
            end, { desc = "inner function" })
            vim.keymap.set({ "x", "o" }, "ac", function()
                select.select_textobject("@class.outer", "textobjects")
            end, { desc = "class outer" })
            vim.keymap.set({ "x", "o" }, "ic", function()
                select.select_textobject("@class.inner", "textobjects")
            end, { desc = "inner class" })
        end,
    },
}
