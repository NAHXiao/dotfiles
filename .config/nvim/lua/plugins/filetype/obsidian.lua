return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
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
            template = "diary.md",
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
        templates = {
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

        -- Optional, sort search results by "path", "modified", "accessed", or "created".
        -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
        -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
        sort_by = "modified",
        sort_reversed = true,

        -- Set the maximum number of lines to read from notes on disk when performing certain searches.
        search_max_lines = 1000,
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
    end,
}
