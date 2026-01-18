@echo off
setlocal enabledelayedexpansion
title Game Clients GUI Shell
color 0b

set "CORE=%~dp0"
set "HTML_FILE=%CORE%GameClients_GUI.html"
set "JS_FILE=%CORE%gameclientsinstalled.js"

:: --- GENERATE INSTALLED APPS LIST ---
(
echo window.INSTALLED_APPS = [
) > "%JS_FILE%"

:: 1. EPIC GAMES
set "EPIC_FOUND=0"
reg query "HKLM\SOFTWARE\WOW6432Node\Epic Games\EpicGamesLauncher" /v "AppDataPath" >nul 2>&1
if %errorlevel%==0 set "EPIC_FOUND=1"
if exist "C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe" set "EPIC_FOUND=1"
if exist "C:\Program Files\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe" set "EPIC_FOUND=1"

if "%EPIC_FOUND%"=="1" ( echo "epic", >> "%JS_FILE%" )

:: 2. STEAM
set "STEAM_FOUND=0"
reg query "HKCU\Software\Valve\Steam" /v "SteamPath" >nul 2>&1
if %errorlevel%==0 set "STEAM_FOUND=1"
if exist "C:\Program Files (x86)\Steam\steam.exe" set "STEAM_FOUND=1"
if exist "C:\Program Files\Steam\steam.exe" set "STEAM_FOUND=1"
if "%STEAM_FOUND%"=="1" ( echo "steam", >> "%JS_FILE%" )

:: 3. UBISOFT CONNECT
set "UBI_FOUND=0"
reg query "HKLM\SOFTWARE\WOW6432Node\Ubisoft\Launcher" /v "InstallDir" >nul 2>&1
if %errorlevel%==0 set "UBI_FOUND=1"
if exist "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\UbisoftConnect.exe" set "UBI_FOUND=1"
if exist "C:\Program Files\Ubisoft\Ubisoft Game Launcher\UbisoftConnect.exe" set "UBI_FOUND=1"
if "%UBI_FOUND%"=="1" ( echo "ubi", >> "%JS_FILE%" )

:: 4. EA DESKTOP
set "EA_FOUND=0"
reg query "HKLM\SOFTWARE\WOW6432Node\Electronic Arts\EA Desktop" /v "ClientPath" >nul 2>&1
if %errorlevel%==0 set "EA_FOUND=1"
if exist "C:\Program Files\Electronic Arts\EA Desktop\EA Desktop\EADesktop.exe" set "EA_FOUND=1"
if exist "C:\Program Files (x86)\Electronic Arts\EA Desktop\EA Desktop\EADesktop.exe" set "EA_FOUND=1"
if "%EA_FOUND%"=="1" ( echo "ea", >> "%JS_FILE%" )

:: 5. BATTLE.NET
set "BNET_FOUND=0"
reg query "HKLM\SOFTWARE\WOW6432Node\Blizzard Entertainment\Battle.net\Capabilities" /v "ApplicationDescription" >nul 2>&1
if %errorlevel%==0 set "BNET_FOUND=1"
if exist "C:\Program Files (x86)\Battle.net\Battle.net.exe" set "BNET_FOUND=1"
if exist "C:\Program Files\Battle.net\Battle.net.exe" set "BNET_FOUND=1"
if "%BNET_FOUND%"=="1" ( echo "bnet", >> "%JS_FILE%" )

:: 6. ROCKSTAR
set "ROCK_FOUND=0"
reg query "HKLM\SOFTWARE\WOW6432Node\Rockstar Games\Launcher" /v "InstallFolder" >nul 2>&1
if %errorlevel%==0 set "ROCK_FOUND=1"
if exist "C:\Program Files\Rockstar Games\Launcher\Launcher.exe" set "ROCK_FOUND=1"
if exist "C:\Program Files (x86)\Rockstar Games\Launcher\Launcher.exe" set "ROCK_FOUND=1"
if "%ROCK_FOUND%"=="1" ( echo "rock", >> "%JS_FILE%" )

:: 7. RIOT
set "RIOT_FOUND=0"
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Riot Client" /v "UninstallString" >nul 2>&1
if %errorlevel%==0 set "RIOT_FOUND=1"
if exist "C:\Riot Games\Riot Client\RiotClientServices.exe" set "RIOT_FOUND=1"
if "%RIOT_FOUND%"=="1" ( echo "riot", >> "%JS_FILE%" )

:: --- PROTOCOL REGISTRATION & LOG MONITOR ---
set "HANDLER=%CORE%GameClients_Handler.cmd"
set "ESCAPED=%HANDLER:\=\\%"

:: 1. Register Protocol (Silent)
reg add "HKCU\Software\Classes\gameclients" /ve /d "URL:GameClients Protocol" /f >nul 2>&1
reg add "HKCU\Software\Classes\gameclients" /v "URL Protocol" /f >nul 2>&1
reg add "HKCU\Software\Classes\gameclients\shell\open\command" /ve /d "\"%ESCAPED%\" \"%%1\"" /f >nul 2>&1

:: 2. Start Log Monitor (Background)
start "Game Clients Log Monitor" "%HANDLER%"

echo ]; >> "%JS_FILE%"
echo window.SYS_USER = "%USERNAME%"; >> "%JS_FILE%"
echo window.SYS_PC = "%COMPUTERNAME%"; >> "%JS_FILE%"
:: ------------------------------------

:GUI_LOOP
cls
:: Start Browser in Kiosk/App Mode
start "" "%HTML_FILE%"

echo.
echo  ======================================================
echo    GAME CLIENTS GUI IS RUNNING
echo  ======================================================
echo.
echo  If you closed the window, to re-open:
echo  1) Restart Interface
echo  2) SHUTDOWN PC
echo  3) UNINSTALL / REVERT
echo.
set /p opt="Selection: "

if "%opt%"=="1" goto GUI_LOOP
if "%opt%"=="2" shutdown /s /t 0
if "%opt%"=="3" (
    call "%CORE%GameClients_Return.cmd"
    exit
)

goto GUI_LOOP
