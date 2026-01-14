# ============================================
# Simple Hytale Server - Automatic Setup
# ============================================

$ErrorActionPreference = "Stop"

# Helper function to find Java 25
function Find-Java25 {
    # Method 1: Check JAVA_HOME
    if ($env:JAVA_HOME -and (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
        try {
            $versionOutput = & "$env:JAVA_HOME\bin\java.exe" -version 2>&1 | Out-String
            if ($versionOutput -match 'version "(\d+)') {
                if ([int]$matches[1] -ge 25) {
                    return "$env:JAVA_HOME\bin\java.exe"
                }
            }
        } catch {}
    }
    
    # Method 2: Search Eclipse Adoptium directories
    $searchPaths = @(
        "C:\Program Files\Eclipse Adoptium\jdk-25*",
        "C:\Program Files (x86)\Eclipse Adoptium\jdk-25*",
        "C:\Program Files\Eclipse Foundation\jdk-25*"
    )
    
    foreach ($pattern in $searchPaths) {
        $dirs = Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue
        foreach ($dir in $dirs) {
            $javaExe = Join-Path $dir.FullName "bin\java.exe"
            if (Test-Path $javaExe) {
                return $javaExe
            }
        }
    }
    
    # Method 3: Check if 'java' command points to Java 25+
    try {
        $javaCmd = Get-Command java -ErrorAction Stop
        $versionOutput = & java -version 2>&1 | Out-String
        if ($versionOutput -match 'version "(\d+)') {
            if ([int]$matches[1] -ge 25) {
                return $javaCmd.Source
            }
        }
    } catch {}
    
    return $null
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   HYTALE SERVER - AUTOMATIC SETUP" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check Java version
Write-Host "[1/6] Checking Java installation..." -ForegroundColor Yellow

$javaInstalled = $false
$javaVersion = 0
$javaPath = $null

try {
    $javaCmd = Get-Command java -ErrorAction Stop
    $versionOutput = & java -version 2>&1 | Out-String
    if ($versionOutput -match 'version "(\d+)') {
        $javaVersion = [int]$matches[1]
        if ($javaVersion -ge 25) {
            $javaInstalled = $true
            $javaPath = $javaCmd.Source
        }
    }
} catch {
    # Java not in PATH
}

if ($javaInstalled) {
    Write-Host "OK - Java $javaVersion detected" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host ""
    if ($javaVersion -eq 0) {
        Write-Host "No Java found in PATH." -ForegroundColor Yellow
    } else {
        Write-Host "Java $javaVersion detected in PATH." -ForegroundColor Yellow
    }
    Write-Host "Searching for Java 25 installation..." -ForegroundColor Yellow
    
    # Search for Java 25
    $javaPath = Find-Java25
    
    if ($javaPath) {
        Write-Host "Found Java 25 at: $javaPath" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        if ($javaVersion -eq 0) {
            Write-Host "Java 25 is not installed on your system." -ForegroundColor Yellow
        } else {
            Write-Host "Java $javaVersion detected, but Hytale requires Java 25 or higher." -ForegroundColor Yellow
        }
        Write-Host ""
        
        $install = Read-Host "Would you like to install Java 25 automatically? (Y/N)"
        
        if ($install -eq 'N' -or $install -eq 'n') {
            Write-Host ""
            Write-Host "Installation cancelled." -ForegroundColor Red
            Write-Host "Please install Java 25 manually from: https://adoptium.net/" -ForegroundColor Yellow
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }
        
        if ($install -ne 'Y' -and $install -ne 'y') {
            Write-Host "Invalid choice. Please enter Y or N." -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        
        Write-Host ""
        Write-Host "Installing Java 25... This may take a few minutes." -ForegroundColor Yellow
        Write-Host ""
        
        # Try winget
        Write-Host "Checking for Windows Package Manager (winget)..." -ForegroundColor Yellow
        try {
            $null = winget --version
            Write-Host "Found winget! Installing Java 25..." -ForegroundColor Green
            Write-Host ""
            Write-Host "Please wait - downloading and installing Java 25..." -ForegroundColor Yellow
            Write-Host "(A UAC prompt may appear - please click Yes to allow installation)" -ForegroundColor Yellow
            Write-Host ""
            
            winget install EclipseAdoptium.Temurin.25.JDK --silent --accept-package-agreements --accept-source-agreements
            
            Write-Host ""
            Write-Host "Refreshing environment..." -ForegroundColor Yellow
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            Start-Sleep -Seconds 2
            
            Write-Host ""
            Write-Host "Verifying Java installation..." -ForegroundColor Yellow
            
            try {
                $javaCmd = Get-Command java -ErrorAction Stop
                $versionOutput = & java -version 2>&1 | Out-String
                if ($versionOutput -match 'version "(\d+)') {
                    $javaVersion = [int]$matches[1]
                    if ($javaVersion -ge 25) {
                        $javaPath = $javaCmd.Source
                        Write-Host "OK - Java $javaVersion installed and ready!" -ForegroundColor Green
                        Write-Host ""
                    } else {
                        Write-Host ""
                        Write-Host "WARNING: Java $javaVersion detected after installation." -ForegroundColor Red
                        Write-Host "Please restart your computer and run this script again." -ForegroundColor Yellow
                        Write-Host ""
                        Read-Host "Press Enter to exit"
                        exit 1
                    }
                }
            } catch {
                Write-Host ""
                Write-Host "WARNING: Java command not found after installation." -ForegroundColor Red
                Write-Host "Please restart your computer and run this script again." -ForegroundColor Yellow
                Write-Host ""
                Read-Host "Press Enter to exit"
                exit 1
            }
        } catch {
            Write-Host "winget not available." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "=========================================" -ForegroundColor Red
            Write-Host "  MANUAL INSTALLATION REQUIRED" -ForegroundColor Red
            Write-Host "=========================================" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please install Java 25 manually:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "1. Open this link: https://adoptium.net/temurin/releases/?version=25" -ForegroundColor White
            Write-Host "2. Download 'Windows x64 JDK .msi'" -ForegroundColor White
            Write-Host "3. Run the installer (use default settings)" -ForegroundColor White
            Write-Host "4. Restart this script after installation" -ForegroundColor White
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
}

# Find Java path if not already set
if (-not $javaPath) {
    Write-Host "Locating Java 25 installation..." -ForegroundColor Yellow
    $javaPath = Find-Java25
    
    if (-not $javaPath) {
        Write-Host ""
        Write-Host "WARNING: Could not locate Java 25 installation directory." -ForegroundColor Yellow
        Write-Host "The server will use the default 'java' command." -ForegroundColor Yellow
        Write-Host ""
        $javaPath = "java"
    } else {
        Write-Host "Found Java 25 at: $javaPath" -ForegroundColor Green
        Write-Host ""
    }
}

# Server Configuration
Write-Host "[2/6] Server Configuration" -ForegroundColor Yellow
Write-Host ""

$serverName = Read-Host "Enter server name (default: My Hytale Server)"
if ([string]::IsNullOrWhiteSpace($serverName)) { $serverName = "My Hytale Server" }

$maxPlayers = Read-Host "Enter max players (default: 20)"
if ([string]::IsNullOrWhiteSpace($maxPlayers)) { $maxPlayers = 20 }

$ramMin = Read-Host "Enter minimum RAM in GB (default: 4)"
if ([string]::IsNullOrWhiteSpace($ramMin)) { $ramMin = 4 }

$ramMax = Read-Host "Enter maximum RAM in GB (default: 8)"
if ([string]::IsNullOrWhiteSpace($ramMax)) { $ramMax = 8 }

Write-Host ""
Write-Host "Enable external access via Playit.gg tunnel?" -ForegroundColor Yellow
Write-Host "This allows friends to connect WITHOUT port forwarding." -ForegroundColor White
Write-Host ""
Write-Host "  YES - Automatic tunnel (easiest, no port forwarding needed)" -ForegroundColor White
Write-Host "  NO  - Manual port forwarding required (default)" -ForegroundColor White
Write-Host ""

$enablePlayit = Read-Host "Enable Playit.gg? (Y/N, default: N)"
if ([string]::IsNullOrWhiteSpace($enablePlayit)) { $enablePlayit = "N" }

# Download Hytale server files
Write-Host ""
Write-Host "[3/6] Downloading Hytale server files..." -ForegroundColor Yellow
Write-Host ""

# Create directories
New-Item -ItemType Directory -Force -Path "downloader" | Out-Null
New-Item -ItemType Directory -Force -Path "server" | Out-Null

# Download Hytale downloader if not present
if (-not (Test-Path "downloader\hytale-downloader-windows-amd64.exe")) {
    Write-Host "Downloading Hytale downloader..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://downloader.hytale.com/hytale-downloader.zip" -OutFile "downloader\hytale-downloader.zip"
    
    Write-Host "Extracting downloader..." -ForegroundColor Yellow
    Expand-Archive -Path "downloader\hytale-downloader.zip" -DestinationPath "downloader" -Force
    Remove-Item "downloader\hytale-downloader.zip"
}

Write-Host ""
Write-Host "Running Hytale downloader..." -ForegroundColor Yellow
Write-Host "You may need to authenticate with your Hytale account." -ForegroundColor White
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  AUTHENTICATION REQUIRED" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The downloader will show an authorization URL." -ForegroundColor White
Write-Host "Open the URL in your browser and enter the code." -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue"

Push-Location downloader
& .\hytale-downloader-windows-amd64.exe -download-path ..\server -credentials-path .hytale-downloader-credentials.json
Pop-Location

# Check if server.zip was created and extract it
if (Test-Path "server.zip") {
    Write-Host ""
    Write-Host "Extracting server files..." -ForegroundColor Yellow
    Expand-Archive -Path "server.zip" -DestinationPath "server" -Force
    Remove-Item "server.zip"
    Write-Host "Server files extracted successfully!" -ForegroundColor Green
}

# Check if Assets.zip exists and extract it
if (Test-Path "server\Assets.zip") {
    Write-Host ""
    Write-Host "Extracting assets... This may take a few minutes." -ForegroundColor Yellow
    Push-Location server
    Expand-Archive -Path "Assets.zip" -DestinationPath "." -Force
    Remove-Item "Assets.zip"
    Write-Host "Assets extracted successfully." -ForegroundColor Green
    Pop-Location
}

if (-not (Test-Path "server\Server\HytaleServer.jar")) {
    Write-Host ""
    Write-Host "ERROR: Server files not downloaded." -ForegroundColor Red
    Write-Host "This might be because Hytale hasn't released the server yet." -ForegroundColor Yellow
    Write-Host "Your credentials are saved and the script will work once servers are available." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Download playit.gg if enabled
if ($enablePlayit -eq 'Y' -or $enablePlayit -eq 'y') {
    Write-Host ""
    Write-Host "[3.5/6] Downloading Playit.gg tunnel" -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Test-Path "playit-windows.exe")) {
        Write-Host "Downloading playit-windows.exe (64-bit)" -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri "https://github.com/playit-cloud/playit-agent/releases/download/v0.16.5/playit-windows-x86_64-signed.exe" -OutFile "playit-windows.exe"
            Write-Host "Playit.gg downloaded successfully." -ForegroundColor Green
        } catch {
            Write-Host "WARNING: Failed to download Playit.gg" -ForegroundColor Yellow
            Write-Host "You can download manually from: https://playit.gg/download" -ForegroundColor White
        }
    } else {
        Write-Host "Playit.gg already downloaded." -ForegroundColor Green
    }
}

# Create config.json
Write-Host ""
Write-Host "[4/6] Configuring server..." -ForegroundColor Yellow
Write-Host ""

$configJson = @"
{
  "Version": 3,
  "ServerName": "$serverName",
  "MOTD": "Welcome!",
  "Password": "",
  "MaxPlayers": $maxPlayers,
  "MaxViewRadius": 32,
  "LocalCompressionEnabled": false,
  "Defaults": {
    "World": "default",
    "GameMode": "Adventure"
  },
  "RateLimit": {},
  "LogLevels": {},
  "DisplayTmpTagsInStrings": false,
  "PlayerStorage": {
    "Type": "Hytale"
  },
  "AuthCredentialStore": {
    "Type": "Encrypted",
    "Path": "auth.enc"
  }
}
"@

$configJson | Out-File -FilePath "server\config.json" -Encoding UTF8

Write-Host "Server config created!" -ForegroundColor Green
Write-Host ""

# Create configuration file
Write-Host "[5/6] Creating configuration..." -ForegroundColor Yellow
Write-Host ""

$configEnv = @"
# Server configuration - Generated by setup.ps1
JAVA_EXE=$javaPath
RAM_MIN=$ramMin
RAM_MAX=$ramMax
"@

$configEnv | Out-File -FilePath "config.env" -Encoding UTF8

Write-Host "Configuration created: config.env" -ForegroundColor Green
Write-Host "Server will use: $javaPath" -ForegroundColor White
Write-Host ""

# First launch for authentication
Write-Host "[6/6] Initial server setup..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Starting server for first-time authentication..." -ForegroundColor Yellow
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  IMPORTANT - AUTHENTICATION SETUP" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The server will start now." -ForegroundColor White
Write-Host "In the server console, you need to run these commands:" -ForegroundColor White
Write-Host ""
Write-Host "  1. /auth persistence Encrypted" -ForegroundColor Yellow
Write-Host "  2. /auth login device" -ForegroundColor Yellow
Write-Host ""
Write-Host "Then open the URL shown and enter the device code." -ForegroundColor White
Write-Host "After that, you can stop the server with: /stop" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to start the server"

Push-Location server
if ($javaPath -eq "java") {
    & java -Xms"$ramMin`G" -Xmx"$ramMax`G" -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -jar Server\HytaleServer.jar --assets .
} else {
    & $javaPath -Xms"$ramMin`G" -Xmx"$ramMax`G" -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -jar Server\HytaleServer.jar --assets .
}
Pop-Location

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Hytale server is configured and ready!" -ForegroundColor White
Write-Host ""
Write-Host "Available Scripts:" -ForegroundColor Yellow
Write-Host "  start.bat      - Start the Hytale server (local only)" -ForegroundColor White
Write-Host "  serve.bat      - Start server with Playit.gg tunnel (internet)" -ForegroundColor White
Write-Host "  stop.bat       - Stop the running server" -ForegroundColor White
Write-Host "  uninstall.bat  - Remove all server files and start fresh" -ForegroundColor White
Write-Host ""
Write-Host "Server Details:" -ForegroundColor Yellow
Write-Host "  Name: $serverName" -ForegroundColor White
Write-Host "  Max Players: $maxPlayers" -ForegroundColor White
Write-Host "  RAM: $ramMin`GB - $ramMax`GB" -ForegroundColor White
Write-Host "  Authentication: Encrypted (persistent)" -ForegroundColor White

if ($enablePlayit -eq 'Y' -or $enablePlayit -eq 'y') {
    Write-Host "  Playit.gg: Enabled" -ForegroundColor White
}

Write-Host ""
Write-Host "To connect locally: localhost:5520" -ForegroundColor Cyan

if ($enablePlayit -eq 'Y' -or $enablePlayit -eq 'y') {
    Write-Host "For internet: Run serve.bat and claim your tunnel at https://playit.gg" -ForegroundColor Cyan
} else {
    Write-Host "For internet: Use serve.bat (with Playit.gg) or forward UDP port 5520" -ForegroundColor Cyan
}

Write-Host ""
Read-Host "Press Enter to exit"
