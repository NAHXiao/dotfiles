-- FIXME:https://github.com/epwalsh/obsidian.nvim/issues/669  (无法跳转中文标题)
return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    -- ft = "markdown",
    event = {
        vim.g.obsidianPath and "BufReadPre " .. vim.g.obsidianPath .. "/*.md" or nil,
        vim.g.obsidianPath and "BufNewFile  " .. vim.g.obsidianPath .. "/*.md" or nil,
    },
    keys = {
        { "<leader>ofw", "<cmd>ObsidianSearch<cr>", desc = "搜索关键词" },
        { "<leader>off", "<cmd>ObsidianQuickSwitch<cr>", desc = "搜索Obsidian文件" },
        { "<leader>oft", "<cmd>ObsidianTags<cr>", desc = "搜索Obsidian Tag" },
        { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "打开/创建今日日记" },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        -- "hrsh7th/nvim-cmp",
        "saghen/blink.cmp",
    },
    opts = {
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
            -- Optional, if you keep daily notes in a separate directory.
            folder = "Diary",
            -- Optional, if you want to change the date format for the ID of daily notes.
            -- date_format = "%Y-%m-%d %H:%M:%S",
            -- Optional, if you want to change the date format of the default alias of daily notes.
            -- alias_format = "%Y-%m-%d %H:%M:%S",
            -- Optional, default tags to add to each new daily note created.
            default_tags = { "日记" },
            -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
            template = "diary.md",
        },
        -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
        -- way then set 'mappings = {}'.
        mappings = {
            -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
            ["gf"] = {
                action = function()
                    return require("obsidian").util.gf_passthrough()
                end,
                opts = { noremap = false, expr = true, buffer = true },
            },
            -- Toggle check-boxes.
            ["<leader>ch"] = {
                action = function()
                    return require("obsidian").util.toggle_checkbox()
                end,
                opts = { buffer = true },
            },
            -- Smart action depending on context, either follow link or toggle checkbox.
            ["<cr>"] = {
                action = function()
                    local last = "%!"
                    if require("obsidian").util.cursor_on_markdown_link(nil, nil, true) then
                        return "<cmd>ObsidianFollowLink<CR>"
                    elseif vim.fn.getline("."):match("^%s*%-%s*%[" .. last .. "%]") then
                        -- ^(%s*)%-%s*%[%!%](.*)%$
                        local spaces, rest =
                            vim.fn.getline("."):match("^(%s*)%-%s*%[" .. last .. "%](.*)")
                        spaces = spaces or ""
                        rest = rest or ""
                        vim.schedule(function()
                            local cur_line = vim.fn.line(".")
                            vim.api.nvim_buf_set_lines(0, cur_line - 1, cur_line, false, {
                                spaces .. (rest and (rest:len() > 0 and rest:sub(2) or "") or ""),
                            })
                        end)
                    else
                        return require("obsidian").util.smart_action()
                    end
                end,
                opts = { buffer = true, expr = true },
            },
            ["<S-CR>"] = {
                action = function()
                    return require("obsidian").util.smart_action()
                end,
                opts = { buffer = true, expr = true },
            },
        },

        -- Where to put new notes. Valid options are
        --  * "current_dir" - put new notes in same directory as the current buffer.
        --  * "notes_subdir" - put new notes in the default notes subdirectory.
        new_notes_location = "current_dir",

        -- Optional, customize how note IDs are generated given an optional title.
        ---@param title string|?
        ---@return string
        note_id_func = function(title)
            -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
            -- In this case a note with the title 'My new note' will be given an ID that looks
            -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
            local suffix = ""
            if title ~= nil then
                -- If title is given, transform it into valid file name.
                suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            else
                -- If title is nil, just add 4 random uppercase letters to the suffix.
                for _ = 1, 4 do
                    suffix = suffix .. string.char(math.random(65, 90))
                end
            end
            return tostring(os.time()) .. "-" .. suffix
        end,

        -- Optional, customize how note file names are generated given the ID, target directory, and title.
        ---@param spec { id: string, dir: obsidian.Path, title: string|? }
        ---@return string|obsidian.Path The full path to the new note.
        note_path_func = function(spec)
            -- This is equivalent to the default behavior.
            local path = spec.dir / tostring(spec.id)
            return path:with_suffix(".md")
        end,

        -- Optional, customize how wiki links are formatted. You can set this to one of:
        --  * "use_alias_only", e.g. '[[Foo Bar]]'
        --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
        --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
        --  * "use_path_only", e.g. '[[foo-bar.md]]'
        -- Or you can set it to a function that takes a table of options and returns a string, like this:
        wiki_link_func = function(opts)
            return require("obsidian.util").wiki_link_id_prefix(opts)
        end,

        -- Optional, customize how markdown links are formatted.
        markdown_link_func = function(opts)
            return require("obsidian.util").markdown_link(opts)
        end,

        -- Either 'wiki' or 'markdown'.
        preferred_link_style = "wiki",

        -- Optional, boolean or a function that takes a filename and returns a boolean.
        -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
        disable_frontmatter = false,

        -- Optional, alternatively you can customize the frontmatter data.
        ---@return table
        note_frontmatter_func = function(note)
            if note.title then
                note:add_alias(note.title)
            end
            -- 初始
            local out = { id = note.id, aliases = note.aliases, tags = note.tags }
            -- 覆盖
            if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                for k, v in pairs(note.metadata) do
                    out[k] = v
                end
            end
            -- 始终更新
            out["date"] = os.date("%Y-%m-%d %H:%M:%S")
            return out
        end,

        -- Optional, for templates (see below).
        templates = {
            folder = "Templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M:%S",
            -- A map for custom variables, the key should be the variable and the value a function
            substitutions = {},
        },

        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
        -- URL it will be ignored but you can customize this behavior here.
        ---@param url string
        follow_url_func = function(url)
            if vim.g.is_win then
                vim.cmd(':silent exec "!start ' .. url .. '"')
            elseif vim.g.is_nix then
                if vim.g.is_mac then
                    vim.fn.jobstart({ "open", url })
                elseif vim.g.is_android then
                    vim.fn.jobstart({
                        "am",
                        "start",
                        "--user",
                        "0",
                        "-a",
                        "android.intent.action.VIEW",
                        "-d",
                        url,
                    })
                elseif vim.g.is_wsl then
                    vim.fn.jobstart({ "wslopen", url })
                else
                    vim.fn.jobstart({ "xdg-open", url })
                end
            else
                vim.notify("Obsidian: follow_url_func(): Unsupported OS")
            end
        end,

        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
        -- file it will be ignored but you can customize this behavior here.
        ---@param img string
        follow_img_func = function(img)
            if vim.g.is_win then
                vim.cmd(':silent exec "!start ' .. img .. '"')
            elseif vim.g.is_nix then
                if vim.g.is_mac then
                    vim.fn.jobstart({ "qlmanage", "-p", img })
                elseif vim.g.is_android then
                    vim.fn.jobstart({
                        "am",
                        "start",
                        "--user",
                        "0",
                        "-a",
                        "android.intent.action.VIEW",
                        "-d",
                        img,
                    })
                elseif vim.g.is_wsl then
                    vim.fn.jobstart({ "wslopen", img })
                else
                    vim.fn.jobstart({ "xdg-open", img })
                end
            else
                vim.notify("Obsidian: follow_img_func(): Unsupported OS")
            end
        end,

        -- Optional, set to true if you use the Obsidian Advanced URI plugin.
        -- https://github.com/Vinzent03/obsidian-advanced-uri
        use_advanced_uri = true,

        -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
        open_app_foreground = true,

        picker = {
            -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
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

        -- Optional, sort search results by "path", "modified", "accessed", or "created".
        -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
        -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
        sort_by = "modified",
        sort_reversed = true,

        -- Set the maximum number of lines to read from notes on disk when performing certain searches.
        search_max_lines = 1000,

        -- Optional, determines how certain commands open notes. The valid options are:
        -- 1. "current" (the default) - to always open in the current window
        -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
        -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
        open_notes_in = "current",
        ui = {
            enable = true,
            update_debounce = 200,
            max_file_length = 5000,
            checkboxes = {
                -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
                [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                ["x"] = { char = "", hl_group = "ObsidianDone" },
                [">"] = { char = "", hl_group = "ObsidianRightArrow" },
                ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
                ["!"] = { char = "", hl_group = "ObsidianImportant" },
            },
            bullets = { char = "•", hl_group = "ObsidianBullet" },
            external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            reference_text = { hl_group = "ObsidianRefText" },
            highlight_text = { hl_group = "ObsidianHighlightText" },
            tags = { hl_group = "ObsidianTag" },
            block_ids = { hl_group = "ObsidianBlockID" },
            hl_groups = {
                ObsidianTodo = { bold = true, fg = "#f78c6c" },
                ObsidianDone = { bold = true, fg = "#89ddff" },
                ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
                ObsidianTilde = { bold = true, fg = "#ff5370" },
                ObsidianImportant = { bold = true, fg = "#d73128" },
                ObsidianBullet = { bold = true, fg = "#89ddff" },
                ObsidianRefText = { underline = true, fg = "#c792ea" },
                ObsidianExtLinkIcon = { fg = "#c792ea" },
                ObsidianTag = { italic = true, fg = "#89ddff" },
                ObsidianBlockID = { italic = true, fg = "#89ddff" },
                ObsidianHighlightText = { bg = "#75662e" },
            },
        },

        attachments = {
            img_folder = "assets",
        },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)
        require("obsidian.util").ANCHOR_LINK_PATTERN = "#[%w%d\u{4e00}-\u{9fff}][^#]*"
    end,
}
