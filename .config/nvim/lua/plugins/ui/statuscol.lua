return {
    "luukvbaal/statuscol.nvim",
    enabled = true,
    event = { "VeryLazy","BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
        local builtin = require("statuscol.builtin")
        local ffi = require("statuscol.ffidef")
        local C = ffi.C

        -- only show fold level up to this level
        local fold_level_limit = 2
        local function foldfunc(args)
            local foldinfo = C.fold_info(args.wp, args.lnum)
            if foldinfo.level > fold_level_limit then
                return " "
            end

            return builtin.foldfunc(args)
        end
        require("statuscol").setup({
            relculright = true,
            ft_ignore = { "neo-tree", "neotree" },
            bt_ignore = {'acwrite','help','nofile','nowrite','quickfix','terminal','prompt'},
            segments = {
                {
                    sign = {
                        name = { ".*" },
                        text = { ".*" },
                    },
                    click = "v:lua.ScSa",
                },
                { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                -- { text = { " " } },
                {
                    sign = { namespace = { "gitsigns" }, colwidth = 1, wrap = true },
                    click = "v:lua.ScSa",
                },
                -- { text = { " " } },
                { text = { foldfunc }, click = "v:lua.ScFa" },
                { text = { " " } },
            },
        })
    end,
}
