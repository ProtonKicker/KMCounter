@echo off
REM Simple batch file to compile KMCounter with verbose output
echo Running Ahk2Exe compiler...
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in KMCounter.ahk /verbose

echo.
echo Checking if executable was created...
if exist KMCounter.exe (
    echo Compilation successful! KMCounter.exe created.
    dir KMCounter.exe
) else (
    echo Compilation failed. Please check the script for errors.
)
echo.
echo Compiler version:
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /version
pause