# Operqon Consolidated Platform Adoption Report

## Executive Summary

ServerKit (jhd3197/ServerKit) is the recommended infrastructure and internal operations chassis for Operqon via an official extension (operqon-ops), while your existing Python provider API, PostgreSQL governance ledger, and customer portal must remain the system of record. The decisive ServerKit differentiators are multi-server Go agent (jhd3197/serverkit-agent), single-realm Keycloak staff OIDC, blue/green self-updates, and a formal extension runtime (docs/EXTENSIONS.md), whereas VortexPanel lacks OIDC, multi-server support, and white-labeling. At the same time, ServerKit's single-worker Gunicorn (-w 1 --threads N), single-realm OIDC limit, flat 4-role RBAC, mutable audit_logs table, and localStorage-only white-label persistence mean it cannot safely host customer-facing portals, two-person maker–checker approvals, or governed pricing. The operqon-ops extension acts as the unified staff management home on a dedicated ops node (or isolated port 127.0.0.1:5000), your PostgreSQL provider API remains the system of record for billing, maker–checker verification, and audit, and all future products are absorbed as Provisioning Domains with their own Keycloak clients and frappe_docker tenant benches.

## 1. Consolidated Architecture & Prior-Research Reconciliation

### Reconciliation with Prior Two Chats

- **Chassis Decision (Chat 1 — Operqon Infrastructure Chassis Evaluation):** Reaffirmed. Adopt ServerKit under strict Topology B: SERVERKIT_EXTERNAL_PROXY=1, no Traefik/Caddy ownership, agent at --level=monitor on live hosts, and operqon-ops as a third-party extension (plugin.json + ESM) so core remains untouched and serverkit update flows.
- **Component Stack (Chat 2 — Operqon SaaS Component Adoption Analysis):** Reconciled with the expanded candidate list and verified licences below. Key corrections vs. Chat 2:
  - **PDF Generation:** Chat 2 did not evaluate PDF engines; Gotenberg (gotenberg/gotenberg, MIT) wins for HTML/Markdown/Office-to-PDF sidecar rendering, with WeasyPrint (Kozea/WeasyPrint, BSD) as an optional in-process Python fallback.
  - **Billing Engine:** Chat 2 compared getlago/lago (AGPL-3.0) and killbill/killbill (Apache-2.0). Re-verification confirms Kill Bill gates Aviate Coupons, metering, and tax rates behind its paid enterprise tier ($9,999/mo), leaving only a coupon demo in OSS. Because Kill Bill also adds JVM/OSGi weight for a Python team and lacks Pakistan gateways, keep your existing Python billing + procrastinate for dunning retries) rather than adopting Kill Bill or AGPL-3.0 lago right now.
  - **Backups:** Chat 2 recommended pgbackrest + restic; Pluton (plutonhq/pluton, Apache-2.0) adds a clean Restic + Rclone web UI for host/non-Frappe files, while Frappe tenant backups stay with bench --site ... backup.
  - **Observability & Uptime:** Chat 2 recommended TwiN/gatus + henrygd/beszel + amir20/dozzle + glitchtip; Uptime Kuma (louislam/uptime-kuma, MIT) is an acceptable MIT alternative for uptime/status pages, whereas SigNoz (SigNoz/signoz, MIT core + commercial ee/LICENSE) is too heavy (ClickHouse + OTel) for a single production VPS.
  - **Automation:** Activepieces (activepieces/activepieces, MIT CE + commercial EE) fits a JS/TS/Docker stack better than Kestra (kestra-io/kestra, Apache-2.0, Java/JVM, which also had CISA KEV CVE-2026-49869 in 2026).
  - **Audit & Compliance:** Google Trillian (google/trillian, Apache-2.0) is officially in maintenance mode (superseded by transparency-dev/tessera) and requires MySQL + gRPC; retain pgaudit + sqlalchemy-continuum + append-only PostgreSQL + S3/B2 Object Lock.
  - **Frappe Print Designer:** Confirmed archived on Oct 13, 2026 (frappe/print_designer, AGPL-3.0); Frappe v16's built-in Print Format Editor replaces it.

### Layered Architecture & Placement

```
Internet ──▶ Host Caddy Edge (:80/:443 TLS, sole port owner on every VPS)
               ├── app.operqon.com ──▶ Customer Portal (vanilla JS) ──▶ Provider API (Python/FastAPI) ──▶ PostgreSQL (Provider DB)
               ├── ops.operqon.com ──▶ ServerKit (127.0.0.1:5000) + operqon-ops Extension ──▶ Provider API (read/write via JWT) ──▶ PostgreSQL
               ├── status.operqon.com ──▶ Uptime Kuma (public status)        ├── docs.operqon.com ──▶ BookStack (KB)
               └── api.operqon.com ──▶ Provider API (tenant lifecycle, billing, provisioning jobs)
ServerKit Fleet Telemetry (read-only): serverkit-agent --level=monitor on Frappe VPS (CPU/RAM/disk/Docker) + Dokploy/Postiz VPS
Sidecars (Ops VPS, isolated Compose): Gotenberg (PDF), Flagsmith, Apprise, Uptime Kuma, Beszel/Dozzle/GlitchTip, Pluton/pgBackRest, Activepieces, Superset (optional)
Identity: Keycloak — Staff Realm (ServerKit SSO, operqon-ops, sidecars via oauth2-proxy) · Customer Realm (Customer Portal only; never ServerKit)
Tenants: frappe_docker Compose benches (ERPNext v16 + hrms/helpdesk/crm/insights/lms/webshop/payments/builder/wiki + xpos + FBR app) — provisioned by Provider API + bench CLI; never managed by ServerKit's Docker UI.
```

- **What is the chassis:** ServerKit (127.0.0.1:5000, Topology B behind Caddy) for infrastructure telemetry, container visibility, and the unified staff UI via the operqon-ops extension.
- **What stays ours:** Python Provider API + PostgreSQL (tenant lifecycle, subscriptions/invoices, two-person maker-checker, governed pricing) + Keycloak (staff/customer realms) + frappe_docker Compose benches + bench CLI provisioning/backups.
- **What is adopted per need:** See the Adoption Register below.

## 2. Adoption Register

| Need | Adopted Project | Licence (Verified) | Why It Wins | Integration Shape | What Build It Cancels |
|---|---|---|---|---|---|
| Chassis & Fleet Ops | jhd3197/ServerKit + serverkit-agent | MIT | Python/Flask + React stack match; Go multi-server agent; OIDC/PKCE; formal extension SDK; blue/green self-updates. | Host/Docker behind Caddy (SERVERKIT_EXTERNAL_PROXY=1); operqon-ops extension. | Custom multi-server telemetry UI, Docker inspector, & staff ops shell. |
| Subscription Billing & Dunning | Keep Ours (reject Kill Bill / Lago) | Ours (Proprietary) | Kill Bill (Apache-2.0) gates coupons/metering to $9,999/mo Aviate & adds JVM/OSGi; Lago is AGPL-3.0 + ClickHouse. | Existing Python Provider API + PostgreSQL + procrastinate (MIT) for dunning retries. | Cancels adopting/operating a heavy JVM or ClickHouse billing engine. |
| PDF Generation | gotenberg/gotenberg (alt: WeasyPrint) | MIT (WeasyPrint: BSD) | Stateless Docker HTTP API converts HTML/CSS/Markdown to PDF cleanly; avoids Python C-lib (cairo / pango) dependency drift. | Docker sidecar on internal network called by Provider API. | Custom Chromium/wkhtmltopdf PDF worker scripts. |
| Revenue / MRR Analytics | apache/superset (or SQL views in operqon-ops) | Apache-2.0 (Flagged) | Connects directly to read-only PostgreSQL replica for MRR/churn/cohort dashboards; mature OIDC support. | Isolated Docker sidecar behind Caddy + Keycloak staff realm (optional Phase 5). | Custom BI chart/export builder for internal finance. |
| Feature Flags & Rollouts | Flagsmith/flagsmith | BSD-3-Clause (Flagged; Open-Core EE) | Runs on PostgreSQL; per-tenant segments, percentage rollouts, and kill switches with Python/React SDKs. | Docker sidecar behind oauth2-proxy + Keycloak staff realm. | Custom feature-flag tables, evaluation logic, & toggle UI. |
| Notification Delivery | caronc/apprise | BSD-2-Clause (Flagged) | Single Python library/API supporting 100+ SMS, email, WhatsApp-webhook, Slack, & Telegram channels. | Python library inside Provider API (or apprise-api sidecar). | Per-channel transport SDK wrappers. |
| Notification Templating | resend/react-email (skip Novu initially) | MIT (Novu: MIT + Commercial EE) | Novu adds Node + MongoDB + Redis + open-core EE split; react-email compiles clean responsive templates with zero runtime DB. | Build-time template compilation + Jinja/Python variable injection. | Hand-coded table-based HTML email templates. |
| Transactional Mail | External SMTP Relay (alt: postalserver/postal) | MIT (Postal) | VPS port-25 blocks & IP reputation warm-up risk transactional deliverability; use Postal only on a dedicated IP. | SMTP/HTTP API via Connections Hub / Provider API. | Custom bounce/DKIM/SPF mail-server wiring. |
| Uptime & Public Status | louislam/uptime-kuma (or TwiN/gatus) | MIT (Gatus: Apache-2.0) | Uptime Kuma is MIT with 90+ alert hooks & built-in public status pages; Gatus is better if GitOps/PostgreSQL-first. | Isolated Docker sidecar behind Caddy (status.operqon.com). | Custom HTTP/TLS/TCP health prober & status page. |
| Observability (Metrics/Logs/Traces) | henrygd/beszel + amir20/dozzle + GlitchTip (reject SigNoz) | MIT | SigNoz (MIT core + commercial ee/LICENSE) requires ClickHouse + OTel Collector; Beszel + Dozzle + GlitchTip fit a lean VPS. | Sidecars on Ops node behind Caddy + Keycloak OIDC (oauth2-proxy). | Custom container log viewer, host metric scraper, & error tracker. |
| Documentation / Help Centre | BookStackApp/BookStack (or frappe/wiki) | MIT | BookStack offers native Keycloak OIDC, shelf/book RBAC, & clean public/internal KB; Frappe Wiki is MIT if you want zero new DB. | Docker sidecar (uses MariaDB) behind Caddy (docs.operqon.com). | Custom markdown CMS, search, & RBAC docs portal. |
| Backup Management UI | plutonhq/pluton + pgbackrest | Apache-2.0 (Pluton) / MIT (pgBackRest) | Pluton wraps Restic + 70+ Rclone targets (S3/B2) in a modern UI; pgBackRest handles PostgreSQL WAL/PITR (not bench backup). | Pluton sidecar for host/non-Frappe volumes; pgBackRest for Postgres. | Custom Restic/Rclone cron scripts & backup dashboard. |
| Workflow Automation | activepieces/activepieces (reject Kestra) | MIT (CE; Commercial EE) | TypeScript/Docker stack fits team; Kestra (Apache-2.0) is heavy JVM & suffered CISA KEV CVE-2026-49869 in 2026. | Isolated Docker sidecar for internal webhook/API orchestration. | Custom glue scripts for internal ops workflows. |
| Verifiable Audit Log | Keep Ours + pgaudit + S3/B2 Object Lock (reject Trillian) | PostgreSQL License | Trillian (Apache-2.0) is in maintenance mode (superseded by Tessera) & needs MySQL/gRPC. Hash-chained append-only PG + pgaudit is leaner and native. | Append-only PG table (trigger-protected) + periodic hash-anchored S3 export. | Heavy gRPC Merkle-tree server maintenance. |
| Tenant ERP Apps (Official) | hrms, helpdesk, crm, insights, lms, webshop, payments, builder, wiki | GPL-3.0 (hrms, webshop) · AGPL-3.0 (helpdesk, crm, insights, lms) · MIT (payments, builder, wiki) | Official Frappe v16 apps; Print Designer (frappe/print_designer) is archived—use Frappe v16's built-in Print Format Editor. | Installed unmodified inside frappe_docker bench images; provider platform talks only over HTTPS APIs. | Building HR, Payroll, Helpdesk, CRM, BI, LMS, or e-commerce from scratch. |
| Tenant POS (v16-native) | kodlyft/xpos | MIT | Built for ERPNext v16; offline-first PWA + Android Capacitor app, thermal ESC/POS, mixed-currency PKR/USD, and split payments. | Installed as Frappe app on tenant bench image. | Building an offline-capable v16 POS. |
| Pakistan FBR Invoicing | UniVenture-Solutions/fbr_digital_invoicing (note: SpotLedger/pakistan_tax UNVERIFIED) | MIT | SpotLedger/pakistan_tax could not be located on GitHub (UNVERIFIED); fbr_digital_invoicing is MIT (4 stars, 0 releases, v16 compatibility UNVERIFIED). | Evaluate/fork MIT reference into a dedicated Operqon FBR Frappe app. | Starting FBR QR/JSON schema mapping from zero. |

**GPL / AGPL Practical Consequence for Operqon:** Because Operqon's provider control plane (Python + PostgreSQL) and tenant ERPNext benches interact with GPL/AGPL-licensed Frappe apps only via network APIs, and because you run the Frappe apps inside their own frappe_docker instances strictly over HTTPS REST/RPC APIs, installing unmodified GPL-3.0 (hrms, webshop) or AGPL-3.0 (helpdesk, crm, insights, lms) apps inside tenant benches does not trigger copyleft disclosure on your proprietary provider control plane or customer portal. Avoid modifying those apps in-place; fork only when you must, and keep proprietary code out of the AGPL/GPL apps themselves.

## 3. Coverage Map (Every Need Accounted For)

| Need | Mapping | Target Component / Owner | Notes / Gaps |
|---|---|---|---|
| Tenant lifecycle & oversight | Already-ours + Extension | Provider API/PG + operqon-ops extension | UI surfaced in ServerKit sidebar; state stays in Provider PG. |
| Subscriptions, invoices, trials, dunning | Already-ours + Still-to-build | Provider API/PG + procrastinate worker | Keep ours; add procrastinate for dunning retry schedules; coupons still-to-build if needed. |
| Payment verification (maker–checker) | Already-ours | Provider API/PG + operqon-ops UI | Must never rely on ServerKit RBAC; enforced in Provider API. |
| Governed pricing (whole-proposal) | Already-ours | Provider API/PG + operqon-ops UI | Whole-proposal approval stays in Provider PG. |
| Provisioning jobs & failure resolution | Already-ours + Adopted service | Provider API + procrastinate | Idempotent bench job states & retries in Provider PG. |
| Payment-gateway settings (write-only → masked) | Already-ours | Provider API/PG | Do not store tenant/provider gateway secrets in ServerKit's config_schema. |
| Issues inbox for admin team | Already-ours + Extension | Provider API/PG + operqon-ops UI | Surfaced inside ServerKit as a custom route/tab. |
| Servers, benches, backups/restore, domains | Chassis + Already-ours | ServerKit (servers/Docker) + Provider API (benches) | ServerKit monitors hosts/containers; bench lifecycle & Caddy routes stay ours. |
| Platform settings & danger-zone actions | Chassis + Already-ours | ServerKit (host) + Provider API (tenant danger zone) | Tenant suspend/delete gated by Provider API maker–checker. |
| Identity administration | Already-ours | Keycloak (Staff + Customer realms) | ServerKit connects to Staff realm only; Keycloak Admin Console handles realm admin. |
| Feature flags & staged rollout | Adopted service | Flagsmith (BSD-3-Clause) | Docker sidecar on Ops node; SDKs in Provider API & portals. |
| Notifications (email/SMS/WhatsApp templating + delivery) | Adopted service + Still-to-build | react-email (MIT) + apprise (BSD-2) | Local Pakistan SMS/WhatsApp provider adapter still-to-build or via apprise custom webhook. |
| Transactional mail | Adopted service | External SMTP Relay (or Postal MIT on dedicated IP) | Avoid sending transactional mail from the live Frappe VPS IP. |
| Uptime monitoring + public status page | Adopted service | Uptime Kuma (MIT) or Gatus (Apache-2.0) | Independent sidecar; public status page at status.operqon.com. |
| Metrics/logs/traces observability | Adopted service | Beszel + Dozzle + GlitchTip (all MIT) | Lightweight stack; full distributed OTel tracing is an accepted gap until fleet grows. |
| Revenue/MRR analytics | Adopted service / Still-to-build | Apache Superset (Apache-2.0) or operqon-ops charts | Superset reads PG replica; or render MRR widgets directly in operqon-ops. |
| PDF generation (invoices/receipts) | Adopted service | Gotenberg (MIT) | Stateless Docker sidecar called by Provider API. |
| Documentation / help centre | Adopted service | BookStack (MIT) or Frappe Wiki (MIT) | BookStack supports Keycloak OIDC natively. |
| Backup management | Adopted service + Already-ours | Pluton (Apache-2.0) + pgBackRest (MIT) + bench backup | Pluton for host/non-Frappe; bench for Frappe sites. |
| Workflow automation | Adopted service | Activepieces (MIT CE) | Internal ops automation only (no tenant-facing multi-tenant EE). |
| Internal admin tooling | Chassis + Extension | ServerKit + operqon-ops (plugin.json + ESM) | Unified staff entry point. |
| Tamper-evident audit | Already-ours + Adopted service | Provider PG + pgaudit + S3/B2 Object Lock | Append-only DB triggers + cryptographic hash chain + WORM storage. |
| Tenant HR & payroll | Adopted service (Tenant app) | frappe/hrms (GPL-3.0) | Unmodified on bench; Pakistan payroll localisation is an accepted gap / still-to-build. |
| Tenant helpdesk, CRM, BI, LMS, e-commerce | Adopted service (Tenant apps) | helpdesk, crm, insights, lms (AGPL-3.0); webshop (GPL-3.0) | Install unmodified on bench images; no proprietary code inside these apps. |
| Tenant print-format design | Already-ours (Frappe v16) | Frappe v16 built-in Print Format Editor | Replaces archived frappe/print_designer. |
| Tenant POS (modern, offline-capable) | Adopted service (Tenant app) | kodlyft/xpos (MIT) | v16-native offline PWA + Android app. |
| Tenant payment gateways & PK gateways | Adopted service + Accepted gap | frappe/payments (MIT, Stripe) + custom PK adapters | Production-grade Easypaisa/JazzCash/PayFast Python SDKs confirmed absent (accepted gap / still-to-build). |
| Pakistan FBR digital invoicing & payroll rules | Still-to-build / Accepted gap | fbr_digital_invoicing (MIT reference) + custom app | SpotLedger/pakistan_tax UNVERIFIED; Pakistan payroll rules absent (accepted gap / still-to-build). |

## 4. Deep-Dive Answers (Questions 2, 5, 6, 7, 8)

### Question 2: ServerKit Specifically (Branding, Extensions, & Agent Boundaries)

**White-Label Depth:** ServerKit's DB-backed Themes API (GET /api/v1/themes/public/active) persists custom CSS variables (accent colors, light/dark tokens) before login. However, our prior inspection of WhiteLabelTab.jsx and Login.jsx showed that brandName and logoData save only to browser localStorage, Login.jsx hardcodes <ServerKitLogo />, and frontend/index.html hardcodes <title>Control Panel</title>. Email template white-labeling in backend mailers is UNVERIFIED. Mitigation: Enable sso_force_sso so staff redirect straight to your branded Keycloak login screen, never seeing ServerKit's login page.

**Keeping Upstream Updates Flowing with operqon-ops:** Build your provider UI as a third-party extension (docs/EXTENSIONS.md) shipping plugin.json + a prebuilt ESM bundle (dist/index.mjs verified by SHA-256 and sdk_version semver) + a hot-loaded Flask blueprint. Because scripts/update.sh runs preserve_installed_plugins() across blue/green slots (/opt/serverkit-a ↔ /opt/serverkit-b), upstream updates flow without touching your extension. Docker caveat: If ServerKit runs in Docker, bind-mount your extension into frontend/src/plugins and set SERVERKIT_FRONTEND_PLUGINS_DIR.

**What Must NEVER Go Inside the Extension:**

- **Maker–checker approvals, governed pricing state, or financial ledgers:** ServerKit's native RBAC has only 4 flat roles (viewer, member, admin, owner), and extension permissions in plugin.json are consent labels, not a sandbox (docker, shell, filesystem, network, db are unmediated per docs/EXTENSIONS.md). Keep all governance in your PostgreSQL Provider API; the extension should only be a thin UI calling that API.
- **Database migrations:** Extensions use db.create_all(), not Alembic—never store business-critical tables in ServerKit's DB.
- **Payment gateway secrets:** Keep write-only → encrypted → masked gateway settings in your Provider API, never in ServerKit's config_schema.

**Agent Boundaries on Live Frappe Hosts:** Per docs/EXTENSIONS.md, agent.command:<action> is the only SDK-mediated capability. Note that docs/AGENT_PERMISSION_LEVELS.md could not be fetched directly in this session (exact command-tier matrix for Monitor / Protect / Full is UNVERIFIED). scripts/install.sh defaults LEVEL=full if --level is omitted and adds the agent to the docker group.

- **Safe on live Frappe hosts:** --level=monitor (read-only CPU/RAM/disk/network telemetry, container health/status inspection, log tailing).
- **Forbidden on live Frappe hosts:** Letting ServerKit or its agent edit Caddy/Nginx configs, run docker compose up/down/pull on frappe_docker stacks, trigger backups/restores, or run arbitrary host shell commands.

### Question 5: Load Protection (Guaranteeing Zero Harm to Production Tenants)

- **Strict Topology B Edge Isolation:** Run ServerKit with SERVERKIT_EXTERNAL_PROXY=1 and SERVERKIT_PUBLIC_URL=https://ops.operqon.com bound to 127.0.0.1:5000 (or better, on a separate Ops VPS). Never enable ServerKit's Dockerized Traefik or Caddy stacks, which hardcode 80:80 and 443:443 and would collide with your live Caddy edge.
- **Resource Budgets (cgroups / Docker Compose):** If any component is co-located, enforce explicit mem_limit and cpus reservations in Compose so sidecars (Gotenberg, Uptime Kuma, Beszel) cannot starve MariaDB, Redis, or Frappe workers.
- **Read-Only Agent Posture:** Install serverkit-agent on the live Frappe VPS strictly with --level=monitor and firewall its outbound connection to the Ops VPS only.
- **Update Discipline:** Never run serverkit update unattended on a host touching production. Pin tested release tags (SERVERKIT_VERSION=vX.Y.Z), test serverkit update + rollback on staging first, and keep frappe_docker digest-pinned updates completely decoupled.
- **100% Reversibility:** Because ServerKit, its agent, and all sidecars use zero shared databases or Caddy files with the live frappe_docker stack, removing ServerKit is a single systemctl stop serverkit-agent + deleting one Caddy reverse-proxy block—zero tenant downtime.

### Question 6: Future Integration (School ERP+LMS, Postiz on Dokploy, RAG, & One-Owner-Per-Host)

**The One-Owner-Per-Host Rule for Docker Panels:** Never run two Docker-orchestrating control planes in which one can redeploy the other's containers. For a host running Dokploy, the recommended approach is to keep Dokploy as the sole owner of its Compose stacks and run only serverkit-agent --level=monitor there for unified fleet telemetry, alerting, and log viewing—never trigger Compose redeploys from ServerKit's UI.

**Absorbing Future Products Without Merging Data or Governance:**

- **School ERP+LMS (Laravel/React/PostgreSQL RLS) & Postiz:** Register each product as its own Provisioning Domain in the Provider API (with its own tenants, plans, and procrastinate queues) and its own Keycloak Client / Realm. Surface their operational queues and health inside dedicated tabs of the operqon-ops ServerKit extension.
- **RAG Service & Small Services:** Deploy as isolated Docker Compose stacks on the Ops or App VPS behind Caddy + oauth2-proxy, monitored via ServerKit's fleet view and Uptime Kuma/Beszel. Each product keeps its own PostgreSQL database and Keycloak Client; shared governance (billing, audit, feature flags) is provided by the Provider API, never by ServerKit.

### Question 7: Phased Rollout & Verification Gates

| Phase | Scope | Gate Evidence Required to Advance |
|---|---|---|
| Phase 0: Throwaway Pilot | Spin up staging VPS with Caddy + dummy frappe_docker bench + ServerKit (SERVERKIT_EXTERNAL_PROXY=1) + serverkit-agent --level=monitor. | Zero port 80/443 conflicts; serverkit update + rollback pass; dummy Frappe WebSocket & workers stay healthy; bench backup unaffected. |
| Phase 1: Ops VPS + SSO + Branding | Deploy ServerKit on dedicated Ops VPS; wire Keycloak Staff Realm (OIDC + PKCE + sso_force_sso); apply Operqon theme via Themes API. | Staff log in with one Keycloak session; Customer Realm users are rejected; no ServerKit login screen is shown. |
| Phase 2: operqon-ops Extension | Package Provider Console views (tenant list, maker–checker queue, Issues inbox) as dist/index.mjs + Flask blueprint calling Provider API. | Extension hot-loads, authenticates via staff JWT, enforces maker–checker in Provider PG, and survives serverkit update. |
| Phase 3: Core Sidecars | Deploy Gotenberg (PDF), Flagsmith (Flags), Uptime Kuma (Status), Beszel + Dozzle + GlitchTip, and BookStack (Docs). | PDF invoices render; status page monitors live endpoints; staff access all tools via Keycloak SSO. |
| Phase 4: Fleet Rollout | Enroll live Frappe VPS and Dokploy/Postiz VPS into ServerKit using serverkit-agent --level=monitor. | Both hosts report telemetry in one dashboard; zero Docker/Caddy interference verified over 7-day soak. |

### Question 8: Risks, Red Lines, & Exit Strategy

- **Bus Factor:** ServerKit is overwhelmingly maintained by a single author (@jhd3197, 15 contributors total) with rapid releases (v1.11.x), creating regression and abandonment risk. Mitigation: Pin release tags, stage every upgrade, and keep all business logic in your Provider API, never in ServerKit.
- **Supply Chain of Self-Updates & Extensions:** serverkit update executes scripts/update.sh as root/systemd-run, and extensions run un-sandboxed in the Flask process. Mitigation: Verify release checksums before applying (install.sh now refuses tarballs without checksums), use Ed25519 .minisig verification for extensions (docs/EXTENSIONS.md), and never install untrusted third-party marketplace extensions.
- **Audit Immutability:** ServerKit's audit_logs is mutable SQLAlchemy. Mitigation: Keep all compliance/financial audit trails in your append-only PostgreSQL (pgaudit + hash-chained export to S3/B2 Object Lock).
- **Lock-In & Exit Cost:** Near zero if you follow this architecture—your Provider API, PostgreSQL DB, Keycloak realms, and frappe_docker benches have zero runtime dependency on ServerKit.
- **Red Lines (Do NOT Proceed If):**
  - The pilot reveals serverkit-agent --level=monitor still requires write permissions to the Docker socket that allow container mutation, or causes measurable load on live Frappe workers.
  - You are tempted to migrate your PostgreSQL governance ledger, maker–checker rules, or customer portal into ServerKit.
  - An upstream ServerKit update breaks preserve_installed_plugins() or OIDC PKCE during the Phase 0/2 pilot.

## 5. Chassis Scoring Table (ServerKit vs. VortexPanel)

| Criterion | ServerKit | ServerKit Evidence | VortexPanel | VortexPanel Evidence |
|---|---|---|---|---|
| SSO Fit | 4 | Native OIDC (PKCE), SAML 2.0, OAuth 2.0, WebAuthn (README); single realm only. | 1 | Session + Argon2id + TOTP only; no OIDC/SAML/OAuth in README. |
| Docker / Frappe Fit | 3 | Coexists via SERVERKIT_EXTERNAL_PROXY=1 (INSTALLATION.md); opt-in Caddy/Traefik hardcode 80/443. | 2 | Manages Docker/Caddy/Nginx, but assumes host-level ownership; internal handlers UNVERIFIED. |
| Extensibility | 4 | Formal plugin.json, hot-loaded Flask blueprints, ext_<slug>_* tables, runtime ESM bundles (EXTENSIONS.md). | 2 | Has plugins/App Store concept, but no verified public third-party extension SDK (README). |
| Updatability After Customisation | 3 | Blue/green serverkit update preserves .env, DB, & extensions, but overwrites core slots. | 1 | Enforces git verify-tag against upstream signed tags; core edits break updates (README). |
| White-Label Depth | 2 | DB-backed Themes API, but WhiteLabelTab saves to localStorage & Login.jsx hardcodes logo (email branding UNVERIFIED). | 1 | No white-label settings documented (Light/Dark + 7 languages only); templates UNVERIFIED. |
| Fleet Future | 4 | Dedicated Go agent (serverkit-agent) over HMAC WebSocket/HTTP fallback. | 1 | Strictly single-server per install; only one-time server migration tool (README). |
| Security | 3 | Hardened agent systemd unit + Ed25519 extension signing, but plugins aren't sandboxed & AGENT_PERMISSION_LEVELS.md details UNVERIFIED. | 3 | Strong host hardening (Argon2id, TOTP, Fail2Ban, ModSecurity WAF, random login path); privilege model UNVERIFIED. |
| Project Health | 3 | Active (v1.11.27+, 1.8k stars, 89+ releases, 15 contributors), but bus factor of 1 (@jhd3197). | 2 | Active (v3.11.0), but tiny community (32 stars, 17 forks) and single-author (BrowserlessAPI) risk. |
| Adoption Effort (5 = least) | 3 | Moderate: build operqon-ops extension + wire Staff OIDC while keeping Provider API separate. | 1 | Requires hard fork to build OIDC, multi-server agent, white-labeling, and plugin SDK. |

## 6. Final Verdict, Top 5 Risks, & Pre-Production Pilot Checklist

**Recommended Decision:** CONDITIONAL GO on ServerKit (as Staff Ops Chassis + operqon-ops Extension) + NO-GO on VortexPanel, Kill Bill, SigNoz, Kestra, and Trillian. Proceed only on a throwaway pilot, with ServerKit on an isolated Ops VPS, agent at --level=monitor, and all provider, billing, and bench workflows untouched.

### Top 5 Risks & Mitigations

1. **Port 80/443 or Caddy Override on Live VPS** → Deploy ServerKit on a separate Ops VPS (preferred) or bind it to 127.0.0.1:5000 with SERVERKIT_EXTERNAL_PROXY=1; never enable ServerKit's Dockerized Caddy/Traefik.
2. **Over-Privileged Agent on Live Frappe Node** → Explicitly pass --level=monitor during serverkit-agent installation and audit actual allowed actions before pairing to production.
3. **Single-Maintainer Bus Factor & Fast-Release Regressions** → Pin tested release tags (SERVERKIT_VERSION), test every update on staging, and keep all business logic in your Provider API.
4. **White-Label Leakage & Single-Realm OIDC Limit** → Force Keycloak Staff Realm login (sso_force_sso) so staff bypass ServerKit's hardcoded Login.jsx; keep Customer Realm users on your existing Customer Portal.
5. **Extension Privilege & Governance Dilution** → Treat operqon-ops strictly as a thin UI proxy to your Provider API; enforce maker–checker, pricing governance, and append-only audit exclusively in PostgreSQL.

### Exact Pre-Production Pilot Checklist

- [ ] **Edge & Port Isolation:** Install ServerKit on a staging VPS with SERVERKIT_EXTERNAL_PROXY=1 behind Caddy; verify zero port 80/443 conflicts and healthy WebSocket proxying to a dummy frappe_docker bench.
- [ ] **Agent Least-Privilege Audit:** Install serverkit-agent --level=monitor on the staging Frappe host; verify empirically that container start/stop/exec and host shell commands are blocked.
- [ ] **Blue/Green Update & Rollback Drill:** Run serverkit update and serverkit rollback on staging while a dummy operqon-ops extension is installed; confirm preserve_installed_plugins() keeps the extension working and Frappe containers remain untouched.
- [ ] **Keycloak Staff OIDC Verification:** Connect ServerKit to a staging Keycloak Staff Realm with PKCE (S256) and sso_force_sso; verify Customer Realm tokens are rejected.
- [ ] **Backup Non-Interference:** Run bench --site ... backup alongside Pluton/pgBackRest on staging and verify clean site restore without ServerKit interference.
