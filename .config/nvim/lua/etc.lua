local utils = require("utils")
local g = vim.g
local uv = vim.uv or vim.loop
local osname = uv.os_uname().sysname
-- projroot TODO: Bind To LspAttach workspace_folders[1].name
g.projroot = nil
g.root_marker = {
	-- 版本控制
	".git",
	".svn",
	".hg",
	".bzr",
	"_darcs",
	".fslckout",
	-- 构建系统
	"Makefile",
	"CMakeLists.txt",
	"Cargo.toml",
	"pyproject.toml",
	"pom.xml",
	"build.gradle",
	"package.json",
	"go.mod",
	-- IDE/编辑器
	".project",
	".root",
	".vscode",
	".idea",
	".projectile",
	-- 工具配置
	"compile_commands.json",
	".clang-format",
	".editorconfig",
	".stylua.toml",
	-- 其他
	".repo",
	".gitignore",
}
local function set_global_project_root()
	g.projroot = utils.findfile_any({
		filelist = g.root_marker,
		startpath = vim.fn.getcwd(),
		use_first_found = false,
		return_dirname = true,
	}) or vim.fn.getcwd()
end
set_global_project_root()
vim.api.nvim_create_autocmd("DirChanged", {
	callback = function()
		set_global_project_root()
	end,
})
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	callback = function()
		local buftype = vim.bo.buftype
		local name = vim.api.nvim_buf_get_name(0)
		if buftype == "" and name ~= "" then
			vim.b.projroot = utils.findfile_any({ -- For Common Buffer : it's projroot or it's parent dir ; For Other : nil
				filelist = vim.g.root_marker,
				startpath = vim.fn.fnamemodify(name, ":p:h"),
				use_first_found = false,
				return_dirname = true,
			}) or vim.fn.fnamemodify(name, ":p:h")
			-- For asyncrun
			vim.b.asyncrun_root = vim.b.projroot
		end
	end,
})
-- obsidian
do
	local obsidianpath
	if osname == "Windows_NT" then
		obsidianpath = "E:/Obsidian/main"
	elseif osname == "Linux" then
		if g.is_wsl then
			obsidianpath = "/mnt/e/Obsidian/main"
		else
			obsidianpath = os.getenv("HOME") .. "/.local/Obsidian/main"
		end
	else
		obsidianpath = nil
	end
	if obsidianpath ~= nil and uv.fs_stat(obsidianpath) then
		g.obsidianPath = obsidianpath
	end
end

-- keyboard
if vim.g.is_wsl or vim.g.is_win then
	local im_select = vim.fs.normalize(vim.fn.stdpath("config") .. "/bin/im-select.exe")
	local im_select_mspy = vim.fs.normalize(vim.fn.stdpath("config") .. "/bin/im-select-mspy.exe")
	local pending_process = {
		insert_enter = nil,
		insert_leave = nil,
	}

	-- 带超时检查的进程终止器
	local function safe_terminate(process, timeout)
		if not process or process:is_closing() then
			return
		end

		local timer = vim.loop.new_timer()
		timer:start(timeout or 50, 0, function()
			timer:stop()
			timer:close()
			if not process:is_closing() then
				process:kill(15) -- SIGTERM
				vim.defer_fn(function()
					if not process:is_closing() then
						process:kill(9) -- SIGKILL
					end
				end, 10)
			end
		end)
	end

	vim.schedule(function()
		vim.system({ im_select, "1033" }, { text = true })
	end)
	vim.api.nvim_create_augroup("IME_Control", { clear = true })
	vim.api.nvim_create_autocmd("InsertLeavePre", { --En
		group = "IME_Control",
		pattern = "*",
		callback = function()
			if pending_process.insert_enter and not pending_process.insert_enter:is_closing() then
				safe_terminate(pending_process.insert_enter)
			end
			vim.defer_fn(function()
				pending_process.insert_leave = vim.system({ im_select, "1033" }, { text = true }, function()
					pending_process.insert_leave = nil
				end)
			end, 1)
		end,
	})

	vim.api.nvim_create_autocmd("InsertEnter", { -- Py.En
		group = "IME_Control",
		pattern = "*",
		callback = function()
			if pending_process.insert_leave and not pending_process.insert_leave:is_closing() then
				safe_terminate(pending_process.insert_leave)
			end
			vim.defer_fn(function()
				pending_process.insert_enter = vim.system({ im_select, "2052" }, { text = true }, function()
					pending_process.insert_enter = vim.system(
						{ im_select_mspy, "英语模式" },
						{ text = true },
						function()
							pending_process.insert_enter = nil
						end
					)
				end)
			end, 1)
		end,
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = "IME_Control",
		pattern = "*",
		callback = function()
			vim.system({ im_select, "2052" }, { text = true }):wait()
		end,
	})
end

-- 终端终止时自动进入normal模式
vim.api.nvim_create_autocmd("TermClose", {
	callback = function(ctx)
		if vim.api.nvim_get_current_buf() == ctx.buf then
			vim.cmd("stopinsert")
		end
	end,
})
--对于已终止的term禁止进入term-insert模式
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.api.nvim_create_autocmd("ModeChanged", {
			buffer = 0,
			callback = function()
				local mode = vim.fn.mode()
				if mode == "t" then
					local status = vim.fn.jobwait({ vim.b.terminal_job_id }, 0)[1]
					if status ~= -1 then
						vim.cmd("stopinsert")
					end
				end
			end,
		})
	end,
})

--禁用保存后的提示
vim.cmd("autocmd BufWritePost * silent! !clear")
