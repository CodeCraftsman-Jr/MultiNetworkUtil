package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/widget"
	"github.com/NadeenUdantha/multinet"
)

type NetworkAdapter struct {
	Name    string
	IP      string
	Status  string
	Type    string // "ethernet", "wifi", "other"
}

type MultiNetGUI struct {
	app        fyne.App
	window     fyne.Window
	server     *multinet.Server
	serverMux  sync.Mutex
	isRunning  bool
	
	// UI Components
	adapterList    *widget.List
	algorithmSelect *widget.Select
	listenEntry    *widget.Entry
	hashPortCheck  *widget.Check
	startStopBtn   *widget.Button
	statusLabel    *widget.Label
	logText        *widget.Entry
	
	// Data
	adapters       []NetworkAdapter
	selectedPaths  map[string]bool
}

func main() {
	gui := NewMultiNetGUI()
	gui.Run()
}

func NewMultiNetGUI() *MultiNetGUI {
	a := app.New()
	a.SetMetadata(&fyne.AppMetadata{
		ID:   "com.multinet.gui",
		Name: "MultiNet GUI",
	})
	
	w := a.NewWindow("MultiNet - Multiple Connection Manager")
	w.Resize(fyne.NewSize(800, 600))
	
	gui := &MultiNetGUI{
		app:           a,
		window:        w,
		selectedPaths: make(map[string]bool),
	}
	
	gui.setupUI()
	gui.refreshAdapters()
	
	return gui
}

func (g *MultiNetGUI) setupUI() {
	// Algorithm selection
	g.algorithmSelect = widget.NewSelect(
		[]string{"weighted-lru", "roundrobin", "random", "hash"},
		nil,
	)
	g.algorithmSelect.SetSelected("weighted-lru")
	
	// Listen address
	g.listenEntry = widget.NewEntry()
	g.listenEntry.SetText("127.0.0.1:1080")
	
	// Hash port option
	g.hashPortCheck = widget.NewCheck("Hash port in address key", nil)
	g.hashPortCheck.SetChecked(true)
	
	// Network adapters list
	g.adapterList = widget.NewList(
		func() int { return len(g.adapters) },
		func() fyne.CanvasObject {
			check := widget.NewCheck("", nil)
			label := widget.NewLabel("Adapter info")
			return container.NewHBox(check, label)
		},
		func(id widget.ListItemID, obj fyne.CanvasObject) {
			if id >= len(g.adapters) {
				return
			}
			
			adapter := g.adapters[id]
			container := obj.(*container.Container)
			check := container.Objects[0].(*widget.Check)
			label := container.Objects[1].(*widget.Label)
			
			check.SetChecked(g.selectedPaths[adapter.IP])
			check.OnChanged = func(checked bool) {
				g.selectedPaths[adapter.IP] = checked
			}
			
			label.SetText(fmt.Sprintf("%s (%s) - %s - %s", 
				adapter.Name, adapter.Type, adapter.IP, adapter.Status))
		},
	)
	
	// Control buttons
	refreshBtn := widget.NewButton("Refresh Adapters", g.refreshAdapters)
	g.startStopBtn = widget.NewButton("Start MultiNet", g.toggleServer)
	
	// Status and logging
	g.statusLabel = widget.NewLabel("Status: Stopped")
	g.logText = widget.NewMultiLineEntry()
	g.logText.SetText("MultiNet GUI started...\n")
	g.logText.Disable()
	
	// Layout
	configForm := container.NewVBox(
		widget.NewLabel("Configuration"),
		widget.NewSeparator(),
		
		container.NewHBox(
			widget.NewLabel("Algorithm:"),
			g.algorithmSelect,
		),
		
		container.NewHBox(
			widget.NewLabel("Listen Address:"),
			g.listenEntry,
		),
		
		g.hashPortCheck,
		
		widget.NewSeparator(),
		widget.NewLabel("Network Adapters (Select which to use):"),
		container.NewHBox(refreshBtn),
		container.NewScroll(g.adapterList),
	)
	
	controlPanel := container.NewVBox(
		widget.NewLabel("Control"),
		widget.NewSeparator(),
		g.startStopBtn,
		g.statusLabel,
		widget.NewSeparator(),
		widget.NewLabel("Log:"),
		container.NewScroll(g.logText),
	)
	
	content := container.NewHSplit(configForm, controlPanel)
	content.SetOffset(0.6) // 60% for config, 40% for control
	
	g.window.SetContent(content)
}

func (g *MultiNetGUI) Run() {
	g.window.ShowAndRun()
}

func (g *MultiNetGUI) refreshAdapters() {
	g.adapters = []NetworkAdapter{}
	
	interfaces, err := net.Interfaces()
	if err != nil {
		g.logMessage(fmt.Sprintf("Error getting network interfaces: %v", err))
		return
	}
	
	for _, iface := range interfaces {
		if iface.Flags&net.FlagUp == 0 || iface.Flags&net.FlagLoopback != 0 {
			continue // Skip down or loopback interfaces
		}
		
		addrs, err := iface.Addrs()
		if err != nil {
			continue
		}
		
		for _, addr := range addrs {
			if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
				if ipnet.IP.To4() != nil { // IPv4 only
					adapterType := "other"
					if strings.Contains(strings.ToLower(iface.Name), "ethernet") ||
					   strings.Contains(strings.ToLower(iface.Name), "eth") {
						adapterType = "ethernet"
					} else if strings.Contains(strings.ToLower(iface.Name), "wi-fi") ||
							  strings.Contains(strings.ToLower(iface.Name), "wifi") ||
							  strings.Contains(strings.ToLower(iface.Name), "wireless") {
						adapterType = "wifi"
					}
					
					adapter := NetworkAdapter{
						Name:   iface.Name,
						IP:     ipnet.IP.String(),
						Status: "Up",
						Type:   adapterType,
					}
					g.adapters = append(g.adapters, adapter)
				}
			}
		}
	}
	
	g.adapterList.Refresh()
	g.logMessage(fmt.Sprintf("Found %d network adapters", len(g.adapters)))
}
