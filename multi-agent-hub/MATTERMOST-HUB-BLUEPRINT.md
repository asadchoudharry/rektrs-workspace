# Rektrs Multi-Agent Hub — Mattermost Only (Owner decision 2026-11-14)

## Decision
- Single platform: **Mattermost Team Edition** (NOT Entry — Entry hides history after 10,000 messages; Team Edition = unlimited history, max 250 users, no SSO — fine for 3 partners + bots).
- Image pinned: `mattermost/mattermost-team-edition` (pin a release line at install, never `latest` blindly) + `postgres:16-alpine`.
- All human + agent communication in Mattermost. No Colanode.

## Host & safety (srv1322702 — shared 8GB, Dokploy, Postiz/Odoo/website live)
- Pre-install gate: `free -h`, `df -h`, `docker stats` snapshot; abort if free RAM < 2.5GB.
- Hard container limits in compose: mattermost mem_limit 1.25GB, postgres 512MB. No builds on host — pull images only.
- Unique COMPOSE_PROJECT_NAME=`rektrs-hub` (Postiz staging incident lesson: never reuse another project's name).
- Domain proposal: `hub.rektrs.com` via Dokploy/Traefik, TLS on.
- Backup: nightly pg_dump to host volume + before any upgrade.

## Dokploy compose sketch (to finalise at install)
```yaml
name: rektrs-hub
services:
  postgres:
    image: postgres:16-alpine
    environment: [POSTGRES_DB=mattermost, POSTGRES_USER=mmuser, POSTGRES_PASSWORD=<from vault>]
    volumes: [mm-postgres:/var/lib/postgresql/data]
    deploy: {resources: {limits: {memory: 512M}}}
  mattermost:
    image: mattermost/mattermost-team-edition:<pinned>
    depends_on: [postgres]
    environment:
      - MM_SQLSETTINGS_DRIVERNAME=postgres
      - MM_SQLSETTINGS_DATASOURCE=postgres://mmuser:<pw>@postgres:5432/mattermost?sslmode=disable
      - MM_SERVICESETTINGS_SITEURL=https://hub.rektrs.com
    volumes: [mm-data:/mattermost/data, mm-config:/mattermost/config, mm-logs:/mattermost/logs]
    deploy: {resources: {limits: {memory: 1280M}}}
volumes: {mm-postgres: {}, mm-data: {}, mm-config: {}, mm-logs: {}}
```

## Structure inside Mattermost
Team: `rektrs`
Channels:
- `command` — Assad's single-input channel; fan-out starts here
- `agent-lounge` — agents discuss / divide work
- `tasks` — one thread per task, status in thread (claimed / doing / done / blocked)
- `progress` — bot-posted daily digest + GitHub PR/commit events
- `decisions` — humans-only final decisions (bots read-only)
- `general` — partners' normal chat

Users: Assad (admin) + Partner 1 + Partner 2.
Bots (Bot Accounts, member role only, token per bot, tokens in Secure Vault only):
- `muse-assad` (this Muse — custom connector + scheduled poll/webhook)
- `muse-p1`, `muse-p2` (partners' Muses connect the same way from their side)
- `chatgpt` — via Assad's own logged-in ChatGPT in Muse's browser (see below) OR OpenAI API later
- `gemini` — via Assad's own logged-in Gemini in Muse's browser OR Google AI API later
- `grok` — web login (owner step, when Assad chooses) OR xAI API later
- `github-relay` — incoming webhook for Cursor PRs/commits into `progress`

## How ChatGPT / Gemini join (owner-login model)
- Assad logs into ChatGPT and Gemini HIMSELF in Muse's cloud browser (he types his own password/OTP; Muse never receives or stores them).
- Muse then drives those logged-in sessions as a bridge: reads `command`/`agent-lounge`, asks ChatGPT/Gemini, posts their answers back under their bot names.
- Honest limit: this bridge works while the browser session stays logged in and while Muse is active; it is not a 24/7 independent bot. True always-on = API keys later (paid, per use) — upgrade path kept open, same bot accounts reused.

## Fan-out protocol (single input)
1. Assad posts in `command` (or in the command app): e.g. `@all <sawal/task>` or `@chatgpt @gemini <sawal>`.
2. Coordinator (muse-assad) splits work, posts assignments in `tasks` threads, pings the right bots.
3. Each agent replies in the same thread; coordinator posts one merged summary in `command` + updates `progress`.
4. No agent merges code / spends / messages outsiders without its own human owner's approval.

## Command app (Phase 2, after hub is live)
- Thin web app (PWA, installable on Assad's phone) over the Mattermost API: one input box, agent picker (All / select), answers side-by-side, progress board fed from `tasks` threads + GitHub.
- Mattermost's own mobile/desktop apps are used until then — no waiting.

## Phases
- P0: host check + Dokploy install + admin/team/channels (Muse)
- P1: bots + Muse connector live; Assad logs in ChatGPT/Gemini himself; first @all test
- P2: partners onboard (their Muses connect), GitHub relay for Cursor
- P3: command app PWA

## Open owner inputs
- Partners' names/emails for invites
- Subdomain confirm: hub.rektrs.com
- Grok: web login now or later?
