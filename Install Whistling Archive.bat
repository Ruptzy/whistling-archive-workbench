@echo off
title Whistling Archive - put a shortcut on the Desktop
cd /d "%~dp0"

if not exist "index.html" goto :zip
if not exist "tools\create-shortcut.ps1" goto :zip

rem One-time tidy: remove Windows' "downloaded from the internet" mark from
rem everything in this folder, so nothing here shows a warning again.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%~dp0' -Recurse -File | Unblock-File" >nul 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -File "tools\create-shortcut.ps1"
echo.
pause
exit /b

:zip
echo.
echo   It looks like this was opened from INSIDE the downloaded ZIP,
echo   so the rest of the Workbench isn't here yet.
echo.
echo   1. Close this window.
echo   2. Right-click the ZIP you downloaded and choose "Extract All...".
echo   3. Open the extracted folder and double-click "Install Whistling Archive" again.
echo.
pause
