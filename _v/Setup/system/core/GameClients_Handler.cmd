@echo off
setlocal enabledelayedexpansion
title Game Clients Handler & LOG MONITOR
color 0a

:: Define Log File
set "LOGFILE=%~dp0activity.log"
set "TIMESTAMP=%DATE% %TIME%"

:: If no parameter -> MONITOR MODE (Run in background)
if "%1"=="" goto MONITOR_MODE

:: --- ACTION MODE (Triggered by links) ---
set "INPUT=%1"
set "INPUT=%INPUT:"=%"

:: Write to Log
echo [%TIMESTAMP%] TRIGGERED: %INPUT% >> "%LOGFILE%"

:: Protocol Routing
if "%INPUT%"=="gameclients:epic" goto RUN_EPIC
if "%INPUT%"=="gameclients:steam" goto RUN_STEAM
if "%INPUT%"=="gameclients:ubi" goto RUN_UBI
if "%INPUT%"=="gameclients:bnet" goto RUN_BNET
if "%INPUT%"=="gameclients:ea" goto RUN_EA
if "%INPUT%"=="gameclients:riot" goto RUN_RIOT
if "%INPUT%"=="gameclients:rock" goto RUN_ROCK
if "%INPUT%"=="gameclients:xbox" goto RUN_XBOX
if "%INPUT%"=="ms-xbox:" goto RUN_XBOX
if "%INPUT%"=="gameclients:toolbox" goto RUN_TOOLBOX
if "%INPUT%"=="gameclients:restart" goto RUN_RESTART
if "%INPUT%"=="gameclients:shutdown" goto RUN_SHUTDOWN
if "%INPUT%"=="gameclients:return" goto RUN_RETURN
if "%INPUT%"=="gameclients:uninstall" goto RUN_RETURN
if "%INPUT%"=="gameclients:downloads" goto RUN_DOWNLOADS
if "%INPUT%"=="gameclients:appsize" goto RUN_APPSIZE
if "%INPUT%"=="gameclients:bluetooth" goto RUN_BLUETOOTH
if "%INPUT%"=="gameclients:wifi" goto RUN_WIFI
if "%INPUT%"=="gameclients:optimize" goto RUN_OPTIMIZE
if "%INPUT%"=="gameclients:restore" goto RUN_RESTORE

echo [%TIMESTAMP%] ERROR: Undefined command -> %INPUT% >> "%LOGFILE%"
exit

:MONITOR_MODE
cls
echo ======================================================
echo   GAME CLIENTS LOG MONITOR
echo   Listening for browser events...
echo ======================================================
echo.
:: Create Log file if not exists
if not exist "%LOGFILE%" (echo [System Started] > "%LOGFILE%")

:: Live log tracking using PowerShell
powershell -Command "Get-Content -Path '%LOGFILE%' -Wait"
exit

:: --- COMMAND BLOCKS ---
:RUN_BLUETOOTH
echo [%TIMESTAMP%] Opening Bluetooth Settings... >> "%LOGFILE%"
start ms-settings:bluetooth
exit

:RUN_WIFI
echo [%TIMESTAMP%] Opening Wifi Settings... >> "%LOGFILE%"
start ms-settings:network-wifi
exit

:RUN_OPTIMIZE
echo [%TIMESTAMP%] GAME MODE: Maximum Performance Mode Active... >> "%LOGFILE%"

:: 1. Close Explorer (Desktop/Taskbar)
taskkill /F /IM explorer.exe >nul 2>&1

:: 2. Power Plan: High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1

:: 3. Stop Unnecessary Services
set "SERVICES=Spooler WSearch DiagTrack SysMain Themes WerSvc DPS PcaSvc MapsBroker TabletInputService"
for %%S in (%SERVICES%) do (
    net stop %%S /y >nul 2>&1
)

:: 4. Kill Background Apps (Bloatware)
set "APPS=OneDrive.exe Teams.exe Skype.exe Cortana.exe SearchUI.exe TextInputHost.exe PhoneExperienceHost.exe Calculator.exe YourPhone.exe"
for %%A in (%APPS%) do (
    taskkill /F /IM %%A >nul 2>&1
)

:: 5. Clean Clean Files (Temp)
echo [%TIMESTAMP%] Cleaning Temp files... >> "%LOGFILE%"
del /s /f /q "%TEMP%\*.*" >nul 2>&1
rd /s /q "%TEMP%" >nul 2>&1
md "%TEMP%" >nul 2>&1

:: Flush DNS Cache
ipconfig /flushdns >nul 2>&1

echo [%TIMESTAMP%] System Optimized (RAM/CPU Freed). >> "%LOGFILE%"
exit

:RUN_RESTORE
echo [%TIMESTAMP%] DESKTOP MODE: System restoring to normal... >> "%LOGFILE%"

:: 1. Power Plan: Balanced (Default)
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1

:: 2. Start Services
set "SERVICES=Spooler WSearch SysMain Themes TabletInputService"
for %%S in (%SERVICES%) do (
    net start %%S >nul 2>&1
)

:: 3. Start Explorer
start explorer.exe

echo [%TIMESTAMP%] Desktop Restored. >> "%LOGFILE%"
exit

:RUN_EPIC
echo [%TIMESTAMP%] Starting Epic Games... >> "%LOGFILE%"
set "P1=C:\Program Files\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe"
start "" "%P1%"
call :RESIZE_WINDOW "EpicGamesLauncher"
exit

:RUN_STEAM
echo [%TIMESTAMP%] Starting Steam... >> "%LOGFILE%"
start "" "steam://open/main"
exit

:RUN_UBI
echo [%TIMESTAMP%] Starting Ubisoft Connect... >> "%LOGFILE%"
start "" "uplay://"
:: Fallback EXE check
timeout /t 2 >nul
tasklist | find /i "UbisoftConnect.exe" >nul
if %errorlevel% neq 0 (
    if exist "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\UbisoftConnect.exe" (
        cd /d "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\"
        start "" "UbisoftConnect.exe"
    )
)
exit

:RUN_BNET
echo [%TIMESTAMP%] Starting Battle.net... >> "%LOGFILE%"
start "" "battlenet://"
:: Fallback EXE
timeout /t 2 >nul
tasklist | find /i "Battle.net.exe" >nul
if %errorlevel% neq 0 (
    if exist "C:\Program Files (x86)\Battle.net\Battle.net.exe" (
        cd /d "C:\Program Files (x86)\Battle.net\"
        start "" "Battle.net.exe"
    )
)
exit

:RUN_EA
echo [%TIMESTAMP%] Starting EA App... >> "%LOGFILE%"
:: Protocol sometimes unstable for EA App, Direct EXE is better
set "EA_PATH=C:\Program Files\Electronic Arts\EA Desktop\EA Desktop\EADesktop.exe"
if exist "%EA_PATH%" (
    cd /d "C:\Program Files\Electronic Arts\EA Desktop\EA Desktop\"
    start "" "EADesktop.exe"
    exit
)
start "" "origin://"
exit

:RUN_RIOT
echo [%TIMESTAMP%] Starting Riot Client... >> "%LOGFILE%"
set "RIOT_PATH=C:\Riot Games\Riot Client\RiotClientServices.exe"
if exist "%RIOT_PATH%" (
    cd /d "C:\Riot Games\Riot Client\"
    start "" "RiotClientServices.exe" --launch-product=league_of_legends --launch-patchline=live
    exit
)
start "" "riot:"
exit

:RUN_ROCK
echo [%TIMESTAMP%] Starting Rockstar Launcher... >> "%LOGFILE%"
set "ROCK_PATH=C:\Program Files\Rockstar Games\Launcher\Launcher.exe"
if exist "%ROCK_PATH%" (
    cd /d "C:\Program Files\Rockstar Games\Launcher\"
    start "" "Launcher.exe"
    exit
)
set "ROCK_PATH=C:\Program Files (x86)\Rockstar Games\Launcher\Launcher.exe"
if exist "%ROCK_PATH%" (
    cd /d "C:\Program Files (x86)\Rockstar Games\Launcher\"
    start "" "Launcher.exe"
    exit
)
start "" "rockstar:"
exit

:RUN_XBOX
echo [%TIMESTAMP%] Starting Xbox App... >> "%LOGFILE%"
start "" "xbox:"
exit


:RUN_DOWNLOADS
echo [%TIMESTAMP%] Opening Downloads folder... >> "%LOGFILE%"
start "" "%USERPROFILE%\Downloads"
exit

:RUN_APPSIZE
echo [%TIMESTAMP%] Opening Add/Remove Programs... >> "%LOGFILE%"
start control appwiz.cpl
exit

:RUN_TOOLBOX
echo [%TIMESTAMP%] Searching for Toolbox... >> "%LOGFILE%"
:: 1. Quick Check
set "CHECK_PATHS=C:\Windows\AtlasToolbox.exe;%USERPROFILE%\Desktop\AtlasToolbox.exe;%USERPROFILE%\Desktop\Atlas\AtlasToolbox.exe;%~dp0..\..\AtlasToolbox.exe;C:\Program Files\Atlas Toolbox\AtlasToolbox.exe;C:\Program Files (x86)\Atlas Toolbox\AtlasToolbox.exe"

for %%P in ("%CHECK_PATHS:;=" "%") do (
    if exist "%%~P" (
        echo [%TIMESTAMP%] Found: %%~P >> "%LOGFILE%"
        echo [%TIMESTAMP%] Setting working directory: %%~dpP >> "%LOGFILE%"
        
        :: Go to working directory
        cd /d "%%~dpP"
        start "" "%%~nxP"
        exit
    )
)

:: 2. Deep Search
echo [%TIMESTAMP%] Starting Deep Search... >> "%LOGFILE%"
for /f "delims=" %%A in ('dir /b /s "C:\AtlasToolbox.exe" 2^>nul') do (
    echo [%TIMESTAMP%] Found: %%A >> "%LOGFILE%"
    echo [%TIMESTAMP%] Setting working directory: %%~dpA >> "%LOGFILE%"
    
    :: Go to working directory
    cd /d "%%~dpA"
    start "" "%%~nxA"
    exit
)
echo [%TIMESTAMP%] ERROR: Toolbox not found! >> "%LOGFILE%"
exit

:RUN_RESTART
echo [%TIMESTAMP%] SYSTEM RESTARTING... >> "%LOGFILE%"
shutdown /r /t 0
exit

:RUN_SHUTDOWN
echo [%TIMESTAMP%] SYSTEM SHUTTING DOWN... >> "%LOGFILE%"
shutdown /s /t 0
exit

:RUN_RETURN
echo [%TIMESTAMP%] Returning to Interface... >> "%LOGFILE%"
call "%~dp0GameClients_Return.cmd"
exit

:RESIZE_WINDOW
:: %1 = Process Name (without .exe)
timeout /t 3 >nul
echo [%TIMESTAMP%] Resizing Window: %~1 >> "%LOGFILE%"
set "PS_CMD=$code='[DllImport(""user32.dll"")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);'; $type=Add-Type -MemberDefinition $code -Name Win32Move -Namespace Win32 -PassThru; $proc=Get-Process -Name '%~1' -ErrorAction SilentlyContinue; if($proc){ $type::MoveWindow($proc.MainWindowHandle, 100, 100, 800, 600, $true) }"
powershell -Command "%PS_CMD%"
goto :EOF
