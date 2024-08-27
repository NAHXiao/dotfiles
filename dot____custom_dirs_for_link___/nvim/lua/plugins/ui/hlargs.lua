--更好的高亮
return {
  "m-demare/hlargs.nvim",
  version = "*",
  lazy = true,
  config = function()
require('hlargs').setup()
  end,
}
