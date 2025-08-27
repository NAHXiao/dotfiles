-- local branch = vim.fn.has("0.11") and "main" or "master"
local branch = "master"
-- stylua: ignore
local ensure_install = { "bash", "c", "cpp", "cmake", "css", "dockerfile", "go", "gomod", "gowork", "html", "http", "java", "javascript", "json", "lua",  "make", "markdown", "markdown_inline", "python", "regex", "rust", "toml", "vim", "yaml", }
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
                desc = "Toggle: TSContext",
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
                TreesitterContextLineNumber = {
                    fg = { transform = "lighten", from = "#e3a680", amount = 0.55 },
                    bg = { "LineNr.bg" },
                },
            }, { dependency = "outer<-inner", type = "colorscheme" })
            require("treesitter-context").setup(opts)
        end,
    },
    {
        "RRethy/nvim-treesitter-endwise",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    },
    -- nvim-treesitter-textobjects
}
