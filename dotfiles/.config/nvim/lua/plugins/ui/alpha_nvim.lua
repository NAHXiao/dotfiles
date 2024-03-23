--首页
return {
    "goolord/alpha-nvim",
    version = "*",
    lazy = false,
    config = function()
        --   Recently opened files                   SPC f h
        local alpha = require "alpha"

        local dashboard = require "alpha.themes.dashboard"
        local theta = require "alpha.themes.theta"

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
        local ObsidianLinux = os.getenv("HOME") .. "/.local/Obsidian/main";
        local ObsidianWin = "E:/Obsidian/main";
        local obsidianbotton;
        if vim.loop.fs_stat(ObsidianLinux) then
            obsidianbotton = dashboard.button("o", "  Obsidian", "<cmd>cd " .. ObsidianLinux .. " <CR><cmd>edit .<cr>");
        elseif vim.loop.fs_stat(ObsidianWin) then
            obsidianbotton = dashboard.button("o", "  Obsidian", "<cmd>cd " .. ObsidianWin .. " <CR><cmd>edit .<cr>");
        else
            obsidianbotton = nil
        end
        theta.buttons.val = {
            { type = "text",    val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
            { type = "padding", val = 1 },
            dashboard.button("e", "󰈔  New file", "<Cmd>ene<CR>"),
            dashboard.button("SPC s l", "  Recently sessions"),
            dashboard.button("SPC f f", "󰈞  Find file"),
            dashboard.button("SPC f w", "󰊄  Live grep"),
            obsidianbotton,
            dashboard.button("c", "  Configuration", "<cmd>cd " .. vim.fn.stdpath("config") .. " <CR><cmd>edit .<cr>"),
            dashboard.button("p", "  Plugins", "<Cmd>Lazy<CR>"),
            dashboard.button("q", "󰅚  Quit", "<Cmd>qa<CR>"),
        }
        alpha.setup(theta.config)
    end,
}
