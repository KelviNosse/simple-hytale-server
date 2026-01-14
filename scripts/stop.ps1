# ============================================
# Simple Hytale Server - Stop Script
# ============================================

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  HYTALE - STOP SERVER" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Looking for running Hytale server..." -ForegroundColor Yellow
Write-Host ""

# Find Java process running HytaleServer.jar
$serverStopped = $false
$processes = Get-Process -Name java -ErrorAction SilentlyContinue

foreach ($proc in $processes) {
    try {
        $commandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
        if ($commandLine -like "*HytaleServer.jar*") {
            Write-Host "Found Hytale server process: PID $($proc.Id)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Stopping server..." -ForegroundColor Yellow
            
            Stop-Process -Id $proc.Id -Force
            
            Write-Host ""
            Write-Host "Server stopped successfully!" -ForegroundColor Green
            $serverStopped = $true
            break
        }
    } catch {
        # Skip processes we can't access
    }
}

if (-not $serverStopped) {
    Write-Host "No running Hytale server found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If the server is running in a console window, use the /stop command there." -ForegroundColor White
}

# Stop Playit.gg if running
Write-Host ""
Write-Host "Checking for Playit.gg tunnel..." -ForegroundColor Yellow

$playitProcess = Get-Process -Name "playit-windows" -ErrorAction SilentlyContinue
if ($playitProcess) {
    Write-Host "Stopping Playit.gg tunnel..." -ForegroundColor Yellow
    Stop-Process -Name "playit-windows" -Force -ErrorAction SilentlyContinue
    Write-Host "Playit.gg tunnel stopped." -ForegroundColor Green
}

Write-Host ""
Read-Host "Press Enter to exit"
