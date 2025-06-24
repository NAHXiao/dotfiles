@echo off
echo [%*]
start "" /b %*
exit /b %ERRORLEVEL%
