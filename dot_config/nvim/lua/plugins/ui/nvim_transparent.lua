return {
    "xiyaowong/nvim-transparent",
    version = "*",
    lazy = false,
    cmd = { "TransparentToggle" },
    keys = {
        { "<leader>\\", ":TransparentToggle<CR>", mode = "n", silent = true },
    },
    config = function()
        require("transparent").setup({
            exclude_groups = {
                "CursorLine",
            },
        })
        local function set_nr_color()
            if vim.g.transparent_enabled then
                vim.api.nvim_set_hl(0, "LineNr", { fg = "#ffffff" })
                vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff" })
            end
        end
        vim.defer_fn(function()
            set_nr_color()
        end, 1000)
        vim.cmd([[
            delcommand TransparentEnable
            delcommand TransparentDisable
            delcommand TransparentToggle
        ]])
        vim.api.nvim_create_user_command("TransparentToggle", function()
            require("transparent").toggle()
            set_nr_color()
        end, { desc = "Toggle transparent" })
    end,
}
