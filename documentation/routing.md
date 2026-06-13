# Routing & interfaces

Inspect and manipulate interfaces, addresses, routes, the ARP cache and the
connection-tracking table.

> Changing network state (adding routes/addresses, flushing conntrack) requires
> `NET_ADMIN`. Inspection is generally fine without it.

## `ip` (iproute2)

The modern replacement for `ifconfig`/`route`/`arp`. The one tool to learn.

```sh
ip addr                      # show interfaces and their addresses
ip -br addr                  # brief, one line per interface
ip route                     # show the main routing table
ip route get 8.8.8.8         # which route/source IP is used to reach a target
ip neigh                     # ARP / neighbour cache
ip -s link                   # per-interface stats (drops, errors)
ip rule                      # policy routing rules
ip route show table all      # every routing table (useful with CNIs)
```

Common debugging flow: `ip route get <svc-ip>` to confirm the egress
interface, then `ip -s link` to check for drops on that interface.

## `ifconfig` / `route` / `netstat` (net-tools)

Legacy equivalents, handy when muscle memory or old docs assume them.

```sh
ifconfig -a                  # all interfaces
route -n                     # routing table, numeric
netstat -rn                  # same routing table
netstat -i                   # interface counters
```

Prefer `ip` and `ss` for anything new; these are here for familiarity.

## `arping`

Probe a host on the local L2 segment via ARP — proves L2 reachability even
when ICMP is filtered, and detects duplicate IPs.

```sh
arping -I eth0 192.168.1.1   # ARP-ping the gateway on eth0
arping -c 3 -D 192.168.1.50  # duplicate-address detection (-D)
```

## `ethtool`

Query/control NIC driver and hardware settings.

```sh
ethtool eth0                 # link speed, duplex, link detection
ethtool -S eth0              # driver/hardware statistics (rx/tx drops)
ethtool -i eth0              # driver name and version
ethtool -k eth0              # offload feature flags (gro, tso, ...)
```

`-S` is the go-to for spotting hardware-level packet drops.

## `bridge`

Inspect Linux bridges and their FDB — useful on nodes using bridge-based CNIs.

```sh
bridge link                  # ports attached to bridges
bridge fdb show              # forwarding database (MAC → port)
bridge vlan show             # VLAN filtering config
```

## `conntrack`

Read and manipulate the netfilter connection-tracking table — central to
debugging NAT, kube-proxy and service load-balancing issues.

```sh
conntrack -L                 # list all tracked connections
conntrack -L -p tcp --dport 80
conntrack -E                 # live event stream of new/destroyed conns
conntrack -S                 # per-CPU stats (look for insert_failed, drop)
conntrack -D -p tcp --dport 80   # delete matching entries (NET_ADMIN)
```

Rising `insert_failed`/`drop` in `conntrack -S` often explains intermittent
connection resets behind a busy NAT/service.
