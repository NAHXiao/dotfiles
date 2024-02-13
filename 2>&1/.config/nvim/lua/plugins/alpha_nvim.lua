
return {
  "goolord/alpha-nvim",
  version = "*",
  lazy = false,
  config = function()
            require 'alpha'.setup(require 'alpha.themes.dashboard'.config)
  end,
}
