# ChatGPT sync pack — Operqon R2.1 deploy fixes (for a NEW ERP chat)

Prepared: 2026-11-06 ~17:35 PKT by Muse (research stage).
Why: the old ERP ChatGPT chat ("Continue Development Phase") hit its maximum
conversation length after the R2.1 ZIP was delivered. All of Muse's deploy-script
fixes + the deployed R2 acceptance.sh still need syncing into ChatGPT's master
copy, and that sync must now go into a NEW chat in the ERP project. Assad was
told in the main chat (2026-11-06 ~17:26 PKT) that Muse will handle this.

## What to send ChatGPT (new chat, ERP project)

Short intro + the fix list below. Keep each message short — long replies from
ChatGPT have twice died at delivery with "Message delivery timed out" (R2 and
R2.1). Attach the two files named under "Files to attach" once fetched.

### Fix 1 — merchant.env preflight checked the wrong path
- The deploy script checked `$ROOT/config/merchant.env`; the real file is
  `$ROOT/deploy/config/merchant.env` (exists, 785 bytes, gateway variable
  names present; values were never read or reported).
- Fix: point the preflight at `deploy/config/merchant.env`.

### Fix 2 — overlay dirs created 0700 broke the test container
- The overlay's `install -D` under the script's umask 077 created new
  tests/fixtures directories as 0700, so the non-root test container failed
  collection with PermissionError on tests/fixtures.
- Fix: normalize overlay directory permissions to 755 after install
  (`find "$ROOT/app" "$ROOT/alembic" "$ROOT/tests" "$ROOT/frontend" -type d -exec chmod 755 {} +`).
- Local patch helper: `~/workspace/patch_intake_deploy.py`

### Fix 3 — test image build reused a stale cached layer
- The Docker test-image build reused a cached COPY layer from the
  broken-permissions run, so Fix 2 did not take effect until the build was
  made `--no-cache` (proven by reproducing 53 passed / 2 skipped in a
  hand-built scratch copy first).
- Fix: `docker build --pull --no-cache -f "$ROOT/Dockerfile.test" ...`
- Local patch helper: `~/workspace/patch_intake_deploy2.py`

### Fix 4 — JS syntax check assumed host Node.js (host has none)
- Fix: run the check in a container —
  `docker run --rm -v "$PORTAL/assets:/portal-assets:ro" node:22-alpine node --check /portal-assets/request-access.mjs`
  (same check, no host install).
- Local patch helper: `~/workspace/patch_intake_deploy3.py`

### Fix 5 — readiness window too short (10 probes)
- Fix: widen to 30 probes (`for _ in $(seq 1 30); do`).
- Local patch helper: `~/workspace/patch_intake_deploy4.py`

### Fix 6 — readiness probe missing its closing `]` (the root cause)
- The line read `[ "$(http_code http://127.0.0.1:18090/readyz)" = 200; then`
  — the missing `]` made the test error on every iteration ("[: missing `]'"),
  so every deploy declared "API did not become ready" and rolled back even
  though the R2.1 API was actually up (verified healthy three separate ways,
  readyz 200 in ~8s).
- Fix: `[ "$(http_code http://127.0.0.1:18090/readyz)" = 200 ]; then ready=1; break; fi`
- Local patch helper: `~/workspace/patch_intake_deploy5.py`

### Result of the patched deploy (evidence the fixes work)
- Final patched `scripts/deploy-public-intake.sh` sha256:
  `689aaa75837bdd18d06517483273c62ee418591a32d04d92e5ff5ff5422710b6`
- R2.1 deployed LIVE ~5:15 PM PKT 2026-11-06 on 127.0.0.1:18090
  (image operqon/provider-api:r2.1-public-intake); migration 0006 applied
  additively; backup `/root/operqon-public-intake-r21.e8Fz6M`;
  deploy acceptance "PUBLIC INTAKE ACCEPTANCE: PASS"; tests 53 passed / 2 skipped.
- Live verification passed independently: request-access.html 200, one real
  POST created exactly one "requested" tenant (202), duplicate POST 409,
  non-intake /api/* 404, portal stage "public-intake".

### acceptance.sh — byte-for-byte master-copy match (ChatGPT's own request)
- ChatGPT's Corrected4 master acceptance.sh already contains the same
  GET-vs-POST claim-check fix functionally, but hashes differ:
  Corrected4 `5ea8818d…20602a55` vs VPS-deployed `8ff7a9f8…9639c35`.
- ChatGPT asked Muse to upload the actual deployed acceptance.sh so its
  master copy can match byte-for-byte. Send the deployed file with this sync.

### Master-copy correction still owed (pricing catalogue)
- The seeded plan catalogue returned by the public GET still shows currency
  SAR, trial_days 14 and tiers Starter/Growth/Enterprise — NOT Assad's approved
  pricing (multi-currency per country; PKR Starter 7,500/mo, yearly 75,000;
  Growth 9,999/mo; Business 19,999/mo; tax-excluded; trial 3 DAYS).
- Prices are null/unapproved so nothing wrong is displayed publicly, but the
  master copy should carry the approved tiers/trial/currency. (The values
  themselves enter R2 through its authenticated pricing-proposal/approver flow
  at E2E/cutover, not by seeding.)

## Files to attach (fetch at delivery — NOT yet fetched)
- Patched deploy script from the VPS:
  `/root/Operqon_Public_Intake_R21/operqon-provider-r2/scripts/deploy-public-intake.sh`
  (verify sha256 = 689aaa75… above after fetching).
- Deployed R2 acceptance.sh from the VPS — likely path:
  `/opt/operqon-provider-r2/scripts/acceptance.sh`
  (verify sha256 starts 8ff7a9f8… and ends …9639c35; confirm the exact path on
  the VPS, it was not re-verified in this research stage).
- Local patch helpers already on disk: `~/workspace/patch_intake_deploy*.py`
  (also copied to /root/ on the VPS).

## Limits of this preparation
- VPS SSH was NOT reachable from this research stage (egress blocked:
  proxy CONNECT 403), so neither file above was fetched or re-hashed here.
  The main agent must fetch them over SSH with `~/workspace/scripts/rssh.sh`
  before sending.
- Do NOT paste secrets: merchant.env values were never read and must not be
  included; only file paths and variable names.
