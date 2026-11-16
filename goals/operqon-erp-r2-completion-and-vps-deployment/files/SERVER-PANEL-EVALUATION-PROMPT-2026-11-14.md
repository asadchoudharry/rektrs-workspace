# Server Panel Evaluation — Prompt for ChatGPT / Gemini

**How to use (Assad):** copy everything between the two `===` lines below and paste it as one message into ChatGPT and into Gemini. Both will be asked for the same structure Muse is using, so the three reports can be compared side by side. Send their replies back here; the decision will be made on all three sets of findings together.

===

You are a senior platform architect and SaaS infrastructure advisor. I need an independent, evidence-based evaluation. Browse and verify the two open-source projects yourself from their GitHub repositories and documentation — do not rely only on what I state below, and clearly flag anything you could not verify.

## Who we are and what we run today

We operate **Operqon**, a multi-tenant ERP SaaS (company: Rektrs (Private) Limited, Pakistan). Tenants pay a monthly per-user subscription. Current production architecture:

- **Tenant engine:** Frappe / ERPNext running in Docker (frappe_docker-style Compose stacks — backend, frontend, websocket, queue workers, scheduler, MariaDB, Redis). One shared bench stack currently serves multiple tenant sites; more servers are planned as tenants grow.
- **Provider control plane (built by us):** a provider console + customer portal (static HTML/CSS/vanilla JS frontends) backed by our own Python provider API and PostgreSQL. It handles: tenant lifecycle, subscriptions, billing and invoices, manual bank-transfer payment verification with a two-person approval rule (maker–checker separation of duties), governed pricing changes (whole-proposal approval), provisioning jobs with retry/failure resolution workflows, payment-gateway settings, backups, and an in-console "Issues" inbox so our admin team can resolve operational problems without engineering help.
- **Identity:** Keycloak (OIDC) is our single identity provider — separate realms for provider staff and for customers. One login across our surfaces is a hard requirement.
- **Edge:** Caddy is our standard public reverse proxy / TLS edge on all servers.
- **Hosting:** Linux VPS servers (Docker everywhere). One production VPS today, growth to a small fleet expected.
- **Live business:** real paying tenants are live on this stack today. Any adoption must not endanger running tenants.

## What we want

A single management dashboard for the whole ecosystem: server/infrastructure management **and** our Operqon provider console in one panel, under our own brand (white-labelled as Operqon), with minimum custom development. We are evaluating two open-source panels as the chassis:

1. **ServerKit** — https://github.com/jhd3197/ServerKit
2. **VortexPanel** — https://github.com/BrowserlessAPI/VortexPanel

## Things we believe we have verified (check us on these)

- Both are MIT-licensed. ServerKit: Python/Flask backend + React frontend, multi-server via a Go agent, auth includes OIDC / SAML 2.0 / OAuth 2.0 / WebAuthn, Docker-centric (app templates, services, databases), a built-in White Label settings tab and themes API, per-server reverse-proxy stacks (host Nginx default, or Dockerised Traefik or Caddy), blue/green self-update with rollback, and a formal **extension (plugin) system** documented in `docs/EXTENSIONS.md` (plugin.json manifest, backend Flask blueprints hot-loaded, plugin-owned tables prefixed `ext_<slug>_`, lifecycle hooks, UI contributions for nav/routes/widgets, runtime delivery of prebuilt frontend ESM bundles, install straight from GitHub, version-compatibility gates).
- VortexPanel: Python/Flask + Alpine.js, cPanel-style **single-server** hosting panel (websites on Nginx/Apache/OpenLiteSpeed/Caddy, ModSecurity WAF, Fail2Ban, cloud backups, Docker UI), **no OIDC/SSO and no multi-server support** that we could find.

## Questions your report must answer

1. **Verdict:** Which panel (if either) should become the chassis for our single white-labelled Operqon panel — and why, in evidence, not preference?
2. **White-label depth:** How completely can each be rebranded (name, logo, theme, login screens, domains, emails)? What would still betray the original product?
3. **Updates vs customisation:** If we adopt and customise, do upstream updates keep flowing? Analyse each project's actual update mechanism and what breaks it. Compare three strategies and recommend one:
   - (a) configure-only (white-label settings + SSO) with zero code changes,
   - (b) build our provider features as an official **extension/module** of the panel (for ServerKit, judge its extension system seriously: backend, own tables, UI routes/widgets, runtime frontend bundles, compatibility gates),
   - (c) hard fork and fully make it our own codebase.
   For the recommended strategy, state concretely how an upstream release would be absorbed by us, step by step.
4. **Impact on Frappe/ERPNext:** Our tenant benches are Docker Compose stacks fronted by Caddy with WebSocket and background-job services. What happens if this panel (and its agent) manages the same servers? Cover: proxy/port ownership conflicts, the panel creating or altering Docker resources, its backup system vs ours, agent privileges (root / Docker socket), resource overhead, and how bench updates and rollbacks would work. What must we pilot-test before trusting it near production benches?
5. **Impact on the rest of our stack:** Keycloak SSO integration depth, our existing console/portal (keep, link, or rebuild as modules?), and our provider database and audit/governance model (maker–checker approvals, immutable audit) — can that governance live inside the panel's permission model?
6. **Future applications:** We will add more products on the same fleet: a multi-tenant school ERP+LMS (Laravel + React + PostgreSQL row-level security, deployed via Docker/Dokploy today), a social-media product (also Docker/Dokploy), plus smaller services. Which panel serves as the fleet-wide infrastructure layer for all of this, and where does each panel stop being useful?
7. **Risks:** project health and bus factor, security posture of giving a panel/agent control of production servers, lock-in and exit cost, hidden maintenance burden. Be specific to these two projects' actual state (release cadence, contributor base, code structure).
8. **Adoption plan:** a phased plan (pilot → white-label → SSO → our modules → fleet) with what is verified at each phase before moving on, and an honest effort estimate per phase for a small team.

## Required output format

- Start with a one-paragraph executive verdict.
- Then a scoring table, 1–5 per criterion, for each panel, with one line of evidence per score: SSO/identity fit · Docker & Frappe/ERPNext fit · extensibility & module system · updatability after customisation · white-label depth · multi-server/fleet future · security posture · project health · adoption effort (5 = least effort).
- Then answers to questions 1–8 in order, citing repository files/docs where a claim depends on them.
- End with: your recommended strategy, the top 5 risks with mitigations, and a pilot checklist of exactly what to test before any production use.
- If a feature or claim cannot be verified from the repository or docs, say so explicitly instead of guessing.

===
