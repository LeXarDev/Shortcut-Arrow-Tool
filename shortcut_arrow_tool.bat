@echo off
setlocal EnableDelayedExpansion

:: --- Header with date/time ---
echo ==========================================
echo         Shortcut Arrow Modifier 
echo               @LeXarDev  
echo        %DATE% %TIME%
echo ==========================================
echo.

:: --- Check for admin privileges ---
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrator privileges...
    powershell start -verb runas '%~0'
    exit /b
)

:: --- Check current shortcut arrow status ---
REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 >nul 2>&1
if "%errorlevel%"=="0" (
    echo Current status: Shortcut arrow is ^<REMOVED^>
) else (
    echo Current status: Shortcut arrow is ^<DEFAULT^>
)
echo.

:: --- Ask user for action ---
echo What do you want to do?
echo [1] Remove shortcut arrow
echo [2] Restore default arrow
set /p action="Choose 1 or 2: "

if "%action%"=="1" (
    set mode=remove
) else if "%action%"=="2" (
    set mode=restore
) else (
    echo Invalid choice. Exiting.
    pause
    exit /b
)

:: --- Confirm action ---
set /p confirm="Are you sure you want to %mode% the shortcut arrow? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b
)

:: --- Backup registry ---
echo Backing up current registry setting...
reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" "%~dp0ShellIcons_Backup.reg" /y
echo Backup saved to ShellIcons_Backup.reg
echo.

:: --- Perform action ---
if "%mode%"=="remove" (
    echo Removing shortcut arrow...
    REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /t REG_SZ /d \"\" /f
) else (
    echo Restoring default shortcut arrow...
    REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f
)


:: --- Restart Explorer ---
echo Restarting Explorer to apply changes...
taskkill /f /im explorer.exe >nul
start explorer.exe

echo.
echo Done! Shortcut arrow has been %mode%d.
pause