# Release script for hytale-manager
# Creates a distributable package with exe + scripts

Write-Host "Creating release package..." -ForegroundColor Cyan

# Build the exe first
Write-Host "Building executable..." -ForegroundColor Yellow
& .\build.ps1

if (-not (Test-Path "hytale-manager.exe")) {
    Write-Host "Build failed - exe not found" -ForegroundColor Red
    exit 1
}

# Create release directory
Write-Host "Preparing release folder..." -ForegroundColor Yellow
if (Test-Path "release") {
    Remove-Item "release" -Recurse -Force
}
New-Item -ItemType Directory -Force -Path "release/simple-hytale-server" | Out-Null

# Copy exe and scripts
Write-Host "Copying files..." -ForegroundColor Yellow
Copy-Item "hytale-manager.exe" -Destination "release/simple-hytale-server/"
Copy-Item "scripts" -Destination "release/simple-hytale-server/" -Recurse
Copy-Item "README.md" -Destination "release/simple-hytale-server/"
Copy-Item "LICENSE" -Destination "release/simple-hytale-server/" -ErrorAction SilentlyContinue

# Create zip
Write-Host "Creating zip package..." -ForegroundColor Yellow
$version = "1.0.0"
$zipName = "simple-hytale-server-v$version.zip"

Push-Location release
Compress-Archive -Path "simple-hytale-server" -DestinationPath $zipName -Force
Pop-Location

# Verify
if (Test-Path "release/$zipName") {
    $zipSize = (Get-Item "release/$zipName").Length / 1MB
    Write-Host ""
    Write-Host "Release package created: release/$zipName" -ForegroundColor Green
    Write-Host "Size: $([math]::Round($zipSize, 2)) MB" -ForegroundColor Green
    Write-Host ""
    Write-Host "Contents:" -ForegroundColor Yellow
    Write-Host "  - hytale-manager.exe" -ForegroundColor White
    Write-Host "  - scripts/ (5 PowerShell files)" -ForegroundColor White
    Write-Host "  - README.md" -ForegroundColor White
    Write-Host ""
    Write-Host "Ready for GitHub release!" -ForegroundColor Cyan
} else {
    Write-Host "Failed to create zip package" -ForegroundColor Red
    exit 1
}
