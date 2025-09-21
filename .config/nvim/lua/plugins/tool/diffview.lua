return {
    "sindrets/diffview.nvim",
    version = "*",
    lazy = true,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    cmd = {
        "DiffviewFileHistory",
        "DiffviewOpen",
    },
    config = true,
}
