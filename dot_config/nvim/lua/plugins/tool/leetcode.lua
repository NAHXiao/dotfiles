local arg = "leetcode"
-- 抓包搜索graphql
-- 型如Hm_lvt_f0faad39bcf8471e3ab3ef70125152c3=1708828149; csrftoken=; gr_user_id=; _bl_uid=; a2873925c34ecbd2_gr_last_sent_cs1=; Hm_lvt_fa218a3ff7179639febdb15e372f411c=; tfstk=; _gid=; Hm_lpvt_fa218a3ff7179639febdb15e372f411c=; __appToken__=; a2873925c34ecbd2_gr_session_id=; a2873925c34ecbd2_gr_last_sent_sid_with_cs1=; a2873925c34ecbd2_gr_cs1=; a2873925c34ecbd2_gr_session_id_sent_vst=; Hm_lpvt_f0faad39bcf8471e3ab3ef70125152c3=; _gat=1; _ga=; _ga_PDVPZYN3CW=;
return {
    "kawre/leetcode.nvim",
    lazy = vim.fn.argv()[1] ~= arg,
    build = ":TSUpdate html",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- telescope 所需
        "MunifTanjim/nui.nvim",
        -- 可选
        "nvim-treesitter/nvim-treesitter",
        "rcarriga/nvim-notify",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        arg = arg,
        cn = {
            enabled = true,
        },
        injector = {
            ["cpp"] = {
                before = { "#include <bits/stdc++.h>", "using namespace std;" },
            },
            ["rust"] = {},
        },
        description = {
            -- position = "top",
            position = "left",
            width = "35%",
            show_stats = true,
        },
        console = {
            dir = "col",
        },
        hooks = {
            ["question_enter"] = {
                -- For question
                function(q)
                    local bufnr = q.bufnr
                    -- vim.b[bufnr].copilot_enabled = false
                    vim.cmd("Copilot disable")

                    vim.keymap.set(
                        "n",
                        "<leader>ll",
                        "<Cmd>Leet list<CR>",
                        { buffer = bufnr, desc = "LeetCode list" }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>lr",
                        "<Cmd>Leet run<CR>",
                        { buffer = bufnr, desc = "LeetCode run" }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>ls",
                        "<Cmd>Leet submit<CR>",
                        { buffer = bufnr, desc = "LeetCode submit" }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>li",
                        "<Cmd>Leet info<CR>",
                        { buffer = bufnr, desc = "LeetCode information" }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>ld",
                        "<Cmd>Leet desc<CR>",
                        { buffer = bufnr, desc = "LeetCode description" }
                    )
                end,
                -- For question description
                function(q)
                    local winid = q.description.winid

                    vim.wo[winid].wrap = true
                    vim.wo[winid].showbreak = "NONE"
                    vim.wo[winid].foldcolumn = "0"
                end,
            },
        },
        -- image_support = true,
        image_support = false,
    },
}
