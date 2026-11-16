# ServerKit Adoption Plan — Operqon Single Panel

**Date:** 2026-11-14 · **Status:** Muse's findings and recommendation. **Decision is pending** the three-way comparison (this plan + ChatGPT's report + Gemini's report on the shared evaluation prompt).
**Method:** 5 parallel investigation lanes, every load-bearing claim verified against the ServerKit repository code/docs (panel v1.11.x, agent v1.6.x) and our own platform records. Items a lane could not verify are marked UNVERIFIED and are pilot-test items, not assumptions.

---

## 1. Executive verdict

**Adopt ServerKit as the infrastructure layer and staff home of Operqon — as a tracked upstream (not a hard fork), white-labelled as far as its settings honestly allow, with Operqon built as its official extension, and with all money/governance logic staying in our own provider API.**

The one-sentence shape: **ServerKit becomes the building; Operqon remains the business that lives in it.** ServerKit supplies servers, Docker, services, proxy, backups, monitoring, identity login and the panel shell. Our provider API keeps tenants, subscriptions, billing, approvals, pricing and provisioning — the extension inside the panel is its face, never its brain.

Why this shape and not the alternatives is answered question-by-question in §2, because those were the owner's three questions.

---

## 2. The owner's three questions, answered from evidence

### Q1 — "Agar hum completely change kar dein to ServerKit ki updates ati rahengi?"

Depends entirely on *where* the change lives. The panel's self-update (verified in `scripts/update.sh` + `panel_update_service.py`) is blue/green: it deploys a **pristine** new tree into the inactive slot, copies across exactly four things — `.env`, the panel database, installed plugin directories, and `/etc` + `/var` data — health-checks, flips a symlink, and auto-rolls-back on failure.

- **Settings-level change (themes, config, installed extensions): updates flow perfectly.** Themes are server-side data in the DB; extensions are deliberately carried forward (`preserve_installed_plugins`), with a boot-time repair pass if files were wiped, and every failure mode degrades *the extension alone* (status `error`, its routes 503, a fail-soft card on its pages) — never the panel.
- **Core code edits: silently discarded.** Anything else changed inside the tree is gone after an update, with no warning and no merge. A hard fork therefore cannot use the built-in updater against upstream; it must point the updater at *our own fork* (the updater is fork-aware — every upstream URL flows through a `GITHUB_REPO` setting) and absorb upstream by **merging tags into our repo forever**, against a maintainer who ships multiple PRs a day and is mid-restructure (core features are actively being extracted into extensions; version went 1.11.27 → 1.11.40 in days). That is a permanent merge tax for a benefit §2.3 shows we mostly don't need.
- **One supply-chain warning that applies to every strategy:** each self-update first downloads and executes the newest `update.sh` from upstream `main` as root, unreviewed. Our policy: pin updates to release tags and/or serve reviewed tarballs from our own mirror (`SERVERKIT_MIRROR_URL` / offline tarball options exist). Updates stay one-click; they stop being unreviewed.

**Answer:** updates keep flowing if our changes live in settings + extensions (the mechanisms upstream built and tests for exactly this). They stop flowing — and turn into merge work — the moment we edit core.

### Q2 — "Hum apne system ko hi uska module bana lein to kesa rahega?"

**This is the right instinct, and the repo is walking toward it** (their own roadmap: thin core, new capabilities shipped as installable extensions). ServerKit's extension system is real and mature: `plugin.json` manifest, hot-loaded Flask blueprint, own tables (`ext_<slug>_*`), lifecycle hooks, nav/route/widget/dashboard contributions, runtime-delivered prebuilt frontend bundles (sha256 + SDK-version gated), install straight from GitHub, ed25519 signing.

But the mapping has a hard internal boundary, proven from their own docs:

- **What the extension should be (Shape A — face):** ~12–14 React pages over our existing provider API — tenant list/detail, approvals queue, payment review, price-proposal review, billing views, provisioning job console, Issues inbox, settings cards — plus dashboard widgets (tenant counts, provisioning health, MRR). Our vanilla-JS console's *specification* (API contracts, v3 designs, workflow rules) carries over almost in full; its *code* does not (React rewrite on a stable API).
- **What the extension must never be (the brain):** their documentation states it plainly — extension permissions are a consent signal, not enforcement (`docker`/`shell`/`db` are ungated; `db` is raw SQLAlchemy); lifecycle hooks are "convenience, not correctness" (failures logged and swallowed); there is **no role/claims framework for extensions at all** (the words role/OIDC/SSO appear zero times in the extension guide); and uninstall-with-purge **drops the extension's tables**. Maker–checker approvals, pricing governance and the immutable audit therefore stay in our provider API and PostgreSQL, exactly where they already live and already work. The extension forwards the signed-in user's identity to our API, which authorises per role and per action as it does today.
- **MVP slice that proves everything with the smallest surface:** (1) read-only Tenants pages (proves ESM delivery + proxy pattern), (2) overview dashboard widgets (proves contributions), (3) **one** write path — payment-verification approve/reject — with a precise acceptance test: a same-user approve attempted through the extension must fail with our API's SoD rejection exactly as it does from today's console; a proper billing→approver pair must succeed and land in **our** `audit_events`. One pilot-verification item gates all write paths: that the panel JWT an extension receives can be validated by our API (JWKS/discovery) so identity forwarding is cryptographic, not a trusted header [UNVERIFIED until pilot].

**Answer:** our system as their module = the recommended strategy — with "module" defined as face-only. The moment the module starts holding governed data or rules, it inherits every weakness above.

### Q3 — "Hamari baqi applications, jaise Frappe/ERPNext, par kya asar ho ga?"

On a tenant bench host, **nothing — if and only if two independent locks are both engaged**, and this is the best-engineered part of the product:

- **Agent permission levels** live in the agent's *own local config*, are enforced *by the agent*, and can only be changed on the box, as root, with typed confirmation. There is no panel API for it; a compromised panel **cannot** escalate an agent. **Monitor** (default for new installs) has *no inbound command channel at all* — signed telemetry out, nothing in. **Protect** adds only a fixed firewall/Fail2Ban/CrowdSec allowlist. **Full** is the whole feature set — and is the default only for legacy/unattended installs, which we ban.
- **Panel-side Observed mode** independently refuses mutating commands server-side, audit-logs every refusal, and counts blocked commands.
- With Monitor + Observed: the panel sees bench metrics and Docker inspect/logs (a conscious confidentiality decision — inspect exposes container env vars, i.e. bench secrets, to panel accounts) and can mutate **nothing**.

The named dangers, all code-verified, all handled by rule rather than hope:

1. **Full level = generic, unscoped Docker power** — stop/remove any container, remove images/volumes/networks, compose up/down against *arbitrary paths* (including the bench's own), web terminal. No ownership filter exists. → Full is banned on tenant hosts, permanently.
2. **The panel host itself is the dangerous seat, not the agent.** The panel's own Docker Cleanup removes *all* stopped non-ServerKit containers, then prunes images/networks (optionally volumes); system prune `-a` would delete our retained rollback images (oc30 etc.) by definition. → **The panel never runs on a bench host.** It gets its own small dedicated host.
3. **ProxyStack binds 80/443.** ServerKit's Caddy/Traefik stacks would fight our host Caddy for the edge (fail-safe only by accident while our Caddy holds the ports). → Proxy stacks are never enabled on bench hosts; our Caddy stays the edge and simply fronts the panel on its own port (the panel serves on :5000 and its own compose file documents running behind Caddy). Tenant domains are never entered into ServerKit's site management on a bench host.
4. **Compose project-name collision — our own lived failure class exists here too.** ServerKit runs compose without `-p`, so project identity follows `.env`/directory rules exactly as in the Postiz incident. → Reserved-name discipline for ServerKit apps; generic compose actions never pointed at bench paths; Monitor level makes the whole class unreachable on tenant hosts anyway.
5. **Disk growth.** Panel DB grows ~11 MB/day and every self-update snapshots the tree + DB twice (the authors themselves document ~9.6 GB after six updates against an 800 MB DB on a small VPS). → Another reason the panel lives on its own host with quotas, alerts wired to real channels, and its DB backup automated to B2 with a drilled restore (the panel is single-instance by design — one SQLite file, in-memory agent registry, single worker; panel down = sites keep serving, we lose visibility/deploys until restored; that is acceptable *only* with a proven restore).

**For the rest of the portfolio** (Lane 5): School ERP+LMS is ServerKit's cleanest fit (git deploy + `serverkit.yaml` manifests + managed PostgreSQL/PgBouncer — it can take the Dokploy role there). RAG and the SMS/phone services fit fully (template catalogue is AI-heavy). Rektrs Social/Postiz: Dokploy stays owner of that shared, fragile host; ServerKit agent in Observe/Monitor gives fleet visibility; migration only in a planned window. IQRS shared hosting: not applicable, stays its own programme. **Coexistence law (their own docs say it too): two panels writing the same host's config is never supported — one owner per host.** ServerKit's `cleanup-apps` treats foreign containers as orphans; dual management is how outages happen.


---

## 3. White-label: the honest picture (corrects an earlier statement in this chat)

Earlier in this conversation the built-in White Label tab was presented as "panel apna ban gaya." Code-level checking corrects that:

- **Colour themes are real white-label** — server-side data in the panel DB, applied panel-wide including pre-auth login screens (`GET /api/v1/themes/public/active` exists precisely so login paints branded). Our colours, everywhere, surviving updates. ✅
- **Brand name and logo are browser-local cosmetics** — the White Label tab writes only to the admin's own `localStorage` (logo as a base64 data URL). No backend storage, no login-screen presence, invisible to other admins. ❌ as a product feature.
- Favicon tint is per-install and re-applied automatically by the updater. ✅

**What this means practically:** the panel is a **staff-only** surface — customers never see it (they see the portal and their tenant ERP, both already ours). A staff panel in Operqon colours with our favicon is 90% of the professional requirement. The remaining 10% (our name/logo on the shared login screen) is achievable only by a **thin fork patch** making brand server-side — a small, single-purpose core change. Recommendation: **do not fork for this on day one.** Run settings-level branding first; take the thin-fork decision as its own later gate, with eyes open that it converts every upstream update into a (small, near-mechanical) merge. The extension + theme work is identical under both futures, so nothing is wasted either way.

## 4. Scorecard (same criteria as the prompt given to ChatGPT/Gemini)

1–5, evidence-based, from the five lanes. VortexPanel column carried from the 2026-11-14 head-to-head evaluation.

| Criterion | ServerKit | VortexPanel | Evidence in one line |
|---|---|---|---|
| SSO / identity fit | 4 | 1 | OIDC/SAML/OAuth/WebAuthn + linking; but no IdP→role mapping (roles stay panel-local). VortexPanel: no SSO at all |
| Docker & Frappe/ERPNext fit | 4 | 2 | Docker-native + Monitor/Observed coexistence; but zero Frappe awareness — bench lifecycle stays ours by design |
| Extensibility & module system | 5 | 1 | Full extension platform (manifest, own tables, UI contributions, runtime ESM, signing). VortexPanel: none found |
| Updatability after customisation | 5 (settings+extension) / 2 (core edits) | 2 | Blue/green updates carry settings+plugins, discard core edits silently |
| White-label depth | 3 | 3 | Themes server-side ✅; name/logo browser-local ❌. VortexPanel branding is template-level |
| Multi-server / fleet future | 4 | 1 | Go agent, capability-gated fleet contract, central metrics; single-instance panel caps the ceiling. VortexPanel: single server |
| Security posture | 4 | 3 | Agent-side permission levels are genuinely strong; deductions for unsandboxed extensions, localStorage tokens, non-immutable audit |
| Project health | 3 | 3 | Extreme velocity + unusually honest security docs; bus factor = 1 on both |
| Adoption effort (5 = least) | 3 | 2 | Pilot + dedicated host + React extension build; VortexPanel fails the core requirement at any effort |

## 5. Adoption conditions (all mandatory) and red lines

**Conditions:**
1. Panel on a **dedicated management host**, behind our Caddy, staff-only reachability (IP/VPN restriction), treated as Keycloak-grade infrastructure.
2. Agent levels by host class: **tenant production hosts = Monitor + Observed, always**; Protect only per-host by decision; Full only on our own infrastructure hosts; `Features.Exec` off except named hosts; legacy implicit-Full installs banned.
3. Keycloak OIDC for all staff; MFA enforced in the Keycloak provider realm; `sso_default_role=viewer`; panel-local roles reviewed on a schedule (Keycloak groups do **not** propagate); admin held by two named people; **developer treated as a sudoers-equivalent grant** (it can open terminals).
4. Extensions: first-party signed + **our own signed extensions only**, installed from our controlled repo; marketplace unused on production; installs are change-managed deploys; plugin pip installs off.
5. API keys: explicit scopes + expiry mandatory by procedure (an empty-scope key is silently a full-access key; no per-key IP allowlist exists).
6. Audit: ServerKit's log is a plain table in its own DB — operational convenience, **not** our record. Provider audit stays in our `audit_events`; panel audit gets off-box append-only shipping before production reliance.
7. Proxy-hop configuration (`TRUST_PROXY_HEADERS` / hops) validated against our real Caddy chain in the pilot — lockouts and audit IPs depend on it.
8. Updates: pinned to reviewed release tags / our mirror; monthly cadence (security fixes land only on the latest line); agent binary updates governed manually until upstream ships signed agent releases (their own audit's outstanding item).
9. Full mirror of upstream in the Rektrs GitHub org from day one; panel DB backup to B2 automated and restore **drilled**.

**Red lines — any one blocks adoption:** Full agents as the default on tenant hosts · any third-party marketplace extension on the production panel · panel co-located on a tenant host or publicly reachable without edge restriction · billing/pricing/payment-approval logic moved into the panel or an extension without dual control in our layer · ServerKit's audit log as the sole record of provider actions.

## 6. Phased plan

- **Phase 0 — Replica pilot (throwaway VPS).** Replica bench (same compose shape, pinned images incl. a retained rollback digest, `COMPOSE_PROJECT_NAME` as production, host Caddy, test tenant) + ServerKit. Run Lane 3's 15-item checklist in order: baseline diffing, refusal battery under Monitor+Observed, panel-escalation attempt, governed bench image swap **and rollback** under observation, panel self-update with bench untouched, cleanup/prune canary test (proving the blast radius empirically), project-name collision drill, ProxyStack tripwire, disk-pressure soak, secrets-exposure review, kill-switch drill. **Gate: all 15 pass; production agent (Monitor) is installed only after this gate, and any later move to Protect/Full re-runs items 3, 5, 9 plus an owner decision.**
- **Phase 1 — Panel home.** Dedicated host; white-label theme (Operqon colours + favicon); Keycloak OIDC (authentication; roles panel-local, viewer default); mirror repo + B2 panel backup + restore drill; agents at Monitor on the Operqon VPS (Observed) and the Postiz host (Observe). Our existing console/portal keep running untouched — the panel links to them under one login.
- **Phase 2 — Operqon extension MVP.** Read-only Tenants + overview widgets + the single W2 write path with the SoD acceptance test (§2.2). Requires the JWT-validation verification first. Success = staff do tenant oversight and payment verification from inside the panel; our console remains live as fallback.
- **Phase 3 — Extension phase 2.** Issues inbox (the standing owner priority: every operational issue resolvable in-panel), pricing-proposal UI, provisioning job console. Gateway **secrets stay in our API's encrypted store** — the extension fronts the cards, never holds the credentials.
- **Phase 4 — Fleet rollout, one owner per host.** School ERP+LMS deploys move to ServerKit (git deploy + `serverkit.yaml`); RAG/SMS services onboard; Postiz host stays Dokploy-owned (Monitor visibility only) until a planned migration window; Dokploy remains warm as the exercised exit path.
- **Phase 5 — Optional branding gate.** Decide the thin fork patch for server-side name/logo on the login screen, knowing its merge cost. Skip it if staff-facing colours+favicon prove sufficient in practice.

## 7. Exit, if we ever leave

Rated **low–moderate pain, front-loaded in our favour**: workloads are ordinary Docker containers that keep serving with the panel stopped; generated proxy configs are standard-syntax files on the host; `serverkit.yaml` manifests live in our repos (redeploy elsewhere = translation, not archaeology); our extensions are our own MIT code (Flask + React) needing re-housing, not ransom. What we lose: panel-internal state (users/roles, panel audit/metrics history) and the contribution wiring. The discipline that keeps exit cheap is the same one that keeps updates flowing: **zero core edits, everything ours in extensions + manifests.**

## 8. Decisions reserved for the three-way faisla

1. Adopt ServerKit on this shape — yes/no (after ChatGPT + Gemini reports are compared).
2. Panel host: new small dedicated VPS vs an existing non-tenant host.
3. Branding depth now: themes+favicon (recommended) vs thin fork immediately.
4. Dokploy end-state per host (recommended: Operqon VPS → ServerKit; Postiz host → Dokploy until planned migration).
