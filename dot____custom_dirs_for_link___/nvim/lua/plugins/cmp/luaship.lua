return {
    "L3MON4D3/LuaSnip",
    version = "*",
    lazy = true,
    event = "InsertEnter",
    -- tag = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
        "rafamadriz/friendly-snippets"
    },
    config = function()
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
                        f(date, {}), i(1, "hello"), i(2, "hello"), t "textnode", t({ "first line", "second line" }), sn(
                        3, {
                            i(1, "sub1"), i(2, "sub2")
                        }), f(function(input, parent, user_args) -- parent参数作用: Snippet-Data , user_args???
                        return input[1][1]
                    end, { 1 })                                  --怎么传入多个参数?
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
                            trig = "leetcode",
                            name = "leetcode",
                            dscr = "bits/stdc++ and namespace std"
                        },
                        {
                            text({ "#include <bits/stdc++.h>", "using namespace std;", "" }),
                            insert(1),
                        }),
                    snip({
                        trig = "printvec",
                        name = "printvec",
                        dscr = "use cout to print vector"
                    }, {
                        text("for (auto it : "), insert(1, "vec"), text({ ") {", "" }),
                        text({
                            "    std::cout<<it<<' ';",
                            "}",
                            "std::cout<<std::endl;", ""
                        }),
                    }),
                    snip({
                        trig = "printvec2",
                        name = "printvec2",
                        dscr = "use cout to print vector<vector>"
                    }, {
                        text("for (auto it : "), insert(1, "vec"), text({ ") {", "" }),
                        text({
                            "    for (auto it2 : it ) {",
                            "        std::cout<<it2<<' ';",
                            "    }",
                            "    std::cout<<std::endl;",
                            "}",
                            "std::cout<<std::endl;", ""
                        }),
                    }),
                },
            })
        end
        --- API---
        --invalidata() 临时hidden
        --get_keyed_node(key) 返回与key关联的当前节点
        -----vscode luasnip ---------
        -- require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/my_snip" } })

        -- $HOME/.local/share/nvim/lazy/friendly-snippets/snippets
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
        do
            local map = vim.api.nvim_set_keymap
            local opts = { noremap = true, silent = true }
            map("i", "<c-j>", "<cmd>lua require'luasnip'.jump(1)<CR>", opts)
            map("s", "<c-j>", "<cmd>lua require'luasnip'.jump(1)<CR>", opts)
            map("i", "<c-k>", "<cmd>lua require'luasnip'.jump(-1)<CR>", opts)
            map("s", "<c-k>", "<cmd>lua require'luasnip'.jump(-1)<CR>", opts)
        end
    end,
}
