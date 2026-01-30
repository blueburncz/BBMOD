@echo off
setlocal
cd /d "%~dp0" || exit /b 1

python expand-shaders.py

endlocal
