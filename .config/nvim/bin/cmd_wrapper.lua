---limitation:for windows,the executable replacement will start from the first "--cmds" with spaces on both sides.
---TODO:prepend_stdout
local ffi = require("ffi")
local is_windows = ffi.os == "Windows"
local is_unix = not is_windows
local options = {
    print_cmds = {
        type = "boolean",
        match = { "-p", "--print-cmds" },
        default = false,
    },
    stdin_file = {
        type = "string",
        match = { "--stdin-file", "-if" },
    },
}
---@alias options {
---cmds:string[],
---print_cmds:boolean,
---stdin_file?:string}
local cleanfuncs = {}
local function err(str)
    io.stderr:write("Error:" .. str .. "\n")
    for _, func in ipairs(cleanfuncs) do
        func()
    end
    os.exit(1)
end
local function exit(code)
    for _, func in ipairs(cleanfuncs) do
        func()
    end
    os.exit(code)
end
if is_windows then
    vim.cmd("language en_us.UTF-8")
    ffi.cdef([[
        char* GetCommandLineA();
        int WideCharToMultiByte(
            unsigned int CodePage,
            unsigned long dwFlags,
            const wchar_t* lpWideCharStr,
            int cchWideChar,
            char* lpMultiByteStr,
            int cbMultiByte,
            const char* lpDefaultChar,
            int* lpUsedDefaultChar
        );

        typedef void* HANDLE;
        typedef unsigned long DWORD;
        typedef int BOOL;
        typedef char* LPSTR;
        typedef const char* LPCSTR;
        typedef wchar_t* LPWSTR;
        typedef const wchar_t* LPCWSTR;
        typedef void* LPVOID;
        typedef unsigned short WORD;
        typedef struct {
            DWORD  nLength;
            LPVOID lpSecurityDescriptor;
            BOOL   bInheritHandle;
        } SECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;
        typedef struct {
            DWORD  cb;
            LPSTR  lpReserved;
            LPSTR  lpDesktop;
            LPSTR  lpTitle;
            DWORD  dwX;
            DWORD  dwY;
            DWORD  dwXSize;
            DWORD  dwYSize;
            DWORD  dwXCountChars;
            DWORD  dwYCountChars;
            DWORD  dwFillAttribute;
            DWORD  dwFlags;
            WORD   wShowWindow;
            WORD   cbReserved2;
            void*  lpReserved2;
            HANDLE hStdInput;
            HANDLE hStdOutput;
            HANDLE hStdError;
        } STARTUPINFOA, *LPSTARTUPINFOA;
        typedef struct {
            HANDLE hProcess;
            HANDLE hThread;
            DWORD  dwProcessId;
            DWORD  dwThreadId;
        } PROCESS_INFORMATION, *LPPROCESS_INFORMATION;
        BOOL CreateProcessA(
            LPCSTR                lpApplicationName,
            LPSTR                 lpCommandLine,
            LPSECURITY_ATTRIBUTES lpProcessAttributes,
            LPSECURITY_ATTRIBUTES lpThreadAttributes,
            BOOL                  bInheritHandles,
            DWORD                 dwCreationFlags,
            LPVOID                lpEnvironment,
            LPCSTR                lpCurrentDirectory,
            LPSTARTUPINFOA        lpStartupInfo,
            LPPROCESS_INFORMATION lpProcessInformation
        );
        BOOL CloseHandle(HANDLE hObject);
        DWORD WaitForSingleObject(HANDLE hHandle, DWORD dwMilliseconds);
        BOOL GetExitCodeProcess(HANDLE hProcess, DWORD* lpExitCode);
        
		HANDLE CreateFileA(
			LPCSTR                lpFileName,
			DWORD                 dwDesiredAccess,
			DWORD                 dwShareMode,
			LPSECURITY_ATTRIBUTES lpSecurityAttributes,
			DWORD                 dwCreationDisposition,
			DWORD                 dwFlagsAndAttributes,
			HANDLE                hTemplateFile
		);
		HANDLE GetStdHandle(DWORD nStdHandle);
    ]])
elseif is_unix then
    ffi.cdef([[
        int execvp(const char *file, char *const argv[]);
        int access(const char *pathname, int mode);
        void exit(int status);
        int fork();
        int waitpid(int pid, int *status, int options);
		int open(const char *pathname, int flags);
		int dup2(int oldfd, int newfd);
		int close(int fd);
    ]])
end
---@param opts options
local function execute_windows(opts)
    local kernel32 = ffi.load("kernel32")
    local function get_command_line_a()
        local cmd_line = kernel32.GetCommandLineA()
        if cmd_line ~= nil then
            return ffi.string(cmd_line)
        else
            err("Unable to get command line")
        end
    end
    local function prefix_replace(str, prefix, replacement)
        if str:sub(1, #prefix) == prefix then
            return replacement .. str:sub(#prefix + 1)
        end
        return str
    end
    local full_cmdline = get_command_line_a()
    local _, cmd_start = full_cmdline:find(" %-%-cmds +")
    if not cmd_start then
        err("--cmds not found in command line")
    end
    cmd_start = cmd_start + 1
    local cmdline = full_cmdline:sub(cmd_start)
    cmdline = prefix_replace(cmdline, opts.cmds[1], vim.fn.exepath(opts.cmds[1]))
    if opts.print_cmds then
        print("[" .. cmdline .. "]")
        print()
    end
    local cmd_buffer = ffi.new("char[?]", #cmdline + 1)
    ffi.copy(cmd_buffer, cmdline)
    local si = ffi.new("STARTUPINFOA")
    local pi = ffi.new("PROCESS_INFORMATION")
    si.cb = ffi.sizeof(si)
    si.wShowWindow = 1 -- SW_SHOWNORMAL

    local hStdinFile = nil
    if opts.stdin_file then
        local sa = ffi.new("SECURITY_ATTRIBUTES")
        sa.nLength = ffi.sizeof(sa)
        sa.bInheritHandle = 1
        sa.lpSecurityDescriptor = nil

        hStdinFile = kernel32.CreateFileA(
            opts.stdin_file,
            0x80000000, -- GENERIC_READ
            1, -- FILE_SHARE_READ
            sa, -- 使用可继承的安全属性
            3, -- OPEN_EXISTING
            0x80, -- FILE_ATTRIBUTE_NORMAL
            nil
        )
        if hStdinFile == ffi.cast("void*", -1) then -- INVALID_HANDLE_VALUE
            err("Failed to open stdin file")
        end
    end
    si.dwFlags = 0x100 -- STARTF_USESTDHANDLES
    si.hStdInput = hStdinFile or kernel32.GetStdHandle(0xFFFFFFF6) -- STD_INPUT_HANDLE
    si.hStdOutput = kernel32.GetStdHandle(0xFFFFFFF5) -- STD_OUTPUT_HANDLE
    si.hStdError = kernel32.GetStdHandle(0xFFFFFFF4) -- STD_ERROR_HANDLE
    local success = kernel32.CreateProcessA(
        nil, -- lpApplicationName
        cmd_buffer, -- lpCommandLine
        nil, -- lpProcessAttributes
        nil, -- lpThreadAttributes
        1, -- bInheritHandles
        0, -- dwCreationFlags
        nil, -- lpEnvironment
        nil, -- lpCurrentDirectory
        si, -- lpStartupInfo
        pi -- lpProcessInformation
    )
    if hStdinFile then
        kernel32.CloseHandle(hStdinFile)
    end
    if success == 0 then
        local error_code = kernel32.GetLastError()
        err("Failed to create process, error: " .. error_code)
    end
    kernel32.WaitForSingleObject(pi.hProcess, 0xFFFFFFFF)
    local exit_code = ffi.new("DWORD[1]")
    local got_exit_code = kernel32.GetExitCodeProcess(pi.hProcess, exit_code)
    kernel32.CloseHandle(pi.hProcess)
    kernel32.CloseHandle(pi.hThread)
    if got_exit_code ~= 0 then
        return tonumber(exit_code[0])
    else
        err("Failed to get exit code")
        return -1
    end
end
---@param opts options
local function execute_unix(opts)
    if opts.print_cmds then
        print("[" .. table.concat(opts.cmds, " ") .. "]")
        print()
    end
    local argv = ffi.new("char*[?]", #opts.cmds + 1)
    local c_strings = {}
    for i = 1, #opts.cmds do
        c_strings[i] = ffi.new("char[?]", #opts.cmds[i] + 1)
        ffi.copy(c_strings[i], opts.cmds[i])
        argv[i - 1] = c_strings[i]
    end
    argv[#opts.cmds] = nil

    local pid = ffi.C.fork()
    if pid == 0 then
        if opts.stdin_file then
            local fd = ffi.C.open(opts.stdin_file, 0) -- O_RDONLY
            if fd >= 0 then
                ffi.C.dup2(fd, 0) -- 重定向到stdin
                ffi.C.close(fd)
            end
        end
        ffi.C.execvp(c_strings[1], argv)
        err("Failed to execute command")
        ffi.C.exit(1)
    elseif pid > 0 then
        local status = ffi.new("int[1]")
        ffi.C.waitpid(pid, status, 0)
        local exit_code = bit.rshift(status[0], 8)
        return exit_code
    else
        err("Failed to fork process")
        return -1
    end
end
---@return options
local function parse_args(args)
    local cmds_index = nil
    for i = 1, #args do
        if args[i] == "--cmds" then
            cmds_index = i
            break
        end
    end
    if not cmds_index then
        err("--cmds parameter not found")
    end
    if args[cmds_index + 1] == nil then
        err("no cmds provided")
    end
    local cmd0 = args[cmds_index + 1]
    if vim.fn.executable(cmd0) == 0 then
        err(cmd0 .. " is not executable")
    end
    local result = {}
    result.cmds = {}
    for i = cmds_index + 1, #args do
        result.cmds[#result.cmds + 1] = args[i]
    end
    local i = 1
    for key, config in pairs(options) do
        if config.default ~= nil then
            result[key] = config.default
        end
    end
    while i <= cmds_index - 1 do
        local arg = args[i]
        local matched = false

        for key, config in pairs(options) do
            for _, pattern in ipairs(config.match) do
                if config.type == "boolean" then
                    if arg == pattern or arg == pattern .. "=true" then
                        result[key] = true
                        matched = true
                        break
                    elseif arg == pattern .. "=false" then
                        result[key] = false
                        matched = true
                        break
                    end
                elseif config.type == "enum" then
                    local prefix = pattern .. "="
                    if arg:sub(1, #prefix) == prefix then
                        local value = arg:sub(#prefix + 1)
                        if value == "" then
                            err("Option " .. pattern .. " requires a value")
                        end

                        local valid = false
                        for _, enum_value in ipairs(config.enum) do
                            if value == enum_value then
                                valid = true
                                break
                            end
                        end
                        if not valid then
                            local valid_values = table.concat(config.enum, ", ")
                            err("Option " .. pattern .. " must be one of: " .. valid_values)
                        end

                        result[key] = value
                        matched = true
                        break
                    end
                else -- string or number
                    local prefix = pattern .. "="
                    if arg:sub(1, #prefix) == prefix then
                        local value = arg:sub(#prefix + 1)
                        if value == "" then
                            err("Option " .. pattern .. " requires a value")
                        end

                        if config.type == "number" then
                            local num = tonumber(value)
                            if not num then
                                err("Option " .. pattern .. " requires a numeric value")
                            end
                            result[key] = num
                        else
                            result[key] = value
                        end
                        matched = true
                        break
                    end
                end
            end
            if matched then
                break
            end
        end
        if not matched then
            err("Unknown option: " .. arg)
        end
        i = i + 1
    end
    return result
end
---@param opts options
local function execute(opts)
    if is_windows then
        return execute_windows(opts)
    else
        return execute_unix(opts)
    end
end
exit(execute(parse_args(arg)))
