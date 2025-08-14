return {
    cmd = {
        "clangd",
        "--offset-encoding=utf-16", -- 解决warning: multiple different client offset_encodings detected for buffer, this is not supported yet
        "--fallback-style=webkit",
        "--enable-config",
        "--print-options",
        "--background-index",
        "--clang-tidy",
        "--pch-storage=memory",
        -- "--header-insertion=never",
        -- "--header-insertion-decorators",
        "--all-scopes-completion",
        "--completion-style=detailed",
        "--log=verbose",
        "-j=4",
    },
}
