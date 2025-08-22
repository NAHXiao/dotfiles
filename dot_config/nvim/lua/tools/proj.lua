local uv = vim.uv
---@alias path string

---@class Project
---@field name string
---@field path path  (Unique)
---@field mainwindows path[][]
---@field filebuffers path[]

---@alias Projects table<path,Project>

local M = {
    _setuped = false,
    config = {
        save_on_exit = true,
        update_on_exit = true,
        workspace = {
            vim.fs.joinpath(uv.os_homedir(), "workspace") .. "/1*/*",
            vim.fs.joinpath(uv.os_homedir(), "workspace") .. "/2*/*",
            vim.fs.joinpath(uv.os_homedir(), "workspace") .. "/3*/*",
        },
        projfile = vim.fs.joinpath(vim.fn.stdpath("data"), "proj/proj.json"),
        mksession = {
            name = function(path)
                return vim.fn.fnamemodify(path, ":t")
            end,
            path = function()
                return require("utils").get_rootdir(0)
            end,
            -- {
            -- 	{ -- 第一列file窗口
            -- 		"filepath1", -- top1
            -- 		"filepath2", -- top2
            -- 	},
            -- }
            mainwindow = function()
                local windows = vim.api.nvim_list_wins()
                local columns = {}
                for _, win in ipairs(windows) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    local bufname = vim.api.nvim_buf_get_name(buf)
                    if
                        bufname ~= ""
                        and vim.api.nvim_get_option_value("buftype", { buf = buf }) == ""
                    then
                        local pos = vim.api.nvim_win_get_position(win)
                        local col = pos[2] + 1
                        if not columns[col] then
                            columns[col] = {}
                        end
                        table.insert(columns[col], bufname)
                    end
                end
                local sorted_columns = {}
                for col, buffers in pairs(columns) do
                    table.insert(sorted_columns, { col = col, buffers = buffers })
                end
                table.sort(sorted_columns, function(a, b)
                    return a.col < b.col
                end)
                local result = {}
                for _, entry in ipairs(sorted_columns) do
                    table.insert(result, entry.buffers)
                end
                return result
            end,
            filebuffers = function()
                local buffers = {}
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(buf) then
                        local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
                        local name = vim.api.nvim_buf_get_name(buf)
                        if buftype == "" and name ~= "" then
                            table.insert(buffers, name)
                        end
                    end
                end
                return buffers
            end,
        },
    },
}

M.__index = M
function M:notify(msg, level, opts)
    vim.notify("proj: " .. msg, level, opts)
end

---@return Projects
function M:projreader()
    local projfile = self.config.projfile
    if 0 == vim.fn.filereadable(projfile) then
        return {}
    end
    local file = io.open(projfile, "r")
    if not file then
        self:notify(projfile .. " cannot be opened", vim.log.levels.ERROR)
        return {}
    end
    local content = file:read("*a")
    file:close()
    local projects = vim.json.decode(content)
    if projects == nil then
        return {}
    end
    local modified = false
    for path, _ in pairs(projects) do
        if 0 == vim.fn.isdirectory(path) then
            projects[path] = nil
            modified = true
            self:notify(path .. " is not exist and has been deleted", vim.log.levels.WARN)
        end
    end
    if modified then
        self:projwriter(projects)
    end
    return projects
end

---@param projects Projects
function M:projwriter(projects)
    local projfile = self.config.projfile
    vim.fn.mkdir(vim.fn.fnamemodify(projfile, ":h"), "p")
    local file = io.open(projfile, "w")
    if not file then
        self:notify("Failed to open proj file", vim.log.levels.ERROR)
        return
    end
    local content = vim.json.encode(projects)
    file:write(content)
    file:close()
end

---@return Project
function M:mksession()
    local funcs = self.config.mksession
    local path = funcs.path()
    local project = {
        name = funcs.name(path),
        path = path,
        mainwindows = funcs.mainwindow(),
        filebuffers = funcs.filebuffers(),
    }
    return project
end

function M:save()
    local project = self:mksession()
    vim.notify(vim.inspect(project))
    local projects = self:projreader()
    if projects == nil then
        projects = {}
    end
    projects[project.path] = project
    self:projwriter(projects)
end

---@param project Project
---@return boolean
function M:load(project)
    local layout = project.mainwindows or {}
    ----------------------------------------
    local _buffers = vim.api.nvim_list_bufs()
    vim.cmd("wa!")
    for _, buf in ipairs(_buffers) do
        vim.api.nvim_buf_delete(buf, { force = true })
    end
    _buffers = vim.api.nvim_list_bufs()
    ----------------------------------------
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    local base_win = vim.api.nvim_get_current_win()
    vim.cmd("enew")
    for col_idx, column in ipairs(layout) do
        if col_idx > 1 then
            vim.cmd("vsplit")
            vim.cmd("wincmd l")
        end
        for row_idx, filepath in ipairs(column) do
            if row_idx > 1 then
                vim.cmd("split")
                vim.cmd("wincmd j")
            end
            if 1 == vim.fn.filereadable(filepath) then
                vim.cmd("edit " .. filepath)
            end
        end
    end
    vim.api.nvim_set_current_win(base_win)
    ----------------------------------------
    local buffers = M.filebuffers or {}
    --exclude mainwindows
    for _, filepaths in ipairs(layout) do
        for _, filepath in ipairs(filepaths) do
            for i, buffer in ipairs(buffers) do
                if buffer == filepath then
                    table.remove(buffers, i)
                    break
                end
            end
        end
    end
    for _, filepath in ipairs(buffers) do
        local buf = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_buf_call(buf, function()
            if 1 == vim.fn.filereadable(filepath) then
                vim.cmd("edit " .. filepath)
            end
        end)
    end
    ----------------------------------------
    --- set cwd to path
    local path = project.path
    if vim.fn.isdirectory(path) == 1 then
        vim.cmd("cd " .. path)
    else
        vim.cmd("lcd " .. path)
    end
    ----------------------------------------
    for _, buf in ipairs(_buffers) do
        vim.api.nvim_buf_delete(buf, { force = false })
    end
    local ok, mod = pcall(require, "tools.term")
    if ok then
        mod:reset()
    end
    return true
end

function M:update()
    local project = self:mksession()
    local projects = self:projreader()
    if projects == nil or projects[project.path] == nil then
        return false
    end
    projects[project.path] = project
    self:projwriter(projects)
end

function M:delbypath(path)
    local projects = self:projreader()
    if projects == nil or projects[path] == nil then
        return
    end
    projects[path] = nil
    self:projwriter(projects)
end

---@param callback fun(project:Project)
function M:select(callback)
    local projects = self:projreader()
    if projects == nil then
        self:notify("No projects found", vim.log.levels.WARN)
        return
    end
    local options = {}
    for path, project in pairs(projects) do
        table.insert(options, { path = path, name = project.name })
    end
    if #options == 0 then
        self:notify("No projects found", vim.log.levels.WARN)
        return
    end
    vim.ui.select(options, {
        prompt = "Select a project:",
        format_item = function(item)
            return item.name .. " (" .. item.path .. ")"
        end,
    }, function(choice)
        if choice ~= nil then
            callback(projects[choice.path])
        else
            self:notify("No project selected")
        end
    end)
end

-- Create Autocmds
-- Save/Update Proj When Exit , then set _setuped true
function M:setup()
    if M._setuped == false then
        vim.api.nvim_create_augroup("proj", { clear = true })
        vim.api.nvim_create_autocmd("vimleavepre", {
            group = "proj",
            callback = function()
                local _saved = false
                if self.config.save_on_exit then
                    local matched_paths = {}
                    for _, glob in ipairs(self.config.workspace) do
                        vim.list_extend(matched_paths, vim.fn.glob(glob, true, true))
                    end
                    if vim.tbl_contains(matched_paths, self.config.mksession.path()) then
                        self:save()
                        _saved = true
                    end
                end
                if self.config.update_on_exit and not _saved then
                    self:update()
                end
            end,
        })
        self._setuped = true
    end
end

function M:select_and_load()
    self:select(function(project)
        if project ~= nil then
            self:load(project)
        end
    end)
end

function M:select_and_del()
    self:select(function(project)
        if project ~= nil then
            self:delbypath(project.path)
        end
    end)
end

return M
