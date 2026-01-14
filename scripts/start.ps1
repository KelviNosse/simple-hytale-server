# ============================================
# Simple Hytale Server - Start Script
# ============================================

$ErrorActionPreference = "Stop"

# Load server configuration
if (-not (Test-Path "config.env")) {
    Write-Host "ERROR: Server not configured." -ForegroundColor Red
    Write-Host "Please run setup.bat first." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Parse config.env
$config = @{}
Get-Content "config.env" | ForEach-Object {
    if ($_ -match '^([^#].+?)=(.+)$') {
        $config[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$javaExe = $config['JAVA_EXE']
$ramMin = $config['RAM_MIN']
$ramMax = $config['RAM_MAX']

# Check if server is already authenticated
if (-not (Test-Path "server\auth.enc")) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "  FIRST TIME SETUP - AUTHENTICATION" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your server needs to be authenticated." -ForegroundColor Yellow
    Write-Host "After the server starts, run these commands in order:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. /auth persistence Encrypted" -ForegroundColor Yellow
    Write-Host "  2. /auth login device" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Then visit the URL shown and enter the code." -ForegroundColor White
    Write-Host "After authentication, use /stop to shut down." -ForegroundColor White
    Write-Host ""
    Write-Host "This is only needed once - future starts will be automatic." -ForegroundColor Green
    Write-Host ""
    Read-Host "Press Enter to continue"
    Write-Host ""
}

Write-Host "Starting Hytale Server in new window..." -ForegroundColor Green
Write-Host ""

$serverPath = Join-Path (Get-Location) "server"
$javaArgs = "-Xms$($ramMin)G", "-Xmx$($ramMax)G", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled", "-XX:MaxGCPauseMillis=200", "-jar", "Server\HytaleServer.jar", "--assets", "."

if ($javaExe -eq "java") {
    Start-Process -FilePath "java" -ArgumentList $javaArgs -WorkingDirectory $serverPath -WindowStyle Normal
} else {
    Start-Process -FilePath $javaExe -ArgumentList $javaArgs -WorkingDirectory $serverPath -WindowStyle Normal
}

Write-Host "Server started in separate window" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
