local ffi = require("ffi")
local is_windows = ffi.os == "Windows"
local is_unix = not is_windows
local print_cmds = false
local convert_env = false
local exepath
local cmd1
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
    ]])
elseif is_unix then
    ffi.cdef([[
        int execvp(const char *file, char *const argv[]);
        int access(const char *pathname, int mode);
        void exit(int status);
        int fork();
        int waitpid(int pid, int *status, int options);
    ]])
end
local function parse_flags()
    if not arg then
        print("Error: No arguments provided")
        os.exit(1)
    end
    local cmds_index = nil
    for i = 1, #arg do
        if arg[i] == "--cmds" then
            cmds_index = i
            break
        end
    end
    if not cmds_index then
        print("Error: --cmds parameter not found")
        os.exit(1)
    end
    for i = 1, cmds_index - 1 do
        if arg[i] == "--print-cmds" then
            print_cmds = true
        elseif arg[i] == "--convert-env" then
            convert_env = true
        end
    end
    local cmds = {}
    for i = cmds_index + 1, #arg do
        table.insert(cmds, arg[i])
    end
    if #cmds == 0 then
        print("Error: No command found after --cmds")
        os.exit(1)
    end
    return cmds
end
local function expand_env_vars(str)
    if not convert_env then
        return str
    end
    local function get_env_var(name)
        return os.getenv(name)
    end
    local function process_expansion(match)
        local var_name, operator, _ = match:match("^([^:]+)(:?[^}]*)")

        if not var_name then
            return match
        end
        local env_value = get_env_var(var_name)
        local is_set = env_value ~= nil and env_value ~= ""
        if not operator or operator == "" then
            -- 简单变量替换 ${var}
            return env_value or ""
        elseif operator:match("^:%-(.*)") then
            -- ${variable:-value} 如果变量没有被设置，则使用默认值
            local default_val = operator:match("^:%-(.*)") or ""
            return is_set and env_value or default_val
        elseif operator:match("^:%+(.*)") then
            -- ${variable:+value} 如果变量被设置，则使用指定的值
            local alt_val = operator:match("^:%+(.*)") or ""
            return is_set and alt_val or ""
        elseif operator:match("^:%?(.*)") then
            -- ${variable:?message} 如果变量没有被设置，则输出错误消息并退出
            local error_msg = operator:match("^:%?(.*)") or "parameter not set"
            if not is_set then
                print("Error: " .. var_name .. ": " .. error_msg)
                os.exit(1)
            end
            return env_value
        elseif operator:match("^##(.*)") then
            -- ${variable##pattern} 删除从前查找最长的匹配
            local pattern = operator:match("^##(.*)")
            if is_set and pattern ~= "" then
                local result = env_value:gsub("^.*" .. pattern, "")
                return result
            end
            return env_value or ""
        elseif operator:match("^#(.*)") then
            -- ${variable#pattern} 删除从前查找最短的匹配
            local pattern = operator:match("^#(.*)")
            if is_set and pattern ~= "" then
                local result = env_value:gsub("^.-" .. pattern, "")
                return result
            end
            return env_value or ""
        elseif operator:match("^%%%%(.*)") then
            -- ${variable%%pattern} 删除从后查找最长的匹配
            local pattern = operator:match("^%%%%(.*)")
            if is_set and pattern ~= "" then
                local result = env_value:gsub(pattern .. ".*$", "")
                return result
            end
            return env_value or ""
        elseif operator:match("^%%(.*)") then
            -- ${variable%pattern} 删除从后查找最短的匹配
            local pattern = operator:match("^%%(.*)")
            if is_set and pattern ~= "" then
                local result = env_value:gsub(pattern .. ".-$", "")
                return result
            end
            return env_value or ""
        elseif operator:match("^//(.*)") then
            -- ${variable//pattern/replacement} 全局替换
            local pattern, replacement = operator:match("^//([^/]*)/?(.*)")
            if is_set and pattern then
                replacement = replacement or ""
                local result = env_value:gsub(pattern, replacement)
                return result
            end
            return env_value or ""
        elseif operator:match("^/(.*)") then
            -- ${variable/pattern/replacement} 单次替换
            local pattern, replacement = operator:match("^/([^/]*)/?(.*)")
            if is_set and pattern then
                replacement = replacement or ""
                local result = env_value:gsub(pattern, replacement, 1)
                return result
            end
            return env_value or ""
        end

        return env_value or ""
    end
    str = str:gsub("%${([^}]+)}", process_expansion)
    return str
end
local function execute_windows(cmdline)
    local kernel32 = ffi.load("kernel32")
    local function get_command_line_a()
        local cmd_line = kernel32.GetCommandLineA()
        if cmd_line ~= nil then
            return ffi.string(cmd_line)
        else
            return nil
        end
    end
    local full_cmdline = get_command_line_a()
    if not full_cmdline then
        print("Error: Unable to get command line")
        os.exit(1)
    end

    local cmds_pos = full_cmdline:find("%-%-cmds")
    if not cmds_pos then
        print("Error: --cmds not found in command line")
        os.exit(1)
    end
    local cmd_start = full_cmdline:find("%s", cmds_pos)
    if not cmd_start then
        print("Error: No command found after --cmds")
        os.exit(1)
    end
    cmdline = full_cmdline:sub(cmd_start + 1):gsub("^%s+", "")
    if convert_env then
        cmdline = expand_env_vars(cmdline)
    end
    local function replace_prefix(str, prefix, repl)
        local p = "^" .. (prefix:gsub("([^%w])", "%%%1"))
        local safe_repl = repl:gsub("%%", "%%%%")
        return str:gsub(p, safe_repl, 1)
    end
    cmdline = replace_prefix(cmdline, cmd1, exepath)
    if print_cmds then
        print("[" .. cmdline .. "]")
        print()
    end
    local cmd_buffer = ffi.new("char[?]", #cmdline + 1)
    ffi.copy(cmd_buffer, cmdline)
    local si = ffi.new("STARTUPINFOA")
    local pi = ffi.new("PROCESS_INFORMATION")
    si.cb = ffi.sizeof(si)
    si.dwFlags = 0
    si.wShowWindow = 1 -- SW_SHOWNORMAL
    local success = kernel32.CreateProcessA(
        nil, -- lpApplicationName
        cmd_buffer, -- lpCommandLine
        nil, -- lpProcessAttributes
        nil, -- lpThreadAttributes
        0, -- bInheritHandles
        0, -- dwCreationFlags
        nil, -- lpEnvironment
        nil, -- lpCurrentDirectory
        si, -- lpStartupInfo
        pi -- lpProcessInformation
    )

    if success == 0 then
        print("Error: Failed to create process")
        return -1
    end
    kernel32.WaitForSingleObject(pi.hProcess, 0xFFFFFFFF)
    local exit_code = ffi.new("DWORD[1]")
    local got_exit_code = kernel32.GetExitCodeProcess(pi.hProcess, exit_code)
    kernel32.CloseHandle(pi.hProcess)
    kernel32.CloseHandle(pi.hThread)
    if got_exit_code ~= 0 then
        return tonumber(exit_code[0])
    else
        print("Error: Failed to get exit code")
        return -1
    end
end
local function execute_unix(cmds)
    if convert_env then
        for i = 1, #cmds do
            cmds[i] = expand_env_vars(cmds[i])
        end
    end
    if print_cmds then
        print("[" .. table.concat(cmds, " ") .. "]")
        print()
    end
    local argv = ffi.new("char*[?]", #cmds + 1)
    local c_strings = {}
    for i = 1, #cmds do
        c_strings[i] = ffi.new("char[?]", #cmds[i] + 1)
        ffi.copy(c_strings[i], cmds[i])
        argv[i - 1] = c_strings[i]
    end
    argv[#cmds] = nil
    local pid = ffi.C.fork()
    if pid == 0 then
        ffi.C.execvp(c_strings[1], argv)
        print("Error: Failed to execute command")
        ffi.C.exit(1)
    elseif pid > 0 then
        local status = ffi.new("int[1]")
        ffi.C.waitpid(pid, status, 0)
        local exit_code = bit.rshift(status[0], 8)
        return exit_code
    else
        print("Error: Failed to fork process")
        return -1
    end
end
local function main()
    local cmds = parse_flags()
    cmd1 = cmds[1]
    exepath = vim.fn.exepath(cmds[1])
    if "" == exepath then
        os.exit(1)
    end
    local exit_code
    if is_windows then
        exit_code = execute_windows()
    else
        exit_code = execute_unix(cmds)
    end
    -- print("[process exited " .. exit_code .. "]")
    os.exit(exit_code)
end
main()
