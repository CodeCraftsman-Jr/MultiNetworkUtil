# MultiNet Installation Script (PowerShell)
# Run this script in PowerShell as Administrator for best results

# Set error action preference
$ErrorActionPreference = "Stop"

# Check execution policy
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "WARNING: PowerShell execution policy is Restricted" -ForegroundColor Yellow
    Write-Host "You may need to run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    Write-Host "Or run this script with: powershell -ExecutionPolicy Bypass -File install.ps1" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    MultiNet Installation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "ERROR: PowerShell 3.0 or higher is required" -ForegroundColor Red
    Write-Host "Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if we're in the right directory
if (-not (Test-Path "readme.md") -or -not (Test-Path "go.mod")) {
    Write-Host "ERROR: This doesn't appear to be the MultiNet project directory" -ForegroundColor Red
    Write-Host "Please navigate to the MultiNet folder and run this script again" -ForegroundColor Red
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "WARNING: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Some features may not work properly" -ForegroundColor Yellow
    Write-Host ""
}

# Function to check if command exists
function Test-Command($command) {
    try {
        Get-Command $command -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Check Go installation
Write-Host "[1/6] Checking Go installation..." -ForegroundColor Green
if (Test-Command "go") {
    $goVersion = go version
    Write-Host "Found: $goVersion" -ForegroundColor Green
} else {
    Write-Host "ERROR: Go is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Go first:" -ForegroundColor Yellow
    Write-Host "1. Visit: https://golang.org/dl/" -ForegroundColor Yellow
    Write-Host "2. Download and install Go for Windows" -ForegroundColor Yellow
    Write-Host "3. Restart PowerShell and run this script again" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Check Git installation
Write-Host "[2/6] Checking Git installation..." -ForegroundColor Green
if (Test-Command "git") {
    $gitVersion = git --version
    Write-Host "Found: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "WARNING: Git not found" -ForegroundColor Yellow
    Write-Host "Git is recommended for downloading dependencies" -ForegroundColor Yellow
    Write-Host "You can download it from: https://git-scm.com/download/win" -ForegroundColor Yellow
}
Write-Host ""

# Check for C compiler
Write-Host "[3/6] Checking C compiler..." -ForegroundColor Green
if (Test-Command "gcc") {
    Write-Host "C compiler found" -ForegroundColor Green
} else {
    Write-Host "WARNING: C compiler (gcc) not found" -ForegroundColor Yellow
    Write-Host "Fyne GUI requires a C compiler. Please install one of:" -ForegroundColor Yellow
    Write-Host "1. TDM-GCC: https://jmeubank.github.io/tdm-gcc/" -ForegroundColor Yellow
    Write-Host "2. MinGW-w64: https://www.mingw-w64.org/downloads/" -ForegroundColor Yellow
    Write-Host "3. Visual Studio Build Tools" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}
Write-Host ""

# Download dependencies
Write-Host "[4/6] Installing Go dependencies..." -ForegroundColor Green

# Clean module cache first to avoid stale dependencies
Write-Host "Cleaning module cache..."
go clean -modcache

Write-Host "Downloading dependencies directly from GitHub repositories..."
try {
    # Set Go proxy to direct for better compatibility
    $env:GOPROXY = "direct"
    $env:GOSUMDB = "off"

    # Download dependencies - let Go handle versions automatically
    Write-Host "Getting go-socks5 from GitHub..."
    go get github.com/armon/go-socks5

    Write-Host "Getting golang-lru from GitHub..."
    go get github.com/hashicorp/golang-lru

    Write-Host "Getting yaml.v3 dependency..."
    go get gopkg.in/yaml.v3

    Write-Host "Running: go mod tidy"
    $output = go mod tidy 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error output: $output" -ForegroundColor Red

        # Try alternative approach
        Write-Host "Trying alternative dependency resolution..." -ForegroundColor Yellow
        $env:GOPROXY = "https://proxy.golang.org,direct"
        $output = go mod tidy 2>&1

        if ($LASTEXITCODE -ne 0) {
            throw "go mod tidy failed with exit code $LASTEXITCODE"
        }
    }
    Write-Host "[OK] Dependencies downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download dependencies" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "This might be due to:" -ForegroundColor Yellow
    Write-Host "1. Network/proxy issues with gopkg.in or golang.org" -ForegroundColor Yellow
    Write-Host "2. Corporate firewall blocking Go module downloads" -ForegroundColor Yellow
    Write-Host "3. DNS resolution issues" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Try these solutions:" -ForegroundColor Cyan
    Write-Host "1. Use a VPN or different network" -ForegroundColor Cyan
    Write-Host "2. Configure Go proxy: go env -w GOPROXY=https://goproxy.io,direct" -ForegroundColor Cyan
    Write-Host "3. Disable Go checksum: go env -w GOSUMDB=off" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Installing GUI dependencies..."
try {
    $null = go get fyne.io/fyne/v2/app 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Failed to get fyne/app" }

    $null = go get fyne.io/fyne/v2/widget 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Failed to get fyne/widget" }

    $null = go get fyne.io/fyne/v2/container 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Failed to get fyne/container" }

    Write-Host "[OK] GUI dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "WARNING: Failed to install GUI dependencies" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "GUI version may not build properly" -ForegroundColor Yellow
}
Write-Host ""

# Build applications
Write-Host "[5/6] Building applications..." -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "go.mod")) {
    Write-Host "ERROR: go.mod not found. Make sure you're in the MultiNet project directory" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-Path "multinet\main.go")) {
    Write-Host "ERROR: multinet\main.go not found. Invalid project structure" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Building command-line version..."
try {
    $buildOutput = go build -o multinet.exe ./multinet 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build output: $buildOutput" -ForegroundColor Red
        throw "Build failed with exit code $LASTEXITCODE"
    }

    if (Test-Path "multinet.exe") {
        Write-Host "[OK] multinet.exe created successfully" -ForegroundColor Green
    } else {
        throw "multinet.exe was not created"
    }
} catch {
    Write-Host "ERROR: Failed to build command-line version" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Building GUI version..."
if (Test-Path "gui\main.go") {
    try {
        $guiBuildOutput = go build -o multinet-gui.exe ./gui 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "GUI build output: $guiBuildOutput" -ForegroundColor Yellow
            throw "GUI build failed with exit code $LASTEXITCODE"
        }

        if (Test-Path "multinet-gui.exe") {
            Write-Host "[OK] multinet-gui.exe created successfully" -ForegroundColor Green
        } else {
            throw "multinet-gui.exe was not created"
        }
    } catch {
        Write-Host "WARNING: Failed to build GUI version" -ForegroundColor Yellow
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "This might be due to missing C compiler or GUI source issues" -ForegroundColor Yellow
    }
} else {
    Write-Host "GUI source not found, skipping GUI build" -ForegroundColor Yellow
}
Write-Host ""

# Create sample configuration
Write-Host "[6/6] Creating sample configuration..." -ForegroundColor Green
if (-not (Test-Path "config.yaml")) {
    if (Test-Path "example.cfg.yaml") {
        Copy-Item "example.cfg.yaml" "config.yaml"
        Write-Host "[OK] config.yaml created from example" -ForegroundColor Green
    } else {
        Write-Host "WARNING: example.cfg.yaml not found, creating basic config" -ForegroundColor Yellow
        $basicConfig = @'
algorithm: weighted-lru
listen: 127.0.0.1:1080
hashport: true
paths:
  - type: direct
    addr: 192.168.1.100  # REPLACE with your Ethernet IP
  - type: direct
    addr: 192.168.1.101  # REPLACE with your WiFi IP
'@
        $basicConfig | Out-File -FilePath "config.yaml" -Encoding UTF8
        Write-Host "Basic config.yaml created" -ForegroundColor Green
    }
} else {
    Write-Host "config.yaml already exists" -ForegroundColor Yellow
}
Write-Host ""

# Show network adapters
Write-Host "Your current network adapters:" -ForegroundColor Cyan
try {
    $adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.Virtual -eq $false}
    if ($adapters) {
        $adapters | Format-Table Name, InterfaceDescription, LinkSpeed -AutoSize

        Write-Host "Network adapter IP addresses:" -ForegroundColor Cyan
        foreach ($adapter in $adapters) {
            $ip = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            if ($ip) {
                Write-Host "  $($adapter.Name): $($ip.IPAddress)" -ForegroundColor White
            }
        }
    } else {
        Write-Host "No active network adapters found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Could not retrieve network adapter information" -ForegroundColor Yellow
    Write-Host "Run 'ipconfig /all' manually to see your network configuration" -ForegroundColor Yellow
}

# Final instructions
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         Installation Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Available executables:" -ForegroundColor Green
if (Test-Path "multinet.exe") {
    Write-Host "  [OK] multinet.exe (command-line version)" -ForegroundColor Green
}
if (Test-Path "multinet-gui.exe") {
    Write-Host "  [OK] multinet-gui.exe (GUI version)" -ForegroundColor Green
}
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit config.yaml with your network adapter IPs" -ForegroundColor Yellow
Write-Host "2. Run: .\multinet.exe -cfg config.yaml" -ForegroundColor Yellow
if (Test-Path "multinet-gui.exe") {
    Write-Host "   Or run: .\multinet-gui.exe (for GUI)" -ForegroundColor Yellow
}
Write-Host "3. Configure your applications to use SOCKS5 proxy: 127.0.0.1:1080" -ForegroundColor Yellow
Write-Host ""

Write-Host "For help finding your network IPs, run: ipconfig /all" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to exit"
