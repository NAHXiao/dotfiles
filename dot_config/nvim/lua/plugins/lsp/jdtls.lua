return {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
        local jdtls_installdir
        jdtls_installdir = vim.fs.joinpath(Globals.mason_install_root_dir, "packages", "jdtls")
        if vim.fn.isdirectory(jdtls_installdir) == 0 then
            vim.notify(
                "JDTLS is not installed, please run :MasonInstall jdtls",
                vim.log.levels.ERROR
            )
            return
        end

        local lombok_path = vim.fs.joinpath(jdtls_installdir, "lombok.jar")
        local bundles = {}
        -- java-debug
        vim.list_extend(
            bundles,
            vim.split(
                vim.fn.glob(
                    vim.fn.stdpath("data")
                    .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
                ),
                "\n"
            )
        )

        -- vscode-java-test
        vim.list_extend(
            bundles,
            vim.split(
                vim.fn.glob(
                    vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar"
                ),
                "\n"
            )
        )

        local jdtls = require("jdtls")
        local root_dir = require("utils").get_rootdir()
        local compact = require("utils").list_compact
        local config = {
            cmd = compact {
                "jdtls",
                ("--jvm-arg=-javaagent:%s"):format(lombok_path),
                ("--jvm-arg=-Xmx%s"):format(os.getenv("JDTLS_XMX") or "8G"),
                "-data",
                ("%s/jdtls/%s"):format(
                    (os.getenv("XDG_CACHE_HOME") or vim.uv.os_homedir() .. "/.cache"),
                    require("utils").encode_path(root_dir)
                ),
            },
            root_dir = root_dir,
            filetypes = { "java" },
            init_options = {
                bundles = bundles,
                extendedClientCapabilities = jdtls.extendedClientCapabilities,
            },
        }

        vim.api.nvim_create_autocmd({ "FileType" }, {
            pattern = "java",
            callback = function()
                jdtls.start_or_attach(config)
            end,
        })
    end,
}
