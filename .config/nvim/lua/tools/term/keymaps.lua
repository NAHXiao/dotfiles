---@diagnostic disable: unused-local
local utils = require("tools.term.utils")

---@param keymaps {modes:string|string[],keys:string|string[],rhs:string|(fun(panel,node)|fun(panel)),desc?:string}[]
---@param node? NNode|fun():NNode
---@param bufnr? number nil==global
local map = function(keymaps, node, bufnr)
    local function map(mode, lhs, rhs, desc)
        vim.keymap.set(
            mode,
            lhs,
            rhs,
            { desc = desc, buffer = bufnr, noremap = true, silent = true }
        )
    end
    local panel = require("tools.term.panel")
    for _, keymap in ipairs(keymaps) do
        local keys = type(keymap.keys) == "string" and { keymap.keys } or keymap.keys
        ---@cast keys string[]
        for _, key in ipairs(keys) do
            map(keymap.modes, key, type(keymap.rhs) == "string" and keymap.rhs or function()
                ---@type NNode|nil
                local n
                if type(node) == "function" then
                    n = node()
                elseif type(node) == "table" then
                    n = node
                end
                keymap.rhs(panel, n)
            end, keymap.desc)
        end
    end
end

---@type table<string,fun(panel:panel,node:NNode)>
local actions = {
    add_term = function(panel, node)
        while node and node.classname ~= "GroupNode" do
            node = node.parent
        end
        ---@cast node GroupNode
        node:addnode(require("tools.term.node.termnode"):new({ name = "append-default" }, {
            cmds = { vim.o.shell },
            opts = {},
        }, true))
    end,
    add_group_input = function(panel, node)
        vim.ui.input({ prompt = "[Terminal] Enter name: " }, function(input)
            if not input or input == "" then
                vim.notify("[terminal]: Terminal name cannot be empty", vim.log.levels.ERROR)
                return
            end
            while node and node.classname ~= "GroupNode" do
                node = node.parent
            end
            ---@cast node GroupNode
            node:addnode(require("tools.term.node.groupnode"):new { name = input })
        end)
    end,
    add_term_input = function(panel, node)
        local cmds = {}
        local i = 1
        while true do
            local prompt = ("Enter value for cmd[%d]"):format(i)
                .. (i ~= 1 and ": " .. (table.concat(cmds, " ")) or "")
            local done = false
            vim.ui.input({ prompt = prompt }, function(input)
                if input == nil then
                    cmds = nil
                    done = true
                elseif input == "" then
                    done = true
                else
                    cmds[i] = input
                    i = i + 1
                end
            end)
            if done then
                break
            end
        end
        if cmds ~= nil and #cmds ~= 0 then
            panel.get_root():addnode(
                require("tools.term.node.termnode"):new(
                    { name = cmds[1] },
                    { cmds = cmds, opts = {} },
                    true
                )
            )
        end
    end,
    toggle_expand_or_set_curnode = function(panel, node)
        utils.log_notify("<cr> on " .. node.name)
        if node.classname == "GroupNode" or node.classname == "TaskSetNode" then
            ---@cast node TaskSetNode|GroupNode
            node:toggle_expand()
        else
            panel.set_cur_node(node)
            panel.panel_follow_node(panel.get_cur_node(), { expand = true, always = true })
        end
    end,
    toggle_pin = function(panel, node)
        node:toggle_pin()
    end,
    inspect_node = function(panel, node)
        if not node then
            return
        end
        local msg = {
            name = node.name,
            classname = node.classname,
            display = node:display(),
            tostring = node:tostring(),
            uniqueName = node.parent and node.parent:getUniqueNameByNode(node) or nil,
        }
        if node.classname == "TermNode" or node.classname == "TaskTermNode" then
            ---@cast node TermNode|TaskTermNode
            msg.jobinfo = {
                jobid = node.jobinfo.jobid,
                pid = vim.F.npcall(vim.fn.jobpid, node.jobinfo.jobid),
                cmds = node.jobinfo.cmds,
                repeat_left_times = node.repeat_left_times,
            }
        end
        vim.notify(vim.inspect(msg))
    end,
    inspect_tree = function(panel, node)
        local data = panel.getdata()
        local tree_lines = {}
        ---@type {[1]:NNode,[2]:number}[]
        local stack = { { panel.get_root(), 0 } }
        while #stack > 0 do
            local topNode, topIndent = unpack(table.remove(stack, #stack))
            tree_lines[#tree_lines + 1] = string.rep(" ", topIndent)
                .. topNode:tostring()
                .. " line"
                .. tostring(panel.getdata():getByKey(topNode))

            if topNode.classname == "GroupNode" or topNode.classname == "TaskSetNode" then
                ---@cast topNode GroupNode|TaskSetNode
                if topNode.expanded then
                    for i = #topNode.children, 1, -1 do
                        stack[#stack + 1] = { topNode.children[i], topIndent + 1 }
                    end
                end
            end
        end
        utils.log("inspect_tree: ", tree_lines)
        vim.notify(table.concat(tree_lines, "\n"))
    end,
    rename = function(panel, node)
        vim.ui.input({ prompt = "[Terminal] Enter name: " }, function(input)
            if not input or input == "" then
                vim.notify("[terminal]: Terminal name cannot be empty", vim.log.levels.ERROR)
                return
            end
            assert(type(input) == "string")
            node:rename(input)
        end)
    end,
    restart = function(panel, node)
        node:restart()
    end,
    switch_next = function(panel, node)
        local function flatten_next_node(cur)
            if not cur then
                return nil
            end
            if cur.classname == "TaskSetNode" or cur.classname == "GroupNode" then
                ---@cast cur TaskSetNode|GroupNode
                if cur.children and #cur.children > 0 then
                    return cur.children[1]
                end
            end
            if cur.next then
                return cur.next
            elseif cur.parent then
                return cur.parent.next
            else
                return nil
            end
        end
        local target = flatten_next_node(node)
        while target and (target.classname ~= "TermNode" and target.classname ~= "TaskTermNode") do
            target = flatten_next_node(target)
        end
        if target then
            panel.set_cur_node(target)
            panel.panel_follow_node(panel.get_cur_node(), { expand = true, always = true })
        end
    end,
    switch_prev = function(panel, node)
        local function flatten_prev_node(cur)
            if not cur then
                return nil
            end
            if cur.prev then
                local prev = cur.prev
                if prev.classname == "TaskSetNode" or prev.classname == "GroupNode" then
                    ---@cast prev TaskSetNode|GroupNode
                    if prev.children and #prev.children > 0 then
                        return prev.children[#prev.children]
                    end
                end
                return prev
            else
                return cur.parent
            end
        end
        local target = flatten_prev_node(node)
        while target and (target.classname ~= "TermNode" and target.classname ~= "TaskTermNode") do
            target = flatten_prev_node(target)
        end
        if target then
            panel.set_cur_node(target)
            panel.panel_follow_node(panel.get_cur_node(), { expand = true, always = true })
        end
    end,
    delete = function(panel, node)
        if node ~= panel.get_root() then
            vim.ui.input({ prompt = "[Terminal] Ensure delete? [y/n]" }, function(input)
                if not input or input == "" or (not input:lower():find("^y")) then
                    return
                end
                node.parent:delnode(node)
            end)
        end
    end,
    swap_with_next = function(panel, node)
        node.parent:swap(node, 1)
        panel.panel_follow_node(node, { expand = false, always = true })
    end,
    swap_with_prev = function(panel, node)
        node.parent:swap(node, -1)
        panel.panel_follow_node(node, { expand = false, always = true })
    end,
}

return {
    ---@type {modes:string|string[],keys:string|string[],rhs:string|fun(panel:panel),desc?:string}[]
    global = {
        {
            modes = "v",
            keys = "<CR>",
            rhs = function(panel)
                local lines = utils.visual_selection()
                local node = panel.get_cur_node()
                if lines and node and panel.send_feedkey(lines, node) then
                    vim.cmd("normal! \28\14")
                end
            end,
            desc = "Term: send to curnode",
        },
        {
            modes = { "n", "t", "v", "i" },
            keys = "<M-`>",
            rhs = function(panel)
                panel.toggle()
            end,
            desc = "Term: toggle panel",
        },
    },
    ---@type {modes:string|string[],keys:string|string[],rhs:string|fun(panel:panel,node:NNode),desc?:string}[]
    termbuf = {
        {
            modes = { "n", "t" },
            keys = "<A-'>",
            rhs = actions.add_group_input,
            desc = "AppendNewGroupNode",
        },
        {
            modes = { "n", "t" },
            keys = "<A-;>",
            rhs = actions.add_term_input,
            desc = "AppendNewGroupNode",
        },
        {
            modes = { "n", "t" },
            keys = "<A-/>",
            rhs = actions.add_term,
            desc = "AppendNewTermNode",
        },
        {
            modes = { "n", "t" },
            keys = "<A-r>",
            rhs = actions.rename,
            desc = "NodeRename",
        },
        {
            modes = { "n", "t" },
            keys = "<A-R>",
            rhs = actions.restart,
            desc = "NodeRestart",
        },
        {
            modes = { "n", "t" },
            keys = "<A-.>",
            rhs = actions.switch_next,
            desc = "NodeSwitchNext",
        },
        {
            modes = { "n", "t" },
            keys = "<A-,>",
            rhs = actions.switch_prev,
            desc = "NodeSwitchNext",
        },
    },
    ---@type {modes:string|string[],keys:string|string[],rhs:string|fun(panel,node),desc?:string}[]
    panelbuf = {
        {
            modes = { "n", "t" },
            keys = { "<A-;>", "a" },
            rhs = actions.add_term_input,
            desc = "AppendNewGroupNode",
        },
        {
            modes = { "n", "v" },
            keys = { "<A-'>", "A" },
            rhs = actions.add_group_input,
            desc = "AppendNewGroupNode",
        },
        {
            modes = { "n", "v" },
            keys = { "<A-/>" },
            rhs = actions.add_term,
            desc = "AppendNewTermNode",
        },
        {
            modes = { "n", "v" },
            keys = { "<space>", "<cr>" },
            rhs = actions.toggle_expand_or_set_curnode,
            desc = "ToggleExpand",
        },
        {
            modes = { "n", "v" },
            keys = { "p" },
            rhs = actions.toggle_pin,
            desc = "TogglePin",
        },
        {
            modes = { "n", "v" },
            keys = "r",
            rhs = actions.rename,
            desc = "NodeRename",
        },
        {
            modes = { "n", "v" },
            keys = "R",
            rhs = actions.restart,
            desc = "NodeRestart",
        },
        {
            modes = { "n", "v" },
            keys = "i",
            rhs = actions.inspect_node,
            desc = "NodeInspect",
        },
        {
            modes = { "n", "v" },
            keys = "I",
            rhs = actions.inspect_tree,
            desc = "NodeInspect",
        },
        {
            modes = { "n", "v" },
            keys = { "J", "." },
            rhs = actions.switch_next,
            desc = "NodeSwitchNext",
        },
        {
            modes = { "n", "v" },
            keys = { "K", "," },
            rhs = actions.switch_prev,
            desc = "NodeSwitchNext",
        },
        {
            modes = { "n", "v" },
            keys = { "h" },
            rhs = actions.swap_with_prev,
            desc = "swap_with_prev",
        },
        {
            modes = { "n", "v" },
            keys = { "l" },
            rhs = actions.swap_with_next,
            desc = "swap_with_next",
        },
        {
            modes = { "n", "v" },
            keys = "x",
            rhs = actions.delete,
            desc = "NodeDelete",
        },
    },
    map = map,
}
