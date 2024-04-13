return {
  "rebelot/kanagawa.nvim",
  version = "*",
  lazy = false,
  cond=false,
  priority=1000,
  config = function()
    if tostring(vim.fn.getenv('WEZTERM_EXECUTABLE')) ~= '/usr/bin/wezterm-gui' then
    require('kanagawa').setup({
        keywordStyle = { italic = false, bold = true },
    })
    vim.cmd("colorscheme kanagawa")
    end
  end,
}
