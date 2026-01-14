@echo off
echo =========================================
echo   HYTALE SERVER - UNINSTALL SCRIPT
echo =========================================
echo.
echo WARNING: This will delete ALL server files including:
echo   - Server folder (worlds, configs, mods)
echo   - Hytale downloader and credentials
echo.
echo This action CANNOT be undone!
echo.
echo The following will be kept:
echo   - setup.bat (to reinstall)
echo   - start.bat, serve.bat, and stop.bat (utility scripts)
echo   - uninstall.bat (this script)
echo   - README.md (documentation)
echo.
set /p CONFIRM="Are you sure you want to uninstall? (yes/no): "

if /i not "%CONFIRM%"=="yes" (
    echo.
    echo Uninstall cancelled.
    pause
    exit /b 0
)

echo.
echo Checking for running server...

REM Check if server is running
for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq java.exe" /FO LIST 2^>nul ^| find "PID:"') do (
    wmic process where "ProcessId=%%i" get CommandLine 2>nul | find "HytaleServer.jar" >nul
    if not errorlevel 1 (
        echo.
        echo ERROR: Hytale server is currently running!
        echo Please stop the server first using stop.bat or /stop command.
        echo.
        pause
        exit /b 1
    )
)

echo No running server found. Proceeding with uninstall...
echo.

REM Delete server folder
if exist "server" (
    echo Deleting server folder...
    rmdir /s /q "server"
    if errorlevel 1 (
        echo WARNING: Failed to delete server folder. Some files may be in use.
    ) else (
        echo Server folder deleted.
    )
)

REM Delete downloader folder
if exist "downloader" (
    echo Deleting downloader folder...
    rmdir /s /q "downloader"
    if errorlevel 1 (
        echo WARNING: Failed to delete downloader folder. Some files may be in use.
    ) else (
        echo Downloader folder deleted.
    )
)

REM Delete downloader credentials
if exist ".hytale-downloader-credentials.json" (
    echo Deleting Hytale downloader credentials...
    del /f /q ".hytale-downloader-credentials.json"
)

REM Delete Playit.gg tunnel
if exist "playit-windows.exe" (
    echo Deleting Playit.gg tunnel...
    del /f /q "playit-windows.exe"
)

REM Delete Playit.gg config
if exist "playit.toml" (
    del /f /q "playit.toml"
)

REM Delete server configuration
if exist "config.env" (
    echo Deleting server configuration...
    del /f /q "config.env"
)

echo.
echo =========================================
echo   UNINSTALL COMPLETE
echo =========================================
echo.
echo All server files have been removed.
echo To reinstall, run: setup.bat
echo.
pause
