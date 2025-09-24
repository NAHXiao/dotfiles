---@param filter? fun(win: integer): boolean
---@return integer[] winids
local function get_rightmost_wins(filter)
    filter = filter or function(_)
        return true
    end
    local wins = vim.api.nvim_tabpage_list_wins(0)
    local max_right = -1
    local rightmost = {}
    for _, win in ipairs(wins) do
        local pos = vim.api.nvim_win_get_position(win)
        local col = pos[2]
        local right = col + vim.api.nvim_win_get_width(win)
        if right > max_right then
            max_right = right
        end
    end
    for _, win in ipairs(wins) do
        local pos = vim.api.nvim_win_get_position(win)
        local right = pos[2] + vim.api.nvim_win_get_width(win)
        if right == max_right and filter(win) then
            table.insert(rightmost, { win = win, row = pos[1] })
        end
    end
    table.sort(rightmost, function(a, b)
        return a.row < b.row
    end)
    return vim.tbl_map(function(item)
        return item.win
    end, rightmost)
end
return {
    "willothy/flatten.nvim",
    opts = {
        window = {
            ---@module 'flatten'
            ---@type fun(opts: Flatten.OpenContext):  Flatten.BufferId,Flatten.WindowId?
            open = function(opts)
                local files = opts.files
                local stdin_buf = opts.stdin_buf
                local bufnr = stdin_buf ~= nil and stdin_buf.bufnr or files[1].bufnr
                local winnr
                local base_win = get_rightmost_wins(function(win)
                    return vim.bo[vim.fn.winbufnr(win)].buftype == ""
                end)[1] or get_rightmost_wins()[1]
                winnr = vim.api.nvim_open_win(bufnr, true, {
                    split = "right",
                    win = base_win,
                })
                vim.api.nvim_set_current_win(winnr)
                assert(vim.fn.winbufnr(winnr) == bufnr, "Failed to open buffer in window")
                return bufnr, winnr
            end,
            diff = "tab_vsplit",
            focus = "first",
        },
    },
    lazy = false,
    priority = 1001,
}
