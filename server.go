package multinet

import (
	"context"
	"fmt"
	"net"
	"net/netip"
	"strconv"

	"github.com/armon/go-socks5"
)

type Server struct {
	l      net.Listener
	cfg    *Config
	server *socks5.Server
	dialer Dialer
}

func NewServer(cfg *Config) (*Server, error) {
	return NewServerWithListener(cfg, nil)
}

func NewServerWithListener(cfg *Config, l net.Listener) (*Server, error) {
	s, err := GetSelector(cfg)
	if err != nil {
		return nil, err
	}

	dialer := newSelectorDialer(s)

	// Create SOCKS5 server with custom dialer
	conf := &socks5.Config{
		Dial: func(ctx context.Context, network, addr string) (net.Conn, error) {
			// Parse the address
			host, portStr, err := net.SplitHostPort(addr)
			if err != nil {
				return nil, err
			}

			port, err := strconv.Atoi(portStr)
			if err != nil {
				return nil, err
			}

			// Resolve the host to IP
			ips, err := net.LookupIP(host)
			if err != nil {
				return nil, err
			}

			var ip net.IP
			for _, resolvedIP := range ips {
				if resolvedIP.To4() != nil {
					ip = resolvedIP.To4()
					break
				}
			}
			if ip == nil {
				return nil, fmt.Errorf("no IPv4 address found for %s", host)
			}

			// Create AddrPort
			addrPort := netip.AddrPortFrom(netip.AddrFrom4([4]byte(ip)), uint16(port))

			// Use our custom dialer
			conn, _, err := dialer.Dial(addrPort)
			if err != nil {
				return nil, err
			}

			// Convert to net.Conn
			return conn.(net.Conn), nil
		},
	}

	server, err := socks5.New(conf)
	if err != nil {
		return nil, err
	}

	return &Server{
		cfg:    cfg,
		l:      l,
		server: server,
		dialer: dialer,
	}, nil
}

func (s *Server) Listen() error {
	if s.l != nil {
		return fmt.Errorf("Already listening")
	}

	l, err := net.Listen("tcp", s.cfg.Listen)
	if err != nil {
		return fmt.Errorf("Failed to listen: %v\n", err)
	}
	s.l = l
	fmt.Println("Listening on", s.cfg.Listen)

	return nil
}

func (s *Server) Serve() error {
	if s.l == nil {
		return fmt.Errorf("Not listening")
	}
	fmt.Println("Serving")
	return s.server.Serve(s.l)
}

func (s *Server) Close() error {
	if s.l == nil {
		return nil
	}
	return s.l.Close()
}
