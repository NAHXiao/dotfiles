--rust crates.io
return {
    "saecki/crates.nvim",
    version = "*",
    lazy = true,
    event = { "BufRead Cargo.toml" },
    config = function()
        require('crates').setup({})
        local opts = { silent = true, noremap = true }
        vim.keymap.set('n', '<leader>ct', function() require("crates").toggle() end, opts)
        vim.keymap.set('n', '<leader>cr', function() require("crates").reload() end, opts)

        vim.keymap.set('n', '<leader>cv', function() require("crates").show_versions_popup() end, opts)
        vim.keymap.set('n', '<leader>cf', function() require("crates").show_features_popup() end, opts)
        vim.keymap.set('n', '<leader>cd', function() require("crates").show_dependencies_popup() end, opts)

        vim.keymap.set('n', '<leader>cu', function() require("crates").update_crate() end, opts)
        vim.keymap.set('v', '<leader>cu', function() require("crates").update_crates() end, opts)
        vim.keymap.set('n', '<leader>ca', function() require("crates").update_all_crates() end, opts)
        vim.keymap.set('n', '<leader>cU', function() require("crates").upgrade_crate() end, opts)
        vim.keymap.set('v', '<leader>cU', function() require("crates").upgrade_crates() end, opts)
        vim.keymap.set('n', '<leader>cA', function() require("crates").upgrade_all_crates() end, opts)

        vim.keymap.set('n', '<leader>cH', function() require("crates").open_homepage() end, opts)
        vim.keymap.set('n', '<leader>cR', function() require("crates").open_repository() end, opts)
        vim.keymap.set('n', '<leader>cD', function() require("crates").open_documentation() end, opts)
        vim.keymap.set('n', '<leader>cC', function() require("crates").open_crates_io() end, opts)
    end,
}
