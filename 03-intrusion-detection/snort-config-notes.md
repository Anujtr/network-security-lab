# Snort Configuration Notes

Setup notes for the Snort IDS on the Gateway VM. Snort monitors the client-facing
interface (`enp0s2`) so it sees attack traffic entering from the client network.

## Install

```bash
sudo apt-get update -y
sudo apt-get install -y snort
```

During install, set the local network to `10.0.0.0/8` (server-side HOME_NET) and the
monitoring interface to `enp0s2`.

## snort.conf changes

Set the network variables:

```
ipvar HOME_NET 10.0.0.0/8
ipvar EXTERNAL_NET !$HOME_NET
```

Comment out the default rule includes and enable only the custom rules:

```bash
sudo sed -i 's/^include \$RULE_PATH/#include \$RULE_PATH/' /etc/snort/snort.conf
```

Then add:

```
include $RULE_PATH/local.rules
```

Validate the config:

```bash
sudo snort -T -c /etc/snort/snort.conf
```

## Running Snort (detection mode)

```bash
sudo snort -A console -c /etc/snort/snort.conf -i enp0s2 -q
```

## Gateway sysctl settings (/etc/sysctl.conf)

These are required so spoofed/broadcast attack traffic passes through for testing.
Without disabling reverse-path filtering, the Land and Smurf attacks fail silently.

```
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.all.accept_redirects = 1
net.ipv4.conf.all.send_redirects = 1
net.ipv4.icmp_echo_ignore_broadcasts = 0
```

Apply with `sudo sysctl -p` (or `sudo sysctl -w <key>=<value>` for a single setting).

## Attack commands (from the Client VM)

```bash
# Land attack
sudo hping3 -S 10.0.0.10 -a 10.0.0.10 -p 80 -s 80 -c 5

# SYN flood
sudo hping3 -a 192.168.0.50 10.0.0.10 -S -p 80 --faster -c 50

# Smurf attack
sudo hping3 -1 --flood -a 10.0.0.10 192.168.0.255 -c 5

# UDP flood
sudo hping3 -2 --flood -a 192.168.0.50 10.0.0.10 -c 50

# Port scans
sudo hping3 -A 10.0.0.10 -p ++1 -c 30     # TCP ACK
sudo hping3 -F 10.0.0.10 -p ++1 -c 30     # TCP FIN
sudo hping3 -UPF 10.0.0.10 -p ++1 -c 30   # TCP Xmas
sudo nmap  -sN 10.0.0.10 -p 1-100         # TCP Null
sudo hping3 -2 10.0.0.10 -p ++1 -c 30     # UDP
```
