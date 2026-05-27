# ThreatScore-2.0

ThreatScore-2.0 is a Bash-based threat intelligence and IOC enrichment platform that combines threat-intel APIs, Google-grounded OSINT, AI-driven analysis, and Telegram integration into a single workflow.

It is designed to act like a lightweight SOC/threat-hunting assistant rather than a simple IOC reputation checker.

---

# Features

- IOC analysis for:
  - IP addresses
  - Domains
  - URLs
  - MD5 / SHA1 / SHA256 hashes

- Threat enrichment using:
  - VirusTotal
  - AbuseIPDB
  - AlienVault OTX
  - Cloudflare URL Scanner
  - URLScan
  - MalwareBazaar
  - ThreatYeti
  - Gemini grounded Google OSINT

- AI-driven operational analysis using GPT-5.5:
  - Infrastructure role analysis
  - Phishing/malware delivery detection
  - Scanning/bruteforce behavior analysis
  - Infostealer/stager workflow analysis
  - Malware execution-role reasoning
  - Threat attribution context
  - SOC-focused remediation guidance

- Telegram bot integration
- Real-time IOC submissions through Telegram
- Structured analyst-style verdicts
- Infrastructure-aware IOC triage
- Community vs official OTX pulse distinction
- Google-grounded cybersecurity OSINT searching
- CSV IOC history logging

---

# Example Output

```text
ThreatScore AI Analysis

Type: URL
Target: https://saocloud.icu

Verdict:
Malicious URL/domain used as Rhadamanthys infostealer infrastructure, likely payload staging and/or C2/exfiltration support.

Confidence:
High - Multiple VT detections plus OSINT/sandbox reporting tie the domain to Rhadamanthys-like stealer behavior.

Infrastructure:
Hosted on suspicious disposable .icu infrastructure associated with malware delivery activity.

Why:
OSINT and sandbox telemetry indicate PowerShell-based payload delivery, script execution, and credential/session theft behavior.

Associated activity:
Infostealer delivery, fake CAPTCHA chains, payload staging, and credential theft.

Likely behavior:
Victims are redirected through phishing/malvertising flows that retrieve additional payloads from attacker-controlled infrastructure.

Exploit pattern:
PowerShell loader / phishing delivery chain.

Threat attribution:
Associated with Rhadamanthys infostealer activity.

Action:
Block at DNS/proxy/firewall layers, hunt for historical connections, investigate PowerShell execution and browser credential access.
```

---

# Architecture

```text
IOC
 ↓
ThreatScore-2.0
 ↓
Threat Intel APIs
 ↓
Google-grounded OSINT
 ↓
GPT-5.5 Threat Analysis
 ↓
Telegram / Terminal Output
 ↓
CSV IOC History Logging
```

---

# Installation

## Clone

```bash
git clone https://github.com/YOUR_USERNAME/ThreatScore-2.0.git
cd ThreatScore-2.0
```

---

## Install Dependencies

### Ubuntu / Debian

```bash
sudo apt update

sudo apt install -y \
curl \
jq
```

---

# API Keys Required

ThreatScore-2.0 requires API keys for several providers.

The script will prompt for keys automatically on first launch and store them locally in:

```bash
.ThreatScore.conf
```

Required services:

```text
OpenAI
Gemini
VirusTotal
AbuseIPDB
OTX
Cloudflare
URLScan
ThreatYeti
MalwareBazaar
Telegram Bot
```

---

# Usage

## Make Executable

```bash
chmod +x ThreatScore_2.0.sh
```

Run:

```bash
./ThreatScore_2.0.sh
```

---

## Telegram IOC Submission

Send any IOC directly to the Telegram bot:

```text
8.8.8.8
example.com
https://example.com
44d88612fea8a8f36de82e1278abb02f
```

---

# CSV Logging

ThreatScore-2.0 automatically stores analyzed IOCs in:

```bash
ThreatScore_results.csv
```

Format:

```text
Timestamp,Type,IOC,Verdict
```

Example:

```text
2026-05-23 21:14:02,IP,8.34.210.38,HIGH
2026-05-23 21:18:11,URL,https://saocloud.icu,HIGH
2026-05-23 21:20:44,HASH,f13a42e6016eb9a413ff180378059f9c6202e92fc06797e48975dc0dc72c2b9e,MEDIUM
```

---

# Analysis Types

## IP Analysis

Focuses on:
- scanning
- brute force
- exposed-service probing
- honeypot activity
- VPS/proxy/VPN abuse
- auth attacks
- infrastructure role

---

## Domain / URL Analysis

Focuses on:
- phishing
- fake CAPTCHA
- pastejacking
- malware staging
- redirects
- credential theft
- infostealers
- C2/exfiltration infrastructure

---

## Hash Analysis

Focuses on:
- malware capability
- PE/DLL traits
- packers
- anti-debugging
- sandbox behavior
- loader/dropper behavior
- malware execution role

---

# Design Goals

ThreatScore-2.0 is designed to prioritize:

- operational behavior over raw reputation
- grounded evidence over hallucination
- SOC-style reasoning over generic summaries
- infrastructure role analysis over vendor metadata
- actionable remediation guidance

---

# Notes

- ThreatScore-2.0 is designed for defensive/security research purposes.
- Outputs are AI-assisted and should be validated in operational environments.
- Threat intelligence from community sources may contain false positives or incomplete context.
- Some OSINT results may vary over time due to live Google-grounded searches and external threat-intelligence updates.
- If an external API is unavailable or returns incomplete data, some fields may appear as `null`, `N/A`, or empty in the analysis.
