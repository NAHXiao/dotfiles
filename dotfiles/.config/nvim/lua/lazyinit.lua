local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
--
-- if not vim.loop.fs_stat(lazypath) then
-- 	vim.fn.system({
--         "bash",
--         "-c 'while ! git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable' "..lazypath.." ;do echo retry;done",
-- 	})
-- end

vim.opt.rtp:prepend(lazypath)
-- require("lazy").setup("plugins")
require("lazy").setup(
    {
        { import = "plugins.build_debug" },
        { import = "plugins.cmp" },
        { import = "plugins.edit" },
        { import = "plugins.filetype" },
        { import = "plugins.lib" },
        { import = "plugins.lsp" },
        { import = "plugins.tool" },
        { import = "plugins.ui" },
        { import = "plugins.telescope" },
    }
)
