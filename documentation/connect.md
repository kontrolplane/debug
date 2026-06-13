# Connect, transfer & TLS

Make connections by hand to prove (or disprove) that a service is reachable
and behaving, independent of the application.

## `curl`

HTTP(S) and many other protocols. The default for testing APIs and endpoints.

```sh
curl -v https://example.com               # verbose: TLS handshake, headers
curl -sS -o /dev/null -w '%{http_code} %{time_total}s\n' https://example.com
curl -k https://10.0.0.5                  # skip TLS verification
curl --resolve host:443:10.0.0.5 https://host/   # force a backend IP, keep SNI
curl -H 'Host: my-svc' http://<ingress-ip>/      # test ingress routing
curl --max-time 5 ...                     # bound the request time
curl -x http://proxy:8080 https://example.com    # via a proxy
```

`--resolve` is invaluable for testing a specific backend/pod while preserving
the TLS SNI and `Host` header.

## `wget`

Simpler downloader; useful when a script expects it or for recursive fetches.

```sh
wget -qO- http://example.com              # print body to stdout
wget --spider -S http://example.com       # headers only, don't download
wget -O /tmp/file https://host/file
```

## `nc` (netcat-openbsd)

Swiss-army knife for raw TCP/UDP — test ports, send bytes, listen.

```sh
nc -vz host 443                           # is the TCP port open? (scan)
nc -vz -u host 53                         # UDP port check
nc -l 8080                                # listen on 8080 (simple server)
echo -e 'GET / HTTP/1.0\r\n' | nc host 80 # hand-craft an HTTP request
nc -vz host 20-25                         # scan a small port range
```

`nc -vz` is the quickest "is this port reachable from here" test.

## `socat`

Like `nc` but far more capable — bidirectional relays, TLS, UNIX sockets,
port-forwards.

```sh
# TCP port-forward: local 8080 -> backend 80
socat TCP-LISTEN:8080,fork,reuseaddr TCP:10.0.0.5:80

# expose a UNIX socket over TCP (e.g. inspect a container socket)
socat TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock

# TLS client, print the negotiated connection
socat -v OPENSSL:host:443,verify=0 STDIO
```

## `telnet`

Old-school interactive TCP probe; still handy for poking line-based protocols.

```sh
telnet host 25                            # talk to an SMTP server by hand
telnet host 6379                          # poke Redis, etc.
```

## `openssl`

Inspect and debug TLS — certificates, chains, protocol versions, ciphers.

```sh
# show the served cert chain and handshake details
openssl s_client -connect host:443 -servername host

# just the certificate, parsed
openssl s_client -connect host:443 -servername host </dev/null 2>/dev/null \
  | openssl x509 -noout -text

# check expiry dates
openssl s_client -connect host:443 -servername host </dev/null 2>/dev/null \
  | openssl x509 -noout -dates

# force a protocol version to test support
openssl s_client -connect host:443 -tls1_2
```

`-servername` sends SNI — required to get the right cert from most modern
endpoints and ingress controllers.
