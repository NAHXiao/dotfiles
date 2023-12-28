DebugToFile = function(log)
    if log == nil then
        return
    end
    local file = io.open('/home/wangsf/tmp/nvim.log', 'a')
    file:write(os.date("%Y-%m-%d %H:%M:%S", os.time()) .. ' ' .. tostring(log) .. '\n')
    file:close()
end

-- Run
-- 判断当前缓冲区文件扩展名的函数
function is_file_extension(extensions)
    local current_extension = vim.fn.expand('%:e'):lower()
    for _, ext in ipairs(extensions) do
        if current_extension == ext then
            return true
        end
    end
    return false
end

function CompileAndRunning()
    local current_file = vim.fn.expand('%:p')
    local current_file_without_extension = vim.fn.expand('%:t:r')
    local cpp_extensions = { 'cpp', 'cxx', 'CPP' }
    local echo_gaps = [[(echo;printf '%*s\n' "$(tput cols)" | tr ' ' '-';echo)]]
    local echo_gaps_twice =
    [[(echo;printf '%*s\n' "$(tput cols)" | tr ' ' '-';printf '%*s\n' "$(tput cols)" | tr ' ' '-';echo)]]

    if is_file_extension(cpp_extensions) then
        require('FTerm').run({ echo_gaps })
        require('FTerm').run({ 'g++', current_file, '-o', current_file_without_extension, '&&',
            echo_gaps_twice, '&&', './' ..
        current_file_without_extension })
    elseif is_file_extension({ 'c' }) then
        require('FTerm').run({ echo_gaps })
        require('FTerm').run({ 'gcc', current_file, '-o', current_file_without_extension, '&&',
            echo_gaps_twice, '&&', './' ..
        current_file_without_extension })
    elseif is_file_extension({ 'rs' }) then
        require('FTerm').run({ echo_gaps })
        require('FTerm').run({ 'cargo', 'build', '&&', echo_gaps_twice
        , '&&', 'cargorun.py -m=debug --default-args' })
    elseif is_file_extension({ 'py' }) then
        require('FTerm').run({ echo_gaps_twice })
        require('FTerm').run({ 'python', current_file })
    elseif is_file_extension({ "sh" }) then
        require('FTerm').toggle();
    end
end

function CompileAndRunningRelease()
    local current_file = vim.fn.expand('%:p')
    local current_file_without_extension = vim.fn.expand('%:t:r')
    local cpp_extensions = { 'cpp', 'cxx', 'CPP' }
    local echo_gaps = [[(echo;printf '%*s\n' "$(tput cols)" | tr ' ' '-';echo)]]
    local echo_gaps_twice =
    [[(echo;printf '%*s\n' "$(tput cols)" | tr ' ' '-';printf '%*s\n' "$(tput cols)" | tr ' ' '-';echo)]]

    if is_file_extension(cpp_extensions) then
        require('FTerm').run({ echo_gaps })
        require('FTerm').run({ 'g++', current_file, '-o', current_file_without_extension, '&&',
            echo_gaps_twice, '&&', './' ..
        current_file_without_extension })
    elseif is_file_extension({ 'c' }) then
        require('FTerm').run({ echo_gaps })
        require('FTerm').run({ 'gcc', current_file, '-o', current_file_without_extension, '&&',
            echo_gaps_twice, '&&', './' ..
        current_file_without_extension })
    elseif is_file_extension({ 'rs' }) then
        require('FTerm').run({ echo_gaps })
        require('FTerm').run({ 'cargo', 'build', '--release &&', echo_gaps_twice
        , '&&', 'cargorun.py -m=release --default-args' })
    elseif is_file_extension({ 'py' }) then
        require('FTerm').run({ echo_gaps_twice })
        require('FTerm').run({ 'python', current_file })
    end
end
