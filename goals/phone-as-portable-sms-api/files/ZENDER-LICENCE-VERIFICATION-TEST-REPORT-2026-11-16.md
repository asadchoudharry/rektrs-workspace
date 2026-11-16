# ZENDER LICENCE VERIFICATION TEST — REPORT (2026-11-16)

Owner question (2026-11-16 ~15:11 PKT): *"Sendqon main koi esa feature
hy jo Vendor say connected ho or wo jab chahy disconnect ker sakta
hoo"* — is any part of Sendqon connected to the vendor (Titan
Systems) in a way that lets the vendor cut us off at will?

This test resolves **Open UNVERIFIED item #1** of the rebuild roadmap
(`zender-rebuild-tree/08-REBUILD-ROADMAP.md`). Method: live
observation only — packet captures, firewall block tests, isolated
cold starts on our own install. Nothing was decompiled.

## VERDICT

**Offline after a one-time online activation. The vendor holds NO
kill switch over this install.**

- **First-ever start** (empty companion storage): the binary contacts
  the vendor licence portal — **`api.titansys.dev`** — once, validates
  the licence code, and stores the result locally:
  `work/storage/license.token` (640 B SMPP / 685 B WhatsApp), bound to
  `work/storage/machine.id`. This happened once, at our first start
  2026-11-16 09:21:51 UTC.
- **Every later start** verifies the **stored** token **locally** —
  proven with the SMPP container's entire non-local network egress
  dropped by firewall: it still verified in 2 milliseconds.
- **No periodic re-verification exists.** Across full startup
  captures, a dedicated 12-minute token/network watch, and the
  complete log history, neither binary ever contacts the portal
  again. The WhatsApp binary rewrites its token file every 120 s —
  a purely local re-seal (zero DNS, zero new connections at those
  moments).
- **Practical meaning:** if the vendor's portal dies tomorrow, or
  the vendor turns hostile and refuses us, **nothing changes here** —
  running servers keep running, restarts keep verifying. The only
  portal-dependent moment is a **from-scratch activation**: a fresh
  install, or a companion whose `work/storage` was wiped. Both
  `license.token` + `machine.id` files are already inside the
  nightly config backup (`sendqon-config-2026-11-16.tar.gz` verified
  to contain all four files), so a server restore keeps the
  activation.

## Evidence

### Baseline (2026-11-16 ~10:11 UTC)
All 7 containers Up; app-side `service_servers`: Primary WhatsApp
**healthy**, smpp-1 **healthy**; both rows `license_state=licensed`.
Companion IPs: whatsapp 172.19.0.7, smpp 172.19.0.8 (network
`sendqon_default`, bridge `br-dcdd5c004431`).

### Log wording + timing (the first tell)
| Event | Log line | Delay after start line |
|---|---|---|
| First start, both binaries, 09:21:51 | `license verified … outcome=licensed` | ~0.4 s |
| SMPP restart, 10:13:32 | **`stored license verified`** | **+0.002 s** |
| WhatsApp restart, 10:15:41 | **`stored license verified`** | **+0.010 s** |

A WAN round-trip cannot complete in 2–10 ms; the word "stored" is
the binary's own description. WhatsApp verified *before* its first
outbound fetch of any kind. `license.token` mtimes match the story:
SMPP's token was written at 09:21:51.535 (the first-start
millisecond) and never modified again.

### Startup network captures (tcpdump, 115 s per restart)
- **SMPP** opened exactly 2 outbound connections, both to Cloudflare
  IPs of **sendqon.rektrs.com:443** (172.67.204.161, 104.21.85.108) —
  our own app (bootstrap + Reverb). No UDP.
- **WhatsApp** connected only to the same Cloudflare IPs (ours) and
  **57.144.203.32:443** (Meta — `web.whatsapp.com`, its linked
  account traffic). No UDP.
- Host-side DNS capture in both windows: **no vendor domain queried
  at all** (only web.whatsapp.com + Oracle host telemetry noise).

### Hard block test (SMPP, the decisive experiment)
Rules added to `DOCKER-USER` (recorded verbatim; removed after):
`RETURN -s 172.19.0.8 -d 172.19.0.0/16`, then
`DROP -s 172.19.0.8` (all other egress). Block on 10:18:22 UTC.
SMPP restarted under the block:

```
10:18:23.254  zender-smpp starting (version=5.0.4)
10:18:23.256  "stored license verified" license_id=… outcome=licensed
10:18:38.272  bootstrap failed, retrying in 2s (our own public URL
              unreachable — that path was cut too, by design)
```

Licence: **passed with zero external network**. The only failures
were bootstrap retries to *our own* URL. Rules removed 10:21:06 UTC;
both companions restarted; end state = baseline (both healthy,
`license_state=licensed`, main app stack never restarted).
Note: the block window was ~3 minutes rather than the planned ~10 —
the monitoring session's completion signal proved unreliable, so the
rules were removed manually instead of being left unattended. This
does not weaken the result: verification is a start-time event and
it passed at +2 ms under a total block; the running-server question
is covered by the captures, log history and watch below.

### Isolated cold starts (what a fresh install does)
Each binary was run alone with `--network none`, an **empty**
workdir and a copy of its real config (copies shredded afterwards):

```
SMPP:     "license portal unavailable" outcome=retrying state=unlicensed
WhatsApp: "license portal unavailable" outcome=retrying state=unlicensed
```

Both created a fresh `storage/machine.id` and kept retrying — no
stored token, no licence. A follow-up probe (fresh container,
egress dropped at the firewall but DNS visible) showed the binary
resolving **`api.titansys.dev`** (A + AAAA) — the one and only
vendor endpoint; every SYN was dropped, so no activation exchange
took place during the probe.

### Token watch (12 min, 30 s sampling + capture)
WhatsApp `license.token` rewrites at **exactly 120 s intervals**
(mtimes at :07 past each even minute); SMPP's token is never
touched. During the watch: **0** `titansys` DNS queries; the only
new connections either companion opened were the per-minute
health/Reverb connections to our own domain (10:31:07–08). The
120 s rewrite is a local re-seal, **not** a phone-home.

### Log history
Each binary's complete logs contain exactly **one licence line per
start** — no re-checks across ~1 h 15 min of runtime, including a
live paired WhatsApp session.

### App side
The Laravel app polls each companion's internal health endpoint
every minute (`wa:health-check`, `smpp:servers-health`) and records
the binary-reported `license_state` — a read, not a vendor channel.

## Side-check: `android:app-updates`
`CheckGatewayAppUpdatesCommand` (runs every 15 min) and the three
services it calls (`GatewayAppUpdateAlerts`,
`PhoneBridgeAppUpdateAlerts`, `TelephonyAppVersions`) contain **no
external URL, no HTTP call, no vendor reference**. Required-version
data comes from local plugin config and the local `system_settings`
table (`app_required_published_*` keys); the command only compares
versions, moves waiting messages and alerts device owners. Entirely
local — not a vendor connection.

## Caveats
- "No periodic re-check" is proven for the observed windows (~1 h
  15 min of logs + two startup captures + a 12-min watch). An
  interval longer than that cannot be excluded by observation
  alone — but there is no mechanism for one: outside activation the
  binaries never resolve or contact the portal (cold cache in the
  probe proved the name is only looked up when a token is missing),
  and the stored token verifies with the network fully down.
- The **Telephony** binary (not installed on this host) was not
  tested; same licence family, expected identical — UNVERIFIED for
  telephony specifically.
- Rule for operations: **never wipe a companion's `work/` dir**
  casually — a wiped storage means a fresh activation (portal +
  valid code needed, once). The files are small and already backed
  up nightly.

## State after the test
Both companions Up, **healthy**, `license_state=licensed`; all test
firewall rules removed (`DOCKER-USER` holds only its pre-existing
metadata rule); the 5 main app containers were never restarted.
