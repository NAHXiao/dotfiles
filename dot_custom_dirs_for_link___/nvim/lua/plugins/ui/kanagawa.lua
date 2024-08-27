return {
    "rebelot/kanagawa.nvim",
    version = "*",
    lazy = false,
    cond = false,
    priority = 1000,
    config = function()
        -- if tostring(vim.fn.getenv('WEZTERM_EXECUTABLE')) ~= '/usr/bin/wezterm-gui' then
        require('kanagawa').setup({
            compile = true,
            keywordStyle = { italic = false, bold = true },
            background = { dark = "wave", light = "lotus" },
            colors = {
                theme = {
                    wave = {
                        ui = {
                            float = {
                                bg = "yellow",
                            },
                        },
                    },
                    dragon = {
                        syn = {
                            parameter = "yellow",
                        },
                    },
                    all = {
                        ui = {
                            bg_gutter = "none"
                        }
                    }
                }
            }
        })
        vim.cmd("colorscheme kanagawa")
        -- end
    end,
}
