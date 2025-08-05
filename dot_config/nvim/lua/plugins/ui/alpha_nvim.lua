--首页
return {
    "goolord/alpha-nvim",
    version = "*",
    lazy = vim.fn.argc() > 0,
    cmd = { "Alpha", "AlphaRedraw", "AlphaRemap" },
    config = function()
        --   Recently opened files                   SPC f h
        local alpha = require("alpha")

        local dashboard = require("alpha.themes.dashboard")
        local theta = require("alpha.themes.theta")

        theta.header.val = {
            [[                                                     ]],
            [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ]],
            [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ]],
            [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ]],
            [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ]],
            [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ]],
            [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ]],
            [[                                                     ]],
        }
        local obsidianbutton

        obsidianbutton = vim.g.obsidianPath
                and dashboard.button(
                    "o",
                    "  Obsidian",
                    "<cmd>cd " .. vim.g.obsidianPath .. " <CR><cmd>edit .<cr>"
                )
            or nil
        theta.buttons.val = {
            {
                type = "text",
                val = "Quick links",
                opts = { hl = "SpecialComment", position = "center" },
            },
            { type = "padding", val = 1 },
            dashboard.button("e", "󰈔  New file", "<Cmd>ene<CR>"),
            -- dashboard.button("SPC s l", "  Recently sessions"),
            -- dashboard.button(
            --     "p",
            --     "  Projects",
            --     "<cmd>lua require('tools.proj'):select_and_load()<cr>"
            -- ),
            dashboard.button("f", "󰈞  Find file"),
            dashboard.button("g", "󰊄  Live grep"),
            obsidianbutton,
            dashboard.button(
                "c",
                "  Configuration",
                "<cmd>cd " .. vim.fn.stdpath("config") .. " <CR><cmd>edit .<cr>"
            ),
            dashboard.button("p", "  Plugins", "<Cmd>Lazy<CR>"),
            dashboard.button("q", "󰅚  Quit", "<Cmd>qa<CR>"),
        }
        alpha.setup(theta.config)
    end,
}
