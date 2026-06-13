# Reachability

Confirm whether a host is reachable and where along the path packets are lost
or delayed.

## `ping`

ICMP echo — the first reachability check. Note that many cloud/k8s
environments filter ICMP, so a failed ping doesn't always mean "down".

```sh
ping -c 4 8.8.8.8            # send 4 packets and stop
ping -c 4 -i 0.2 host        # tighter interval
ping -s 1472 -M do host      # MTU/fragmentation probe (don't-fragment)
ping6 -c 4 host              # IPv6
```

The `-M do` with a large `-s` is a quick way to find MTU/black-hole issues
(common with overlays/VPNs): if large packets fail but small ones succeed,
suspect MTU.

## `traceroute`

Map the L3 hops to a destination and see where latency or loss appears.

```sh
traceroute 8.8.8.8           # default UDP probes
traceroute -T -p 443 host    # TCP SYN to 443 (gets through more firewalls)
traceroute -I host           # ICMP probes
traceroute -n host           # skip reverse DNS (faster)
```

Use `-T -p <port>` when UDP/ICMP is filtered but the service port is open.

## `mtr`

`traceroute` + `ping` combined into a live, continuously updating view —
best for spotting intermittent loss on a specific hop.

```sh
mtr host                     # interactive live view
mtr -r -c 100 host           # report mode: 100 cycles, then print summary
mtr -rn -c 100 host          # numeric, no DNS
mtr -T -P 443 host           # TCP mode to a specific port
```

Report mode (`-r`) is the one to paste into tickets.

## `fping`

Ping many hosts in parallel — sweep a subnet or a list of pods/nodes quickly.

```sh
fping -a -g 10.0.0.0/24      # show only alive hosts in a /24
fping -c 3 host1 host2 host3 # 3 probes each, per-host stats
fping < hosts.txt            # read targets from a file
```

`-a -g` is a fast "what's up on this subnet" sweep.
