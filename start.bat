@echo off

REM Load server configuration
if not exist "config.env" (
    echo ERROR: Server not configured.
    echo Please run setup.bat first.
    pause
    exit /b 1
)

REM Parse config.env
for /f "tokens=1,* delims==" %%a in (config.env) do (
    if "%%a"=="JAVA_EXE" set "JAVA_EXE=%%b"
    if "%%a"=="RAM_MIN" set "RAM_MIN=%%b"
    if "%%a"=="RAM_MAX" set "RAM_MAX=%%b"
)

cd server

REM Check if server is already authenticated
if not exist "auth.enc" (
    echo.
    echo =========================================
    echo   FIRST TIME SETUP - AUTHENTICATION
    echo =========================================
    echo.
    echo Your server needs to be authenticated.
    echo After the server starts, run these commands in order:
    echo.
    echo   1. /auth persistence Encrypted
    echo   2. /auth login device
    echo.
    echo Then visit the URL shown and enter the code.
    echo After authentication, use /stop to shut down.
    echo.
    echo This is only needed once - future starts will be automatic.
    echo.
    echo Press any key to continue...
    pause >nul
    echo.
)

echo Starting Hytale Server...
echo.
"%JAVA_EXE%" -Xms%RAM_MIN%G -Xmx%RAM_MAX%G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -jar Server\HytaleServer.jar --assets .

cd ..
pause
