@echo off
setlocal enabledelayedexpansion
REM ============================================
REM Simple Hytale Server - Automatic Setup
REM ============================================

echo.
echo =========================================
echo    HYTALE SERVER - AUTOMATIC SETUP
echo =========================================
echo.

REM Check Java version
:check_java
echo [1/6] Checking Java installation...
set "java_installed=0"
set "jver=0"

java -version >nul 2>&1
if not errorlevel 1 (
    REM Java found, check version
    for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
        set "verstr=%%v"
        set "verstr=!verstr:"=!"
        for /f "delims=." %%a in ("!verstr!") do set "jver=%%a"
    )

    if !jver! geq 25 (
        set "java_installed=1"
    )
)

if !java_installed!==1 (
    echo OK - Java !jver! detected
    echo.
    goto :java_ready
)

REM Java not found or wrong version - search for existing Java 25 installation
echo.
if !jver!==0 (
    echo No Java found in PATH.
) else (
    echo Java !jver! detected in PATH.
)
echo Searching for Java 25 installation...

REM Try to find Java 25 before prompting for install
call :find_java25_check
if "!JAVA_EXE!"=="" (
    REM Java 25 not found anywhere, prompt for installation
    echo.
    if !jver!==0 (
        echo Java 25 is not installed on your system.
    ) else (
        echo Java !jver! detected, but Hytale requires Java 25 or higher.
    )
    echo.
    echo Would you like to install Java 25 automatically? (Y/N)
) else (
    REM Found Java 25, skip installation
    echo Found Java 25 at: !JAVA_EXE!
    echo.
    goto :java_ready
)
echo.
echo This will install Eclipse Temurin 25 JDK (recommended by Adoptium)
echo Installation path: Default system location
echo.
set /p INSTALL_JAVA="Install Java 25? (Y/N): "

if /i "!INSTALL_JAVA!"=="N" (
    echo.
    echo Installation cancelled.
    echo Please install Java 25 manually from: https://adoptium.net/
    echo.
    pause
    exit /b 1
)

if /i not "!INSTALL_JAVA!"=="Y" (
    echo Invalid choice. Please enter Y or N.
    goto :check_java
)

echo.
echo Installing Java 25... This may take a few minutes.
echo.

REM Try winget first (built into Windows 10/11)
echo Checking for Windows Package Manager (winget)...
winget --version >nul 2>&1
if not errorlevel 1 (
    echo Found winget! Installing Java 25...
    echo.
    echo Please wait - downloading and installing Java 25...
    echo (A UAC prompt may appear - please click Yes to allow installation)
    echo.

    winget install EclipseAdoptium.Temurin.25.JDK --silent --accept-package-agreements --accept-source-agreements

    echo.
    echo Refreshing environment variables...
    call :refresh_env
    goto :verify_java
) else (
    echo winget not available.
    goto :manual_install
)

:manual_install
echo.
echo =========================================
echo   MANUAL INSTALLATION REQUIRED
echo =========================================
echo.
echo Please install Java 25 manually:
echo.
echo 1. Open this link: https://adoptium.net/temurin/releases/?version=25
echo 2. Download "Windows x64 JDK .msi"
echo 3. Run the installer (use default settings)
echo 4. Restart this script after installation
echo.
pause
exit /b 1

:refresh_env
REM Refresh environment variables without restarting shell
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYS_PATH=%%b"
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USR_PATH=%%b"
set "PATH=!SYS_PATH!;!USR_PATH!"
goto :eof

:verify_java
echo.
echo Verifying Java installation...
timeout /t 2 >nul

java -version >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: Java command not found after installation.
    echo Please restart your computer and run this script again.
    echo.
    pause
    exit /b 1
)

set "jver=0"
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set "verstr=%%v"
    set "verstr=!verstr:"=!"
    for /f "delims=." %%a in ("!verstr!") do set "jver=%%a"
)

if !jver! lss 25 (
    echo.
    echo WARNING: Java !jver! detected after installation.
    echo Please restart your computer and run this script again.
    echo.
    pause
    exit /b 1
)

echo OK - Java !jver! installed and ready!
echo.

:java_ready
REM Find the exact Java 25 installation path (if not already found)
if "!JAVA_EXE!"=="" (
    echo Locating Java 25 installation...
    call :find_java25_check
    if "!JAVA_EXE!"=="" (
        echo.
        echo WARNING: Could not locate Java 25 installation directory.
        echo The server will use the default 'java' command.
        echo.
        set "JAVA_EXE=java"
    ) else (
        echo Found Java 25 at: !JAVA_EXE!
        echo.
    )
)
goto :continue_setup

:find_java25_check
REM Search for Java 25 installation in common locations
set "JAVA_EXE="

REM Method 1: Check JAVA_HOME if it points to Java 25
if defined JAVA_HOME (
    if exist "!JAVA_HOME!\bin\java.exe" (
        for /f "tokens=3" %%v in ('"!JAVA_HOME!\bin\java.exe" -version 2^>^&1 ^| findstr /i "version"') do (
            set "verstr=%%v"
            set "verstr=!verstr:"=!"
            for /f "delims=." %%a in ("!verstr!") do (
                if %%a geq 25 (
                    set "JAVA_EXE=!JAVA_HOME!\bin\java.exe"
                    goto :eof
                )
            )
        )
    )
)

REM Method 2: Search Eclipse Adoptium installation directories
for /d %%d in ("C:\Program Files\Eclipse Adoptium\jdk-25*") do (
    if exist "%%d\bin\java.exe" (
        set "JAVA_EXE=%%d\bin\java.exe"
        goto :eof
    )
)

REM Method 3: Search Eclipse Adoptium in Program Files (x86)
for /d %%d in ("C:\Program Files (x86)\Eclipse Adoptium\jdk-25*") do (
    if exist "%%d\bin\java.exe" (
        set "JAVA_EXE=%%d\bin\java.exe"
        goto :eof
    )
)

REM Method 4: Search Temurin installation directories
for /d %%d in ("C:\Program Files\Eclipse Foundation\jdk-25*") do (
    if exist "%%d\bin\java.exe" (
        set "JAVA_EXE=%%d\bin\java.exe"
        goto :eof
    )
)

REM Method 5: Check if 'java' command points to Java 25+
where java >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
        set "verstr=%%v"
        set "verstr=!verstr:"=!"
        for /f "delims=." %%a in ("!verstr!") do (
            if %%a geq 25 (
                REM Get full path from where command
                for /f "delims=" %%p in ('where java 2^>nul') do (
                    set "JAVA_EXE=%%p"
                    goto :eof
                )
            )
        )
    )
)

goto :eof

:continue_setup
REM Java is ready with full path, continue with setup
REM Get server configuration
echo [2/6] Server Configuration
echo.
set /p SERVER_NAME="Enter server name (default: My Hytale Server): "
if "!SERVER_NAME!"=="" set "SERVER_NAME=My Hytale Server"

set /p MAX_PLAYERS="Enter max players (default: 20): "
if "!MAX_PLAYERS!"=="" set "MAX_PLAYERS=20"

set /p RAM_MIN="Enter minimum RAM in GB (default: 4): "
if "!RAM_MIN!"=="" set "RAM_MIN=4"

set /p RAM_MAX="Enter maximum RAM in GB (default: 8): "
if "!RAM_MAX!"=="" set "RAM_MAX=8"

echo.
echo Enable external access via Playit.gg tunnel?
echo This allows friends to connect WITHOUT port forwarding.
echo.
echo   YES - Automatic tunnel (easiest, no port forwarding needed)
echo   NO  - Manual port forwarding required (default)
echo.
set /p ENABLE_PLAYIT="Enable Playit.gg? (Y/N, default: N): "
if "!ENABLE_PLAYIT!"=="" set "ENABLE_PLAYIT=N"

echo.
echo [3/6] Downloading Hytale server files...
echo.

REM Create directories
mkdir downloader 2>nul
mkdir server 2>nul

REM Download Hytale downloader if not present
if not exist "downloader\hytale-downloader-windows-amd64.exe" (
    echo Downloading Hytale downloader...
    curl -L -o downloader\hytale-downloader.zip https://downloader.hytale.com/hytale-downloader.zip

    if errorlevel 1 (
        echo ERROR: Failed to download Hytale downloader
        pause
        exit /b 1
    )

    echo Extracting downloader...
    tar -xf downloader\hytale-downloader.zip -C downloader
    del downloader\hytale-downloader.zip
)

echo.
echo Running Hytale downloader...
echo You may need to authenticate with your Hytale account.
echo.
echo =========================================
echo   AUTHENTICATION REQUIRED
echo =========================================
echo.
echo The downloader will show an authorization URL.
echo Open the URL in your browser and enter the code.
echo.
pause

cd downloader
hytale-downloader-windows-amd64.exe -download-path ../server -credentials-path .hytale-downloader-credentials.json
cd ..

REM Check if server.zip was created and extract it
if exist "server.zip" (
    echo.
    echo Extracting server files...
    tar -xf server.zip -C server
    if not errorlevel 1 (
        echo Server files extracted successfully!
        del server.zip
    ) else (
        echo ERROR: Failed to extract server.zip
        pause
        exit /b 1
    )
)

REM Check if Assets.zip exists and extract it
if exist "server\Assets.zip" (
    echo.
    echo Extracting assets... This may take a few minutes.
    cd server
    tar -xf Assets.zip
    if not errorlevel 1 (
        echo Assets extracted successfully.
        del Assets.zip
    ) else (
        echo ERROR: Failed to extract Assets.zip
        cd ..
        pause
        exit /b 1
    )
    cd ..
)

if not exist "server\Server\HytaleServer.jar" (
    echo.
    echo ERROR: Server files not downloaded.
    echo This might be because Hytale hasn't released the server yet.
    echo Your credentials are saved and the script will work once servers are available.
    echo.
    pause
    exit /b 1
)

REM Download playit.gg if enabled
if /i "!ENABLE_PLAYIT!"=="Y" (
    echo.
    echo [3.5/6] Downloading Playit.gg tunnel
    echo.
    
    if not exist "playit-windows.exe" (
        echo Downloading playit-windows.exe (64-bit)
        curl -L -o playit-windows.exe https://github.com/playit-cloud/playit-agent/releases/download/v0.16.5/playit-windows-x86_64-signed.exe
        
        if errorlevel 1 (
            echo WARNING: Failed to download Playit.gg
            echo You can download manually from: https://playit.gg/download
            set "ENABLE_PLAYIT=N"
        ) else (
            echo Playit.gg downloaded successfully.
        )
    ) else (
        echo Playit.gg already downloaded.
    )
)

echo.
echo [4/6] Configuring server...
echo.

REM Create config.json
(
echo {
echo   "Version": 3,
echo   "ServerName": "!SERVER_NAME!",
echo   "MOTD": "Welcome!",
echo   "Password": "",
echo   "MaxPlayers": !MAX_PLAYERS!,
echo   "MaxViewRadius": 32,
echo   "LocalCompressionEnabled": false,
echo   "Defaults": {
echo     "World": "default",
echo     "GameMode": "Adventure"
echo   },
echo   "RateLimit": {},
echo   "LogLevels": {},
echo   "DisplayTmpTagsInStrings": false,
echo   "PlayerStorage": {
echo     "Type": "Hytale"
echo   },
echo   "AuthCredentialStore": {
echo     "Type": "Encrypted",
echo     "Path": "auth.enc"
echo   }
echo }
) > server\config.json

echo Server config created!
echo.

REM Create configuration file
echo [5/6] Creating configuration...
echo.

(
echo # Server configuration - Generated by setup.bat
echo JAVA_EXE=!JAVA_EXE!
echo RAM_MIN=!RAM_MIN!
echo RAM_MAX=!RAM_MAX!
) > config.env

echo Configuration created: config.env
echo Server will use: !JAVA_EXE!
echo.

REM First launch for authentication
echo [6/6] Initial server setup...
echo.
echo Starting server for first-time authentication...
echo.
echo =========================================
echo   IMPORTANT - AUTHENTICATION SETUP
echo =========================================
echo.
echo The server will start now.
echo In the server console, you need to run these commands:
echo.
echo   1. /auth persistence Encrypted
echo   2. /auth login device
echo.
echo Then open the URL shown and enter the device code.
echo After that, you can stop the server with: /stop
echo.
echo Press any key to start the server...
pause >nul

cd server
"!JAVA_EXE!" -Xms!RAM_MIN!G -Xmx!RAM_MAX!G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -jar Server\HytaleServer.jar --assets .
cd ..

echo.
echo =========================================
echo   SETUP COMPLETE!
echo =========================================
echo.
echo Your Hytale server is configured and ready!
echo.
echo Available Scripts:
echo   start.bat      - Start the Hytale server (local only)
echo   serve.bat      - Start server with Playit.gg tunnel (internet)
echo   stop.bat       - Stop the running server
echo   uninstall.bat  - Remove all server files and start fresh
echo.
echo Server Details:
echo   Name: !SERVER_NAME!
echo   Max Players: !MAX_PLAYERS!
echo   RAM: !RAM_MIN!GB - !RAM_MAX!GB
echo   Authentication: Encrypted (persistent)
if /i "!ENABLE_PLAYIT!"=="Y" (
echo   Playit.gg: Enabled
)
echo.
echo To connect locally: localhost:5520
if /i "!ENABLE_PLAYIT!"=="Y" (
echo For internet: Run serve.bat and claim your tunnel at https://playit.gg
) else (
echo For internet: Use serve.bat (with Playit.gg) or forward UDP port 5520
)
echo.
pause
