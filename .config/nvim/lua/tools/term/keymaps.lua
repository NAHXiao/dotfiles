---@diagnostic disable: unused-local
local utils = require("tools.term.utils")

---@param keymaps {modes:string|string[],keys:string|string[],rhs:string|(fun(panel:panel,node:NNode?)),desc?:string}[]
---@param node (NNode|nil)|fun():(NNode|nil)
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
---@param node NNode?
---@return GroupNode|nil
local function find_group_upward(node)
    while node and node.classname ~= "GroupNode" do
        node = node.parent
    end
    ---@cast node GroupNode|nil
    return node
end

---fallback seq -> return `expected?`
---NOTE: code -> return `did practical work?`

---@type table<string,fun(panel:panel,node:NNode|nil):boolean>
local actions
actions = {
    add_term_and_focus = function(panel, node)
        node = not node and panel.get_root() or find_group_upward(node)
        if not node then
            return false
        end
        local shell = utils.default_shell
        ---@cast node GroupNode
        local target = node:addnode(
            require("tools.term.node.termnode"):new(
                { name = vim.fn.fnamemodify(shell[1], ":t:r") },
                {
                    cmds = shell,
                    opts = {},
                },
                true
            )
        )
        panel.set_cur_node(target)
        panel.panel_follow_node(target, { expand = true, always = true })
        return true
    end,
    add_group_input = function(panel, node)
        node = not node and panel.get_root() or find_group_upward(node)
        if not node then
            return false
        end
        vim.ui.input({ prompt = "[Terminal] Enter group name: " }, function(input)
            if not input or input == "" then
                vim.notify("[Terminal]: Terminal name cannot be empty", vim.log.levels.ERROR)
                return
            end
            ---@cast node GroupNode
            node:addnode(require("tools.term.node.groupnode"):new { name = input })
        end)
        return true
    end,
    add_term_input = function(panel, node)
        node = not node and panel.get_root() or find_group_upward(node)
        if not node then
            return false
        end
        local cmds = {}
        local i = 1
        while true do
            local prompt = ("Enter value for cmd[%d]"):format(i)
                .. (i ~= 1 and ": " .. ("`" .. table.concat(cmds, " ") .. "`") or "")
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
            while node and node.classname ~= "GroupNode" do
                node = node.parent
            end
            ---@cast node GroupNode
            node:addnode(
                require("tools.term.node.termnode"):new(
                    { name = cmds[1] },
                    { cmds = cmds, opts = {} },
                    true
                )
            )
        end
        return true
    end,
    toggle_expand_or_set_curnode = function(panel, node)
        if not node then
            return false
        end
        utils.log_notify("<cr> on " .. node.name)
        if node.classname == "GroupNode" or node.classname == "TaskSetNode" then
            ---@cast node TaskSetNode|GroupNode
            node:toggle_expand()
        else
            ---@cast node TaskTermNode|TermNode
            panel.set_cur_node(node)
            panel.panel_follow_node(node, { expand = true, always = true })
            panel.focus("term")
        end
        return true
    end,
    toggle_pin = function(panel, node)
        if not node then
            return false
        end
        node:toggle_pin()
        return true
    end,
    inspect_node = function(panel, node)
        if not node then
            return false
        end
        local msg = {
            name = node.name,
            classname = node.classname,
            bufnr = node--[[@as TermNode]].bufnr,
            repeat_left_times = node--[[@as TermNode]].repeat_left_times,
            display = node:display(),
            tostring = node:tostring(),
            parent = node.parent and node.parent:tostring() or "nil",
            children = node--[[@as GroupNode]].children
                    and vim.iter(node--[[@as GroupNode]].children)
                        :map(function(n)
                            return n:tostring()
                        end)
                        :totable()
                or nil,
            uniqueName = node.parent and node.parent:getUniqueNameByNode(node) or nil,
            status = node--[[@as TaskTermNode|TaskSetNode]].status,
        }
        if node.classname == "TermNode" or node.classname == "TaskTermNode" then
            ---@cast node TermNode|TaskTermNode
            msg.jobinfo = {
                jobid = node.jobinfo.jobid,
                pid = vim.F.npcall(vim.fn.jobpid, node.jobinfo.jobid),
                cmds = node.jobinfo.cmds,
                repeat_left_times = node.repeat_left_times,
                opts = node.jobinfo.opts,
            }
        end
        vim.notify(vim.inspect(msg))
        return true
    end,
    inspect_tree = function(panel, _)
        local data = panel.get_data()
        local tree_lines = {}
        ---@type {[1]:NNode,[2]:number}[]
        local stack = { { panel.get_root(), 0 } }
        while #stack > 0 do
            local topNode, topIndent = unpack(table.remove(stack, #stack))
            tree_lines[#tree_lines + 1] = string.rep(" ", topIndent)
                .. topNode:tostring()
                .. " line"
                .. tostring(panel.get_data():getByKey(topNode))

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
        return true
    end,
    rename = function(panel, node)
        if not node then
            return false
        end
        vim.ui.input({ prompt = "[Terminal] Enter name: " }, function(input)
            if not input or input == "" then
                vim.notify("[Terminal]: Terminal name cannot be empty", vim.log.levels.ERROR)
                return
            end
            assert(type(input) == "string")
            node:rename(input)
        end)
        return true
    end,
    restart = function(panel, node)
        if not node then
            return false
        end
        node:restart(true)
        return true
    end,
    switch_next = function(panel, node) -- node's next other than curnode's next
        if not node then
            return false
        end
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
            ---@cast target TaskTermNode|TermNode
            panel.set_cur_node(target)
            panel.panel_follow_node(target, { expand = true, always = true })
            return true
        end
        return false
    end,
    switch_prev = function(panel, node) -- node's prev other than curnode's prev
        if not node then
            return false
        end
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
            ---@cast target TaskTermNode|TermNode
            panel.set_cur_node(target)
            panel.panel_follow_node(target, { expand = true, always = true })
            return true
        end
        return false
    end,
    delete_confirm = function(panel, node)
        if not node then
            return false
        end
        local root = panel.get_root()
        if node == root then
            vim.ui.input({ prompt = "[Terminal] Ensure clear all? [y/n]" }, function(input)
                if not input or input == "" or (not input:lower():find("^y")) then
                    return
                end
                root:clear()
            end)
        else
            vim.ui.input({ prompt = "[Terminal] Ensure delete? [y/n]" }, function(input)
                if not input or input == "" or (not input:lower():find("^y")) then
                    return
                end
                if not actions.switch_next(panel, node) then
                    actions.switch_prev(panel, node)
                end
                node.parent:delnode(node)
            end)
        end
        return true
    end,
    delete_noconfirm = function(panel, node) --NoRoot
        if not node then
            return false
        end
        local root = panel.get_root()
        if not node or node == root then
            return false
        end
        if not actions.switch_next(panel, node) then
            actions.switch_prev(panel, node)
        end
        node.parent:delnode(node)
        return true
    end,
    swap_with_next = function(panel, node)
        if not node then
            return false
        end
        if node and node.parent then
            if node.parent:swap(node, 1) then
                panel.panel_follow_node(node, { expand = false, always = true })
                return true
            end
        end
        return false
    end,
    swap_with_prev = function(panel, node)
        if not node then
            return false
        end
        if node and node.parent then
            if node.parent:swap(node, -1) then
                panel.panel_follow_node(node, { expand = false, always = true })
            end
        end
        return false
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
            desc = "Term: SendToCurnode",
        },
        {
            modes = { "n", "t", "v", "i" },
            keys = "<M-`>",
            rhs = function(panel)
                panel.toggle()
            end,
            desc = "Term: TogglePanel",
        },
    },
    ---@type {modes:string|string[],keys:string|string[],rhs:string|fun(panel:panel,node:NNode),desc?:string}[]
    termbuf = {
        {
            modes = { "n", "t" },
            keys = "<A-'>",
            rhs = actions.add_group_input,
            desc = "Term: AppendNewTermNode",
        },
        {
            modes = { "n", "t" },
            keys = "<A-;>",
            rhs = actions.add_term_input,
            desc = "Term: AppendNewGroupNode",
        },
        {
            modes = { "n", "t" },
            keys = "<A-/>",
            rhs = actions.add_term_and_focus,
            desc = "Term: AppendNewTermNode(default)",
        },
        {
            modes = { "n", "t" },
            keys = "<A-r>",
            rhs = actions.rename,
            desc = "Term: NodeRename",
        },
        {
            modes = { "n", "t" },
            keys = "<A-R>",
            rhs = actions.restart,
            desc = "Term: NodeRestart",
        },
        {
            modes = { "n", "t" },
            keys = "<A-.>",
            rhs = actions.switch_next,
            desc = "Term: NodeSwitchNext",
        },
        {
            modes = { "n", "t" },
            keys = "<A-,>",
            rhs = actions.switch_prev,
            desc = "Term: NodeSwitchNext",
        },
        {
            modes = { "n", "t" },
            keys = "<A-q>",
            rhs = actions.delete_confirm,
            desc = "Term: NodeDeleteWithConfirm",
        },
        {
            modes = { "n", "t" },
            keys = "<A-S-q>",
            rhs = actions.delete_noconfirm,
            desc = "Term: NodeDeleteNoConfirm",
        },
    },
    ---@type {modes:string|string[],keys:string|string[],rhs:string|fun(panel,node),desc?:string}[]
    panelbuf = {
        {
            modes = { "n", "t" },
            keys = { "<A-;>", "a" },
            rhs = actions.add_term_input,
            desc = "Term: AppendNewTermNode",
        },
        {
            modes = { "n", "v" },
            keys = { "<A-'>", "A" },
            rhs = actions.add_group_input,
            desc = "Term: AppendNewGroupNode",
        },
        {
            modes = { "n", "v" },
            keys = { "<A-/>" },
            rhs = actions.add_term_and_focus,
            desc = "Term: AppendNewTermNode(default)",
        },
        {
            modes = { "n", "v" },
            keys = { "<space>", "<cr>", "<2-LeftMouse>" },
            rhs = actions.toggle_expand_or_set_curnode,
            desc = "Term: ToggleExpand",
        },
        {
            modes = { "n", "v" },
            keys = { "p" },
            rhs = actions.toggle_pin,
            desc = "Term: TogglePin",
        },
        {
            modes = { "n", "v" },
            keys = "r",
            rhs = actions.rename,
            desc = "Term: NodeRename",
        },
        {
            modes = { "n", "v" },
            keys = "R",
            rhs = actions.restart,
            desc = "Term: NodeRestart",
        },
        {
            modes = { "n", "v" },
            keys = "i",
            rhs = actions.inspect_node,
            desc = "Term: NodeInspect",
        },
        {
            modes = { "n", "v" },
            keys = "I",
            rhs = actions.inspect_tree,
            desc = "Term: TreeInspect",
        },
        {
            modes = { "n", "v" },
            keys = { "J", "." },
            rhs = actions.switch_next,
            desc = "Term: NodeSwitchNext",
        },
        {
            modes = { "n", "v" },
            keys = { "K", "," },
            rhs = actions.switch_prev,
            desc = "Term: NodeSwitchPrev",
        },
        {
            modes = { "n", "v" },
            keys = { "h" },
            rhs = actions.swap_with_prev,
            desc = "Term: SwapWithPrev",
        },
        {
            modes = { "n", "v" },
            keys = { "l" },
            rhs = actions.swap_with_next,
            desc = "Term: SwapWithNext",
        },
        {
            modes = { "n", "v" },
            keys = { "x", "<A-q>" },
            rhs = actions.delete_confirm,
            desc = "Term: NodeDeleteWithConfirm",
        },
        {
            modes = { "n", "v" },
            keys = { "X", "<A-S-q>" },
            rhs = actions.delete_noconfirm,
            desc = "Term: NodeDeleteNoConfirm",
        },
    },
    map = map,
}
