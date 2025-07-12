@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    MultiNet Installation Script
echo ========================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Not running as Administrator
    echo Some features may not work properly
    echo.
)

:: Check Go installation
echo [1/6] Checking Go installation...
go version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Go is not installed or not in PATH
    echo.
    echo Please install Go first:
    echo 1. Visit: https://golang.org/dl/
    echo 2. Download and install Go for Windows
    echo 3. Restart your terminal and run this script again
    echo.
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('go version') do echo Found: %%i
)
echo.

:: Check Git installation
echo [2/6] Checking Git installation...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Git not found
    echo Git is recommended for downloading dependencies
    echo You can download it from: https://git-scm.com/download/win
    echo.
) else (
    for /f "tokens=*" %%i in ('git --version') do echo Found: %%i
)
echo.

:: Check for C compiler (required for Fyne)
echo [3/6] Checking C compiler...
gcc --version >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: C compiler (gcc) not found
    echo Fyne GUI requires a C compiler. Please install one of:
    echo 1. TDM-GCC: https://jmeubank.github.io/tdm-gcc/
    echo 2. MinGW-w64: https://www.mingw-w64.org/downloads/
    echo 3. Visual Studio Build Tools
    echo.
    set /p continue="Continue anyway? (y/n): "
    if /i "!continue!" neq "y" exit /b 1
) else (
    echo C compiler found
)
echo.

:: Download dependencies
echo [4/6] Installing Go dependencies...
echo Downloading dependencies directly from GitHub repositories...

echo Getting go-socks5 from GitHub...
go get github.com/armon/go-socks5
if %errorlevel% neq 0 (
    echo WARNING: Failed to get go-socks5, trying alternative...
)

echo Getting golang-lru from GitHub...
go get github.com/hashicorp/golang-lru
if %errorlevel% neq 0 (
    echo WARNING: Failed to get golang-lru, trying alternative...
)

echo Running: go mod tidy
go mod tidy
if %errorlevel% neq 0 (
    echo ERROR: Failed to download dependencies
    echo Make sure you have internet connection and Git installed
    pause
    exit /b 1
)

echo Installing GUI dependencies...
go get fyne.io/fyne/v2/app
go get fyne.io/fyne/v2/widget
go get fyne.io/fyne/v2/container
echo.

:: Build applications
echo [5/6] Building applications...

echo Building command-line version...
go build -o multinet.exe ./multinet
if %errorlevel% neq 0 (
    echo ERROR: Failed to build command-line version
    pause
    exit /b 1
) else (
    echo [OK] multinet.exe created successfully
)

echo Building GUI version...
if exist gui\main.go (
    go build -o multinet-gui.exe ./gui
    if %errorlevel% neq 0 (
        echo WARNING: Failed to build GUI version
        echo This might be due to missing C compiler
    ) else (
        echo [OK] multinet-gui.exe created successfully
    )
) else (
    echo GUI source not found, skipping GUI build
)
echo.

:: Create sample configuration
echo [6/6] Creating sample configuration...
if not exist config.yaml (
    copy example.cfg.yaml config.yaml >nul
    echo [OK] config.yaml created from example
) else (
    echo config.yaml already exists
)
echo.

:: Final instructions
echo ========================================
echo         Installation Complete!
echo ========================================
echo.
echo Available executables:
if exist multinet.exe echo   [OK] multinet.exe (command-line version)
if exist multinet-gui.exe echo   [OK] multinet-gui.exe (GUI version)
echo.
echo Next steps:
echo 1. Edit config.yaml with your network adapter IPs
echo 2. Run: multinet.exe -cfg config.yaml
if exist multinet-gui.exe echo    Or run: multinet-gui.exe (for GUI)
echo 3. Configure your applications to use SOCKS5 proxy: 127.0.0.1:1080
echo.
echo For help finding your network IPs, run: ipconfig /all
echo.
echo Press any key to exit...
pause >nul
