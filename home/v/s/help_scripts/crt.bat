@echo off
setlocal enabledelayedexpansion

for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set "starttime=%%I"
set /a starttime=1*!starttime:~8,2! * 3600 + 1*!starttime:~10,2! * 60 + 1*!starttime:~12,2!

cargo run

for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set "endtime=%%I"
set /a endtime=1*!endtime:~8,2! * 3600 + 1*!endtime:~10,2! * 60 + 1*!endtime:~12,2!

set /a elapsedtime=endtime - starttime

if %errorlevel% equ 0 (
    if !elapsedtime! gtr 20 (
        my-alert-rs "ok"
    )
) else (
   if !elapsedtime! gtr 20 (
        my-alert-rs "err"
    )
)
