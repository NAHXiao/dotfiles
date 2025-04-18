------------------------------------
-- Nvim UFO - GOOD FOLDING      ----
--https://github.com/kevinhwang91/nvim-ufo
-- ---------------------------------
-- 代码折叠

return {
    "kevinhwang91/nvim-ufo",
    version = "*",
    cond = false,
    lazy = true,
    event = "InsertEnter",
    dependencies = {
        "kevinhwang91/promise-async",
    },
    config = function()
        vim.cmd("augroup MyColors; autocmd!; augroup end")

        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        -- Option 3: treesitter as a main provider instead
        -- Only depend on `nvim-treesitter/queries/filetype/folds.scm`,
        -- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
        -- require('ufo').setup({
        --     provider_selector = function(bufnr, filetype, buftype)
        --         return {'treesitter', 'indent'}
        --     end
        -- })
        local handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = ("   %d "):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    -- str width returned from truncate() may less than 2nd argument, need padding
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end
            table.insert(newVirtText, { suffix, "MoreMsg" })
            return newVirtText
        end

        -- Hide foldcolumn for transparency
        vim.opt.foldcolumn = "0"
        ------------------------

        require("ufo").setup({
            fold_virt_text_handler = handler,

            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
        })
        -------------------------
        local bufnr = vim.api.nvim_get_current_buf()
        require("ufo").setFoldVirtTextHandler(bufnr, handler)
    end,
}
