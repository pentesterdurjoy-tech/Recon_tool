#!/bin/bash

# Simple Linux Recon Script


clear
echo "=============================="
echo "      SIMPLE RECON TOOL"
echo "=============================="

read -rp "Enter target domain/IP: " target

if [[ -z "$target" || "$target" == -* || "$target" == *[[:space:]]* ]]; then
    echo "Invalid target!"
    exit 1
fi

# Remove URL scheme and path
target="${target#http://}"
target="${target#https://}"
target="${target%%/*}"

echo
echo "[1] Target Information"
echo "Target: $target"
date

echo
echo "[2] DNS Lookup"
getent ahosts "$target" | awk '!seen[$1]++ {print $1}' || true

echo
echo "[3] Ping Test"
ping -c 2 -W 2 "$target" 2>/dev/null ||
    echo "Ping failed or blocked."

echo
echo "[4] HTTP Headers"
curl -sSI --connect-timeout 5 "http://$target" |
    head -n 8

echo
echo "[5] HTTPS Headers"
curl -sSI --connect-timeout 5 "https://$target" |
    head -n 8

echo
echo "[6] Common Port Check"

for port in 22 80 443 8080; do
    if timeout 2 bash -c \
        "echo >/dev/tcp/$target/$port" 2>/dev/null; then
        echo "Port $port: OPEN"
    else
        echo "Port $port: CLOSED or FILTERED"
    fi
done

echo
echo "Recon completed."

