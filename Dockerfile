# Network debugging toolbox
#
# A throwaway container packed with common network troubleshooting tools,
# meant to be injected into a Kubernetes cluster (kubectl debug / run) or a
# plain Linux host to diagnose connectivity, DNS, routing and packet issues.

FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="network-toolbox" \
      org.opencontainers.image.description="Container packed with network debugging tools for Kubernetes and Linux." \
      org.opencontainers.image.source="https://github.com/kontrolplane/network"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    # core networking / routing
    iproute2 \
    iputils-ping \
    iputils-arping \
    net-tools \
    traceroute \
    mtr-tiny \
    fping \
    ethtool \
    bridge-utils \
    conntrack \
    # dns
    dnsutils \
    # capture / inspect
    tcpdump \
    tshark \
    ngrep \
    # connect / transfer
    curl \
    wget \
    netcat-openbsd \
    socat \
    telnet \
    openssl \
    # scan / throughput
    nmap \
    iperf3 \
    # diagnostics / misc
    lsof \
    strace \
    jq \
    procps \
    iptables \
    vim-tiny \
    less \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Keep the container alive when run without a command so it can be exec'd into.
CMD ["sleep", "infinity"]
