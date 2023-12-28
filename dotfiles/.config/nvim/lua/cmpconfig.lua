require('func')
local lspkind = require("lspkind")
--   פּ ﯟ   some other good icons
local kind_icons = {
    Text = "",
    Method = "m",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
    Copilot = "",
}
-- find more here: https://www.nerdfonts.com/cheat-sheet

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end
local cmp = require("cmp")

cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
            -- vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = {
        ["<Tab>"] = cmp.mapping({
            c = function()
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    cmp.complete()
                end
            end,
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    fallback()
                end
            end,
        }),
        ["<S-Tab>"] = cmp.mapping({
            c = function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    cmp.complete()
                end
            end,
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    fallback()
                end
            end,
        }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
        ["<C-n>"] = cmp.mapping({
            c = function()
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                    vim.api.nvim_feedkeys(t("<Down>"), "n", true)
                end
            end,
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                    fallback()
                end
            end,
        }),
        ["<C-p>"] = cmp.mapping({
            c = function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                else
                    vim.api.nvim_feedkeys(t("<Up>"), "n", true)
                end
            end,
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                else
                    fallback()
                end
            end,
        }),
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        --['<C-e>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
        --['<C-e>'] = cmp.mapping({ i = cmp.mapping.close(), c = cmp.mapping.close() }),
        --mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ["<C-e>"] = cmp.mapping.abort(),

        --[[ ['<CR>'] = cmp.mapping({
            i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
            c = function()
                if cmp.visible() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                end
            end,
        }), ]]
    },

    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
            vim_item.menu = ({
                copilot = "[Copilot]",
                nvim_lsp = "[LSP]",
                luasnip = "[LuaSnip]",
                buffer = "[Buffer]",
                path = "[Path]",
                emoji = "[Emoji]"
            })[entry.source.name]
            return vim_item
        end,
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "copilot" },
        -- { name = "vsnip" },
        { name = "luasnip" },
        { name = "emoji" },
        { name = 'nvim_lsp_signature_help' },
    }, {
        { name = "buffer" },
        { name = "path" },
    }),
    --[[ sorting = {
        priority_weight = 2,
        comparators = {
            require("copilot_cmp.comparators").prioritize,

            -- Below is the default comparitor list and order for nvim-cmp
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    }, ]]
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = "buffer" },
    }),
})

-- Use buffer source foj `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
    completion = { autocomplete = false },
    sources = {
        { name = "buffer" },
    },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    completion = { autocomplete = false },
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})
-- 函数补全括号
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)



----------LuaSnip----------------
do
    local ls = require("luasnip")
    local s = ls.snippet
    local sn = ls.snippet_node
    local isn = ls.indent_snippet_node
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local c = ls.choice_node
    local d = ls.dynamic_node
    local r = ls.restore_node
    local events = require("luasnip.util.events")
    local ai = require("luasnip.nodes.absolute_indexer")
    local extras = require("luasnip.extras")
    local l = extras.lambda
    local rep = extras.rep
    local p = extras.partial
    local m = extras.match
    local n = extras.nonempty
    local dl = extras.dynamic_lambda
    local fmt = require("luasnip.extras.fmt").fmt
    local fmta = require("luasnip.extras.fmt").fmta
    local conds = require("luasnip.extras.expand_conditions")
    local postfix = require("luasnip.extras.postfix").postfix
    local types = require("luasnip.util.types")
    local parse = require("luasnip.util.parser").parse_snippet
    local ms = ls.multi_snippet
    local k = require("luasnip.nodes.key_indexer").new_key

    local snip = ls.snippet
    local node = ls.snippet_node
    local text = ls.text_node
    local insert = ls.insert_node
    local func = ls.function_node
    local choice = ls.choice_node
    local dynamicn = ls.dynamic_node
    local date = function() return { os.date('%Y-%m-%d') } end
    ls.add_snippets(nil, {
        all = {
            s({
                trig = "date",
                name = "Date",
                dscr = "Date in the form of YYYY-MM-DD",
                -- wordTrig=true,--仅当完全匹配才展开
                trigEngine = "vim", -- string|function 匹配模式
                -- docTring= -- 覆写从.json加载的文档
                hidden = false,     --true=>when querying ,the snippet should not show : 弃用
                -- priority=1000, -- 优先级,默认1000,
                -- snippetType = ,--"snippet"|"autosnippet" ,配合 ls.config.setup({enable_autosnippets=true})自动触发代码段
                -- resolveExpandParams= -- ???
                -- condition=???
                -- show_condition=
                -- filetype= 覆盖ls.add_snippets设置的文件类型
            }, {
                -- snippet.env snippet.captures snippet.trigger使用??? dynamic_node|function_node
                f(date, {}), i(1, "hello"), i(2, "hello"), t "textnode", t({ "first line", "second line" }), sn(3, {
                i(1, "sub1"), i(2, "sub2")
            }), f(function(input, parent, user_args) -- parent参数作用: Snippet-Data , user_args???
                return input[1][1]
            end, { 1 })                              --怎么传入多个参数?
            }, {
                -- callbacks = { -- 回调函数,似乎是按第几个inputnode来定位?
                -- position of the node, not the jump-index!!
                -- s("trig", {t"first node", t"second node", i(1, "third node")}).
                -- [3] = {
                -- [events.enter] = function(node, _event_args) DebugToFile("hello???") end
                -- }
                -- }
            }
            ),
            s({ trig = "trig" }, {
                i(1), t "text", i(2), t "text again", i(3)
            }),
            snip({
                    trig = "meta",
                    name = "Metadata",
                    dscr = "Yaml metadata format for markdown"
                },
                {
                    text({ "---",
                        "title: " }), insert(1, "note_title"), text({ "",
                    "author: " }), insert(2, "author"), text({ "",
                    "date: " }), func(date, {}), text({ "",
                    "categories: [" }), insert(3, ""), text({ "]",
                    "lastmod: " }), func(date, {}), text({ "",
                    "tags: [" }), insert(4), text({ "]",
                    "comments: true",
                    "---", "" }),
                    insert(0)
                }),
        },
    })
end

do
    local keymap = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }
    keymap("i", "<c-j>", "<cmd>lua require'luasnip'.jump(1)<CR>", opts)
    keymap("s", "<c-j>", "<cmd>lua require'luasnip'.jump(1)<CR>", opts)
    keymap("i", "<c-k>", "<cmd>lua require'luasnip'.jump(-1)<CR>", opts)
    keymap("s", "<c-k>", "<cmd>lua require'luasnip'.jump(-1)<CR>", opts)
end

--- API---
--invalidata() 临时hidden
--get_keyed_node(key) 返回与key关联的当前节点
-----vscode luasnip ---------
-- require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/my_snip" } })
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load("global")
require 'luasnip'.filetype_extend("cpp", { "cpp", "cppdoc" })
require 'luasnip'.filetype_extend("c", { "c", "cdoc" })
require 'luasnip'.filetype_extend("rs", { "rust", "rustdoc" })
require 'luasnip'.filetype_extend("sh", { "shell", "shelldoc" })
require 'luasnip'.filetype_extend("python", { "base", "pydoc", "python" })
require 'luasnip'.filetype_extend("html", { "html" })
require 'luasnip'.filetype_extend("make", { "make" })
require 'luasnip'.filetype_extend("nix", { "nix" })
require 'luasnip'.filetype_extend("sql", { "sql" })
