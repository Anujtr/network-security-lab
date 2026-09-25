# Stage 3 - Intrusion Detection (Snort)

Put a Snort IDS on the gateway to detect and log malicious traffic. This is the detection layer of the lab, and it complements the firewall's prevention.

## Goal

Write custom Snort signatures that detect a range of network attacks, then prove they work by launching each attack from the client and confirming Snort alerts. Where Stage 2 blocks unwanted traffic, this stage detects and logs it.

## What Was Built

Nine custom signatures in [`local.rules`](local.rules), all with SIDs above 10,000,000 as required for local rules, covering:

**Denial-of-service attacks**
- **Land attack**: TCP SYN with identical source and destination IP:port
- **SYN flood**: high-volume SYN packets, caught with threshold detection
- **Smurf attack**: ICMP echo requests to a broadcast address (amplification)
- **UDP flood**: high-volume UDP packets, threshold-based

**Port scans** (five techniques)
- TCP ACK, FIN, Xmas, and Null scans (detected by their distinctive flag combinations) plus a UDP scan

Each attack was deployed from the client with `hping3` (and `nmap` for the Null scan), and Snort's alerts were captured to confirm detection.

## Key Techniques

- **Threshold detection** (`threshold: type both, ...`) to log a sample of events during a flood instead of thousands of individual alerts, which keeps the log readable while still catching the pattern.
- **Flag-based signatures** to tell scan types apart (`flags:FPU` for Xmas, `flags:0` for Null).
- **Gateway tuning** to let spoofed attack traffic through for testing: disabling reverse-path filtering (`rp_filter=0`) and enabling broadcast ping response. Without these, the Land and Smurf attacks fail silently.

## What This Demonstrates

- Writing and reasoning about IDS detection rules, which is close to real detection-engineering work.
- Understanding attack mechanics well enough to both launch and detect each one.
- The main limitation of signature-based IDS: it only catches known patterns, so a modified attack can evade it and rules need constant updating.

## Honest Caveats

Being upfront about the lab's scope, which also doubles as interview prep:
- The Land-attack rule hardcodes the target IP, so it's lab-specific. A production rule would detect the source-equals-destination condition generally.
- Some rules point at `$HOME_NET` (the server network) while Snort monitors the client-facing interface. Worth understanding the interface and direction relationship relative to where each attack traveled.

## Files

- `report.pdf`: full write-up with rule explanations, attack commands, and detection screenshots
- `local.rules`: the nine custom Snort signatures
- `snort-config-notes.md`: HOME_NET setup and config changes
