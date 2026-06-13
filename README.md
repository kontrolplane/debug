# network-toolbox

A throwaway container packed with common network troubleshooting tools, meant
to be injected into a Kubernetes cluster or a plain Linux host to diagnose
connectivity, DNS, routing and packet issues.

## What's inside

| Category | Tools |
| --- | --- |
| Routing / interfaces | `ip`, `ifconfig`, `arping`, `ethtool`, `bridge`, `conntrack` |
| Reachability | `ping`, `traceroute`, `mtr`, `fping` |
| DNS | `dig`, `nslookup`, `host` |
| Packet capture | `tcpdump`, `tshark`, `ngrep` |
| Connect / transfer | `curl`, `wget`, `nc`, `socat`, `telnet`, `openssl` |
| Scan / throughput | `nmap`, `iperf3` |
| Diagnostics | `lsof`, `strace`, `ss`, `netstat`, `jq`, `iptables` |

Per-tool usage notes and examples live in [`documentation/`](documentation/README.md).

## Usage

### Kubernetes

Run an ephemeral debug pod:

```sh
kubectl run debug --rm -it --restart=Never \
  --image=ghcr.io/kontrolplane/network:latest -- bash
```

Attach to an existing pod's network namespace with `kubectl debug`:

```sh
kubectl debug -it <pod> --image=ghcr.io/kontrolplane/network:latest \
  --target=<container> -- bash
```

Inspect a node:

```sh
kubectl debug node/<node> -it --image=ghcr.io/kontrolplane/network:latest
```

### Docker

```sh
docker run --rm -it --network host \
  ghcr.io/kontrolplane/network:latest bash
```

## Local build

```sh
docker build -t network-toolbox .
docker run --rm -it network-toolbox bash
```
