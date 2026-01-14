# Build script for hytale-manager.exe
# Requires: go

Write-Host "Building Hytale Server Manager..." -ForegroundColor Cyan

Push-Location src

# Build the executable
Write-Host "Compiling executable..." -ForegroundColor Yellow
go build -ldflags="-s -w" -o ../hytale-manager.exe manager.go

# Verify exe was created
if (Test-Path ../hytale-manager.exe) {
    $exeSize = (Get-Item ../hytale-manager.exe).Length
    Write-Host "✓ Executable created: $('{0:N0}' -f $exeSize) bytes" -ForegroundColor Green
} else {
    Write-Host "✗ Build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

Write-Host "`n✅ Build complete: hytale-manager.exe" -ForegroundColor Green
