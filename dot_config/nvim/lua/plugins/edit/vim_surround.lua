return {
    "tpope/vim-surround",
    version = "*",
    lazy = true,
    event = "InsertEnter",
    dependencies = {},
    config = function()
        -- [[ surround ]]
        -- cs"'
        -- cs"<q>
        -- ds"
        -- ysiw]
        -- cs]{
        -- yss)
        -- ds{ds(
        -- ysiw)
    end,
}
