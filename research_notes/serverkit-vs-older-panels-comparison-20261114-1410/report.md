# ServerKit vs 1Panel vs Portainer CE vs Cockpit — sourced comparison

Research date: **2026-11-14**. All facts below were read on 2026-11-14 unless a different date is stated. Each fact is flagged **[verified live]** (read in the live browser on the actual page) or **[index]** (read via the web index/search fetch of that page). URLs are copied verbatim from tool results.

## Summary

**Verdict: No — none of the three older panels beats ServerKit for this specific use case** (self-hosted on an ARM64 Ubuntu 24.04 Oracle host; one free-forever panel; SSO/OIDC to external Keycloak; multi-server management of x86 VPS hosts; one-click Docker app installs incl. Uptime Kuma and MinIO; owner self-manages and may self-fork). ServerKit is the only one of the four that satisfies all the hard requirements simultaneously in its single, MIT-licensed edition. Each older panel fails at least one hard requirement, with an exact, citable gate:

- **1Panel** — multi-node management is **Pro-only** (official Pro page + README comparison table), advanced WAF is Pro-only, and **no SSO/OIDC exists in any edition found** (official Settings doc lists only a single local user, password, TOTP, passkey). Closest competitor on host depth and app store, but fails requirements 1, 2 and 3.
- **Portainer CE** — container-only (no host management at all), so it fails requirement 5 outright; its full SSO (OIDC discovery, group→team sync, RBAC, audit) is Business Edition, which is free only up to **3 nodes** and paid from $1,045/yr above that; CE's own OAuth-to-Keycloak works only in a limited manual mode (third-party evidence). Decisively, **Portainer 3 has no Community Edition at all and CE 2.45 stops receiving fixes after August 2027** (official blog, 2026-11-06) — a hard security-patch deadline for a self-forking owner.
- **Cockpit** — fully free and the best raw OS/systemd admin tool, but **has no OIDC login** (SSO = Kerberos/SSSD only), its **multi-host switching is deprecated since Cockpit 322** and disabled by default on most current distros, and it has **no app store / no Docker app templates** (Podman single containers only). Fails requirements 2, 3 and 4.

ServerKit's caveats (stated honestly, weighted per the mission): it is by far the youngest/smallest project (1.8k stars vs 37–39k); Keycloak-specific login interoperability is **UNVERIFIED** (generic OIDC is documented); a generic arbitrary-systemd-unit UI is **UNVERIFIED**; and whether local core modifications survive its blue/green updater is **UNVERIFIED**.

## Findings

### 1. Truly free for lifetime — paid-edition gates

**ServerKit — PASS, no paid edition found.** Single MIT-licensed product; README: "$0 license cost — MIT-licensed, without subscription or seat fees." [verified live] https://github.com/jhd3197/ServerKit

**1Panel — FAIL (multi-node + parts of WAF/security gated).** Official Pro edition page **[index, opened 2026-11-14]** https://1panel.pro/pro-edition and the README's own Pro comparison table **[verified live]** https://github.com/1Panel-dev/1Panel agree:
- OSS edition: "$0, free to use, open-source, forever free"; includes full Docker/website/app management, 185+ one-click apps (Pro page; README table says 165+ — counts differ by source/date), **Basic WAF**.
- **Multi-node management: OSS ❌ / Pro ✅** ("Unified Multi-node Console — OSS: — / Pro: ✓"; cross-node file transfer Pro-only).
- Pro-only also: advanced WAF + anti-tampering, website tamper protection, website uptime monitoring/monitoring reports, scheduled virus scanning, custom logo/theme, custom app-store URL, mobile apps, email & IM alerts (email panel alerts themselves are free; WeCom/DingTalk/Feishu/SMS alerts are Pro-only per the Settings doc).
- Ent-only: KVM Web UI, AI Gateway, priority support.
- Pro pricing: **$80/year subscription** or **$200 perpetual license (V2 only)**; one license bound to one device at a time.

**Portainer CE — PARTIAL FAIL.** CE itself is free, open source (zlib), no license key — official CE-vs-BE blog, 2026-01-05 **[index, opened 2026-11-14]** https://www.portainer.io/blog/portainer-community-edition-ce-vs-portainer-business-edition-be-which-should-you-install . But the gated features live in Business Edition: full RBAC (CE = basic user management), full GitOps, registry management, audit logs, Kubernetes provisioning, fleet governance policies, and SSO "Yes" vs CE "Limited". BE is "free forever for up to 3 nodes — no trial, no credit card, no feature restrictions"; beyond 3 nodes, official pricing **[index]** https://www.portainer.io/pricing lists Starter **$1,045/yr** (5/10/15 nodes) and Scale **$2,095/yr** (5–25 nodes). A node = any machine running or managed by Portainer Server. For "panel + several x86 servers" this use case exceeds 3 nodes, so the full-featured edition is not free here. Worse for "free for lifetime": see §8 — CE is end-of-line.

**Cockpit — PASS.** No paid edition exists; fully free, LGPL-2.1-or-later (plus some GPL-3.0+/BSD/MIT components). [verified live] https://github.com/cockpit-project/cockpit

### 2. SSO/OIDC with external Keycloak (free edition)

**ServerKit — PASS (generic OIDC documented; Keycloak-specific UNVERIFIED).** README lists "SSO & OAuth: Google, GitHub, **OpenID Connect, and SAML 2.0** with account linking"; auth stack includes JWT, OAuth 2.0, OIDC, SAML 2.0, WebAuthn/passkeys, TOTP 2FA. [verified live] https://github.com/jhd3197/ServerKit . No ServerKit-specific document naming Keycloak as a tested IdP was found — **Keycloak interoperability is UNVERIFIED**; note ServerKit also ships one-click *templates to deploy* Keycloak/Authelia/Authentik as apps (https://www.serverkit.ai/templates/keycloak [index]), which is a different fact from panel-login integration.

**1Panel — FAIL.** Official Settings documentation **[index, opened 2026-11-14]** https://1panel.pro/docs/v2/user_manual/settings/ lists the complete auth surface: one panel user per host ("1Panel supports one user per host"), panel password + expiration/complexity, TOTP MFA, passkey (WebAuthn), security entrance, allowed IPs, domain binding, panel SSL. No OAuth/OIDC/LDAP/SSO settings appear anywhere in the doc, and the Pro page does not list SSO either. No OIDC login to Keycloak exists in the free edition (or in any edition found).

**Portainer CE — PARTIAL PASS (limited).** Official blog: "Business Edition integrates with AD, LDAP, and OIDC-compatible IdPs… Community Edition supports LDAP and OAuth in a more limited form without AD support or provider templates." [index] https://www.portainer.io/blog/portainer-community-edition-ce-vs-portainer-business-edition-be-which-should-you-install . Third-party evidence (not Portainer-official) confirms CE's custom OAuth provider can be pointed at Keycloak by manually entering auth/token/userinfo URLs, but CE lacks OIDC discovery and creates users with no team membership; BE adds discovery + automatic team sync from group claims **[index]** (KeycloakPro Portainer–Keycloak guide; https://architecture.portainer.io/ch4 describes the custom-provider option). So: basic Keycloak login in CE = plausible/limited; full SSO + group mapping + RBAC = BE (free ≤3 nodes only).

**Cockpit — FAIL.** Official Authentication guide **[index, opened 2026-11-14]** https://cockpit-project.org/guide/195/authentication.html : login is via local PAM accounts "or you can setup a Kerberos based SSO solution." The official SSO guide covers Kerberos only — domain-joined host (`realm join`), krb5.keytab, FreeIPA/AD, SSSD; plus TLS client certificates/smart cards via FreeIPA/AD + SSSD [index] https://cockpit-project.org/guide/195/sso.html . **No native OIDC/OAuth provider login** (Keycloak as an OIDC client) appears in the official auth docs. Keycloak could only participate indirectly via Kerberos/SPNEGO federation — not the required direct OIDC integration.

### 3. Multi-server management from one dashboard (free edition)

**ServerKit — PASS, full control.** Dedicated Go agent (Linux/Windows/macOS; native .deb/.rpm; ARM64), HMAC-SHA256-signed real-time WebSocket/Socket.IO link; fleet inventory, approval queue, staged agent rollouts, LAN auto-discovery, offline command queue, fleet heatmaps/metric comparisons/alert thresholds/anomaly detection, server templates with drift detection/auto-remediation, WireGuard remote-access tunnels, remote Docker control. [verified live + index] https://github.com/jhd3197/ServerKit . Agent now lives in its own repo (jhd3197/serverkit-agent) per project discussion [index]. Not observe-only — it is a full remote-admin agent.

**1Panel — FAIL in free edition.** The panel's architecture is core + per-host agents, but the unified multi-node console, cross-node monitoring, batch updates and cross-node file transfer are exactly the Pro gate in §1 (OSS ❌). Free edition = single-host panels only. Gate evidence: https://1panel.pro/pro-edition [index] and README table [verified live] https://github.com/1Panel-dev/1Panel .

**Portainer CE — PASS for containers only.** Portainer Agent / Edge Agent per environment gives full container control (containers, images, volumes, networks, stacks/Compose) across many hosts from one dashboard, free in CE. It manages container environments, **not hosts** (see §5). Fleet governance policies and full RBAC are BE-only. [index] https://www.portainer.io/blog/portainer-community-edition-ce-vs-portainer-business-edition-be-which-should-you-install

**Cockpit — FAIL (deprecated).** Official latest guide **[index, opened 2026-11-14]** http://cockpit-project.org/guide/latest/feature-machines.html carries the banner: **"This feature is deprecated as of Cockpit 322."** Mechanism: primary server reaches others over SSH (password/SSH keys), hosts listed in `/etc/cockpit/machines.d/*.json`; switching gives full per-host Cockpit admin (not observe-only), but it is host-switching, not a unified fleet dashboard (the old aggregate Dashboard page was removed in Cockpit 234 [index]). Cockpit 322 release notes [index]: host switcher disabled by default in Fedora 41+, Debian testing/unstable, CentOS Stream 10, RHEL 10, Arch — it "stays as-is in current stable distros including Ubuntu 22.04/24.04 LTS", and can be re-enabled with `AllowMultiHost=yes` in cockpit.conf. Deprecation reason: all hosts' code runs in one browser context with no isolation (security).

### 4. App store / one-click Docker app templates

**ServerKit — PASS.** 118 bundled app templates (README snapshot dated 2026-09-05) / "100+ templates" marketplace [verified live] https://github.com/jhd3197/ServerKit . **Uptime Kuma: yes** — https://www.serverkit.ai/templates/uptime-kuma [index] ("Uptime Kuma is a ServerKit template: click install… provisions containers, volumes, reverse proxy"). **MinIO: yes** — https://www.serverkit.ai/templates/minio [index] (same one-click wording; MinIO itself is AGPL-3.0). Per-template ARM64: a template-status source found in the index claimed minio supports linux/amd64+arm64 and uptime-kuma passes on ARM64, but that source's attribution to ServerKit could not be fully confirmed — **per-template ARM64 status is partly UNVERIFIED**; upstream Uptime Kuma and MinIO images are multi-arch, and both templates are Docker-based, so ARM64 use is expected but should be confirmed per template before committing.

**1Panel — PASS on apps (but see §1/§3 gates).** Official Pro page: **185+ one-click apps** (README table says 165+ — discrepancy noted). Includes Uptime Kuma and MinIO [index, secondary] (homeserver roundup 2026-11-12 lists the store running "Nextcloud, Bitwarden, Uptime Kuma, WordPress, MySQL, Redis and MinIO"). Note: app store itself is free in OSS, but a *custom app-store URL* is Pro-only, and apps can only be installed per single host in the free edition (no multi-node console).

**Portainer CE — WEAK / not a vendor app store.** No native curated app store. Portainer ships a small default template list and supports a custom template JSON URL; the large catalogue is the community-maintained Lissy93/portainer-templates (400+/500+ templates, MIT) imported via Settings → App Templates [index], which includes an Uptime Kuma stack (its page notes amd64/arm64/armv7 images) [index]. **MinIO's presence in that community list was NOT individually verified — UNVERIFIED.** Templates are community-maintained, not Portainer-curated.

**Cockpit — FAIL.** No app store and no app templates. Containers are handled by the cockpit-podman plugin: pull an image and run a single Podman container — no Compose stacks, no one-click catalogue [index, incl. SUSE Cockpit docs]. Uptime Kuma/MinIO would be manual container creation, and via Podman rather than Docker.

### 5. Host management depth

**ServerKit — broadest web-hosting-style depth.** README [verified live] https://github.com/jhd3197/ServerKit : Nginx virtual hosts + Let's Encrypt, DNS zones (Cloudflare/Route53/DigitalOcean), MySQL/MariaDB + PostgreSQL with browser SQL console, web file manager + FTP, visual cron editor, Postfix/Dovecot email, backups to S3/B2/local, Docker & Compose, per-app WAF (ModSecurity v3 + OWASP CRS), ClamAV/Fail2ban/SSH hardening, container CVE scanning (grype/syft), real-time monitoring + alerts (Discord/Slack/Telegram/email/webhooks), status pages; UI also shows processes, journald logs, SSH sessions. Caveats: (a) a **generic arbitrary systemd-unit management UI is UNVERIFIED** — the "Services" UI refers to app services (static/Node/Python/PHP/Docker apps); (b) the README warns that a **containerised (Docker) install cannot manage its own host** (no systemd, no host nginx, no managed vhosts) — the one-line install is required for host management.

**1Panel — strong single-host depth.** Both editions include (official Pro page [index] https://1panel.pro/pro-edition ): Docker, website management (OpenResty sites/SSL), databases, firewall, SSH, file management, app store, scheduled tasks (cron), monitoring, backups, Fail2ban, basic WAF. Advanced WAF/anti-tamper and several monitoring/alert extras are Pro (see §1). No SSO/multi-user model (one user per host).

**Portainer CE — containers only, by design.** Scope is Docker/Swarm/Podman/Kubernetes/ACI environments [verified live README] https://github.com/portainer/portainer . Panel-natively **missing**: systemd services, host files, host firewall, web server/virtual hosts, host databases, cron, host monitoring/alerting. Fails the host-depth requirement outright; it would have to be paired with another tool for host admin.

**Cockpit — best raw OS admin, no web-hosting layer.** Official site [index] https://cockpit-project.org/ : systemd services (inspect/interact), logs/journal, network settings, firewall (firewalld), storage (RAID/LUKS/NFS/iSCSI), user accounts, software updates (PackageKit), terminal, SELinux, VMs (cockpit-machines), Podman containers, metrics history via PCP. File manager is a separate app (cockpit-files/Navigator) [index] https://cockpit-project.org/applications . **Missing panel-natively**: nginx/Apache virtual hosts, MySQL/PostgreSQL admin, mail, cron editor (shows systemd timers, not crontab [index, secondary]), WAF, DNS/web-hosting features.

### 6. ARM64 support (panel + agent)

**ServerKit — PASS both.** README requirements table: Arch "x86_64 · ARM64" (minimum and recommended), OS Ubuntu 22.04+/Debian 12+/Fedora/RHEL-family 9+, **Recommended: Ubuntu 24.04 LTS** [verified live] https://github.com/jhd3197/ServerKit . Panel Docker image multi-arch **verified**: `jhd3197/serverkit:1.11.40` and `:latest` list linux/amd64 (121.84 MB) + **linux/arm64 (121.01 MB)** [index fetch, crawled 2026-11-14] https://hub.docker.com/r/jhd3197/serverkit/tags . Agent: Go binaries incl. ARM64 (.deb/.rpm) per README [verified live].

**1Panel — PASS (panel).** Official install docs list server architectures: **x86_64, aarch64, armv7l, ppc64le, s390x, riscv64** [index] https://1panel.pro/docs/v2/installation/online_installation/ . A community Docker image (moelin/1panel) also lists linux/arm64 [index] — noted as community, not official; the official evidence is the install-doc architecture list. (Agent/node ARM binaries matter less here because multi-node is Pro-gated anyway.)

**Portainer CE — PASS both.** CE image tags list **linux/arm64** (e.g. `portainer/portainer-ce:2.45.3-alpine`, `2.45.3-linux-arm64`) [index, opened 2026-11-14] https://hub.docker.com/r/portainer/portainer-ce/tags . Agent image also multi-arch **verified**: `portainer/agent:3.0.1-alpine` lists linux/amd64, linux/arm/v7, **linux/arm64 (43.8 MB)**, linux/ppc64le [index fetch, crawled 2026-11-14] https://hub.docker.com/r/portainer/agent/tags . In this use case the agents run on x86 VPS hosts anyway; the ARM64 panel host is what matters, and it is supported.

**Cockpit — PASS.** Distro-packaged (no Docker panel image). Ubuntu Noble (24.04) **arm64** packages exist: packages.ubuntu.com noble-backports lists cockpit-pcp for arm64; Launchpad shows cockpit-bridge / cockpit-sosreport arm64 builds for Noble (e.g. 362-1~bpo24.04.1 published 2026-07-22) [index]. No separate agent — remote hosts need cockpit-bridge + SSH, same packages.

### 7. Maturity and health

| Panel | Age | Latest release (Nov 2026) | Cadence | Stars / forks / commits | License |
|---|---|---|---|---|---|
| ServerKit | Youngest; founding/first-release date **UNVERIFIED** | **v1.11.40, 2026-11-14** [verified live] | Very frequent (v1.11.27 Oct 26, v1.11.24 Oct 24, v1.11.20 Oct 12, plus dev builds) | 1.8k stars, 181 forks, 3,096 commits [verified live] | MIT |
| 1Panel | Repo created **2022-07-19** [index, secondary] | **v2.5.1, 2026-11-12** [index, official changelog https://1panel.pro/docs/v2/changelog/ ] | ~Weekly/bi-weekly (v2.5.0 Nov 11, v2.4.2 Oct 30, v2.4.1 Oct 22) | 37.5k stars, 3.4k forks, 5,819 commits [verified live] | GPL-3.0 |
| Portainer CE | Founded **2016**, first major release June 2016 [index, secondary] | **CE 2.45.3 LTS** (Oct 2026) [index, Docker Hub + repo sidebar] | LTS line; **CE is end-of-line** (see §8) | 38.8k stars, 2.9k forks, 6,197 commits [verified live] | zlib (CE); BE commercial |
| Cockpit | Started **2013**, Red Hat-sponsored [index, LWN https://lwn.net/Articles/965434/ ] | **372, 2026-11-10** [verified live sidebar] | Time-based, ~every two weeks (in practice near-weekly recently) | 15.4k stars, 1.4k forks, 24,413 commits, **241 contributors** [verified live] | LGPL-2.1+ (main) |

Contributor counts for ServerKit, 1Panel and Portainer were not directly captured — **UNVERIFIED** (Cockpit's 241 was visible on its repo page). Per the mission, team size/bus factor is weighted LOW for this decision; the maturity gap matters mainly as longevity risk for ServerKit and as an end-of-life risk for Portainer CE (which is a lifecycle fact, not a team-size judgement).

Repo URLs: https://github.com/jhd3197/ServerKit · https://github.com/1Panel-dev/1Panel · https://github.com/portainer/portainer · https://github.com/cockpit-project/cockpit — all [verified live] 2026-11-14.

### 8. Self-update mechanism, core-mod survival, fork-friendliness

**ServerKit.** Update: `sudo serverkit update` — atomic blue/green update with pre-flight checks, DB backup, migration, automatic rollback; supports `--dry-run`, `--branch dev`, `--release [version]` [verified live README] https://github.com/jhd3197/ServerKit . MIT license = unrestricted fork. Intended extension model per README/CONTRIBUTING: fork → feature branch → PR, and new capabilities ship as installable Marketplace extensions (core stays lean). **Whether local core modifications survive a blue/green `serverkit update` is UNVERIFIED** — the mechanism replaces the installation atomically, so a self-forker should assume core edits are overwritten unless he maintains his own build/update path; no explicit vendor statement was found.

**1Panel.** Settings doc §7 (About): in-panel update check with auto-rollback on failure; snapshots cover the 1panel binary, 1pctl, systemd service, DB and apps [index] https://1panel.pro/docs/v2/user_manual/settings/ . GPL-3.0 = forkable. **Important fork caveat** from the official advanced-install doc [index]: "The 1Panel binary installed from this script includes additional features of the professional edition beyond the open-source repository code, which require a license for activation" — i.e. the official binary ≠ the OSS repo; Pro features are not reproducible from the public source. Whether core mods survive updates: **UNVERIFIED** explicitly.

**Portainer CE.** CE is zlib-licensed and forkable, and is normally updated by pulling the new image and recreating the container (data in /data) — the official upgrade doc was not opened, so treat the mechanism detail as standard-Docker practice rather than cited fact. The decisive fact is lifecycle: official blog, 2026-11-06 **[index, opened 2026-11-14]** https://www.portainer.io/blog/portainer-3-is-kubernetes-first-not-kubernetes-only — "**Portainer 3 has no Community Edition. CE 2.45 is the last version of CE we will release**… it won't get new features, and **after August 2027 it won't get fixes either**. Portainer has root-level access… we'd advise against running it unpatched." (This official post supersedes an earlier May 2027 end date reported by third parties in Sept 2026 — sources disagreed; the later official statement is used.) Portainer 3 is Kubernetes-first; Docker/Swarm/Podman get bug/security fixes only. For a self-forking owner this means: after Aug 2027, **all** security patching of CE becomes his own burden. BE is closed commercial code — not forkable. CE's README also positions CE for homelabs/learning/non-production use [verified live, partially truncated view; corroborated by secondary summaries].

**Cockpit.** Fully free/LGPL — forkable. Updates arrive through the distro package manager / Cockpit's own Software Updates page (distro-packaged model); a fork means maintaining your own packages/builds instead of taking distro updates. A specific official citation for the update mechanism was not captured — mechanism detail flagged accordingly. No paid edition and no vendor kill-switch: the lowest long-term patch-burden risk of the four *for the panel code itself*, but it fails the functional hard requirements (§2–§4).

## Comparison table (the 8 points)

| # | Criterion | ServerKit | 1Panel | Portainer CE | Cockpit |
|---|---|---|---|---|---|
| 1 | Free for lifetime, no paid gate on required features | ✅ Single MIT edition, $0, no paid tier found | ❌ Multi-node = Pro ($80/yr or $200 perpetual V2); advanced WAF etc. Pro | ⚠️ CE free, but full SSO/RBAC/GitOps/audit = BE; BE free ≤3 nodes only, then $1,045/yr+; CE end-of-line | ✅ Fully free, no paid edition |
| 2 | SSO/OIDC to Keycloak (free ed.) | ✅ Generic OIDC + SAML 2.0 in core (Keycloak-tested: UNVERIFIED) | ❌ None — single local user + TOTP + passkey only | ⚠️ Limited manual OAuth (no discovery, no group→team sync); full SSO = BE | ❌ Kerberos/SSSD SSO only, no OIDC |
| 3 | Multi-server from one dashboard (free ed.) | ✅ Free Go agent, full control, fleet features | ❌ Pro-only unified multi-node console | ✅ For containers (Agent/Edge Agent, full container control) — not hosts | ❌ Multi-host deprecated since v322; SSH host-switching, off by default on most current distros |
| 4 | App store / one-click Docker templates | ✅ 118 bundled templates; Uptime Kuma ✅, MinIO ✅ (per-template ARM64 partly UNVERIFIED) | ✅ 185+ apps (README: 165+); Uptime Kuma ✅, MinIO ✅ — but per-host only in free ed. | ⚠️ No vendor store; community template JSON (Lissy93, 400+); Uptime Kuma ✅, MinIO UNVERIFIED | ❌ None; Podman single-container run only, no Compose/templates |
| 5 | Host management depth | ✅ Nginx vhosts+LE, DNS, MySQL/PG + SQL console, files/FTP, cron editor, mail, backups, Docker, ModSecurity WAF, monitoring/alerts (generic systemd UI UNVERIFIED; Docker-install can't manage own host) | ✅ Strong single-host: sites/SSL, DBs, firewall, files, cron, Docker, monitoring, basic WAF | ❌ Container environments only; no systemd/files/firewall/vhosts/DBs/cron/host monitoring | ✅ Best raw OS admin: systemd, firewalld, storage, logs, updates, terminal; ❌ no vhosts/DB admin/cron editor/WAF; files via separate app |
| 6 | ARM64 (panel + agent) | ✅ README arch table x86_64·ARM64, Ubuntu 24.04 recommended; Docker image linux/arm64 verified; agent ARM64 | ✅ Official install docs list aarch64 (+armv7l/ppc64le/s390x/riscv64) | ✅ CE image linux/arm64 verified; Agent image linux/arm64 verified | ✅ Ubuntu 24.04 (Noble) arm64 packages verified (Launchpad/packages.ubuntu.com); no separate agent (bridge+SSH) |
| 7 | Maturity / health | Youngest: 1.8k★, v1.11.40 (2026-11-14), very frequent releases, MIT | 37.5k★, repo since 2022-07, v2.5.1 (2026-11-12), ~weekly, GPL-3.0 | 38.8k★, since 2016, CE 2.45.3 LTS — but CE discontinued in v3, zlib | 15.4k★, since 2013, Red Hat, v372 (2026-11-10), ~biweekly, 241 contributors, LGPL-2.1+ |
| 8 | Self-update / fork | `serverkit update` blue/green + rollback; MIT fork; extensions via Marketplace; core-mod survival UNVERIFIED | In-panel update + rollback, snapshots; GPL fork, but official binary contains non-OSS Pro code (license-activated) | Image-pull updates; zlib fork of CE possible, but upstream CE fixes end Aug 2027 → patch burden shifts to owner; BE closed | Distro package updates; LGPL fork = maintain own packages; no vendor EOL announced |

## Verdict

**No older panel beats ServerKit for this use case.** Scoring strictly against the stated hard requirements:

- **1Panel fails 3 of them**: multi-server is pay-gated (Pro, $80/yr or $200 perpetual — official Pro page + README table), there is no SSO/OIDC at all (official Settings doc), and advanced WAF is pay-gated. It would be the pick only if the company dropped the SSO and multi-server requirements or accepted a per-device Pro license — which contradicts "truly free for lifetime."
- **Portainer CE fails on scope and lifecycle**: it manages containers, not hosts (no systemd/files/firewall/vhosts/databases/cron), its complete SSO/RBAC feature set is Business Edition (free only ≤3 nodes; this fleet is larger), it has no vendor app store, and — most damaging for a self-manager — **CE is finished: no CE in Portainer 3, and CE 2.45 receives no fixes after August 2027** (Portainer's own blog). A fork owner inherits 100% of security patching from that date.
- **Cockpit fails 3 of them**: no OIDC (Kerberos-only SSO), multi-host deprecated since v322, and no app store/Docker templates at all. It remains an excellent free *per-host OS admin* tool and could complement a panel, but it cannot be the one panel for this brief.
- **ServerKit passes every hard requirement in its free MIT edition**: generic OIDC/SAML SSO, free full-control multi-server agent (ARM64), 118 one-click templates including verified Uptime Kuma and MinIO pages, the broadest host/web management of the four, verified ARM64 panel support on Ubuntu 24.04, and a documented self-update command. Its risks are longevity/maturity (young, small community — weighted LOW per the brief) and the unverified items below, which should be validated in a pilot (especially a Keycloak login test) before full commitment.

## Could not verify (UNVERIFIED — not guessed)

1. ServerKit login against a real **Keycloak** realm (only generic OIDC/SAML support is documented).
2. ServerKit generic **systemd-unit management UI** (services UI found refers to app services).
3. Whether **local core modifications survive updates** for ServerKit (blue/green updater) and 1Panel — no explicit vendor statement found for either.
4. **Per-template ARM64** status inside ServerKit's catalogue (incl. its Uptime Kuma/MinIO templates specifically); upstream images are multi-arch.
5. **MinIO** presence in the community Lissy93 Portainer template list.
6. GitHub **contributor counts** for ServerKit, 1Panel, Portainer (only Cockpit's 241 was directly visible); ServerKit's founding/first-release date.
7. Portainer CE's official upgrade-procedure document (not opened; update-by-image-pull is standard practice, stated as such).
8. Cockpit's software-update mechanism citation from an official upgrade doc (distro-packaging model is established; the specific citation was not captured).
9. 1Panel app count discrepancy: official Pro page says **185+**, README comparison table says **165+** (reported as-is; likely different snapshot dates).
10. Portainer CE 2.45 LTS end-of-support: third-party Sept 2026 reporting said May 2027; Portainer's official 2026-11-06 blog says fixes stop **after August 2027** and supersedes the earlier announcement — the official later date is used in this report.

## Sources

All read 2026-11-14. [L] = verified live in browser, [I] = via web index fetch.

- ServerKit repo (README: features, requirements/ARM64, update command, 118 templates, SSO list) — https://github.com/jhd3197/ServerKit [L]
- ServerKit Docker Hub tags (linux/arm64 for 1.11.40/latest) — https://hub.docker.com/r/jhd3197/serverkit/tags [I]
- ServerKit template pages — https://www.serverkit.ai/templates/uptime-kuma [I], https://www.serverkit.ai/templates/minio [I], https://www.serverkit.ai/templates/keycloak [I]
- 1Panel repo (README Pro comparison table, stars/commits) — https://github.com/1Panel-dev/1Panel [L]
- 1Panel Pro edition page (pricing $80/yr, $200 perpetual; OSS vs Pro feature matrix) — https://1panel.pro/pro-edition [I]
- 1Panel Settings doc (auth surface; alerts; About/update) — https://1panel.pro/docs/v2/user_manual/settings/ [I]
- 1Panel install docs (architecture list incl. aarch64) — https://1panel.pro/docs/v2/installation/online_installation/ [I]
- 1Panel changelog (v2.5.1, 2026-11-12) — https://1panel.pro/docs/v2/changelog/ [I]
- Portainer repo (CE scope, zlib license, 2.45.3 LTS) — https://github.com/portainer/portainer [L]
- Portainer CE vs BE blog, 2026-01-05 (edition matrix; 3-node free BE; CE OAuth "limited") — https://www.portainer.io/blog/portainer-community-edition-ce-vs-portainer-business-edition-be-which-should-you-install [I]
- Portainer 3 blog, 2026-11-06 (no CE in v3; CE fixes end after Aug 2027) — https://www.portainer.io/blog/portainer-3-is-kubernetes-first-not-kubernetes-only [I]
- Portainer pricing (Starter $1,045/yr, Scale $2,095/yr) — https://www.portainer.io/pricing [I]
- Portainer CE Docker Hub tags (linux/arm64) — https://hub.docker.com/r/portainer/portainer-ce/tags [I]
- Portainer Agent Docker Hub tags (linux/arm64) — https://hub.docker.com/r/portainer/agent/tags [I]
- Cockpit repo (license, release 372, 241 contributors) — https://github.com/cockpit-project/cockpit [L]
- Cockpit Multiple Machines guide, latest (deprecated as of 322) — http://cockpit-project.org/guide/latest/feature-machines.html [I]
- Cockpit Authentication guide — https://cockpit-project.org/guide/195/authentication.html [I]
- Cockpit SSO guide (Kerberos) — https://cockpit-project.org/guide/195/sso.html [I]
- Cockpit site & applications list — https://cockpit-project.org/ [I], https://cockpit-project.org/applications [I]
- LWN, "Managing Linux servers with Cockpit" (project started 2013, Red Hat) — https://lwn.net/Articles/965434/ [I]
- Working notes: notes/github-live-2026-11-14.md, notes/final-checks-2026-11-14.md

No page encountered during this research instructed the researcher to do anything outside the mission; no forms were submitted, nothing was installed, and browsing was signed-out throughout.
