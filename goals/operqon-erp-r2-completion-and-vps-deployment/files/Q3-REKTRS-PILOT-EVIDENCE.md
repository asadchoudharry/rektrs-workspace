# Q3 Rektrs Pilot — Evidence Pack

**Tenant:** Rektrs Private Limited — tenant id `f02ded70-c77a-44dc-a935-fa91484b18e6`,
slug `rektrs-private-limited`, country PK, plan `enterprise` (Business),
admin assadchoudharry@gmail.com.
**Target site:** `rektrs-private-limited.stage.operqon.cloud` (staging pairing,
image `operqon/erpnext-tenant:v16.53.0-oc9`). The pilot ran as a controlled
pilot on the staging pairing; production cutover is a separate change window
and was not part of this run.
**Run dates:** 2026-11-06 (intake) → 2026-11-07 (Stages 0–4) → 2026-11-08
(Stages 5–9).
**Sources:** lane reports in `hidden_files/` (cited per stage), the
coordinator's own database verifications recorded in `MEMORY.md`, and the
run sheet `hidden_files/q3-rektrs-run-sheet.md`. Facts not present in a
report or in `MEMORY.md` are marked UNVERIFIED where they appear.

---

## Stage 0 — Go/no-go checks (2026-11-07 ~19:05–19:15 PKT)

Source: `team-q3-pilot-stage1.md` §1. All live reads; Rektrs not mutated.

| # | Check | Result |
|---|-------|--------|
| 0.1 | Public pricing endpoint, PK | PASS — all 3 plans `price_approved: true`, PKR, `trial_days: 3`; monthly minor: starter 750000, growth 999900, enterprise 1999900 |
| 0.2 | Pairing decision / suffix pair | PASS — `OPERQON_SITE_SUFFIX=stage.operqon.cloud`, target label `staging`; target site `rektrs-private-limited.stage.operqon.cloud` |
| 0.3 | Hostname readiness | PASS — `dig` from the VPS → 72.61.214.64 (wildcard `*.stage`); sibling sites on the same suffix answered `pong` over verified HTTPS. The loopback tls-ask endpoint (127.0.0.1:18097) returned 404 uniformly (Rektrs name, published site, garbage name alike) — uniform service behaviour, not a Rektrs refusal |
| 0.4 | Executor health | PASS — `operqon-r2-provisioner.timer` active (~40 s cadence); `worker-preflight.sh` clean ("ISOLATED ERPNext v16 BENCH + ROOT-ONLY SECRETS + CLOUDFLARE HOOK: CHECKED") |
| 0.5 | Latest provider backup fresh | PASS — `erp-saas-r2-provider-backup.timer` last ran 2026-11-07 02:57:32 UTC |
| 0.6 | Repo snapshot / GitHub VERIFIED | PASS — `verify-github-source.sh` → "GITHUB SOURCE-OF-TRUTH: VERIFIED e92588d06de41b37a976fc217caa513faed50b3e" (the deployed marker at the time; docs head `d09eea0a` on top) |
| 0.7 | Preconditions P-1 (SSO `response_type=code`, F-1) / P-2 (admin role grant, F-3) | PASS — both closed by Pass C for the staging pairing (pairing then on image oc5) |
| 0.8 | F-5 (provisioning seeds setup-wizard masters) | IN FLIGHT at Stage 0 — the F-5 lane had not yet reported; pairing still on oc5. F-5 gated the start of Stage 5 (payment → automatic provisioning), not Stages 3–4. It closed later the same evening (executor step `configure_setup_masters` + app-side `apply_setup_masters`, pairing image oc8, then carried into oc9 by F-ride) |

Sub-items the Stage 0 lane flagged as open (same-day DB re-read of approved
seat prices; pairing-lock / open-jobs read) were closed by the Stage 1
closure batch below.

## Stage 1 — Intake confirmation (2026-11-07)

Source: `team-q3-pilot-stage1.md` §5 (read-only DB batch; stop rule NOT
triggered).

Tenant row, as read:

| Field | Value |
|---|---|
| id | `f02ded70-c77a-44dc-a935-fa91484b18e6` |
| company_name | Rektrs Private Limited |
| status | `requested` |
| onboarding_path | `paid` |
| plan_code | `enterprise` |
| email_verified_flag | **true** |
| identity_verified_flag | false — truthful record; the seamless paid path has no identity step by design (S7) |
| created_by | `public-intake` |
| admin_email | assadchoudharry@gmail.com |
| country_code | PK |
| created_at | 2026-11-06 12:28:58 UTC |

- Customer identity binding PRESENT: `customer_identities` row
  `2ebc9ea3-39c3-4b66-b6c8-86dd9e587753`, created 2026-11-06 16:14:02 UTC.
- Absence checks, all as expected: subscriptions 0 rows, billing_invoices
  0 rows, provision_jobs 0 rows.
- PK seat prices confirmed exact against approved proposal
  `c4ed372c-84a6-4459-a8da-54c6b0e4fae2` (v1, approved 2026-11-07
  10:55:43 UTC): `additional_seat_minor` starter 50000, growth 50000,
  enterprise 100000. Monthly/annual minor: starter 750000/7500000, growth
  999900/9999000, enterprise 1999900/19999000, onboarding fees 0.
- Pairing lock clear: provision_jobs across all tenants only in terminal
  states (completed 4, failed 1, published 18); non-terminal or leased
  jobs: 0.

## Stage 2 — Removed

The identity-review stage was removed from the product in S7. There is
deliberately no step here; nothing was performed or skipped in this run.

## Stage 3 — Customer link (already complete before the pilot)

The `customer_identities` binding (Stage 1 evidence) and the verified
customer email completed this stage before the pilot began; no link/claim
action remained for the owner. Portal resting state observed by the owner
on 2026-11-07: onboarding stage "Email verified", current plan Business
Rs 19,999, "No invoices yet", "Nothing to pay right now" — the expected
resting state at this point of the flow.

## Stage 4 — Subscription + invoice (2026-11-07, console, `operqon-billing`)

Source: `team-q3-pilot-stage1.md` §6 (server-side DB verification of the
owner's console sitting; no mismatches).

Subscription:

| Field | Value |
|---|---|
| id | `050443be-0731-422b-b8c9-21ec476e0ad4` |
| tenant_id | `f02ded70-c77a-44dc-a935-fa91484b18e6` |
| plan_code | `enterprise` (Business) |
| state | `pending_payment` (console showed Draft → Pending payment) |
| created_by | `2e583306…` (the `operqon-billing` actor ref) |
| created_at | 2026-11-07 14:30:49 UTC |

Invoice:

| Field | Value |
|---|---|
| id | `f6d611a7-6ce7-426c-b7cf-dd0cc19edff4` |
| invoice_number | `OPQ-202611-EBABC231` |
| subscription_id | `050443be-0731-422b-b8c9-21ec476e0ad4` |
| pricing_proposal_id | `c4ed372c-84a6-4459-a8da-54c6b0e4fae2` (approved PK v1) |
| amount_minor | **1999900** — exactly Rs 19,999.00, taken server-side from approved pricing; no amount field exists on the form |
| currency | PKR |
| payment_channel | offline (payment_gateway NULL) |
| period_days | 30 (Monthly) |
| status | `issued` |
| created_by | `2e583306…` (billing actor) |
| created_at / issued_at | 2026-11-07 14:31:28 UTC / 14:31:38 UTC |
| due_at | **2026-11-21** 14:31:28 UTC |
| paid_at / payment_reference | NULL at this stage |

Audit events 445 (`subscription_drafted`), 446 (`billing_invoice_drafted`),
447 (`billing_invoice_issued`), all by the billing actor; the chain was
verified by the app's own HMAC verifier at the time (AUDIT_CHAIN_OK, 446
events counted by the verifier; the SQL linkage check counted ids to 447).

Stage-label nuance (recorded in the Stage 1 report §6.3): the shipped
`customer_status` computation renders the portal stage `email_verified`
for a `requested` + email-verified tenant even with a subscription
pending payment and an issued unpaid invoice; the string
`awaiting_payment` is produced only for an `approved`-status tenant
without the payment flag. No record was wrong.

**Known product gap recorded at this stage:** customer self-service
subscription/invoice creation does not exist in the shipped product (no
customer endpoint; creation is provider-side in the console under the
billing login). It did not block the pilot. The owner's decision on
building it (the S9 item) is still open — see the open queue.

## Pre-Stage-5 board re-verification (2026-11-08 ~08:47 PKT) — BOARD GREEN

Source: `team-q3-pilot-preflight-rerun-20261108.md` (third run; runs 1–2
were blocked/interrupted by a sandbox egress outage — a verification
outage, not a system fault; the platform was independently confirmed up).

All 8 items PASS, read live that morning:

1. Marker `29c7135f0c73a38f915a83d1d2cd2b914dd68d82` (F-ride) + live
   alembic head `0016_offline_evidence_optional`.
2. Rektrs tenant in its exact Stage-4 state: `requested`, version 2,
   email_verified true, identity_verified false.
3. Subscription `050443be…` `pending_payment`; invoice
   `OPQ-202611-EBABC231` `issued`, 1999900 minor, PKR, unpaid, due
   2026-11-21.
4. Test notice `8ce6ba02…` still `pending_verification` (bank reference
   `55566542`, submitted 2026-11-07 16:40:46 UTC) — not resolved
   overnight; sitting step 1 (reject it first) stood.
5. Pricing proposal `c4ed372c…` the only approved PK proposal, terms
   exactly `{"currency": "PKR", "tax": "excluded", "trial_days": 3}`.
6. Pairing: zero non-terminal provision jobs (published 23, completed 4,
   failed 2); provisioner timer active; staging pairing backend on image
   oc9.
7. readyz 200 on 18090 and 18089; audit chain 611 events (ids to 612),
   0 hash-linkage mismatches, `audit_head` = last event's hash; provider
   backup had run 2026-11-08 02:41:35 UTC.
8. demo2 (`714b7600-4511-4a1a-8f77-aaefa50084eb`) still `requested`,
   version 2 — untouched.

The owner chose to wait for this green board before sitting (decision
recorded 2026-11-08 08:41 PKT).

## Stage 5 — Offline payment settlement (2026-11-08, driven model)

Run under the owner's driven-takeover model (owner decision 2026-11-08
12:33 PKT: the coordinator drives the console/portal steps; the owner
creates accounts, performs the sign-ins, and makes the actual bank
transfer — his bank app, his money). Coordinator's own DB verifications
(MEMORY.md) settle each sub-step.

**5.1 Test notice rejected.** Notice `8ce6ba02-5198-4f40-aff7-1a1fdb67f31b`
(bank reference `55566542`, a test notice from the 2026-11-07 exploration
sitting — no payment was ever made against it). Driven session
12:34–12:36 PKT: the owner signed in as `operqon-billing-approver`; the
lane exact-match-verified the row (invoice `OPQ-202611-EBABC231` /
reference `55566542` / Pending verification) and rejected it with reason
"Test notice — no payment made." Coordinator DB verification: status
`rejected`, resolved_by `7f0a4157…`, resolved_at 2026-11-08 07:36:18 UTC,
audit event 626 `customer_payment_notice_rejected`; offline approvals for
the invoice = 0 (nothing settled); invoice still `issued`/unpaid.

**5.2 Product gap found live — no bank instructions on the portal
invoice.** The customer-portal session (owner signed in; portal opened
straight into the Rektrs workspace) found invoice `OPQ-202611-EBABC231`
showing **no bank payment instructions at all** — no bank name, account
title, account number or IBAN; the page said only "Pay by bank transfer,
then record the transfer…" and "Contact Operqon billing for bank
transfer instructions." The receiving account is owner-side business
knowledge and was recorded nowhere in the system. The owner transferred
to his own Operqon receiving account; only the bank reference entered
the system. This gap is closed by a built fix — see "Built during the
pilot" below (bank-instructions build).

**5.3 Real transfer + portal notice.** The owner made the real bank
transfer of Rs 19,999 and supplied the bank transaction reference
**TX-5526658456885** (owner's attestation; system-side verification
happens at the approval). The driven portal session filed the notice on
invoice `OPQ-202611-EBABC231` with exactly that reference; the portal
showed "Payment notice received — pending independent verification" at
submission.

**Portal gap #2 (display-only):** after a reload, the redesigned portal
did **not** re-display the pending notice (form back empty, invoice still
"Issued"). The filing lane reported the outcome UNCONFIRMED and did not
re-file. The coordinator's DB check settled it: the notice **is** stored
— reference TX-5526658456885, `pending_verification`, submitted
2026-11-08 07:44:05 UTC; audit event 629
`customer_payment_notice_submitted` (actor `customer:5bde9f88…`); invoice
still `issued`, subscription still `pending_payment`. Root cause (found
by the build lane): the customer invoices read path carried no notice
state at all; the submit path set the confirmation string locally
(`frontend/customer/assets/dashboard.js`, ~line 400) and discarded it.
Fix BUILT post-pilot — see below.

**5.4 Approval + settlement.** Driven session 12:45–12:48 PKT: the owner
signed in as `operqon-billing-approver`; the lane exact-match-verified
the row and approved. Approval row
`7509865e-7606-4fb1-9dff-a94f6785fae6`:

| Field | Value |
|---|---|
| bank_account_alias | `rektrs-private-limited` — the console's own validation required the registered lowercase slug format; the literal "Rektrs Private Limited" in the coordinator's brief was rejected by the form. Same beneficiary |
| bank_transaction_reference | TX-5526658456885 |
| statement_sha256 | **NULL** — the evidence-hash field was left empty; the optional-hash path (migration 0016) was taken on the real run |
| amount | 1999900 minor, PKR |
| approved_at | 2026-11-08 07:47:36 UTC |
| approved_by (actor ref) | `7f0a4157…` |
| Separation of duties | Clean: approver ≠ invoice.created_by (`2e583306…`, billing) and ≠ tenant.created_by (`public-intake`) |

Resulting state changes (coordinator-verified): notice →
`verified`; invoice → **PAID** (paid_at 2026-11-08 07:47:36 UTC,
payment_reference `offline:TX-5526658456885`); subscription →
**active**; tenant → `provisioning` (version 3). Audit events 630–634:
`offline_bank_credit_approved` → `tenant_offline_payment_approved` →
`paid_subscription_activated` → `payment_provisioning_queued` →
`provision_job_claimed`. Provision job
`1423d8fa-51fc-40c8-a77c-7dbc4ff44c1e` was daemon-claimed at
2026-11-08 07:47:40 UTC.

**Stage 5 verdict: COMPLETE.** The fixture pattern was not used for the
real tenant at any point: the payment was the owner's real transfer and
the approval ran under the owner's own billing-approver session.

## Stages 6–7 — Provisioning, publication, site battery (2026-11-08)

Source: `team-q3-pilot-stage67-verify.md`. Verdict: **STAGE 6-7 PASS.**

Timeline (all live-read):

| Moment | UTC | Evidence |
|---|---|---|
| Settlement (invoice paid) | 07:47:36 | invoice `paid_at`; audit 631, 633 |
| Daemon claim | 07:47:40 | audit 634 `provision_job_claimed` (`operqon-executor-service`) — 4 s after queueing, **unattended, no augmentation** |
| Executor completed | 07:50:04 | audit 635 `frappe_site_created`, 636 `tenant_sso_configured`, 637 `tenant_support_configured`, 638 `tenant_setup_masters_seeded` |
| Daemon auto-publish | 07:50:10 | audit 639 `payment_verified_site_auto_published`; tenant → `active` |

Settle → publish ≈ **2.5 minutes** (the workflow-test precedent), inside
the 15-minute incident rule.

Provider records:
- Tenant: status **`active`**, version **4**, updated 2026-11-08
  07:50:10 UTC (the publish write).
- Job `1423d8fa-51fc-40c8-a77c-7dbc4ff44c1e`: state `published`,
  attempts **1**, `failure_code` empty, task_type `create`, site_name
  `rektrs-private-limited.stage.operqon.cloud`; `requested_by` and
  `approved_by` both `operqon-payment-automation` (the auto-publish
  gate's two fields, exactly).
- **Published manifest bindings (the F-ride claim patch, proven on the
  real tenant):** `setup_masters_configured: true`,
  `setup_country_code: "PK"`, `setup_currency: "PKR"`,
  `setup_fiscal_year: "2026-2027"` — carried by the daemon-claimed job
  with **no augmentation** (no lane touched this job). Also
  `site_status: published`, apps `[erpnext, operqon_core]`,
  `sso_configured: true` (client `operqon-erp-rektrs-private-limited`),
  `support_configured: true`, `site_users` = exactly one (Asad Ahmad),
  backup ref
  `/var/backups/operqon-sites/1423d8fa-51fc-40c8-a77c-7dbc4ff44c1e.json`.
- **`identity_reviews` rows for this tenant = 0** — the seamless paid
  path ran with no identity step anywhere.

Site battery (bench, staging pairing):
- Pong: `GET /api/method/ping` → `{"message":"pong"}` HTTP 200.
- Apps: frappe **16.54.0**, erpnext **16.53.0**, **operqon_core 0.0.1**.
- Seeded masters, exact: Customer Group **5**, Territory **3** (incl.
  Pakistan), Item Group **6**, Supplier Group **8**, UOM **239** + UOM
  Category **17**, Fiscal Year **2026-2027** (2026-07-01 → 2027-06-30,
  disabled = 0), Standard Selling + Standard Buying price lists both
  **PKR, enabled**, Global Defaults `default_currency = PKR`,
  `country = Pakistan`.
- SSO as shipped: the site's own login page carries the "Login with
  Operqon" authorize href verbatim with **`response_type=code`** and
  `client_id=operqon-erp-rektrs-private-limited` (the F-1 fix, live on
  this site). The interactive round-trip itself was Stage 8.
- Tenant admin (assadchoudharry@gmail.com): enabled, System User, roles
  **exactly [Operqon Tenant Admin, System Manager]** (the F-3 grant).

Boring checks:
- Audit chain verifies: **638 events** (ids to 639), 0 prev_hash linkage
  mismatches, `audit_head` = event 639's hash (full-table SQL linkage +
  head equality, the corroboration method of record).
- Rektrs billing states unchanged: subscription `active`, invoice
  `paid` with reference `offline:TX-5526658456885`.
- demo2 still `requested` version 2, untouched.
- Pairing: zero non-terminal jobs; published count 24 (+1 = this run).

## Stage 8 — First access via SSO (2026-11-08, three browser runs)

The owner's first sign-in exposed two defects that every API-level and
bench-level battery in this programme had missed. Both are recorded
plainly, with their resolutions.

### Finding (i) — the staging pairing served no static assets at all

First run (12:53–12:55 PKT): the login page rendered unstyled (no CSS,
logo/images failing, the login form appearing twice) and `/desk`
rendered as a completely blank white page; the site root then also
rendered blank. The owner confirmed the same broken page on his own
screen (tab title "Frappe", broken-image icon) at ~12:55 PKT. Probes
from the box returned **404 for every `/assets/…` URL on every site on
the pairing**, Rektrs and the known-good workflow-final sibling alike,
while the asset files existed intact on disk (`sites/assets`, correct
`assets.json`) and HTML/ping/SSO/masters were healthy.

Diagnosis verdict (2026-11-08 ~13:00 PKT): the staging bench was
gunicorn-only behind a pure Caddy reverse proxy. Frappe's WSGI app does
not serve `/assets`, and there was **no nginx/static tier anywhere in
the chain** — so every CSS/JS/image URL 404'd for every pairing site.
The pairing had never had a static tier in its current container form.
USER-IMPACT = real: any fresh browser got an unstyled login and a
blank Desk.

Resolution: a `frontend` nginx service was added to the staging compose
(same oc9 tenant image, stock Frappe nginx config via
`nginx-entrypoint.sh`, host port 127.0.0.1:18091) and only Caddy's
`*.stage.operqon.cloud` upstream was repointed to it (snapshots of the
compose file and Caddyfile kept; config validated before reload). The
addition was pure — a docker-ps diff proved no existing container was
recreated. Verification via the public path: **ASSETS = SERVED** — every
previously-404 asset returned 200 with the correct content type and
byte-exact sizes on **both** Rektrs and the sibling (website CSS
578,166 B; login CSS 77,953 B; desk CSS 823,695 B; desk JS
1,346,622 B; frappe-web JS 669,028 B; logo/favicon 200). Console,
portal, Keycloak discovery and provider-production readyz all stayed
200 — untouched surfaces proven. Caveats recorded at the time: no site
had `public/files` content yet, so the `/files` static-hit branch was
unexercised against a real file (same generated template the pilot
stack serves from); the pairing has no websocket service
(pre-existing, unchanged by this fix).

### Finding (ii) — provisioning leaves the site in Frappe's setup-incomplete state

Second run (13:07–13:08 PKT, after the asset fix): pages rendered
styled, but the site presented **no login page at all** — guests were
routed to the ERPNext first-run Setup Wizard
(`/desk/build/setup-wizard/0`) and `/login` redirected back to it; there
was no "Login with Operqon" button in a browser, so no SSO sign-in was
possible.

Diagnosis verdict (2026-11-08 ~13:14 PKT), proven on the live site
databases: Rektrs had **zero Companies**; `tabInstalled
Application.is_setup_complete = 0` for **both** frappe and erpnext
(Frappe v16 derives `System Settings.setup_complete` from those rows;
the Desk SPA router force-routes every session to the wizard while
either is 0); Global Defaults `default_company` was NULL (the
currency/country defaults from F-5 were set). The workflow-final
sibling was in the identical flag state; its one Company had been
created by the workflow-test driver through the admin's own session
(2026-11-07 23:39:55), not by provisioning — and even that never
flipped the flags. In the provisioning path itself (executor `create` →
`ensures` → `configure_setup_masters` → `configure_sso` →
`configure_support` → `backup`), nothing creates a Company and nothing
marks setup complete: `apply_setup_masters` scopes itself to the
company-free subset by design, and the app pack's
`bootstrap_company(config)` (`operqon_core/setup/bootstrap.py`, ENG-025/026)
is called only by proof/test fixtures, never by the executor — and even
it sets neither `default_company` nor the flags.

Resolution on the real site: **the owner completed the ERPNext setup
wizard himself** during his Stage 8 takeover session (Company created
2026-11-08 13:12:53 site-local, owner `assadchoudharry@gmail.com`). The
coordinator's corrective lane (which would have run `bootstrap_company`
server-side) re-read the state first, found the wizard already
completed, and **stopped, creating nothing** — exactly as its guard
required. Resulting record: Company **"rektrs"**, abbreviation **"R"**,
Pakistan, PKR, Standard Template chart ("Standard with Numbers"),
perpetual inventory on, **96 accounts**, 5 default warehouses, standard
account defaults wired; both `is_setup_complete` flags → 1;
`System Settings.setup_complete` → 1; Global
Defaults `default_company` = "rektrs". The coordinator verified no
collateral damage: masters intact, admin roles exact, SSO unchanged,
and guests then received `GET /login` → 200 with the "Login with
Operqon" button and no wizard redirect.

Differences from the prescribed bootstrap record (flagged at the time,
deliberately left untouched): the company is named "rektrs"/"R" rather
than "Rektrs Private Limited" with a derived abbreviation; the Fiscal
Year 2026-2027 record's companies list is empty (the wizard did not
link the company into it; Frappe resolves the fiscal year by date, so
practical impact is limited); and no Operqon Company Setup (ENG-025)
record exists. **The owner decided on 2026-11-08 (~13:20 PKT) to keep
the company name "rektrs"** — no rename will be performed.

The permanent fix is queued in the post-pilot release: a new executor
step `configure_company` after `configure_setup_masters`, calling a
whitelisted app-pack function that runs `bootstrap_company` from the
claim's country/currency plus the provider company record, sets
`default_company` and both setup-complete flags, idempotent,
failing loudly on ambiguity — so every future tenant lands on the
login page, not the wizard.

### Third run — Stage 8 PASS (2026-11-08 13:18–13:20 PKT)

- Guest view: `/login` served with the **"Login with Operqon"** link
  and **no wizard bounce**.
- The SSO click carried straight into the **Desk** on the existing
  session (the lane logged out and back in to prove the guest path).
- Signed-in user verified from the profile: **Asad Ahmad**,
  assadchoudharry@gmail.com, username `asad_ahmad`, **Active/Enabled**.
- Company list = exactly **"rektrs"** (PKR, Pakistan, perpetual
  inventory).
- Desk apps: **ERPNext + Operqon + Framework**; ERPNext workspaces:
  Setup, Accounts, Selling, Buying, Stock, Manufacturing, Projects,
  Assets, Quality.
- The Desk was left open for the owner.

**Stage 8 verdict: PASS** — with the two findings above recorded as the
stage's substantive output.

### Follow-up verdicts (Stage 8 deviations, closed the same day)

- **LOGIN PAGE = STYLED FOR NEW VISITORS.** A complete resource audit
  of the login page was run; the unstyled rendering seen in the third
  run was the old browser profile holding a **cached pre-fix 404**.
  New visitors get the styled page.
- **OPERQON ICON = `/assets/operqon_core/images/operqon-app-icon-dark.svg` → 404.**
  The Operqon app tile on the Desk home fails to load. The icon source
  exists in the app pack, but it never entered the built asset tree.
  The Desk branding build owns the fix (see the open queue).
- **HOME CARDS = STALL on Total Stock Value only.** The Desk home
  number cards resolve to 0.0 instantly except **Total Stock Value**,
  which stalls: the Bin read behind it returns **403** for the
  tenant-admin roles (the measured F-6/pin boundary — direct reads of
  governed trees remain gated for the admin's roles on this pin). The
  card's data path, not the site, is what stalls.
- **TIMEZONE = set to Asia/Karachi.** The tenant admin user's
  `time_zone` was **Asia/Kolkata**; it was corrected to
  **Asia/Karachi** (the owner's actual timezone) and re-read confirmed.

## Backups taken during the pilot (2026-11-08)

Source: `team-full-backup-20261108.md` plus the Keycloak and provider
legs recorded in `MEMORY.md`.

On the owner's direct order ("back up everything"), a full backup run
was taken at 2026-11-08 07:57 UTC (12:57 PKT):

- **Provider DB:** fresh `pg_dump -Fc` (167,726 B, harness-validated,
  alembic head 0016 recorded in its `.info`) → restic snapshot
  **`13e26723`** on Cloudflare R2 (tags `erp-saas, operqon-provider,
  daily`).
- **Rektrs site:** bench backup with files — database.sql.gz
  978,750 B, files.tar 10,240 B, private-files.tar 10,240 B,
  site_config_backup.json 261 B (gzip/tar integrity-checked) → restic
  snapshot **`f7379cb0`** (tags `erp-saas, rektrs-site, manual-20261108`),
  **restore-read verified from R2**. That manual snapshot is a one-off:
  no recurring leg covers staging-pairing tenant sites.
- Already covered that day by the existing daily legs: Pilot
  `pilot.local` (snapshot `adf53c03`, 02:38 UTC), Demo (snapshot
  `fdede405`, 03:45 UTC, self-verifies restore-read), R1 encrypted
  local provider backup (02:41 UTC). Repo state after the run: 39
  snapshots, 37.06 MiB.

Gaps the backup lane named, and what happened to each:

1. **Keycloak's own Postgres had no backup leg at all** — closed the
   same day: fresh dump (294,192 B, TOC-validated) → restic snapshot
   **`18f96ac7`** with restore-read from R2 PASS; then a **recurring
   daily leg** was installed mirroring the provider pattern — wrapper
   `/usr/local/sbin/erp-saas-r2-backup-keycloak`, timer daily **03:05
   UTC** (enabled + active), retention extended to the `keycloak` tag
   (7d/4w/6m) — and proven by a hand run → snapshot **`3485c9c4`** with
   restore-read hash match. The provider leg was verified untouched by
   that install.
2. **The ~39 other staging-pairing fixture sites** have no backup leg.
   They are test fixtures slated for the owner-ordered purge (see the
   open queue); the Rektrs manual snapshot above is the deliberate
   exception.
3. **Box-level config/secrets** (`/etc/operqon/*`, the restic password,
   the R1 backup key) are not in restic by design; owner-held copies
   remain an open owner item (carried in the handover queue, Q1).

**Provider harness flake — FIXED + PROVEN.** The Keycloak leg work
exposed a latent defect in the provider backup harness
(`backup-provider-db-r41.sh`): its TOC check used
`printf … | grep -q "dbname: …"` under `set -o pipefail`; `grep -q`
exits on the early header match, SIGPIPEs `printf`, and the check can
fail closed despite a good dump. The fix replaced line 73 with a
pipe-free shell `case` match (pre-change copy
`backup-provider-db-r41.sh.bak-20261108T080739Z-pipefail-fix` kept; the
coordinator verified the change by direct diff and confirmed the daily
wrapper calls exactly this script). Proof hand run 2026-11-08
08:10:55 UTC: wrapper exit 0 through the new check, fresh dump
`operqon-provider-pre-r41-20261108T081055Z.dump`, LATEST pointer
advanced, restic snapshot **`506bcf4b`**, restore-read sha256 match,
both provider timers enabled + active.

## Built during the pilot (not deployed)

Two product-gap fixes found by the real run were built the same day.
Both sit composed in one tree, `~/workspace/operqon-team/bank-instructions/`
(a copy of the F-ride release tree), and both ride the post-pilot
release. Reports: `team-bank-instructions-build.md`,
`team-portal-notice-display-build.md`.

**Bank-transfer instructions (Stage 5 gap #1).** The portal already
rendered a `manual_bank_instructions` field on offline invoices, but
the API sourced it from the static env setting
`OPERQON_MANUAL_BANK_INSTRUCTIONS`, which held exactly the fallback
text, with no operator-editable source. The build adds: a console
Settings card ("Bank transfer instructions", below Notifications) with
bank name / account title / account number–IBAN / optional note; an
operator-only `GET|PUT /api/v1/provider/settings/bank-transfer`
(stored in `platform_settings` key `bank_transfer`, in the clear — it
is not a secret; audit event `bank_transfer_settings_updated` carrying
field names only); and DB-first resolution of the portal payload with
the env fallback preserved byte-for-byte (no portal frontend change
was needed). A complete record renders the composed instructions on
issued offline invoices only; unset or partial records render today's
exact fallback. No migration (the settings table exists since 0015).
Gate status: the sandbox had no container runtime, so the real
Dockerfile.test image gate could not run — venv rehearsal only (base
398/3 + 1 pre-existing failure → built 408/3 + 1, i.e. +10 tests, zero
regressions; the one failure is the pre-existing token-drift artefact
that self-skips inside the image; expected image result 409/3). The
image gate remains **owed at composition** (`scripts/test-in-container.sh`).
F-1 deploy-list check done — no new shipped files.

**Portal pending-notice re-display (Stage 5 gap #2).** Root cause: the
customer invoices read path (`GET /api/v1/customer/invoices`) carried
**no notice state at all** — the submit path set the confirmation
string locally in the frontend and discarded it, so a reload had
nothing to reconstruct from. The build adds a `payment_notice_status`
field to the invoices payload (the latest notice's real status per
invoice, or null) and teaches the portal renderer to rebuild the
pending banner with the submit path's exact wording when the status is
`pending_verification`; resolved notices never resurrect the banner,
and a rejection returns the payable form. Submission behaviour, the
notice lifecycle and every SoD rule are untouched. Tests: +6 Python
(real endpoints, including the pilot's exact file → reload scenario
and cross-tenant isolation) + 2 DOM tests; venv rehearsal base 408/3 + 1
pre-existing failure → built 414/3 + 1 (zero regressions; expected
image result 415/3). The image gate remains owed at composition, as
above.

**Desk branding pack + provisioning `configure_company`** are also part
of the post-pilot release scope (see the open queue); they are builds
commissioned after the pilot run, not artefacts of it, and are recorded
here only to keep the queue in one place.

## Verification rules changed by this pilot (standing)

The two Stage 8 findings were missed by every API-level and bench-level
battery in the programme (the Stage 6–7 battery verified pong, app
versions, DB masters, the SSO href string and the audit chain — it
never fetched an asset URL and never loaded a page as a guest). The
following are now standing battery items for every future site/pairing
verification:

1. **Asset-fetch check** — fetch the page's own asset URLs (CSS/JS/
   images) and require 200 + correct content type, not just HTML 200.
2. **Guest-login reachability** — a provisioned site is not done until
   a guest browser session reaches its login page (no wizard routing,
   no blank render) and the SSO round-trip lands on the Desk.
3. The owner's own device/browser evidence remains ground truth: when
   it contradicts a clean test result, the server side, logs and
   response bodies are checked first.

## Pilot exit criteria — assessment against the run sheet

| Criterion | State |
|---|---|
| Tenant `active` | MET — version 4, published 2026-11-08 07:50:10 UTC |
| Provisioning job `published` | MET — job `1423d8fa…`, attempts 1 |
| Owner signed in via SSO with a usable governed surface | MET — Stage 8 third run (Desk landing, admin user verified, both roles exact). Recorded nuance: the as-admin governed reads (Company / Customer / Sales Invoice) were proven as-shipped by Pass C on a fresh tenant of the same build, and on Rektrs by the Stage 6–7 battery's role/masters verification; a fresh post-sign-in governed-read battery on the Rektrs site itself is UNVERIFIED in the lane reports — the owner's first real entries remain the live proof |
| Evidence pack complete | MET — this document (Stage 9) |

**Deviations from the run sheet, stated plainly:** the run sheet's
Stage 5 assumed the portal invoice carries Operqon's bank instructions
(it did not — gap #1 above); the sheet's Stage 5 sitting model was
superseded mid-run by the owner's driven-takeover model (2026-11-08
12:33 PKT); the sheet's Stage 8 expected the seeded masters to be the
only first-run question (the asset tier and the setup-complete state
were both missing in ways the sheet did not anticipate); and the
owner's own wizard completion replaced the coordinator's planned
bootstrap corrective for Finding (ii). None of the sheet's stop
conditions was triggered by the run itself; the two Stage 8 findings
were handled as defects found at the gate, not as stop-condition
events.

## Open queue after the pilot

In the order the programme carries them:

1. **demo2 run** — the second real tenant (id
   `714b7600-4511-4a1a-8f77-aaefa50084eb`, still `requested` v2) runs
   the same sheet. Its Stage 8 will need the same setup completion
   Rektrs needed (wizard or the `configure_company` step, whichever
   lands first) and the new asset-fetch + guest-login battery items.
2. **Slice 10** — pilot gate + accountant sign-off + ACC-18; closing it
   closes **W1**.
3. **Post-pilot release** — one vehicle carrying: the bank-instructions
   build + the portal notice-display build (composed tree
   `~/workspace/operqon-team/bank-instructions/`; image gate owed at
   composition); the provisioning **`configure_company`** step (the
   Finding (ii) permanent fix); the **Desk branding pack** (Operqon
   face on the tenant ERP — owner's standing brand rule, 2026-11-08;
   includes the Operqon tile-icon fix); and a new pairing image
   (**oc10**) built from the refreshed app pack. After deploy, the
   operator sets the real bank instructions once in the console.
4. **Fixture cleanup** — owner-ordered (2026-11-07 22:59 PKT) purge of
   all test tenants/payments/notices and their bench sites (Pass B/C,
   F-5, S6A1/S7-proof/S8A1, e2e-*, workflow-final incl. `01ce2fd5…`,
   the F-ride claim fixture) now that the pilot is complete. The
   hash-chained audit trail must stay valid — audit events are never
   silently deleted. The rejected Rektrs test notice is NOT part of
   this purge (it was resolved by rejection during the run).
5. **S9 decision (owner)** — build customer self-service
   subscription/invoice creation, or keep console-side Stage 4 as the
   operating model. Until decided, every tenant's Stage 4 is
   console-side.
6. **Alert webhook** — driven session per the driven model: the owner
   signs in as `operqon-owner`, pastes the webhook URL into the
   console Notifications card himself (it never travels in chat), and
   the coordinator then runs `/usr/local/sbin/operqon-webhook-sync`
   once. The empty webhook is why the provisioner OnFailure unit shows
   as the single `systemctl --failed` entry — the alerter exits 1 by
   design; not a defect.
7. **R4.2 merchant inputs (owner/bank)** — Easypaisa + PayFast merchant
   accounts and credentials; adapters are built (32 mock tests).
   Credentials will be entered via the live console gateway-settings
   cards. Every gateway currently reports
   `merchant_live_verified: false`.
8. **Owner secure-store items** — the three VPS-only secrets (restic
   password file, R1 backup key, settings-encryption key) into the
   owner's own secure store, plus creating one healthchecks.io check
   (`operqon-provider-backup`, period 1d, grace ~2h) with its URL saved
   to `/etc/erp-saas-backup/healthchecks-provider-url` (600). Carried
   from Q1 of the handover queue.

---

*Pack assembled 2026-11-08 (Stage 9 close-out lane). Stage-by-stage
sources are cited in each section; anything not in a cited report or in
`MEMORY.md` is marked UNVERIFIED inline.*
