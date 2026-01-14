# ============================================
# Simple Hytale Server - Playit.gg Tunnel
# ============================================

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  PLAYIT.GG TUNNEL MANAGER" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if playit.gg is available
if (-not (Test-Path "playit-windows.exe")) {
    Write-Host "WARNING: Playit.gg tunnel not found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To use Playit.gg:" -ForegroundColor White
    Write-Host "  1. Run setup.bat" -ForegroundColor White
    Write-Host "  2. Choose 'Y' when asked about Playit.gg" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternatively, download manually from https://playit.gg/download" -ForegroundColor White
    Write-Host "and save as playit-windows.exe in this folder." -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Starting Playit.gg tunnel..." -ForegroundColor Yellow
Start-Process -FilePath "playit-windows.exe" -WindowStyle Normal
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  PLAYIT.GG TUNNEL ACTIVE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Visit https://playit.gg to claim your tunnel URL" -ForegroundColor Cyan
Write-Host "Share that URL with friends to connect" -ForegroundColor White
Write-Host ""
Write-Host "Tunnel is running in the background." -ForegroundColor Green
Write-Host "Now you can start the server." -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
