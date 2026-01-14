# Simple Hytale Server

Automated Hytale server setup for Windows.

## Requirements

- Windows 10 (1809+) or Windows 11
- 4GB+ RAM
- Hytale account

Java 25 auto-installs during setup.

## Usage

Run the manager:
```powershell
.\hytale-manager.exe
```

**Menu:**
1. Setup Server (first-time)
2. Start Server
3. Start Playit.gg Tunnel
4. Stop Server
5. Uninstall Server

**Or use direct commands:**
```powershell
.\hytale-manager.exe setup
.\hytale-manager.exe start
.\hytale-manager.exe serve
.\hytale-manager.exe stop
.\hytale-manager.exe uninstall
```

## First-Time Setup

After running setup, authenticate in the server console:
```
/auth persistence Encrypted
/auth login device
```
Visit the URL shown, enter the code, then `/stop`.

## Internet Access

**Playit.gg (easiest):**
```powershell
.\hytale-manager.exe serve
.\hytale-manager.exe start
```
Claim tunnel at https://playit.gg

**Port forwarding:**
Forward UDP port 5520 in your router.

## Configuration

`server/config.json` - Server settings
`config.env` - RAM and Java path