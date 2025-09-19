---@diagnostic disable: unused-local
---@alias dependency_type "inner<-inner"|"outer<-inner"|"outer<-outer"
---@alias color_hook_type "colorscheme"|"transparent"
local enable = true
if not enable then
    return setmetatable({}, {
        __index = function()
            return function() end
        end,
    })
end

local M = {}
local config = require("tools.config.hl")
local UIEntered = false
local log = function(act, hlname, msg) end
local apply_transforms = require("libs.hl").apply_transforms

--- | type    | colorscheme  |     transparent         |
--- | --------| ------------ | ------------------------|
--- | idi/odi | c | c,t(save on first?,c resume on off)|
--- | odo | invalid | t(save on first?,resume on off)  |
---@type table<string,{dependency_type:dependency_type,color_hook_type:color_hook_type,on_colorscheme:boolean,on_transparent:boolean,cached:nil|vim.api.keyset.get_hl_info,hltransform_wrapped:fun(colorscheme_changed:boolean,transparent_changed:boolean):(false|HighlightTable|fun():HighlightTable)}>
local color_tbls = {}

---@param tbl HighlightTransformRegistMap
---@param opts {dependency_type:dependency_type,color_hook_type:color_hook_type,on_colorscheme:boolean,on_transparent:boolean}
local function register(tbl, opts)
    for name, hltftbl in pairs(tbl) do
        color_tbls[name] = {
            color_hook_type = opts.color_hook_type,
            dependency_type = opts.dependency_type,
            on_colorscheme = opts.on_colorscheme,
            on_transparent = opts.on_transparent,
            hltransform_wrapped = function(colorscheme_changed, transparent_changed)
                assert(colorscheme_changed or transparent_changed)
                assert(not (colorscheme_changed and transparent_changed))
                local this = color_tbls[name]
                if
                    this.dependency_type == "inner<-inner"
                    or this.dependency_type == "outer<-inner"
                then
                    if this.color_hook_type == "colorscheme" then
                        assert(colorscheme_changed and not transparent_changed)
                        log("set", name, hltftbl)
                        return hltftbl
                    elseif this.color_hook_type == "transparent" then
                        if colorscheme_changed and not transparent_changed then
                            if config.transparent_enabled then
                                -- this.cached = vim.api.nvim_get_hl(0, { name = name, link = false })
                                this.cached = vim.api.nvim_get_hl(0, { name = name })
                                log("save and set", name, { save = this.cached, set = hltftbl })
                                return hltftbl
                            else
                                log("clear", name, this.cached)
                                this.cached = nil
                                return false
                            end
                        elseif not colorscheme_changed and transparent_changed then
                            if config.transparent_enabled then
                                -- this.cached = vim.api.nvim_get_hl(0, { name = name, link = false })
                                this.cached = vim.api.nvim_get_hl(0, { name = name })
                                log("save and set", name, { save = this.cached, set = hltftbl })
                                return hltftbl
                            else
                                local cached = this.cached
                                log("resume and clear", name, cached)
                                assert(cached ~= nil, "cached should not be nil")
                                this.cached = nil
                                return cached
                            end
                        end
                    end
                elseif this.dependency_type == "outer<-outer" then
                    if transparent_changed then
                        if config.transparent_enabled then
                            -- this.cached = vim.api.nvim_get_hl(0, { name = name, link = false })
                            this.cached = vim.api.nvim_get_hl(0, { name = name })
                            log("save and set", name, { save = this.cached, set = hltftbl })
                            return hltftbl
                        else
                            local cached = this.cached
                            log("resume and clear", name, cached)
                            assert(cached ~= nil, "cached should not be nil")
                            this.cached = nil
                            return cached
                        end
                    elseif colorscheme_changed then
                        return hltftbl
                    end
                end
                assert(false, "unreachable code")
            end,
        }
    end
    if opts.dependency_type == "inner<-inner" or opts.dependency_type == "outer<-inner" then
        if opts.color_hook_type == "colorscheme" then
            local hltbl = vim.iter(tbl)
                :map(function(k, v)
                    return k, color_tbls[k].hltransform_wrapped(true, false)
                end)
                :filter(function(k, v)
                    return v ~= false
                end)
                :fold({}, function(t, k, v)
                    tbl[k] = v
                    return tbl
                end)
            apply_transforms(hltbl)
        elseif opts.color_hook_type == "transparent" then
            local hltbl = vim.iter(tbl)
                :map(function(k, v)
                    if config.transparent_enabled then
                        return k, color_tbls[k].hltransform_wrapped(false, true)
                    else
                        return k, false
                    end
                end)
                :filter(function(k, v)
                    return v ~= false
                end)
                :fold({}, function(t, k, v)
                    tbl[k] = v
                    return tbl
                end)
            apply_transforms(hltbl)
        end
    elseif opts.dependency_type == "outer<-outer" then
        if opts.on_transparent then
            local hltbl = vim.iter(tbl)
                :map(function(k, v)
                    if config.transparent_enabled then
                        return k, color_tbls[k].hltransform_wrapped(false, true)
                    else
                        return k, false
                    end
                end)
                :filter(function(k, v)
                    return v ~= false
                end)
                :fold({}, function(t, k, v)
                    tbl[k] = v
                    return tbl
                end)
            apply_transforms(hltbl)
        else
            local hltbl = vim.iter(tbl)
                :map(function(k, v)
                    return k, color_tbls[k].hltransform_wrapped(true, false)
                end)
                :filter(function(k, v)
                    return v ~= false
                end)
                :fold({}, function(t, k, v)
                    tbl[k] = v
                    return tbl
                end)
            apply_transforms(hltbl)
        end
    end
end

---@param tbl table<string,HighlightTable|fun():HighlightTable>
---@param opts {dependency:dependency_type,type:color_hook_type}
function M.register(tbl, opts)
    if opts.dependency == "inner<-inner" or opts.dependency == "outer<-inner" then
        if opts.type == "colorscheme" then
            register(tbl, {
                dependency_type = opts.dependency,
                color_hook_type = opts.type,
                on_colorscheme = true,
            })
        elseif opts.type == "transparent" then
            register(tbl, {
                dependency_type = opts.dependency,
                color_hook_type = opts.type,
                on_colorscheme = true,
                on_transparent = true,
            })
        end
    elseif opts.dependency == "outer<-outer" then
        if opts.type == "colorscheme" then
            register(tbl, {
                dependency_type = opts.dependency,
                color_hook_type = opts.type,
                on_colorscheme = true,
            })
        elseif opts.type == "transparent" then
            register(tbl, {
                dependency_type = opts.dependency,
                color_hook_type = opts.type,
                on_transparent = true,
            })
        end
    end
end

---@param hilist table<string>
---@param opts {dependency:dependency_type,type:color_hook_type}
function M.register_transparent(hilist, opts)
    -- assert(opts.dependency ~= "outer<-inner")
    local tbl = vim.iter(hilist)
        :map(function(it)
            return it,
                function()
                    local hl = vim.api.nvim_get_hl(0, { name = it, link = false })
                    -- local hl = vim.api.nvim_get_hl(0, { name = it })
                    hl.bg = nil
                    return hl
                end
        end)
        :fold({}, function(t, k, v)
            t[k] = v
            return t
        end)
    M.register(tbl, opts)
end

local __running
---@param colorscheme_changed boolean
---@param transparent_changed boolean
local function apply(colorscheme_changed, transparent_changed)
    assert(colorscheme_changed or transparent_changed)
    assert(not (colorscheme_changed and transparent_changed))
    if __running then
        return
    end
    __running = true
    local clearcb = function()
        for _, dependency_type in ipairs { "inner<-inner", "outer<-inner", "outer<-outer" } do
            local tbl = vim.iter(color_tbls)
                :filter(function(k, v)
                    return v.dependency_type == dependency_type
                end)
                :filter(function(k, v)
                    return (v.on_colorscheme and colorscheme_changed)
                        or (v.on_transparent and transparent_changed)
                end)
                :map(function(k, v)
                    return k, v.hltransform_wrapped(colorscheme_changed, transparent_changed)
                end)
                :filter(function(k, v)
                    return v ~= false
                end)
                :fold({}, function(tbl, k, v)
                    tbl[k] = v
                    return tbl
                end)
            local errs = apply_transforms(tbl)
            if next(errs) then
                for hlname, err in pairs(errs) do
                    log("Error", hlname, err)
                    vim.notify(
                        ("Error setting highlight %s: %s"):format(hlname, err),
                        vim.log.levels.ERROR
                    )
                end
            end
        end
        __running = false
    end

    if UIEntered then --it's work but i don't know why (Fixed:ColorScheme switch)
        vim.schedule(clearcb)
    else
        clearcb()
    end
end
---@return boolean
function M.is_transparented()
    return config.transparent_enabled or false
end

---@param on? boolean
function M.toggle_transparent(on)
    if on then
        config.transparent_enabled = on
    else
        config.transparent_enabled = not config.transparent_enabled
    end
    config.save_config()
    apply(false, true)
end

---should be called before colorscheme load
function M.setup()
    if config.transparent_enabled == nil or config.use_lightbg == nil then
        config.read_config()
        config.save_config()
        if config.transparent_enabled == true then
            apply(false, true)
        end
    end
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            apply(true, false)
        end,
    })
    M.register(config.colorscheme_idi, { dependency = "inner<-inner", type = "colorscheme" })
    local tbl = vim.iter(config.transparent_groups_idi)
        :map(function(hlname)
            return hlname,
                function()
                    -- local hl = vim.api.nvim_get_hl(0, { name = hlname, link = false })
                    local hl = vim.api.nvim_get_hl(0, { name = hlname, link = false })
                    hl.bg = nil
                    return hl
                end
        end)
        :fold({}, function(tbl, k, v)
            tbl[k] = v
            return tbl
        end)
    M.register(tbl, {
        dependency = "inner<-inner",
        type = "transparent",
    })
    M.register(config.transparent_idi, {
        dependency = "inner<-inner",
        type = "transparent",
    })
    require("utils").map("n", "<leader>\\\\", function()
        M.toggle_transparent()
        require("utils").vim_echo(
            ("Transparent: %s"):format(M.is_transparented() and "On" or "Off")
        )
    end, { desc = "Toggle transparent" })

    require("utils").map("n", "<leader>\\|", function()
        if vim.o.background == "dark" then
            vim.o.background = "light"
        else
            vim.o.background = "dark"
        end
        config.use_lightbg = vim.o.background == "light"
        config.save_config()
        require("utils").vim_echo(("Background: %s"):format(vim.o.background))
    end, { desc = "Toggle background" })

    require("utils").auc("UIEnter", {
        callback = function()
            UIEntered = true
        end,
    })
end
return M
