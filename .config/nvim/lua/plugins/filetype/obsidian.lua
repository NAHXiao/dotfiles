local arg1 = "obsidian"
return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = vim.fn.argv()[1] ~= arg1,
    event = {
        vim.g.obsidianPath and "BufReadPre " .. vim.g.obsidianPath .. "/*.md" or nil,
        vim.g.obsidianPath and "BufNewFile  " .. vim.g.obsidianPath .. "/*.md" or nil,
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "saghen/blink.cmp",
        "nvim-telescope/telescope.nvim",
    },
    opts = {
        legacy_commands = false,
        workspaces = {
            {
                name = "main",
                path = vim.g.obsidianPath,
            },
        },
        completion = {
            nvim_cmp = false,
            blink = true,
        },
        log_level = vim.log.levels.INFO,
        daily_notes = {
            folder = "Diary",
            default_tags = { "日记" },
            -- template = "diary.md",
        },
        new_notes_location = "current_dir",
        frontmatter = {
            enable = true,
            ---@type folder = "Templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M:%S",
            -- A map for custom variables, the key should be the variable and the value a function
            substitutions = {},
        },
        picker = {
            name = "telescope.nvim",
            -- Optional, configure key mappings for the picker. These are the defaults.
            -- Not all pickers support all mappings.
            note_mappings = {
                -- Create a new note from your query.
                new = "<C-x>",
                -- Insert a link to the selected note.
                insert_link = "<C-l>",
            },
            tag_mappings = {
                -- Add tag(s) to current note.
                tag_note = "<C-x>",
                -- Insert a tag at the current location.
                insert_tag = "<C-l>",
            },
        },
        search = { max_lines = 1000, sort_by = "modified", sort_reversed = true },
        ---@type "current"|"vsplit"|"hsplit"
        open_notes_in = "current",
        ui = {
            enable = false,
            update_debounce = 200,
            max_file_length = 5000,
            checkbox = {
                order = { " ", "x", ">", "~", "!" },
            },
        },
        attachments = {
            folder = "assets",
        },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)
        ---@type fun(templateName:string):string[]
        local function loadTemplates(templateName)
            local templateFilePath =
                vim.fs.joinpath(vim.g.obsidianPath, "/Templates", templateName .. ".lua")
            if vim.fn.filereadable(templateFilePath) == 0 then
                return {}
            end
            local ok, content = pcall(
                loadfile(templateFilePath) or function() end,
                vim.g.obsidianPath,
                "Templates",
                "Templates/scripts"
            )
            if ok and type(content) == "string" then
                return vim.split(content, "\n")
            end
            return {}
        end

        -- --https://github.com/epwalsh/obsidian.nvim/issues/669  (无法跳转中文标题)
        -- require("obsidian.util").ANCHOR_LINK_PATTERN = "#[%w%d\u{4e00}-\u{9fff}][^#]*"
        -- local Patterns = require("obsidian.search").Patterns
        -- Patterns.TagCharsOptional = "[A-Za-z\u{4e00}-\u{9fff}0-9_/-]*"
        -- Patterns.TagCharsRequired =
        --     "[A-Za-z\u{4e00}-\u{9fff}]+[A-Za-z\u{4e00}-\u{9fff}0-9_/-]*[A-Za-z\u{4e00}-\u{9fff}0-9]+"
        -- Patterns.Tag =
        --     "#[A-Za-z\u{4e00}-\u{9fff}]+[A-Za-z\u{4e00}-\u{9fff}0-9_/-]*[A-Za-z\u{4e00}-\u{9fff}0-9]+"
        if vim.fn.argv()[1] == arg1 then
            vim.schedule(function()
                local bufnr = vim.fn.bufnr("obsidian")
                local buf_exists = bufnr and bufnr ~= -1
                if buf_exists then
                    vim.api.nvim_buf_delete(bufnr, { force = true })
                end
                vim.cmd.cd(vim.g.obsidianPath)
                local diary_file = vim.g.obsidianPath .. "/Diary/" .. os.date("%Y-%m-%d") .. ".md"
                -- 打开今日日记文件(Dairy/YYYY-MM-DD.md)
                vim.cmd.edit(diary_file)
                -- 不存在则创建并保存
                if vim.fn.filereadable(diary_file) == 0 then
                    vim.api.nvim_buf_set_lines(0, 0, -1, false, loadTemplates("diary"))
                    vim.cmd.write()
                end
                vim.keymap.set("n", "<localleader>", "<cmd>Obsidian<cr>")
            end)
        end
    end,
}
