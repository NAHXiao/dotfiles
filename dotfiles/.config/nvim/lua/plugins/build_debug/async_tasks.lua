return {
    "skywind3000/asynctasks.vim",
    version = "*",
    keys = {
        { "<F6>", "<cmd>AsyncTask build<cr>",     desc = "build" },
        { "<F7>", "<cmd>AsyncTask run<cr>",       desc = "run" },
        { "<F8>", "<cmd>AsyncTask run_input<cr>", desc = "run_input" },
    },
    lazy = true,
    dependencies = {
        "skywind3000/asyncrun.vim",
    },
    config = function()
        vim.g.asynctasks_extra_config = {
            vim.fn.stdpath("config") .. "/lua/plugins/build_debug/asynctasks.ini",
        }
        vim.g.asynctasks_term_rows = 10
        vim.g.asynctasks_confirm = 0

        -- local tasks = vim.api.nvim_call_function('asynctasks#list("")');

        vim.cmd([[
function! s:fzf_sink(what)
	let p1 = stridx(a:what, '<')
	if p1 >= 0
		let name = strpart(a:what, 0, p1)
		let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
		if name != ''
			exec "AsyncTask ". fnameescape(name)
		endif
	endif
endfunction

function! s:fzf_task()
	let rows = asynctasks#source(&columns * 48 / 100)
	let source = []
	for row in rows
		let name = row[0]
		let source += [name . '  ' . row[1] . '  : ' . row[2] ]
	endfor
	let opts = { 'source': source, 'sink': function('s:fzf_sink'),
				\ 'options': '+m --nth 1 --inline-info --tac' }
	if exists('g:fzf_layout')
		for key in keys(g:fzf_layout)
			let opts[key] = deepcopy(g:fzf_layout[key])
		endfor
	endif
	call fzf#run(opts)
endfunction

command! -nargs=0 AsyncTaskFzf call s:fzf_task()
]])

    end,
}
