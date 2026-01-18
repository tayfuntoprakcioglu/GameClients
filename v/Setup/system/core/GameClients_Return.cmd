@echo off
setlocal
title Game Clients - Uninstall System

:: Parent directory check (Root dir)
pushd "%~dp0..\.."
set "ROOT_DIR=%CD%"
popd

echo.
echo ======================================================
echo    GAME CLIENTS - UNINSTALL
echo ======================================================
echo.
echo  This operation will completely remove Game Clients:
echo  1. Shell settings (Explorer.exe will return)
echo  2. UAC settings (Default)
echo  3. All Game Clients files will be deleted.
echo.
set /p confirm="Are you sure? (Y/N): "
if /i not "%confirm%"=="Y" exit /b

:: 1. SHELL REVERT
echo.
echo  [1/3] Reverting Shell (Explorer)...
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /f >nul 2>&1

:: 2. UAC REVERT
echo  [2/3] Reverting UAC settings...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 5 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f >nul 2>&1

:: 3. SELF DESTRUCT
echo  [3/3] Deleting files...
echo.
echo  System cleaned. Logging off...
timeout /t 3 >nul

:: Background self-delete command
start "" /b cmd /c "ping localhost -n 3 >nul & rd /s /q "%ROOT_DIR%""

:: Log off (Required for Shell change)
shutdown /l
