@echo off
echo =========================================
echo   PLAYIT.GG TUNNEL MANAGER
echo =========================================
echo.

REM Check if playit.gg is available
if not exist "playit-windows.exe" (
    echo WARNING: Playit.gg tunnel not found.
    echo.
    echo To use Playit.gg:
    echo   1. Run setup.bat
    echo   2. Choose "Y" when asked about Playit.gg
    echo.
    echo Alternatively, download manually from https://playit.gg/download
    echo and save as playit-windows.exe in this folder.
    echo.
    pause
    exit /b 1
)

echo Starting Playit.gg tunnel...
start /B playit-windows.exe
timeout /t 3 >nul
echo.
echo =========================================
echo   PLAYIT.GG TUNNEL ACTIVE
echo =========================================
echo.
echo Visit https://playit.gg to claim your tunnel URL
echo Share that URL with friends to connect
echo.
echo Tunnel is running in the background.
echo Now run start.bat in another terminal to start the server.
echo.
pause
