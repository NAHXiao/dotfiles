return {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
        local jdtls_installdir
        local mason_path = os.getenv("MASON") or nil
        if mason_path then
            jdtls_installdir = vim.fs.joinpath(mason_path, "packages", "jdtls")
            if vim.fn.isdirectory(jdtls_installdir) == 0 then
                jdtls_installdir = nil
            end
        end

        local lombok_path
        if vim.fn.filereadable(vim.fs.joinpath(jdtls_installdir, "lombok.jar")) == 1 then
            lombok_path = vim.fs.joinpath(jdtls_installdir, "lombok.jar")
        else
            lombok_path = nil
        end

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
        local cmd = {
            "jdtls",
            lombok_path ~= nil and ("--jvm-arg=-javaagent:" .. lombok_path) or "",
            "--jvm-arg=-Xmx" .. (os.getenv("JDTLS_XMX") or "1G"),
        }
        local config = {
            cmd = cmd,
            root_dir = vim.fs.dirname(
                vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]
            ),
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
