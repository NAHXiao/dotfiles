---vim will attempt to prevent vim.lsp.enable() for all LSPs that are in the disable list but not in disable_exclude.
---You need to restart vim to apply the changes.
---@type {disable?:table<string>|true,disable_exclude?:table<string>,extend?:table<string,vim.lsp.Config>,override?:table<string,vim.lsp.Config>}
return {
    disable = true,
    disable_exclude = { "lua_ls" },
}
