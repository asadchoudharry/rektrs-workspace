# BUILD REPORT — Wave 2C-B API amendment (staging wave)

**Built:** 2026-11-08 · **Builder:** API builder lane (local build complete; **staging swap NOT executed by this lane** — see §6)
**Scope:** one additive family-readable endpoint that closes the Wave 2 wiring lane's **flag 2**: Connect has no version-notice source because the API-230 slice (`staffapi/appVersions`) is staff-session-only and no family route exists. This amendment is the family half of that slice (rider D-W2-5a), built on the Familydocs rails proven in Wave 2C-A (checker spot-gate PASS-WITH-NOTES).
**Master:** `~/workspace/iqrs-api/staff-ext/Familydocs.php` (amended in place; pristine baseline kept as `Familydocs.php.pre-wave2cb`)
**Battery:** `~/workspace/iqrs-api/staff-ext/test-wave2cb-api-staging.sh` (written; **run pending the swap**, §7)
**Rehearsal:** `~/workspace/iqrs-api/staff-ext/rehearse-wave2cb-appversion.php` (throwaway local proof of the configured:true logic, §5)

---

## 1. Files

| File | Before | After |
|---|---|---|
| Familydocs.php | 26,322 B · md5 `3884308c5d876d55090e4bf8ec6970bf` (the deployed 2C-A master) | **30,067 B · md5 `fea360933c7e16f5dc0221b74923cb1f`** |
| Staffapi.php | 570,998 B · md5 `5a9be05adacec777a1f214a71356c6a4` | **UNTOUCHED** — byte-identical |
| Staffsync.php | 151,515 B · md5 `ecc33f6047dd660218cb1797d5579651` | **UNTOUCHED** — byte-identical |

**Additivity:** the Familydocs diff against `Familydocs.php.pre-wave2cb` (md5-verified copy of the deployed master) is **+73 lines / −0 lines** — one contiguous inserted section (the `appVersion` method + its `table_exists` helper + their comments) between `fileOpen()` and the kinds section. No existing line is edited — the class header still documents `fileOpen` only, deliberately: the new section carries its own documentation so the diff stays purely additive. No vendor file is touched. `php -l` clean on all three files (PHP 8.3.6).

## 2. Placement — why inside Familydocs

Familydocs is the family-session controller: every family-door extension read lives behind its guard. The alternatives were weighed:

- **A separate tiny controller** would add a second file to the swap manifest (and a second preflight/backup pair) for one 30-line read, with no separation gain — the read shares Familydocs' guard, its session resolution (`family_user()`), and its reader.
- **Inside Familydocs** the new method reuses the proven guard preamble verbatim and keeps the family surface in the one file the coordinator already swaps under a known manifest.

The method is document-adjacent only in the sense that it serves the same signed-in family reader; it reads no documents and no per-student data.

## 3. The endpoint — `POST /api/familydocs/appVersion`

**Request:** `{}` (no parameters — the staff slice's shape).

**Guard — the vendor's own machinery, exactly as `fileOpen`:** POST only (else HTTP 400, the extension shape) → `Auth_model::check_auth_client()` (failure = the vendor's HTTP 200 + `{"status":0,"message":"Unauthorized."}`) → `Auth_model::auth()` against `users_authentication` (its own 401 JSON on failure/expiry) → the session user resolved by Familydocs' `family_user()` (role must be `student` or `parent`, else 401). A **staff token can never open this door** (staff ids have no `users_authentication` row — the same fact the 2C-A checker proved at `fileOpen`). Any signed-in student or parent may read the answer; it carries no per-student data, so no ownership step applies.

**Response** (HTTP 200): `{"status":1,"message":"Successfully.","record":{...}}` — the staff slice's envelope, with the record scoped to the family app:

```json
{ "configured": false, "connect": null, "checked_at": "2026-11-08 00:12:34" }
```

When a `connect` row exists in `api_app_versions`, `connect` is the per-app entry **field-for-field as the staff slice defines it** — same keys, same order, same casts:

```json
{ "latest_version_code": 23, "latest_version_name": "2.12",
  "min_supported_code": 20, "store_url": "…", "message": "…" }
```

and `configured` becomes `true`. The loop, the field set, the `(int)` casts and the `checked_at` are mirrored line-for-line from `Staffapi::appVersions` (Staffapi.php:9755–9783); the missing-table test is the staff slice's own `table_exists` (`SHOW TABLES LIKE 'api_app_versions'`, Staffapi.php:1451–1454), mirrored as a private helper in Familydocs.

### The one deliberate scoping, named

The staff record also carries a `workspace` entry; this door does **not** serve it. A family session has no business polling the staff app's version record, so the family record is `{configured, connect, checked_at}` and `configured` means **"a connect row exists"** — for this reader, exactly what the staff flag means for its reader ("a row for an app this reader polls"). No field is invented and no staff-defined field is renamed; the only difference from the staff payload is the omission of the other app's entry. The battery (§7) pins this contract both ways: the family record's key set must equal the staff record's key set minus `workspace`, and the family `connect` entry must agree with the staff slice's `connect` entry read live in the same run.

## 4. Honesty — `configured: false` until the office wants notices

The `api_app_versions` table **does not exist on staging today** (the 2A report's fixture F5; creating it is an office decision, and **this lane does not create it**). With the table absent, the `SHOW TABLES` probe answers false and the endpoint returns `configured: false` + `connect: null` with **no error** — the staff slice's exact behaviour, so Connect shows no version notice, which is the truthful state until the office creates and fills the table (F5 DDL in BUILD-REPORT-wave2a-api.md §8). Once a `connect` row exists, the same code answers `configured: true` with that row — no further server change is ever needed for the notice to light up.

## 5. Self-checks performed (local)

- `php -l` clean: Familydocs.php (amended), Staffapi.php, Staffsync.php (both untouched, md5s re-verified after the build).
- Additivity: `diff Familydocs.php.pre-wave2cb Familydocs.php` = **73 added / 0 removed** lines, a single insertion hunk.
- Column audit: the method reads only the F5 DDL columns (`app`, `latest_version_code`, `latest_version_name`, `min_supported_code`, `store_url`, `message`) — the same set the staff slice reads; nothing else is queried.
- **Configured:true rehearsal (local, shipped bytes):** `rehearse-wave2cb-appversion.php` extracts `appVersion()` + `table_exists()` byte-for-byte from the built master and executes them against stub framework neighbours (input / auth_model / db / json_output), with fixture rows in the F5 shape (MySQL string values, so the casts are exercised). **13/13 checks PASS:** (A) table missing → `configured:false`, `connect:null`, record keys exactly `{configured, connect, checked_at}`; (B) workspace + connect + unknown-app rows → `configured:true`, the connect entry field-for-field with ints cast, no `workspace` key on the family record; (C) workspace row only → `configured:false`; (D) a bare connect row with NULL columns → `configured:true` with nulls preserved.
  **What this does and does not prove, plainly:** it proves the *shipped logic* on both paths. It is **not** a live staging proof of the true path — this lane cannot create or drop tables on staging (no SQL channel; the browser route is the coordinator's), so the live configured:true proof remains owed until the office creates the table, at which point any family read demonstrates it. The live configured:false path — staging's actual state today — is the battery's job (§7). No temporary staging table was created: there is no safe channel for this lane to create one, and inventing one was rejected rather than worked around.

## 6. Staging swap manifest (for the coordinator's browser lane — NOT executed here)

This lane is a generic subagent and cannot operate the live browser; the established route is a CEO-operated File Manager swap under the **"IQRS Hostinger" browser profile `p0b17e5065f41`**. Staging controllers folder: `staging/api/application/controllers/` under the staging site root `/home/u238632175/domains/iqrs.edu.pk/public_html/staging`.

| Step | File | Preflight (staging now) | Backup name | New size | New md5 |
|---|---|---|---|---|---|
| 1 | Familydocs.php | 26,322 B · md5 `3884308c5d876d55090e4bf8ec6970bf` — **stop if different** | `Familydocs.php.bak-2026-11-08-wave2cb` | **30,067 B** | `fea360933c7e16f5dc0221b74923cb1f` |

Staffapi.php and Staffsync.php are **not** in this manifest (untouched). Production is **not** in this manifest. Landing signal after the swap: the no-token probe `POST /api/familydocs/appVersion` flips from **404** to the guard answer **401 JSON** (`{"status":401,...}`), while `POST /api/familydocs/fileOpen` keeps answering exactly as before; then run the battery (§7).

## 7. The battery — `test-wave2cb-api-staging.sh` (written, run pending the swap)

~30 checks, on the 2C-A battery's patterns (staging-only BASE refusal; credentials via **environment only** — `ADMIN_PASSWORD`, `PARENT_PASSWORD`, `STUDENT_PASSWORD` — the script refuses to run with any unset and carries no credential values, grep-verified):

- **Guards:** no-token `appVersion` → 401 JSON (pre-swap: 404, named as "not swapped yet"); no-client-headers → the vendor refusal (HTTP 200 + status 0); GET → 400; **staff token at `appVersion` → 401** (the family door stays shut to staff sessions).
- **The mirrored contract, read live both ways:** `staffapi/appVersions` (admin session) answers with record keys `{configured, connect, workspace, checked_at}`; the family reads (parent **and** student) answer HTTP 200 with record keys **exactly** `{configured, connect, checked_at}`, `configured: false`, `connect: null`, `checked_at` present — and the family's `connect` entry **agrees byte-for-byte** with the staff slice's `connect` entry from the same run. (If the office lands F5 before the battery runs, the `configured: false` legs will fail loudly rather than silently pass — the section-4 note in the script says to inspect first; that is the intended tripwire, the same posture as the 2C-A battery's dated expectations.)
- **fileOpen regression:** a fresh **"W2CB Script"** exam fixture built through the staff API (group → exam → subject → assign Seven–Diamond (7,**13**) + Four–Daffodils (3,2) → marks for one student of each section, the diagnosis-corrected ids), then: unpublished → `file:null` + reason (publication gate intact); publish → the parent's card is a real PDF (magic bytes) and the student's own card likewise; foreign child **2397** refused identically for parent and student; nonexistent student 999999 gets the identical answer. Fixtures are left in staging clearly named ("W2CB Script").

**Run command** (credentials via env — the staging fixtures of the programme's own record):
```bash
cd ~/workspace/iqrs-api/staff-ext
ADMIN_PASSWORD=… PARENT_PASSWORD=… STUDENT_PASSWORD=… \
./test-wave2cb-api-staging.sh
```
Expected once swapped: `RESULT: PASS=… FAIL=0`. Local validation so far: `bash -n` clean; the env-refusal fires before any network call (exit 2). The battery itself is **not run by this lane** — per the 2C-A precedent it runs after the coordinator's swap lands.

## 8. What this lane does not do

- **No staging swap** (coordinator's browser lane, §6) and **no battery run** before it.
- **No `api_app_versions` table** is created anywhere — the office's decision (F5).
- **No app change:** wiring Connect's version-notice card to `familydocs/appVersion` is the apps fix build's job, after this amendment's checker spot-gate — the same sequence as 2C-A (endpoint proven first, app wiring second).
