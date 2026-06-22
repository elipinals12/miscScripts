@echo off
color 0a
title Wi-Fi Info Grabber

echo -----------------------------------------------
echo               Wi-Fi Info Grabber
echo -----------------------------------------------

:: Get TRUE SSID
for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces ^| findstr /r "^....Profile"') do (
    set "ssid=%%a"
)

:: Trim leading and trailing spaces from SSID
for /f "tokens=* delims= " %%b in ("%ssid%") do (
    set "ssid=%%b"
)

set "ssid=%ssid:~0,-1%"

echo     SSID                   : %ssid%



:: GET JUST BEGINNING OF SSID FOR PASS SEARCH
for /f "tokens=* delims= " %%d in ("%ssid%") do (
    set "ssid=%%d"
)
for /f "delims=' tokens=1" %%l in ("%ssid%") do set "ssid=%%l"


netsh wlan show profile name="%ssid%*" key=clear | findstr /r "^....Key"


echo -----------------------------------------------
pause