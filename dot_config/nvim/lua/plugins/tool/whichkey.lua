local expand_keys_prefixs = {
    "<leader>f",
    "<leader><space>",
    "<leader>\\",
    "<leader>a",
}
---@type string[][]
local formatted_expand_keys_prefixs
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        delay = vim.o.timeoutlen / 2,
        ---@type wk.Win.opts
        win = {
            no_overlap = false,
        },
        ---@type number|fun(node: wk.Node):boolean?
        expand = function(node)
            if not formatted_expand_keys_prefixs then
                formatted_expand_keys_prefixs = vim.iter(expand_keys_prefixs)
                    :map(function(it)
                        return require("which-key.util").keys(it)
                    end)
                    :totable()
            end
            if node.parent and node.parent.path and #node.parent.path > 0 then
                for _, path in ipairs(formatted_expand_keys_prefixs) do
                    if vim.deep_equal(path, node.parent.path) then
                        return true
                    end
                end
            end
            return false
        end,
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show { global = false }
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
    config = function(_, opts)
        require("which-key").setup(opts)
        require("which-key").add {
            { "<leader>a", group = "Ai" },
            { "<leader>b", group = "Buffer" },
            { "<leader>d", group = "Debug" },
            { "<leader>f", group = "Find" },
            { "<leader>l", group = "Lsp" },
            { "<leader>g", group = "GitSigns" },
            { "<leader>t", group = "Trouble" },
            { "<leader>\\", group = "Switch" },
            { "<leader><leader>", group = "Buffer Local Keymaps" },
        }
    end,
}
