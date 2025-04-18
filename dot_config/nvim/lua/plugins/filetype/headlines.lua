return {
    "lukas-reineke/headlines.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    config = function()
        require("headlines").setup({
            markdown = {
                fat_headline_lower_string = "▔",
                -- fat_headline_lower_string = "▀",
            },
            rmd = {
                fat_headline_lower_string = "▔",
            },
            norg = {
                fat_headline_lower_string = "▔",
            },
            org = {
                fat_headline_lower_string = "▔",
            },
        })
    end,
}
