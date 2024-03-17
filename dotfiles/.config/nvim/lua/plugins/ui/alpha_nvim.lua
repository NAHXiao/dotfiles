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

    theta.buttons.val = {
      { type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
      { type = "padding", val = 1 },
      dashboard.button("e", "󰈔  New file", "<Cmd>ene<CR>"),
      dashboard.button("se", "  Recently sessions"),
      dashboard.button("SPC f f", "󰈞  Find file"),
      dashboard.button("SPC f g", "󰊄  Live grep"),
      dashboard.button("c", "  Configuration", "<Cmd>edit ~/.config/nvim<CR>"),
      dashboard.button("p", "  Plugins", "<Cmd>Lazy<CR>"),
      dashboard.button("q", "󰅚  Quit", "<Cmd>qa<CR>"),
    }
    alpha.setup(theta.config)
    end,
}
