return {
    "puremourning/vimspector",
    version = "*",
    lazy = true,
    cond = false,
    enable = false,
    keys = {
        --1 run
        --S-1 run-release
        --2 breakpoint
        --3 watch
        --4 eval
        --5 debug
        --S-5 stop
        --C-S-5 restart
        --6
        --7
        --8
        --9
        --10 step over
        --11 step into
        --S-11 step out
        { "<F2>", "<cmd>call vimspector#ToggleBreakpoint()<cr>" },
        { "<F3>", "<cmd>call vimspector#AddWatch()<cr>" },
        { "<F4>", "<cmd>call vimspector#Evaluate()<cr>" },

        { "<F5>", "<cmd>call vimspector#Launch()<cr>" },
        { "<F17>", "<cmd>call vimspector#Reset()<cr>" },
        { "<F41>", "<cmd>call vimspector#Restart()<cr>" },

        -- { "<F6>",      "<cmd>NvimTreeToggle<cr>" },
        -- { "<F7>",      "<cmd>NvimTreeToggle<cr>" },
        -- { "<F8>",      "<cmd>NvimTreeToggle<cr>" },
        -- { "<F9>",      "<cmd>NvimTreeToggle<cr>" },
        { "<F10>", "<cmd>call vimspector#StepOver()<cr>" }, --逐过程
        { "<F11>", "<cmd>call vimspector#StepInto()<cr>" }, --逐语句
        { "<F23>", "<cmd>call vimspector#StepOut()<cr>" }, --跳出(ShiftF11)
    },
    config = function()
        -- vim.g.vimspector_enable_mappings = 'VISUAL_STUDIO'
        vim.g.vimspector_base_dir = vim.fn.stdpath("data") .. "/lazy/vimspector"
        vim.g.vimspector_install_gadgets = { "debugpy", "vscode-cpptools", "CodeLLDB" }
        -- 全局配置
        -- g:vimspector_configurations vim variable (dict)
        -- <vimspector home>/configurations/<OS>/<filetype>/*.json
        -- .vimspector.json in the project source
        vim.g.vimspector_configurations = {
            example_debug_configuration = {
                -- This is a single-line comment  explaining the purpose
                adapter = "example-adapter-name",
                filetypes = {}, -- optional
                variables = {
                    SecretToken = { -- Variables should start with upper-case letters
                        shell = { "cat", "${HOME}/.secret_token" },
                    },
                },
                configuration = {
                    request = "launch", -- or it could be "attach"
                    program = {
                        "${fileBasenameNoExtension}",
                        "-c",
                        "configuration_file.cfg",
                        "-u",
                        "${USER}",
                        --test-identifier, "${TestIdentifier}",
                        --secret-token, "${SecretToken}"
                    },
                },
                breakpoints = {
                    exception = {
                        caught = "",
                        uncaught = "Y",
                    },
                },
            },
            Test = {
                -- This is a single-line comment  explaining the purpose
                adapter = "LLVM",
                filetypes = {}, -- optional
                variables = {
                    SecretToken = { -- Variables should start with upper-case letters
                        shell = { "cat", "${HOME}/.secret_token" },
                    },
                },
                configuration = {
                    request = "launch", -- /* or it could be "attach" */,
                    program = {
                        "${fileBasenameNoExtension}",
                        "-c",
                        "configuration_file.cfg",
                        "-u",
                        "${USER}",
                        --test-identifier, "${TestIdentifier}",
                        --secret-token, "${SecretToken}"
                    },
                },
                breakpoints = {
                    exception = {
                        caught = "",
                        uncaught = "Y",
                    },
                },
                args = {
                    "one",
                    "two three",
                    "four",
                    "*${CommandLineArgs}",
                    "${var:pre defined var${file\\}}",
                },
            },
            Example_MAC_LLVM = {
                filetypes = {}, -- optional
                adapters = {
                    lldb_vscode = {
                        variables = {
                            LLVM = {
                                shell = "brew --prefix llvm",
                            },
                        },
                        attach = {
                            pidProperty = "pid",
                            pidSelect = "ask",
                        },
                        command = {
                            "${LLVM}/bin/lldb-vscode",
                        },
                        env = {
                            LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES",
                        },
                        name = "lldb",
                    },
                    vscode_cpptools = {
                        attach = {
                            pidProperty = "processId",
                            pidSelect = "ask",
                        },
                        command = {
                            "${gadgetDir}/vscode-cpptools/debugAdapters/bin/OpenDebugAD7",
                        },
                        name = "cppdbg",
                    },
                },
            },
            Launch = {
                adapter = "vscode-cpptools",
                filetypes = { "cpp", "c", "objc", "rust" }, -- optional
                configuration = {
                    request = "launch",
                    cwd = "${workspaceFolder}",
                    program = "${workspaceFolder}/${fileBasenameNoExtension}",
                    --program= "${fileDirname}/${fileBasenameNoExtension}",
                    --MIMode= "<lldb or gdb>"
                    MIMode = "gdb",
                    externalConsole = true,
                    stopAtEntry = true,
                    args = {},
                    environment = {},
                },
            },
            LaunchWithArgs = {
                adapter = "vscode-cpptools",
                filetypes = { "cpp", "c", "objc", "rust" }, -- optional
                default = true,
                configuration = {
                    request = "launch",
                    cwd = "${workspaceFolder}",
                    program = "${workspaceFolder}/${fileBasenameNoExtension}",
                    --program= "${fileDirname}/${fileBasenameNoExtension}",
                    --MIMode= "<lldb or gdb>"
                    MIMode = "gdb",
                    externalConsole = true,
                    stopAtEntry = true,
                    args = { "*${CommandLineArgs}" },
                    environment = {},
                },
            },
            Attach = {
                adapter = "vscode-cpptools",
                filetypes = { "cpp", "c", "objc", "rust" }, -- optional
                configuration = {
                    name = "Attach",
                    request = "attach",
                    program = "${workspaceFolder}/${fileBasenameNoExtension}",
                    --MIMode= "<lldb or gdb>"
                    MIMode = "gdb",
                    stopAtEntry = true,
                    setupCommands = {
                        { -- only for gdb
                            description = "Enable pretty-printing for gdb",
                            text = "-enable-pretty-printing",
                            ignoreFailures = true,
                        },
                    },
                },
            },
            Python = {
                adapter = "debugpy",
                filetypes = { "python" }, -- optional
                configuration = {
                    name = "Python: Current File",
                    type = "python",
                    request = "launch",
                    program = "${file}",
                    args = { "*${CommandLineArgs}" },
                    cwd = "${workspaceFolder}",
                    env = { _ = "" },
                    envFile = "",
                    stopOnEntry = 0,
                    debugOptions = {},
                    -- pythonPath = '${config.python.pythonPath}',
                    externalConsole = 0,
                },
            },
        }

        -- Vimspector
        vim.cmd([[
let g:vimspector_sidebar_width = 45
let g:vimspector_bottombar_height = 15
let g:vimspector_terminal_maxwidth = 70
let g:vimspector_terminal_mixwidth = 50
let g:vimspector_code_mixwidth =50
]])
    end,
}
