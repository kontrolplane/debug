# Packet capture & inspection

Capture and inspect traffic on the wire. Indispensable when "the request
leaves but nothing comes back".

> All capture tools need `NET_RAW` (and usually run as root). In Kubernetes,
> attach with `kubectl debug --target=<container>` so you share the target's
> network namespace, or run a pod with `securityContext.capabilities.add:
> ["NET_RAW"]`.

## `tcpdump`

The workhorse packet capturer with BPF filtering.

```sh
tcpdump -i any -n                         # all interfaces, no DNS
tcpdump -i eth0 -nn port 80               # TCP/UDP port 80, numeric host+port
tcpdump -i any host 10.0.0.5 and port 443
tcpdump -i any 'tcp[tcpflags] & tcp-syn != 0'   # SYN packets only
tcpdump -i any -c 100 -w /tmp/cap.pcap     # write 100 pkts to a file
tcpdump -nn -A port 80                     # print payload as ASCII (HTTP)
tcpdump -i any -vv icmp                    # verbose ICMP (e.g. unreachables)
```

Workflow tips:
- `-w file.pcap` to capture, then copy out (`kubectl cp`) and open in Wireshark.
- Watch for `R` (RST) flags or ICMP `unreachable` to explain failed connects.
- `-s 0` captures full packets (default on modern versions).

## `tshark`

Wireshark's CLI — capture with the same BPF filters as tcpdump, but also apply
Wireshark **display filters** and dissect protocols on the command line.

```sh
tshark -i any -f "port 53"                # capture filter (BPF)
tshark -i any -Y "http.request"           # display filter (dissected)
tshark -r /tmp/cap.pcap -Y "tcp.flags.reset==1"   # read a pcap, filter resets
tshark -i any -Y dns -T fields -e dns.qry.name    # extract just DNS queries
tshark -q -z conv,tcp -r /tmp/cap.pcap    # TCP conversation statistics
```

Use `tshark` over `tcpdump` when you need protocol-aware filtering (e.g.
`http.response.code==500`) or field extraction.

## `ngrep`

`grep` for the network — match a regex against packet payloads. Great for a
quick "did this string cross the wire" without a full pcap.

```sh
ngrep -d any -q 'GET' port 80             # HTTP GETs
ngrep -d any -q 'Host:' tcp port 80       # match a header
ngrep -d any -W byline 'password' port 8080   # readable line-by-line output
```
