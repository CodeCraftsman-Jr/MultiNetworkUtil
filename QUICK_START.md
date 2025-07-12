# MultiNet - Quick Start Guide

## 🚀 One-Click Installation

### For Windows Users:

**Option 1: PowerShell (Recommended)**
1. Right-click on PowerShell and "Run as Administrator"
2. Navigate to the MultiNet folder
3. Run: `.\install.ps1`

**Option 2: Command Prompt**
1. Right-click on Command Prompt and "Run as Administrator"  
2. Navigate to the MultiNet folder
3. Run: `install.bat`

## 📋 What the installer does:

✅ Checks if Go is installed  
✅ Checks for Git and C compiler  
✅ Downloads all dependencies  
✅ Builds both CLI and GUI versions  
✅ Creates sample configuration  
✅ Shows your network adapters  

## 🔧 Manual Installation (if needed):

### 1. Install Go
- Download from: https://golang.org/dl/
- Install the Windows .msi file
- Restart your terminal

### 2. Install C Compiler (for GUI)
- Download TDM-GCC: https://jmeubank.github.io/tdm-gcc/
- Install and add to PATH

### 3. Build MultiNet
```bash
go mod tidy
go build -o multinet.exe ./multinet
go build -o multinet-gui.exe ./gui
```

## 🖥️ Usage:

### Command Line:
```bash
.\multinet.exe -cfg config.yaml
```

### GUI Version:
```bash
.\multinet-gui.exe
```

## ⚙️ Configuration:

1. **Find your network IPs:**
   ```bash
   ipconfig /all
   ```

2. **Edit config.yaml:**
   ```yaml
   algorithm: weighted-lru
   listen: 127.0.0.1:1080
   paths:
     - type: direct
       addr: YOUR_ETHERNET_IP    # e.g., 192.168.1.100
     - type: direct  
       addr: YOUR_WIFI_IP        # e.g., 192.168.1.101
   ```

3. **Configure your apps to use SOCKS5 proxy:**
   - Proxy: `127.0.0.1:1080`

## 🎯 Best Results With:
- Download managers (IDM, JDownloader)
- Game clients (Steam, Epic)
- Torrent clients
- Multiple browser tabs

## 🆘 Troubleshooting:

**"go: command not found"**
- Install Go from https://golang.org/dl/
- Restart terminal

**"gcc: command not found"**  
- Install TDM-GCC or MinGW-w64
- GUI won't work without C compiler

**Network adapters not found**
- Run as Administrator
- Check both LAN and WiFi are connected

**Firewall blocking**
- Allow multinet.exe through Windows Firewall

## 📞 Need Help?

1. Check `INSTALLATION_GUIDE.md` for detailed instructions
2. Check `SETUP_GUIDE.md` for usage help
3. Run the installer scripts - they check for common issues

---

**Ready to combine your internet connections for faster speeds!** 🚀
