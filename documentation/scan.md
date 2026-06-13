# Scan & throughput

Discover what's listening and measure how much bandwidth a path can carry.

> Only scan hosts/networks you are authorized to test.

## `nmap`

Port and service discovery.

```sh
nmap -sn 10.0.0.0/24                  # ping sweep: which hosts are up
nmap -p 80,443 10.0.0.5               # check specific ports
nmap -p- 10.0.0.5                     # all 65535 TCP ports
nmap -sV -p 1-1024 10.0.0.5           # detect service/version on open ports
nmap -sU -p 53,123 10.0.0.5           # UDP scan (slow)
nmap --open -p 1-1000 10.0.0.0/24     # only report open ports across a range
```

In Kubernetes, `nmap -sV` against a service ClusterIP is a quick way to confirm
the backend is actually serving the expected protocol on the expected port.

## `iperf3`

Active throughput measurement between two endpoints. Needs a server on one side
and a client on the other.

```sh
# on the server side (e.g. a pod/node at the far end)
iperf3 -s                             # listen on default port 5201

# on the client side
iperf3 -c <server-ip>                 # 10s TCP throughput test
iperf3 -c <server-ip> -t 30 -P 4      # 30s, 4 parallel streams
iperf3 -c <server-ip> -R              # reverse direction (server -> client)
iperf3 -c <server-ip> -u -b 100M      # UDP at 100 Mbit/s (measures loss/jitter)
```

Run two toolbox pods (one `iperf3 -s`, one `iperf3 -c <svc/pod-ip>`) to measure
real pod-to-pod or cross-node bandwidth and packet loss.
