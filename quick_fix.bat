@echo off
echo ========================================
echo    Quick Dependency Fix
echo ========================================
echo.

echo Based on your output, most dependencies are working!
echo Fixing the golang-lru version issue...
echo.

echo [1/4] Setting Go environment...
go env -w GOPROXY=https://goproxy.io,direct
go env -w GOSUMDB=off

echo [2/4] Getting dependencies without version specifiers...
go get github.com/armon/go-socks5
go get github.com/hashicorp/golang-lru
go get gopkg.in/yaml.v3

echo [3/4] Running go mod tidy...
go mod tidy
if %errorlevel% neq 0 (
    echo Trying with different proxy...
    go env -w GOPROXY=direct
    go mod tidy
    if %errorlevel% neq 0 (
        echo ERROR: Still having issues
        echo Try running: go clean -modcache
        echo Then run this script again
        pause
        exit /b 1
    )
)

echo [4/4] Testing build...
go build -o multinet-test.exe ./multinet
if %errorlevel% neq 0 (
    echo ERROR: Build failed
    pause
    exit /b 1
) else (
    echo SUCCESS: Build completed!
    del multinet-test.exe
)

echo.
echo ========================================
echo    SUCCESS: All dependencies fixed!
echo ========================================
echo.
echo You can now run:
echo   go build -o multinet.exe ./multinet
echo   ./multinet.exe -cfg config.yaml
echo.
pause
