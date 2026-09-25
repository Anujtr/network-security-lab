#!/bin/bash
# Network Security Lab - Stage 2: Firewall & NAT
# iptables whitelist firewall with DNAT port forwarding and SNAT masquerading.
# Run on the Gateway VM.
#
# Interfaces:
#   enp0s2 = client-facing (192.168.0.100/24)
#   enp0s3 = server-facing (10.0.0.100/8)
#   enp0s1 = NAT / internet-facing (DHCP)

# --- Reset: flush existing rules and chains (filter + nat tables) ---
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X

# --- Whitelist policy: default DROP on all chains ---
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP

# --- Enable IP forwarding (required for routing between networks) ---
sudo sysctl -w net.ipv4.ip_forward=1

# --- Loopback + connection-state tracking (return traffic) ---
sudo iptables -A INPUT  -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT   -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -o enp0s1 -j ACCEPT   # allow gateway's own internet access

# --- NAT: POSTROUTING masquerade (server -> internet, hides private IP) ---
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -o enp0s1 -j MASQUERADE

# --- NAT: PREROUTING port forwarding (DNAT) from gateway to server ---
sudo iptables -t nat -A PREROUTING -i enp0s2 -p tcp --dport 80 -j DNAT --to-destination 10.0.0.10:80
sudo iptables -t nat -A PREROUTING -i enp0s2 -p tcp --dport 22 -j DNAT --to-destination 10.0.0.10:22
sudo iptables -t nat -A PREROUTING -i enp0s2 -p tcp --dport 21 -j DNAT --to-destination 10.0.0.10:21
sudo iptables -t nat -A PREROUTING -i enp0s2 -p tcp --dport 30000:30099 -j DNAT --to-destination 10.0.0.10

# --- FORWARD: allow the forwarded services client -> server ---
sudo iptables -A FORWARD -i enp0s2 -o enp0s3 -p tcp --dport 80 -j ACCEPT
sudo iptables -A FORWARD -i enp0s2 -o enp0s3 -p tcp --dport 22 -j ACCEPT
sudo iptables -A FORWARD -i enp0s2 -o enp0s3 -p tcp --dport 21 -j ACCEPT
sudo iptables -A FORWARD -i enp0s2 -o enp0s3 -p tcp --dport 30000:30099 -j ACCEPT

# --- FORWARD: server -> client (ICMP) and server -> internet ---
sudo iptables -A FORWARD -i enp0s3 -o enp0s2 -p icmp -j ACCEPT
sudo iptables -A FORWARD -i enp0s3 -o enp0s1 -j ACCEPT

# --- INPUT/OUTPUT: allow ping to/from the gateway's internal interfaces ---
sudo iptables -A INPUT  -i enp0s2 -p icmp -s 192.168.0.0/24 -j ACCEPT
sudo iptables -A INPUT  -i enp0s3 -p icmp -s 10.0.0.0/8      -j ACCEPT
sudo iptables -A OUTPUT -o enp0s2 -p icmp -d 192.168.0.0/24  -j ACCEPT
sudo iptables -A OUTPUT -o enp0s3 -p icmp -d 10.0.0.0/8      -j ACCEPT

# --- Persist across reboots (optional) ---
# sudo apt install iptables-persistent
# sudo netfilter-persistent save
