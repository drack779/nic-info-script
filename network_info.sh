#!/bin/bash
# network_info.sh - Skriptas išveda Linux kompiuterio tinklo parametrus
set -euo pipefail

echo "=== Tinklo parametrai - $(date) ==="
echo

echo "-> Sistema"
uname -srmo 2>/dev/null || true
echo

echo "-> Tinklo adapteriai ir būklė"
ip -brief link show 2>/dev/null || ip link show
echo

echo "-> IP konfigūracija"
ip -brief addr show 2>/dev/null || ip addr show
echo

echo "-> Maršrutų lentelė"
ip route show 2>/dev/null || route -n
echo

echo "-> DNS (/etc/resolv.conf)"
if [ -f /etc/resolv.conf ]; then
    grep -v '^#' /etc/resolv.conf || true
else
    echo "resolv.conf nerasta"
fi

echo
echo "-> ARP (ip neigh)"
ip neigh show 2>/dev/null || arp -n
echo

echo "-> Atidaryti tinklo ryšiai (pirmi 100)"
if command -v ss >/dev/null 2>&1; then
    ss -tunap | head -n 100
elif command -v netstat >/dev/null 2>&1; then
    netstat -tunap | head -n 100
else
    echo "ss/netstat nerasta"
fi

echo
echo "-> MAC adresai"
ip -o link show 2>/dev/null | awk -F': ' '{print $2 " -> " $3}' || true

echo
echo "-> Viešasis IP"
if command -v curl >/dev/null 2>&1; then
    curl -s https://api.ipify.org || echo "nepavyko gauti viešo IP"
elif command -v wget >/dev/null 2>&1; then
    wget -qO- https://api.ipify.org || echo "nepavyko gauti viešo IP"
else
    echo "curl/wget nerasta"
fi

echo
echo "=== Pabaiga ==="
