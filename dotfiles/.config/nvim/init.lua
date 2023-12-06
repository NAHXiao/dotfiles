--[[ init.lua ]]
-- Impatient for faster loading
require('impatient')
-- LEADER
vim.g.mapleader = " "
-- TODO
vim.g.localleader = " "
vim.o.timeoutlen = 800

DebugToFile = function(log)
    if log == nil then
        return
    end
    local file = io.open('/home/wangsf/tmp/nvim.log', 'a')
    file:write(os.date("%Y-%m-%d %H:%M:%S", os.time()) .. ' ' .. tostring(log) .. '\n')
    file:close()
end

-- Color theme
if tostring(vim.fn.getenv('WEZTERM_EXECUTABLE')) ~= '/usr/bin/wezterm-gui' then
    require('kanagawa').setup({
        keywordStyle = { italic = false, bold = true },
    })
    vim.cmd("colorscheme kanagawa")
end




-- Highlight colors
vim.cmd([[
hi CursorLineNr guifg=#7e9cd8
" hi FoldColumn guifg=#4a4f54 guibg=#26292c
hi GitSignsAdd guibg=#193549 guifg=#3ad900
hi GitSignsChange guibg=#193549 guifg=#ffc600
hi GitSignsDelete guibg=#193549 guifg=#ff2600
hi ColorColumn guifg=NONE guibg=#204563 gui=NONE
"报错背景透明
hi Pmenu ctermfg=15 ctermbg=9 guifg=Red guibg=NONE
]])
--禁用保存后的提示
vim.cmd("autocmd BufWritePost * silent! !clear")
----------------------------------------
--        为透明文档添加边框       -----
----------------------------------------
local border = {
    { "🭽", "FloatBorder" },
    { "▔", "FloatBorder" },
    { "🭾", "FloatBorder" },
    { "▕", "FloatBorder" },
    { "🭿", "FloatBorder" },
    { "▁", "FloatBorder" },
    { "🭼", "FloatBorder" },
    { "▏", "FloatBorder" },
}
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.buf.hover({
    border = border,
})


-- IMPORTS
require("vars")      -- Variables
require("opts")      -- Options
require("keys")      -- Keymaps
require("plug")      -- Plugins
require("plugsetup") -- Plugins setup

-- vim.api.nvim_set_var设置内部变量。
-- vim.api.nvim_set_option设置选项。
-- vim.api.nvim_set_keymap设置键映
--
-- vim.g:映射到vim.api.nvim_set_var; 设置全局变量。
-- vim.o:映射到vim.api.nvim_win_set_var; 设置作用域为给定窗口的变量。
-- vim.b; 映射到vim.api.nvim_buf_set_var; 设置作用域为给定缓冲区的变量。射。
--
-- vim.g:映射到vim.api.nvim_get_var; 读取全局变量。
-- vim.o:映射到vim.api.nvim_win_get_var; 读取作用域为给定窗口的变量。
-- vim.b; 映射到vim.api.nvim_buf_get_var; 读取作用域为给定缓冲区的变量。
--
--set--get
-- vim.o:映射到vim.api.nvim_set_option; 相当于:set。
-- vim.go:映射到vim.api.nvim_set_option; 相当于:setglobal。
-- vim.bo; 映射到vim.api.nvim_buf_set_option; 相当于:setlocal缓冲区选项。
-- vim.wo:映射到vim.api.nvim_win_set_option; 相当于:setlocal窗口选项。
--
--
--
--
