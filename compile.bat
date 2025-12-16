@echo off
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "KMCounter.ahk" /out "KMCounter.exe" /icon "resouces\KMCounter.ico"
echo Compilation exit code: %errorlevel%
pause