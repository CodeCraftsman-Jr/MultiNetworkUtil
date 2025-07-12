# Complete Installation Guide for MultiNet GUI

This guide will help you install Go and all dependencies needed to run MultiNet with GUI on a fresh Windows PC.

## Step 1: Install Go Programming Language

### Method 1: Download from Official Website (Recommended)

1. **Go to the official Go website:**
   - Visit: https://golang.org/dl/
   - Or direct link: https://go.dev/dl/

2. **Download Go for Windows:**
   - Click on the Windows installer (e.g., `go1.21.x.windows-amd64.msi`)
   - Choose the latest stable version

3. **Install Go:**
   - Run the downloaded `.msi` file
   - Follow the installation wizard (default settings are fine)
   - Go will be installed to `C:\Program Files\Go` by default

4. **Verify Installation:**
   - Open Command Prompt or PowerShell
   - Run: `go version`
   - You should see something like: `go version go1.21.x windows/amd64`

### Method 2: Using Package Manager (Alternative)

**Using Chocolatey (if you have it):**
```powershell
choco install golang
```

**Using Scoop (if you have it):**
```powershell
scoop install go
```

## Step 2: Set Up Environment Variables (Usually automatic)

If `go version` doesn't work, manually set up:

1. **Add Go to PATH:**
   - Open System Properties → Advanced → Environment Variables
   - Add `C:\Program Files\Go\bin` to your PATH
   - Add `C:\Users\YourUsername\go\bin` to your PATH

2. **Set GOPATH (optional for modern Go):**
   - Create environment variable `GOPATH` = `C:\Users\YourUsername\go`

## Step 3: Install Git (Required for Go modules)

1. **Download Git:**
   - Visit: https://git-scm.com/download/win
   - Download and install Git for Windows

2. **Verify Git installation:**
   ```bash
   git --version
   ```

## Step 4: Download and Set Up MultiNet

1. **Download the MultiNet project:**
   ```bash
   git clone https://github.com/NadeenUdantha/multinet.git
   cd multinet
   ```

   **Or download as ZIP:**
   - Go to: https://github.com/NadeenUdantha/multinet
   - Click "Code" → "Download ZIP"
   - Extract to a folder like `C:\multinet`

2. **Navigate to the project directory:**
   ```bash
   cd C:\path\to\multinet
   ```

## Step 5: Install Go Dependencies

1. **Install required Go modules:**
   ```bash
   go mod tidy
   ```

2. **Install GUI dependencies:**
   ```bash
   go get fyne.io/fyne/v2/app
   go get fyne.io/fyne/v2/widget
   go get fyne.io/fyne/v2/container
   ```

## Step 6: Install C Compiler (Required for Fyne GUI)

Fyne requires CGO, which needs a C compiler:

### Option A: Install TDM-GCC (Recommended)
1. Download from: https://jmeubank.github.io/tdm-gcc/
2. Install TDM-GCC (choose 64-bit version)
3. Make sure it's added to PATH during installation

### Option B: Install MinGW-w64
1. Download from: https://www.mingw-w64.org/downloads/
2. Install and add to PATH

### Option C: Install Visual Studio Build Tools
1. Download Visual Studio Build Tools
2. Install C++ build tools

## Step 7: Build MultiNet Applications

1. **Build the command-line version:**
   ```bash
   go build -o multinet.exe ./multinet
   ```

2. **Build the GUI version (after creating GUI code):**
   ```bash
   go build -o multinet-gui.exe ./gui
   ```

## Step 8: Verify Everything Works

1. **Test the command-line version:**
   ```bash
   ./multinet.exe -cfg example.cfg.yaml
   ```

2. **Test the GUI version:**
   ```bash
   ./multinet-gui.exe
   ```

## Troubleshooting Common Issues

### Issue: "go: command not found"
**Solution:** Go is not in PATH
- Restart your terminal/command prompt
- Check if Go is installed: `where go`
- Manually add Go to PATH if needed

### Issue: "gcc: command not found" or CGO errors
**Solution:** C compiler not installed
- Install TDM-GCC or MinGW-w64 as described above
- Make sure compiler is in PATH
- Restart terminal after installation

### Issue: "module not found" errors
**Solution:** Dependencies not downloaded
```bash
go clean -modcache
go mod download
go mod tidy
```

### Issue: Firewall blocking the application
**Solution:** 
- Allow multinet.exe through Windows Firewall
- Run as Administrator if needed

### Issue: Network adapters not detected
**Solution:**
- Run as Administrator
- Check if network adapters are enabled
- Verify both LAN and WiFi are connected

## Quick Installation Script

Create a batch file `install.bat` for automated setup:

```batch
@echo off
echo Installing MultiNet dependencies...

echo Checking Go installation...
go version
if %errorlevel% neq 0 (
    echo Go is not installed. Please install Go first.
    pause
    exit /b 1
)

echo Installing Go dependencies...
go mod tidy
go get fyne.io/fyne/v2/app
go get fyne.io/fyne/v2/widget  
go get fyne.io/fyne/v2/container

echo Building applications...
go build -o multinet.exe ./multinet
go build -o multinet-gui.exe ./gui

echo Installation complete!
echo Run: multinet.exe -cfg config.yaml (command line)
echo Or run: multinet-gui.exe (GUI version)
pause
```

## System Requirements

- **OS:** Windows 10/11 (64-bit recommended)
- **RAM:** 2GB minimum, 4GB recommended
- **Disk:** 500MB free space
- **Network:** Multiple active network connections (LAN + WiFi)
- **Permissions:** Administrator rights may be required

## Next Steps

After installation:
1. Configure your network adapters
2. Create or modify config.yaml
3. Run MultiNet GUI for easy management
4. Configure your applications to use the SOCKS5 proxy

For detailed usage instructions, see `SETUP_GUIDE.md`.
