local M = {}
M.diagnostics = {
    error = { " " },
    warn = { " " },
    info = { " " },
    hint = { "󰌵 " }
}
M.git = {

}
---@type table<string,table<string,{[1]:icon,[2]:highlight}>>
return M
