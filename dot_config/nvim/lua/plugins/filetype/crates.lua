--rust crates.io
return {
    "saecki/crates.nvim",
    version = "*",
    lazy = true,
    event = { "BufRead Cargo.toml" },
    config = function()
        require("crates").setup({})
        local commands = {
            { cmd = "<cmd>lua require('crates').toggle()<cr>", desc = "Toggle crates" },
            { cmd = "<cmd>lua require('crates').reload()<cr>", desc = "Reload crates" },

            {
                cmd = "<cmd>lua require('crates').show_versions_popup()<cr>",
                desc = "Cargo.toml:Show versions popup",
            },
            {
                cmd = "<cmd>lua require('crates').show_features_popup()<cr>",
                desc = "Cargo.toml:Show features popup",
            },
            {
                cmd = "<cmd>lua require('crates').show_dependencies_popup()<cr>",
                desc = "Cargo.toml:Show dependencies popup",
            },
            {
                cmd = "<cmd>lua require('crates').update_crate()<cr>",
                desc = "Cargo.toml:Update crate",
            },
            {
                cmd = "<cmd>lua require('crates').update_crates()<cr>",
                desc = "Cargo.toml:Update crates (visual)",
            },
            {
                cmd = "<cmd>lua require('crates').update_all_crates()<cr>",
                desc = "Cargo.toml:Update all crates",
            },
            {
                cmd = "<cmd>lua require('crates').upgrade_crate()<cr>",
                desc = "Cargo.toml:Upgrade crate",
            },
            {
                cmd = "<cmd>lua require('crates').upgrade_crates()<cr>",
                desc = "Cargo.toml:Upgrade crates (visual)",
            },
            {
                cmd = "<cmd>lua require('crates').upgrade_all_crates()<cr>",
                desc = "Cargo.toml:Upgrade all crates",
            },
            {
                cmd = "<cmd>lua require('crates').open_homepage()<cr>",
                desc = "Cargo.toml:Open homepage",
            },
            {
                cmd = "<cmd>lua require('crates').open_repository()<cr>",
                desc = "Cargo.toml:Open repository",
            },
            {
                cmd = "<cmd>lua require('crates').open_documentation()<cr>",
                desc = "Cargo.toml:Open documentation",
            },
            {
                cmd = "<cmd>lua require('crates').open_crates_io()<cr>",
                desc = "Cargo.toml:Open crates.io",
            },
        }
        require("commander").add(commands)
    end,
}
