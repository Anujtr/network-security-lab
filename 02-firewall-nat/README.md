# Stage 2 — Firewall & NAT

Harden the gateway from Stage 1 with an `iptables` firewall so that only explicitly authorized traffic is allowed — the **prevention** layer of the lab.

## Goal

Turn the permissive network from Stage 1 into a whitelist-controlled environment: deny everything by default, then allow only the specific services the client is meant to reach on the server, exposed through the gateway's IP via NAT.

## What Was Built

- **Whitelist firewall.** Set default policies to `DROP` on the INPUT, OUTPUT, and FORWARD chains, then added explicit `ACCEPT` rules only for allowed paths. Nothing passes unless a rule permits it.
- **Connection-state tracking.** Allowed `ESTABLISHED,RELATED` traffic so replies to permitted connections return correctly through the default-DROP firewall.
- **Port forwarding (DNAT).** PREROUTING rules forward HTTP (80), SSH (22), and FTP (21, plus passive range 30000–30099) from the gateway's client-side IP to the server's internal IP.
- **Masquerading (SNAT).** A POSTROUTING masquerade rule lets the server reach the internet while hiding its private IP behind the gateway.

The full command set is in [`iptables-rules.sh`](iptables-rules.sh).

## Verification

- `nmap` TCP scan from the client confirmed only ports 21/22/80 were reachable through the gateway.
- `nmap` UDP scan returned `open|filtered` — correctly interpreted as the default-DROP policy silently dropping probes, not a misconfiguration.
- `ping` tests confirmed the client could reach the gateway but **not** the server directly or the internet, exactly as intended.
- `curl`, `ftp`, and `ssh` through the gateway IP confirmed the forwarded services worked.

## What This Demonstrates

- Firewall administration with iptables: default-DROP whitelist design, chain/rule ordering, and least-privilege access control.
- The distinction between **DNAT** (PREROUTING, for inbound port forwarding) and **SNAT/masquerade** (POSTROUTING, for outbound address hiding).
- Reading tool output honestly — interpreting a `filtered` scan result correctly rather than assuming a failure.

> Note: the assignment framed this as a "stateless" packet filter, but connection-state matching (`-m state --state ESTABLISHED,RELATED`) was used for return traffic, which is stateful — a distinction worth being precise about.

## Files

- `report.pdf` — full write-up with the rules and verification screenshots
- `iptables-rules.sh` — the actual firewall and NAT commands
