# MultiNet Setup Guide for LAN + WiFi

This guide will help you set up MultiNet to use both your LAN (Ethernet) and WiFi connections simultaneously for faster internet speeds.

## Prerequisites

1. **Main PC with both connections active:**
   - Ethernet/LAN connection (primary internet)
   - WiFi connection (secondary internet)
   - Both connections should be connected to different networks or the same network

2. **Both connections must be working independently**

## Step-by-Step Setup

### Step 1: Find Your Network Adapter IP Addresses

1. Open Command Prompt or PowerShell as Administrator
2. Run: `ipconfig /all`
3. Look for these two adapters:

   **Ethernet adapter Ethernet:** (or similar name)
   ```
   IPv4 Address. . . . . . . . . . . : 192.168.1.XXX
   ```
   
   **Wireless LAN adapter Wi-Fi:** (or similar name)
   ```
   IPv4 Address. . . . . . . . . . . : 192.168.1.YYY
   ```

4. **Write down both IP addresses** - you'll need them for configuration

### Step 2: Configure MultiNet

1. Copy the example configuration:
   ```bash
   copy example.cfg.yaml config.yaml
   ```

2. Edit `config.yaml` and replace the IP addresses:
   ```yaml
   paths:
     - type: direct
       addr: YOUR_ETHERNET_IP    # Replace with your Ethernet IP
     - type: direct  
       addr: YOUR_WIFI_IP        # Replace with your WiFi IP
   ```

### Step 3: Build and Run MultiNet

1. **Build the application:**
   ```bash
   go build -o multinet.exe ./multinet
   ```

2. **Run with your configuration:**
   ```bash
   ./multinet.exe -cfg config.yaml
   ```

3. **You should see output like:**
   ```
   MultiNet SOCKS5 proxy listening on 127.0.0.1:1080
   ```

### Step 4: Configure Applications

Now you can configure your applications to use the SOCKS5 proxy at `127.0.0.1:1080`

**For browsers:**
- Chrome: Use proxy extension or `--proxy-server=socks5://127.0.0.1:1080`
- Firefox: Settings → Network Settings → Manual proxy → SOCKS Host: 127.0.0.1, Port: 1080

**For download managers:**
- IDM: Options → Proxy/Socks → Use SOCKS proxy → 127.0.0.1:1080
- This works best as IDM creates multiple connections

**For system-wide (advanced):**
- Use tools like Proxifier or tun2socks for VPN-like functionality

## How It Works

1. **MultiNet creates a SOCKS5 proxy** that listens on port 1080
2. **Applications connect to this proxy** instead of directly to the internet
3. **MultiNet routes each connection** through either your LAN or WiFi using the selected algorithm
4. **Multiple parallel connections** get distributed across both internet connections
5. **Result: Combined bandwidth** from both connections

## Algorithms Available

- `weighted-lru`: Balances load based on recent usage (recommended)
- `roundrobin`: Alternates between connections
- `random`: Randomly selects connection
- `hash`: Uses connection hash for consistent routing

## Troubleshooting

**If it doesn't work:**
1. Make sure both network connections are active
2. Verify IP addresses are correct in config.yaml
3. Check Windows Firewall isn't blocking the application
4. Try running as Administrator
5. Test each connection individually first

**Best results with:**
- Download managers that create multiple connections (IDM, JDownloader)
- Torrent clients
- Game downloaders (Steam, Epic, etc.)
- Streaming applications

**Limited benefit for:**
- Single-connection downloads
- Basic web browsing (unless using multiple tabs)

## Example Real-World Performance

- LAN: 50 Mbps + WiFi: 30 Mbps = Combined ~80 Mbps
- Works best when both connections have good speeds
- Actual performance depends on application and server support
