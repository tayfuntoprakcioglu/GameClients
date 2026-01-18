@echo off
setlocal enabledelayedexpansion
title Game Clients Installer
color 0b

:: Admin Check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ======================================================
    echo  ADMIN RIGHTS REQUIRED
    echo ======================================================
    echo.
    echo  Please right-click the file and select "Run as Administrator".
    echo.
    pause
    exit
)

set "CORE=%~dp0system\core"

:MENU
cls
echo.
echo ======================================================
echo    GAME CLIENTS - SETUP
echo ======================================================
echo.
echo  1) START INSTALLATION (Set Shell ^& UAC)
echo  2) EXIT
echo.
set /p ch="Selection: "

if "%ch%"=="1" goto SETUP
if "%ch%"=="2" exit
goto MENU

:SETUP
cls
echo.
echo [1/3] Registering Protocol (gameclients://)...
reg add "HKCR\gameclients" /ve /t REG_SZ /d "URL:Game Clients Protocol" /f >nul
reg add "HKCR\gameclients" /v "URL Protocol" /t REG_SZ /d "" /f >nul
set "HANDLER=%CORE%\GameClients_Handler.cmd"
reg add "HKCR\gameclients\shell\open\command" /ve /t REG_SZ /d "\"%HANDLER%\" \"%%1\"" /f >nul

echo [2/3] Application of UAC Settings (Game Mode)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f >nul

echo [3/3] Setting Interface...
echo.
echo  Activating GUI (Visual HTML Interface)...
set "SHELL_COMMAND=\"%CORE%\GameClients_GUI.cmd\""

:: Winlogon Shell Change
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "%SHELL_COMMAND%" /f >nul

echo.
echo  =========================================
echo   INSTALLATION COMPLETE!
echo  =========================================
echo.
echo  You must LOG OFF and LOG IN for changes to take effect.
echo.
echo  1) Log Off Now (Recommended)
echo  2) Return to Main Menu
echo.
set /p r="Selection: "
if "%r%"=="1" shutdown /l
goto MENU
