# Stage 3 — Intrusion Detection (Snort)

Put a Snort IDS on the gateway to detect and log malicious traffic — the **detection** layer of the lab, complementing the firewall's prevention.

## Goal

Write custom Snort signatures that detect a range of network attacks, then prove they work by launching each attack from the client and confirming Snort alerts. Where Stage 2 *blocks* unwanted traffic, this stage *detects and logs* it.

## What Was Built

Nine custom signatures in [`local.rules`](local.rules) (all with SIDs above 10,000,000, as required for local rules), covering:

**Denial-of-service attacks**
- **Land attack** — TCP SYN with identical source and destination IP:port
- **SYN flood** — high-volume SYN packets, caught with threshold detection
- **Smurf attack** — ICMP echo requests to a broadcast address (amplification)
- **UDP flood** — high-volume UDP packets, threshold-based

**Port scans** (five techniques)
- TCP ACK, FIN, Xmas, and Null scans (detected by their distinctive flag combinations) and a UDP scan

Each attack was deployed from the client using `hping3` (and `nmap` for the Null scan), and Snort's alerts were captured to confirm detection.

## Key Techniques

- **Threshold detection** (`threshold: type both, ...`) to log a sample of events during a flood rather than thousands of individual alerts — keeping the log readable while still catching the pattern.
- **Flag-based signatures** to distinguish scan types (e.g. `flags:FPU` for Xmas, `flags:0` for Null).
- **Gateway tuning** required to let spoofed attack traffic through for testing — disabling reverse-path filtering (`rp_filter=0`) and enabling broadcast ping response, without which the Land and Smurf attacks fail silently.

## What This Demonstrates

- Writing and reasoning about IDS detection rules — close to real detection-engineering work.
- Understanding attack mechanics well enough to both *launch* and *detect* each one.
- The core limitation of signature-based IDS: it catches known patterns only, so a modified attack can evade it and rules need constant updating.

## Honest Caveats

Being upfront about the lab's scope (and good interview prep):
- The Land-attack rule hardcodes the target IP, making it lab-specific; a production rule would detect the source-equals-destination condition generally.
- Some rules point at `$HOME_NET` (the server network) while Snort monitors the client-facing interface — worth understanding the interface/direction relationship relative to where each attack traveled.

## Files

- `report.pdf` — full write-up with rule explanations, attack commands, and detection screenshots
- `local.rules` — the nine custom Snort signatures
- `snort-config-notes.md` — HOME_NET setup and config changes
