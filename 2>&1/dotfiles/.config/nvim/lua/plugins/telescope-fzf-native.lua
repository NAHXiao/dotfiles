--TODO
--    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- Make telescope faster
return {
 'nvim-telescope/telescope-fzf-native.nvim',
  version = "*",
  lazy = false,
  build='make',
  dependencies={
  },
  config = function()
  end,
}
