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
        local Obsidian;
        local obsidianbotton;

        local osname = vim.loop.os_uname().sysname;
        if osname == 'Windows_NT' then
            Obsidian = "E:/Obsidian/main";
        elseif osname == "Linux" then
            Obsidian = os.getenv("HOME") .. "/.local/Obsidian/main";
        else
            Obsidian = nil;
        end
        if Obsidian == nil then
            obsidianbotton = nil
        elseif vim.loop.fs_stat(Obsidian) then
            obsidianbotton = dashboard.button("o", "  Obsidian", "<cmd>cd " .. Obsidian .. " <CR><cmd>edit .<cr>");
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
