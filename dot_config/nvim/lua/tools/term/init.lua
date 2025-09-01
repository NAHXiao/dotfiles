local panel = require("tools.term.panel")
local function setup()
    local map = require("tools.term.keymaps").map
    local keymaps = require("tools.term.keymaps").global
    map(keymaps)
end
---@param name string
---@param ujobinfo ujobinfo
---@param focus boolean?
---@param switch boolean?
---@param unique_key string?
local function newtask(name, ujobinfo, focus, switch, unique_key)
    local node = panel.get_root():addnode(
        require("tools.term.node.tasktermnode"):new({ name = name }, ujobinfo, true),
        unique_key
    )
    if switch then
        panel.set_cur_node(node)
    end
    if focus then
        panel.focus()
    else
        panel.open()
    end
end
---@param name string
---@param tasks {name:string,jobinfo:ujobinfo,ignore_err:boolean,bg:boolean}[]
---@param focus boolean?
---@param switch boolean?
---@param unique_key string?
local function newtaskset(
    name,
    tasks,
    seq,
    break_on_err,
    focus,
    switch,
    after_finish_all,
    unique_key
)
    local node = panel.get_root():addnode(
        require("tools.term.node.tasksetnode"):new(
            { name = name },
            tasks,
            seq,
            break_on_err,
            after_finish_all,
            true
        ),
        unique_key
    )
    if node.children and #node.children > 0 then
        if switch then
            panel.set_cur_node(node.children[1])
        end
    end
    if focus then
        panel.focus()
    else
        panel.open()
    end
end
---@param name string
---@param ujobinfo ujobinfo
---@param focus boolean?
---@param switch boolean?
local function newterm(name, ujobinfo, focus, switch)
    local node = panel
        .get_root()
        :addnode(require("tools.term.node.termnode"):new({ name = name }, ujobinfo, true))
    if switch then
        panel.set_cur_node(node)
    end
    if focus then
        panel.focus()
    else
        panel.open()
    end
end
return {
    setup = setup,
    newtask = newtask,
    newtaskset = newtaskset,
    newterm = newterm,

    open = panel.open,
    close = panel.close,
    toggle = panel.toggle,
    focus = panel.focus,
    is_focused = panel.is_focused,
}
