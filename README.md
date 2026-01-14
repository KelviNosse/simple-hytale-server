# Simple Hytale Server

Automated Hytale server setup for Windows. Bare-metal deployment for plugins, mods, and 24/7 hosting.

> **Not for casual play** - Use Hytale's built-in invite code feature for quick sessions with friends.

## Requirements

- Windows 10 (1809+) or Windows 11
- 4GB RAM minimum (8GB recommended)
- Hytale account

Java 25 auto-installs during setup.

## Quick Start

### Interactive Menu (Recommended)
```powershell
.\hytale-manager.exe
```

Select from menu:
1. Setup Server (first-time)
2. Start Server
3. Start with Playit.gg Tunnel
4. Stop Server
5. Uninstall Server

### Direct Commands
```powershell
.\hytale-manager.exe setup
.\hytale-manager.exe start
.\hytale-manager.exe serve
.\hytale-manager.exe stop
.\hytale-manager.exe uninstall
```

### First-Time Setup
After running setup, authenticate in the server console:
```
/auth persistence Encrypted
/auth login device
```
Then visit the URL shown, enter the code, and stop the server with `/stop`.

## Project Structure

```
simple-hytale-server/
├── hytale-manager.exe    # Main executable
├── scripts/              # PowerShell automation scripts
├── src/                  # Source code (Go)
├── server/               # Generated: Hytale server files
└── downloader/           # Generated: Hytale downloader
```

## Internet Access

### With Playit.gg (No Port Forwarding)
```powershell
.\hytale-manager.exe serve   # Terminal 1: Start tunnel
.\hytale-manager.exe start   # Terminal 2: Start server
```
Visit <https://playit.gg> to claim your URL.

### With Port Forwarding
1. Run `.\hytale-manager.exe start`
2. Forward UDP port 5520 in router
3. Share your public IP

## Configuration

Edit `server/config.json`:
```json
{
  "ServerName": "My Server",
  "MaxPlayers": 20,
  "Password": ""
}
```

Edit `config.env` for RAM/Java:
```env
RAM_MIN=4
RAM_MAX=8
```