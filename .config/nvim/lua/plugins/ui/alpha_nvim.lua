--首页
return {
    "goolord/alpha-nvim",
    version = "*",
    lazy = false,
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
        local obsidianbotton

        obsidianbotton = vim.g.obsidianPath
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
            dashboard.button(
                "p",
                "  Projects",
                "<cmd>lua require('utils').proj:select_and_load()<cr>"
            ),
            dashboard.button("SPC f f", "󰈞  Find file"),
            dashboard.button("SPC f w", "󰊄  Live grep"),
            obsidianbotton,
            dashboard.button(
                "c",
                "  Configuration",
                "<cmd>cd " .. vim.fn.stdpath("config") .. " <CR><cmd>edit .<cr>"
            ),
            dashboard.button("l", "  Plugins", "<Cmd>Lazy<CR>"),
            dashboard.button("q", "󰅚  Quit", "<Cmd>qa<CR>"),
        }
        alpha.setup(theta.config)
    end,
}
