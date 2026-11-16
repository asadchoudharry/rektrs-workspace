# GitHub live reads 2026-11-14 (verified live in research browser)

## ServerKit https://github.com/jhd3197/ServerKit
- 1.8k stars, 181 forks, 3,096 commits, latest commit Nov 14 2026, 92 tags / 90 releases shown
- MIT license (sidebar + README)
- README snapshot 2026-09-05: 118 bundled app templates, $0 license cost MIT without subscription/seat fees
- Requirements: Arch x86_64 · ARM64 (min & recommended), OS Ubuntu 22.04+/Debian12+/Fedora/RHEL9+, Recommended Ubuntu 24.04 LTS, 1 vCPU/1GB min
- Update: `sudo serverkit update` — Atomic blue/green update with pre-flight checks, DB backup, migration, automatic rollback. --dry-run, --branch dev, --release [version]
- Docker option note: containerised panel cannot manage its own host — no systemd, no host nginx, no managed site vhosts; use one-line install for that
- SSO & OAuth: Google, GitHub, OpenID Connect, SAML 2.0 with account linking; Auth stack: JWT, OAuth2, OIDC, SAML2, WebAuthn/passkeys; Passkeys & 2FA TOTP
- Multi-server: Go agent Linux/Windows/macOS, HMAC-SHA256 over WebSocket, native .deb/.rpm, ARM64; fleet inventory, approval queue, staged rollouts, LAN discovery, offline command queue, fleet monitor heatmaps/alerts, server templates drift detection, remote access tunnels WireGuard
- WAF: Per-app ModSecurity v3 + OWASP CRS detect/block; plus ClamAV, Fail2ban, container CVE scanning grype/SBOM syft
- Host: Nginx vhosts + Let's Encrypt, DNS, MySQL/MariaDB+PostgreSQL with SQL console, files/FTP/cron visual editor, email Postfix/Dovecot, backups S3/B2, Marketplace 100+ templates, Docker & Compose, monitoring real-time CPU/RAM/disk/network + alerts Discord/Slack/Telegram/email/webhooks, status pages
- Contributing flow: fork → feature branch → PR

## 1Panel https://github.com/1Panel-dev/1Panel
- 37.5k stars, 3.4k forks, 5,819 commits, latest commit Nov 14 2026, GPL-3.0, 135 tags, Releases 133, latest v2.5.1 visible in sidebar
- README Pro table (primary gate evidence): OSS is free forever; Pro/Ent add:
  - One-click app installs: OSS ✅ Pro ✅ Ent ✅
  - AI agents: OSS 5, Pro Unlimited
  - WAF & advanced security: OSS Basic, Pro/Ent ✅
  - Website tamper protection: OSS ❌ Pro/Ent ✅
  - Website uptime monitoring: OSS ❌ Pro/Ent ✅
  - Multi-node management: OSS ❌ Pro/Ent ✅
  - Custom logo/theme: OSS ❌
  - KVM Web UI / AI Gateway: Ent only
- README: 165+ apps in marketplace comparison table, curated app store one-click

## Portainer https://github.com/portainer/portainer
- 38.8k stars, 2.9k forks, 6,197 commits, Zlib license, branch release/2.45, Releases 195, Release 2.45.3 LTS Latest visible
- README: CE is free lightweight container mgmt UI for Docker, Swarm, Podman, Kubernetes, ACI; BE builds on same open-source base and adds features/hardening/commercial support; Take3 – get 3 free nodes of BE
- README Intended use (truncated in view): CE designed for homelabs/learning/personal/non-production, no support/warranty — need docs page for full

## Cockpit https://github.com/cockpit-project/cockpit
- 15.4k stars, 1.4k forks, 24,413 commits, Contributors 241 visible, Releases 456, latest release 372 (4 days before Nov 14, i.e. ~Nov 10 2026)
- Licenses listed: LGPL-2.1 or later (main), plus GPL-3.0+, BSD-3, CC-BY-SA, MIT for components
- README: interactive server admin, add other machines that have Cockpit installed and accessible via SSH and jump between them; available in numerous distros as `cockpit` package
