---vim will attempt to prevent vim.lsp.enable() for all LSPs that are in the disable list but not in disable_exclude.
---You need to restart vim to apply the changes.
---@alias ulsp_config {disable?:table<string>|true,disable_exclude?:table<string>,extend?:table<string,vim.lsp.Config>,override?:table<string,vim.lsp.Config>}
---@alias lsp_config {disable:table<string>|true,disable_exclude:table<string>,extend:table<string,vim.lsp.Config>,override:table<string,vim.lsp.Config>}
local utils = require("utils")
local M = {}
---@param reload? boolean
function M.loadconfig(reload)
    if reload then
        package.loaded["tools.config.lsp"] = nil
    end
    M.config = require("tools.config.lsp")
    M.config.ulsp_config_ok = nil
    local config = M.config
    if vim.uv.fs_stat(config.ulsp_config_path()) then
        -- local ok, ulsp_config = pcall(dofile, config.ulsp_config_path())
        local ok, ulsp_config = require("utils").pdofile(config.ulsp_config_path())
        if ok then
            vim.validate("ulsp_config.disable", ulsp_config.disable, function(it)
                return type(it) == "table" or it == true
            end, true)
            vim.validate("ulsp_config.disable_exclude", ulsp_config.disable_exclude, "table", true)
            vim.validate("ulsp_config.extend", ulsp_config.extend, "table", true)
            vim.validate("ulsp_config.override", ulsp_config.override, "table", true)
            ulsp_config.disable = ulsp_config.disable or {}
            ulsp_config.disable_exclude = ulsp_config.disable_exclude or {}
            ulsp_config.extend = ulsp_config.extend or {}
            ulsp_config.override = ulsp_config.override or {}
            config.ulsp_config = ulsp_config
            for lspname, _ in pairs(config.ulsp_config.extend) do
                config.auto_enable[#config.auto_enable + 1] = lspname
            end
            for lspname, _ in pairs(config.ulsp_config.override) do
                config.auto_enable[#config.auto_enable + 1] = lspname
            end
        end
        config.ulsp_config_ok = ok
    end
end

---Override/Extend: should be called after <rtp>/lsp loaded,u
---@param mode "autocmd"|"immediate"
function M.setup_ulspconfig(mode)
    vim.validate("mode", mode, function(it)
        return it == "autocmd" or it == "immediate"
    end)
    local function setup_lspc()
        local config = M.config
        if config.ulsp_config_ok == true then
            for lsp, conf in pairs(config.ulsp_config.extend) do
                vim.lsp.config(lsp, conf)
            end
            for lsp, conf in pairs(config.ulsp_config.override) do
                vim.lsp.config[lsp] = conf
            end
        elseif config.ulsp_config_ok == false then
            vim.notify(
                ("[LSP]: dofile %s error: %s"):format(config.ulsp_config_path(), config.ulsp_config),
                vim.log.levels.ERROR
            )
        end
    end
    if mode == "autocmd" then
        require("utils").auc("User", {
            -- pattern = "RTPAfterPluginLoad",
            pattern = "VeryLazy",
            callback = setup_lspc,
        })
    elseif mode == "immediate" then
        setup_lspc()
    end
end

---g+u
---由于enable会导致resolved config生成,因此需要运行在<rtp>加载后
---[我也不知道为什么setup放到lazy加载前并使nvim_lspconfig lazy=false就能保证doautoall在nvim_lspconfig的<rtp>加载后执行,doautoall在下一个loop执行?]
---[我也不知道为什么将nvim_lspconfig完全禁用并只在enable_lsps前prepend_rtp会存在bug:使用nvim <filename>打开时第一次的FileType事件丢失了]
function M.enable_lsps()
    for _, lsp in ipairs(M.config.auto_enable) do
        if M.allow_enable(lsp) then
            vim.lsp.enable(lsp)
        end
    end
end

function M.allow_enable(lspname)
    if M.config.ulsp_config_ok then
        local ulsp_config = M.config.ulsp_config
        local pass
        if ulsp_config.disable == true then
            pass = vim.list_contains(ulsp_config.disable_exclude, lspname)
        else
            pass = (not vim.list_contains(ulsp_config.disable, lspname))
                or vim.list_contains(ulsp_config.disable_exclude, lspname)
        end
        return pass
    end
    return true
end

---Should be called earlyer,once
function M.setup_disable()
    local _enable = vim.lsp.enable
    vim.lsp.enable = function(name, enable)
        vim.validate("name", name, { "string", "table" })
        if type(name) == "string" then
            name = { name }
        end
        if enable == nil or enable == true then
            name = vim.iter(name)
                :filter(function(it)
                    local pass = M.allow_enable(it)
                    if not pass then
                        vim.notify(("[LSP]: %s has been disabled"):format(it), vim.log.levels.WARN)
                    end
                    return pass
                end)
                :totable()
        end
        return _enable(name, enable)
    end
    vim.api.nvim_create_user_command("LspStartForce", function(args)
        for _, lsp in ipairs(args.fargs) do
            _enable(lsp, true)
        end
    end, {
        complete = function()
            return vim.fn.getcompletion("LspStart ", "cmdline")
        end,
        nargs = "+",
    })
end

function M.toggle_inlay_hints()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    require("utils").vim_echo(
        ("[LSP.InlayHint]: %s"):format(vim.lsp.inlay_hint.is_enabled() and "Enabled" or "Disabled")
    )
end

---once
function M.setup_keymap()
    require("utils").map("n", "<leader>el", function()
        utils.focus_or_new(M.config.ulsp_config_path(), M.config.ulsp_config_tmpl)
    end, { desc = "Edit: Lsp" })
    require("utils").map("n", "<leader>\\i", M.toggle_inlay_hints, { desc = "Toggle inlay hints" })
end

---g,once
function M.lsp_settings()
    local config = M.config
    vim.lsp.inlay_hint.enable(true)
    vim.lsp.config("*", config.lsp_default_config)
    if config.extend then
        for lsp, conf in pairs(config.extend) do
            vim.lsp.config(lsp, conf)
        end
    end
    if config.override then
        for lsp, conf in pairs(config.override) do
            vim.lsp.config[lsp] = conf
        end
    end
end

function M.mason_auto_install()
    local ok, mason_registry = pcall(require, "mason-registry")
    if not ok then
        vim.notify(
            "[LSP]: require('mason-registry') error,please ensure mason is installed",
            vim.log.levels.ERROR
        )
        return
    end
    local function install(pkg_name)
        local ok, pkg = pcall(mason_registry.get_package, pkg_name)
        if ok then
            if not pkg:is_installed() then
                pkg:install()
            end
        else
            vim.schedule(function()
                vim.notify(("[LSP]: %s not found in mason-registry"):format(pkg_name))
            end)
        end
    end
    mason_registry.refresh(function(success, _)
        if success then
            local lsp2pkg = vim.iter(mason_registry.get_all_package_specs())
                :filter(function(it)
                    return vim.tbl_contains(it.categories, "LSP")
                end)
                :map(function(it)
                    return it.name,
                        (it.neovim and it.neovim.lspconfig and it.neovim.lspconfig or it.name)
                end)
                :fold({}, function(tbl, k, v)
                    tbl[k] = v
                    return tbl
                end)
            lsp2pkg = require("mason-core.functional").invert(lsp2pkg)
            setmetatable(lsp2pkg, {
                __index = function(_, k)
                    return k
                end,
            })
            for _, lsp_name in ipairs(M.config.mason_ensure_install_lsp) do
                install(lsp2pkg[lsp_name])
            end
            for _, pkg_name in ipairs(M.config.mason_ensure_install_dap) do
                install(pkg_name)
            end
            for _, pkg_name in ipairs(M.config.mason_ensure_install_extra) do
                install(pkg_name)
            end
        else
            vim.schedule(function()
                vim.notify("[LSP]: refresh mason_registry failed")
            end)
        end
    end)
end

function M.setup()
    M.loadconfig()
    M.lsp_settings()
    M.setup_ulspconfig("autocmd")
    M.setup_disable()
    M.enable_lsps()
    require("utils").auc("User", {
        pattern = "ProjRootChanged",
        callback = M.reload,
    })

    M.setup_keymap()
    require("utils").auc("User", {
        pattern = "VeryLazy",
        callback = M.mason_auto_install,
    })
end

function M.reload()
    M.loadconfig(true)
    M.setup_ulspconfig("immediate")
    --NOTE: internel API
    for nm, _ in pairs(vim.lsp._enabled_configs) do
        for _, client in ipairs(vim.lsp.get_clients { name = nm }) do
            client:stop()
        end
    end
    vim.lsp._enabled_configs = {}
    M.enable_lsps()
end

return M
