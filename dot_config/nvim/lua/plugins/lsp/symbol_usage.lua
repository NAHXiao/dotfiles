return {
    "Wansmer/symbol-usage.nvim",
    event = "LspAttach",
    config = true,
    keys = {
        {
            "<leader>\\l",
            function()
                if require("symbol-usage").toggle_globally() then
                    require("symbol-usage").refresh()
                end
            end,
            desc = "Toggle CodeLens",
        },
    },
}
