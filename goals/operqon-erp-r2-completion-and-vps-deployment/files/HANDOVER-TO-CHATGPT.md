# OPERQON — HANDOVER / CONTINUATION FILE

**Purpose.** This is the single living document from which ANY builder (ChatGPT, or a
future Muse session) can pick up the Operqon ERP programme exactly where it stopped.
It is updated at EVERY milestone, and the same copy is committed to the source-of-truth
repository. If you are continuing this work: read this file fully first, then the
goal GOAL.md, then the blueprint README.

**Owner:** Assad (decisions, approvals, all passwords/MFA are his alone — never ask
him to put secrets in chat; logins happen through his browser / secure vault only).

**Working model (owner decision, 2026-11-06 23:55 PKT):** Muse builds, tests,
deploys and verifies directly. ChatGPT is the fallback builder: if Muse's capacity
runs out, the owner hands THIS file + the repository to ChatGPT, which continues from
the "REMAINING WORK QUEUE" below, in order, and must update this file per milestone.
(Earlier the model was ChatGPT-builds / Claude-verifies; the owner reversed it after
a token-cost review. The GitHub no-ZIP delivery rule stands either way.)

**Owner addendum (2026-11-06 23:58 PKT): FULL APPROVAL.** The owner directed: do
whatever is needed, do not ask for approvals (GitHub included) — just complete it.
Whoever continues this programme works autonomously and reports RESULTS, not
requests. The only steps that physically require the owner are the ones bound to
his personal credentials/documents (his role-account passwords + MFA; the real
tenants' identity documents) — prepare those fully; never request, reset or
record his passwords.

---

## 1. CURRENT LIVE STATE (verified 2026-11-06 ~23:46 PKT)

- **R4.1 is LIVE and fully accepted.** Migrations at alembic head `0009_country_pricing`
  (0008 = bank-claim reject/list with audit; 0009 = per-country pricing).
- API: R2/R3/R4.1 stack on `127.0.0.1:18090`; R1 kept on `127.0.0.1:18089` as rollback
  canary. Both `/readyz` = 200.
- Owner console: https://control.operqon.cloud (root path redirects to /tenants.html
  via a Caddy exact-path rule added 2026-11-06; backup `/root/Caddyfile.pre-rootfix-20261106`).
  Console serves the R4.1 actionable UI; served assets hash-verified == package
  (console.css `73edd1ec…`, tenants.html `ab784210…`).
- Customer portal: https://operqon.cloud/customer/ (200). Keycloak realms
  `operqon-provider` + `operqon-customers` at login.operqon.cloud (admin API only at
  VPS-local `127.0.0.1:18086`). Brevo SMTP works in both realms.
- Acceptance evidence (attempt-7 run, `/root/r41-deploy7.log`): 74 tests passed /
  3 skipped; all 7 provider roles passed REAL MFA browser acceptance; 5 bank notices
  verified (invoices paid, tenants → provisioning, 5 provision jobs completed) and
  3 rejected with recorded reasons (invoices stayed payable) — all on disposable
  e2e tenants. Full report: `hidden_files/r41-deploy-2026-11-06.md` in the goal workspace.
- Real tenants UNTOUCHED by the deploy: `rektrs-private-limited` and `demo2`, both
  still status **requested**. (Plus disposable e2e tenants — see report.)
- Pre-deploy backup: `/var/backups/operqon-provider-r2/operqon-provider-pre-r41-20261106T180455Z.dump`
  (sha256 `85f4059a…`, TOC-validated). Restore rehearsal on a throwaway PG passed.

## 2. SOURCE OF TRUTH

- Repository: **s22benlg1m01140-sudo/operqon-core** (private). Work branch:
  `release/operqon-provider-r2`. Approved deployment commit:
  **`2cedc9640b4cbd9d440345cda87107d11e7648be`** (the Console MVP5
  release tree, Rams install-convergence heal composition, committed
  2026-11-11 in the Rams install-hook-fix sequence; the provider marker
  `/etc/operqon/r2-approved-github-commit` points at the handover commit
  carrying this update, whose parent is that tree commit). `main` must
  stay untouched unless the owner says otherwise.
- VPS gate: clone at `/opt/operqon-r2-github`, approved SHA in
  `/etc/operqon/r2-approved-github-commit` (600, root); `scripts/verify-github-source.sh`
  must print "GITHUB SOURCE-OF-TRUTH: VERIFIED" and exit 0 after any deploy.
- Deployed manifest: 576 entries, byte-identical to the repo's.
- RULE: every change lands as a commit on the release branch BEFORE or WITH its
  deployment; after deploying, refresh the clone + approved-commit file + deployed
  manifest and re-run the gate. No ZIP deliveries any more.

## 3. ACCESS & ENVIRONMENT (names/paths only — no secret values exist in this file)

- VPS: Hostinger `srv2107420.hstgr.cloud` (72.61.214.64), Ubuntu 26.04, KVM 2, Jakarta.
- SSH ONLY via the wrapper on Muse's VM: `~/workspace/scripts/rssh.sh root@72.61.214.64`
  (explicit key + ssh_proxy.py ProxyCommand; bare ssh fails auth; rsync works with
  `-e ~/workspace/scripts/rssh.sh`).
- App tree: `/opt/operqon-provider-r2/` (deploy compose: `deploy/compose.r3-customer.yaml`;
  force-recreating the api container needs env exports OPERQON_CUSTOMER_ISSUER /
  _AUDIENCE / _CLIENT_ID + OPERQON_FRAPPE_OIDC_CLIENT_ID recovered from the running
  container's env — they are stored nowhere else).
- Keycloak bootstrap admin: user `operqon-keycloak-bootstrap`, password in
  `/opt/operqon-staff-identity/runtime.env` on the VPS (read server-side only).
- merchant.env: `/opt/operqon-provider-r2/deploy/config/merchant.env` (600; contents
  never printed). Gateway credentials get added THERE via the secure flow only.
- E2E test accounts: `/root/operqon-r4-e2e.env`, `/root/operqon-r41-e2e.env` (600, VPS only).

## 4. PEOPLE / LOGINS (all owner-held; each holds EXACTLY ONE role — see Rule 2)

Console door for all: https://control.operqon.cloud → Sign in → username.
- `operqon-owner` — operqon:operator (tenant review queue; review-only by design;
  owner decided 2026-11-06 23:34 PKT to keep it that way).
- `operqon-identity` — operqon:identity (verify email + identity review).
- `operqon-approver` — operqon:approver (tenant approve/reject).
- `operqon-billing` — operqon:billing (pricing drafts).
- `operqon-pricing` — operqon:pricing_approver (pricing approval).
- `operqon-provisioner` — operqon:provisioner.
- `operqon-billing-approver` — operqon:billing_approver (bank notice verify/reject).
All six role accounts completed first login (own password + TOTP) on 2026-11-06.

## 5. HARD RULES (do not break; each was learned from a real incident)

1. **7-key tenant-queue contract is FROZEN**: API `tenant_queue()` returns exactly
   the 7 keys the console validates; the console locks with "Provider authorization
   required" on any shape drift. (Root cause of the 2026-11-06 login-loop incident.)
2. **Exactly-one-role verifier**: the provider API rejects any token whose roles
   claim contains ≠1 allowed operqon role. Never grant a second operqon role to
   any account; a multi-role "super owner" requires a deliberate, tested release.
3. **Pricing enters ONLY via the authenticated approver flow** (billing drafts →
   pricing_approver approves). Never seed or hard-code prices.
4. **No feature disabling**: missing keys/credentials go in as configurable env
   vars/secrets; releases ship COMPLETE and LIVE.
5. **Production discipline**: pre-deploy DB backup (validated) + disposable-PG
   rehearsal for migrations + snapshot/rollback path + post-deploy live verify,
   every time. Migrations are forward-only (downgrades raise RuntimeError).
6. **Secrets never in chat, files, or git.** The GitHub secret-exclusion audit runs
   on every push (customer `config.js` stays local; only `.example` is committed).
7. The owner's own browser/device evidence outranks clean test results: if he
   reports a failure, check server logs and response bodies first.
8. ERP and the IQRS school system (iqrs.edu.pk) are SEPARATE projects — never mix.
9. Domain renewals are parked by the owner's order — do not touch or raise them.

## 6. DECIDED FACTS

- **Pricing (owner-decided)**: multi-currency per country. Pakistan (PKR): Starter
  Rs 7,500/mo (Rs 75,000/yr), Growth Rs 9,999/mo, Business Rs 19,999/mo; tax-EXCLUDED;
  3-day trial. Enter via Rule 3 flow, country = Pakistan.
- **Approval is payment-driven**: online gateway success → auto-approve/provision;
  offline (bank claim) → PENDING until billing_approver verifies (or rejects with
  a recorded reason — supported since R4.1).
- **Gateways**: Phase 1 = Stripe + JazzCash (adapters exist), Easypaisa + PayFast
  (catalogue only — adapters are R4.2, blocked on merchant contracts/credentials).
  Phase 2 = NayaPay Business, Xstack, rest.
- **Invoices cannot be created until an approved pricing proposal exists**
  (create_invoice is gated on it) — pricing is the next gate for the real flow.
- Identity review needs the SHA-256 fingerprint of the actual evidence document
  reviewed (documents live outside the system; the hash is the attestation).
- **ERP design — LOCKED (owner decision, 2026-11-09 12:44 PKT)**: the tenant
  ERP frontend design language is DreamsPOS **as-is** (Option 1): light
  theme, orange `#FE9F43` + navy `#092C4C` (Brand/Dark `#1B2950`), Nunito
  Sans — DreamsTech's Figma Community file `1NuD8im5R2GSz4Zdf5AsHG`,
  supplied by the owner. This supersedes the same-morning Orven approval
  (2026-11-09 11:06 PKT) FOR THE ERP FRONTEND ONLY; console + portal
  designs still come from the owner separately. Full record: the
  2026-11-09 design-programme entry at the end of §9 + Q9 below.

## 7. REMAINING WORK QUEUE (in order — continue from the top)

### Q1. W0 closure — provider DB backup off-VPS + restore rehearsal  [CORE DONE 2026-11-07 00:00 PKT]
DONE: the off-VPS mechanism is restic → Cloudflare R2 (bucket `erp-saas-backups`,
config `/etc/erp-saas-backup/r2.env` + restic password file). The provider leg was
ADDED additively (zero existing files edited): `/usr/local/sbin/erp-saas-r2-backup-provider`
+ `erp-saas-r2-provider-backup.{service,timer}` (daily 02:50 UTC; fresh dump via
backup-provider-db-r41.sh, hash-verified, tags `erp-saas,operqon-provider,daily`).
Proof run: dump 66,184 B (alembic 0009) → restic snapshot `e15aefaf`; restore FROM
THE OFF-VPS COPY into a throwaway PG verified (byte-identical sha256;
alembic_version 0009_country_pricing; tenants = 8 = live; 16 tables; two GRANTs to
the stack-created role operqon_api are skipped in a bare container — expected).
Report: `hidden_files/w0-backup-closure-2026-11-06.md`. Part 2 DONE (2026-11-07
00:03 PKT): provider-tag retention live — `/usr/local/sbin/erp-saas-r2-retention-provider`
+ service/timer (Sun 05:15 UTC; policy keep 7d/4w/6m scoped by tags
`erp-saas,operqon-provider,daily`, proven by inventory + dry-run to match ONLY
provider snapshots; first real forget runs under the timer). STILL OPEN in Q1 —
two OWNER-ONLY micro-items: (a) the restic password file AND the R1 backup key
(`/opt/operqon-provider-r1/deploy/secrets/backup-key`) exist ONLY on the VPS —
total VPS loss would leave the off-VPS copies undecryptable; the owner must store
both passphrases in his own secure store (never via chat/files/git);
(b) healthcheck ping for the provider backup leg — the owner creates ONE check in
his healthchecks.io account (suggested name `operqon-provider-backup`, period 1d,
grace ~2h) and saves its ping URL as a single line to
`/etc/erp-saas-backup/healthchecks-provider-url` (mode 600); the on-box wiring
after that is ~10 min (wrapper + drop-in specified in the W0 report). Reusing
another chain's check was deliberately rejected (it could mask that chain's failures).

### Q2. Pricing — enter + approve the decided PKR set  [PREP DONE 2026-11-07; read the prep report BEFORE the session]
Prep report: `hidden_files/team-pricing-prep.md`; click-by-click runbook:
`~/workspace/operqon-team/pricing-prep/SESSION-RUNBOOK.md`; post-approval checks:
same dir, POST-APPROVAL-VERIFY.md. The naive flow is WRONG in four ways:
(1) Proposal v1 ALREADY EXISTS (seeded by migration 0002: draft, currency SAR,
prices null; country backfilled PK by 0009) — billing EDITS v1; "New country
draft" returns 409. (2) SAR TRAP: the terms box is pre-filled
{"currency":"SAR"} and the whitelist is not country-bound — the runbook mandates
replacing it with {"currency":"PKR","tax":"excluded","trial_days":3} and reading
the summary back at two points. (3) Values are MINOR units, digits only:
Starter 750000/7500000, Growth 999900/9999000, enterprise 1999900/19999000,
onboarding 0; trial 3 already in the catalogue. (4) ⚠️ MISSING OWNER VALUE:
approval hard-requires `additional_seat_minor` > 0 per tier and NO seat price was
ever decided — the owner must name seat prices (3 tiers) or approval 409s.
One-way door: no endpoint can set `rejected`, so an awaiting_approval proposal
cannot be recalled — the runbook's read-back discipline is mandatory.
DEFECT FIXES (D2 deadlock, D3 approver-sees-no-amounts, D5 currency-country
binding, D4 dead terms-merge) are being built by a fix lane
(`~/workspace/operqon-team/pricing-fixes/`, report `team-pricing-fixes.md`) and
must be reviewed + deployed BEFORE the owner's pricing session.
Currency whitelist note: the R4.1 draft-update path validates PKR/SAR only —
fine for Pakistan + Saudi; D5 binds currency to country.

### Q3. First real tenants end-to-end (Rektrs, then demo2)  [REKTRS PILOT COMPLETE 2026-11-08 — tenant ACTIVE, Stages 0–9 done; evidence pack `files/Q3-REKTRS-PILOT-EVIDENCE.md`; DEMO2 RUN COMPLETE 2026-11-10 — tenant ACTIVE via the S9 self-service path (the owner ran his 6 run-pack steps; invoice OPQ-202611-D18B2D26 PAID; site published); evidence pack `hidden_files/demo2-evidence.md`; see the demo2 entry at the end of §9. W1 is NOT closed by demo2 — Slice 10 / ENG-060 remains. See the 2026-11-08 update-log entry at the end of §9 for the Rektrs record, incl. the two Stage 8 findings and the new battery rules]
Authoritative runbook: `~/workspace/operqon-team/provisioning-prep/runbook-first-real-tenant.md`
(+ frappe-oidc-design.md, site-users-fix-spec.md, dress-rehearsal-plan.md;
summary hidden_files/team-provisioning-prep.md). CORRECTIONS to earlier
descriptions: (a) the PAID path has NO human Approve step — intake hard-codes
onboarding_path="paid", the console approve endpoint 409s for paid tenants, and
approval happens inside payment settlement (settle_invoice →
activate_after_payment, actor operqon-payment-automation); the approver role
belongs to the trial/manual path. Paid-path order is: pricing live (Q2) →
identity verify + review (owner, real document SHA-256) → subscription/invoice →
payment settle (offline: billing_approver verify) → automatic activation →
provisioning job → site → publication. (b) PUBLICATION is the weak point: the
five R4.1 acceptance tenants still sit at "provisioning" because auto-publish
needs https://<site>/api/method/ping → pong — hostname DNS/TLS/routing readiness
is a Stage-0 exit criterion; on failure fix routing, NEVER hand-edit state.
(c) ENVIRONMENT: the live executor targets the STAGING pairing
(stage.operqon.cloud); adopted decision — Rektrs runs first as a controlled
pilot on that pairing; production-bench cutover is a separate later window.
(d) ERP SSO is UNIMPLEMENTED and OPERQON_FRAPPE_OIDC_CLIENT_ID is dead config
(read by zero code paths) — implement per frappe-oidc-design.md (per-tenant
confidential client operqon-erp-<slug>, executor configure_sso step, roster
gate as primary control, negative SSO test R11 = release blocker).
(e) site_users has a 4-layer root cause (prep report §5) — fix spec F1–F4;
F1/F3/F4 are being built by a fix lane (team-siteusers-fixes.md), F2 lands with
the OIDC step. Rektrs provisions only after Slice 1 Step 3 (R7); dress
rehearsal Pass A on current code first, Pass B gates the real run; rehearsal
uses real APIs only.

### Q4. R4.2 — Easypaisa + PayFast adapters  [PREP DONE 2026-11-07; completion BLOCKED on owner merchant inputs]
Prep report: `hidden_files/team-gateways-r42.md`; tree
`~/workspace/operqon-team/gateways-r42/` (adapters + wiring + env example, 32
mock tests pass, no schema/migration changes). Readiness: Easypaisa ≈60%,
PayFast ≈65% (adapter code ≈85% each); 12 TODO_SPEC items name the exact
document/credential that closes each. Owner inputs — Easypaisa (Telenor
Microfinance Bank, ~7–15 working days): production Store ID, portal Hash Key,
sandbox Store ID + Hash Key + test MSISDN (must be requested), merchant guide
PDF, REST credentials + EWP account number + exact Inquire URLs, IPN portal
config; go-live needs their 7 sandbox cases passed. PayFast: production
Merchant ID + Secured Key, UAT pair, character-exact registered Merchant Name,
merchant guide, callback whitelisting. With those in hand: drop in adapters,
sandbox E2E on a disposable tenant, deploy under Section-5 discipline.
Trust notes: Easypaisa postback is a trigger only — settlement requires the
server-side Inquire (PAID + exact amount); PayFast's callback carries no
amount — integrity rests on basket binding + TXNAMT at the token step.

### Q5. W1 — shared business core build (blueprint wave W1)  [PLAN DONE 2026-11-07; SLICE 1 BUILDING]
Blueprint: `files/Operqon_SaaS_ERP_Blueprint_v1_2026-11-06.pdf` (+ ZIP; extracted
copy under `references/blueprint-v1/`). Implementation plan:
`hidden_files/w1-implementation-plan.md`. SCOPE (blueprint backlog): ENG-013–060
(48 items — Platform 013–024, Finance 025–036, Supply 037–048, Commerce 049–060);
wave gate 8–14 weeks for a 5–7-person team ("3 real end-to-end businesses;
reconciled ledgers") — calendar must be re-based for a single-builder reality.
GAP MAP: 1/48 live, 9 partially, 38 not started; W1 is chiefly TENANT-side: live
provisioning creates only vanilla ERPNext sites and NO Operqon Frappe app exists
yet — finance/supply/commerce capability sits in upstream ERPNext, unvalidated;
blueprint principle = map/validate first, extend only on gaps (no duplicate
posting engine). 10 ordered slices; non-goals (W2+: pack platform ENG-061–068,
FBR/Pakistan pack, ZATCA, industry depth, payroll localisation) must not leak in.
ADOPTED READINGS under the full-approval mandate (recorded, not silently assumed):
R4 — the "3 real businesses" gate is met via controlled/isolated pilots, because
blueprint §7 bars real paid ops where country gates are unpassed (Pakistan gates
are W2); R7 — real tenants (Q3) provision AFTER Slice 1 lands the app-install
path, avoiding retroactive installs. SLICE 1 (building): tenant ERP foundation +
order-to-cash posting proof (ENG-025–028/030, ACC-01/02) — Step-0 bench reconcile,
Operqon Frappe app skeleton, company bootstrap (CoA template + opening balances),
posting-fixture harness asserting real GL/AR/stock numbers on a DISPOSABLE site;
no control-plane migration. Working tree: `~/workspace/operqon-w1-build/`;
report: `hidden_files/w1-slice1-foundation-2026-11-07.md`.

### Q6. W2 — Pakistan country pack (FBR etc.), then W3–W5 per blueprint.  [PLAN DONE 2026-11-07]
Plan: `hidden_files/w2-pakistan-plan.md` (ENG-061–096, 36 items, 9 slices).
Essentials: FBR digital invoicing ONLY via a licensed integrator (PRAL route is
free); STGO 01/2026 — mistakes correctable within 72 hours via the Board system,
Commissioner approval after; federal goods tax ≠ provincial services tax; gap
1/36 live. Owner decisions queued for W2 time: integrator route + agreement,
named licensed tax specialist (self-approval is blueprint-prohibited), provincial
sequence, pilot cohort. Deepest open unknown: whether one integrator arrangement
can serve many unrelated SaaS tenants. 15 unverified items listed in plan §8 —
do not treat them as facts. UPDATE 2026-11-09: the FBR integrations
composition is IN oc13 on the staging pairing (hooks append-merge,
install_all routing, Activate wiring); the NEXT W2 slice — the
transactional outbox / idempotency + transport submission state
machine (ENG-073, ENG-075 submission surface, ENG-090 machine;
ENG-074 receipt-application half only; ENG-076 NOT built) — is
BUILT LOCALLY ONLY, NOT deployed, and rides oc14 (full record in
the oc13/W2 entries at the end of §9; report
`hidden_files/team-w2-outbox.md`). UPDATE 2026-11-09 (oc14):
that outbox slice IS NOW DEPLOYED on the staging pairing in image
oc14 (see the oc14 entry at the end of §9): the Operqon
Integration Outbox DocType is live via the canonical sync path,
and the hourly drain
(`operqon_core.integrations.drain.drain_outbox`) is registered
and inert-safe (no `pk_fbr` record → drained 0, no errors).
### Q7. Legacy stacks (Pilot / Demo / RC2)  [AUDIT DONE 2026-11-07 — read team-legacy-audit.md before touching anything]
⚠️ Demo has NO database of its own — its site DB lives inside Pilot's MariaDB
and its backups exec into Pilot's containers; app.operqon.cloud is served from
Pilot's volume. NEVER remove Pilot before Demo is retired/migrated. Nothing
live depends on any legacy stack. Combined idle RAM ≈2.4 GB of 7.75 GB.
⚠️ /opt/erp-saas/operqon-source/ is the ONLY standalone copy of the original
operqon_core Frappe app (not in git) — archive lane is pushing it to GitHub
branch `archive/legacy-operqon-core-source` (2026-11-07) and fully archiving
RC2 (dead since Oct 31, zero backups). Removal sequence when executed:
source archive → RC2 (archive verified first) → Demo only when retired
(Caddy → timers → containers → its DB inside Pilot) → Pilot last.
### Q8. Housekeeping when a git-capable path exists: turn the RELEASES.md receipts
(live/provider-r2.1 / r3 / r3-fix7, R4.1 283368f9) into real git tags; consider
branch protection on the release branch.

### Q9. ERP design programme + own-frontend build  [DESIGN COMPLETE 2026-11-09; GAP methods bench-proven; oc13–oc21 DEPLOYED on the staging pairing (current: oc21, 2026-11-10) — every governed surface serves LIVE data (Home/Stock/Accounts from oc14; Sales/Buying/Trial Balance/Balance Sheet/POS catalogue from oc15); the LOGIN CHAPTER is resolved at the data level (CSRF oc16 → session-first button oc17 → frappe-global root cause oc18 → owner landed inside with live data 2026-11-10 → truth-in-labelling fixes oc19, served-code proof 9/9) with ONLY the owner's visual confirmation of oc19 outstanding; firstrun live flip REFUSED in oc19 (payload mapping lane in progress; adminSource stays "fixture") **then SHIPPED in oc20 (adminSource "live"; battery + render proof PASS); oc20 also made governed WRITES live on the staging bench (11 whitelisted methods; first real invoice + Material Transfer + partial payment proven; F-OC20-1 SPA cost_center gap → oc21)**; oc21 CLOSED F-OC20-1 + F-OC20-2 (branch selection in the SPA; headline proof = a branch-scoped Branch Manager completing a real Sales Invoice through the served SPA's own live path) and merged the M3 transactional surface (Quotation / Sales Order / Delivery / lifecycle / stock count + trace / bank rec) + the paged aggregates fix (matrix 264 rows / 44 DocTypes; F-OC21-1 branch-axis guard + F-OC21-2 installer convergence fixed in-cycle)**; the full on-page audit has RUN and its paperwork is CLOSED (131 checks; coverage 16 covered / 100 partial / 9 uncovered; residue = a short re-pass on a provisioned proof site) — see the oc13–oc21 entries + the CURRENT STATE entries at the end of §9]
Working file: "Operqon ERP — Design (DreamsPOS base)", Figma key
`6CNjuF2lkBlkg5xB0SX5ER` (IRFAN HAIDER's team, Rektrs account) — its
Production page holds **64 frames across all 10 Operqon surfaces**
(census: `hidden_files/team-design-slices91012.md`), incl. ~38 in-style
builds for the surfaces the free Community edition (62 screens,
light-only) lacked: Sales/Buying documents, Accounts, People/Admin,
Settings. Arithmetic patterns verified (balance sheet / trial balance /
journal / aging); 2 animation prototype flows built. Licence: the free
edition is CC BY 4.0 with attribution to DreamsTech (a Credits page
rides in the working file); the owner buys the commercial rights
DIRECTLY from the vendor himself (see the §9 entry dated 2026-11-09) —
nothing was purchased by Muse. Dark theme = Slice 11, waits on the
purchased kit's own dark hexes (GAP-11). Build: own-frontend foundation
at `~/workspace/operqon-team/own-frontend/`; tokens aligned to the
locked Option 1 light language (GAP-07 resolved for light; dark
provisional); S1 Home is wired to the GAP-01 contract. UPDATE
2026-11-09 (oc13): the GAP-01/02/03/04/05 backend methods ARE built,
bench-proven and re-proven, and DEPLOYED on the staging pairing in
image oc13 (see the oc13 entries at the end of §9); the own-frontend
packaged build `v-751315221a5b` is served at route `/operqon` on the
tenant site with the W1–W4 auth/session wiring applied (live mode,
session bridge, envelope unwrap, roles → nav) and the
`role_home_page` flip to `/operqon` taken. STILL IN FLIGHT (rides
oc14): the per-surface live data-source wiring (switching the
own-frontend surfaces from fixture sources to the live GAP methods
end-to-end) and the print-format validation remedy named in the
oc13 entry. UPDATE 2026-11-09 (oc14): oc14 IS DEPLOYED on the
staging pairing (see the oc14 entry at the end of §9) — packaged
frontend `v-9693b59c694f` with the live flips taken (auth mode
"live", `homeSource`/`stockSource`/`accountsSource` "live"), and
LIVE-DATA proof PASS for all 7 governed roles: Home / Stock /
Aging / GL serve real tenant data, `isSample=false`, seeded known
answers matched. The print-format fix is proven in oc14, and
entry-path convergence holds on fresh login, site root and the
apps tile (ONE residual gap: a legacy `/app/operqon-home`
bookmark still opens the Desk SPA — see the oc14 entry; the fix
rides the next image cycle). STILL SAMPLE-BACKED: Sales/Buying
list+form screens, POS, and Trial Balance + other reports — no
proven live server methods yet; those are the next build lanes,
and the sample banner remains on those screens. UNCHANGED: console + portal designs come from the
owner separately (not yet received); the demo2 self-service run
COMPLETED 2026-11-10 (see the demo2 entry at the end of §9);
Slice 10 (W1 close) still awaits his go-ahead. OPEN (coordinator
item, not an owner decision right now): the >5,000-document story
— the GAP methods' 5,000-row fetch cap silently drops the oldest
documents from totals past 5,000 rows; server-side aggregates are
the recorded follow-up direction; NOT fixed.

## 8. KEY REFERENCES

- Goal workspace: `~/workspace/goals/operqon-erp-r2-completion-and-vps-deployment/`
  — `files/` (blueprint ZIP/PDF, specs, runbooks, this file), `hidden_files/`
  (verification + deploy reports: r4, r41, github-* series), `GOAL.md`.
- Verification/deploy reports are the evidence base — read them before re-asking
  questions they already answer.
- ChatGPT working chat (fallback builder): "Master Copy Tasdeeq",
  ERP-CUSTOMIZATION project, conversation 6aedcb75-1288-83ed-9fb1-7ef55c4c88ea.
  It has confirmed (2026-11-06 23:48 PKT): GitHub source of truth, approved commit
  283368f9, no-ZIP delivery policy, R4.2 queued.
- Blueprint progress baseline (2026-11-06): planning 100%; implementation ≈8–10%
  of total blueprint scope; the SaaS control-plane slice ≈60–65% (rises sharply
  when Q2+Q3 complete). Full blueprint is a multi-month programme by its own
  estimates — never promise it "by tomorrow".

## 8B. AGENT TEAM (formed 2026-11-07 ~00:15 PKT on the owner's order — 13 lanes + coordinator)

The coordinator (main Muse in the ERP side chat) reviews every lane's output
before anything reaches production; lanes work in isolated trees
(`~/workspace/operqon-team/<lane>/`, `~/workspace/operqon-w1-build/`) and write
reports to `hidden_files/team-*.md`. Lanes: (1) W1 Slice 1 foundation + posting
proof [building]; (2) Slice 2 platform trust [building]; (3) Slice 3 membership
[local phase]; (4) Slice 5 purchase/period-close [local phase]; (5) Slice 7
supply [local phase]; (6) Slice 8 commerce [local phase]; (7) independent QA /
acceptance catalogue; (8) Q2 pricing preparation (runbook — owner's session
executes); (9) Q3 provisioning preparation (runbook + Frappe OIDC design +
site_users fix spec); (10) R4.2 gateway adapter preparation (credential-free
parts); (11) W2 Pakistan pack plan; (12) legacy stacks audit (read-only);
(13) observability audit + plan. Slices 4/6/9/10 lanes open as their
dependencies (Slices 1/3/5/8) land. If a successor continues this programme:
re-form lanes the same way, one report file per lane, coordinator reviews all.

## 9. UPDATE LOG (append one line per milestone; newest last)

- 2026-11-06 23:46 — R4.1 deployed + accepted + GitHub gate VERIFIED (283368f9). [Muse]
- 2026-11-06 23:48 — ChatGPT confirmed sync + no-ZIP GitHub rule; R4.2 queued. [Muse]
- 2026-11-06 23:53 — Owner's screenshot visually confirmed the fixed console design. [owner]
- 2026-11-06 23:55 — Owner switched the working model: Muse builds directly;
  this handover file created as the continuation mechanism. [owner + Muse]
- 2026-11-06 23:58 — Owner granted FULL APPROVAL: no approval asks; complete the
  programme end-to-end (GitHub included). W0 off-VPS backup work in progress. [owner + Muse]
- 2026-11-07 00:00 — Q1 core done: provider DB joined the restic→R2 off-VPS backup
  (snapshot e15aefaf) and a restore from the off-VPS copy was proven. Retention +
  healthcheck for the provider leg in progress (part 2). [Muse]
- 2026-11-07 00:03 — Q1 part 2 done: provider retention policy + weekly timer live
  (dry-run proven tag-safe). Healthcheck ping awaits one owner-created check.
  Q1 closed except the two owner micro-items. W1 scoping started. [Muse]
- 2026-11-07 00:08 — W1 plan delivered (ENG-013–060; 10 slices; gap map 1/48 live).
  Readings R4 (controlled pilots for the wave gate) + R7 (Q3 after Slice 1)
  adopted + recorded. Slice 1 build commissioned (foundation + posting proof,
  disposable site only). [Muse]
- 2026-11-07 00:15 — Owner ordered a 10–15 agent team with work divided: 13 lanes
  formed (§8B), each with an isolated tree + a team-*.md report; coordinator
  reviews everything before production. [owner + Muse]
- 2026-11-07 00:18 — Team lane delivered the W2 Pakistan plan (ENG-061–096;
  FBR via licensed integrator only; 9 slices; owner decisions + 15 unverified
  items recorded in Q6). [team → Muse]
- 2026-11-07 00:22 — Pricing prep lane: session runbook + 4 flow findings (legacy
  SAR draft, SAR trap, minor-unit values pinned, seat price MISSING) + defects
  D1–D7. Fix lane commissioned for D2/D3/D5/D4 — deploy before the pricing
  session. Seat prices flagged to the owner as the one missing input. [team → Muse]
- 2026-11-07 00:24 — Slice 8 (commerce) local phase complete: 38/38 contract
  tests (ENG-049–053/058/059), handoff payload v1 to Slice 1 defined; 10 bench
  proofs queued behind Slices 1+7. Report team-slice8-commerce.md. [team → Muse]
- 2026-11-07 00:25 — Observability audit found LIVE defects: the health watch
  itself fails every 120s (missing capacity JSON; ~700 alert webhooks/day) and
  operqon-r2-maintenance has failed hourly since 2026-11-06 13:00 UTC (missing
  grant on public_intake_rate_limits). Fix lanes commissioned for both
  (team-maintenance-fix.md, team-watch-fix.md). Full gap list G1–G10 in
  team-observability.md. [team → Muse]
- 2026-11-07 00:26 — QA lane complete: R4.1 suite independently reproduced
  (74/3), 46/46 harness assertions PASS (queue contract, role verifier, alembic,
  manifest 139/139, sign-in chain, secret hygiene); coordinator ran the live
  console parity check himself — ALL PASS. Standing rule adopted (F-1): a
  release whose deploy script omits any shipped frontend file (assets included)
  fails QA. ACC-15/18/10 gap lane commissioned. [team → Muse]
- 2026-11-07 00:27 — Slice 7 (supply) local phase complete: ENG-037–048
  validation matrix + stock-ledger oracle + policies + fixtures, 38/38 tests,
  bench harness (13 scenarios) ready; all bench proofs await Slice 1.
  Report team-slice7-supply.md. [team → Muse]
- 2026-11-07 00:28 — Legacy audit: Demo's DB lives inside Pilot's MariaDB
  (Pilot is load-bearing for the public demo); operqon_core original source
  found only on the VPS (not in git) — archive lane commissioned to rescue it
  to GitHub + archive RC2. Nothing removed. Report team-legacy-audit.md. [team → Muse]
- 2026-11-07 00:29 — Provisioning prep: paid path has NO human approve step
  (approval is inside payment settlement); the 5 acceptance tenants are stuck
  at "provisioning" on the ping/publication gate; ERP SSO unimplemented (env
  var is dead config); site_users 4-layer root cause + F1–F4 spec. Rektrs =
  controlled pilot on the staging pairing (adopted). site_users fix lane
  commissioned. Runbook supersedes Q3's older summary. [team → Muse]
- 2026-11-07 00:30 — Slice 2 (platform trust) local build complete: 108/3 tests
  (ENG-013 adversarial OIDC, ENG-014 link guard + unlink endpoint, ENG-020,
  ENG-023 audit old/new, ENG-024 secret inventory); no migration. It deploys
  later as ONE bundled control-plane release with the pricing fixes, site_users
  fixes and ACC gaps — after coordinator review. [team → Muse]
- 2026-11-07 00:31 — R4.2 prep complete: Easypaisa + PayFast adapters built to
  the existing gateway pattern (32 mock tests; code ≈85%); completion waits on
  the exact merchant-input checklists now recorded in Q4 (Easypaisa onboarding
  lead time ~7–15 working days). [team → Muse]
- 2026-11-07 00:32 — Slice 5 (finance close) local phase complete: P2P cycle +
  period close fixture-proven, 50/50 scenario assertions (report
  team-slice5-finance.md). INTEGRATION ITEMS for the bench phase: (B2) verify
  Slice 1's bootstrap ensures input-tax, SRBNB and bank accounts (its CoA
  template v1 reportedly ensures output_tax only) — add before Slice 5's
  B1–B7 proofs; (B3) classify ERPNext's native price-variance posting against
  the proven clearing-account semantics before building any extension. [team → Muse]
- 2026-11-07 00:33 — Slice 3 (membership) local phase complete: 72/72 tests;
  ENG-015 CustomerMembership + migration 0011 (any pricing migration is 0010
  and sequences first), merged Team roster, anti-takeover scope rules;
  ENG-016 deny-by-default role/branch policy (6 roles × 18 DocTypes, F01–F18
  denial catalogue). Coordinator merges its hooks snippet into Slice 1's
  hooks.py at integration. Bench proofs B1–B9 pending. [team → Muse]
- 2026-11-07 00:35 — Pricing fixes built (82/3 tests): D2 reject endpoint +
  full state machine, D3 approver sees amounts read-only, D5 currency bound to
  country (PK→PKR, SA→SAR), D4 dead merge removed; migration
  0010_pricing_proposal_rejection (additive, forward-only) — rehearsal owed
  before production; sequences before 0011. Disclosure: two baseline tests had
  encoded the D5 bug (SAR literals) — literals corrected, assertions unchanged.
  Deploys in the bundled control-plane release. [team → Muse]
- 2026-11-07 00:36 — Maintenance job FIXED live: migration 0006 had omitted
  DELETE on public_intake_rate_limits (the prune needs it); single GRANT
  applied, manual run success, backlog assessed = zero drift (nothing ever
  qualified for expiry/overdue during the outage). Durability TODO for the
  bundled release: add idempotent migration 0012 carrying that grant, else a
  from-scratch rebuild reintroduces the failure. [team → Muse]
- 2026-11-07 00:37 — Health watch FIXED live (G1+G8+G7): transition-only
  alerting (state file; ok→fail / RECOVERED / set-change / 24h reminder),
  capacity leg degrades to non-alerting UNKNOWN (verify-cloudflare.sh is a
  verifier, not a producer — deliberately not scheduled; leg re-arms if a
  producer lands), new disk/inode/RAM + cert-expiry legs; 3 consecutive
  successful live runs, zero alert POSTs since deploy. Only
  monitoring/check.sh changed (backup .pre-watchfix-20261107). GitHub/manifest
  close-out sync commissioned (team-watchfix-github-sync.md). [team → Muse]
- 2026-11-07 00:37 — ACC gaps: ACC-15 (plan downgrade) BUILT + proven (115/3
  on the Slice-2 baseline; effective at period end, excess + remediation/grace,
  nothing deleted). ACC-18 has NO control-plane home (tenant-side; contract
  written, reassigned to Slice 10/IW1). ACC-10 scoped to IP-07/ENG-098 (W3).
  ⚠️ MIGRATION COLLISION: two lanes both numbered a migration 0010 — final
  chain at integration: 0010 pricing_rejection → 0011 membership → 0012
  plan_downgrades (renumbered) → 0013 maintenance grant. [team → Muse]
- 2026-11-07 00:38 — Legacy rescue done: operqon_core original source pushed
  to GitHub branch archive/legacy-operqon-core-source (fce083da; secret scan
  clean; the dir did hold a .git whose 8 commits existed nowhere else). RC2
  fully archived + restore-verified off-VPS (restic d9222abd) — removal lane
  commissioned (dead stack, zero dependencies; its two secrets files are the
  accepted discard). Pilot/Demo untouched. [team → Muse]
- 2026-11-07 00:40 — SLICE 1 PROVEN on a real bench (w1proof.stage…): all 5
  named tests green — bootstrap idempotent (96 accounts), opening TB balanced,
  ACC-01 order-to-cash exact, ACC-02 credit note, ENG-030 payment ceilings +
  concurrency; company TB Dr=Cr=178,180. No engine gap: failures were the
  wizard-less site layer (empty ERPNext setup fixtures), now ensured by the
  bootstrap itself. Slice 1b commissioned: reconcile the 3 app copies, merge
  Slice 3's access pack + settle Slice 5's B2, bake the app into the staging
  bench image, extend the executor create path, prove test 6 end-to-end.
  [team → Muse]
- 2026-11-07 00:42 — site_users fixes F1/F3/F4 built (87/3; manifest 140):
  roster carries an honest status (ok/unavailable) instead of silent empties,
  built-ins excluded from seat counts, 6h manifest refresh via executor-key
  internal endpoints, NO migration. Deploy order is API first, executor
  second. INTEGRATION lane commissioned to merge everything (Slice 2 +
  pricing + ACC-15 + site_users + Slice 3 control plane) into one release
  tree with the 0010→0013 chain, F-1 audit, PG rehearsal and QA re-run —
  deploy follows coordinator review. [team → Muse]
- 2026-11-07 00:43 — RC2 REMOVED: 7 containers, 4 volumes, scaffold +
  orphaned volumes cleared (dangling = 0); +537 MB RAM available measured;
  post-checks all pass (Pilot/Demo/live stacks untouched, readyz 200/200,
  watch green). Restorable from restic d9222abd except its two secrets files
  (accepted discard). Legacy left: Pilot + Demo only. [team → Muse]
- 2026-11-07 00:44 — Watch-fix GitHub close-out done: check.sh synced into
  the source of truth (manifest still 139, one line changed), snapshot
  1a6b79a7 + RELEASES receipt 43ea25d4, gate VERIFIED — the approved-commit
  marker is now 1a6b79a700837e48bd6ac16d3bc1b9e6c2a78558. [team → Muse]
- 2026-11-07 00:48 — Owner directive: team size is the coordinator's call;
  development must stay error-free AND fast (parallelism, never cut gates).
  Team scaled to 7 running lanes: + Slice 4 (support), Slice 6 (assets/FX),
  Slice 9 (POS/portal) local phases, Q3 dress-rehearsal Pass A (current code,
  real APIs, disposable tenant), observability phase 2 (G2 maintenance +
  G3 provisioning failure visibility). [Assad → Muse]
- 2026-11-07 00:54 — UI/UX DESIGN TEAM formed on the owner's order: redesign
  the whole Operqon surface set to a best-in-class standard, inspired by
  Mobbin + Page Flows + Awwwards + Behance + Dribbble. Owner authorized
  account creation via Google sign-in (assadchoudharry@gmail.com) on such
  design-reference sites; coordinator limits: free tiers only, no purchases
  or card details. Wave 1: showcase pattern harvest (public), Mobbin/Page
  Flows browser harvest (sign-in on those two sites), scored audit of the
  deployed surfaces. Design-system + synthesis lanes follow. [Assad → Muse]
- 2026-11-07 00:58 — Design audit done (team-design-audit.md): intake 7.8 +
  tenant home 7.9 are the reference standards; console 5.4, portal 5.6,
  tenant branding coverage ≈2 (95% stock ERPNext). Headline defects: money
  actions on native prompt()/confirm() dialogs (bank verify = 3 prompts; no
  modal anywhere — unlink/downgrade UIs must NOT become more prompts), the
  billing ledger prints raw minor units ("750000 PKR"), failure styled as
  success (audit-integrity box), 4-way token fork with drift started, AA
  contrast failures, and the apex site.css exists in NEITHER package
  (rescue check = design-system lane Task 0). Design-system lane
  commissioned (tokens, kit, modal spec, redesign spec, quick-wins brief
  sequenced after the bundled release). [team → Muse]
- 2026-11-07 00:59 — Showcase research done (team-design-research-
  showcases.md): 18 references; top-5 = Infinify, Atomus (brand-as-token-
  mode), Virgil Pana DataGrid, PlanINN (+65% table width), HRMS; portal
  target = four-quadrant billing page with seat progress bars; direction =
  two-layer tokens with density modes, Inter + tabular numerals. Folded
  into the design-system lane. Mobbin/Page Flows harvest still running
  (owner completed the Mobbin login ~00:57). [team → Muse]
- 2026-11-07 01:02 — Dress rehearsal PASS A complete (team-rehearsal-
  pass-a.md): real-API run green to the pricing gate — intake 202/409,
  customer link 201, identity review 200, approver-on-paid-tenant → 409
  (paid-path model proven live), portal truth exact. Invoice create → 423
  with pricing the SOLE failing conjunct (v1 draft/SAR/null; 0 price rows)
  — the expected boundary, nothing forced. Publication gate layer-exact:
  sites pong inside the bench but *.stage.operqon.cloud has NO public DNS
  and Caddy has NO staging route — hostname-readiness lane commissioned
  (staging suffix only). Pass B gates: pricing session, hostname fix,
  Slice 1b test 6, OIDC configure_sso, site_users deploy. Rektrs/demo2
  untouched (still requested). [team → Muse]
- 2026-11-07 01:04 — Slice 6 (assets + FX) local phase done
  (team-slice6-assets-fx.md): depreciation engine (SLM + WDV, final-row
  plug, exact salvage landing), asset book with tamper-detecting
  register↔GL reconcile, FX book + currency policy (revaluation restates
  carrying; lifetime identity proven; ACC-07 returns at original rate).
  35 unit tests + 132/132 scenario assertions. Its 6 CoA keys were missing
  from the bootstrap — routed into Slice 1b's Step 2b check (running) so
  the bench wave starts complete. Bench B1–B8 queued behind 1b. A
  return-after-revaluation policy corner is parked for B7 evidence.
  [team → Muse]
- 2026-11-07 01:05 — BUNDLED RELEASE integration complete + coordinator
  review PASSED (team-bundled-release.md): 164/3 tests (167/0 with PG),
  chain 0010 pricing → 0011 memberships → 0012 plan_downgrades → 0013
  maintenance grant, manifest 162 clean, QA 8/8. Membership scoping is
  additive (X-Operqon-Tenant header; legacy behaviour byte-identical
  without it); the bundle restores the LIVE watch-fixed check.sh so the
  deploy cannot regress the watch. Deploy fires when Slice 1b reports
  (executor files reconciled first if diverged): API → migrations →
  frontend → executor; owed at deploy: Slice 3 B1 acceptance + 7-role
  browser E2E. Fresh-install caveat recorded (alembic_version VARCHAR(32)
  vs the 33-char 0005 stamp — production unaffected). [team → Muse]
- 2026-11-07 01:06 — Slice 9 (POS + tenant portal) local phase done
  (team-slice9-pos-portal.md): 61/61 tests. Shift close reconciles to
  the paisa with maker-checker variance (nothing silently absorbed);
  offline invoices sync exactly once (replay = DUPLICATE, tamper =
  CONFLICT quarantine, revoked device = HELD); cross-outlet returns
  share one ceiling at the original grand total; portal reads are
  tenant+customer+submitted scoped with a uniform not-found. POS prices
  delegate to Slice 8's engine (proven verbatim: 45/Nos pack rule).
  POS-settlement handoff v1 to Slice 1 written. ERPNext has no POS
  device registry — a draft device DocType is the scoped answer. Bench
  B1–B9 queued behind Slice 1b. [team → Muse]
- 2026-11-07 01:07 — Observability phase 2 done (team-observability-
  phase2.md). ⚠️ OPERQON_ALERT_WEBHOOK in /etc/operqon/r2-monitor.env is
  EMPTY and always was (mtime predates all fix work): NO alert on the box
  can currently be delivered — watch included; the "~700 posts/day"
  narrative is not reproducible (earlier proofs were sink-based). One
  owner input activates everything: populate that variable via the
  secure flow (destination is the owner's choice); all consumers resolve
  it per-run, no restarts. G2 (OnFailure alerts for maintenance +
  provisioner) and G3 (provisioning failure/stuck watcher, 5-min timer)
  are installed and proven via sink + one unplanned production proof
  (a rehearsal row failed one executor run at 19:56 UTC; self-recovered,
  zero real impact). [team → Muse]
- 2026-11-07 01:08 — Slice 4 (support/attachments/search/exports) local
  phase done (team-slice4-support.md): 91/91 tests. Support access =
  time-boxed session grants with customer-side HMAC-bound consent (never
  a second role; provider self-consent impossible); download/export
  tokens re-check CURRENT state at redemption; search isolation oracle
  proves zero cross-tenant leak. Two in-lane defects fixed: error bodies
  leaked reason codes (existence oracle) and — binding lesson, design
  decision 11 — flush-never-commit + raised denials silently ERASED
  denial audits; fixed commit-before-raise on all 14 paths. A pre-deploy
  check of the BUNDLED tree for the same pattern is running. Slice 4's
  migration must renumber to 0014 at its integration. [team → Muse]
- 2026-11-07 01:09 — DESIGN SYSTEM delivered (team-design-system.md;
  artefacts in ~/workspace/operqon-team/design-system/): one canonical
  W3C DTCG token source → web/Frappe/Keycloak targets; modes (light/dark
  × brand × density) canonical, console keeps its approved default;
  AA contrast fixes computed in (incl. darkened status-text variants);
  full status-language table; money standard (raw minor units banned
  outside the pricing editor); modal spec migrating all 7 native-dialog
  groups (bank verify's 3 prompts → one evidence form); portal billing
  = four-quadrant composition; quick-wins brief sequenced on top of the
  bundled release. Task 0: site.css + logo SAFE in repo (absent from
  packages), but the live apex tree diverges from the repo (customer/
  subtree + request-access live-only) — rescued + reconciliation lane
  running; provider Keycloak theme confirmed missing in the installed
  state (owner logins render stock Keycloak). [team → Muse]
- 2026-11-07 01:10 — SLICE 1B COMPLETE, TEST 6 PASS: provisioning now
  installs operqon_core through the real executor (job attempt 1;
  manifest apps [erpnext, operqon_core]; Slice 1 harness 6/6 on the new
  site AND w1proof at template v1.1+v1.2). Hooks conflict was real —
  entitlement/access composed as 2-handler lists on 13 overlapping
  DocTypes (dict merge would have silently replaced entitlement).
  Bootstrap template v1.2: Slice 5 + Slice 6 accounts ensured (input tax
  and bank added/wired; all six Slice 6 keys ensured), w1proof 96→102
  accounts. ⚠️ MARKER ADVANCED to a99f4159 (1b's executor change; gate
  verified). RELEASES.md rows for R4.1 GA + 1b + the bundle are owed at
  the bundled close-out. Deploy lane + Bench Wave A (Slices 3/5/6
  proofs) commissioned. [team → Muse]
- 2026-11-07 01:12 — Hostname readiness done (team-hostname-readiness.md):
  the Caddy→bench half is built, live and proven (wildcard block +
  on-demand Let's Encrypt gated by a loopback ask-service that only
  approves names of sites that exist on the bench; internal-cert proof
  returned pong for w1proof + e2e-r41-final-co; production routes all
  re-verified, Caddy diff additions-only, backup
  /root/Caddyfile.pre-hostname-20261107). SOLE remaining layer = DNS:
  operqon.cloud DNS is Hostinger hPanel dashboard-only (no API token
  exists). Owner action (paste-ready): add A record `*.stage` →
  72.61.214.64, TTL 3600. Once it lands, cert issuance + the executor's
  publish retries converge on their own. [team → Muse]
- 2026-11-07 01:14 — Apex reconciliation done (team-apex-reconciliation.md):
  repo `public_portal/` now reproduces the complete live apex release
  (commit f90ea2d7; 13 files; live won over the repo's retired prelaunch
  copies; request-access.css committed for the first time; config.js
  deliberately excluded). Marker untouched. Deploy-lane flags: auth.js
  statement order — LIVE ordering is canonical (coordinator decision);
  refresh public_portal/customer/ after the bundled deploy (APEX_FILES.txt
  = the 16-entry apex manifest). The owner chose for Muse to add the
  `*.stage` DNS record himself via the browser with the saved Hostinger
  login — task delegated. [team → Muse; Assad decision]
- 2026-11-07 01:19 — DNS record ADDED via hPanel (A `*.stage` →
  72.61.214.64, TTL 3600; 13→14 records, nothing else touched) and the
  FULL PATH VERIFIED by the coordinator: w1proof + e2e-r41-final-co
  stage hostnames return {"message":"pong"} over HTTPS 200 with valid
  on-demand certs; a bogus name is refused (ask-gate working publicly).
  The publication gate is OPEN — the stuck tenants should publish on the
  executor's own cycles; first flips to be confirmed in lane reports.
  Pass B's hostname gate is CLOSED. [Muse browser + verification]
- 2026-11-07 02:06 — Bench Wave A reported (team-bench-wave-a.md).
  Slice 5: B1/B2/B4/B6 PASS, B5 numbers PASS (native close classified:
  no reason/maker-checker/snapshots — ACC-12 close stays app-layer);
  B3 CLASSIFIED as an engine/spec gap (variance PI posts its 80 as a
  residual inside SRBNB; no native clearing/disposition — the spec's
  clearing + approver flow is app-layer work). Slice 3: B4 + decision
  layer PASS; live layer blocked by THREE app-pack defects — D1
  (release-blocking: the User Scope DocTypes sit outside Frappe's
  doctype sync path and NEVER INSTALL; governed checks raise 1146),
  D2 (`is_disabled` → the pin's field is `disabled`), D3 (ToDo
  `assigned_to` → `allocated_to`). Fix lane commissioned (packaging
  regression test included). Slice 6 + final regression BLOCKED by a
  sandbox egress-proxy outage (SSH CONNECT refused since ~20:35 UTC;
  VPS healthy, HTTPS fine) — packaged for a single-connection re-run;
  no Slice 6 numbers claimed. [team → Muse]
- 2026-11-07 02:37 — ✅ BUNDLED RELEASE LIVE (team-bundled-deploy-resume.md):
  production at alembic 0013; merged executor ac4f34bf… (1b hunks ∪ F1/F3,
  diff-proven both ways); auth.js aligned to the live ordering
  (2ad42edc…); suite 178/3 incl. the containerised run (a Dockerfile.test
  data-omission was caught by the deploy's own gate, rolled back cleanly,
  fixed, relaunched — gate lesson: run the suite inside Dockerfile.test).
  Acceptance ALL PASS: 7-role MFA E2E (billing_approver verify+reject),
  Slice 3 B1, pricing-reject exercise (PK v1 untouched), membership
  smoke, audit 125→129, parity 5/6 (delta = the stale QA golden).
  Bonus: the merged executor provisioned the fixture tenant end-to-end
  (ACTIVE, apps [erpnext, operqon_core]) and self-healed all 8 published
  rosters. Rektrs/demo2 still requested. STEP 6 (GitHub close-out)
  PREPARED but blocked: push approval cards keep expiring + the SSH
  outage blocks the $ROOT sync — staged at
  ~/workspace/operqon-team/bundled-release-push/ with exact commands in
  the report §6 (Push A snapshot, Push C RELEASES — only 2 rows missing:
  1b a99f4159 + this bundle; R4.1 GA's row already exists — then marker
  advance + gate). Until then the marker knowingly lags production.
  [team → Muse]
- 2026-11-07 01:15 — Bundled deploy lane PAUSED AT GATE 0 by design
  (team-bundled-deploy.md): the denial-audit check had not reported, so
  nothing was installed and production is untouched. Pre-flight PASS
  (gate VERIFIED a99f4159; readyz 200/200; production at 0009; backup
  dump sha256 7f089e73… + restic snapshot 2a9aea3f) and the disposable-PG
  rehearsal PASS (fresh dump → 0013; DELETE privilege flips f→t exactly
  at 0013; data preserved). Resume the deploy the moment the
  denial-audit report lands; the resume kit (executor hashes, apex
  flags, file-mode lesson) is in the deploy report. [team → Muse]
- 2026-11-07 01:16 — Denial-audit check CLEAR (team-denial-audit-check.md):
  no Slice-4-class defect in the bundle; all 17 denial paths proven to
  lose nothing (denials raise before any audit append; audits record
  committed transitions only). The one flush-then-raise (settlement →
  activation conflict) is a documented single-transaction unit — rolling
  back is CORRECT there; "fixing" it would falsify the audit chain.
  Suite 178/3, QA 8/8, manifest 163 (one added test file, zero shipped
  hashes changed). Denial-audit coverage gaps G1–G4 logged as a
  post-launch hardening feature (ride with Slice 4's integration).
  DEPLOY RESUMED (team-bundled-deploy-resume.md). [team → Muse]
- 2026-11-07 05:49 — App-pack defects FIXED + committed (team-app-pack-fixes.md):
  D1 DocTypes relocated to the module sync path (byte-identical), D2
  `disabled`, D3 `allocated_to` — both field fixes evidenced from the
  pinned tags (ERPNext v16.53.0 cost_center.json; Frappe v16.54.0
  todo.json). Suites: app-pack 38, entitlement 22 (+63 subtests); NEW
  packaging regression test shipped with the app (fails on the old
  layout by name). Commit 42a1d2d6 (app only; marker stays a99f4159).
  Slice 3's test had hard-coded the defective path — fixed, assertions
  unchanged. 1b's install runbook carries a dated correction.
  OUTSTANDING: the 7 old-path files still exist in the REPO (deletes
  died on approval timeouts/restarts; install-inert, but the packaging
  test fails on a raw clone until removed — exact commands in the fix
  report §5). Bench re-proof (oc3 bake + P0–P6 + harness) packaged at
  ~/workspace/operqon-team/app-pack-fixes/, waiting on SSH like the
  Slice 6 re-run and Step 6's $ROOT sync. [team → Muse]
- 2026-11-07 06:07 — Design QUICK WINS built (team-design-quick-wins.md):
  all 11, frontend-only on the bundled tree; pytest 192/3, node 15/15,
  QA 9/9, manifest 169 clean; DOM-harness render proofs portal 19/19 +
  console 20/20 (incl. failure-never-styled-as-success); contrast all
  ≥4.5:1. ⚠️ The kit's money-formatter snippet was WRONG for PKR (Intl/
  CLDR gives exponent 0 → "PKR 750,000" for Rs 7,500 — a 100× misread);
  the lane pinned PKR/SAR to ISO 4217 exponent 2 (TOKENS.md itself
  still needs the correction — token-infra lane). Deploy = a small
  frontend release queued behind SSH recovery (after Step 6's sync,
  the app-fix bench and the Slice 6 re-run). [team → Muse]
- 2026-11-07 07:58 — ✅ STEP 6 CLOSE-OUT COMPLETE (team-close-out-step6.md):
  SSH recovered; owner go-ahead given. Push A (bundle snapshot) =
  7346c528… = the NEW approved marker (gate VERIFIED at it; $ROOT
  manifest 163/163; clone + marker file both at S1). Push B RELEASES
  e02cc00e, Push C portal refresh f9125041, handover cbd56e7f. The 7
  old-path DocType files are DELETED (head 69041b88) — the repo has
  exactly one DocType location. readyz 200/200, failed units 0,
  Rektrs/demo2 still requested (coordinator-verified). The GitHub
  close-out queue is EMPTY; marker == production. [team → Muse]
- 2026-11-07 07:59 — App-fix bench (team-appfix-bench.md): image oc3
  live on the staging pairing; **D1 + D2 CLOSED** on a real
  executor-created site (P0–P3 PASS: DocTypes + tables present, six
  scope records inserted, policy matches, cost-center tree works).
  P4–P6 did NOT run — the proof script's own make_si doesn't pin
  currency and fresh sites default to INR (harness gap, not an app
  defect; one-line fix, re-run commissioned). Harness posting proofs
  3/3 on the oc3 site; the bootstrap count "failure" is the package's
  own step ordering (proofs before harness on one site), idempotency
  itself proven (102==102). ⚠️ Both new fixture tenants sit at
  `provisioning`/`created_unpublished` though their sites answer pong —
  publication flip never landed; diagnosis lane commissioned (first
  hypothesis: the staging proxy's bridge-IP target went stale when
  the backend was recreated for oc3 — hostname G2). [team → Muse]
- 2026-11-07 08:03 — Completion lane (team-appfix-completion.md):
  **P4–P6 ALL PASS (16/16)** after pinning currency in the harness's
  make_si (test tooling only). B2 composition decides live (Lahore
  True / Karachi False / Beta False / Admin None), B5 rejects the
  cross-company row with the exact message, B6 + D3 exercised
  (deactivate_user reassigns via allocated_to). **D1/D2/D3 ALL CLOSED
  on a real site.** Publication mystery SOLVED: it is the
  payment-proof gate BY DESIGN (main.py:1087–1152 — auto-publish
  needs the payment-automation stamp + a paid invoice + an
  independent proof + all verification flags); DB-inserted trialing
  fixtures fail its first condition, which is why NO fixture (1b,
  Wave A, app-fix) ever auto-published — DNS was never the constraint
  (G2 eliminated: bridge IP 172.25.0.5 == Caddy's target). Fixtures
  waived as evidence. ⚠️ Q3 NOTE: a real TRIAL tenant can never pass
  that gate; its publish path is the operator endpoint
  POST /provisioning/{job_id}/publish — the Pass B runbook must carry
  that step. [team → Muse]
- 2026-11-07 08:31 — Slice 6 bench COMPLETE (team-slice6-bench.md) —
  Bench Wave A fully done. B1/B5/B7 PASS; B3 mechanics PASS (fixture
  contamination on the sale leg); B4 tax-split PASS but NO Asset is
  auto-created by PR/PI on this pin (the app phase must create it);
  B8 identity reconciles. Classifications: **WDV/pro-rata anchoring**
  — ERPNext posts a 1-day stub then anniversaries (lifetime totals
  EXACT, curve differs from the oracle); **ERR lifecycle = restate +
  explicit reversal** (make_reverse_journal) — the period-end
  procedure must include the reversal step; scrap convention = WITH
  disposal-period pro-rata. **A6 DECIDED from measured evidence:** a
  return after a revaluation strands qty×(restated−booked) (+2000
  measured; control run exact) — the CurrencyPolicy is amended: such
  a return must also reverse the returned portion's unrealised FX.
  w1proof harness 6/6; all closing checks green. [team → Muse]
- 2026-11-07 09:09 — ✅ QUICK-WINS RELEASE LIVE (team-quick-wins-deploy.md):
  **marker S2 = 10a51af4…** (gate VERIFIED; $ROOT 169/169; RELEASES row
  live/provider-quickwins-2026-11-07). Frontend-only (head still 0013).
  Live proofs: DOM harness 14/14 (danger banner on stubbed audit
  failure; "Rs 12,345.00" — raw minor units never render); formatter
  corpus vs live 11/11 incl. 750000 PKR → "PKR 7,500.00"; 7-role MFA
  E2E; parity 6/6 after re-pins (tenants.html eb931df1). Deploy took 4
  attempts — #1 rolled back at migrate with a brief API outage:
  **the 0640 mode trap left by Step 6's $ROOT sync** (uid 10001 could
  not read the sources; rollback restored the same unreadable tree).
  STANDING RULE: $ROOT syncs stage from a mode-normalised (0644) copy
  (in RELEASES.md + AGENTS.md). Portal got a documented tokens bridge
  (the apex fork lacked the 11 QW-10 vars; appended byte-exact) until
  the token-infrastructure lane kills the fork. [team → Muse]
- 2026-11-07 09:41 — Bench Wave B COMPLETE (team-bench-wave-b.md).
  Slice 7: 12 PASS (serial race exactly 1/20) / ENG-045 GAP (count
  variance needs the maker-checker extension). Slice 8: B8 joint exit
  exact; credit race invariant holds but via a DB deadlock, not the
  polite refusal; **pricing is currency-exact + UOM-exact upstream
  and has NO specificity precedence — ENG-051 determinism is an
  extension**; Pricing Rule validate silently clears customer scoping
  unless applicable_for is set (trap). Slice 9: B8 PASS via Merge-Log
  consolidation (**POS Invoices post NOTHING directly on this pin**);
  GAPs measured for the designed extensions ENG-054 (close variance
  accepted unapproved), ENG-055 (offline dedupe is name-deep only),
  ENG-056 (cross-outlet returns pass the sold quantity); tenders must
  settle the ROUNDED total (PKR fraction 0.0 + Banker's rounding).
  Slice 4: BP-1 PASS — merged tree suite 271/1, migration
  0014_support rehearsed clean 0013→0014; support role MISSING from
  Slice 3's matrix (integration must add it); fresh-chain dies at
  0005 on a from-zero DB (VARCHAR(32) version table — pre-existing);
  BP-6/BP-7 partial, gated on Slice 4's own integration. Isolation
  held at every CHECKED surface (model-layer APIs are unchecked by
  Frappe design — claims must be stated at checked surfaces).
  Provisioning note: fresh sites default to INR (2.9446) until pinned
  — the bootstrap should pin the default currency. [team → Muse]
- 2026-11-07 10:41 — Slice 4 integration BUILD complete
  (team-slice4-integration.md; tree operqon-team/slice4-integration/,
  bundled-release base — build only, no deploy). Migration 0014 as
  rehearsed; both routers mounted; consent route customer-surface
  only; routes 65→81 (+16/−0); suite 281/3, zero regressions. Support
  role added to the role matrix (17 rows; install converges {7,115};
  live re-proof is a Wave-C bench item). Denial-audit G2 implemented
  (membership denials audited commit-before-raise, responses
  byte-identical); G1/G3/G4 deferred per the denial-audit report's
  own guidance. Release composition notes: the next release must
  compose production-as-it-stands (bundled + quick-wins frontend)
  ∪ this tree ∪ gateway-settings (0015) — and the EXPORT-COMPLETION
  DRIVER must be commissioned before that deploy (exports otherwise
  stay queued; support sessions unaffected). [team → Muse]
- 2026-11-07 10:46 — Gateway settings BUILD complete (owner decision
  of 10:26 executed; team-gateway-settings.md; tree
  operqon-team/gateway-settings/). Console-managed gateway config:
  migration 0015 (after 0014), secrets AES-256-GCM at rest (master
  key from a server key FILE; app boots without it, secret writes
  503), operator-only settings API (masked GET, write-only secrets,
  audit names field names only), resolve_gateway() DB-first with env
  fallback (no console row ⇒ legacy behaviour exactly), settings UI
  in the shipped console design + Notifications card for the alert
  webhook (test ping real; gateway "test" is an honest stub until
  merchant onboarding). Suite 214/3, zero regressions. Deploy notes:
  create deploy/secrets/settings-encryption-key (600, uid 10001)
  before first boot AND back it up; host monitoring still reads the
  webhook from r2-monitor.env — a host-sync step at deploy makes the
  console value effective. The tree never deploys standalone
  (depends on 0014). [team → Muse]
- 2026-11-07 10:47 — Release composition lane commissioned: merge
  the Slice 4 tree + gateway-settings tree into one deploy-ready
  tree (operqon-team/release-r42/), build the export-completion
  driver, real-PG rehearsal of 0013→0014→0015, union suite, deploy
  runbook. Deploy itself remains a separate coordinator step.
  [team → Muse]
- 2026-11-07 10:52 — TEAM EXPANSION (Assad's order: grow the team,
  raise the speed). 6 new parallel lanes, all local builds:
  pack-guards (ENG-045/054/055/056), pack-finance (Slice 5 B3 +
  ACC-12 + Slice 6 app phase + A6 rule), pack-commerce (credit
  serialisation, CM01 ledger, ENG-051 layer), token-infrastructure
  (one token source + generator + Keycloak themes + TOKENS.md fix),
  oidc-sso (configure_sso step + roster gate + R11 harness — the
  last Q3 gate), design-modals (all 7 dialog groups off
  prompt()/confirm()). With composition, 7 lanes run in parallel;
  bench re-proofs ride Wave C. [team → Muse]
- 2026-11-07 10:58 — Release composition COMPLETE, deploy lane
  commissioned on the report §9 runbook (team-release-composition.md;
  tree operqon-team/release-r42/). Accounting: 182+30+3 = 214
  manifest entries, sha256 clean, modes 644. Export driver built
  (rides the hourly maintenance pass; crash rolls back to queued;
  unconfigured store ⇒ visibly queued, never failed). Suite 323/3
  (192+22+103+6), zero regressions; REAL PG16 rehearsal: single
  head 0015, stepwise 0013→0014→0015 verified; routes 88 = exact
  union; frontend parity 21/21. Deploy includes: S3 push, settings
  encryption key creation (+ coverage check), export dir, live-
  compose delta, webhook host-sync (or the armed one-command sync
  script if the console value is still empty), full acceptance
  incl. the first live support round trip. [team → Muse]
- 2026-11-07 11:02 — Token infrastructure COMPLETE
  (team-token-infrastructure.md; tree operqon-team/
  token-infrastructure/). One generator emits 10 files from the
  canonical token source (web ×3 surfaces, Frappe CSS, Keycloak
  themes for BOTH realms — the provider theme now exists);
  generation aborts on any AA contrast failure (31 pairs pass).
  Fork map: every live copy hashed; the 11 QW-10 vars are source
  tokens; all 30 apex defs asserted in the target. COMPONENT-KIT
  §5's formatter snippet corrected byte-for-byte to the shipped
  money module (PKR/SAR exponent-2 pin). Drift check negative-
  tested; --release mode shows today's fork (3 differing, 5
  missing) as the switchover baseline. Open at switchover: 9
  console chrome hexes exist in no token source (explicit decision
  listed in the map). Switchover rides a later release. [team → Muse]
- 2026-11-07 11:04 — Commerce pack COMPLETE (team-pack-commerce.md;
  tree operqon-team/pack-commerce/). All three builds behind
  Commerce Settings flags, DEFAULT OFF (ungoverned docs keep
  byte-identical native outcomes): ENG-053 serialised credit check
  (Customer-row lock at before_submit; loser gets the polite
  refusal — 25-thread race passes WITH a hazard control proving
  the unlocked failure mode), CM01 append-only commission ledger
  (B7 numbers exact: net 7,500), ENG-051 pricing layer (oracle
  resolver on real Pricing Rules; P05 0.34 USD + P09 45/Nos at
  document level; two-sided S8-4 defence — a silently-globaled
  rule prices NOBODY). Proof 61 + oracle 38/38 + packaging PASS.
  Open for Wave C: the P01 pre-emption closure decision (C-1) and
  commission cancellation semantics. [team → Muse]
- 2026-11-07 11:04 — Modals COMPLETE (team-design-modals.md; tree
  operqon-team/design-modals/). All 7 live dialog groups off
  prompt()/confirm() onto one shared modal component; bank verify's
  two 3-prompt chains are ONE evidence-form flow (formatted amount,
  attestation). Legacy wire behaviour was captured FIRST, then the
  DOM harness proved payloads BYTE-EQUAL (incl. two deliberate
  quirks: notice-reject sends the reason raw, pricing-reject
  trimmed); Esc = zero API calls everywhere. Unlink wired into the
  Identity panel; downgrade wired into subscription rows;
  downgrade-cancel + membership exported/proven, awaiting a panel
  anchor. Pytest 199/3, node 15/15, native-dialog grep = 0.
  Composition note: merge with the gateway-settings frontend in
  DISJOINT regions; keep ONE .modal-* CSS copy; never deploy this
  tree standalone over the settings build. [team → Muse]
- 2026-11-07 11:05 — Guards pack COMPLETE (team-pack-guards.md;
  tree operqon-team/pack-guards/). All four bench-measured GAPs
  built: ENG-054 variance approval (per-tender amounts must EQUAL
  the close; guard at before_submit — validate would deadlock its
  own workflow), ENG-055 pos_sync endpoint (POSTED/DUPLICATE/
  CONFLICT-quarantined/HELD-posts-exactly-once; device revocation
  terminal), ENG-056 cross-outlet return ceiling (Wave B's breach
  now refuses, remaining=1), ENG-045 count maker-checker (Slice 7
  policies.py verbatim in-app). 152 tests + packaging green
  (Slice 7 38/38 on the app copy; Slice 9 61/61 vs its oracle).
  CROSS-LANE FIND: Frappe hands hooks FLOATS while lane money
  layers are Decimal-only — adapters bridge at the boundary;
  fingerprints always hash the RAW payload (relayed to the finance
  lane live). ENG-040's hook ships unwired by design (decision
  function in policies.py; wire at composition). [team → Muse]
- 2026-11-07 11:10 — Finance pack COMPLETE (team-pack-finance.md;
  tree operqon-team/pack-finance/). All six: B3 variance clearing
  (detection beside PI submit, advisory; stock-never-touched
  enforced in code — plan accounts ⊆ {srbnb, price_variance,
  cogs}), ACC-12 controlled close (reason forced; reopen
  maker≠checker; deny-only guard on 7 voucher types), B4 explicit
  Asset creation (per-unit, net of tax), B6 FX procedure (settlement
  refuses until the reversal is booked), A6 amended return rule
  (pack scenario exact: AR 232000, unrealised −8000, lifetime
  identity holds), own depreciation curves (JE-posted). Proof:
  oracles 23/50 + 35/132 + pack 42 + packaging, all green. The
  guards lane's float-boundary note is applied + test-backed
  (Decimal(str()) funnel; fingerprints raw). DEFECT IT CAUGHT:
  finance key srbnb didn't resolve in CoA template v1.2
  (stock_received_but_not_billed) — every clearing/depreciation JE
  would have raised live; fixed at the resolver funnel + pinned.
  Merge decision due: template v1.3 fold-in of the price-variance
  account. [team → Muse]
- 2026-11-07 11:13 — OIDC configure_sso BUILD COMPLETE
  (team-oidc-sso.md; tree operqon-team/oidc-sso/) — the last Q3
  gate is built. Executor step between ensures and backup creates
  the per-tenant confidential client operqon-erp-<slug> (standard
  flow only, one redirect URI); re-runs converge, secret rotates;
  the secret crosses into the bench ONLY via docker-exec stdin
  (asserted absent from argv/stdout/marker/completion/audit). Site
  side rosters the tenant admin AT PROVISIONING (F2 lands);
  sso_gate on both login hooks — non-roster → account disabled +
  PermissionError; fail-closed on an unreadable roster; password
  logins untouched. Provider suite 201/3 (+23, zero regressions);
  failure honesty proven (mock KC 500 → job fails before backup).
  R11 harness 5/5 (non-roster refused + auto-account disabled;
  revoked member refused next login). One PRE-EXISTING app-suite
  failure flagged (Slice 3 widened has_permission past an old
  test's expectation — reconcile at composition, not the lane's).
  Pass B live exercise (coordinator-run) needs: the bootstrap
  admin + secret file on the VPS, one non-roster KC fixture, and
  the four contract-built seams verified on the pin. All six
  expansion lanes + composition now complete; only the r42 deploy
  is in flight. [team → Muse]
- 2026-11-07 11:39 — RELEASE-R42 DEPLOYED + ACCEPTED
  (team-release-r42-deploy.md). **Marker S3-final fca77629…**
  (receipt d560a144; the deploy lane's own handover push ae1928a3
  is the branch head — this local entry rides the next push).
  Alembic 0015; suite 323/3 in the REAL Dockerfile.test image;
  readyz 200/200; audit chain OK (213 events); Rektrs/demo2 still
  requested. THREE attempts: (1) suite gate failed — the tree's
  Dockerfile.test lacked COPY MANIFEST.sha256 (composition had
  proven in a venv replica, never the real build) and the settings
  key was staged as raw bytes while config reads UTF-8 text → a
  BRIEF API OUTAGE, recovered from the S2 git archive, DB never
  migrated. LESSON (standing): the gate runs the ACTUAL docker
  build; a venv replica does not count. Key re-staged base64
  (45 B, 600, uid 10001 → 32 B). (2) the acceptance wrapper reused
  the stale R4.1 E2E env — clean rollback to S2 code on the
  migrated DB. (3) fresh fixtures → ALL PASS: 7-role MFA E2E,
  BP-7 support round trip LIVE incl. expiry (3 denial audits),
  G2 probe (exactly 1 denial row), settings smoke, export smoke
  (artefact sha == descriptor sha; the descriptor is the download
  contract — no byte-streaming route this release), DOM parity
  byte-identical, QA 9/9. Export store actually lives at
  deploy/data/exports (compose resolves from deploy/). OWNER
  ITEM: the settings key has NO off-VPS backup (both restic legs
  are DB-only) — it joins the W0 passphrase items. Webhook:
  console value empty → env untouched; sync armed at
  /usr/local/sbin/operqon-webhook-sync (one run makes a future
  console entry effective). [team → Muse]
- 2026-11-07 11:40 — FRONTEND DESIGN TEAM formed (Assad's order:
  landing pages + website bhi). Two local-build lanes:
  frontend-apex (public website + landing + product/industries/
  pricing/about — pricing page wired to the public plans endpoint
  with an honest pre-approval state; decided prices NEVER
  hard-coded; no fabricated proof elements; generated apex tokens
  + drift check) and frontend-structural (compose modals into the
  r42 frontend, then REDESIGN-SPEC: console KPI home + two-stage
  workspace + portal four-quadrant billing; generated console/
  portal tokens; the 9 chrome hexes decided explicitly per-hex;
  payload-identity proofs per surface). Publishes/deploys remain
  coordinator steps. [team → Muse]
- 2026-11-07 11:55 — Frontend-apex COMPLETE (team-frontend-apex.md;
  tree operqon-team/frontend-apex/). Publish-shaped public site
  (25 files, manifest clean): landing reworked on verified facts
  only (design-facts strip labelled as such; Security section =
  HMAC audit, MFA roles, off-site backups), product + industries
  (14 packs, none claimed shipped) + about (no invented contacts,
  no testimonials/logos/counts anywhere), pricing page wired to
  the public endpoint — renders ONLY approved prices via the
  shipped money build; NO price figure exists in any file; the
  page lights up by itself when Q2 pricing is approved. Intake is
  presentation-only (head/CSP/form/module byte-identical to live);
  customer/ byte-identical from r42; config.js absent by design.
  Tokens = byte copy of the GENERATED target (the append-tokens
  bridge is retired). 69 checks green incl. pricing two-state in a
  real browser under the production origin shape + intake POST
  byte-parity + 21 WCAG pairings. Publish lane commissioned on the
  report's 6-step checklist. [team → Muse]
- 2026-11-07 11:59 — APEX PUBLISHED, new website LIVE at
  https://operqon.cloud (team-frontend-apex-publish.md). Drift
  gate: token re-copy byte-identical, suite green (69). Backup
  /root/operqon-portal-apex-20261107T0658Z (18-file inventory
  byte-verified). Install: exactly the 24 manifest files,
  no --delete — 5 replaced (index, intake html, tokens → the
  generated target, BRIDGE RETIRED, 2 css) + 7 added (product,
  industries, pricing, about, pricing.js, money.js, config
  example); the only live-only file, customer/config.js, was
  preserved untouched (sha ac1b03ca… before == after, contents
  never read). Live verification ALL PASS: 6 pages + /customer/
  200, served bytes == manifest pins, pricing honesty proven
  from the live endpoint (all 3 plans price_approved: false,
  monthly_price_minor: null — no figures anywhere served; the
  page lights up alone when Q2 lands), intake frozen parts
  byte-identical, console/APIs untouched (marker S3). [team → Muse]
- 2026-11-07 12:08 — OWNER CHOSE the website direction: #5
  Product-Is-The-Hero (dark navy hero, huge headline + one italic
  serif word, gold glow, OUR dashboard rising as the hero visual).
  Hero-redesign lane building it in frontend-hero/ on the apex
  base; intake page now FULLY frozen (look included); screenshots
  come to Assad for approval BEFORE any publish. References pack:
  operqon-team/frontend-references/. [team → Muse]
- 2026-11-07 12:09 — Frontend-structural COMPLETE
  (team-frontend-structural.md): modals composed into the r42
  frontend (one .modal-* set, selector-set proof), console KPI
  home (role-gated, existing endpoints only), two-stage workspace
  (tabbed; shared decision builder; modal configs identical),
  portal four quadrants (unservable spec elements = honest
  states). Suite 242/3, exactly 7 frontend files changed,
  payload-identity 10/10 + 10/10. 9-HEX DECISION CLOSED: 8 →
  console-chrome primitives in the generator source (AA gate now
  40 pairs), 1 mapped (#F7FAF9 → surface-alt); console.css has
  ZERO hex literals. S4 frontend-only deploy lane commissioned
  (real-Dockerfile gate; any backend diff vs S3 = STOP; apex
  rides byte-identical, not part of the release). [team → Muse]
- 2026-11-07 12:10 — Bench Wave C commissioned (the backend
  team's current work): pack re-proofs on the real staging bench
  (guards §7, finance 6, commerce C-1…C-12, OIDC pin seams),
  install_policy live re-proof incl. the support role, BP-6/7
  site legs, has_permission test re-pin, ENG-040 wiring. Four
  decisions to surface with evidence: P01 closure, commission
  cancellation, CoA v1.3 fold-in, POS roles into the matrix.
  Bench-direct sites (wavec-*), control plane out of bounds
  during the S4 deploy. [team → Muse]
- 2026-11-07 12:27 — Hero redesign COMPLETE, owner approval
  pending (team-frontend-hero.md; tree frontend-hero/). Direction
  5 built: navy hero #051E33 + gold glow; headline "Run the work.
  See the whole business." ("business." = self-hosted Playfair
  italic gold); the hero visual is OUR dashboard built in pure
  HTML/CSS (real modules, "Sample data" ×3, no invented proof),
  tilted at the hero's foot; a CSP added to the landing. Product/
  industries/pricing/about carry the same band (one gold serif
  word each from the same copy). New language lives in hero.css
  scoped body.showcase — intake + site.css BYTE-IDENTICAL to the
  published base; customer/ + pricing.js untouched; tokens via
  the generator (web target only; gate now 52 pairings). Proofs:
  73 contracts + 20 browser renders + 6/6 node, manifest 29 files
  clean, +≈43 KB. Approval screenshots in the tree's
  tests/evidence/ — PUBLISH ONLY ON ASSAD'S GO. [team → Muse]
- 2026-11-07 12:31 — Scaling roadmap DELIVERED
  (files/SCALING-ROADMAP.md; all figures measured live,
  read-only): 2 vCPU / 7.7 GiB RAM (4.3 avail), swap 1.4/2.0 GiB
  already used (first pressure signal warm), disk 96G/46G with
  ~23 GB reclaimable docker cache. Staging density: 16 sites on
  ONE bench node ≈1.1 GB RAM; per-site DB ≈100 MB. Legacy
  Pilot+Demo ≈0.9 GB RAM (retire-first frees it). Stages keyed
  to triggers, bands 15–25 / ~50 / 100+ tenants; binding
  constraint = concurrent active users, not site count. Owner
  also stated the same hour: he dislikes .html URLs and asked
  about Next.js — CEO proposal put to him (A clean URLs only /
  B website → Next.js static export / C everything, against
  advice); public URLs must read clean regardless. [team → Muse]
- 2026-11-07 12:33 — HERO DESIGN PUBLISHED, LIVE at
  operqon.cloud (team-frontend-hero-publish.md). Gates green
  (suite exit 0, manifest 30/30, drift PASS — token copy
  174f3a8c matched the regenerated target). Backup
  /root/operqon-portal-hero-20261107T0731Z (25/25 verified).
  Install: 29 manifest files, no --delete — 6 replaced (5 pages
  + tokens), 5 added (hero.css, reveal.js, 2× Playfair woff2,
  on-dark logo), 18 carried; config.js preserved (ac1b03ca
  before == after); intake frozen (served == pre-publish live ==
  hero pins). Live: 24 fetches 200 and hash-equal to pins; the
  hero serves (navy, Playfair italic, dashboard + Sample data
  ×3); pricing honesty proven from the live endpoint (all plans
  unapproved/null); neighbours untouched (marker S3 — S4 still
  deploying). Owner then chose Option B: Next.js lane building
  the static-export re-platform (frontend-next/); .html URLs
  remain until that set replaces this one. [team → Muse]
- 2026-11-07 12:47 — RELEASE-S4 LIVE + ACCEPTED
  (team-release-s4-deploy.md): marker S4 = 8bd6dff0…, RELEASES
  receipt 0e563960. Frontend-only: composition closed exactly
  (manifest 214→227; BACKEND ZERO DIFFS; alembic still 0015).
  Gate from the REAL Dockerfile.test image: 339/3 = the
  predicted +16 over S3. Backup dump 0efe345e… + restic
  747584b7. Acceptance ALL PASS: 7-role MFA E2E ×7 with bank
  verify/reject consumed through the NEW MODALS (modals are
  live in real flows), R3 OIDC, served==tree 9/9, KPI Home on
  the frozen envelope, 5 workspace tabs, portal quadrants,
  money corpus 7/7 on the served module, audit 230 OK, readyz
  200/200. Device-only remainder: none functional. Four
  attempts, all disclosed (harness Home-landing re-spec; the
  0640 trap self-inflicted via rsync of edited files; a fixture
  missing the pending_payment step; then clean). Fixture tenant
  ended active + published through the real flow. Q2 unchanged.
  [team → Muse]
- 2026-11-07 12:54 — Frontend-Next COMPLETE (team-frontend-next
  .md; tree frontend-next/): Next.js 16.4.5 + React 19.3.1,
  App Router, output:'export' — no Node in production. Intake +
  customer/ + assets ride as 24 verbatim hero-tree files,
  hash-asserted by postbuild on EVERY build (config.js asserted
  absent). Publish set 59 files, manifest clean. PARITY vs the
  approved design: text diff EMPTY on all 5 pages; screenshots
  5/6 BYTE-IDENTICAL (product off by 248 px = 0.019%, a
  reveal-frame strip); hero browser-verified (dashboard
  1060×451, zero overflow ×12, 0 blocked scripts). Pricing
  two-state + intake byte-parity hold. Two frictions solved:
  CSP vs RSC inline payloads → postbuild sha256 hash-pinning
  (no unsafe-inline); the pricing hydration race → the exported
  pricing page ships RUNTIME-FREE (hero-identical shape + CSP).
  Weight: 1,067,595 B vs 161,291 B static (+906 KB framework
  machinery; RSC payloads never fetched under plain anchors).
  Publish lane commissioned with the Caddy 301 set + clean-URL
  verification. [team → Muse]
- 2026-11-07 13:06 — NEXT.JS SITE PUBLISHED, LIVE (completion
  appended to team-frontend-next-publish.md). Fix first:
  customer/ re-carried from release-s4 (3 files → the live S4
  hashes 0e89f817 / dbff1d04 / dd0a398e); postbuild's customer
  pin RE-POINTED hero → release-s4 (dated; README: customer/ is
  owned by the provider release line — re-carry + re-point at
  every future release); suite §1b asserts export == release-s4;
  full parity suite green; team-frontend-next.md re-issued
  COMPLETE (§§1–9 incl. §7 publish notes + §9 addendum).
  Publish: backups /root/operqon-portal-next-20261107T080243Z
  (30/30) + /root/Caddyfile.pre-next-20261107T080243Z; install
  59 files (34 added, 25 at existing paths); removals = exactly
  the 4 legacy .html pages, after the reload; end state 60 = 59
  + config.js preserved (ac1b03ca before == after). Caddy: +16
  lines in the apex block only (5× 301 + @cleanPages rewrite),
  validated on-server before swap. Live verification ALL PASS
  (87 assertions): clean URLs 200 + hash-equal to the manifest
  (all 59 fetched), .html → 301 → 200 ×5, intake 200 direct +
  byte-identical (39699194…), unknown paths 404, pricing honest
  (endpoint unapproved/null), PORTAL SERVES THE S4 HASHES,
  console/readyz/marker S4 clean. Also today: an external stack
  assessment was reviewed with Assad — its Postgres/MariaDB
  "correction" does NOT apply to us (control plane = PostgreSQL
  by design; tenant ERPNext = MariaDB as required); no
  architecture change; the scaling roadmap stands.
  [team → Muse]
- 2026-11-07 13:30 — Bench Wave C COMPLETE (team-bench-wave-c
  .md): install_policy PASS ({7,115}→{0,0}; support role = 17
  read rows); Guards PASS all (ENG-054/055/056/045 + ENG-040
  wired, quarantine field proven); Finance PASS all 6 (A6 lands
  AR exactly 232000); Commerce PASS except C-12 quotation
  freeze FAILS end-to-end (upstream re-prices inside its own
  validate before the layer runs — C-1 family, measured); SSO
  seams PASS; BP-6/7 PASS (granted scope = exactly the granted
  company, 53 docs; get_doc bypass = Frappe's documented
  unchecked API) — MISSING PIECE: no shipped code issues the
  site scope row from a provider support session. 11 in-pack
  defects found + fixed + regression-tested, incl. the commerce
  credit gate reading SNAPSHOT-STALE under REPEATABLE READ (a
  concurrent pair BOTH landed pre-fix; locking reads now).
  RELEASE BLOCKER: commerce's 3 custom fields have NO installer.
  COORDINATOR DECISIONS (all four papers' recommendations
  adopted): P01 → guard self-healing at entry (C-12 = its test;
  bench re-proof is a pre-deploy gate); commission cancel →
  append-only offsetting entries; CoA v1.3 folds srbnb +
  price_variance in (alias kept); POS roles → explicit matrix
  rows. App-pack composition lane commissioned (blocker +
  BP-6/7 site seam included). Clean-URLs lane (console/portal)
  still running. [team → Muse]
- 2026-11-07 13:51 — App-pack composition COMPLETE
  (team-app-pack-composition.md; tree app-pack-composed/, 175
  files; delta vs the Wave C tree: 8 added / 17 modified / 0
  deleted). All 4 decisions in + locally proven: P01
  self-healing (proven-re-price → frozen-restored; C-12 case
  85→80→85 in tests; BENCH RE-PROOF STILL OWED); commission
  cancellation = append-only offsets (stranded case nets 0);
  CoA v1.3 (srbnb canonical, price_variance first-class, alias
  kept flipped; tests_w1 re-pinned, re-run owed); POS roles
  explicit — convergence now {9 roles, 119 rows}. BLOCKER
  CLOSED: install_all() (after_install + after_migrate) creates
  exactly 9/119/9 on a bare install, second pass 0. BP-6/7 seam
  site-side BUILT (support_scope.py: HMAC-signed grants,
  default-deny, append-only Operqon Support Grant log, scope
  recomputed from the log; 13 tests) — the CP counterpart is
  specified, not built. Suites: no regressions, no silent
  re-pins (one disclosed composition-context failure = the
  baseline's own). TWO LANES COMMISSIONED: Wave D bench gates
  (the 5 owed gates + tests_w1, fixtures waved-*) and the S6
  release composition (S4 ∪ fixed SSO executor ∪ seam CP
  counterpart ∪ this app; no migration expected). [team → Muse]
- 2026-11-07 13:58 — RELEASE-S5 (CLEAN URLS) LIVE + ACCEPTED
  (team-clean-urls-console-portal.md). No .html in any RESTING
  address bar: console lands on https://control.operqon.cloud/
  and the portal on https://operqon.cloud/customer/dashboard;
  both old .html URLs 301 (query rides). Keycloak probing
  proved only …/tenants.html is registered (no wildcard) → the
  OIDC protocol stayed BYTE-IDENTICAL; only the resting URL
  changed (2 functional points in oidc-browser.mjs); NO
  Keycloak change. Marker 143e929f…; manifest 228; backend
  byte-identical to S4; head 0015. Portal bytes UNCHANGED — the
  frontend-next customer/ pin stays valid. Acceptance ALL PASS
  (7-role E2E ×7 with strict resting-URL assertions; portal
  quadrants; served==tree; audit 264; QA package PASS).
  Pushes: A 143e929f / B 65e2cbb2 (receipt; tag
  live/provider-clean-urls-2026-11-07) / C c193756f. OWED
  FORMALITY: the QA live-parity harness run produced no result
  — the sandbox→VPS SSH proxy is in a sustained failure window
  (public HTTPS fine); every assertion was curl-verified live;
  run /root/live_console_parity.py when SSH is stable and
  append to the report §2.10. The S6 composition lane was
  re-based onto S5 mid-flight. [team → Muse]
- 2026-11-07 14:12 — S6 RELEASE CANDIDATE COMPOSED
  (team-release-s6-composition.md; tree release-s6/, 400 files,
  manifest 399 clean). S5 ∪ SSO executor (wholesale from
  oidc-sso, both Wave C fixes in; API merge = 5 hunks; frontend
  delta = the 4-line "Open ERP" hunk only) ∪ composed app pack
  (app_pack/ 8→176 files, bytes = app-pack-composed/) ∪ seam
  counterpart. ONE NAMED DEVIATION (accepted): the seam
  delivers EXECUTOR-MEDIATED, not API-signed — API signing
  would put seam secrets in the provider DB = a migration;
  here the API only derives work items (additions-only in
  app/support.py; lifecycle byte-identical) and the executor
  signs from its root-only facts file. Cross-proof: signed
  grant+revoke accepted by the shipped site-side core;
  tampered refused BAD_SIGNATURE. Hard rules held: alembic
  byte-identical (head 0015), route diff EXACTLY +2 (88→90),
  7-key + one-role untouched. Local suites: S5 338/3/1 → S6
  388/3/1 (+50 = OIDC 24 + seam 26; the 1 failure pre-existing
  on pristine S5); expected in-image 389/3. Bootstrap +
  deploy runbooks in the report (also
  docs/KEYCLOAK_BOOTSTRAP_RUNBOOK.md in-tree). DEPLOY WAITS ON
  WAVE D: gates 1–4 gate it; gate 5 (seam bench proof) must
  pass before the delivery pass touches a real site.
  [team → Muse]
- 2026-11-07 14:39 — OWNER DECISION: THE SERVICE-PROVIDER
  PRINCIPLE (supersedes the identity-review design). Operqon
  is a service provider like Odoo/ERPNext/Zoho — it takes NO
  identification and owns NO client compliance. Onboarding =
  signup → payment → setup, fully auto; the only human
  approval left = manual-payment verification (our own
  money). Compliance packs (FBR, ZATCA, gateways) are
  INTEGRATION OPTIONS the tenant connects with THEIR OWN
  credentials — their compliance, their authority
  relationship; the W2 plan's framing must be amended to this
  model when its build lane opens. A seamless-onboarding lane
  is commissioned on the release-s6 base: remove the
  identity-review gate (the review surface stays as an
  optional record; settlement honestly sources the state the
  publish gate needs; the dashboard never shows a paid tenant
  waiting on identity_review). Composes as S7 after S6.
  [Assad → team via Muse]
- 2026-11-07 14:47 — THE INTEGRATION STANDARD (Assad, binding
  for every pack): integrations ship as Odoo-style MODULES —
  complete + seamless, built to the compliance authority's
  full current spec; the tenant enters THEIR OWN credentials
  and activates it themselves; activation validates the
  credentials for real and returns a clear error if they are
  wrong (never a silent half-active state); Operqon keeps
  the module spec-current as the authority's rules change —
  the tenant owns registration, credentials and filings.
  Applies to FBR (W2), ZATCA P1/P2, tenant gateways, all
  future authority integrations. [Assad → team via Muse]
- 2026-11-07 14:52 — SEAMLESS-ONBOARDING BUILD COMPLETE
  (team-seamless-onboarding.md; tree seamless-onboarding/).
  The first lane died mid-batch on a tool safety refusal
  (tree left half-edited, production untouched); a completion
  lane verified its 7 landed groups and finished the rest
  one edit at a time. DESIGN = PURE REMOVAL: nobody sets the
  identity flag for seamless tenants (False/None = the
  truthful record); create_invoice / settle_invoice /
  activate_after_payment / publish-site all ungated; the
  review endpoint survives as an OPTIONAL record; the
  customer stepper drops the Identity step. 4 new proofs
  pass (zero-review paid flow to provisioning; publish gate
  end-to-end; stage never identity_review — even with the
  flag True; post-activation reviews move nothing). Suite
  388/3/1 → 392/3/1 (delta = exactly the 4 new tests).
  Accounting vs release-s6: 9 modified + 1 added, no
  migration. Composes as S7 after S6; until S7 deploys the
  LIVE system still enforces the gate. [team → Muse]
- 2026-11-07 15:55 — ★ Q2 PRICING LIVE. The session ran in
  the Muse browser (Assad signed in personally, twice):
  billing edited v1 (terms replaced wholesale →
  PKR/excluded/3; all 12 values exact incl. seats
  50000/50000/100000) → submitted (strip: PKR · Awaiting
  approval — SAR trap avoided); pricing_approver approved
  (strip: PKR · Approved; drafter ≠ approver). Coordinator's
  live check of the public endpoint: all 3 plans
  price_approved TRUE, PKR 750000/999900/1999900, trial 3 —
  the website pricing page lights up from the same endpoint.
  Phase-3 formality (stored read-back + audit + disposable
  draft-invoice proof) commissioned as a verification lane.
  The Q3 pricing blocker is GONE. [Assad + team → Muse]
- 2026-11-07 16:00 — BENCH WAVE D: ALL FIVE GATES PASS +
  tests_w1 (team-bench-wave-d.md). C-12 re-proven live
  (85 restored; decision trail frozen-restored; negative
  controls hold). POS docperm: the pin as composed BROKE
  native POS access (custom rows eclipse native rows) → the
  documented fallback applied to the composed tree — the
  matrix of record is now {9 roles, 123 rows}, superseding
  119. Fresh install-app PASS ×2 (9/123/9). Wave C battery
  clean-room: 188 PASS vs 181, no real regressions. Seam
  proof 15/15 (grant/revoke/bad-sig/expired all correct).
  Deploy-readiness: the bench list is EMPTY. S6 DEPLOY LANE
  COMMISSIONED with a mandatory pre-step (refresh app_pack/
  from the amended composed tree; re-pin 119→123 in-tree),
  then bootstrap + oc4 rebuild + deploy + acceptance.
  [team → Muse]
- 2026-11-07 16:01 — PRICING PHASE-3: ALL PASS — Q2 FULLY
  CLOSED (team-pricing-phase3-verify.md). Stored values
  exact (proposal c4ed372c…, PKR, maker≠checker); audit
  events 278→279 with chain OK; the invoice gate PROVEN
  lifted — a disposable tenant's draft invoice OPQ-202611-
  95DED2DD = 750000 PKR / draft / 30 days (Pass A's same call
  was 423). Rektrs/demo2 re-read untouched. [team → Muse]
- 2026-11-07 17:31 — RELEASE-S6 LIVE + ACCEPTED
  (team-release-s6-deploy.md; tree release-s6-final/).
  Marker 6164e754… (gate VERIFIED). Pre-step: app_pack
  refreshed (delta = 3 files; matrix {9,123}; proofs 22/22).
  GATE DEFECT fixed in-tree: Dockerfile.test never COPY'd
  app_pack/ — the real-image gate caught what a venv could
  not; dated targeted COPY added; gate 389/3. Acceptance ALL
  PASS: 7-role E2E ×7, R3 OIDC, SSO smoke (Social Login Key +
  roster on site; portal sso_configured), seam smoke
  (grant→delivered→revoke→disabled; forged refused
  BAD_SIGNATURE), audit OK 361, pairing on oc4. Backup dump
  22221618… + restic 7ac0988e; pushes A/B/C landed.
  ⚠️ KEYCLOAK INCIDENT (recovered): the runbook name
  operqon-keycloak-bootstrap IS the instance's own
  KC_BOOTSTRAP_ADMIN — a lane script reset its password to a
  value lost at a 404; recovered via Keycloak's temporary-
  admin flow to the env-of-record password (no realm login
  ever affected). The scoped executor admin is therefore
  named operqon-kc-bootstrap (least-privilege verified
  200/403/403; secret at /etc/operqon/keycloak-bootstrap-
  secret, 600). NEVER reset operqon-keycloak-bootstrap.
  Known issue → S7: the delivery helper catches builtin
  PermissionError; Frappe's is not a subclass, so refusals
  report "failed" not "denied" (refusals still refuse).
  S7 LANE COMMISSIONED: seamless delta + that one-liner
  onto s6-final; acceptance centrepiece = a disposable paid
  tenant PUBLISHED with ZERO identity-review records.
  [team → Muse]
- 2026-11-07 17:56 — RELEASE-S7 (SEAMLESS) LIVE + ACCEPTED
  (team-release-s7-deploy.md; tree release-s7/). Marker
  e92588d0… (gate VERIFIED). Composition zero conflicts;
  delta = the 10 seamless files + the PermissionError fix +
  its test + a deploy-driver fix. F-1 CATCH: deploy-r41.sh
  never installed app/payment_policy.py — S7 would have
  shipped half its change (old settlement gate live) without
  it; fixed in all lists, $ROOT hash confirms the new file.
  Gate 397/3 as predicted. ★ SEAMLESS PROOF LIVE: disposable
  tenant e2e-s7proof-verify-co — subscription with NO
  identity review → invoice OPQ-202611-FA8FDAB4 → offline
  approve → settled → PUBLISHED; DB: identity_reviews = 0,
  flag still false; the dashboard stage NEVER showed
  identity_review. Parity/health all pass (audit OK 382);
  Rektrs/demo2 still requested. ⚠️ CORRECTION: S6's Push B
  RELEASES receipt never landed on the branch (the S6
  report's §10 was wrong); S7's Push B backfilled the S6 row
  from the S6 report, flagged as a backfill — the receipt
  chain is now complete. Follow-ups running: frontend-next
  customer/ re-carry to release-s7; Q3-prep lane (runbook
  amendments + Pass B with R10/R11 live + the Rektrs run
  sheet). [team → Muse]
- 2026-11-07 ~18:15 — RELEASE-S7 LIVE + ACCEPTED
  (team-release-s7-deploy.md; tree release-s7/). Seamless
  onboarding is LIVE: the identity-review gate is REMOVED
  (pure removal — the flag stays False/None as the truthful
  record; the review survives only as an optional operator
  record) + the S6 known issue fixed (the support-delivery
  helper now catches frappe.exceptions.PermissionError too,
  so site refusals report "denied", not "failed"; 4 new
  regression tests execute the shipped helper against a stub
  frappe). Composition vs s6-final: exactly the 10 seamless
  files + worker/bench_executor.py + ONE deploy-driver fix
  (deploy-r41.sh's frozen lists never installed
  app/payment_policy.py — added with a dated note) +
  manifest (401 entries, file sha 665c0529…). No migration;
  alembic head 0015. REAL image gate 397/3 (389 + 4 seamless
  + 4 PermissionError), stated before gating and confirmed
  standalone + in-script. Deploy attempt 1 COMPLETE (fresh
  fixture set S7A1 minted pre-deploy under the then-live S6
  rules; verify leg paid → tenant active/published; reject
  leg rejected). CENTREPIECE PROVEN LIVE: disposable tenant
  e2e-s7proof-verify-co driven through the real paid flow
  post-deploy — link → subscription 201 → invoice 750000 PKR
  → notice → billing-approver offline-approve → settlement →
  activation → provisioning → PUBLISHED (site pong), with
  ZERO identity_reviews rows in the DB afterwards,
  identity_verified_flag still false, and the customer
  dashboard stage walking email_verified → provisioning →
  live (identity_review at NO poll). Served==tree parity
  incl. the portal dashboard.js published in place into the
  apex release dir (S6 pattern; backup
  /root/dashboard.js.pre-s7-20261107; config.js preserved
  ac1b03ca…). Audit chain OK 382 events; readyz 200/200;
  systemctl 0 failed; pricing endpoint still PKR-approved;
  Rektrs/demo2 still requested (the pilot is the separate
  next step). Backup: dump 1f357293… + restic f5dc9109.
  Follow-up owed (coordinator): re-carry the frontend-next
  customer/ pin from release-s7 (the standing rule — the
  portal bytes advanced again). [deploy lane → Muse]
- 2026-11-07 13:47 — RELEASE-S5 LIVE + ACCEPTED
  (team-clean-urls-console-portal.md): marker S5 =
  143e929f6dac090c8d16afb3dddc031c97c833b5, RELEASES row
  live/provider-clean-urls-2026-11-07. NO .html IN ANY
  ADDRESS BAR, console + portal included, with ZERO Keycloak
  change: the operqon-owner-console client registers ONLY
  /tenants.html (probe: /, /tenants, bare origin → 400), so
  the OIDC protocol is byte-identical and only the browser's
  resting URL moved — oidc-browser.mjs two points (callback
  also accepts /; cleanUrl settles at /), Caddy 301s
  /tenants.html → /?{query} (query verified to ride) and
  serves the app at / by internal rewrite; portal
  dashboard.html → 301 → /customer/dashboard (rewrite to
  the file; ZERO portal byte changes — the frontend-next
  customer/ pin to the release line stays valid, NO
  re-carry needed). FRONTEND-ONLY over S4: backend
  byte-identical, no migration (head 0015), MANIFEST
  5a5acb4c…, suite 339/3 in the real image (probe on the
  final tree). Two attempts disclosed (attempt 1: the new
  return-wait used wait_for_url, which cannot see a
  replaceState landing — rolled back clean, fixed by
  polling location). Post-edge STRICT pass
  (OPERQON_EXPECT_CLEAN_URL=1): 7-role MFA PASS ×7, every
  role resting at https://control.operqon.cloud/, bank
  verify+reject consumed via modals; customer PASS resting
  exactly at /customer/dashboard, four quadrants rendered.
  Follow-on in the same release: monitoring/check.sh health
  leg now probes the clean root (its .html probe 301s by
  design; watch green again). Backups: pg_dump 3a812484…,
  restic d1a18dfd; Caddyfile backup
  /root/Caddyfile.pre-cleanurls-20261107T083216Z. Rektrs /
  demo2 untouched (requested). Fixtures S5A (tenant
  4f70fa46…, consumed by the deploy) + S5B (tenant
  334c8ae9…, active + published via the strict pass).
  /tenants.html + /customer/callback.html remain ONLY as
  protocol-transient URIs (Keycloak callbacks), never as a
  resting address. [team → Muse]

### 2026-11-07 ~11:4x PKT — RELEASE-R42 DEPLOYED LIVE (Slice 4 control plane + gateway settings + export driver)
Marker is now S3F = fca7762961e9fc0c42da90a31bea5bd1bb8ef164 (branch
release/operqon-provider-r2); gate prints GITHUB SOURCE-OF-TRUTH:
VERIFIED fca77629…; RELEASES row live/provider-slice4-gateway-2026-11-07.
DB at alembic 0015_gateway_settings (0013→0014→0015 stepwise inside the
deploy; forward-only as always). Composed suite 323 passed / 3 skipped
IN the Dockerfile.test image during the deploy; 7-role MFA E2E PASS with
fresh r42 fixtures; R3 customer OIDC regression PASS. Pre-deploy backup:
dump /var/backups/operqon-provider-r2/operqon-provider-pre-r41-20261107T060136Z.dump
(90,734 B, sha256 e4df5707…) + restic snapshot 88068420.
FIRST LIVE PROOFS: BP-7 support round trip incl. expiry leg and the
3-denied-read audit rows; G2 membership denial writes exactly one
customer_membership_denied row with the response unchanged; gateway
settings masked read + non-secret write/read-back/clear over the DB-first
resolver (env fallback intact); export pipeline end-to-end (job → hourly
maintenance driver → ready; artifact sha256 == download-descriptor
sha256; descriptor is the shipped download contract — no byte-streaming
route this release). Fixture tenant e2e-r42-verify-co provisioned to
active/published by the executor. Audit chain OK 213 events.
Rektrs + demo2 still requested (untouched).
DEPLOY HONESTY: it took THREE attempts. Attempt 1 failed the suite gate
(the tree's Dockerfile.test lacked COPY MANIFEST.sha256 — the composition
lane's local image was a venv replica, never the real build) and, because
$ROOT had been pre-synced, the rollback trap restarted the NEW code on
the unmigrated DB; compounded by the settings key having been staged as
raw bytes while app config reads secret files as UTF-8 TEXT — the API
was briefly down until $ROOT was restored from the S2 git archive (DB
never migrated in attempt 1). Attempt 2 passed suite+migration+6/7 roles
but its billing_approver step used the STALE R4.1 E2E env (fixture notices
long consumed) → clean trap rollback to S2 code on the 0015 DB (safe per
§9.7). Attempt 3 with a fresh fixture set passed everything. Both harness
fixes are folded into S3F (Dockerfile.test COPY + the §9.3.3 compose delta
in the tree) — the initial push 91868d61 (S3) is superseded by S3F in the
branch history. LESSONS: (1) build the real Dockerfile.test image against
any composed tree BEFORE deploy day; (2) settings-class secret files are
TEXT (base64) by the app's config contract — check a secret's consumer
before staging bytes; (3) every deploy mints a FRESH E2E fixture set +
env (R4.1, bundled, quick-wins and now r42 all did; reusing an old env
fails at the notice-consuming role).
TWO RESIDUE FACTS: the compose resolves ./data/exports relative to
deploy/, so the live export store is /opt/operqon-provider-r2/deploy/data/exports
(chowned 10001; the runbook's $ROOT/data/exports is unused by compose —
export job #1 b9b8f297 failed on exactly this before the fix and stays
failed with its honest reason); the settings encryption key
(/opt/operqon-provider-r2/deploy/secrets/settings-encryption-key, base64
form, 600, uid 10001) is covered by NO off-VPS backup — store it with the
W0 passphrases (owner item). WEBHOOK: console Notifications value is
EMPTY; /etc/operqon/r2-monitor.env untouched; the one-command sync now
exists at /usr/local/sbin/operqon-webhook-sync (resolves the console value
in-container → atomic line rewrite → operqon-alert proof; empty value =
clean STOP, env untouched — guard tested). When the operator saves a URL
in the console, run that one command and the host alert stack follows.
QA harness: EXPECTED_HEAD → 0015 + two console golden re-pins → 9/9 PASS
(results-20261107T063031Z.json). Full report:
hidden_files/team-release-r42-deploy.md. [deploy lane → Muse]

### 2026-11-07 ~17:47 PKT — S6 DEPLOYED LIVE (SSO executor + composed app pack {9,123} + support seam)
Marker is now 6164e7544753eb7a3e834c04e057055e27cfa63b (branch
release/operqon-provider-r2); RELEASES row
live/provider-sso-seam-2026-11-07. DB at alembic 0015_gateway_settings
(S6 ships NO migration). Suite 389 passed / 3 skipped IN the real
Dockerfile.test image (after a shipped gate fix, dated in-file: the
test image now COPYs the four app_pack files the suite reads by path).
7-role MFA E2E PASS + R3 OIDC PASS on fresh fixtures (set S6A3; the
verify leg ran the pending_payment step and the S6 executor activated
the fixture tenant: job published with sso_configured +
support_configured in the manifest). Pre-deploy backup: pg_dump
sha256 22221618… + restic snapshot 7ac0988e. Bench image
operqon/erpnext-tenant:v16.53.0-oc4 — the app pack was refreshed at
deploy time to the bench Wave D matrix of record (9 roles / 123
docperm rows; the POS entries also carry the native POS rows).
KEYCLOAK: the executor's scoped admin is operqon-kc-bootstrap (the
runbook's name operqon-keycloak-bootstrap is the instance's own
KC_BOOTSTRAP_ADMIN — taken); its roles are the customers-realm
view-clients/manage-clients/create-client, assigned via the master
realm's operqon-customers-realm client (Keycloak 26 rejects direct
cross-realm role-mapping); secret at
/etc/operqon/keycloak-bootstrap-secret (600, never printed); executor
env gained OPERQON_KEYCLOAK_ADMIN_SECRET_FILE / _ADMIN_BASE /
OPERQON_CUSTOMER_ISSUER / _ADMIN_USER. Verified least-privilege:
customers clients 200, provider clients 403, master users 403. An
incident during the first bootstrap attempt (the master admin's
password was reset to a value the failing script lost) was recovered
within the hour via the documented kc.sh bootstrap-admin
temporary-admin flow and verified by token grant; no realm user or
login was affected. Full account in the lane report.
SSO SMOKE (disposable tenant e2e-s6smoke-co, real flow): Social
Login Key "Operqon" + Operqon Tenant Identity + roster written on
the site; portal dashboard reports sso_configured=true; the served
portal dashboard.js is the S6 build (sha256 02e65ea0…) whose ONLY
delta vs S5 is the 4-line "Open ERP" hunk. SEAM SMOKE on the same
site: provider session → customer consent → grant delivered by the
executor (site User Scope enabled for E2E S6SMOKE Co, support User
enabled) → customer revoke → revoke delivered (scope + user
disabled) → forged payload refused BAD_SIGNATURE on the site grant
log. One precondition learned: a fresh site has NO Company until
company bootstrap runs, and grants bind companies — before that the
site correctly denies UNKNOWN_COMPANY.
KNOWN ISSUE for the next release: the executor's
SUPPORT_DELIVERY_HELPER catches the builtin PermissionError, but
frappe.exceptions.PermissionError does not subclass it (MRO verified
in the bench image), so site-side refusals are reported to the API
as delivery "failed" (retried to the derivation cap) instead of
"denied". Refusals still refuse; the happy path delivers.
DEPLOY HONESTY: FOUR attempts. A1: the lane's wrapper omitted the
four compose OIDC exports the S5 wrapper carried → rollback before
migration. A2: the lane's fixture bank alias was not the lowercase
slug the evidence schema requires → verify button never enabled →
rollback. A3: the lane's verify reference did not equal the fixture
notice's reference (invoice settled, notice never flipped) AND the
fixture create job failed SITE_EXECUTION_FAILED because the staging
bench's workerless RQ default queue sat at its 1750-job cap
(QueueOverloaded inside User.on_update during configure_sso) — the
queue was purged (operqon-r2-staging-redis-queue-1, rq:queue:*);
NOTE for future lanes: the staging pairing has no RQ workers, so
queues only ever grow — purge them if site work fails with
QueueOverloaded. A4 passed everything. Audit chain OK 361 events.
Rektrs + demo2 still requested (untouched). Full report:
hidden_files/team-release-s6-deploy.md. [deploy lane → Muse]

### 2026-11-07 ~18:10 PKT — Q3 PASS B (dress rehearsal on the S7 build; report team-q3-passb-prep.md)
Runbook amendments landed (identity stage REMOVED from the runbook +
rehearsal plan; POST-APPROVAL-VERIFY forward text corrected) and the
Rektrs run sheet was delivered (hidden_files/q3-rektrs-run-sheet.md).
Pass B on disposable tenant e2e-passb-trading-co (8d77e8e3…), real
APIs + real SSO: **R9 PASS** — seamless paid flow to active +
published, invoice OPQ-202611-07E5723A at exactly 1,999,900 PKR,
identity_reviews = 0, dashboard never showed identity_review.
**R10 FAIL as shipped → FINDING F-1:** the site's "Login with
Operqon" button href omits `response_type=code` (the Social Login
Key's auth_url_data written by `operqon_core/saas/sso_provisioning.py`
AUTH_URL_DATA = scope only) → Keycloak refuses with "Missing
parameter: response_type" → site 500. Systemic on every provisioned
tenant (confirmed identical on s7proof/s6a3/waved-sso sites). With
the driver appending that one parameter, the flow itself PASSES
(/desk, session = admin, System Manager). F-2 (minor): the OAuth
callback renders Frappe's generic 500 page on provider errors.
**R11 PASS (gate):** non-roster Keycloak customer refused 403, its
auto-created site User disabled in the same request, Error Log
verbatim "SSO login refused … not on the authorised roster" (the
as-shipped attempt itself was unreachable because of F-1).
**R12 PARTIAL → FINDING F-3:** team-before truth PASS; the add-a-user
leg FAILED — provisioning grants the tenant admin **System Manager
only**, while the access-policy matrix governs Company / Customer /
Sales Invoice / User with Operqon-roles-only Custom DocPerms (which
replace the native rows) and the policy engine recognises only
"Operqon*" roles — measured as-admin: Company/Customer/Sales Invoice
403, User list = own record only. The first human on every tenant
site could sign in but not use the ERP, and nobody tenant-side could
grant the missing role (bootstrap deadlock). **R13: rollback refusal
verified** on the published tenant (409s, zero side effects; the full
cycle needs a completed-but-unpublished fixture — fixture-design
note F-4). Run sheet gates Stage 8 on preconditions P-1 (= F-1) and
P-2 (= F-3); Stages 0–7 unblocked. Rektrs/demo2 never touched.

### 2026-11-07 ~19:30 PKT — PASS C: F-1 + F-3 FIXED, DELIVERED TO THE STAGING PAIRING, STAGE 8 RE-VERIFIED (report team-passc-fixes.md)
FIXES (composed app tree `app-pack-composed/`, now canonical; the
oidc-sso home tree's copy diverges by exactly these): **F-1** —
AUTH_URL_DATA gains `"response_type": "code"` (one line). **F-3**
(coordinator decision: the grant is the fix; matrix, policy engine
and native rows UNCHANGED) — `_upsert_tenant_admin` grants the
designated admin `ADMIN_ROLES = ("System Manager", "Operqon Tenant
Admin")`, additive + idempotent: a re-apply converges an existing
admin to the pair, touching no one else. Regression coverage: NEW
`operqon_core/saas/tests/test_sso_provisioning.py` (5 tests incl. the
carried Wave C redirect-url regression); all saas + access suites
green locally and in-image (per-module runs; the combined-process
run shows the SAME 8 module-restore errors on the pre-fix oc4 image —
pre-existing harness behaviour, not a regression).
DELIVERY — STAGING PAIRING ONLY: new bench image
**operqon/erpnext-tenant:v16.53.0-oc5** built from the fixed tree
(same recipe as oc4; in-image: fixes present, matrix still 9 roles /
123 rows); pairing `/opt/operqon-r2-staging-bench/compose.yaml`
pointed oc4 → oc5 (backup compose.yaml.pre-passc-oc5-20261107),
backend recreated, existing sites pong. **⚠️ PRODUCTION PAIRING
UNCHANGED: it still runs the pre-fix app — F-1 and F-3 remain live
for production-provisioned tenants until the next provider release
carries the fixed app into the production pairing image. That
production ride is a NAMED FOLLOW-UP for the release lane; the
provider code/marker are untouched by this lane (this handover
commit is docs-only on top of marker e92588d0…).**
PASS C LEG (a) — FRESH tenant e2e-passc-trading-co (622d5b39…)
through the full seamless paid flow (invoice 1,999,900 PKR exact,
job published attempt 1, identity_reviews = 0): **R10 AS-SHIPPED
PASS** — button href carries response_type=code verbatim, round
trip lands /desk, session = tenant admin holding BOTH roles
(bench-verified), roster = exactly the admin. **R12 AS-ADMIN PASS**
— governed reads all 200; creates through the admin's own session:
Company 200, User 200 (the Pass B add-a-user leg), then — after the
DESIGNED scope bootstrap (admin creates her own Operqon User Scope
for the company via the Tenant-Admin-only surface, 200; until then
company-scoped creates deny with reason COMPANY_OUT_OF_SCOPE, and
branch-scoped writes must name a cost center — policy working as
designed, NOT a blanket 403) — Customer 200, Item 200, draft Sales
Invoice ACC-SINV-2026-00001 200. **R11 AS-SHIPPED PASS** (reachable
for the first time): 403 "Not Permitted" page, no session, User
disabled, Error Log verbatim. **Boundary PASS:** a user holding
only Operqon Read Only gets read ✓ / write ✗ / create ✗ on
Company / Customer / Sales Invoice / Journal Entry, and a real
Customer insert raises PermissionError — the matrix refuses where
it says so.
PASS C LEG (b) — IN-PLACE REPAIR of the Pass B site: re-applied the
shipped executor's own `configure_sso` for e2e-passb-trading-co
(ensure_client converged + rotated the client secret per design
§4.1); its stored auth_url_data now carries response_type and its
admin converged to {System Manager, Operqon Tenant Admin}; the same
probe battery then PASSED on it (button as-shipped → /desk, reads
200, Company/User creates 200, scope bootstrap 200, Customer/Item/
Sales Invoice 200, boundary identical). The S6/S7 fixture sites are
repaired by the same re-apply whenever a future lane needs them.
LEG (c) — provider stayed boring: readyz 200/200 (R2 + R1),
pricing endpoint PKR-approved, audit chain OK (431 events),
**Rektrs + demo2 still `requested`** (never run by Pass B or C).
**NEW FINDING F-5 (coordinator decision pending):** executor-
provisioned sites ship WITHOUT ERPNext's setup-wizard masters —
Customer Group / Territory / Item Group / UOM trees are EMPTY, no
Fiscal Year, no default price list, site default currency INR —
and the pin's native DocPerm rows give create on those trees only
to ERPNext functional roles (Item Manager / Sales Master Manager),
NOT to System Manager, so the tenant admin cannot seed them through
the site's own surfaces (measured 403s as-admin). First Customer /
Item / Invoice entry on a fresh tenant therefore needs the masters
seeded another way (Pass C seeded the fixture sites via the bench
Administrator channel as a disclosed probe prerequisite; product
options: executor seeds masters at provisioning, or company-setup
does). **NEW FINDING F-6 (platform behaviour, measured):** on this
pin, a permission-checked User save by a non-Administrator editor
(REST PUT and bench doc-save alike) SILENTLY discards role and
user-type changes — four controlled experiments; the identical save
with permissions bypassed persists. Practical consequence: tenant
team roles cannot be assigned by the tenant admin through the
site's own User surface; the designed team path is the roster +
membership flow (and bench-Administrator assignment works). Run
sheet updated: **P-1 and P-2 marked CLOSED** (staging scope) with
the scope-bootstrap + F-5 expectations written into Stage 8.
[passc-fix lane → Muse]

### F-5 FIXED — provisioning seeds the setup-wizard masters (2026-11-07, f5-seeding lane)

**F-5 is CLOSED for the staging pairing** (report:
`hidden_files/team-f5-seeding.md`). Provisioning now seeds the
ERPNext setup-wizard masters itself, as a new executor step
`configure_setup_masters` (after the site-master ensures, before
configure_sso/backup, so the verified backup contains a usable
site). The site-side half is `apply_setup_masters(payload)` in the
composed app's `operqon_core/setup/bootstrap.py`, using ERPNext's
OWN wizard data at runtime — the four trees (Customer Group,
Territory, Item Group, Supplier Group) from the wizard's
`get_preset_records(country)`, the full UOM set (239) via the
wizard's `add_uom_data()`, Standard Selling/Buying price lists in
the tenant currency, and the wizard's no-company defaults subset.
Fiscal Year: the wizard's country table + algorithm (Pakistan
Jul 1–Jun 30 → "2026-2027" covering today); ERPNext's own daily
`auto_create_fiscal_year` scheduler extends the chain thereafter.
**Currency discipline:** (country_code, currency) come from the
tenant's OWN provider record (its country → the approved pricing
currency for that country; PK → PKR), carried on the claim payload;
the executor refuses an ambiguous pair loudly BEFORE any site
touch, and the site side independently refuses a currency that
disagrees with Frappe's geo data for the country. Nothing is
hard-coded; roles/permissions were NOT widened (the F-3 rule).
Get-or-create throughout — re-runs create nothing, partial sites
converge. Two in-lane defects found + fixed: the pin's Country
DocType has no `currency` field (cross-check now reads
`frappe.geo.country_info`; oc6→oc7), and this pin's Global Defaults
has no `current_fiscal_year` field (the wizard's write of it is dead
upstream too; dropped, oc7→oc8).
**Delivery:** staging pairing image
`operqon/erpnext-tenant:v16.53.0-oc8` (compose backups
`compose.yaml.pre-f5-oc6/oc7/oc8-20261107`) + the executor step via
the executor's own deploy path ($ROOT/worker/bench_executor.py,
backup `bench_executor.py.pre-f5-20261107`). **Provider production
code, the marker (`e92588d0…`) and the production pairing were NOT
touched.** The claim-payload locale fields + the completion binding
for the manifest's setup_* facts are delivered as a source patch
(`~/workspace/operqon-team/f5-seeding/provider/`) riding the NEXT
provider release with F-1/F-3 — until it lands, the live claim
carries no locale and an unpatched daemon run would fail the
seeding step loudly by design; the executor's root-only marker
carries the masters summary meanwhile (the manifest's setup_*
fields read null on the current API, disclosed in the report).
**Verification (fresh disposable tenant e2e-f5-trading-co, full
seamless paid flow, invoice OPQ-202611-37065728 at exactly
1,999,900 PKR, job published, attempts 2 — attempt 1 was the
country-field defect above, held safely by the job lease):** bench
inspect shows the seeded masters + FY 2026-2027 + price lists PKR +
Global Defaults PKR/Pakistan (no Administrator-channel seeding
anywhere in the flow; the claim augmentation in the driver is the
Pass C leg-(b) pattern, disclosed in the report); the tenant admin
through her OWN SSO session created Company (PKR), her scope grant,
Customer (Individual/Pakistan), Item (Products/Nos) and draft Sales
Invoice ACC-SINV-2026-00001 (docstatus 0, PKR, 100, Standard
Selling); bootstrap re-run created [] with counts unchanged;
negative proofs refused (missing/wrong/unknown locale, counts
unchanged); suites green (test_setup_masters 6/6, test_bootstrap
3/3, test_sso_provisioning 5/5, test_support_scope 13/13 — its
rc=1 is a post-test cleanup quirk in Frappe's harness, tests OK);
boring checks pass (readyz 200/200, pricing PKR-approved, audit OK
463 events, **Rektrs + demo2 still `requested`**). **Measured
boundary (pre-existing, pairing-wide, NOT changed by design):**
direct REST reads of the master trees remain 403 for the admin's
roles (the pin's native rows) — the masters are fully usable as
link targets for Customer/Item/Invoice entry; tenant-admin master
maintenance is not promised on this pin. **F-6** is recorded as a
known limitation in the run sheet (Stage 8 + P-2 note): tenant
admins cannot assign Operqon roles via Desk User saves on this pin;
team roles flow via the roster/membership path. **Production ride
(named follow-up, joins F-1/F-3):** the next provider release must
(1) refresh `app_pack/` from app-pack-composed (delta = setup/
bootstrap.py + tests_w1/test_setup_masters.py), (2) apply the
claim/completion provider patch, (3) build the production pairing
image from it (oc-series recipe). Until then F-5 is closed for
staging only — where the Rektrs pilot runs.
[f5-seeding lane → Muse]
- 2026-11-07 ~21:25 — **RELEASE-S8 LIVE: customer-portal redesign**
  (lane report team-release-s8-portal.md §1–§12). Marker is now
  **11d8d76f6fd384bbec45422df0493e809c9428eb** (Push A, 403 paths);
  RELEASES receipt row `live/provider-portal-redesign-2026-11-07`
  landed as Push B 3525e8d6. The tree is S7 + the redesign portal
  (12-page SPA on the exact S7 data layer; parity differential-proven,
  payment-notice POST + logout URL byte-identical; 4 of 9 portal
  files changed; live config.js preserved ac1b03ca…) **with one
  executor exception**: the pre-deploy run was STOPPED CLEAN by an
  executor-clobber guard — the tree's pre-F-5 executor (ea0afcaa…)
  would have silently reverted the live F-5 executor (6fa0951b…,
  the ONLY live divergence from S7) — so the F-5 executor was
  absorbed VERBATIM into the tree (worker/bench_executor.py,
  6fa0951b…) and is now carried by the release; post-deploy the
  live executor still hashes 6fa0951b…. **The app-side F-5 delta
  (app_pack bootstrap) and the provider claim patch (country_code
  + currency on the job claim) are NOT in S8** — they ride the next
  provider release with the app_pack refresh and the production
  pairing image, exactly as the F-5 entry above records. Until the
  claim patch ships, the F-5 interim rule stands: staging
  provisioning is driver-augmented; a daemon-claimed job fails the
  seeding step loudly by design (SITE_EXECUTION_FAILED) — proven
  again by this release's own disposable fixture (S8A1 tenant
  6784bbd8…, job b167ea21… failed at the seeding step 2026-11-07
  15:46 UTC; tenant rests suspended = the designed failed-job
  posture; its subscription is active, verify invoice
  OPQ-202611-E2A9272C paid, reject invoice OPQ-202611-B11E0B16
  still issued; the failure fired the provisioner OnFailure alert
  unit, which reports failed only because no alert webhook is
  configured — owner input pending, same posture pre-release).
  Gate: expectation re-derived for the amended tree and stated
  before gating — **397 passed / 3 skipped** in the real
  Dockerfile.test image, standalone AND in-script (the absorbed
  executor first failed 7 executor-integration tests whose fixtures
  mint locale-less test jobs; closed by dated boundary fakes of
  configure_setup_masters in 3 test files, assertions unchanged;
  the f5-seeding tree holds NO provider-side pytest tests for the
  executor delta — nothing further to absorb). Deploy attempt 1
  COMPLETE; backups: dump sha256 cce10182… + restic 0c4a15db;
  rollback snapshot /root/operqon-r41.GMGdXH; $ROOT manifest
  0 non-OK; served == tree for all 9 portal files; console served
  bytes unchanged vs S7; 7-role MFA + R3 OIDC acceptance PASS
  in-script; portal fixture acceptance PASS (real data + an issued
  offline invoice WITH its notice form for two customers incl.
  OPQ-202611-178C7E9D; switcher: 2 memberships, switch renders the
  second company, scoped requests carry X-Operqon-Tenant; one
  assertion re-specced with a dated note — the shipped auth layer
  POSTs /customer/link on every sign-in, so the slot assertion
  targets creation calls); audit chain OK (480 events); pricing
  still PKR-approved. **Portal gap + naming:** customer-side
  subscription/invoice CREATION does not exist anywhere in the
  shipped backend (no endpoint — creation is provider-side under
  operqon:billing by design); the redesign therefore ships an
  honest disabled "Start your subscription — Coming soon" slot
  that renders ONLY at stage email_verified with no subscription
  and zero invoices (proven live on fixture S8S1; absent for
  subscribed customers) and fires no creation call. The
  self-service endpoint build that replaces the slot is
  **RELEASE-S9** (the planning notes' "S8" — S8 is this portal
  release). **Rektrs pilot state (read-verified at this
  acceptance):** tenant still `requested`; Stage 4 DONE earlier
  today by the owner-as-billing — subscription 050443be…
  `pending_payment`, invoice **OPQ-202611-EBABC231** `issued` at
  exactly 1,999,900 minor PKR (due 2026-11-21); demo2 still
  `requested`. NEXT: pilot Stage 5 (owner's real bank payment →
  portal notice → billing-approver verification), then Stages 6–7
  DRIVER-AUGMENTED per the interim rule above.
  [release-s8 lane → Muse]
- 2026-11-07 ~23:48 PKT — **F-RIDE LIVE: app_pack F-1/F-3/F-5 +
  claim patch + optional evidence hash (migration 0016)**
  (lane report team-release-fride-deploy.md). Marker is now
  **29c7135f0c73a38f915a83d1d2cd2b914dd68d82** (Push A, 408 paths =
  407-file manifest + MANIFEST.sha256; GITHUB SOURCE-OF-TRUTH:
  VERIFIED at the new marker); RELEASES receipt row
  `live/provider-fride-2026-11-07` landed as Push B e08f5b0c.
  Deploy attempt 1 COMPLETE: pre-backup dump sha256 05da4384… +
  restic 13bb9142; in-script gate 399 passed / 3 skipped;
  7-role MFA + R3 OIDC acceptance PASS in-script; rollback
  snapshot /root/operqon-r41.BhvQAn (not invoked); disposable-PG
  rehearsal of 0016 passed both legs (fresh chain to head; the
  0015-dump upgrade preserved all 22 existing approval digests,
  column flipped to nullable). $ROOT manifest 407 entries
  0 non-OK; all 18 composition delta paths hash-match $ROOT vs
  tree; executor still byte-identical 6fa0951b…. Pairing image
  **oc9** built from the deployed tree's app_pack (in-image:
  F-1 response_type=code, F-3 ADMIN_ROLES, F-5
  apply_setup_masters; suites 5/5·6/6·3/3·13/13; matrix
  {9 roles, 123 rows}); staging pairing oc8→oc9 (compose backup
  /opt/operqon-r2-staging-bench/compose.yaml.pre-fride-oc9-20261107
  kept). NOTE: there is NO separate production bench stack on
  the box — the executor targets the staging pairing only and no
  provisioned production sites exist, so the oc9 build itself is
  the production pairing refresh. configure_sso re-applied via
  the executor for e2e-s6a3-verify-co, e2e-s7a1-verify-co,
  e2e-s7proof-verify-co: auth_url_data gained
  response_type=code on all three, admin roles exactly
  [Operqon Tenant Admin, System Manager], roster exactly the
  admin; secret rotation per design §4.1 expected. S6A2 + S8A1
  left as the runbook specified (suspended/never-landed; S8A1
  converges via the normal flow if ever re-driven).
  **CENTREPIECE — THE CLAIM PATCH IS PROVEN, THE AUGMENTATION
  INTERIM PROCEDURE IS RETIRED:** fixture tenant
  e2e-fride-claim-co (3bd0841e…) ran the real paid flow
  (invoice OPQ-202611-005BE804 priced server-side at exactly
  1,999,900 PKR) and job cfb474a8… was DAEMON-CLAIMED WITH NO
  AUGMENTATION → published with setup_masters_configured true,
  setup_country_code PK, setup_currency PKR,
  setup_fiscal_year 2026-2027; masters verified on the site;
  identity_reviews = 0. Q3 Stage 6 for the Rektrs pilot no
  longer needs any driver augmentation — the daemon-claimed job
  seeds PK/PKR + FY 2026-2027 on its own. OPTIONAL-HASH PROVEN:
  (i) on the deployed HTTPS console, a fixture billing-approver
  session opened the verify modal and its file picker filled
  evidence_sha256 with exactly the known digest (0a6e60c7…) of
  the picked file — modal cancelled, nothing settled; (ii) a
  null-hash offline-approve settled end-to-end (approval row
  statement_sha256 IS NULL; audit event 558
  offline_bank_credit_approved carries payment_sha256 as JSON
  null); (iii) malformed digests still 422 (non-hex / uppercase
  / 63-char). Boring checks: readyz 200/200; audit chain
  verified (567 events); pricing PK approved (750000/999900/
  1999900, trial 3d); served console bytes == tree for the 3
  hash-helper files; customer/config.js preserved ac1b03ca…;
  zero customer/ bytes changed. **Rektrs pilot state
  (read-verified at this acceptance, UNTOUCHED):** tenant
  `requested` v2; subscription `pending_payment`; invoice
  OPQ-202611-EBABC231 `issued` at 1,999,900 PKR, unpaid; the
  TEST notice 8ce6ba02 STILL `pending_verification` (reject it
  at Stage 5, never approve); demo2 `requested` v2. NEXT:
  pilot Stage 5 still awaits the owner's real sitting (real
  transfer → real notice → billing-approver approval, his two
  logins); Stages 6–7 now run unaugmented.
  [f-ride deploy lane → coordinator]

- 2026-11-08 ~13:30 PKT — **Q3 REKTRS PILOT COMPLETE (Stages 0–9) —
  the first REAL tenant is ACTIVE end-to-end** (evidence pack:
  `files/Q3-REKTRS-PILOT-EVIDENCE.md` in the goal workspace; lane
  reports team-q3-pilot-stage1.md,
  team-q3-pilot-preflight-rerun-20261108.md,
  team-q3-pilot-stage67-verify.md, team-full-backup-20261108.md).
  Stages 0–4 (2026-11-07): Stage 0 board 8/8 live PASS; Stage 1
  intake confirmed (tenant f02ded70…, status requested, paid path,
  email verified, identity binding present, zero downstream
  artefacts — the paid path has NO identity step by design, S7);
  Stage 3 already complete (binding); Stage 4 in the console under
  the owner's operqon-billing session — subscription 050443be…
  pending_payment, invoice OPQ-202611-EBABC231 ISSUED at exactly
  1,999,900 minor PKR (Business, offline, monthly/30d, due
  2026-11-21), amount taken server-side from approved proposal
  c4ed372c… (audit 445–447; DB-verified exact). KNOWN GAP recorded
  at Stage 4: customer self-service subscription/invoice creation
  does not exist (no customer endpoint) — every tenant's Stage 4 is
  console-side until the owner decides the S9 item (below).
  PRE-STAGE-5 BOARD GREEN (2026-11-08 ~08:47 PKT, third pre-flight
  run — runs 1–2 were blocked by a sandbox egress outage, a
  verification outage, not a system fault): all 8 items PASS —
  marker 29c7135f + alembic 0016; Rektrs exact Stage-4 state; test
  notice still pending; pricing the only approved PK v1; zero
  non-terminal jobs; pairing oc9; audit chain 611 events, 0
  mismatches; demo2 requested/untouched. The owner chose to WAIT
  for the green board before sitting (08:41 PKT).
  STAGE 5 (2026-11-08, run under the owner's NEW DRIVEN MODEL —
  owner decision 12:33 PKT: the coordinator drives console/portal
  steps via takeover sessions; the owner creates accounts,
  performs the sign-ins, and makes the actual bank transfer):
  (1) test notice 8ce6ba02 (ref 55566542, from the 2026-11-07
  exploration sitting — no payment was ever made against it)
  REJECTED under the owner's billing-approver session, reason
  "Test notice — no payment made." (audit 626; invoice stayed
  payable; zero approvals against it). (2) PORTAL GAP #1 found
  live: the portal invoice carried NO bank instructions at all
  (only "Contact Operqon billing for bank transfer instructions")
  — the receiving account was recorded nowhere in the system; the
  owner transferred to his own Operqon receiving account and only
  the reference entered the system. (3) Real transfer Rs 19,999,
  bank reference TX-5526658456885; portal notice filed (portal
  showed the pending confirmation at submit). PORTAL GAP #2
  (display-only): after a reload the portal did NOT re-display the
  pending notice — the coordinator's DB check settled it: notice
  stored, pending_verification, submitted 07:44:05 UTC, audit 629;
  root cause = the customer invoices read path carried no notice
  state at all (fix BUILT, below). (4) Approval 7509865e… under
  the owner's billing-approver session: alias
  "rektrs-private-limited" (the console required the registered
  lowercase slug format), reference TX-5526658456885,
  statement_sha256 NULL — THE OPTIONAL-HASH PATH TAKEN ON THE
  REAL RUN — amount 1,999,900, SoD clean (approver 7f0a4157… ≠
  invoice creator 2e583306…, ≠ tenant creator public-intake).
  Invoice → PAID (payment_reference offline:TX-5526658456885),
  subscription → ACTIVE, tenant → provisioning v3; audit 630–634;
  job 1423d8fa… daemon-claimed 07:47:40 UTC. NO fixture pattern
  was used for the real tenant at any point.
  STAGES 6–7 PASS (report team-q3-pilot-stage67-verify.md):
  executor completed 07:50:04 UTC (audit 635–638), daemon
  AUTO-PUBLISHED 07:50:10 UTC (audit 639) — settle → publish
  ≈ 2.5 min, attempts = 1, requested_by/approved_by both
  operqon-payment-automation. **THE F-RIDE CLAIM PATCH IS PROVEN
  ON THE REAL TENANT:** manifest bindings setup_country_code PK /
  setup_currency PKR / setup_fiscal_year 2026-2027 carried by the
  daemon-claimed job with NO augmentation. Tenant ACTIVE v4.
  Battery: pong 200; apps frappe 16.54.0 / erpnext 16.53.0 /
  operqon_core 0.0.1; masters exact (Customer Group 5, Territory
  3 incl. Pakistan, Item Group 6, Supplier Group 8, UOM 239 +
  17 categories, FY 2026-2027 enabled, Standard Selling/Buying
  PKR+enabled, Global Defaults PKR/Pakistan); SSO href carries
  response_type=code + client operqon-erp-rektrs-private-limited;
  admin roles exactly [Operqon Tenant Admin, System Manager];
  identity_reviews = 0; audit chain 638 events, 0 mismatches,
  head = event 639's hash; demo2 untouched; pairing zero
  non-terminal jobs.
  STAGE 8 (owner's first sign-in; THREE browser runs) — found and
  fixed two defects EVERY API/bench battery had missed:
  (i) **THE STAGING PAIRING SERVED NO STATIC ASSETS:** gunicorn-
  only bench behind a pure Caddy reverse proxy, no nginx/static
  tier anywhere → every /assets URL 404'd for EVERY pairing site
  (asset files intact on disk); any fresh browser got an
  unstyled login + blank Desk (the owner confirmed the broken
  page on his own screen). FIXED the same hour: a `frontend`
  nginx service added to the staging compose (same oc9 image,
  stock Frappe nginx config, 127.0.0.1:18091; pure addition —
  no existing container recreated) + only Caddy's
  *.stage.operqon.cloud upstream repointed (snapshots kept,
  config validated before reload). ASSETS = SERVED: every
  previously-404 asset 200 with byte-exact sizes on Rektrs AND
  the sibling; console/portal/Keycloak/production readyz all
  stayed 200. (ii) **PROVISIONING LEAVES SITES SETUP-INCOMPLETE:**
  zero Companies, tabInstalled Application.is_setup_complete = 0
  for BOTH frappe and erpnext → the Desk SPA force-routes every
  session to the ERPNext setup wizard; /login bounced; no SSO
  sign-in was possible in a browser. Proven on the live DBs; the
  sibling was in the identical state (its one Company was
  driver-created, and even that never flipped the flags). The
  executor path (create → ensures → configure_setup_masters →
  configure_sso → configure_support → backup) never creates a
  Company and never marks setup complete; the app pack's
  bootstrap_company (bootstrap.py, ENG-025/026) is called only
  by proof/test fixtures and sets neither default_company nor
  the flags. RESOLUTION ON THE REAL SITE: **the OWNER completed
  the setup wizard himself** in his takeover session (Company
  created 2026-11-08 13:12:53 site-local) — the coordinator's
  bootstrap corrective lane re-read the state, found it done,
  and STOPPED, creating nothing. Result: Company "rektrs"
  (abbr "R", PK/PKR, 96 accounts, defaults wired), both flags
  → 1, default_company = "rektrs"; no collateral (masters,
  roles, SSO all re-verified); guests then got /login 200 with
  the SSO button. Differences from the prescribed bootstrap
  record (flagged, deliberately untouched): company named
  "rektrs" not "Rektrs Private Limited"; FY 2026-2027 companies
  list empty (wizard did not link it; FY resolves by date);
  no Operqon Company Setup record. **OWNER DECIDED 2026-11-08:
  keep the name "rektrs" — NO rename.** THIRD RUN — STAGE 8
  PASS: guest /login with "Login with Operqon", no wizard
  bounce; SSO carried into the Desk; user verified from the
  profile (Asad Ahmad, assadchoudharry@gmail.com, asad_ahmad,
  Active/Enabled); Company list = exactly "rektrs"; Desk apps
  ERPNext + Operqon + Framework (workspaces Setup/Accounts/
  Selling/Buying/Stock/Manufacturing/Projects/Assets/Quality);
  Desk left open for the owner.
  STAGE 8 FOLLOW-UP VERDICTS (closed same day): LOGIN PAGE =
  STYLED FOR NEW VISITORS (complete resource audit; the third
  run's unstyled render was the old browser profile holding a
  cached pre-fix 404). OPERQON ICON =
  /assets/operqon_core/images/operqon-app-icon-dark.svg → 404
  (source exists in the app pack; never entered the built
  asset tree — the Desk branding build owns the fix). HOME
  CARDS = STALL on Total Stock Value only (its Bin read 403s
  for the tenant-admin roles — the measured pin boundary; the
  other cards resolve 0.0 instantly). TIMEZONE: the admin
  user's time_zone was Asia/Kolkata — set to Asia/Karachi and
  re-read confirmed.
  STANDING VERIFICATION RULES CHANGED BY THIS PILOT (do not
  regress): the Stage 8 findings were invisible to API/bench
  batteries, which never fetched an asset URL and never loaded
  a page as a guest. Every future site/pairing verification
  MUST include (1) an asset-fetch check (the page's own
  CSS/JS/images → 200 + correct content type) and (2)
  guest-login reachability (a guest browser session reaches
  the login page — no wizard routing, no blank render — and
  the SSO round-trip lands on the Desk). The owner's own
  device/browser evidence remains ground truth (Rule 7).
  BACKUPS (2026-11-08, on the owner's direct order): provider
  DB fresh dump → restic 13e26723; Rektrs site bench backup
  with-files → restic f7379cb0, RESTORE-READ VERIFIED from R2
  (a one-off — no recurring leg covers pairing tenant sites);
  **KEYCLOAK GAP CLOSED:** Keycloak's own Postgres had NO
  backup leg at all — one-off dump → restic 18f96ac7
  (restore-read PASS), then a DAILY LEG INSTALLED
  (wrapper /usr/local/sbin/erp-saas-r2-backup-keycloak, timer
  03:05 UTC, retention extended to the keycloak tag) and
  proven by hand run → snapshot 3485c9c4, restore-read match;
  provider leg verified untouched. **PROVIDER HARNESS FLAKE
  FIXED + PROVEN:** backup-provider-db-r41.sh's TOC check
  (printf | grep -q under pipefail — grep's early exit
  SIGPIPEs printf and can fail the check closed on a good
  dump) replaced with a pipe-free case match (pre-change copy
  .bak-20261108T080739Z-pipefail-fix kept; coordinator verified
  by direct diff); proof hand run → dump
  operqon-provider-pre-r41-20261108T081055Z.dump, restic
  506bcf4b, restore-read sha256 match, both provider timers
  enabled+active. Report team-full-backup-20261108.md.
  BUILT DURING THE PILOT (NOT deployed — both ride the
  post-pilot release, composed in ONE tree
  ~/workspace/operqon-team/bank-instructions/): (a) BANK-
  TRANSFER INSTRUCTIONS (gap #1): console Settings card +
  operator-only GET|PUT /api/v1/provider/settings/bank-transfer
  (platform_settings key bank_transfer, stored in the clear —
  not a secret; audit bank_transfer_settings_updated, field
  names only) + DB-first resolution of the portal's existing
  manual_bank_instructions field with the env fallback
  preserved byte-for-byte (no portal frontend change needed);
  after deploy the operator sets the real instructions ONCE in
  the console. (b) PORTAL PENDING-NOTICE RE-DISPLAY (gap #2):
  payment_notice_status added to the customer invoices payload
  (latest notice per invoice) + the renderer rebuilds the
  pending banner with the submit path's exact wording; resolved
  notices never resurrect it. GATE CAVEAT for both: the sandbox
  had no container runtime, so the real Dockerfile.test image
  gate was NOT run — venv rehearsals only (bank +10 tests,
  notice +6 Python/+2 DOM, zero regressions; the single failure
  in each is the pre-existing token-drift artefact that
  self-skips in the image); **the image gate is OWED at
  composition (scripts/test-in-container.sh)** — expected
  409/3 then 415/3. STAGE 9 = this entry + the evidence pack +
  the run-sheet completion note. Deployed marker UNCHANGED:
  29c7135f (this sync is docs-only).
  NEXT (queue order): demo2 run (tenant 714b7600…, requested
  v2 — same sheet; its Stage 8 will need the same setup
  completion and the new battery items) → Slice 10 (pilot gate
  + accountant sign-off + ACC-18) closes W1 → POST-PILOT
  RELEASE (one vehicle: the two gap builds above with the owed
  image gate + the provisioning configure_company step — the
  Finding-(ii) permanent fix: executor step after
  configure_setup_masters running bootstrap_company from the
  claim's country/currency + provider company record, setting
  default_company + both is_setup_complete flags, idempotent,
  loud on ambiguity + the DESK BRANDING pack — owner rule
  2026-11-08: ERPNext is the backend engine only, every
  tenant-facing surface presents as OPERQON; includes the tile-
  icon fix — + pairing image oc10 from the refreshed app pack)
  → fixture cleanup (OWNER-ORDERED: purge all test
  tenants/payments/notices + their bench sites; the hash-
  chained audit trail must stay valid — never silently delete
  audit events; the rejected Rektrs test notice is NOT part of
  the purge) → S9 decision (owner: customer self-service
  creation vs console-side Stage 4) → alert webhook (driven
  session; owner pastes the URL into the console Notifications
  card himself; coordinator then runs operqon-webhook-sync
  once) → R4.2 merchant inputs (owner/bank; adapters built).
  TENANT-FACING BRAND RULE (owner, 2026-11-08): ERPNext/Frappe
  is the backend engine only — login, Desk, workspaces and
  print present as OPERQON. Recorded as a standing rule
  alongside the service-provider principle.
  [stage-9 close-out lane → coordinator]
- 2026-11-08 19:25 PKT — POST-PILOT RELEASE DEPLOYED + VERIFIED LIVE
  (marker 29c7135f → 0723519f; RELEASES receipt push c9001df0;
  alembic head UNCHANGED at 0016 — this release has no migration):
  console bank-transfer settings (operator-only GET|PUT
  /api/v1/provider/settings/bank-transfer; portal resolves
  manual_bank_instructions DB-first with the shipped fallback) +
  portal payment-notice re-display (payment_notice_status on the
  customer invoices payload; the pending banner renders after
  fresh login AND after reload — proven live on fixture
  e2e-postpilot2-deploy-co; apex portal publish in place per the
  S8 pattern, only dashboard.js changed, config.js preserved
  ac1b03ca) + executor configure_company step (the permanent
  Stage-8 setup-wizard fix) PROVEN LIVE end-to-end: fixture
  e2e-postpilot3-deploy-co settled offline with a null statement
  hash → daemon-claimed job → published with
  company_configured=true, company "E2E Postpilot3 Deploy Co",
  guest login styled with all assets 200, no wizard + app-pack
  branding/fork refresh + pairing oc9 → oc10 (image sha256
  b3a99232…). Rektrs apply_branding re-applied + converged;
  Rektrs otherwise untouched (Company exactly "rektrs",
  default_company "rektrs", frappe/erpnext is_setup_complete 1).
  Bank settings proven with a TEMPORARY test value, then fully
  removed (stored record {}) — the real instructions remain the
  operator's later act. DISCLOSED: (i) the deploy-internal
  fixture e2e-postpilot-deploy-co's job was daemon-claimed in
  the window between the provider deploy and the pairing swap
  and failed loudly at configure_company against the oc9 image
  (tenant rests suspended, the designed posture; no real tenant
  had a job in the window); (ii) TILE ICON NOT CLOSED — the
  composition premise was falsified: operqon-tile.svg exists in
  NO tree on disk, hence not in the oc10 image (pristine-
  container check), so the runtime 404 stands exactly as under
  oc9; the fix is to add the file to the app-pack source and
  ride the next image cycle (oc11); (iii) C1+C3 excluded from
  this release (the "Workspace Role" → "Has Role" one-line fix
  + bench proof ride the next image cycle); S9 is NOT in this
  release. Acceptance: in-script real image gate 422 passed /
  3 skipped / 0 failed; seven-role MFA + R3 OIDC PASS; audit
  chain OK (710 events); readyz 200/200; backups taken first —
  pg_dump sha256 5efc595a… + restic snapshot 63f86cac. Lane
  report: hidden_files/team-release-postpilot-deploy.md.
  [deploy lane → coordinator]
- 2026-11-08 20:43 PKT — S9 RELEASE DEPLOYED + VERIFIED LIVE
  (marker 0723519f → 9b022d33; RELEASES receipt push 862c2819;
  alembic head UNCHANGED at 0016 — no migration; NO pairing
  change — app pack byte-identical, oc10 stands; executor
  byte-identical 11c5ba0f): customer self-service subscription
  start is LIVE. Backend: GET /api/v1/customer/subscription-offer
  + POST /api/v1/customer/subscription-start (app/main.py +130/−0;
  no request body — tenant from the customer binding only, plan
  forced to tenant.plan_code, amount from the approved
  CountryPlanPrice; one atomic action: subscription drafted →
  invoice drafted → subscription pending_payment → invoice
  issued, due +14 days, channel offline; honest precondition
  errors 404/409/423; settlement SoD holds by construction —
  invoice.created_by is the customer actor). Portal: the S8
  slot activated in dashboard.js (deployed a8bc25ca → 8fe62742)
  and published to the Caddy apex in place (served sha ==
  8fe62742; served config.js still ac1b03ca; other 7 customer
  files unchanged; outgoing backed up at
  /root/dashboard.js.pre-s9-20261108). Acceptance: in-script
  real image gate 434 passed / 3 skipped / 0 failed; seven-role
  MFA + R3 OIDC PASS. Attempt history: attempt 1's gate passed
  but the script rollback fired at the owner acceptance — the
  E2E env carried the POST-PILOT disposable verify/reject
  notices, already consumed (fresh-fixture rule); a fresh set
  was minted on fixture e2e-s9-deploy-co (85a2991b) and
  attempt 2 completed (verify invoice OPQ-202611-C79D57F5 paid +
  notice verified; reject invoice OPQ-202611-A121ADD0 issued +
  notice rejected; fixture job published, attempts 1).
  SELF-SERVICE PROVEN LIVE on fresh fixture
  e2e-s9-selfservice-co (37511024): offer eligible (Business,
  Rs 19,999/mo server figures) → real portal UI click-through
  (slot + confirmation modal with the exact figure) →
  subscription pending_payment + invoice OPQ-202611-A6E9C720
  issued at exactly 1,999,900 minor, due = issued + 14 days →
  second start 409 → notice 202, payload shows
  pending_verification → SoD pair live (customer token 401,
  billing role 403, billing_approver 200 with null statement
  hash) → invoice paid, subscription active → daemon job
  published (attempts 1, company_configured=true, company
  "E2E S9 Selfservice Co") → guest /login 200 styled, all 8
  asset URLs 200, no wizard. Unverified-email state proven on
  fixture e2e-s9-unverified-co (5c6765ad): offer
  email_not_verified, start 409, nothing created. OBSERVED:
  the owner has entered the REAL bank-transfer instructions in
  the console setting since the post-pilot deploy — the
  fixture invoice payload resolved them DB-first ("Bank
  transfer — Faysal Bank. …"); the deploy did not touch the
  setting. Boring checks: readyz 200/200; console + portal 200;
  audit chain OK (767 events); $ROOT manifest 432/432;
  systemctl --failed = only the known webhook alerter (webhook
  still empty by owner choice); Rektrs active v4 / demo2
  requested v2 untouched; PK approved proposal c4ed372c
  unchanged. Backups taken first — pg_dump sha256 24cbbb0e…
  + restic snapshot 787dc3d2. S9 fixtures (85a2991b active,
  37511024 active, 5c6765ad requested-unverified) join the
  fixture-cleanup queue. NEXT: demo2 is the designated first
  REAL self-service run (same run sheet); console-modernization
  batches continue on the modernization tree; C1+C3 + the tile
  icon ride the oc11 image cycle. Lane report:
  hidden_files/team-release-s9-deploy.md.
  [deploy lane → coordinator]
- 2026-11-08 ~23:5x PKT — CONSOLE-MODERNIZATION RELEASE
  DEPLOYED + VERIFIED LIVE (marker 9b022d33… →
  6bd1cbe160742063f7df4d42e4d0d4c557bd4cff; receipt commit
  3f5d0d1e…; lane report hidden_files/team-console-release-deploy.md).
  FRONTEND-ONLY: the operator console frontend is replaced
  wholesale by the modernized build (design tokens, Lucide nav,
  datagrid + detail rows, KPI provenance, modal kit, lazy
  src/ui/* modules); backend byte-identical to the live S9
  tree; NO migration (head stays 0016_offline_evidence_optional);
  NO pairing change (bench untouched by this lane); customer/
  portal byte-identical (served config.js ac1b03ca…, dashboard.js
  8fe62742…). Register closed at Step 0: A-16 (notice pairs
  re-pointed to the shipped success/danger TEXT tokens — 6.02:1
  and 6.17:1; axe L3 re-run at the real origin, 24 runs, ZERO
  violations) and A-17 (Downgrade currentTarget capture via the
  lazy subscription-actions module; sweep 24/24). Budgets:
  eager 155,251/156,000 B; CSS 33,960/34,000 B. On-box REAL
  image gate 504 passed / 3 skipped / 0 failed; seven-role MFA
  + R3 OIDC PASS in-script on fresh fixture
  e2e-console-deploy-co (6cfa07e2…): verify → invoice
  OPQ-202611-D1F9842A paid, reject → OPQ-202611-0FEB646D stays
  issued; fixture job published, tenant active. Post-deploy:
  $ROOT manifest 478/478; install audit 79/79 files
  sha-identical ($ROOT + publish dir, 0 misses); AFTER nav
  probe — operator/identity nav sets identical to pre-deploy,
  Lucide SVGs live, KPI provenance rendering, zero JS errors;
  audit chain OK (800 events); Rektrs active v4 / demo2
  requested v2 untouched. Deploy attempts 1–4 rolled back by
  the script trap and are documented in the lane report
  (no-node test-guard gap; publish-dir mode 0700 under umask
  077 — the script now normalises publish dir modes; F-6
  detail row shadowing the data-notice-id write — fixed +
  pinned; one lane-side fixture value error the modal
  validation correctly refused). Attempt 5 COMPLETE
  (snapshot /root/operqon-r41.UXZ90Z). The fixture tenant
  6cfa07e2 joins the fixture-cleanup queue. NEXT (unchanged):
  demo2 is the designated first REAL self-service run; C1+C3
  + the tile icon ride the oc11 image cycle; the pairing
  (oc12) lane runs separately.
  [deploy lane → coordinator]
- 2026-11-09 — **DESIGN PROGRAMME (ERP frontend) — decision chain,
  design complete, build started.** Chain: the v2/v3 HTML/CSS design
  directions were rejected by the owner → Orven (dark + green)
  approved 2026-11-09 11:06 PKT → at 11:12 the owner switched to
  supplying the designs himself in Figma, item by item → at 12:00 he
  supplied DreamsPOS (DreamsTech, Figma Community file
  `1NuD8im5R2GSz4Zdf5AsHG`) → six treatment images were built
  (Dashboard + POS × DreamsPOS as-is / Orven re-skin / hybrid; report
  `hidden_files/team-theme-options.md`) → **Option 1 (DreamsPOS light
  as-is) LOCKED 12:44 PKT**; Orven is superseded for the ERP frontend
  only — console/portal designs still come from the owner separately.
  Vendor file: the FREE Community edition — 62 screens, light-only,
  orange `#FE9F43` / navy `#092C4C`, Nunito Sans, licensed CC BY 4.0
  with attribution to DreamsTech (intake:
  `hidden_files/team-dreamspos-intake.md`; a Credits & Licence page
  rides in the working file). Working duplicate: "Operqon ERP —
  Design (DreamsPOS base)", key `6CNjuF2lkBlkg5xB0SX5ER`, in IRFAN
  HAIDER's team on the Rektrs Figma account. DESIGN COMPLETE: the
  working file's Production page = 64 frames across all 10 Operqon
  surfaces (census `hidden_files/team-design-slices91012.md`),
  including ~38 in-style builds for the surfaces the free file lacked
  (Sales/Buying documents, Accounts, People/Admin, Settings);
  arithmetic patterns verified (balance sheet / trial balance /
  journal / aging); 2 animation prototype flows. Dark theme = Slice
  11, waits on the purchased kit (recorded as GAP-11). PURCHASE: the
  owner buys the commercial rights DIRECTLY from DreamsTech himself
  ("main direct contact Ker k buy kron copyrights", 2026-11-09
  12:25 PKT); the ThemeForest checkout prep (item 38834413, verified
  total $38) was stood down unused — nothing was purchased by Muse.
  The full commercial kit advertises 300+ pages + Dark & Light Modes
  + Figma files included. BUILD STATE: own-frontend foundation slice
  at `~/workspace/operqon-team/own-frontend/`; tokens aligned to the
  locked Option 1 light language (GAP-07 resolved for light; dark
  tokens provisional until the purchased kit lands); S1 Home wired
  to the GAP-01 contract (backend method
  `operqon_core.api.home.get_home_summary` still to build —
  design-side and client-side ready); S2 auth in progress; build
  slice order S3–S9 in that tree's `GAPS.md`. Queue unchanged:
  console + portal designs from the owner separately; demo2
  self-service run + Slice 10 (W1 close) still await his go-ahead.
  [team → Muse]
- 2026-11-09 — **BENCH PROOF + RE-PROOF — GAP-01/02/03/04/05
  (reports `hidden_files/team-bench-proof-gap-methods.md`,
  `hidden_files/team-bench-reproof.md`; fix reports
  `hidden_files/team-fix-matrix-reads.md`,
  `hidden_files/team-fix-child-reads.md`,
  `hidden_files/team-fix-home-perf.md`,
  `hidden_files/team-fix-print-proxy.md`).** FIRST PROOF verdicts:
  the three first methods' arithmetic was exactly right against a
  real site (known-answer dataset reproduced; GAP-04 aging PASS,
  see below), but GAP-01/02 reachability FAILED for every governed
  role (clean 403, never a 500) and GAP-01/02 child sections were
  empty — two defect classes, both in the surrounding platform,
  not in the methods' arithmetic. DEFECT CLASS 1 — child-table
  reads: on this pin, `frappe.get_list` on a child DocType
  (Item Reorder, Sales Invoice Item, Sales Order Item) silently
  returns name-only rows, dropping every requested field, so
  reorder levels / `is_low` and the invoice-line sections
  (top-selling, categories, recent-sales item fields) could never
  populate. FIX (two steps): first the U8 per-parent `get_doc`
  reads (parents fetched via permission-checked list; child rows
  taken from the loaded parent; unreadable parents skip-and-
  continue, never a 500), then the Route-2 parent-keyed BULK read
  for Home's invoice-item leg (`frappe.db.get_all` on Sales
  Invoice Item keyed by `parent IN` chunks of 500 over the
  permission-checked invoice list, projecting only the consumed
  columns). POSTURE AMENDMENT, FENCED, recorded in code in
  `operqon_core/api/__init__.py`: bulk child reads are allowed
  ONLY in `home.py`, ONLY on Sales Invoice Item, ONLY parent-keyed
  to a permission-checked list, ONLY the projected columns;
  `frappe.db.get_all` applies no permissions itself — safety
  derives solely from that parent-key constraint — and every
  other bulk read (other DocType, other filter shape, other
  module, the `frappe.get_all` alias), raw SQL and
  `ignore_permissions` remain forbidden. PERFORMANCE: with U8,
  home summary at 5,007 invoices took 17.94 s (Administrator) /
  47.06 s (Tenant Admin) vs 0.227 s pre-fix; Route 2's re-proven
  expectation was sub-second / ≲2 s, and the oc13 staging volume
  re-time (below) measured 0.25–0.27 s at 5,032 invoices with
  exactly 10 bulk calls and zero Sales Invoice `get_doc` loads.
  DEFECT CLASS 2 — access matrix: GL Entry and Bin were missing
  from `role_matrix.json`, so GAP-01/02 returned 403 for governed
  roles. FIX: the matrix now grants GL Entry + Bin READ (and only
  read) to all seven governed roles; Custom DocPerm count
  181 → 195; DocTypes 31 → 33. No matrix entries were added for
  Item Reorder / Sales Invoice Item — child DocTypes ride their
  parents' permissions once reads go through parent `get_doc`.
  **EXPOSURE NOTE (verbatim in substance from the fix report): a
  DocPerm read lets those roles list/open individual GL Entry
  records directly (raw ledger rows for companies in their scope
  grants) — bounded by company scope and read-only; GL Entry is
  company-scoped (company_field "company", NOT branch-scoped, so
  branch-limited roles read company-wide within granted
  companies); the narrower alternative was rejected because it
  would leave Home 403ing for Sales/Stock; narrowing Home's
  audience later is the honest route if the owner wants
  Sales/Stock out of the raw GL list.** Bin fact: Bin carries NO
  company column on this pin (its company is its Warehouse's), so
  Bin is deliberately NOT company_scoped in the matrix (marking
  it would generate SQL against a nonexistent column and deny
  every Bin read). RE-PROOF verdicts (isolated throwaway stack
  only): GAP-01 PASS (all governed roles 200, child sections
  restored, numbers exact, scoping proven); GAP-02 PASS
  (reorder/`is_low` work for the first time on a real site —
  MacBook Pro reorder_level 15, `is_low` true at qty 13);
  convergence PASS (195/195 matrix-attributable Custom DocPerms,
  exactly 7 read rows each on GL Entry and Bin, all other flags
  0); no-regression PASS. GAP-03: the Desk path
  `frappe.desk.query_report.run` ("General Ledger") is PROVEN
  BLOCKED for every scoped role on the pin ("You don't have
  access to Report: General Ledger") → GAP-03 closes on the
  owned fallback method `get_general_ledger` (bench-proven:
  reconciles exactly with the Desk report for Administrator and
  with SQL ground truth — opening 0.0, closing 538,000 on the
  proof account). GAP-04 aging: PASS (buckets 90,000 / 25,000 /
  10,000 / 30,000 = 155,000; GAP-01 `invoice_due` == aging total;
  the 107,000 delta vs the Desk Accounts Receivable report is
  fully explained — different contracts: invoice-outstanding vs
  GL party-netting incl. the unallocated receipt and the return
  invoice). GAP-05: PASS-WITH-CONDITIONS at re-proof → hardening
  lane then built locally (report `team-fix-print-proxy.md`):
  (a) the pin's `validate_print_permission` is read-OR-print, so
  read-only roles were served PDFs — the fix added an explicit
  per-document print check in
  `operqon_core.api.print.get_invoice_pdf` so the matrix's print
  distinction holds (download is never invoked on a print miss);
  (b) a nonexistent print-format name silently fell back to the
  standard form print view — the same lane added explicit format
  validation in the proxy. Both hardening pieces WERE in oc13
  and were spot-proven there (see the oc13 entry: read-without-
  print → 403, nonexistent format → clean 417, default format →
  200 PDF) — BUT the oc13 proof exposed the remaining defect
  that rides oc14: an EXPLICIT valid format name
  (`print_format="Operqon Invoice"`) returns 417 "does not
  exist" for every tenant role, because on this pin Print Format
  read is System Manager-only, so the validation's read gate
  reports even the valid default format as nonexistent
  (Administrator renders the identical PDF; the default-format
  path is unaffected for all roles). The oc14 remedy is the
  print lane's decision: existence + doc_type check without the
  read gate, or grant Print Format read via the access matrix.
  BENCH GUARDRAILS THAT HELD (both proof lanes): isolated
  throwaway stack only; staging site list identical to baseline
  (43 dirs) after cleanup; provider marker unchanged
  (`6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`); Rektrs site pong.
  OPEN (unchanged, coordinator item): the >5,000-document story
  in Q9 above. [bench + fix lanes → coordinator]
- 2026-11-09 — **oc13 DEPLOYED ON THE STAGING PAIRING (tenant
  pairing image cycle only; report
  `hidden_files/team-oc13-cycle.md`).** Deployed image:
  `operqon/erpnext-tenant:v16.53.0-oc13`, sha256
  `35ce0adfd882119dab72e4049bfee3610e5454f2dea50b248a6ffee3112a58a7`
  (4,771,427,548 B). It carries: the GAP-01/02/03/04/05 methods
  (fixed, per the bench entry above), the 195-DocPerm access
  matrix, S9 governance, the GAP-09 serving build, and the FBR
  integrations composition (hooks append-merge of
  `integrations/wiring.py` — appended, never replaced;
  `install_all()` routing of `install_integrations()`; the
  Operqon Integration record's Activate action wired to FBR
  activation). OWN FRONTEND: packaged build `v-751315221a5b`
  served at route `/operqon` on the tenant site (same-origin;
  session bridge `operqon_core.api.session.get_session_bridge`).
  Frontend wiring W1–W4 applied: `config.auth.mode` → "live",
  exchangePath → the session bridge, the `{"message": …}`
  envelope unwrap, and `payload.roles` → `visibleNavFor`
  (role-filtered nav). The `role_home_page` flip was TAKEN in
  this cycle (all 7 Operqon roles `/app/operqon-home` →
  `/operqon`) after route proof. Volume re-time on staging:
  0.25–0.27 s at 5,032 invoices (Tenant Admin 0.265/0.267/
  0.247 s; pre-fix bench numbers were 17.94 s / 47.06 s).
  Signed-in HTTP proof on the scratch site: 39/40 — the single
  FAIL is the explicit-print-format finding recorded in the
  bench entry above (outside the cycle's named spot-check set;
  the three named print checks all PASS). ROLLBACK: oc12 image
  retained on the box (`operqon/erpnext-tenant:v16.53.0-oc12`,
  sha256 ce549b6c1a8a…) + the compose backup at
  `/opt/operqon-r2-staging-bench/compose.yaml.pre-oc13-20261109`
  (restore it + `docker compose up -d`, then per-site cache
  clears + backend restart per the swap lessons). Provider
  release marker UNCHANGED:
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff` (oc13 is a tenant
  pairing image cycle, not a provider release); staging site
  count unchanged at 43; Rektrs pong OK; neighbours green.
  HONEST PROOF LEVEL: the oc13 site proof is HTTP-level (guest
  redirect, role reachability, method answers, asset 200s) —
  there was NO interactive browser render proof in the cycle.
  oc11 remains a labelled FAILED-GATE artefact — never deploy
  it. Snapshot boundary: the cycle worked only from the
  2026-11-09T14:21Z snapshots; anything a sibling lane landed in
  the live tree after that rides oc14 (the W2 outbox slice,
  below, is exactly that case). [oc13 lane → coordinator]
- 2026-11-09 — **W2 OUTBOX SLICE — BUILT LOCALLY, NOT DEPLOYED
  (rides oc14; report `hidden_files/team-w2-outbox.md`).**
  Built in the app-pack tree under `operqon_core/integrations/**`
  only (no image build, no deploy, no VPS contact): ENG-073
  (transactional outbox) and ENG-075 (API idempotency, submission
  surface) BUILT; ENG-090 transport submission state machine
  BUILT (queued → sent → confirmed / failed-retryable /
  failed-permanent, backoff as data — RetryPolicy 4 attempts,
  delays [60, 300, 1500] s — circuit breaker derived from
  durable attempt history, dead-letter + replay for
  transport-exhaustion only); ENG-074 consumer inbox = the
  receipt-application half only (a generic consumer inbox is NOT
  built — no inbound consumers exist yet); ENG-076 NOT built
  (no inbound webhooks exist yet). Invariants: the idempotency
  key is derived from document identity only (stable across
  retries/restarts, never random) and is sent to the integrator
  as the `Idempotency-Key` header; consult-before-send (a
  confirmed entry returns its stored receipt and stamps the
  invoice with NO new call); a rejection can never stamp an
  invoice (`fbr_invoice_number` stays empty on every failure
  path; a provider rejection is per-document — the integration
  record stays Active — while transport exhaustion / circuit
  opening sets the record to Error); errors are sanitized/
  redacted everywhere, hostile-echo probed (credentials appear
  nowhere stored or shown). Remainder named in the report:
  ENG-090's `unknown` → status-query-before-retry step is NOT
  built (a timeout is a transport failure whose retry reuses
  the SAME key + SAME `invoiceRef`); no replay UI. oc14
  COMPOSITION OWED: move the outbox DocType definition
  (`integrations/outbox_doctype.json` inner `definition`) onto
  the canonical sync path as
  `operqon_core/operqon_core/doctype/operqon_integration_outbox/operqon_integration_outbox.json`
  and retire the in-package spec (or keep
  `ensure_outbox_doctype()` as a no-op belt-and-braces); decide
  outbox-drain scheduling at composition time. [W2 lane →
  coordinator]
- 2026-11-09 — **IN FLIGHT AT THIS SYNC (state, truthfully).**
  (1) Print-format validation remedy (explicit valid format
  417ing for tenant roles — see the bench entry) — rides oc14.
  (2) Frontend live data-source wiring (switching the
  own-frontend surfaces from fixture sources to the live GAP
  methods end-to-end; oc13 applied only the W1–W4 auth/session
  wiring and serves the build — the per-surface data-source
  flip is the in-flight piece) — rides oc14. (3) The W2 outbox
  slice (entry above) — rides oc14. (4) demo2 run still awaits
  the owner's word (run pack ready; the owner's 6 steps; the
  Rs 19,999 real transfer is the owner's). (5) S8 dark theme
  waits on the vendor kit (the owner's direct DreamsTech
  purchase). (6) Console + portal designs are owner-supplied,
  not yet received. [coordinator]
- 2026-11-09 — **oc14 DEPLOYED ON THE STAGING PAIRING (tenant
  pairing image cycle only; report
  `hidden_files/team-oc14-cycle.md`).** Deployed image:
  `operqon/erpnext-tenant:v16.53.0-oc14`, sha256
  `c223a552804654a55fc4fea0c0fdedf0a025ac6d1db7415dbf2a53b5e33589ac`,
  on the staging bench (44 sites, incl. the new `w14proof`
  scratch site created by this cycle; baseline was 43). GATE
  GREEN: `verify_image` 12 PASS lines in-build AND standalone;
  in-image suites ALL OK — api 59 / integrations 46 / access 13
  / saas 125. OWN FRONTEND: packaged build `v-9693b59c694f` with
  the live flips shipped (auth mode "live",
  `homeSource`/`stockSource`/`accountsSource` "live").
  LIVE-DATA PROOF PASS for all 7 governed roles: the frontend's
  Home / Stock / Accounts live branches serve REAL tenant data,
  `isSample=false` throughout, seeded known answers matched
  against an Administrator control — Lahore-scoped roles: sales
  690,000 / profit 561,000 / due 155,000; aging 90,000 / 25,000 /
  10,000 / 30,000 = 155,000; GL Bank – GPC opening 0 / dr
  635,000 / cr 97,000 / closing 538,000; MacBook qty 13, reorder
  15, `is_low` true. PRINT-FORMAT FIX PROVEN: tenant role +
  explicit `print_format="Operqon Invoice"` → 200 PDF (oc13:
  417 for every tenant role); a nonexistent format → clean 417;
  read-without-print → 403. OUTBOX LIVE: the Operqon Integration
  Outbox DocType is live via the canonical sync path (the oc14
  composition owed in the W2 outbox entry above is DONE), and
  the hourly drain
  (`operqon_core.integrations.drain.drain_outbox`) is registered
  and inert-safe (no `pk_fbr` record anywhere → drained 0, no
  errors). ENTRY-PATH CONVERGENCE PROVEN on every ordinary path:
  fresh login (`home_page=operqon`), site root (serves the
  frontend shell), and the apps tile (route `/operqon`) all land
  governed users on the new Operqon frontend; System Manager /
  Administrator keep full Desk access by design. ONE NAMED
  RESIDUAL GAP: a legacy `/app/operqon-home` bookmark is
  rewritten by the pin to `/desk/operqon-home` before
  `before_request` hooks run, so it still opens the Desk SPA —
  the fix (extend the hook to `/desk/operqon-home`, or a website
  redirect rule for the legacy path) is in the post-oc14
  closeout lane and rides the next image cycle. STILL
  SAMPLE-BACKED (honest banner stays): Sales/Buying list+form
  screens, POS, and Trial Balance + other reports — no proven
  live server methods yet; those are the next build lanes.
  ROLLBACK: oc13 image retained on the box
  (`operqon/erpnext-tenant:v16.53.0-oc13`, sha256
  `35ce0adfd882119dab72e4049bfee3610e5454f2dea50b248a6ffee3112a58a7`)
  + the compose backup at
  `/opt/operqon-r2-staging-bench/compose.yaml.pre-oc14-20261109`
  (restore it + `docker compose up -d`, then per-site cache
  clears + backend restart per the swap lessons). Provider
  release marker UNCHANGED before and after:
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff` (oc14 is a tenant
  pairing image cycle, not a provider release; production
  provider lines untouched). HONEST PROOF LEVEL: all oc14 proof
  was HTTP-level from the VPS (no interactive browser); the
  owner's own browser check remains the final human
  confirmation. oc11 remains a labelled FAILED-GATE artefact —
  never deploy it. [oc14 lane → coordinator]
- 2026-11-09 — **IN FLIGHT AT THIS SYNC — POST-oc14 (state,
  truthfully).** (1) The `/app/operqon-home` legacy-bookmark
  fix (extend the convergence hook to `/desk/operqon-home`, or
  a website redirect rule) — post-oc14 closeout lane; rides the
  next image cycle. (2) Sales/Buying list+form screens, POS,
  and Trial Balance + other reports are still sample-backed —
  no proven live server methods yet; those are the next build
  lanes, and the sample banner remains on those screens.
  (3) demo2 run still awaits the owner's word (run pack ready;
  the owner's 6 steps; the Rs 19,999 real transfer is the
  owner's). (4) S8 dark theme waits on the vendor kit (the
  owner's direct DreamsTech purchase). (5) Console + portal
  designs are owner-supplied, not yet received. (6) The owner's
  own browser check of the oc14 frontend remains the final
  human confirmation (all cycle proof was HTTP-level).
  [coordinator]
- 2026-11-09 — **GAP-12–15 LIVE METHODS BUILT LOCALLY (rides
  oc15; report
  `hidden_files/team-live-methods-sales-buying-pos-tb.md`)
  + POST-oc14 CLOSEOUT (report
  `hidden_files/team-post-oc14-closeout.md`).** This entry
  closes items (1) and (2) of the IN FLIGHT list above.
  LIVE METHODS (canonical trees, local build only at this
  point): GAP-12 `api/sales.py` — `get_sales_invoices` /
  `get_sales_invoice` (permission-checked list + gated form
  read; Sales Return Form screen built in the frontend; live
  SAVE for returns refused with a typed error by design).
  GAP-13 `api/buying.py` — PO/PI lists + form reads. GAP-14
  `get_trial_balance` + `get_balance_sheet` in
  `api/accounts.py` (pure builders unit-pinned: TB 3,720,000
  = 3,720,000; BS 3,635,000 = 3,635,000 incl. P&L fold
  605,000). GAP-15 `api/pos.py` — READ-ONLY
  `get_pos_catalogue` / `get_pos_customers`; **no write
  method exists — the Desk POS remains the register of
  record and GAP-06 stays OPEN**. Governance unchanged (all
  read DocTypes already all-seven read; Item Price
  deliberately NOT read). Both TB/BS and the lists inherit
  the documented 5,000-row fetch cap (envelope `capped`).
  Counts at build: test_gap_methods 45 → 59 OK; frontend
  harness 376 → 401. CLOSEOUT: canonical trees reconciled
  byte-identical to the shipped oc14 snapshot (app-pack
  289/289 files, own-frontend 25/25; the stale packaged
  build v-af8c5b0f24ca REMOVED from canonical — a generated
  artefact, regenerable via `scripts/package_frontend.py`).
  LEGACY-BOOKMARK FIX BUILT (canonical, unit-pinned): the
  pin canonicalises /app → /desk BEFORE `before_request`
  hooks run and website redirect rules are never consulted
  for desk/* paths (pin-code evidence in the report), so
  the operative layer is a NEW `after_request` hook in
  `landing.py`: governed users hitting `/app/operqon-home`
  or `/desk/operqon-home` get 302 → /operqon; System
  Manager / Administrator untouched. test_landing.py 11
  tests; saas suite 136. [live-methods + closeout lanes →
  coordinator]
- 2026-11-09 — **oc15 DEPLOYED ON THE STAGING PAIRING
  (tenant pairing image cycle only; report
  `hidden_files/team-oc15-cycle.md`).** Deployed image:
  `operqon/erpnext-tenant:v16.53.0-oc15`, sha256
  `48d4bf5a833efbd3bffe666c5e8fff03dada2e24120489f686623d63fdcc8a82`,
  on the staging bench (44 → 45 sites, incl. the new
  `w15proof` scratch site). GATE GREEN: packaged build
  `v-e91b9ca068e5` with the sales/buying/pos flips shipped
  (home/stock/accounts/auth already "live"); frontend
  harness 401 PASS / 0 FAIL; `verify_image` 17 PASS lines;
  in-image suites ALL OK — api 73 / integrations 46 /
  access 13 / saas 136. LIVE-DATA PROOF PASS for all 7
  governed roles + Administrator on the new surfaces:
  Sales invoices + returns + form, Buying PO list 210,000
  total, PI 80,000 due 30,000 + return −5,000, Trial
  Balance 22,907,000 = 22,907,000 (`capped=False`,
  per-account == direct-DB GL truth), Balance Sheet
  808,000 = 808,000 with P&L fold 858,000, POS catalogue +
  customers; `isSample=false` throughout. ENTRY-PATH
  HEADLINE PASS — **the oc14 residual gap is CLOSED**:
  governed users on `/app/operqon-home` AND
  `/desk/operqon-home` → 302 → /operqon → 200 shell (the
  closeout's after_request fix, HTTP-proven on both
  spellings); System Manager / Administrator Desk
  untouched. ONE FINDING (named, fixed in oc16): the
  GAP-12/13 list methods had NO docstatus filter, so a
  seeded DRAFT invoice (999,999, "Ghost") surfaced in the
  Sales list for every role — submitted-row totals were
  exact, but drafts were visible by default. ROLLBACK:
  oc14 image retained on-box (sha256 `c223a552…`) +
  compose backup
  `/opt/operqon-r2-staging-bench/compose.yaml.pre-oc15-20261109`.
  Provider release marker UNCHANGED before and after:
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff` (tenant
  pairing cycle, not a provider release). HONEST PROOF
  LEVEL: HTTP-level from the VPS; the owner's own browser
  check still outstanding. oc11 remains a labelled
  FAILED-GATE artefact — never deploy it. [oc15 lane →
  coordinator]
- 2026-11-09 — **LOGIN CHAPTER (1 of 4) — THE REKTRS
  LOGIN LOOP DIAGNOSED: CSRF (report
  `hidden_files/team-rektrs-login-diagnosis.md`).** The
  owner reported ~22:44 PKT "login say agy nahi jata"
  (the login does not go forward). Live-browser
  reproduction: the SPA loops — a transient stub shell
  (Al-Noor Traders / Stub user / SAMPLE) then back to
  `#/login`. DIAGNOSIS PROVEN, mechanism step by step:
  **there is no shadow/stub copy anywhere** — the "stub"
  is the LIVE shell's own hard-coded placeholder markup,
  replaced only after a successful bootstrap. The
  bootstrap POST to `get_session_bridge` carried **no
  CSRF token at all**: the packaged shell had no
  `<!-- csrf_token -->` marker (so Frappe's TemplatePage
  injected nothing) and no frontend fetch sent
  `X-Frappe-CSRF-Token` (`grep -ri csrf` over the
  packaged frontend = 0 hits). Frappe's
  `validate_csrf_token` rejects an unsafe request (400
  "Invalid Request", CSRFTokenError, traceback disabled
  — hence NO Error Log rows) whenever the session holds
  a **saved** csrf token — exactly what a Desk-booted
  session carries, and the owner's flow passes through
  Desk (he holds System Manager). Every earlier battery
  missed it: battery sessions were API-created (no Desk
  boot → no saved token → tokenless POSTs pass) and guest
  checks are GETs. SECONDARY FINDINGS (true, not the
  cause): (1) the Rektrs company is genuinely EMPTY (all
  KPIs 0; Customer 1) — screens work but show an empty
  company until data exists; (2) Rektrs was never
  migrated under oc13/oc14 (Custom DocPerms for Operqon
  roles 115 vs the converged 202; Operqon Integration
  Outbox DocType absent) — the migrate was owed and is
  executed in oc16. FIXES BUILT LOCALLY (reports
  `hidden_files/team-csrf-fix.md` +
  `hidden_files/team-draft-visibility-fix.md`): (a) CSRF
  propagation — the marker added to the shell source, a
  shared `csrfHeaders()` helper in config.js (token read
  AT CALL TIME) applied in `tokenExchange` + api-client
  `api()`/`apiBlob()`; frontend harness §16 pins → 410
  PASS / 0 FAIL; a fail-closed CSRF gate added to
  `verify_image.py`. `ignore_csrf` was NOT set anywhere
  (rejected route). (b) Draft visibility (the oc15
  finding) — shared `resolve_docstatus()` in the
  GAP-12/13 list methods: default submitted-only
  (docstatus=1); explicit `docstatus=0` / `"all"`
  overrides; direct form reads of drafts stay unfiltered
  by design; test_gap_methods 59 → 69 OK, mutation-
  checked. [diagnosis + fix lanes → coordinator]
- 2026-11-09 — **oc16 DEPLOYED ON THE STAGING PAIRING
  (tenant pairing image cycle only; report
  `hidden_files/team-oc16-cycle.md`).** Deployed image:
  `operqon/erpnext-tenant:v16.53.0-oc16`, sha256
  `7b0b644a71f3f1795c69cbb2e97212cdd1f5ebf0f468c0535d57f500c3a787e5`,
  on the staging bench (45 → 46 sites, incl. `w16proof`).
  Carries the CSRF propagation fix + the draft-visibility
  fix from the entry above. GATE GREEN: packaged build
  `v-b76fffae60f8`; frontend harness 410 PASS / 0 FAIL;
  `verify_image` 18 PASS lines incl. the CSRF line
  (`PASS: CSRF propagation in image (packaged shell
  carries the csrf_token marker; shipped config.js +
  api-client.js send X-Frappe-CSRF-Token)`); in-image
  suites ALL OK — api 83 / integrations 46 / access 13 /
  saas 136. NAMED DISCREPANCY (recorded, closed in
  oc17): the oc15 flips + GAP-12–15 gate blocks were
  again SNAPSHOT-ONLY — canonical config still read
  sales/buying/pos = "fixture" and canonical
  verify_image still carried the oc14 pin; the shipped
  config reads all-live exactly as oc15 shipped.
  **REKTRS MIGRATE DONE** (pre-migrate DB backup taken
  first): Custom DocPerms 130 → 202 total (Operqon-role
  subset 115 → 187); Operqon Integration Outbox DocType
  present; convergence updated 0 users — CORRECT, its
  only human user holds System Manager (exempt by
  design). PROOF: guest battery PASS (Rektrs +
  w16proof); **CSRF HEADLINE BATTERY PASS at HTTP
  level** — Desk-booted sessions with a SAVED csrf token
  verified in `tabSessions` first (the owner's exact
  failing configuration): bridge POST **400 without the
  header / 200 + live payload with it**, on w16proof AND
  Rektrs, governed + System Manager alike (a pure SM's
  payload `roles: []` is correct — the bridge returns
  Operqon roles only); draft battery **104/104 PASS**;
  per-role regression PASS (corrected battery 32/32 —
  the main battery's 8 "fails" are the known harness
  artefact asserting `isSample` on the GAP-04 aging
  envelope, which by design carries no such field; the
  values matched); print + outbox + entry paths PASS.
  ROLLBACK: oc15 image retained on-box (sha256
  `48d4bf5a…`) + compose backup
  `/opt/operqon-r2-staging-bench/compose.yaml.pre-oc16-20261109`
  (+ Rektrs' pre-migrate DB backup). Provider marker
  UNCHANGED: `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`.
  **STILL UNPROVEN, named exactly: the owner's own
  real-browser sign-in on Rektrs — every proof here is
  HTTP-level.** [oc16 lane → coordinator]
- 2026-11-09/10 — **LOGIN CHAPTER (2 of 4) — THE BUTTON
  DEFECT: DIAGNOSIS PROVEN + FIX BUILT LOCALLY (report
  `hidden_files/team-login-button-diagnosis.md`).** The
  owner tested oc16 himself in a driven live session
  (~23:36–23:40 PKT, on his instruction: sign him in
  HERE, then audit every screen on-page): 3 clicks on
  "Login with Operqon" → instant bounce to
  `/operqon#/login`, Keycloak NEVER reached. He then
  signed in SUCCESSFULLY at operqon.cloud/customer
  (Keycloak `operqon-customers` — account + realm
  HEALTHY), clicked the portal's "Open ERP", landed on
  the tenant `#/login`, 3 more clicks, same bounce (6
  total) — even while holding a fresh IdP session.
  DIAGNOSIS PROVEN: the shipped live-mode click handler
  did exactly ONE thing —
  `location.assign("/login?redirect-to=/operqon")`. Only
  session-holders can ever click it (Guests are bounced
  by the www controller before the shell is served), and
  Frappe's `www/login.py` redirects exactly those users
  straight back to /operqon without rendering the page —
  an instant, sign-in-less circle. The originally
  designed PKCE path is triply dead: the shipped
  authorize/client/redirect values are `.example`
  placeholders; the per-tenant Keycloak client registers
  EXACTLY ONE redirect URI — the Frappe social-login
  callback (the SPA URI → live Keycloak 400, measured;
  the callback → 200); and Frappe's callback requires a
  server-minted single-use OAuth `state` a static SPA
  cannot create. Do NOT "fix" the placeholders by filling
  in real IdP values (see the warning comment in
  canonical config.js). SERVER SIDE HEALTHY (all
  verified live): Social Login Key complete/correct,
  Keycloak client enabled, the owner's User enabled +
  linked + freshly logged in. FIX BUILT LOCALLY
  (canonical own-frontend): **session-first click** —
  `onLoginClick`'s live branch first runs
  `establishSession()` (the session bridge, in place) →
  workspace; it falls back to the /login navigation ONLY
  when the bridge refuses (true Guest / expired
  session). Frontend harness §17 pins drive the real
  handler: 410 → 416 PASS / 0 FAIL; app-pack suites
  unaffected (40 OK). ONE HONEST UNKNOWN left at this
  point (§5.4 of the report): why the in-browser
  load-time bootstrap yielded no token while HTTP
  batteries pass — closed in chapter 3 below. [diagnosis
  lane → coordinator]
- 2026-11-09/10 — **oc17 DEPLOYED ON THE STAGING PAIRING
  (tenant pairing image cycle only; report
  `hidden_files/team-oc17-cycle.md`).** Deployed image:
  `operqon/erpnext-tenant:v16.53.0-oc17`, sha256
  `fa5826678c7270b2d0dac36ce46d5640370f949b1b25d02ad9459b4736a038b1`,
  on the staging bench (46 → 47 sites, incl. `w17proof`).
  Carries the session-first login-button fix. **STAGE 0
  CLOSED THE CANONICAL-RECONCILIATION DEBT**: exhaustive
  diff of canonical vs the oc16 snapshot; the oc15
  GAP-12–15 gate blocks + the 6-switch flips assertion
  merged INTO canonical `scripts/verify_image.py`;
  canonical config data-source values stay "fixture" as
  committed defaults (live flips remain a packaging
  step); the login-fix files are canonical-wins, never
  overwritten. Canonical harness 416 PASS / 0 FAIL;
  suites api 83 / integrations 46 / access 13 / saas
  136. GATE GREEN: packaged build `v-330611a1f7bc`;
  `verify_image` 19 PASS lines incl. the NEW oc17 login
  gate line — the packaged app.js must export
  `onLoginClick` with `await establishSession()` BEFORE
  the /login fallback assign and no `buildAuthorizeUrl`
  in the live branch — **tested BOTH ways** (PASS on the
  oc17 build; FAIL on the oc16 bounce-only handler and
  on an exported-but-bounce-only mutation). PROOF:
  guest battery PASS; **SERVED-BYTES PROOF PASS on
  Rektrs** — the served packaged `src/app.js` sha256
  `360f7f38f86fd30b39bd27252d301c6d6485e6c852dcfca358172173772bec73`
  == the packaged manifest AND contains the session-
  first handler (identical on w17proof); per-role
  regression PASS (corrected 32/32; Lahore 690,000 /
  561,000 / 155,000, aging 90/25/10/30; all-branch
  912,000 / 783,000 / 377,000; GL Bank-GPC closing
  538,000; TB 22,907,000 = 22,907,000; BS 808,000 =
  808,000); draft battery 104/104; CSRF spot check PASS;
  print + outbox + entry paths PASS. NO Rektrs migrate
  this cycle (nothing server-side changed). Lane note:
  the coordinator wrapper ended ~30 s after dispatch;
  the executor child completed the cycle — state was
  recovered from the progress file (NEVER-STOP applied).
  ROLLBACK: oc16 image retained on-box (sha256
  `7b0b644a…`) + compose backup
  `/opt/operqon-r2-staging-bench/compose.yaml.pre-oc17-20261109`.
  Provider marker UNCHANGED:
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`. **STILL
  UNPROVEN: the real-browser proof** — see chapter 3.
  [oc17 lane → coordinator]
- 2026-11-10 — **LOGIN CHAPTER (3 of 4) — DOOR A FAILS
  AGAIN ON oc17; §5.4 ROOT CAUSE PROVEN + FIX BUILT IN
  CANONICAL (report
  `hidden_files/team-login-loop-oc17-diagnosis.md`).**
  Real-browser re-proof (00:16–00:31 PKT): the owner
  clicked "Login with Operqon" three times in a live
  browser; every click went /operqon → /operqon#/login
  within ~2 s; Keycloak was NEVER reached; no workspace
  landing. FORENSICS (bench frontend logs, the click
  window): 8 session-bridge POSTs, **ALL 400** (296 B
  CSRFTokenError bodies); each click = bridge POST 400 →
  fallback → GET /login **301** (the session-holder
  bounce) → /operqon 200 → bootstrap POST 400 →
  #/login. ROOT CAUSE PROVEN: Frappe v16.53.0
  `BaseTemplatePage.add_csrf_token` replaces the shell's
  `<!-- csrf_token -->` marker with
  `<script>frappe.csrf_token = "…";</script>` — an
  assignment that **assumes the `frappe` global already
  exists** (true in Frappe's own pages via their boot
  scripts). Our standalone shell never defined it, so in
  every real browser the injected script throws
  `ReferenceError: frappe is not defined`, the token
  never lands, `csrfHeaders()` sends no header, and the
  bridge POST is rejected 400 for ANY session holding a
  saved csrf token. **The oc16 CSRF fix was therefore
  INCOMPLETE** — marker + header plumbing shipped; the
  global they write to did not exist. This closes the
  button diagnosis's §5.4 unknown. Also proven: Door A
  was a SESSION-HOLDER test, not a guest test — the
  shared default browser profile carried the owner's
  live Rektrs session (saved csrf token present;
  lastupdate = the first click's second). The cache
  hypothesis is DISPROVEN (the oc17 build v-330611a1f7bc
  genuinely ran — only the fixed handler POSTs the
  bridge at all). The shell is the home-page render of
  the operqon www page at `/` (Website Settings
  home_page empty; GET / ≡ GET /operqon). REAL-USER
  IMPACT: a product fix WAS owed — the defect fires for
  any real returning signed-in user in a real browser.
  FIX BUILT IN CANONICAL (not yet packaged at this
  point): `own-frontend/index.html` gains
  `<script>window.frappe = window.frappe || {};</script>`
  immediately before the marker; harness §18 adds a
  source-order pin, a `node:vm` EXECUTION pin (pre-fix
  shell reproduces the ReferenceError exactly; post-fix
  the token lands, zero errors), a mutation pin, and a
  tokenExchange-drives-header pin → **420 PASS / 0
  FAIL**; canonical `verify_image.py` CSRF gate extended
  fail-closed (the guard must precede the marker; FAIL
  on the oc17 shell, PASS on the fixed source).
  **STANDING LESSONS (binding on all future proof
  design): (1) a flow counts as proven only when entered
  through the SAME door the user enters — test-operator
  entries (API login, Desk boot) do not prove the user's
  own path; (2) a new browser task is NOT a clean guest —
  cookie/cache state must be proven from server logs
  before calling any door test "guest"; (3) a test pin
  that hand-supplies the environment the real page lacks
  proves nothing — pins must EXECUTE the real shell/code
  (the node:vm execution pin is the corrective
  pattern).** [forensics lane → coordinator]
- 2026-11-10 — **oc18 DEPLOYED ON THE STAGING PAIRING
  (tenant pairing image cycle only; report
  `hidden_files/team-oc18-cycle.md`).** Deployed image:
  `operqon/erpnext-tenant:v16.53.0-oc18`, sha256
  `8c41ce432a78793e7bfbd1f1ff848b12f22038f0cb1b6b170013bb0afa8b702d`,
  on the staging bench (47 → 48 sites, incl.
  `w18proof`). Carries ONLY the CSRF-global fix on top
  of oc17. STAGE 0 verified canonical holds EXACTLY the
  forensics lane's three changes (shell guard, harness
  §18, verify_image guard-order extension) + expected
  packaging-state diffs; canonical harness 420 PASS / 0
  FAIL; suites api 83 / integrations 46 / access 13 /
  saas 136. GATE GREEN: packaged build `v-5786e7869c19`
  (guard before marker; `--check` no drift); the CSRF
  gate tested BOTH ways (FAIL on the oc17 shell / PASS
  on the oc18 build); `verify_image` 19 PASS lines
  in-build + standalone; in-image suites ALL OK.
  `ignore_csrf` / `allowed_referrers` nowhere. PROOF
  (HTTP level): guest battery PASS (Rektrs + w18proof);
  **SERVED-SHELL PROOF 8/8 — on Rektrs AND w18proof the
  served /operqon carries the guard (byte 836) BEFORE
  Frappe's real injected token assignment (byte 881)**;
  served-bytes PASS (app.js `360f7f38…` == manifest,
  session-first handler in served bytes); CSRF battery —
  saved-token sessions verified in `tabSessions`, bridge
  **400 without header / 200 + live payload WITH the
  token the page itself serves** (the Rektrs proof user
  was disabled again after, enabled=0 verified);
  per-role regression PASS (corrected 32/32 — the main
  battery's 8 "fails" are the known GAP-04 aging
  `isSample` artefact, values exact); draft battery
  104/104; print ALL PASS (29,679 B / 25,279 B PDFs;
  bogus format 417; Stock User 403) + outbox inert
  (DocPerms 202); entry paths PASS; R1/R2 readyz,
  console, portal all 200. NO Rektrs migrate (shell +
  build-script changes only). TWO LANE INCIDENTS,
  recorded openly: (1) the first seed attempt hit
  `QueueOverloaded` — **the staging bench has NO RQ
  worker service by design, so the default queue
  re-accumulates scheduler catch-up jobs and crossed
  the pin's 2,900 limit (2,949) between cycles**; the
  default queue only was purged (2,949 → 0; long queue
  untouched) and the seed re-ran clean 19/0. **This
  WILL bite a future cycle unless the bench gains a
  worker or a periodic default-queue purge.** (2) The
  fix's HTML comment contains the literal text
  `frappe.csrf_token = "..."`, which poisoned one naive
  battery token-scrape (false 12/18 run; anchored scrape
  → green) — **rewording that comment is a named
  future-cycle follow-up** under image == snapshot
  discipline. Also closed with reasoning: sessions
  created by a bare API login are served the injected
  value `"None"` — self-consistent (no saved token →
  the CSRF check does not engage) and unreachable via
  any user door. ROLLBACK: oc17 image retained on-box
  (sha256 `fa582667…`) + compose backup
  `/opt/operqon-r2-staging-bench/compose.yaml.pre-oc18-20261110`.
  Provider marker UNCHANGED:
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`. **CLAIM
  CEILING RESPECTED: HTTP proof only — the login is NOT
  called fixed until the owner's own door lands him in
  the workspace.** [oc18 lane → coordinator]
- 2026-11-10 — **LOGIN CHAPTER (4 of 4) — THE OWNER
  LANDS INSIDE, WITH LIVE DATA; THE "STUB LOOK" IS
  THREE LABELLING DEFECTS (report
  `hidden_files/team-phone-stub-diagnosis.md`).** At
  07:59 PKT the owner opened the tenant site on his OWN
  phone and landed INSIDE the workspace — sidebar "Asad
  Ahmad", "Welcome, Asad", Log out present; the login
  bounce is gone on his own device. SERVER-LOG PROOF
  (his phone's window, 02:58:54–02:58:56 UTC): the
  current oc18 build v-5786e7869c19 was fetched FRESH
  (every asset 200, full body, from the current
  content-versioned directory — **the cache hypothesis
  is RULED OUT from the logs**); the session-bridge
  POST answered **200** (246 B); `get_home_summary`
  answered **200** with the LIVE payload of his real
  company — **company "rektrs", currency "PKR",
  isSample false** — and the only 4xx in the window is
  a cosmetic favicon 404. The SAMPLE banner is
  correctly ABSENT (provenance: the payload's
  `isSample === false` clears it). His screenshot
  nonetheless LOOKED like the stub (company "Al-Noor
  Traders", header "Stub user", KPIs "$0") — proven to
  be three pre-existing frontend labelling defects,
  visible in every session state and previously masked
  by the login bounce (nobody had ever landed inside to
  see them): **(1)** the company switcher is static
  placeholder HTML with NO data binding anywhere (and
  the bridge payload carries no company field — company
  lives in the GAP-01 home payload); **(2)** the stub
  role switcher fails to hide in live mode because
  `app.css` `.role-switcher{display:inline-flex}`
  overrides the `hidden` attribute and — unlike the
  SAMPLE banner — there is no `.role-switcher[hidden]`
  CSS override; **(3)** `fmtMoney()` hard-codes "$" and
  the Home render ignores the payload's `currency`
  field, so a live PKR company renders "$0" instead of
  "Rs 0". Compounding artefact **(4)**: the "Finish
  setting up your workspace — 2 of 5 steps done" card
  is the FIXTURE first-run state, shipped by config
  (`adminSource: "fixture"` in the oc18 build) — it
  renders regardless of session health. Every visible
  number/label in the screenshot maps field-for-field
  onto the live empty-company payload (the company is
  genuinely empty; zeros are REAL). The login chapter's
  data-level story is therefore CLOSED: current build,
  bridge 200, live payload, real identity applied. What
  remained was the labelling fix — shipped in oc19
  below. [forensics lane → coordinator]
- 2026-11-10 — **oc19 DEPLOYED ON THE STAGING PAIRING
  + SERVED-CODE PROOF 9/9 (tenant pairing image cycle
  only; report `hidden_files/team-oc19-cycle.md`).**
  Deployed image: `operqon/erpnext-tenant:v16.53.0-oc19`,
  sha256
  `e18b867ae2fe1f7b0713f99c0c3a810709103762c96e379a831a48dd2184f638`,
  on the staging bench (49 → 50 sites, incl.
  `w19proof`; a separate `w19fresh` site served the
  firstrun battery). Carries the three truth-in-
  labelling fixes for the defects in chapter 4 — all
  frontend-only; the app-pack was NOT touched (no API
  change was needed: the home payload already carries
  the company). FIXES: **(1)** company switcher BOUND
  from the HOME payload — `index.html` gained the
  bindable span `<span id="workspace-company">` and
  `src/app.js` the exported `setWorkspaceCompany()`,
  called in `renderHome()`'s live branch (tenant-
  generic; overwrites only on a non-empty string; the
  placeholder seed remains for stub mode); **(2)**
  `.role-switcher[hidden]{display:none!important}` in
  `src/app.css`, mirroring the SAMPLE-banner rule;
  **(3)** currency-aware `fmtMoney(n, currency)` +
  exported `currencyPrefix()` — PKR → "Rs ", USD → "$",
  EUR → "€", GBP → "£", unmapped → uppercased code +
  space, none/empty → "$" (the pre-fix default, so
  fixture renders stay byte-identical); all six
  `fmtMoney` call sites in `homeHtml` now pass the
  payload's currency; `fmtRs` (Sales document forms, a
  separate formatter) deliberately untouched. GATE
  GREEN: packaged build `v-040754904e6d`; frontend
  harness §19 → **434 PASS / 0 FAIL, mutation-checked**
  (removing the binding call fails exactly the switcher
  pin; removing the CSS rule fails exactly the CSS pin;
  reverting fmtMoney fails exactly the 5 currency
  pins); `verify_image` **20 PASS lines** with a NEW
  oc19 gate block **tested BOTH ways** (the oc18 build
  FAILS all six oc19 assertions; the oc19 build PASSES
  all six); in-image suites at Stage-0 counts (api 83 /
  integrations 46 / access 13 / saas 136). PROOF:
  **HEADLINE 9/9 PASS — the SERVED build's own
  `renderHome()` was EXECUTED against real Rektrs
  payloads** (served shell + served build tree + live
  bridge/home payloads captured with a Tenant-Admin
  session on Rektrs): the switcher renders **"rektrs"**
  (seed was "Al-Noor Traders"), home money renders
  **"Rs 0"** with NO "$" amounts, the role switcher is
  hidden, and the SAMPLE banner clears with provenance
  "live" (payload: company "rektrs", currency "PKR",
  isSample false). Batteries: corrected regression
  32/32 (main battery 168/176 — the 8 known GAP-04
  aging `isSample` artefacts, values exact); drafts
  104/104; rek-shell 8/8; rek-bytes 10/10 (served
  config.js / api-client.js / app.js sha-match the
  packaged manifest on Rektrs AND w19proof); CSRF —
  corrected SM round ALL PASS (the in-runner 16/18's 2
  "fails" are the known SM expectation artefacts; a
  later standalone re-run's Rektrs login fail is the
  proof user already disabled by then, by design);
  print PASS (explicit "Operqon Invoice" 29,679 B;
  default 25,279 B; bogus 417; Stock User 403); outbox
  inert PASS; entry paths PASS; guest battery PASS on
  both sites; seed truth identical to oc18 (TB
  22,907,000 = 22,907,000; BS assets 808,000; Bank-GPC
  dr 635,000 / cr 97,000). NO Rektrs migrate (no
  schema/DocPerm change ships). **FIRSTRUN LIVE FLIP
  REFUSED — DECIDED, NOT SHIPPED:** the server branch
  is CORRECT (bench battery 15/15 PASS: Tenant Admin 5
  steps with company done; Sales User sees exactly
  `first_customer` + `first_invoice`; Read Only
  `{show:false, reason:"role"}` + dismiss refused 417;
  TA dismiss persists; done site all-5-done with
  `completed_on`) — BUT the frontend contract does not
  match: the server steps carry `title` + Desk-vocab
  routes (`new:Customer`, `list:Company`), while the
  SPA card (`firstRunCardHtml`) reads `s.label` and uses
  `s.route` as a hash href, and `admin.js`'s live branch
  returns the payload UNMAPPED. Render proof with the
  real payload through the real card code: every step
  label renders as the literal text **`undefined`** and
  open-step hrefs are `href="new:Customer"` — flipping
  `adminSource` would ship exactly that to every tenant
  admin. **adminSource therefore stays `"fixture"` in
  oc19, asserted inside the image gate itself**
  (verify_image pins `adminSource: "fixture"` in the
  shipped config). NAMED FOLLOW-UP (next cycle): map
  the payload in `admin.js`'s live branch (title→label;
  translate Desk routes to SPA routes or drop the
  href) + harness pins executing the live branch
  against a recorded `get_first_run_state` payload,
  then flip. Process note from the lane: two duplicate
  firstrun-battery runs happened because "failed" SSH
  launches had actually executed server-side (egress
  responses lost) — battery2 (04:12 UTC) is the
  authoritative ALL-PASS run. ROLLBACK: oc18 image
  retained on-box (sha256 `8c41ce43…`) + compose backup
  `/opt/operqon-r2-staging-bench/compose.yaml.pre-oc19-20261110`.
  Provider marker UNCHANGED before, after, and on final
  re-read: `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`.
  Rektrs pong + login 200; R1/R2 readyz 200. **CLAIM
  CEILING: everything above is HTTP / served-bytes /
  DOM-execution proof. The ONLY unproven step of the
  whole login chapter is the owner's visual
  confirmation — re-opening the tenant site on his own
  phone and seeing company "rektrs", Rs amounts, and no
  stub elements. Do not call the chapter fully closed
  until he has seen it.** oc11 remains a labelled
  FAILED-GATE artefact — never deploy it. [oc19 lane →
  coordinator]
- 2026-11-10 — **CURRENT STATE + OPEN ITEMS AT THIS
  SYNC (supersedes the POST-oc14 IN FLIGHT entry above;
  this sync closes the oc15–oc19 handover gap — the
  document was last synced at the oc14 milestone).**
  CURRENT LIVE STATE: the tenant pairing image on the
  staging bench is **oc19** (sha256 `e18b867a…`, build
  v-040754904e6d), 50 sites; the provider release marker
  is **UNCHANGED at
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`** — no
  provider release has shipped since the console-
  modernization release, and production provider lines
  were never touched by any oc13–oc19 cycle. Rektrs
  (tenant `rektrs-private-limited`) is ACTIVE, migrated
  under oc16, and pong-verified through every swap; its
  company data is genuinely empty (zeros on screen are
  real). demo2 is still `requested` / untouched — the
  run pack is ready (`hidden_files/demo2-run-pack.md`;
  the owner's 6 steps incl. the Rs 19,999 real transfer)
  and it runs ONLY on the owner's word. OPEN ITEMS,
  honestly open: (1) **the owner's phone visual
  confirmation of oc19** — the only unproven step of
  the login chapter (asked 2026-11-10 ~10:15 PKT).
  (2) **Firstrun live flip** — payload title/label
  mapping + route translation + harness pins (see the
  oc19 entry); a mapping lane (build + bench proof
  only) is IN PROGRESS; `adminSource` stays "fixture"
  until it lands and a later cycle flips it. (3) **The
  full on-page audit** (the owner's standing order,
  2026-11-09: every screen / link / feature checked one
  by one — LIVE-REAL / SAMPLE / BROKEN with on-page
  evidence — then fix lanes) has NOT yet run; it starts
  once the owner confirms the oc19 landing visually.
  (4) **S8 dark theme** — blocked on the vendor full
  kit; the owner buys the commercial rights + full kit
  DIRECTLY from DreamsTech himself (do not pursue the
  ThemeForest route). (5) **Console + portal designs**
  — owner-supplied separately, NOT yet received.
  (6) **Alert webhook URL still EMPTY** (console
  Notifications card, operqon-owner login) — after the
  owner pastes it, run `/usr/local/sbin/operqon-webhook-sync`
  once; this is also the only remainder of ENG-112's
  alerting half, and creating the one healthchecks.io
  check for the provider backup is owner-side.
  (7) **W2 remainder** per the ENG mapping: ENG-090
  status-query step + replay UI; ENG-091 STGO fiscal
  correction (72-hour window); ENG-095 offline/POS
  policy; ENG-085 Pakistan country profile; ENG-096
  release gate; ENG-061–072 pack platform; ENG-086
  sandbox (owner-gated: licensed-integrator route).
  (8) **The >5,000-document item**: GAP list/home reads
  share a documented 5,000-row fetch cap that silently
  drops the oldest documents from totals at volume —
  server-side aggregates are the remedy; a coordinator
  item, NOT an owner decision right now. (9) **Bench
  RQ note** (see the oc18 entry): no worker by design;
  the default queue will re-cross the pin limit without
  a worker or a periodic purge. (10) Smaller named
  items: the oc18 shell-comment reword (scraper hazard);
  draft-default parity for the REST-served lists
  (Quotations / Orders / Delivery Notes / Purchase
  Receipts / Suppliers) if the coordinator elects it;
  the billing-role `/tenant-queue` 403 (console
  invoice-create tenant picker degrades to a typed
  input for billing); fixture cleanup (owner-endorsed;
  the hash-chained audit trail must stay valid); POS
  Role records absent on a fresh install (open pack
  question from the bench re-proof); GAP-06 register
  switch (a product decision — Desk POS stays the
  register of record until then); Figma Flow 3 (Home
  chart draw-in — a Figma-desktop manual step, not
  reachable via the connector); the blueprint's three
  recorded defects (W5 has NO ENG items; Saudi/ZATCA in
  W3's definition but no backlog items; W4 promises GCC
  expansion but its items are enterprise controls only)
  — a blueprint amendment proposal is owed when W3/W4
  arrive; nothing is invented meanwhile. [coordinator]
- 2026-11-10 — **DEMO2 RUN COMPLETE — the second real
  tenant end-to-end, on the S9 SELF-SERVICE path (run
  pack `hidden_files/demo2-run-pack.md`; evidence pack
  `hidden_files/demo2-evidence.md`).** The owner ran
  his 6 run-pack steps himself; the coordinator
  verified end-to-end from live provider DB reads,
  bench commands and HTTP probes the same day.
  TENANT: `714b7600-4511-4a1a-8f77-aaefa50084eb`
  (slug demo2) — status **active** (version 4), plan
  `enterprise`, created_by `public-intake`.
  SUBSCRIPTION `6f2b8393-8b2e-4ed0-8ffb-2242b35dc1a7`:
  state **active**, plan enterprise, created_by
  `customer:20735533f4c389f93afa9dd0be5c3523`
  (self-service), created 12:27:20 PKT, period
  2026-11-10 → 2026-12-10. INVOICE
  `OPQ-202611-D18B2D26`: **1,999,900 minor / PKR
  exactly**, period_days 30, status **paid**, channel
  `offline`, priced from the approved PK v1 proposal
  `c4ed372c-84a6-4459-a8da-54c6b0e4fae2`, issued
  12:27:20, due 2026-11-24 (start + 14 days),
  paid_at 12:28:47, payment_reference
  `offline:Tx-10546465165`. SETTLEMENT: notice
  `5f95cb6b…` (reference `Tx-10546465165`, submitted
  12:27:29) **verified**; offline approval
  `ab572caf…` at 12:28:47 (after the notice),
  statement_sha256 **NULL** — optional since F-RIDE;
  **SoD clean** (approver ∉ {invoice.created_by,
  tenant.created_by}). PROVISIONING: job
  `24879fca-6855-440d-bced-bb1696dcfc02`
  **published**, requested_by = approved_by =
  `operqon-payment-automation`, attempts **1**, no
  failure code, created 12:28:47, published 12:32:12
  (settle → publish ≈ 3 min 25 s). MANIFEST: site
  `demo2.stage.operqon.cloud`, site_status published,
  apps `[erpnext, operqon_core]`, sso_configured true
  (client `operqon-erp-demo2`), support_configured
  true, setup_masters_configured true, country PK,
  currency PKR, fiscal year 2026-2027, company
  configured as `demo2`; site_users = exactly one
  (Asad Ahmad <iatharabbas@gmail.com>). BATTERY:
  provider records exact; site pong
  `{"message":"pong"}` HTTP 200; bench list-apps
  independently shows frappe 16.55.1 / erpnext
  16.53.0 / **operqon_core 0.0.1**; guest battery
  PASS (/login 200, no setup-wizard redirect,
  "Login with Operqon" present, authorize href
  carries `response_type=code`, all 9 login-page
  asset URLs 200 with correct content types);
  Company count = 1 ("demo2"), Global Defaults
  default_company `demo2` / default_currency `PKR`;
  audit trail — 14 demo2 events tell the whole run;
  chain **1,020 events**, only the genesis event
  unmatched, audit_head.last_hash == latest event
  hash — chain intact; identity_reviews for demo2 =
  **0**. NO stop condition triggered (state was
  `requested` at start; amount exact everywhere;
  bank instructions DB-first; SoD held; no identity
  gate appeared). Provider marker UNCHANGED:
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`;
  provisioner timer active. STILL OWED on demo2:
  (a) the owner's **first SSO sign-in** (site_users
  roster = exactly him; expected roles Operqon
  Tenant Admin + System Manager); (b) portal visual
  read-back (underlying DB facts verified — invoice
  PAID with the offline reference, subscription
  active, tenant active → portal stage computes
  `live`; visual confirmation on his next sign-in).
  **W1 IS NOT CLOSED:** demo2 is the FIRST HALF of
  W1's closing gate — still owed: **Slice 10 /
  ENG-060** (Commerce UAT across sales / warehouse /
  cashier / accountant roles on one order lifecycle,
  the pilot-gate remainder, **accountant sign-off**
  — a named human, cannot be self-certified — and
  ACC-18). [coordinator]
- 2026-11-10 — **CURRENT STATE UPDATE AT THIS SYNC
  (supersedes the demo2 lines of the CURRENT STATE
  entry above; everything else there stands).**
  demo2 is ACTIVE and published (entry above) — it
  is no longer `requested` / untouched. The tenant
  pairing cycle **oc20 is IN FLIGHT** (NOT shipped):
  Stage 3 image gate PASSED, image sha256
  `39a39e94…`; the bench swap is still pending, and
  the oc20 milestone entry is written when the cycle
  completes — oc19 remains the pairing image of
  record until then. Provider marker UNCHANGED at
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`.
  [coordinator]
- 2026-11-10 — **oc20 SHIPPED — GOVERNED WRITES LIVE
  ON THE STAGING BENCH (tenant pairing cycle; full
  report
  `hidden_files/team-oc20-cycle.md`).** Image
  `operqon/erpnext-tenant:v16.53.0-oc20` = sha256
  `39a39e946c4f440029d099912a9cd50ef40c6743be2b73efca1bd2ffc8a020f3`
  (4.77 GB); frontend build **v-74224903692d**
  (exactly one build packaged). Bench swap
  2026-11-10 07:37:41 UTC; **51 sites at swap, 53 at
  close** (incl. the cycle's two proof sites
  w20proof + w20fresh). Provider marker UNCHANGED
  before/after:
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff` —
  tenant pairing cycle only; **no provider release,
  no production changes**. ROLLBACK (not needed):
  oc19 image (sha256 `e18b867a…`) + compose backup
  `/opt/operqon-r2-staging-bench/compose.yaml.pre-oc20-20261110`.
  WHAT SHIPPED: server write methods —
  `api/writes.py`, **11 methods, all POST-only
  whitelisted** (Customer, Supplier, Item create +
  update-by-name; Stock Entry; Sales Invoice; Sales
  Return; Purchase Order; Purchase Invoice; Payment
  Entry; Journal Entry; allowlisted submit), behind
  `api/writekit.py` (governed role/policy gate,
  server-side taxes) with **`Operqon Write Receipt`
  DocType** idempotency receipts; role matrix **36
  DocTypes / 210 entries**. Frontend: callWrite
  seam, Customer/Supplier create UI, create+submit
  flows, typed errors surfaced in-form, POS
  completion live-refusal; this cycle also wired
  **Material Transfer** (direction + per-line
  from/to payload, live validation) and
  fixture-gated **POS Devices** in both modes (by
  design). **FIRSTRUN FLIP SHIPPED**: packaging set
  all seven sources live incl. `adminSource` — the
  four oc19 blockers closed (fields quoting, Users
  surface, Employees matrix row, POS Devices
  fixture-gate). Fresh-install docperms pin
  corrected 195 → 210 (snapshot + canonical).
  IMAGE GATE PASSED: verify_image extended for oc20
  (both-ways tested — the oc19 snapshot fails all 5
  oc20 assertions); standalone **22 PASS** lines;
  in-image suites api **114** (gap 70 + writes 30 +
  session 14) / integrations 46 / access 13 / saas
  136, **0 failures**; snapshot harness **494 PASS
  / 0 FAIL**; ship tarball sha256 `a47f29ad…`.
  PROOF BATTERY — ALL LEGS PASS. (a) **First real
  invoice**: on w20proof, payloads generated by the
  shipped SPA's own builders, posted via the
  whitelisted methods over HTTP (the path the cycle
  brief expressly sanctions): customer + item
  created; Material Receipt **MAT-STE-2026-00006**
  (10 × Rs 100 into Main Warehouse); **Sales
  Invoice ACC-SINV-2026-00011** created +
  submitted — grand **Rs 1,000 PKR**, outstanding
  1,000; Material Transfer **MAT-STE-2026-00007**
  (3 units Main → Branch B) — the transfer wiring
  proven end-to-end; idempotent replay returned the
  same invoice (`idempotent_replay: true`, no
  duplicate); partial payment **ACC-PAY-2026-00007**
  Rs 400 → outstanding **600**. Reconciliation
  **7/7**: GL balanced **1200 = 1200** (Debtors /
  Sales 1,000 + COGS / Stock 200 — the invoice
  posts stock); Bin Main **5** / Branch B **3**;
  SLE net **+8**; exactly **6** Write Receipts.
  (b) **Rektrs regression PASS** (guest login 200,
  8/8 assets, "Login with Operqon", no wizard
  redirect, bridge / pong / manifest PASS;
  proof20 168/176 — only the 8 known AGING
  isSample artefacts, values proven by the
  corrected battery 32/32; draft20 104/104;
  converge 7/7). Rektrs migrated (Write Receipt
  DocType installed; companies `['rektrs']`
  intact): DocPerm census **205 governed-role
  rows, set-identical to a fresh oc20 install
  (0 diff both ways)** — the matrix's 210 entries
  include 5 rows for roles outside the census
  (System Manager ×4, POS User ×1). (c) **Served
  bytes PASS**: config / api-client / app sha ==
  packaged manifest on Rektrs AND w20proof; the
  served build's own `renderHome()` renders
  switcher "rektrs", "Rs 0", role switcher hidden,
  banner live. (d) **Typed refusals PASS**: overpay
  → 417 OPERQON_WRITE:VALIDATION; Read Only write
  → 403 OPERQON_WRITE:PERMISSION_DENIED.
  (e) **Firstrun on the flipped admin source
  PASS**: HTTP battery on w20fresh (Tenant Admin
  5 steps, Sales exactly 2, Read Only show:false +
  dismiss refused 417, TA dismiss persists) +
  served-build render (real titles, SPA routes,
  no "undefined"). FINDINGS (both assigned to
  oc21; neither blocks the shipment):
  **F-OC20-1** — branch-scoped writes REQUIRE the
  `cost_center` argument (`policy.decide` →
  BRANCH_REQUIRED, surfaced as typed 403
  OPERQON_WRITE:COMPANY_OUT_OF_SCOPE); **the
  shipped SPA sends no cost_center in any write
  payload** — its transactional doc models carry
  no branch concept at all — so the SPA's own live
  path cannot complete a branch-scoped write until
  the frontend learns branch selection (same
  family: `buildPaymentEntryPayload` omits the
  `reference_no` / `reference_date` that Bank-mode
  payments require → typed 417). The server
  contract is fully proven over HTTP (battery
  above). **F-OC20-2** — stock-entry idempotency
  keys are keyed on per-screen fixture names and
  can collide across screens; the server refuses
  safely (typed 417 DUPLICATE_IDEMPOTENCY_KEY);
  fix = include the purpose in the key. STATUS
  HONESTY: writes are live on the **staging bench
  pairing only**; the provider release and
  production are unchanged (marker above). **W1
  IS NOT CLOSED by oc20** — Slice 10 / ENG-060
  remains (see the CURRENT STATE UPDATE below).
  [coordinator]
- 2026-11-10 — **CURRENT STATE UPDATE AT THIS SYNC
  (supersedes the oc20 IN FLIGHT lines of the
  previous CURRENT STATE UPDATE, the pairing-image
  lines of the older CURRENT STATE entry's CURRENT
  LIVE STATE paragraph, and its item (2) Firstrun
  live flip; everything else in those entries
  stands).** The tenant pairing image of record on
  the staging bench is now **oc20** (entry above):
  governed writes live there, and the firstrun
  flip is shipped and proven. **CONSOLIDATION**:
  the build order after the 20-lane fan-out + 8
  build teams is written
  (`hidden_files/consolidation-build-order.md`) and
  sequences **oc21 → oc25+**: **oc21 is DISPATCHED**
  (F-OC20-1 fix → M3 merge → aggregates); the
  **P-1 provider release carries the F-1 fix
  first** (support-sessions role gate); the
  **docker gate for the Portal / Console merges is
  still owed and must run on a Docker-capable
  host** (no docker on this VM — the venv evidence
  does not count as the gate). **SLICE 10**: the
  run pack is written
  (`hidden_files/slice10-run-pack.md`) — scripted
  Commerce UAT + close / reconciliation pack +
  accountant sign-off sheet; execution waits on
  the **D-1 decision (the pilot gate's third
  business), still open with the owner**, and the
  named accountant slot. **ACC-18 has NO build**
  — no ENG item, no governed method or screen;
  the gap is recorded in the run pack. Provider
  marker UNCHANGED at
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`.
  [coordinator]
- 2026-11-10 — **oc21 SHIPPED — THE SPA ACTUALLY
  WORKS + M3 TRANSACTIONAL SURFACE (tenant pairing
  cycle; full report
  `hidden_files/team-oc21-cycle.md`).** Image
  `operqon/erpnext-tenant:v16.53.0-oc21` = sha256
  `9de23e90bd298c27c498dffc4b411e28be692a580454e186fba83548a10ead39`;
  frontend build **v-2efe04cb5215** (exactly one
  build; 21 assets). The image was built twice
  under the oc21 tag: the first build `2638418b…`
  was superseded by `9de23e90…` after the
  F-OC21-2 fix below; the frontend build was NOT
  re-run (same v-2efe04cb5215 inside both). Bench
  swap on the staging bench; **54 sites at close**
  (58 sites-dir entries incl. the new w21proof;
  53 at cycle start). Provider marker UNCHANGED
  before/after:
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff` —
  tenant pairing cycle only; **no provider
  release, no production changes**. ROLLBACK (not
  needed): oc20 image (sha256 `39a39e94…`) +
  compose backup
  `/opt/operqon-r2-staging-bench/compose.yaml.pre-oc21-20261110`.
  WHAT SHIPPED: (1) **F-OC20-1 + F-OC20-2 frontend
  fix** (canonical own-frontend) — Branch (Cost
  Center) select in the sales / buying / stock /
  payment / journal forms fed by `getBranches`;
  every write builder emits `cost_center`
  (Journal Entry rows carry row-or-doc branch;
  Sales Return deliberately none — the server
  resolves); Payment emits `reference_no` +
  `reference_date` (defaults to posting date);
  live validators refuse branch-less creates
  in-form (create-only carve-out for the GAP-12
  envelope); stock-entry idempotency key =
  `spa:Stock Entry:<purpose>:<name>`; harness
  **511 PASS / 0 FAIL**, mutation-checked.
  (2) **M3 merge** (scratch-m3 → canonical
  app-pack, never whole-tree): role matrix
  one-commit; writekit adopted (exactly **one**
  `.cancel(` call site package-wide — verified in
  the shipped image); `SUBMITTABLE_DOCTYPES` 12
  by tuple append (lifecycle reads it by
  reference); 7 modules (quotation, sales_order,
  delivery, lifecycle, stock_count, stock_trace,
  bankrec); `get_stock_trace`'s typed read error
  reverted to the plain read-side shape
  (coordinator decision); Branch Manager
  **amend** grants ratified into the matrix;
  final matrix **264 rows / 44 DocTypes** (incl.
  the bench-driven trace read rows below).
  (3) **Aggregates merge**: `common.paged_get_list`
  + home.py paged adoption + `capped` marker
  (only on truncation) + canonical test-fake
  extension in the same change; GAP-02 / GAP-14
  residuals untouched (oc24). STAGE 4 BENCH PROOF
  BEFORE PACKAGING (hard gate, isolated
  gap-proof stack) — **m3 58 PASS / 0 FAIL ·
  agg 11/11 · volagg 8/8** on the real framework:
  SO→DN→SI chain end-to-end (SO per_delivered
  0→100, SI GL exact) = `save_sales_order`
  FMCG-unblock evidence; governed Stock
  Reconciliation posts with ENG-045 variance
  fields; cancel GL-nets zero; **BM amend
  succeeds post-ratification** (amended_from
  set); PI amend carries bill_no verbatim;
  **D3 answered — no in-cycle tightening** (DN
  beyond *remaining* refused by the framework,
  OverAllowanceError, Bin unchanged; beyond
  *ordered* refused by the governed module,
  typed VALIDATION); bank rec full pass (Payment
  Entry in Bank mode with the reference pair
  persisted, Bank Transaction on the real account
  name, human-confirmed pair reconciled —
  allocated 2000 / unallocated 0 / Reconciled);
  aggregates §7 complete (volume SI 5,007 / GL
  5,008 / Items 5,004; paged fetch zero-overlap
  zero-skip, 5,007 = 5,007 = 5,007; KPIs exact at
  volume; timing 0.556 s @5k, 1.754 s @25k with
  sales exact Rs 25,007,000; `capped` fires under
  a lowered ceiling, absent at 5k; Lahore BM
  total exactly 700 pre-volume and 0.0 at volume
  — branch isolation holds at scale); teardown
  clean (gap-proof stack removed; staging sites
  unchanged; marker unchanged). IMAGE GATE
  PASSED: snapshot mode-normalised 0644 (0
  exceptions); snapshot harness PASS (511 + oc21
  §6a0 all-seven-live); verify_image extended
  for oc21 (both-ways tested — oc21 tree full
  PASS, oc20 tree fails at the oc21 pin; mutation
  fails closed); the build itself is the gate:
  **BUILD_RC=0** with all verifier lines inside
  the build; standalone verifier re-run in-image
  **27 PASS lines, 0 fail**; in-image suites
  (unittest — the image carries no pytest): gap
  70, writes 30, volume 13, session 14, access
  13, M3 187, workspaces — **all OK**. PROOF
  BATTERY (Stage 6, driver over real sessions) —
  **24 PASS / 0 FAIL**: Rektrs regression (guest
  login 200, "Login with Operqon", 8 unique login
  assets 200, /operqon 301 → login with no
  wizard, guest bridge 403, pong); **served-bytes
  identity on BOTH sites (21/21 files sha ==
  manifest)**; Read Only save refused (403
  through the served client); overpay refused
  in-form by the served client **and** 417
  `OPERQON_WRITE:VALIDATION: amount 201.0 exceeds
  the outstanding 200.0` from the server (payload
  generated by the served builder); M3 smoke over
  HTTP (SAL-ORD-2026-00001 → MAT-DN-2026-00001 →
  ACC-SINV-2026-00002, SO per_delivered 100);
  firstrun state (company_confirmed done=true)
  on the fresh site **w21proof.stage.operqon.cloud**,
  created and provisioned through the app's own
  firstrun bootstrap (company "W21 Proof Co"
  created end-to-end by `apply_tenant_company` —
  the firstrun machinery proven). **HEADLINE
  PROOF (the cycle's point)**: a **branch-scoped
  Branch Manager** (grant: Main - WPC subtree
  only) completed a real Sales Invoice **through
  the served SPA's own live path** on w21proof —
  the served build `v-2efe04cb5215`'s own
  modules, fetched from the live site and
  executed against it with the BM's real session:
  served `getBranches` returned the branch list;
  served `salesFormHtml` rendered the Branch
  (Cost Center) `<select data-doc-branch>` with
  Main - WPC / Branch B - WPC options; saving
  branch-less was refused **in-form** — "Branch
  (cost center) is required." — before any wire
  call (F-OC20-1's in-form gate); with the branch
  set exactly as the form's change wiring sets
  it, served `saveSalesDoc` created
  **ACC-SINV-2026-00001, docstatus 1, grand total
  Rs 200**; bench reconciliation: GL balanced
  **400 = 400** over 4 rows (Debtors / Sales 200
  + COGS / Stock 200); invoice outstanding 200;
  stock fully accounted (Bin 0 = SLE net 0 over
  4 rows: +10 receipt − 2 headline − 4 DN − 4 M3
  SI). **F-OC20-1 and F-OC20-2 are CLOSED** —
  branch selection + `cost_center` on every write
  builder + Bank reference pair + purpose-keyed
  stock idempotency, all proven live, not just
  pinned. FINDINGS (fixed in-cycle unless
  noted): **F-OC21-1 — branch axis vs
  column-less DocTypes**: Quotation's matrix row
  declares `branch_field: "cost_center"`, but
  the DocType has no such column (branch is a
  create-time gate *argument*, never persisted) —
  one root, three symptoms:
  `enforcement.get_permission_query_conditions`
  emitted `` `tabQuotation`.`cost_center` ``
  (SQL 1054 for branch-granted list readers);
  `enforcement.has_permission` refused **every**
  governed Quotation insert (BRANCH_REQUIRED);
  `writekit.check_governed` refused every
  doc-derived command (submit / cancel / amend)
  with COMPANY_OUT_OF_SCOPE. Fix: a schema-aware
  guard (`enforcement._branch_column_exists`)
  neutralises the branch axis in all three
  places **only** when the doc/argument carries
  no branch and the schema lacks the column; a
  *provided* branch argument is still judged
  (proven live: Lahore BM quoting on Main refused
  by the gate, on Lahore succeeds). Honest
  consequence: branch-restricted Quotation
  *reads* are not implementable without a
  persisted branch — reads are company-scoped,
  recorded as bench evidence. **F-OC21-2 —
  installer convergence** (fixed,
  `access.enforcement.install_policy`): the
  docstring promised "re-running converges", but
  the code skipped existing Custom DocPerm rows
  entirely — so the BM-amend flag change never
  reached migrated sites while fresh installs
  got it (Rektrs amend=0 vs w21proof amend=1 on
  exactly SI / PI / PE / PO / Stock Entry ×
  Branch Manager — the first
  flag-change-on-existing-row in the matrix's
  history, which is why it never bit before).
  install_policy now converges flag fields on
  existing rows (summary gains `updated`); after
  the fix + re-migrate, Rektrs vs w21proof
  Custom DocPerm signature sets are **260 rows
  each, sets IDENTICAL**. **Trace read rows**
  (matrix amendment, bench-driven):
  `get_stock_trace` reads Stock Ledger Entry /
  Serial No / Batch / Serial and Batch Bundle
  permission-checked; none had a matrix row, so
  every governed caller was refused — read-only
  rows for all seven governed roles added (GL
  Entry / Bin precedent; company-scoping per live
  meta — Batch deliberately unscoped, no company
  column); matrix 236 → **264 rows / 44
  DocTypes**; proven live (batch + serial traces
  answer with real movements). **Clearance date
  — lane question answered**: a governed Bank
  Transaction save does **not** propagate
  `clearance_date` to the Payment Entry on this
  pin (the framework sets it only via its own
  Bank Reconciliation Tool flow); bankrec's
  docstring corrected to the truth; the BT
  remains the reconciliation record of truth
  (candidate follow-up, out of scope here: a
  governed clearance-date update would need a
  writekit update-path composition). **Minor
  wart (noted, not blocking)**: the SPA branch
  select offers *all* Cost Centers from
  `getBranches`, incl. the company root group;
  group cost centers are refused server-side in
  transactions, so a wrong pick fails safe with a
  typed refusal (a frontend follow-up could
  filter to leaves). STATUS HONESTY: oc21 is
  live on the **staging bench pairing only**;
  the provider release and production are
  unchanged (marker above). **W1 IS NOT CLOSED
  by oc21** — Slice 10 / ENG-060 remains (see
  the CURRENT STATE UPDATE below).
  [coordinator]
- 2026-11-10 — **CURRENT STATE UPDATE AT THIS SYNC
  (supersedes the "oc21 is DISPATCHED" line of
  the previous CURRENT STATE UPDATE, the demo2
  entry's two STILL OWED lines, the previous
  CURRENT STATE UPDATE's Slice 10 lines — the
  "D-1 decision, still open with the owner" and
  the "ACC-18 has NO build" — and its "docker
  gate still owed" line; everything else in
  those entries stands).** The tenant pairing
  image of record on the staging bench is now
  **oc21** (entry above): the SPA's own live path
  completes branch-scoped writes (F-OC20-1 /
  F-OC20-2 closed), the M3 transactional surface
  and the paged aggregates are merged, and the
  firstrun machinery provisioned a fresh site
  end-to-end (w21proof). **DEMO2 IS FULLY
  CLOSED** — the owner confirmed his first SSO
  sign-in on demo2 (2026-11-10 ~14:16 PKT); the
  demo2 entry's two STILL OWED lines (first SSO
  sign-in; portal visual read-back) are
  discharged — nothing remains owed on demo2.
  **SLICE 10**: **D-1 is DECIDED** — the pilot
  gate's third business is a **third controlled
  pilot tenant (pilot3)** (Rektrs = leg 1, demo2
  = leg 2, pilot3 = leg 3), chosen by the owner
  on the coordinator's recommendation; the
  **accountant slot is FILLED — Asad Choudhary
  (the owner)** (PC-10 closed). **pilot3 run:
  GO given by the owner (~14:16 PKT); pre-flight
  GREEN 16/16; the run is IN FLIGHT at its first
  owner step** — the first relayed O1 link
  pointed at the wrong half of the flow (the
  portal `?signup=1` door has NO intake form;
  the diagnosis proved **zero pilot3 records
  exist** — the intake was never submitted;
  coordinator error, owned and corrected: the
  intake is the standalone public form
  `operqon.cloud/request-access.html` FIRST,
  then `?signup=1` with the SAME email — the
  link step binds by email, and the intake email
  must be FRESH, the Rektrs / demo2 admin emails
  being bound already); the corrected O1 is with
  the owner, and a fork is open with him: (a)
  pilot3 runs today on the current form
  (coordinator recommendation) or (b) pilot3
  becomes the new simple flow's first live test
  (SIMPLE-SIGNUP PROGRAMME below). **ACC-18**:
  the build brief is DELIVERED
  (`hidden_files/acc18-build-brief.md`, 466
  lines, prep only — nothing built): ONE new
  DocType **Operqon Service Change Request**
  (non-submittable, company+branch-scoped;
  status and decided_* read_only — Desk can
  display the trail but never decide) + ONE
  module `api/services.py` with 3 governed
  methods through `writekit.run_command`
  (`save_change_request` forces Draft;
  `decide_change_request` — self-approval
  refused PERMISSION_DENIED, approve without an
  evidence reference refused VALIDATION;
  `get_billable_scope` — Approved CRs only,
  naming a non-approved CR refuses typed); ~15
  DocPerm rows; technician seat = Stock User (no
  role minted), decider = Tenant Admin / Branch
  Manager; **no SPA surface** (the mini-chain
  runs Desk + HTTP; a services screen is ENG-100
  / W3 scope); proposed **ENG-225 · W1**
  (ENG-223 / 224 stay reserved for sa_zatca);
  estimate ≈ **2–2.5 lane-days** — **builds in
  the oc22 window, lands in oc24** after an
  isolated gap-proof bench battery (9 legs).
  Consequence: the Slice 10 commerce UAT can run
  post-oc21 (Variant B — fully governed on the
  oc21 image), but the ACC-18 mini-chain leg —
  and therefore the sign-off — completes **after
  oc24**. **ON-PAGE AUDIT: paperwork CLOSED**
  (`hidden_files/onpage-audit/results.md`,
  131/131 checks): the browser pass returned 2
  LIVE-REAL (D-02 guest /operqon redirect, D-03
  pong), 2 BROKEN (D-01 / D-05 — a **proof-site
  artefact, NOT a product defect**: w20proof was
  battery-created and never provisioned, so no
  Social Login Key exists there and
  `apply_sso_configuration` never ran on it;
  Rektrs + demo2 both carry the button — D-01 /
  D-05 are scored N/A-creation-path on
  battery-created sites from now on), and 127
  BLOCKED-ON-SIGNIN (the TA sign-in could not
  complete — the audit password cannot travel
  through chat; the door itself was prep-proven,
  HTTP login 200 ×3); server-side coverage
  mapping of the 127: **16 COVERED-BY-EVIDENCE ·
  100 PARTIALLY-COVERED · 9 UNCOVERED** (+ 2
  persona containers whose verdicts live in
  their sub-checks); the residue rides a short
  re-pass on a PROVISIONED proof site once a
  credential channel exists that does not route
  the password through chat; one genuine
  contradiction stands recorded — **SA-06b**
  (the checklist expected the Sales Return in
  the F-OC20-1 family; oc21's fix deliberately
  sends returns with NO cost_center — decided by
  the oc21 return leg / the re-pass).
  **SIMPLE-SIGNUP PROGRAMME (owner directive
  2026-11-10 ~14:38 PKT — the Request Access
  system is REMOVED outright, not patched; the
  P-0.5 bind-or-route build lane was CLOSED on
  this directive, its analysis standing, its
  remedy superseded)**: the customer flow
  becomes **sign-up → verified email → payment →
  active**, like every SaaS. State: **SPEC
  DELIVERED** (`hidden_files/simple-signup-spec.md`,
  1,125 lines + 4 lane annexes) — one door (the
  portal) → Keycloak registration → native
  VERIFY_EMAIL required action (24 h Brevo link)
  → `GET /customer/session` by **subject only** →
  complete-signup creates the tenant + binding
  atomically (born bound + born verified);
  **zero provider rows exist before
  verification; NO DB migration**. Endpoint
  delta: DELETE 3 (`POST` + `GET
  /api/v1/public/tenant-requests`, `POST
  /api/v1/customer/link` — email matching dies)
  · CREATE 5 (`GET /api/v1/public/plans`
  byte-identical move, `GET /api/v1/customer/session`,
  `POST /api/v1/customer/signup` — schema
  extra="forbid", NO email field, sending one
  fails 422; 201 created / 200 idempotent
  first-write-wins, `POST
  /api/v1/customer/trial-start`, `POST
  /api/v1/customer/resend-verification`) ·
  CHANGE 3 (subscription-start + offer gain a
  `conversion` mode reusing the trial row;
  `customer_status`; dashboard payload gains
  additive `onboarding_path`) + the
  `customer_status` computation + the
  `app/security.py` verifier split (PV-01/02);
  trial = 3-day self-service from
  `Plan.trial_days` (PK v1 = 3, never
  hard-coded), NO approver on the customer path,
  conversion reusing the SAME subscription row
  (never a second tenant / slug / binding /
  site); migration census (SELECT-only): 44
  tenants (29 active · 8 requested · 4
  provisioning · 3 suspended), 39 identities,
  Rektrs + demo2 both active / bound / flags
  true, **zero real customers pre-active**;
  unbound legacy intakes stay operator-visible —
  never claimable, never auto-deleted.
  **Coordinator RATIFIED on the spec: CR-1**
  (the daemon auto-publish gate gains the
  specced trial branch — `operqon-trial-automation`;
  path == trial + sub `trialing` + `ends_at >
  now` + verified flag; the worker needs no
  logic change; until it ships, trial sites are
  published via the existing operator door and
  trial copy says "being set up", never
  instant-live) **and CR-2** (settlement /
  `activate_after_payment` status set widened
  ONLY for the converted-trial shape — tenant
  `active` + the invoice's subscription is the
  converted trial row + `payment_verified_flag`
  still False — the mechanism for the owner's
  confirmed trial→paid build); the Keycloak
  per-action-lifespan fallback is NOT
  pre-approved (the battery assertion detects
  failure → back to the coordinator).
  **Portal (FE) build COMPLETE** (scratch tree
  `~/workspace/operqon-team/scratch-signup-fe/`
  only — nothing deployed, `customer/config.js`
  verified absent from the diff; **61/61 tests,
  axe 0 violations on all six pages**): one
  signup door (portal "Create account" →
  Keycloak registration); `request-access.html`
  retired to a 702 B redirect stub →
  `/customer/?signup=1`, its form and
  `assets/request-access.mjs` DELETED (killing
  the abandoned `operqon_signup_email`
  sessionStorage write with them); NEW
  verify-email screen (inbox from the account
  token, resend via the Keycloak VERIFY_EMAIL
  action, sign out) — the old "Securing your
  session / not linked to a request" card is
  DELETED with every state that rendered it; NEW
  company+plan step (email shown locked from the
  id_token — never an input, never sent; plans
  from the live public catalogue, PK only);
  dashboard `identity_review` stage entry
  deleted, the `requested` stage now reads
  "Account created"; the "request" vocabulary
  purge is grep-verified at ZERO hits across the
  customer FE + public fixtures (every surviving
  "request" occurrence eyeballed and listed as
  fenced / out-of-scope). The FE closed on
  Contract v1 (pre-spec) — its re-point to the
  landed spec contract is a NAMED composition
  step (isolated functions in auth.js /
  complete-signup.js; FE suites re-run after).
  **GATE-0 PAID**: the REAL Dockerfile.test
  docker gate finally ran on the current tree —
  **504 passed / 3 skipped in-image, provider
  marker unchanged** — discharging the
  docker-gate debt the previous CURRENT STATE
  UPDATE recorded as owed (the composed
  simple-signup tree gets the same gate at
  composition). **Acceptance battery Phases 0–8
  validated** (driver 1,680 lines; BLOCKED
  support — exit 0 requires 0 FAIL **and** 0
  BLOCKED; dry validation only, NO live run
  yet); the Release lead caught and fixed a
  live-fail bug in the battery itself (Phases
  5/6 queried audit metadata as `meta::text` —
  the column is `metadata_json`; it would have
  FAILED live under ON_ERROR_STOP=1).
  **Backend build in its FINAL lane** (Lane D:
  pin updates + full-suite verification): Lanes
  A2 (spec core rework; tests 27/27), B (door
  retired + trial-start + V-1 email-release;
  22/22), B2 (trial→paid conversion +
  customer_status; 16/16), R (resend-verification
  + Keycloak Admin client; 17/17) and P (CR-1
  publish gate + CR-2 settlement widening;
  11/11) are COMPLETE in the scratch tree
  (`~/workspace/operqon-team/scratch-signup-be/`;
  canonical untouched); the lead's final report
  (`hidden_files/team-simple-signup-be.md`) is
  **THE composition gate** — composition then
  runs per the plan (merge order BE → FE → tests
  → MANIFEST last; FE re-point; deploy-script
  list fixes for the deleted .mjs; the
  well-known advertisement rename to
  `public_plans_path` + stage "simple-signup"
  DECIDED, with its Caddy / apply / acceptance
  dependents in the same pass), then all suites
  + the docker gate on the COMPOSED tree + the
  battery on staging → deploy-readiness report.
  **DEPLOY IS GATED on the coordinator's signal
  AND pilot3 publishing — nothing has deployed.**
  **V-1 RULED (coordinator, 2026-11-10 ~14:57
  PKT)**: the live unique index
  `uq_tenants_admin_email_lower` EXISTS
  (verified read-only via `pg_indexes`) and
  **STAYS permanently** — the spec's F2 ("two
  subjects, same email → two tenants") is
  permanently withdrawn; **policy = ONE EMAIL =
  ONE TENANT** (live behaviour today — the old
  intake refused duplicate emails with 409 — so
  keeping it is a non-regression;
  multi-tenant-per-email is an unrequested new
  capability, NOT in this release); the spec's
  "no migration" headline is PRESERVED. The
  sharp edge is closed by a bounded build,
  LANDED in the backend Lane B: **operator
  email-release on reject** (when an operator
  rejects an UNBOUND requested intake — no
  CustomerIdentity AND no Subscription —
  `admin_email` is renamed to
  `released-<tenant_id>@released.invalid` and a
  separate audit `tenant_email_released` is
  appended; a bound or active tenant's email is
  NEVER releasable) + an **application-level
  duplicate-email guard** in `POST
  /customer/signup` (after the idempotency step:
  another subject's tenant holding the claim
  email → 409 "Conflict with an existing provider
  record"; confirmed on disk by the BE lead's own
  read, test-covered) — Battery Phase 8's
  pre-release 409 therefore rests on BOTH the
  guard and the live index, and Phase 8 itself
  is verified (rejected-intake email reusable
  afterwards; the ACTIVE tenant's reject REFUSED,
  tenant byte-identical). Phase 8's staging
  source is DECIDED: operator-staged create (no
  pre-existing legacy row required). **B2
  MIRROR PREP COMPLETE**
  (`hidden_files/team-b2-mirror-prep-20261110.md`):
  a second backup copy (Backblaze B2) prepared
  additive-only on the VPS — rclone installed;
  mirror script `/usr/local/sbin/erp-saas-b2-mirror`
  (append-only `rclone copy` of the restic repo
  at `erp-saas-backups/pilot` — the repo is NOT
  at the bucket root — with snapshot-count
  equality + `restic check` as the proof) +
  activate script `/usr/local/sbin/erp-saas-b2-activate`
  written, NOT run; systemd service + timer
  installed but **DISABLED** (daily 04:15 UTC
  once enabled); fail-closed test PASS
  (`B2_NOT_CONFIGURED`, exit 2, nothing
  touched); zero-change proof — all existing
  backup scripts + `r2.env` sha256-identical
  before/after, existing legs' timers untouched.
  **Activation waits on the owner (owner-only,
  ~2 min, non-blocking): create a Backblaze B2
  account + a private bucket + an application
  key**; the values go into
  `/etc/erp-saas-backup/b2.env` on the VPS, then
  the activate script runs the first mirror +
  proof. **OWNER DECISIONS 2026-11-10 ~14:16 PKT
  (all six answered)**: (1) **pilot3 run: GO**
  (above); (2) **the alert webhook URL +
  healthchecks.io check are DEFERRED BY OWNER
  DECISION until the complete website build is
  done** — ENG-112's alerting remainder + the
  observability switch-on stay parked BY
  DECISION (stop surfacing them as pending
  nags); (3) **demo2 first SSO sign-in: DONE**
  (above — demo2 fully closed); (4) **the three
  backup keys into the owner's own secure
  store** — acknowledged by the owner ("will
  save them"), remains his, no nagging; (5)
  **coordinator recommendations CONFIRMED —
  apply them**: **trial→paid conversion =
  BUILD** (P-2; its mechanism is the CR-2 build
  above), **Portal Q-4 = option (b)** (fix the
  billing-email binding to the identity record —
  its own P-2 change), **second-engine adoption
  = DEFER to M6 planning** — all three CLOSED as
  decisions; (6) **long-term items HELD PENDING
  BY OWNER DECISION**: the DreamsTech direct
  purchase, the console + portal designs (the
  owner supplies), the ENG-086 sandbox, and the
  template-hunt purchases. **CONSOLIDATION
  SEQUENCE (unchanged)**: oc22 next (W2 platform
  + packs land; Shell server methods build
  starts; ACC-18 builds), oc23 (A11y + Shell +
  Brand land; exports E-6/E-7), **P-1 provider
  release carries the F-1 fix first** (then
  billing-queue fix, Portal, Console as one
  composed tree), oc24 (shell surfaces go live;
  ACC-18 lands), P-2, oc25+ (M5 → M6 → M7;
  sa_zatca minted as ENG-223 at W3 start).
  Provider marker UNCHANGED at
  `6bd1cbe160742063f7df4d42e4d0d4c557bd4cff`.
  [coordinator]
- 2026-11-11 08:36 — SIMPLE-SIGNUP MARKER STEP (G-11 resume): the
  simple-signup release tree (deployed live 2026-11-10 ~18:52 PKT) is
  committed to the release branch as
  2c42cd4e38d7feb7ca0e8c74ce13644f2acb169c (497-entry manifest); this
  handover sync is the following commit, and the provider marker
  advances to it (6bd1cbe1… → this commit) with verify-github-source
  VERIFIED. The G-11 release sequence continues from here: P-1 deploy,
  then the Console MVP deploy, the Keycloak operqon:owner leg, and the
  Rams Al Kayan Option-2 proof case. [Muse]
- 2026-11-11 09:39 — P-1 DEPLOYED (G-11 release sequence): the P-1 tree
  (deal desk, dunning studio, payment links, MRR, statements, invoice
  PDF + portal Leg B) is committed as
  90d89cc620cc9ffa56e128fd80294c15b1f25140 and LIVE — isolated
  Dockerfile.test gate 810 passed / 3 skipped on-box, migrations at
  head 0018_payment_links, real-browser smoke PASS (operator sign-in,
  audit chain verifies, MRR surface present). Four attempts: the G-11
  deploy tooling had three defects (backup .absent markers written
  without parent dirs; compose OIDC env not recovered from the running
  container; a served-bytes check that did not follow the
  /customer/dashboard.html 301) — all fixed in the tooling; attempts
  2–3 rolled back cleanly and verified (old behaviour restored,
  /metrics/mrr 404). One earlier gap closed on the way: $ROOT was
  missing 3 Keycloak theme files the simple-signup install had skipped;
  restored from the verified clone so verify-github-source passes.
  The provider marker advances to this handover commit. Next in the
  sequence: Console MVP deploy, Keycloak operqon:owner leg, Rams Al
  Kayan Option-2 proof. [Muse]
- 2026-11-11 10:17 — CONSOLE MVP DEPLOYED (G-11 release sequence,
  grants-fix re-run): the first step-5 deploy (release-console-mvp2)
  applied migrations to head 0023_tenant_access_change and passed
  readyz, but its smoke failed 5/6 — the issues inbox returned 500,
  InsufficientPrivilege on executor_heartbeats: migrations 0019-0023
  created the table owned by the migration role opq_admin with NO
  grants for the API runtime role operqon_api (every migration up to
  0018 had closed with the GRANT block; 0022 omitted it, and the
  single-role Docker gate structurally cannot see cross-role grants).
  That deploy rolled back cleanly (P-1 restored, smoke 5/5 re-passed;
  additive migrations stayed at 0023). The fix ships as composed tree
  release-console-mvp3 = mvp2 + forward migration
  0024_runtime_grants (GRANT SELECT, INSERT, UPDATE ON
  executor_heartbeats + GRANT USAGE, SELECT ON its sequence TO
  operqon_api — the established pattern; downgrade revokes) + a
  contract test that derives the 0019-0023 created-object set from
  the migration sources. Redeploy: QA delta 56 files, isolated gate
  938 passed / 4 skipped in-image, head 0024_runtime_grants,
  real-browser smoke PASS 6/6 including the issues inbox; grants
  verified live (operqon_api arw on the table, rU on the sequence;
  executor heartbeats landing). The tree is committed as
  17ad21fb8c7bfb80b44b220504cfe407d21a8c73; the provider marker
  advances to this handover commit. Remaining in the sequence: Rams
  Al Kayan Option-2 proof on the now-live MVP code (diagnose → retry
  pair → orphan adoption); the Keycloak operqon:owner leg is
  owner-only (the scoped admin holds no provider-realm rights).
  [Muse]
- 2026-11-11 12:24 — CONSOLE MVP5 DEPLOYED + PAIRING oc23 + RAMS
  ATTEMPT 4 (install-hook fix): the operqon_core install-hook defect
  behind attempt 3 is fixed at the app layer — the Workspace dock
  convergence (workspaces/install.py retire_erpnext_home) now DEFERS
  with a named skip when the stock Home workspace's own fixture
  links are absent on a partial shell (Number Cards Annual Sales /
  Annual Purchase / Total Stock Value + Dashboard Chart Profit and
  Loss, all 0 rows on Rams), instead of dying in _validate_links;
  the deferral self-heals on the next migrate. A governed completion
  entry (setup/install.py complete_install = install_all + landing)
  ships with it. Composed tree release-console-mvp5 = mvp4 + the
  executor heal v2 ONLY (no migration; head stays
  0024_runtime_grants): converge_install runs the app's
  complete_install on resumed/adopted shells after
  complete_install_set and records install_converged in the site
  marker. QA delta 2 files; local suite 954 passed / 3 skipped;
  acceptance battery 13/13; deploy smoke PASS. Pairing: oc23 built
  on the oc21 LINEAGE + the hook fix (the oc22-content build FAILED
  its verify_image gate — the packaged frontend the oc22 merge
  placed in canonical is a stale SPA build: sales/buying/pos
  sources "fixture", missing the CSRF login-loop fix and the
  GAP-12–15 wiring — so the SPLIT clause fired; the oc22 swap now
  needs the SPA repackaged from the own-frontend source first).
  oc23 gate legs (i)/(ii)/(iii) all pass; swap done with the timer
  paused; Rektrs + demo2 verified serving (login 200, bundle asset
  200 after the assets_json client-cache flush via a backend
  restart). Retry cap raised 3 → 4 through the governed env-backed
  setting (OPERQON_PROVISION_RETRY_ATTEMPT_CAP=4 in the R2 API
  env_file; no DB edit). Rams attempt 4: diagnosis → retry pair
  (fresh key, SoD intact, request 200 — the raised cap in action)
  → claim → the heal fired and the marker records
  install_converged: true — the job passed install_apps, the
  convergence AND ensures (all three prior failure points) — then
  failed at the NEXT step with SETUP_MASTERS_FAILED
  ("ProvisionStepError: Site setup-masters seeding failed"; the
  step discards bench stderr, so the site-side exception text does
  not survive — follow-ups: give that helper captured output; a
  reproduction lane from the preserved shell state). Per the
  brief's rule and owner Option 2 the lane STOPPED: no further cap
  change, no manual reconciliation. Rams stays suspended
  (attempts 4, manual_required), subscription byte-identical,
  Rektrs + demo2 active and untouched. The tree is committed as
  2cedc9640b4cbd9d440345cda87107d11e7648be; the provider marker
  advances to this handover commit. Full report:
  hidden_files/team-rams-install-hook-fix.md. [Muse]
- 2026-11-11 11:10 — CONSOLE MVP4 DEPLOYED + RAMS PROOF ATTEMPT 3
  (Rams resume fix): the G-3 adoption/resume install-set gap is
  closed in composed tree release-console-mvp4 = mvp3 + the executor
  heal ONLY (no migration; head stays 0024_runtime_grants):
  complete_install_set runs on resumed/adopted shells BEFORE the
  ensures step — missing = create install set − site_config
  installed_apps, installed in create order through the bench
  channel (new allowlisted install_app helper action), re-read and
  verified, and recorded in the ownership marker as
  installed_missing_apps; fresh creates and verify-only completion
  are untouched (pinned by tests, incl. the new acceptance leg G
  driving the exact post-attempt-2 Rams shape to publish). QA delta
  4 files; local suite 949 passed / 3 skipped; real Docker gate
  948 passed / 4 skipped in-image; deploy smoke PASS (issues inbox
  200 with counts + health). Rams Al Kayan attempt 3 — the last
  under the retry cap — was then driven through diagnosis → retry
  pair (one fresh idempotency key, SoD intact) → claim: the heal
  fired and ran bench install-app operqon_core, which REGISTERED
  the app (site_config now lists the full set [frappe, erpnext,
  operqon_core]) but failed inside operqon_core's own install hook —
  workspaces/install.py retire_erpnext_home() saves a Workspace doc
  whose link does not validate on an existing shell
  (LinkValidationError) — recorded honestly at the new step
  install_apps with code APP_INSTALL_FAILED and the captured bench
  output in the failure record. Rams stays suspended (attempts 3/3,
  rollback manual_required, subscription byte-identical, site never
  published); its remaining blocker is that site-side operqon_core
  install-hook defect, and any further attempt is a governed cap
  decision after a site-side fix ships. The tree is committed as
  9170e4e347afc1866aec4aae7b6610b1b5d109d8; the provider marker
  advances to this handover commit. Remaining in the sequence: the
  Keycloak operqon:owner leg (owner-only); oc22 swap; Slice 10 / W1
  closure. Full report: hidden_files/team-rams-resume-install-fix.md.
  [Muse]
