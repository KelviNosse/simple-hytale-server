# Simple Hytale Server

Automated Hytale server setup for Windows. Bare-metal deployment for plugins, mods, and 24/7 hosting.

> **Not for casual play** - Use Hytale's built-in invite code feature for quick sessions with friends.

## Requirements

- Windows 10 (1809+) or Windows 11
- 4GB RAM minimum (8GB recommended)
- Hytale account

Java 25 auto-installs during setup.

## Quick Start

```powershell
# 1. Run setup (one-time)
.\setup.bat

# 2. Authenticate when prompted
/auth persistence Encrypted
/auth login device

# 3. Stop initial server
/stop

# 4. Start server anytime
.\start.bat
```

## Scripts

- **`setup.bat`** - One-time installation
- **`start.bat`** - Start server
- **`serve.bat`** - Start Playit.gg tunnel (for internet access)
- **`stop.bat`** - Stop server and tunnel
- **`uninstall.bat`** - Remove all files

## Internet Access

### With Playit.gg (No Port Forwarding)
```powershell
.\serve.bat   # Terminal 1: Start tunnel
.\start.bat   # Terminal 2: Start server
```
Visit <https://playit.gg> to claim your URL.

### With Port Forwarding
1. Run `.\start.bat`
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