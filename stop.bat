@echo off
echo =========================================
echo   HYTALE - STOP SERVER
echo =========================================
echo.
echo Looking for running Hytale server...
echo.

REM Find Java process running HytaleServer.jar
for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq java.exe" /FO LIST ^| find "PID:"') do (
    set PID=%%i
    REM Check if this Java process is running HytaleServer.jar
    wmic process where "ProcessId=%%i" get CommandLine 2>nul | find "HytaleServer.jar" >nul
    if not errorlevel 1 (
        echo Found Hytale server process: PID %%i
        echo.
        echo Stopping server...
        taskkill /PID %%i /T /F
        if not errorlevel 1 (
            echo.
            echo Server stopped successfully!
        ) else (
            echo.
            echo Failed to stop server. Try closing the server console manually.
        )
        goto :end
    )
)

echo No running Hytale server found.
echo.
echo If the server is running in a console window, use the /stop command there.

:end

REM Stop Playit.gg if running
echo.
echo Checking for Playit.gg tunnel...
tasklist /FI "IMAGENAME eq playit-windows.exe" 2>nul | find /I "playit-windows.exe" >nul
if not errorlevel 1 (
    echo Stopping Playit.gg tunnel...
    taskkill /IM playit-windows.exe /F >nul 2>&1
    if not errorlevel 1 (
        echo Playit.gg tunnel stopped.
    )
)

echo.
pause
