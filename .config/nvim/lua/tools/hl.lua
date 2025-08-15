local config = require("tools.config.hl")
local M = {}
local __mk_handle = require("libs.hl").mkhandle
local path = vim.fn.stdpath("data") .. package.config:sub(1, 1) .. "nvim_transparent_cache"
---@type boolean
local transparent_enabled
local function readswitch()
    local exists, lines = pcall(vim.fn.readfile, path)
    transparent_enabled = exists and #lines > 0 and vim.trim(lines[1]) == "true"
end
local function writeswitch()
    vim.fn.writefile({ tostring(transparent_enabled) }, path)
end
---@param group string|string[]
local function clear_group(group)
    local groups = type(group) == "string" and { group } or group
    ---@cast groups string[]
    for _, v in ipairs(groups) do
        -- local ok, prev_attrs = pcall(vim.api.nvim_get_hl_by_name, v, true)
        local ok, prev_attrs = pcall(vim.api.nvim_get_hl, 0, { name = v })
        if ok and (prev_attrs.background or prev_attrs.bg or prev_attrs.ctermbg) then
            local attrs = vim.tbl_extend("force", prev_attrs, { bg = "NONE", ctermbg = "NONE" })
            attrs[true] = nil
            vim.api.nvim_set_hl(0, v, attrs)
        end
    end
end
local function clear()
    clear_group(config.transparent_groups)
    -- clear_group(config.transparent_extra_groups)
    -- for _, prefix in ipairs(config.transparent_group_prefix_list) do
    --     clear_group(vim.fn.getcompletion(prefix, "highlight"))
    -- end
end


---- who: highlight depends colorscheme
---- when: colorscheme_changed
---@param tbl HighlightTransformRegistMap
function M.regist(tbl)
    for hlname, hlopts in pairs(tbl) do
        config.color_trans_tbl[hlname] = hlopts
    end
    __mk_handle(tbl)()
end

local cached_hlgroup = {}
---- who: transparent_highlight depends colorscheme
---- when: colorscheme_changed or transparent_changed
---- etc: can resume
---@param tbl HighlightTransformRegistMap
function M.regist_transparent(tbl)
    for hlname, hlopts in pairs(tbl) do
        tbl[hlname] = function()
            if transparent_enabled then
                cached_hlgroup[hlname] = vim.api.nvim_get_hl(0, { name = hlname, link = false })
                if type(hlopts) == "function" then
                    return hlopts()
                else
                    return hlopts
                end
            else
                return cached_hlgroup[hlname]
            end
        end
        config.color_transparent_trans_tbl[hlname] = tbl[hlname]
    end
    if transparent_enabled then
        __mk_handle(tbl)()
    end
end

---- who: transparent_highlight not depends colorscheme
---- when: transparent_changed
---- etc: can resume
---@param tbl HighlightTransformRegistMap
function M.regist_transparent_once(tbl)
    for hlname, hlopts in pairs(tbl) do
        tbl[hlname] = function()
            if transparent_enabled then
                cached_hlgroup[hlname] = vim.api.nvim_get_hl(0, { name = hlname, link = false })
                if type(hlopts) == "function" then
                    return hlopts()
                else
                    return hlopts
                end
            else
                return cached_hlgroup[hlname]
            end
        end
        config.color_transparent_changed_tbl[hlname] = tbl[hlname]
    end
    if transparent_enabled then
        __mk_handle(tbl)()
    end
end

---- who: highlight which will be cleared when transparent enabled
---- when: colorscheme_changed,toggle_transparent
---@param groups string[]
function M.add_transparent_groups(groups)
    local tbl = {}
    for _, hlname in ipairs(groups) do
        local hlopts = vim.api.nvim_get_hl(0, { name = hlname, link = false })
        hlopts.bg = nil
        tbl[hlname] = hlopts
    end
    M.regist_transparent_once(tbl)
end

---- who: highlight which will be cleared when transparent enabled
---- when: colorscheme,toggle_transparent
---@param prefixs string[]
-- function M.add_transparent_groupprefix(prefixs)
--     for _, prefix in ipairs(prefixs) do
--         if not vim.list_contains(config.transparent_group_prefix_list, prefix) then
--             config.transparent_group_prefix_list[#config.transparent_group_prefix_list + 1] = prefix
--         end
--     end
--     if transparent_enabled then
--         for _, prefix in ipairs(config.transparent_group_prefix_list) do
--             clear_group(vim.fn.getcompletion(prefix, "highlight"))
--         end
--     end
-- end

local __running
---@param colorscheme_changed boolean
---@param transparent_changed boolean
local mk_handle = function(colorscheme_changed, transparent_changed)
    return function()
        if __running then
            return
        end
        __running = true
        if vim.g.colors_name and not colorscheme_changed and transparent_changed and not transparent_enabled then
            pcall(vim.cmd.colorscheme, vim.g.colors_name)
        end

        local clearcb = function()
            if colorscheme_changed then
                __mk_handle(config.color_trans_tbl)()
            end
            if transparent_enabled then
                clear()
            end
            if colorscheme_changed or transparent_changed then
                __mk_handle(config.color_transparent_trans_tbl)()
            end
            if transparent_changed then
                __mk_handle(config.color_transparent_changed_tbl)()
            end
            __running = false
        end

        if M.UIEnter then --it's work but i don't know why (Fixed:ColorScheme switch)
            vim.schedule(function()
                clearcb()
            end)
        else
            clearcb()
        end
    end
end
---@return boolean
function M.get_transparent()
    return transparent_enabled or false
end

---@param on? boolean
function M.toggle_transparent(on)
    if on then
        transparent_enabled = on
    else
        transparent_enabled = not transparent_enabled
    end
    writeswitch()
    mk_handle(false, true)()
end

M.UIEnter = false
---should be called before colorscheme load
function M.setup()
    M.regist(config.color_trans_tbl)
    M.regist_transparent(config.color_transparent_trans_tbl)
    M.regist_transparent_once(config.color_transparent_changed_tbl)
    vim.api.nvim_create_autocmd({ --[[ "VimEnter", ]] "ColorScheme" }, {
        callback = function()
            local transparent_changed = false
            if transparent_enabled == nil then
                readswitch()
                writeswitch()
                if transparent_enabled == true then
                    transparent_changed = true
                end
            end
            mk_handle(true, transparent_changed)()
        end,
    })
    -- vim.api.nvim_create_autocmd("OptionSet", {
    --     pattern = "background",
    --     callback = __handle,
    -- })
    require("utils").map("n", "<leader>\\\\", function()
        M.toggle_transparent()
        require("utils").vim_echo(("Transparent: %s"):format(M.get_transparent() and "On" or "Off"))
    end, { desc = "Toggle transparent" })
    require("utils").auc("UIEnter", { callback = function() M.UIEnter = true end })
end

return M
