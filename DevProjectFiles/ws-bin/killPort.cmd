@echo off
setlocal enabledelayedexpansion

title 杀死端口

set port=%1%
if "%port%" == "" goto inputPort
goto runKill

:inputPort
set /p port=please input port=

:runKill
echo port=%port%
if "%port%" == "" goto noPortEnd

for /f "tokens=1-5" %%a in ('netstat -ano ^| find "0.0:%port%"') do (
    if "%%e%" == "" (
        set pid=%%d
    ) else (
        set pid=%%e
    )
    echo pid=!pid!
    rem taskkill /f /pid !pid!
)
goto end

:noPortEnd
echo no port to kill

:end


pause