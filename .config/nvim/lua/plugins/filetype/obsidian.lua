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
        wiki_link_func = function(opts)
            return require("obsidian.util").wiki_link_id_prefix(opts)
        end,
        markdown_link_func = function(opts)
            return require("obsidian.util").markdown_link(opts)
        end,

        -- Either 'wiki' or 'markdown'.
        preferred_link_style = "wiki",
        frontmatter = {
            enable = true,
            ---@type fun(note: obsidian.Note): table<string, any>
            func = function(note)
                local out = vim.deepcopy(vim.F.if_nil(note.metadata, {}))
                --不存在则加入
                for k, v in pairs {
                    id = note.id,
                    aliases = note.aliases,
                    tags = note.tags,
                    create_date = os.date("%Y-%m-%d %H:%M:%S"),
                    title = vim.fn.fnamemodify(note:fname() or "", ":t:r"),
                } do
                    out[k] = out[k] or v
                end
                --强制覆盖
                for k, v in pairs {
                    modify_data = os.date("%Y-%m-%d %H:%M:%S"),
                } do
                    out[k] = v
                end
                return out
            end,
        },

        -- Optional, alternatively you can customize the frontmatter data.
        templates = {
            enable = false,
            folder = "Templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M:%S",
            -- A map for custom variables, the key should be the variable and the value a function
            substitutions = {},
        },
        ---@param url string
        follow_url_func = function(url)
            if jit.os == "Windows" then
                vim.cmd(':silent exec "!start ' .. url .. '"')
            elseif jit.os == "Linux" then
                if vim.fn.has("wsl") then
                    vim.fn.jobstart { "wslopen", url }
                else
                    vim.fn.jobstart { "xdg-open", url }
                end
            else
                vim.notify("Obsidian: follow_url_func(): Unsupported OS")
            end
        end,
        ---@param img string
        follow_img_func = function(img)
            if jit.os == "Windows" then
                vim.cmd(':silent exec "!start ' .. img .. '"')
            elseif jit.os == "Linux" then
                if vim.fn.has("wsl") then
                    vim.fn.jobstart { "wslopen", img }
                else
                    vim.fn.jobstart { "xdg-open", img }
                end
            else
                vim.notify("Obsidian: follow_img_func(): Unsupported OS")
            end
        end,
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
            img_folder = "assets",
        },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)
        --https://github.com/epwalsh/obsidian.nvim/issues/669  (无法跳转中文标题)
        require("obsidian.util").ANCHOR_LINK_PATTERN = "#[%w%d\u{4e00}-\u{9fff}][^#]*"
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

        local Patterns = require("obsidian.search").Patterns
        Patterns.TagCharsOptional = "[A-Za-z\u{4e00}-\u{9fff}0-9_/-]*"
        Patterns.TagCharsRequired =
            "[A-Za-z\u{4e00}-\u{9fff}]+[A-Za-z\u{4e00}-\u{9fff}0-9_/-]*[A-Za-z\u{4e00}-\u{9fff}0-9]+"
        Patterns.Tag =
            "#[A-Za-z\u{4e00}-\u{9fff}]+[A-Za-z\u{4e00}-\u{9fff}0-9_/-]*[A-Za-z\u{4e00}-\u{9fff}0-9]+"
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
