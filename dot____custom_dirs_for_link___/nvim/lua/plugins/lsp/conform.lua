local conform_cond = vim.version.cmp(vim.version(), "0.8.0") >= 0;
local conform_branch;
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
    version = '*',
    branch = conform_branch,
    cond = conform_cond,
    event = 'UIEnter',
    keys = {
        {
            "<space>fo",
            function()
                require("conform").format({ async = true }, function(err)
                    if not err then
                        local mode = vim.api.nvim_get_mode().mode
                        if vim.startswith(string.lower(mode), "v") then
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
                        end
                    end
                end)
            end,
            desc = "Format",
            mode = { "n", "v" },
        },
        {
            "<space>fO",
            function()
                require("conform").format({ async = true, force = true }, function(err)
                    if not err then
                        local mode = vim.api.nvim_get_mode().mode
                        if vim.startswith(string.lower(mode), "v") then
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
                        end
                    end
                end)
            end,
            desc = "Format (force)",
            mode = { "n", "v" },
        },
    },
    dependencies = {
    },
    config = function()
        -- $FILENAME - 文件的绝对路径 $DIRNAME - 包含该文件的目录的绝对路径 $RELATIVE_FILEPATH - 文件的相对路径 $EXTENSION - .py .cpp
        local conform_util = require("conform.util")
        local formatters_clang_format = {}
        do
            local c_standards = { "c89", "c99", "c11" }
            local cpp_standards = { "c++98", "c++03", "c++11", "c++14", "c++17", "c++20", "c++23" }
            local function make_clang_formatter(name, filename_hint, fallback_style)
                local root = vim.g.ProjectRoot
                local clang_file = root .. "/.clang-format"
                local use_project_file = vim.fn.filereadable(clang_file) == 1
                local style_arg
                if use_project_file then
                    style_arg = "--style=file"
                elseif vim.fn.filereadable(fallback_style) == 1 then
                    style_arg = "--style=file:" .. fallback_style
                else
                    style_arg = "--style=" .. fallback_style
                end

                return {
                    command = "clang-format",
                    args = {
                        "--assume-filename=" .. filename_hint,
                        style_arg,
                    },
                    stdin = true,
                    cwd = function() return root end,
                    require_cwd = false,
                    inherit = false,
                }
            end
            local local_clang_format_path = vim.fn.stdpath("config") .. "/lua/plugins/lsp/.clang-format"
            local local_clang_format_valid = vim.fn.filereadable(local_clang_format_path) == 1
            for _, std in ipairs(c_standards) do
                local key = "clang_" .. std:gsub("%+", "p"):gsub("%-", "")
                formatters_clang_format[key] = make_clang_formatter(key, "example." .. std,
                    local_clang_format_valid and local_clang_format_path or "Google"
                )
            end
            for _, std in ipairs(cpp_standards) do
                local key = "clang_" .. std:gsub("%+", "p"):gsub("%-", "")
                formatters_clang_format[key] = make_clang_formatter(key, "example." .. std,
                    local_clang_format_valid and local_clang_format_path or "Google"
                )
            end
            -- e.g. clang_c89 clang_cpp23
        end
        -- :help conform-formatters
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "pyink" },
                javascript = { "standardjs" },
                asm = { "asmfmt" },
                cpp = { "clang_cpp23" },
                c = { "clang-format" },
                yaml = { "yamlfmt" },
                java = { "google-java-format" },
                rust = { "rustfmt" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            formatters = vim.tbl_extend("force", formatters_clang_format, {})
        })
        -- local origin_vim_lsp_buf_format = vim.lsp.buf.format
        -- vim.lsp.buf.format = function(opts)
        --     return require("conform").format({ async = true })
        -- end
    end,
}
