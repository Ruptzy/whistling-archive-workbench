@echo off
title Whistling Archive - put a shortcut on the Desktop
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\create-shortcut.ps1"
echo.
pause
