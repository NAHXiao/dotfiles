- after del a uniqnode and add a uniqnode with the same uniqname
```
Error executing vim.schedule lua callback: D:/Users/wangsf/AppData/Local/nvim/lua/tools/term.lua:17: assertion failed!
stack traceback:
	[C]: in function 'assert'
	D:/Users/wangsf/AppData/Local/nvim/lua/tools/term.lua:17: in function 'unreachable'
	D:/Users/wangsf/AppData/Local/nvim/lua/tools/term.lua:718: in function 'delnode'
	D:/Users/wangsf/AppData/Local/nvim/lua/tools/term.lua:1060: in function 'delnode'
	D:/Users/wangsf/AppData/Local/nvim/lua/tools/term.lua:1124: in function 'append_taskterm_node'
	D:/Users/wangsf/AppData/Local/nvim/lua/tools/term.lua:1627: in function 'newtask'
	D:/Users/wangsf/AppData/Local/nvim/lua/tools/task.lua:1019: in function 'run_task'
	D:/Users/wangsf/AppData/Local/nvim/lua/tools/task.lua:1209: in function 'callback'
	D:/Users/wangsf/AppData/Local/nvim/lua/tools/task.lua:856: in function 'fn'
	vim/_editor.lua:366: in function <vim/_editor.lua:365>

```
- ovsv
