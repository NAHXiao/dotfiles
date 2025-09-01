local panel = require("tools.term.panel")
local function setup()
    local map = require("tools.term.keymaps").map
    local keymaps = require("tools.term.keymaps").global
    map(keymaps)
end
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
    if switch then
        panel.set_cur_node(node)
    end
    if focus then
        panel.focus()
    else
        panel.open()
    end
end
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
