@echo off
set "full_command=%*"
echo [%full_command%]
%*
set exit_code=%errorlevel%
exit /b %exit_code%
