local vim_echo = require("utils").vim_echo
return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
        "nvim-treesitter/nvim-treesitter",
    },
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    init = function()
        vim.o.foldcolumn = "1" -- '0' is not bad
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
    end,
    keys = {
        {
            "<leader>\\u",
            function()
                if require("ufo.main").disable() then
                    vim_echo("UFO: Disabled")
                else
                    assert(require("ufo.main").enable())
                    vim_echo("UFO: Enabled")
                end
            end,
            desc = "Toggle UfO Fold",
        },
        {
            "<leader>\\f",
            function()
                vim.o.foldenable = not vim.o.foldenable
                require("utils").vim_echo(
                    ("FoldEnable: %s"):format(vim.o.foldenable and "True" or "False")
                )
            end,
            desc = "Toggle Fold",
        },
    },
    config = function()
        require("ufo").setup({
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
            disabled = { "neo-tree" },
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (" 󰁂 %d lines "):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if curWidth + chunkWidth < targetWidth then
                        table.insert(newVirtText, chunk)
                        curWidth = curWidth + chunkWidth
                    else
                        chunk =
                            { vim.fn.strcharpart(chunkText, 0, targetWidth - curWidth), chunk[2] }
                        table.insert(newVirtText, chunk)
                        curWidth = targetWidth
                        break
                    end
                end
                table.insert(newVirtText, { suffix, "SpecialComment" })
                return newVirtText
            end,
        })
        -- vim.o.foldmethod = "expr"
        -- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
        vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
        -- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep:│,foldclose:]]
        -- vim.o.fillchars = [[eob: ,fold: ,foldopen:󰛲,foldsep:│,foldclose:󰜄]]

        vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Folds: OpenAll" })
        vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Folds: CloseAll" })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "neo-tree" },
            callback = function()
                require("ufo").detach()
                vim.opt_local.foldenable = false
                vim.opt_local.foldcolumn = "0"
            end,
        })
        vim.api.nvim_set_hl(0, "UfoFoldedEllipsis", { bg = nil })
    end,
}
