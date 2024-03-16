return {
  "windwp/nvim-autopairs",
  version = "*",
  lazy = false,
  dependencies = {
  },
  config = function()
      require("nvim-autopairs").setup {}
  end,
}
