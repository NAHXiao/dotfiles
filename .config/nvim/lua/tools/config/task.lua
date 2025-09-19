---`UserTaskSet[number]`:
---```lua
---"taskname"
---{"taskname",bg=true,break_on_err=true}
---{{name="taskname",label="labelname"},bg=true,break_on_err=true}
---{{name="taskname",label="tasklabel",cmds="sleep 1",with_shell=true},bg=true,break_on_err=true}
---```
---@type table<string,{tasks:UserTask[],tasksets:UserTaskSet[]}>
local config = {
    template = {
        tasks = {
            {
                name = "build",
                cmds = { "echo", "$(=CC)", "build" },
                label = "debug",
                opts = {
                    clear_env = false,
                    cwd = "$(-VIM_ROOT)",
                    env = {
                        CC = "clang",
                    },
                },
            },
            {
                name = "run",
                cmds = { "echo", "$(=CC)", "run" },
                label = "debug",
                opts = {
                    clear_env = false,
                    cwd = "$(-VIM_ROOT)",
                    env = {
                        CC = "clang",
                    },
                },
            },
            {
                name = "echo PATH with shell",
                cmds = jit.os ~= "Windows" and "echo $PATH" or "echo %PATH%",
                with_shell = true,
                filetypes = "*",
            },
        },
        tasksets = {
            {
                { name = "build", label = "debug" },
                { name = "run", label = "debug" },
                break_on_err = true,
                seq = true,
                name = "build and run",
            },
        },
    },
    global = {
        tasks = {
            { name = "sleep", cmds = { "sleep", "3s" } },
        },
    },

    c = {
        tasks = {
            {
                name = "build",
                cmds = {
                    "gcc",
                    "-O3",
                    "--std=c23",
                    "$(-VIM_FILEPATH)",
                    "-o",
                    "$(-VIM_FILEDIR)/$(-VIM_FILENOEXT)",
                },
                filetypes = { "c" },
                label = "release",
            },
            {
                name = "build",
                cmds = {
                    "gcc",
                    "-O3",
                    "--std=c23",
                    "$(-VIM_FILEPATH)",
                    "-o",
                    "$(-VIM_FILEDIR)/$(-VIM_FILENOEXT)",
                    "--debug",
                },
                filetypes = { "c" },
                label = "debug",
            },
            {
                name = "run",
                cmds = {
                    "$(-VIM_PATHNOEXT)",
                },
                filetypes = { "c" },
            },
        },
        tasksets = {
            {
                name = "build_and_run(c release)",
                break_on_err = true,
                seq = true,
                { name = "build", label = "release" },
                "run",
                filetypes = { "c" },
            },
            {
                name = "build_and_run(c debug)",
                break_on_err = true,
                seq = true,
                { name = "build", label = "debug" },
                "run",
                filetypes = { "c" },
            },
        },
    },
    cpp = {
        tasks = {
            {
                name = "build",
                cmds = {
                    "g++",
                    "-O2",
                    "--std=c++23",
                    "$(-VIM_FILEPATH)",
                    "-o",
                    "$(-VIM_FILEDIR)/$(-VIM_FILENOEXT)",
                },
                filetypes = { "cpp" },
                label = "release",
            },
            {
                name = "build",
                cmds = {
                    "g++",
                    "-O0",
                    "--std=c++23",
                    "$(-VIM_FILEPATH)",
                    "-o",
                    "$(-VIM_FILEDIR)/$(-VIM_FILENOEXT)",
                    "-g",
                },
                filetypes = { "cpp" },
                label = "debug",
            },
            {
                name = "run",
                cmds = {
                    "$(-VIM_PATHNOEXT)",
                },
                filetypes = { "cpp" },
            },
        },
        tasksets = {
            {
                name = "build_and_run(cpp release)",
                break_on_err = true,
                seq = true,
                { name = "build", label = "release" },
                "run",
                filetypes = { "cpp" },
            },
            {
                name = "build_and_run(cpp debug)",
                break_on_err = true,
                seq = true,
                { name = "build", label = "debug" },
                "run",
                filetypes = { "cpp" },
            },
        },
    },
    java = {
        tasks = {
            {
                name = "build",
                cmds = {
                    "javac",
                    "-d",
                    "$(-VIM_ROOT)/.build",
                    "$(-VIM_FILEPATH)",
                },
                filetypes = { "java" },
            },
            {
                name = "run",
                cmds = {
                    "java",
                    "-cp",
                    "$(-VIM_ROOT)/.build",
                    "$(-VIM_FILENOEXT)",
                },
                filetypes = { "java" },
            },
        },
    },
    go = {
        tasks = {
            {
                name = "project-create",
                cmds = { "go", "mod", "init", "$(+name:main)" },
                filetypes = { "go" },
            },
            {
                name = "go build",
                cmds = { "go", "build" },
                filetypes = { "go" },
            },
            {
                name = "go run .",
                cmds = { "go", "run", "." },
                filetypes = { "go" },
            },
            {
                name = "go run <file>",
                cmds = { "go", "run", "$(-VIM_FILEPATH)" },
                filetypes = { "go" },
            },
            {
                name = "go test",
                cmds = { "go", "test" },
                filetypes = { "go" },
            },
        },
    },
    zig = {
        tasks = {
            {
                name = "build",
                cmds = { "zig", "build-exe", "$(-VIM_FILEPATH)" },
                filetypes = { "zig" },
            },
            {
                name = "run",
                cmds = { "zig", "run", "$(-VIM_FILEPATH)" },
                filetypes = { "zig" },
            },
        },
    },
    swift = {
        tasks = {
            {
                name = "run",
                cmds = { "swift", "$(-VIM_FILEPATH)" },
                filetypes = { "swift" },
            },
        },
    },
    julia = {
        tasks = {
            {
                name = "run",
                cmds = { "julia", "$(-VIM_FILEPATH)" },
                filetypes = { "julia" },
            },
        },
    },
    python = {
        tasks = {
            {
                name = "python run",
                cmds = { "python3", "$(-VIM_FILEPATH)" },
                filetypes = { "python" },
            },
            {
                name = "python run with venv",
                cmds = {
                    (function()
                        local root = require("utils").get_rootdir() or vim.fn.getcwd()
                        local dot_venv_py = vim.fs.joinpath(root, ".venv", "bin", "python")
                        local venv_py = vim.fs.joinpath(root, "venv", "bin", "python")
                        for _, py in ipairs { dot_venv_py, venv_py } do
                            if vim.fn.filereadable(py) then
                                return py
                            end
                        end
                        return "python3"
                    end)(),
                    "$(-VIM_FILEPATH)",
                },
                filetypes = { "python" },
            },
            {
                name = "pytest",
                cmds = { "python", "-m", "pytest" },
                filetypes = { "python" },
            },
        },
    },

    script = {
        tasks = {
            {
                name = "lua run",
                cmds = {
                    "lua",
                    "$(-VIM_FILEPATH)",
                },
                filetypes = { "lua" },
            },
            {
                name = "lua run with nvim",
                cmds = {
                    "nvim",
                    "-u",
                    "NONE",
                    "-l",
                    "$(-VIM_FILEPATH)",
                },
                filetypes = { "lua" },
            },
            {
                name = "node run",
                cmds = {
                    "node",
                    "$(-VIM_FILEPATH)",
                },
                filetypes = { "javascript" },
            },
            {
                name = "powershell run",
                cmds = {
                    "powershell",
                    "-file",
                    "$(-VIM_FILEPATH)",
                },
                filetypes = { "ps1" },
            },
        },
    },
    cmake = {
        tasks = {
            {
                name = "cmake-create",
                cmds = {
                    "bash",
                    vim.fs.joinpath(vim.fn.stdpath("config"), "bin", "cmake_create.bash"),
                    "$(+name:)",
                },
                filetypes = "*",
            },
            {
                name = "project-refresh-config",
                cmds = { "cmake", "--fresh", "-B", "build", "-S", "." },
                filetypes = { "c", "cpp", "cmake" },
            },
            {
                name = "build",
                cmds = { "cmake", "--build", "build" },
                filetypes = { "c", "cpp", "cmake" },
            },
            {
                name = "run",
                cmds = { "build/$(-VIM_PRONAME)" },
                filetypes = { "c", "cpp", "cmake" },
            },
        },
    },
    cargo = {
        tasks = {
            {
                name = "cargo-create",
                cmds = { "cargo", "new", "$(+name)", "--bin" },
                filetypes = "*",
            },
            {
                name = "build",
                cmds = { "cargo", "build" },
                filetypes = { "rust" },
            },
            {
                name = "run",
                cmds = { "cargo", "run" },
                filetypes = { "rust" },
            },
            {
                name = "project-test",
                cmds = { "cargo", "test" },
                filetypes = { "rust" },
            },
        },
    },
    mvn = {
        tasks = {
            {
                name = "mvn-create",
                cmds = {
                    "mvn",
                    "archetype:generate",
                    "-DgroupId=$(+group:com.example)",
                    "-DartifactId=$(+artifactname:hello-world)",
                    "-DarchetypeArtifactId=maven-archetype-quickstart",
                    "-Dinteractivelabel=false",
                },
                filetypes = "*",
            },
            {
                name = "build",
                cmds = { "mvn", "compile" },
                filetypes = { "java" },
            },
            {
                name = "project-test",
                cmds = { "mvn", "test" },
                filetypes = { "java" },
            },
            {
                name = "run",
                cmds = { "mvn", "exec:java", "-Dexec.mainClass=$(+mainClass:)" },
                filetypes = { "java" },
            },
        },
    },
    gradlew = {
        tasks = {
            {
                name = "build",
                cmds = { "$(-VIM_ROOT)/gradlew", "build" },
                filetypes = { "java", "kotlin" },
            },
            {
                name = "test",
                cmds = { "$(-VIM_ROOT)/gradlew", "test" },
                filetypes = { "java", "kotlin" },
            },
            {
                name = "buildAndInstall",
                cmds = { "$(-VIM_ROOT)/gradlew", "installDebug" },
                label = "debug",
                filetypes = { "java", "kotlin" },
            },
            {
                name = "buildAndInstall",
                cmds = { "$(-VIM_ROOT)/gradlew", "installRelease" },
                label = "release",
                filetypes = { "java", "kotlin" },
            },
        },
    },
    web = {
        tasks = {
            {
                name = "npm install",
                cmds = { "npm", "install" },
                filetypes = { "javascript", "typescript" },
            },
            {
                name = "npm run dev",
                cmds = { "npm", "run", "dev" },
                filetypes = { "javascript", "typescript" },
            },
            {
                name = "npm run build",
                cmds = { "npm", "run", "build" },
                filetypes = { "javascript", "typescript" },
            },
            {
                name = "deno run",
                cmds = { "deno", "run", "--allow-all", "$(-VIM_FILEPATH)" },
                filetypes = { "javascript", "typescript" },
            },
        },
    },
}
return config
-- vim: foldlevel=1
