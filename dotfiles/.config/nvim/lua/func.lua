DebugToFile = function(log)
    if log == nil then
        return
    end
    local file = io.open('/home/wangsf/tmp/nvim.log', 'a')
    file:write(os.date("%Y-%m-%d %H:%M:%S", os.time()) .. ' ' .. tostring(log) .. '\n')
    file:close()
end

vim.cmd([[
function! CloseSystemClipboard()
set clipboard=
endfunction
command! CloseSystemClipboard call CloseSystemClipboard()
function! OpenSystemClipboard()
set clipboard=unnamedplus
endfunction
command! OpenSystemClipboard call OpenSystemClipboard()
]])

function ToggleClipboard()
    --TODO 兼容性问题
    local current_clipboard = vim.opt.clipboard:get()[1]
    if current_clipboard == "unnamedplus" then
        vim.opt.clipboard = ""
        print("Clipboard set to empty")
    else
        vim.opt.clipboard = "unnamedplus"
        print("Clipboard set to 'unnamedplus'")
    end
end

vim.cmd("command! ToggleClipboard lua ToggleClipboard()")
