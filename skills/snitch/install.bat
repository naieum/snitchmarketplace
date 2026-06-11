@echo off
REM Snitch installer launcher for Windows.
REM Invokes install.ps1 with an execution policy bypass so users
REM don't have to fight PowerShell's default unsigned-script block.

setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set EXITCODE=%ERRORLEVEL%
echo.
pause
exit /b %EXITCODE%
