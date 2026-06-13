# Diagnostics & misc

Local-host inspection: who's listening, which process owns a socket, what a
process is doing at the syscall level, and how to slice JSON output.

## `ss` (iproute2)

The modern `netstat -tulpn`. Lists sockets fast.

```sh
ss -tulpn                    # all listening TCP/UDP sockets + owning process
ss -tn state established      # established TCP connections
ss -tn dst 10.0.0.5           # connections to a specific host
ss -s                         # summary counts by socket state
ss -tn '( dport = :443 )'     # connections to port 443
ss -tnp 'sport = :80'         # who's connected to our port 80
```

`ss -tulpn` answers "is my service actually listening, and on which address?".
A service bound to `127.0.0.1` instead of `0.0.0.0` is a classic cause of
"connection refused" from other pods.

## `lsof`

List open files — including sockets — and the processes holding them.

```sh
lsof -i                       # all network connections
lsof -i :8080                 # who's using port 8080
lsof -i tcp@10.0.0.5          # connections to a host
lsof -p <pid>                 # everything a process has open
lsof -nP -i                   # numeric (no DNS/port name lookups)
```

Overlaps with `ss` for sockets but also shows file descriptors, which helps
when chasing fd leaks.

## `strace`

Trace the syscalls a process makes — see exactly which `connect()`/`socket()`
calls happen and what errno they return.

```sh
strace -f -e trace=network curl https://example.com   # network syscalls only
strace -f -p <pid>                                     # attach to a running pid
strace -f -e trace=connect,sendto,recvfrom -p <pid>
strace -f -tt -T ...                                   # timestamps + call durations
```

When an app "hangs", `strace -f -p <pid>` shows whether it's blocked in a
`connect()`/`read()` on the network or stuck elsewhere.

> Needs `SYS_PTRACE`. In Kubernetes add it via
> `securityContext.capabilities.add: ["SYS_PTRACE"]` or use `kubectl debug`.

## `jq`

Filter and reshape JSON — pair it with `curl` when testing JSON APIs.

```sh
curl -s http://host/api | jq .                  # pretty-print
curl -s http://host/api | jq '.items[].name'    # extract a field
curl -s http://host/api | jq -r '.token'        # raw string (no quotes)
curl -s http://host/api | jq '.[] | select(.status=="error")'
```

## `iptables`

Inspect the packet-filter / NAT rules — read kube-proxy's service rules and
spot DROP/REJECT rules that explain blocked traffic.

```sh
iptables -L -n -v                     # filter table, numeric, with counters
iptables -t nat -L -n                 # NAT table (kube-proxy service rules)
iptables -t nat -L KUBE-SERVICES -n   # the chain kube-proxy populates
iptables -S                           # rules as the commands that created them
```

Reading is safe; the high packet counters on a DROP rule often pinpoint exactly
what's being blocked.

> Inspection generally needs `NET_ADMIN`. On nodes using `nftables` or IPVS
> mode, also check `nft list ruleset` / `ipvsadm` on the host where available.
