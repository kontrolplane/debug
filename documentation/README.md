# Documentation

Usage notes and practical examples for every tool bundled in the
network-toolbox image. Grouped by purpose.

| Guide | Tools covered |
| --- | --- |
| [routing.md](routing.md) | `ip`, `ifconfig` / `route` / `netstat`, `arping`, `ethtool`, `bridge`, `conntrack` |
| [reachability.md](reachability.md) | `ping`, `traceroute`, `mtr`, `fping` |
| [dns.md](dns.md) | `dig`, `nslookup`, `host` |
| [capture.md](capture.md) | `tcpdump`, `tshark`, `ngrep` |
| [connect.md](connect.md) | `curl`, `wget`, `nc`, `socat`, `telnet`, `openssl` |
| [scan.md](scan.md) | `nmap`, `iperf3` |
| [diagnostics.md](diagnostics.md) | `ss`, `lsof`, `strace`, `jq`, `iptables` |

> Many of these tools need elevated capabilities (`NET_RAW`, `NET_ADMIN`) to
> capture packets or change network state. When running in Kubernetes, the
> pod/ephemeral container needs those capabilities or the host network
> namespace. See notes in the individual guides.
