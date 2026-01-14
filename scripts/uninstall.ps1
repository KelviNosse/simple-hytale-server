# ============================================
# Simple Hytale Server - Uninstall Script
# ============================================

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Red
Write-Host "  HYTALE SERVER - UNINSTALL SCRIPT" -ForegroundColor Red
Write-Host "=========================================" -ForegroundColor Red
Write-Host ""
Write-Host "WARNING: This will delete ALL server files including:" -ForegroundColor Yellow
Write-Host "  - Server folder (worlds, configs, mods)" -ForegroundColor White
Write-Host "  - Hytale downloader and credentials" -ForegroundColor White
Write-Host ""
Write-Host "This action CANNOT be undone!" -ForegroundColor Red
Write-Host ""
Write-Host "The following will be kept:" -ForegroundColor Green
Write-Host "  - All .ps1 and .bat scripts (to reinstall)" -ForegroundColor White
Write-Host "  - README.md (documentation)" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Are you sure you want to uninstall? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host ""
    Write-Host "Uninstall cancelled." -ForegroundColor Green
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host ""
Write-Host "Checking for running server..." -ForegroundColor Yellow

# Check if server is running
$processes = Get-Process -Name java -ErrorAction SilentlyContinue
foreach ($proc in $processes) {
    try {
        $commandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
        if ($commandLine -like "*HytaleServer.jar*") {
            Write-Host ""
            Write-Host "ERROR: Hytale server is currently running!" -ForegroundColor Red
            Write-Host "Please stop the server first using stop.bat or /stop command." -ForegroundColor Yellow
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }
    } catch {
        # Skip processes we can't access
    }
}

Write-Host "No running server found. Proceeding with uninstall..." -ForegroundColor Green
Write-Host ""

# Delete server folder
if (Test-Path "server") {
    Write-Host "Deleting server folder..." -ForegroundColor Yellow
    try {
        Remove-Item -Path "server" -Recurse -Force
        Write-Host "Server folder deleted." -ForegroundColor Green
    } catch {
        Write-Host "WARNING: Failed to delete server folder. Some files may be in use." -ForegroundColor Yellow
    }
}

# Delete downloader folder
if (Test-Path "downloader") {
    Write-Host "Deleting downloader folder..." -ForegroundColor Yellow
    try {
        Remove-Item -Path "downloader" -Recurse -Force
        Write-Host "Downloader folder deleted." -ForegroundColor Green
    } catch {
        Write-Host "WARNING: Failed to delete downloader folder. Some files may be in use." -ForegroundColor Yellow
    }
}

# Delete downloader credentials
if (Test-Path ".hytale-downloader-credentials.json") {
    Write-Host "Deleting Hytale downloader credentials..." -ForegroundColor Yellow
    Remove-Item -Path ".hytale-downloader-credentials.json" -Force
}

# Delete Playit.gg tunnel
if (Test-Path "playit-windows.exe") {
    Write-Host "Deleting Playit.gg tunnel..." -ForegroundColor Yellow
    Remove-Item -Path "playit-windows.exe" -Force
}

# Delete Playit.gg config
if (Test-Path "playit.toml") {
    Remove-Item -Path "playit.toml" -Force
}

# Delete server configuration
if (Test-Path "config.env") {
    Write-Host "Deleting server configuration..." -ForegroundColor Yellow
    Remove-Item -Path "config.env" -Force
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  UNINSTALL COMPLETE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "All server files have been removed." -ForegroundColor White
Write-Host "To reinstall, run: setup.bat" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
