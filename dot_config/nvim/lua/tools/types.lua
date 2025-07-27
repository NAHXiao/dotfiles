---@class task
---@field name string
---@field cmds string[]
---@field mode ("debug"|"release"|"") default ""
---@field type ("project"|"file"|"") default ""
---@field filetypes string[]|{} default {} 表通用
---@field field "global"|"locall"|string don't need to set
---@field opts table default extend

---@class utask
---@field name string
---@field cmds string[]
---@field mode? ("debug"|"release"|"") default ""
---@field type? ("project"|"file"|"") default ""
---@field filetypes? string[]|{} default {}
---@field opts? table default extend

---@class taskset
---@field name string
---@field break_on_err boolean default true
---@field seq boolean default true
---@field field "global"|"locall"|string don't need to set
---@field [integer] {[1]:string,ignore_err?:boolean,bg:boolean}

---@class utaskset
---@field name string
---@field break_on_err? boolean default true
---@field seq? boolean default true
---@field [integer] {[1]:string,ignore_err?:boolean,bg?:boolean}|string


---@alias items (taskset|task)[]



---@alias comp_func fun(a,b):boolean
---@alias comp_order
---| ["field", "isset", "tasktype", "taskmode"]
---| ["field", "isset", "taskmode", "tasktype"]
---| ["field", "tasktype", "isset", "taskmode"]
---| ["field", "tasktype", "taskmode", "isset"]
---| ["field", "taskmode", "isset", "tasktype"]
---| ["field", "taskmode", "tasktype", "isset"]
---| ["isset", "field", "tasktype", "taskmode"]
---| ["isset", "field", "taskmode", "tasktype"]
---| ["isset", "tasktype", "field", "taskmode"]
---| ["isset", "tasktype", "taskmode", "field"]
---| ["isset", "taskmode", "field", "tasktype"]
---| ["isset", "taskmode", "tasktype", "field"]
---| ["tasktype", "field", "isset", "taskmode"]
---| ["tasktype", "field", "taskmode", "isset"]
---| ["tasktype", "isset", "field", "taskmode"]
---| ["tasktype", "isset", "taskmode", "field"]
---| ["tasktype", "taskmode", "field", "isset"]
---| ["tasktype", "taskmode", "isset", "field"]
---| ["taskmode", "field", "isset", "tasktype"]
---| ["taskmode", "field", "tasktype", "isset"]
---| ["taskmode", "isset", "field", "tasktype"]
---| ["taskmode", "isset", "tasktype", "field"]
---| ["taskmode", "tasktype", "field", "isset"]
---| ["taskmode", "tasktype", "isset", "field"]
---@alias comp {field:comp_func,isset:comp_func,tasktype:comp_func,taskmode:comp_func,order:comp_order}



---@class keys_tbl
---@field name string
---@field mode ("debug"|"release"|"") default ""
---@field type ("project"|"file"|"") default ""
---@field filetypes string[]|{} default {}
---@alias task_keys string
