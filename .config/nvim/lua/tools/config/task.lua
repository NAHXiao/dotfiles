---@type table<"global"|string,{tasks:utask[],tasksets:utaskset[]}>
local config = {
    global = {
        tasks = {
            --project-create
            {
                name = "mvn-create",
                cmds = {
                    "mvn",
                    "archetype:generate",
                    "-DgroupId=$(-group:com.example)",
                    "-DartifactId=$(-artifactname:hello-world)",
                    "-DarchetypeArtifactId=maven-archetype-quickstart",
                    "-DinteractiveMode=false",
                },
                type = "project",
            },
            {
                name = "cargo-create",
                cmds = { "cargo", "new", "$(-name)", "--bin" },
                type = "project",
            },
            {
                name = "cmake-create",
                cmds = { "bash", vim.fs.joinpath(vim.fn.stdpath("config"), "bin", "cmake_create.bash"), "$(-name:)" },
                type = "project",
            },
            --c/cpp
            {
                name = "build",
                cmds = {
                    "gcc",
                    "-O3",
                    "--std=c23",
                    "$(VIM_FILEPATH)",
                    "-o",
                    "$(VIM_FILEDIR)/$(VIM_FILENOEXT)",
                },
                filetypes = { "c" },
                type = "file",
                mode = "release",
            },
            {
                name = "build",
                cmds = {
                    "gcc",
                    "-O3",
                    "--std=c23",
                    "$(VIM_FILEPATH)",
                    "-o",
                    "$(VIM_FILEDIR)/$(VIM_FILENOEXT)",
                    "--debug",
                },
                filetypes = { "c" },
                type = "file",
                mode = "debug",
            },
            {
                name = "build",
                cmds = {
                    "g++",
                    "-O3",
                    "--std=c++23",
                    "$(VIM_FILEPATH)",
                    "-o",
                    "$(VIM_FILEDIR)/$(VIM_FILENOEXT)",
                },
                filetypes = { "cpp" },
                type = "file",
                mode = "release",
            },
            {
                name = "build",
                cmds = {
                    "g++",
                    "-O3",
                    "--std=c++23",
                    "$(VIM_FILEPATH)",
                    "-o",
                    "$(VIM_FILEDIR)/$(VIM_FILENOEXT)",
                    "--debug",
                },
                filetypes = { "cpp" },
                type = "file",
                mode = "debug",
            },
            {
                name = "run",
                cmds = {
                    "$(VIM_PATHNOEXT)" .. (GVars.is_win and ".exe" or ""),
                },
                filetypes = { "c", "cpp" },
                type = "file",
            },
            --java
            {
                name = "build",
                cmds = {
                    "javac",
                    "-d",
                    "$(VIM_ROOT)/.build",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "java" },
                type = "file",
            },
            {
                name = "run",
                cmds = {
                    "java",
                    "-cp",
                    "$(VIM_ROOT)/.build",
                    "$(VIM_FILENOEXT)",
                },
                filetypes = { "java" },
                type = "file",
            },
            --scripts
            {
                name = "run",
                cmds = {
                    "lua",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "lua" },
                type = "file",
            },
            {
                name = "run(nvim)",
                cmds = {
                    "nvim",
                    "-u",
                    "NONE",
                    "-l",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "lua" },
                type = "file",
            },
            {
                name = "run",
                cmds = {
                    "python",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "python" },
                type = "file",
            },
            {
                name = "run",
                cmds = {
                    "node",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "javascript" },
                type = "file",
            },
            {
                name = "run",
                cmds = {
                    "powershell",
                    "-file",
                    "$(VIM_FILEPATH)",
                },
                filetypes = { "ps1" },
                type = "file",
            },
        },
        tasksets = {
            {
                name = "build_and_run(cpp release)",
                break_on_err = true,
                seq = true,
                "build(file:release)[cpp]",
                "run(file)[cpp,c]",
            },
            {
                name = "build_and_run(cpp debug)",
                break_on_err = true,
                seq = true,
                { "build(file:debug)[cpp]" },
                "run(file)[cpp,c]",
            },
        },
    },
    template = {
        tasks = {
            {
                name = "build",
                cmds = { "echo", "${CC}" },
                type = "project",
                mode = "debug",
                opts = {
                    clear_env = false,
                    cwd = "$(VIM_ROOT)",
                    env = {
                        CC = "clang",
                    },
                },
            },
            {
                name = "run",
                cmds = { "echo", "${CC}" },
                type = "project",
                mode = "debug",
                opts = {
                    clear_env = false,
                    cwd = "$(VIM_ROOT)",
                    env = {
                        CC = "clang",
                    },
                },
            },
        },
        tasksets = {
            {
                { "build(debug:project)" },
                "run(project:debug)",
                break_on_err = true,
                seq = true,
                name = "build and run",
            },
        },
    },
    cmake = {
        tasks = {
            {
                name = "project-refresh-config",
                cmds = { "cmake", "--fresh", "-B", "build", "-S", "." },
            },
            {
                name = "build",
                cmds = { "cmake", "--build", "build" },
            },
            {
                name = "run",
                cmds = { "build/$(VIM_PRONAME)" },
            },
        },
        tasksets = {},
    },
    cargo = {
        tasks = {
            {
                name = "build",
                cmds = { "cargo", "build" },
            },
            {
                name = "run",
                cmds = { "cargo", "run" },
            },
            {
                name = "project-test",
                cmds = { "cargo", "test" },
            },
        },
        tasksets = {},
    },
    mvn = {
        tasks = {
            {
                name = "build",
                cmds = { "mvn", "compile" },
            },
            {
                name = "project-test",
                cmds = { "mvn", "test" },
            },
            {
                name = "run",
                cmds = { "mvn", "exec:java", "-Dexec.mainClass=$(-mainClass:)" },
            },
        },
        tasksets = {},
    },
}
return config
