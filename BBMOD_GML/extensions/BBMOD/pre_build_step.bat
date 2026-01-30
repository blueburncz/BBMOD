@echo off
setlocal
cd /d "%~dp0" || exit /b 1

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python not found in PATH!
    exit /b 1
)

python expand-shaders.py

endlocal
