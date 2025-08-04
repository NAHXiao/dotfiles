local utils = require("utils")
local conform_cond = vim.version.cmp(vim.version(), "0.8.0") >= 0
local conform_branch
-- *
-- nvim-0.9
-- nvim-0.8
if vim.version.cmp(vim.version(), "0.10.0") >= 0 then
    conform_branch = "master"
elseif vim.version.cmp(vim.version(), "0.9.0") >= 0 then
    conform_branch = "nvim-0.9"
elseif vim.version.cmp(vim.version(), "0.8.0") >= 0 then
    conform_branch = "nvim-0.8"
end
return {
    "stevearc/conform.nvim",
    branch = conform_branch,
    cond = conform_cond,
    event = "UIEnter",
    keys = {
        {
            "gQ",
            function()
                require("conform").format({ async = true }, function(err)
                    if not err then
                        local mode = vim.api.nvim_get_mode().mode
                        if vim.startswith(string.lower(mode), "v") then
                            vim.api.nvim_feedkeys(
                                vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                                "m",
                                true
                            )
                        end
                    end
                end)
            end,
            desc = "Format",
            mode = { "n", "v" },
        },
    },
    dependencies = {},
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "pyink" },
                javascript = { "standardjs" },
                asm = { "asmfmt" },
                cpp = { "clang-format-" },
                c = { "clang-format-" },
                yaml = { "yamlfmt" },
                java = { "google-java-format" },
                rust = { "rustfmt" },
            },
            default_format_opts = {
                lsp_format = "fallback",
                cwd = function()
                    return vim.b.projroot or vim.g.projroot
                end,
            },
            formatters = {
                ["clang-format-"] = {
                    command = "clang-format",
                    args = function()
                        local local_clang_format_path = vim.fn.stdpath("config")
                            .. "/lua/plugins/lsp/.clang-format"
                        local local_clang_format_valid = vim.fn.filereadable(
                            local_clang_format_path
                        ) == 1
                        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
                        local confpath = utils.GetRoot({ ".clang-format", "_clang_format" }, {
                            startpath = path,
                            use_first_found = true,
                            return_dirname = false,
                        })
                        local args = {
                            "--assume-filename=" .. (vim.fn.expand("%:t") or "example.cpp"),
                        }
                        if confpath == nil then
                            args[#args + 1] = "--style="
                                .. (
                                    local_clang_format_valid
                                        and ("file:" .. local_clang_format_path)
                                    or "Google"
                                )
                        end
                        return args
                    end,
                    stdin = true,
                    -- cwd = function()
                    --
                    -- end,
                    require_cwd = false,
                    inherit = false,
                },
            },
            -- formatters = vim.tbl_extend("force", formatters_clang_format, {})
        })
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
