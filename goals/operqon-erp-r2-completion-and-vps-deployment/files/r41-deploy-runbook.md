# Operqon R4.1 — Deploy Runbook (prepared 2026-11-06)

**Status: DEPLOY-READY after the harness prep below — deploy NOT executed.**
R4.1 code verdict (from `hidden_files/r41-verification-2026-11-06.md`): both backend gaps genuinely closed, manifest 137/137, tests 74 passed / 3 skipped, alembic head 0009. The remaining blockers were deploy-harness defects (B1, B2) and preconditions (B3). B1 and B2 are fixed locally by the patches in §1; B3 status is verified item-by-item in §3. Two coordination facts override earlier assumptions — read §5 before scheduling.

All patches are in the local review tree only:
`~/workspace/operqon-r41-review/extract/Operqon_R4_Actionable_Owner_Console/`
No application code was touched. On deploy day the patched tree (not the pristine ZIP) is the release source; re-run `sha256sum -c` expectations accordingly — the three patched/added scripts and the README intentionally differ from the shipped MANIFEST.sha256, and that difference is this document.

---

## 1. Harness patches made (Claude deploy-harness patches, owner's small-fixes rule)

### B1a — NEW `scripts/backup-provider-db-r41.sh` (pre-deploy DB backup)
deploy-r41.sh took no DB backup although migrations 0008/0009 are forward-only (both `downgrade()` raise RuntimeError). The new script:
- Runs `pg_dump -Fc` as role `opq_admin` inside the production DB container `operqon_provider_r1-db-1` (the exact container named by `scripts/preflight.sh`/`acceptance.sh`), database `operqon_provider`, password taken from `/opt/operqon-provider-r1/deploy/secrets/admin-password` — the same secret file the compose migrate service mounts as `OPERQON_DB_ADMIN_PASSWORD_FILE` (`deploy/compose.r3-customer.yaml`, `alembic/env.py`). Password travels via `PGPASSWORD` env only; never printed or written.
- Writes `/var/backups/operqon-provider-r2/operqon-provider-pre-r41-<UTC>.dump` (dir 0700, file 0600), plus `.sha256` and `.info` sidecars (the `.info` records the pre-backup `alembic_version`, consumed by rollback verification), and updates `LATEST-R41-BACKUP`.
- **Fails closed:** non-zero pg_dump, empty file, size < 1024 bytes, bad `PGDMP` magic, or a failed `pg_restore --list` TOC validation (must name `operqon_provider`) aborts and removes the partial file.
- **Encryption:** the R1-era `.dump.enc` backups under `/var/backups/operqon-provider-r1` were produced by R1's own tooling with its own key; no shared encryption helper exists in the R2/R4.1 tree, so none was invented. The dump is plain custom-format, root-only. Adding the provider DB to the encrypted off-VPS rotation remains a W0 item (unchanged).
- `bash -n` clean.

### B1b — NEW `scripts/rollback-r41.sh` (standalone rollback)
The package shipped no standalone rollback (only deploy's EXIT trap, which cannot restore the DB). The new script:
- **Requires the DB backup path as argument 1 and refuses to run without it** (also validates existence + `PGDMP` magic before touching anything). Snapshot dir is argument 2 or `/root/operqon-r41.latest`.
- Prints the full plan before acting. Requires the four compose env exports in the shell (compose `${VAR:?}` hard-fails without them).
- Sequence: stop api → restore source files from the snapshot (exactly deploy-r41.sh trap's file set/layout, including removing 0008/0009 files if absent pre-deploy) + restore the live console copies → `pg_restore --clean --if-exists` from the backup → **hard-verify** `alembic_version` equals the version in the backup's `.info` sidecar (fallback expectation `0007_customer_identity`); if it doesn't match, the script stops with the api left stopped and a manual-intervention message → rebuild api/migrate images → force-recreate api → 30×3 s readyz gate on 18090.
- `bash -n` clean.

### B2 — PATCHED `scripts/acceptance-browser-owner-r41.sh` (docker Playwright pattern)
As shipped it ran `python acceptance-browser-owner-r41.py` on the host — a regression from R3/R4. The patch mirrors `acceptance-browser-owner-r4.sh` exactly: same image (`mcr.microsoft.com/playwright/python:v1.52.0-noble`, overridable via `OPERQON_PLAYWRIGHT_IMAGE`), same `docker run --rm --network host --env-file … -v <script>:/tests/r41.py:ro … python /tests/r41.py` invocation. Adaptations only: r41 script name/mount point, and the pre-flight guards now cover **seven** roles (adds BILLING_APPROVER) plus the six `OPERQON_R41_*` fixture variables, checked by grepping the protected env file for non-empty assignments (values never printed; the file is no longer sourced into the shell). The Python test logic/assertions are **unchanged** (verified: the .py reads only env-file variables and writes no files, so `--env-file` covers it fully). `bash -n` clean.
- This failure mode is not theoretical: see §5 — it is exactly what killed the main chat's R4 deploy today.

### README correction (documentation only)
`README.md` gained a dated Muse correction note (2026-11-06) directly under the paragraph that falsely claimed deploy-r41.sh "performs backup": it states the script takes no DB backup, points at `backup-provider-db-r41.sh` (run before deploy) and `rollback-r41.sh`, and records the B2 wrapper patch. No other README text altered.

**Diffs summary vs the shipped package:** 2 files added (`scripts/backup-provider-db-r41.sh`, `scripts/rollback-r41.sh`), 1 file rewritten (`scripts/acceptance-browser-owner-r41.sh`, 6 lines → 27 lines incl. patch header), 1 file appended (`README.md`, +1 correction paragraph). Zero changes to `app/`, `alembic/`, `frontend/`, tests, compose, or deploy-r41.sh.

---

## 2. Migration rehearsal (0008/0009)

**Local disposable-PG rehearsal: NOT POSSIBLE on this machine — verified, not assumed.** `docker` and `podman` are absent (`docker: command not found`), and no `postgres`/`psql`/`initdb` binaries or `/usr/lib/postgresql` exist locally. No rehearsal was pointed at the VPS/production DB. Fallback performed: full static SQL review.

**Static review of 0008 (`0008_payment_notice_resolution`, down_revision 0007):**
- `drop_constraint("customer_payment_notice_pending_only", type_="check")` — the name matches exactly the constraint created by 0007 (`alembic/versions/0007_customer_identity.py:34`). ✓
- Adds `resolved_by` / `resolved_at` / `rejection_reason` — all nullable, no backfill, no default needed. ✓
- New checks: `status IN ('pending_verification','verified','rejected')` and the rejection-reason check. Existing rows are all `pending_verification` (the only status the old constraint allowed; verified live count of pending = 0, total notices small) → both checks validate cleanly against existing data. ✓
- PG `GRANT SELECT, UPDATE … TO operqon_api` — role exists in production. ✓ Model (`app/models.py:274-275`) matches the migration's constraint names/expressions exactly. ✓

**Static review of 0009 (`0009_country_pricing`, down_revision 0008):**
- `tenants.country_code` and `pricing_proposals.country_code`: `String(2) NOT NULL server_default 'PK'` — PostgreSQL backfills existing rows from the server default as part of the ADD COLUMN; no separate UPDATE needed and none is missing. ✓
- `drop_constraint("uq_pricing_proposal_version", type_="unique")` — name matches 0002's `UniqueConstraint("version", name="uq_pricing_proposal_version")`. ✓ Replacement unique `(country_code, version)`: all existing proposals become country `PK` with already-unique versions → no violation possible. ✓
- New table `country_plan_prices` created empty; FKs to `plans.code` and `pricing_proposals.id` reference existing tables; positive-price check applies to an empty table. ✓ Model matches (models.py:157, 287-288). ✓
- Index `ix_pricing_proposal_country_status` is a plain (non-concurrent) CREATE INDEX — brief lock on a small table; acceptable. Column-level `GRANT UPDATE (country_code)` is valid PostgreSQL syntax. ✓
- `alembic/env.py`'s `ensure_alembic_version_capacity` widens `alembic_version.version_num` inside the migration transaction — already exercised by the R2/R3 production deploys (revision ids `0008_payment_notice_resolution` = 31 chars and `0009_country_pricing` would overflow the R1-era VARCHAR(32)? `0008_payment_notice_resolution` is 31 chars — fits; `0009_country_pricing` is 20 — fits; the widening helper covers the general case anyway). ✓

**Residual risk (honest):** the migrations have still never *executed* against PostgreSQL anywhere — the SQLite suite builds schema via `create_all`, and no PG-gated test references 0008/0009. Static review can verify names, types, and data-compatibility, but not runtime behaviour (lock ordering, grant application, psycopg adaptation — the class of bug that bit migration 0002 in the R2 canary). **Mitigation made a hard deploy-day gate in §4 step 2:** rehearse on the VPS against a *disposable* PostgreSQL container restored from the pre-deploy backup (the deploy-r3.sh disposable-PG pattern), run `alembic upgrade head` there, verify head = `0009_country_pricing`, then discard — before the production migrate runs.

---

## 3. Precondition checklist — verified on the VPS today (2026-11-06, read-only)

### 3a. Muse-side / already in place ✅
| # | Item | Verified state |
|---|---|---|
| 1 | Production DB at alembic **0007** | ✅ `SELECT version_num FROM alembic_version` → `0007_customer_identity` |
| 2 | `merchant.env` at correct path | ✅ `/opt/operqon-provider-r2/deploy/config/merchant.env` exists, 785 bytes, mode 600 (contents never read) |
| 3 | Live stacks healthy | ✅ `operqon_provider_r2-api-1` Up (healthy) on r3-customer image; R1 api + DB containers Up (healthy); Keycloak container Up |
| 4 | R4 deploy not running; baseline clean | ✅ No deploy/acceptance/Playwright processes. Deployed tree's 3 console files hash **exactly** to the GitHub-approved R3 manifest (`/opt/operqon-r2-github/…/MANIFEST.sha256`); the R4 attempt was fully rolled back (§5). R4.1's snapshot-first deploy is safe against this baseline |
| 5 | DB backup + rollback capability | ✅ Created by patch B1a/B1b (§1); backup mechanics dry-verified against the live stack (container name, admin role, password-file path all confirmed working via today's SELECT-only queries) |
| 6 | Browser acceptance runtime | ✅ Fixed by patch B2 (docker pattern); no host Playwright needed |
| 7 | GitHub gate assets | ✅ Clone at `/opt/operqon-r2-github` (HEAD = approved commit), `/etc/operqon/r2-approved-github-commit` in place — gate re-verify is runnable as §4 step 7 |
| 8 | Owner role identities exist | ✅ All six Keycloak users exist and are enabled: `operqon-identity`, `operqon-approver`, `operqon-billing`, `operqon-pricing`, `operqon-provisioner`, `operqon-billing-approver` |

### 3b. Assad-only pending ⏳
| # | Item | Verified state |
|---|---|---|
| 9 | **First-login password + TOTP for the six owner role logins** | ⏳ **NOT done for any of the six.** Keycloak Admin API (read-only, today): every one of `operqon-identity / -approver / -billing / -pricing / -provisioner / -billing-approver` still has `requiredActions = ['CONFIGURE_TOTP', 'UPDATE_PASSWORD']`. Only Assad can do these (passwords/MFA are his; Muse holds none). Needed only if the R4.1 acceptance is to run against the **owner** logins — see item 10's alternative |

### 3c. Not ready — decision/prep still needed ⚠️
| # | Item | Verified state |
|---|---|---|
| 10 | **Seven-role E2E env file for R4.1** | ⚠️ **Does not exist.** `/root/operqon-r4-e2e.env` (mode 600, created by the main chat's R4 engineer) contains USER/PASSWORD/TOTP_SECRET for **six** roles — but for dedicated **test accounts** `e2e-r4-{operator,identity,approver,billing,pricing,provisioner}@operqon.cloud`, whose first-logins are already completed (Keycloak: `requiredActions = []`). It has **no BILLING_APPROVER triple** (no `e2e-r4-billing-approver` account exists either) and **none of the six `OPERQON_R41_*` fixture vars**. Two completion paths: (A) test-account path — create `e2e-r4-billing-approver`, complete its first login, extend the env file with its triple + fixtures (all Claude-side, no Assad dependency); (B) owner-login path — Assad completes item 9 for all six owner logins **plus** a billing_approver owner login, and a fresh 7-role env file is built from those. Path A matches the precedent the R4 engineer already set and unblocks deploy without waiting on item 9; the owner logins remain for Assad's own console use and the human-reviewed demo2 workflow |
| 11 | **Four compose env exports** | ⚠️ **Not stored anywhere on the VPS** — verified: not in `/root/.bashrc` or `/root/.profile`, not in any env file under `/root`, `/etc/operqon`, or the deploy dirs (only requirement checks in scripts and docs mention them). Mechanism: they were **exported manually in the R3 deploy shell**. Deploy-day action: export the same R3 values in the deploy shell before running deploy-r41.sh — `OPERQON_CUSTOMER_ISSUER`, `OPERQON_CUSTOMER_AUDIENCE`, `OPERQON_CUSTOMER_CLIENT_ID`, `OPERQON_FRAPPE_OIDC_CLIENT_ID` (deploy-r41.sh does not check them; compose `${VAR:?}` hard-fails at the build step). Values are configuration identifiers from the R3 deploy (issuer per the pattern enforced in deploy-r3.sh), not new secrets |
| 12 | Test-customer E2E credentials (`OPERQON_E2E_EMAIL` / `OPERQON_E2E_PASSWORD`) | ⚠️ Must be exported in the deploy shell (R3 customer browser regression); not present in the r4 env file (which holds provider-role creds only). Source: the dedicated test customer used by the R3 acceptance — re-export at deploy time |

### 3d. Deploy-time actions (created during the deploy window, by design)
| # | Item | Note |
|---|---|---|
| 13 | Two disposable bank-notice fixtures + six `OPERQON_R41_*` vars | Production currently has **0** `pending_verification` notices (verified today) — no fixtures exist to reuse, and none were created (read-only prep). At deploy time, **after** migrations run (or via the customer flow for a test tenant against issued offline invoices), create two real pending notices on a test tenant: one to verify, one to reject; set `OPERQON_R41_VERIFY_NOTICE_ID`, `OPERQON_R41_REJECT_NOTICE_ID`, `OPERQON_R41_BANK_ACCOUNT_ALIAS`, `OPERQON_R41_BANK_REFERENCE` (must match the verify notice's `bank_transaction_reference` and invoice amount/currency), `OPERQON_R41_BANK_STATEMENT_SHA256` (64-hex), `OPERQON_R41_REJECTION_REASON` (≥5 chars) in the env file. Because deploy-r41.sh runs acceptance itself, the practical order is: run deploy with acceptance expected to pause at the fixture gate only if fixtures are pre-seeded via DB/customer flow for the test tenant **before** deploy (notices can be created pre-migration too — the `customer_payment_notices` table and pending flow exist at 0007; the verify/reject *endpoints* arrive with the migration, the notices themselves don't depend on 0008). Preferred: create both notices via the customer portal flow for the test tenant before deploy |
| 14 | Pre-deploy DB backup | Run `scripts/backup-provider-db-r41.sh` as §4 step 1 (script is new; first live run is deploy day — it fails closed by design) |
| 15 | Disposable-PG migration rehearsal | §4 step 2 — mandatory gate (see §2 residual risk) |

---

## 4. Deploy-day step sequence (exact order)

**Pre-window (shell setup, no system change):**
0. Open the deploy shell on the VPS as root. Export the four compose vars (item 11) and `OPERQON_E2E_EMAIL` / `OPERQON_E2E_PASSWORD` (item 12). Set `OPERQON_R4_E2E_ENV_FILE` to the completed seven-role env file (item 10 — path A or B decided and built beforehand). Confirm the two fixture notices exist as `pending_verification` on the test tenant and the six `OPERQON_R41_*` vars are in the env file (item 13). Upload/extract the **patched** R4.1 tree (§1) as the release dir; confirm the three patched files are the patched versions (README correction note present).

**Window:**
1. **Backup** — `bash scripts/backup-provider-db-r41.sh`. Gate: prints `DB BACKUP COMPLETE` with a path under `/var/backups/operqon-provider-r2/`; record the path (rollback argument 1). Any STOP → abort window, nothing has changed.
2. **Rehearsal (mandatory gate)** — disposable PG on the VPS (deploy-r3.sh pattern): start a throwaway `postgres:16-alpine` container, restore the step-1 backup into it, create role `operqon_api` if the restore requires it for grants, run the release's migrate path against it (`OPERQON_DB_ADMIN_PASSWORD_FILE` pointing at a rehearsal secret, host = the disposable container), verify `alembic_version = 0009_country_pricing` and spot-check `country_plan_prices` exists + notice constraints present. Discard the container. Any failure → abort; production untouched.
3. **Snapshot** — deploy-r41.sh takes its own source snapshot (`/root/operqon-r41.XXXXXX`, recorded in `/root/operqon-r41.latest`) as its first mutating-adjacent step; no manual action beyond noting the path from its output.
4. **Deploy** — `bash scripts/deploy-r41.sh` from the release dir. It re-verifies the manifest, merchant.env, readyz on 18090/18089, and the seven-role env gate; installs the 8 files; runs containerised JS checks + the locked-down full test suite; builds api+migrate images; runs `alembic upgrade head` (**0007 → 0008 → 0009 on production**); force-recreates api; waits for readyz; installs console files + acceptance scripts. **Watch item:** unlike R4 there is no nginx reload after the console install — after deploy, confirm `https://control.operqon.cloud/tenants.html` serves the new build (bank-claims panel present) before acceptance; if the old page is served, reload nginx inside `operqon_owner_console_preview-console-1` (`nginx -t && nginx -s reload`, the R4 rollback's mechanism) as a manual step. On any deploy failure the EXIT trap restores source automatically — but if the migration already ran, the DB stays at 0009 (forward-only; schema is additive/backward-compatible with R4 code by construction); full DB rollback, if ever required, is `bash scripts/rollback-r41.sh <step-1 backup path>`.
5. **Acceptance** — deploy-r41.sh runs `acceptance-r41.sh` itself (HTTP checks → 7-role MFA browser acceptance incl. live verify + reject on the fixtures → R3 customer regression). Gate: final line `R4.1 OWNER CONSOLE + CUSTOMER BROWSER ACCEPTANCE: PASS`. If acceptance alone fails, fix forward or roll back with step 4's rollback command — do not re-run deploy blindly.
6. **Post-acceptance owner evidence (outside the script)** — the human-reviewed demo2 mutation workflow (review → approve → pricing entry via the new per-country PK flow → provisioning) and entry of the decided PKR price set **only** via the billing → pricing_approver country-proposal flow. Never seed prices.
7. **Gate re-verify** — push the deployed R4.1 state to GitHub `release/operqon-provider-r2` (the still-owed R4-state reconciliation is subsumed: the tree going up is the post-R4.1 tree; snapshot commits should still record the R3→R4.1 delta honestly), regenerate manifests, update `/etc/operqon/r2-approved-github-commit` to the new head, and run `scripts/verify-github-source.sh` on the VPS → expect PASS (deployed tree == GitHub subtree, manifests byte-identical).

---

## 5. Coordination notes (read before scheduling)

- **The main chat's R4 deploy did NOT succeed and R4 is not live.** Four attempts are logged (`/root/r4-deploy.log` … `r4-deploy4.log`); the last ended 2026-11-06 17:42:12 UTC failing its browser acceptance with `ModuleNotFoundError: No module named 'playwright'` (host python — the B2 failure mode, one release earlier) followed by `R4 frontend rollback restored; no database changes`. Verified consequences: no `/root/operqon-r4.latest`; the live console dir is byte-identical to the R4 snapshot's pre-deploy copy (`tenants.html` sha256 `091c7a17…` in both); the deployed source tree matches the GitHub-approved R3 manifest. **R4.1 supersedes R4** (it is the R4 tree + corrections), so deploy proceeds from the clean R3 baseline — no separate R4 redeploy is needed or wanted.
- **Two-chat collision risk already materialised once today** (the side chat's gate work and the main chat's deploy touched the same tree concurrently). Deploy-day work for R4.1 must be single-threaded: one operator, one shell, no parallel VPS work from any other chat/session during the window.
- Assad's six **owner** role logins remain untouched by all of the above — their first-login setup (item 9) is still his to do whenever he chooses; with item 10 path A it is **not** a deploy blocker.

---

## 6. What remains blocked after this prep

1. Item 10 decision + build (test-account path A is fully Claude-side: create `e2e-r4-billing-approver`, complete first login, extend env file — a Keycloak *write*, outside this read-only prep's mandate).
2. Item 13 fixtures (deploy-time creation against a test tenant).
3. Assad's item 9 first-logins — only if path B is chosen, or independently for his own console use / the demo2 human-reviewed workflow.
4. The deploy itself (explicitly out of scope for this prep; sequence in §4).
