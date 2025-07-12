@echo off
echo ========================================
echo    YAML Dependency Fix Script
echo ========================================
echo.

echo This script fixes the gopkg.in/yaml.v3 download issue
echo.

echo [1/4] Setting Go environment for better compatibility...
go env -w GOPROXY=https://goproxy.io,direct
go env -w GOSUMDB=off
echo Environment configured.

echo [2/4] Cleaning module cache...
go clean -modcache

echo [3/4] Downloading dependencies with alternative proxy...
go mod download
if %errorlevel% neq 0 (
    echo Trying with different proxy...
    go env -w GOPROXY=https://proxy.golang.org,direct
    go mod download
    if %errorlevel% neq 0 (
        echo Trying direct download...
        go env -w GOPROXY=direct
        go mod download
    )
)

echo [4/4] Running go mod tidy...
go mod tidy
if %errorlevel% neq 0 (
    echo ERROR: Still having issues. This might be a network/firewall problem.
    echo.
    echo Try these solutions:
    echo 1. Use a VPN or different network
    echo 2. Check if your firewall/antivirus is blocking Go
    echo 3. Try running as Administrator
    echo 4. Contact your network administrator about Go module access
    pause
    exit /b 1
)

echo.
echo SUCCESS: Dependencies fixed!
echo.
echo Now try running the main installation:
echo   install.ps1  (PowerShell)
echo   install.bat  (Command Prompt)
echo.
pause
