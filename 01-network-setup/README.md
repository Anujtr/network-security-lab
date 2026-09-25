# Stage 1 - Network Setup

Build the isolated virtual network that the firewall (Stage 2) and IDS (Stage 3) sit on top of.

## Goal

Stand up three Ubuntu VMs (client, gateway, server) on segmented internal networks, so the client and server can only reach each other, and the internet, through the gateway. Forcing everything through the gateway is what later lets a single firewall and IDS see and control all cross-network traffic.

## Topology

- **Client** (192.168.0.10/24): on the internal client network (Net1) only
- **Gateway**: three interfaces, client-facing (192.168.0.100), server-facing (10.0.0.100), and a NAT interface for internet access (Net3)
- **Server** (10.0.0.10/8): on the internal server network (Net2) only

The client and server networks are isolated internal networks with no direct link between them. The gateway routes between them. See the topology diagram in the repo root.

## Key Configuration

- Assigned static IPs and default gateways on each VM with **netplan** (config files in [`configs/`](configs/)).
- Enabled **IP forwarding** on the gateway so it routes between the two internal networks.
- Set up a **NAT network** on the gateway's third interface for outbound internet access.
- Verified reachability end to end with `ping` from each VM.

## What This Demonstrates

- Linux network configuration: interfaces, static addressing, routing, and persistent config with netplan.
- Network segmentation, and why isolating the client and server onto separate networks with a gateway in between is the foundation for controlling and monitoring traffic.

## Files

- `report.pdf`: full write-up with steps and verification screenshots
- `configs/`: netplan configuration files for client, gateway, and server
