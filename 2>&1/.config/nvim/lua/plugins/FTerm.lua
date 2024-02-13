return {
    "numToStr/FTerm.nvim",
    version = "*",
    lazy = true,
    config = function()
        local oscmd
        local os =vim.loop.os_uname().sysname;
        if os == 'Windows_NT' then
            oscmd = "bash"
        elseif os == "Linux" then
            oscmd = "zsh"
        else
            -- oscmd = "zsh"
           oscmd = os.getenv("SHELL")
        end
        require('FTerm').setup({
            border     = 'single',
            -- cmd = os.getenv('SHELL'),
            cmd        = oscmd,
            blend      = 0,
            dimensions = {
                height = 0.9,
                width = 0.9,
            },
        })
    end,
}
