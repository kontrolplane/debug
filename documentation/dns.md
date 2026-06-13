# DNS

Resolve names, test specific resolvers and debug Kubernetes service discovery
(CoreDNS).

All three tools below come from `dnsutils`.

## `dig`

The detailed, scriptable resolver query tool.

```sh
dig example.com                       # A record, full answer section
dig +short example.com                # just the answer, one per line
dig example.com AAAA                  # specific record type
dig @10.96.0.10 example.com           # query a specific resolver
dig +trace example.com                # follow delegation from the root
dig -x 8.8.8.8                        # reverse lookup (PTR)
dig +noall +answer example.com        # answer section only
```

### Kubernetes / CoreDNS

```sh
# resolve a service (cluster DNS is usually 10.96.0.10)
dig +short my-svc.my-ns.svc.cluster.local

# SRV record for a named port / headless service
dig SRV _http._tcp.my-svc.my-ns.svc.cluster.local

# check the pod's actual resolver and search domains
cat /etc/resolv.conf
```

If `dig @<coredns-ip>` works but bare `dig my-svc` doesn't, the issue is the
pod's `search`/`ndots` config in `/etc/resolv.conf`, not CoreDNS.

## `nslookup`

Simpler, interactive-friendly resolver. Widely expected, less verbose output.

```sh
nslookup example.com
nslookup example.com 10.96.0.10       # query a specific server
nslookup -type=mx example.com
nslookup -type=txt example.com
```

## `host`

The most concise of the three — good for quick one-liners.

```sh
host example.com
host -t ns example.com                # nameservers
host -a example.com                   # all records (verbose)
host 8.8.8.8                          # reverse lookup
```
