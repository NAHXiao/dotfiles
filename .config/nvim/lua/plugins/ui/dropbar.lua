return {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    keys = {
        {
            "HP",
            function()
                require("dropbar.api").pick()
            end,
            desc = "DropbarPick",
        },
    },
    opts = {
        bar = {
            enable = function(buf, win, _)
                if
                    not vim.api.nvim_buf_is_valid(buf)
                    or not vim.api.nvim_win_is_valid(win)
                    or vim.fn.win_gettype(win) ~= ""
                    or vim.wo[win].winbar ~= ""
                    or vim.bo[buf].ft == "help"
                    or vim.bo[buf].ft == "neo-tree-preview"
                    or vim.bo[buf].buftype == "terminal"
                    or vim.bo[buf].buftype == "nofile"
                    or vim.w[win].neo_tree_preview == 1
                then
                    return false
                end
                return vim.bo[buf].ft == "markdown"
                    or pcall(vim.treesitter.get_parser, buf)
                    or not vim.tbl_isempty(vim.lsp.get_clients({
                        bufnr = buf,
                        method = "textDocument/documentSymbol",
                    }))
            end,
            sources = function(buf, _)
                local sources = require("dropbar.sources")
                local filename = {
                    get_symbols = function(buff, win, cursor)
                        local symbols =
                            require("dropbar.sources").path.get_symbols(buff, win, cursor)
                        return { symbols[#symbols] }
                    end,
                }
                if vim.bo[buf].ft == "markdown" then
                    return { filename, sources.markdown }
                end
                local utils = require("dropbar.utils")
                return {
                    filename,
                    utils.source.fallback({
                        sources.lsp,
                        sources.treesitter,
                    }),
                }
            end,
            update_debounce = 300
        },
    },
    config = function(_, opts)
        require("dropbar").setup(opts)
        vim.api.nvim_set_hl(0, "WinBar", { link = "Normal" })
        vim.api.nvim_set_hl(0, "WinBarNC", { link = "Normal" })
        require "tools.hl".register_transparent({ "WinBar", "WinBarNC"
        }, { dependency = "inner<-inner", type = "transparent" })
    end,
}
