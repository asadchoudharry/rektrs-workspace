# BUILD REPORT — Wave 2C FIX: IQRS Connect v2.11 (checker S1-1 remedy)

**Build:** IQRS Connect **v2.11**, versionCode **22**, package `pk.edu.iqrs.family`
**APK:** `~/workspace/your_files/iqrs-app/IQRS-Connect-App-v2.11.apk` — 1,614,409 B,
sha256 `8faef355ec0b39b0b95580a50f77a1580ffda80a10fc483cadb0949c180ca6b2`
(same byte size as v2.10 by coincidence of zip alignment — different hash,
different versionCode, different dex strings; all three verified below)
**Signer:** `f7874c3f…462e` — identical to v2.10 (apksigner, both files)
**Target:** **staging** — the shipped dex contains `https://staging.iqrs.edu.pk/api/`
**Scope guard:** the Workspace app was not rebuilt, modified, or re-shipped —
`config/admin.properties` is untouched (v2.14 / code 27 stands) and the
existing v2.14 APK served only as the checker harness's second input, its
sha256 unchanged (`eadeea78…61ed`). The Familydocs / visitorSave UI was NOT
wired in this build (that lane follows the 2C-A battery, per assignment).
Production was not touched anywhere; all live work used staging + the family
fixtures only.

---

## 1. S1-1 — the four module-status route strings (FIXED, live-proven)

`FamilyRepository.loadModuleCatalog` now calls the real vendor routes,
taken from the staging vendor controller source
(`Webservice.php` lines 5176 / 5250 / 5324 / 5370) and matching the
checker's probes:

| v2.10 (404 live) | v2.11 (200 live) |
|---|---|
| `webservice/getELearningStatus` | `webservice/getELearningModuleStatus` |
| `webservice/getAcademicStatus` | `webservice/getAcademicsModuleStatus` |
| `webservice/getCommunicateStatus` | `webservice/getCommunicateModuleStatus` |
| `webservice/getOthersStatus` | `webservice/getOthersModuleStatus` |

Nothing else in the method changed — the mapper, the merge, and the
unknown-never-renders-as-off semantics were already correct (checker).

**Live proof (this lane, staging, family fixture session, the app's own
request shape `{"user":"parent"}` with User-ID + Authorization headers):**

| Route | HTTP | Modules | Payload vs pinned fixture | Switches |
|---|---|---|---|---|
| `getELearningModuleStatus` | 200 | 8 | identical | all ON |
| `getAcademicsModuleStatus` | 200 | 8 | identical | all ON |
| `getCommunicateModuleStatus` | 200 | 1 | identical | all ON |
| `getOthersModuleStatus` | 200 | 8 | identical | all ON |
| the four OLD names (same session/shape) | **404** | — | CodeIgniter 404 page | — |

So the EMPTY-4 catalogue now populates from live data: **25 modules across
the four categories, every switch ON on staging** — the proven outcome is a
correct all-on catalogue (the not-set-up section therefore correctly renders
nothing today, and the Behaviour/Visitors gates open). The off-state remains
pinned by the unit tests over the genuine captures, exactly as the checker
recorded; no staging switch was flipped for this proof.

**Shipped-dex proof:** the v2.11 dex contains all four `*ModuleStatus`
strings and none of the four old names (`strings` dump inspected).

## 2. The permanent guard — SRC-ROUTE-LIVE (contract gate extended)

The defect class was: *mapper verified against genuine fixtures, wiring
never live-proven.* The guard now verifies the wiring itself.

- `tools/contract_check.py` (Gate 2) gained check 3, **SRC-ROUTE-LIVE**:
  every endpoint route literal in the Java sources (`webservice/`,
  `staffapi/`, `staffsync/`, `auth/`, `staffauth/` — 200 unique strings)
  is live-probed against staging. The probe is an unauthenticated POST with
  the vendor headers and an empty body: the service's auth layer refuses a
  real route with 401 before any controller logic runs (read-only even for
  write routes), while a wrong name returns the CodeIgniter 404. Exists =
  HTTP ≠ 404. The original two Gate-2 checks are unchanged.
- A live run writes the **captured-route manifest**
  (`tools/checker/route_manifest.json`: base, probe timestamp, per-route
  HTTP code + exists). This lane's capture: probed **2026-11-07T18:10:38Z**.
- `run_checker.sh` gained **step 5b**: the offline form
  (`contract_check.py --use-manifest`) — every source route string must
  appear in the manifest with `exists=true`. The harness stays
  staging-independent; the manifest is refreshed by a live Gate-2 run
  whenever routes change. Documented in the harness header and
  `tools/checker/README.md`.

**Fail-before proof:** a scratch copy of the tree with the four v2.10
strings restored in `FamilyRepository.java`, checked against the
live-captured manifest → **CONTRACT GATE: FAILED (exit 1)**, naming all
four module routes as absent from the manifest. (Direct live evidence
agrees: §1's probe table, old names → 404.)

**Pass-after:** on the fixed tree, all **66 family-surface routes**
(`webservice/*` + `auth/login`) are proven live — the whole Connect scope
of the guard is green, in both the live run and the manifest form. The
gate's remaining failures are the four staff-side strings in §4, which are
a separate finding, not part of this wave's scope.

## 3. S2-1 — build-report wording (CORRECTED via dated ERRATA)

A dated ERRATA section (2026-11-07) was appended to
`BUILD-REPORT-wave2c.md`; the original text is untouched. It corrects:
§1's D-W2-1a row (the printed route names were the non-existent ones; the
real `*ModuleStatus` names and the blast radius are now recorded), §2's
probe row (service data was probed live; the app's own module-catalogue
calls were not — the part that was broken), and §4's G-2 quote (the
fileOpen refusal is HTTP **401** with body
`{"status":0,"message":"Unauthorized."}`).

## 4. NEW FINDING raised by the guard — staff-side dead writes (NOT fixed here)

The guard's first tree-wide live run caught a second instance of the same
defect class, in the Workspace sources. Four write routes called by staff
UI activities do not exist as addressed:

| App calls | Live | The real route | Why a string swap alone is NOT the fix |
|---|---|---|---|
| `staffapi/incomeSave` | 404 | `staffsync/incomeSave` | sync envelope required |
| `staffapi/expenseSave` | 404 | `staffsync/expenseSave` | sync envelope required |
| `staffapi/inventoryIssue` | 404 | `staffsync/inventoryIssue` | envelope + field mismatch |
| `staffapi/inventoryReturn` | 404 | `staffsync/inventoryReturn` | sync envelope required |

Evidence: the methods exist only in `Staffsync.php` (local master lines
2837, 2842, 3003, 3073); `Staffapi.php` has the reads (`incomeList`,
`expenseList`, `itemIssueList`) but no such saves. The sync controller's
`w2_sync_begin` refuses any call without `client_txn_id`
(`{"status":0,"message":"client_txn_id required"}`), and the app's
`postAction` calls send none. `inventoryIssue` additionally mismatches
fields: the server requires `issue_type` (`staff`/`student`) + `issue_to`
(person id); the app sends `issue_to` = the type string and `issue_to_id`
= the person id. So Finance add-income/add-expense and Inventory
issue/return have been dead against the real service since Wave 2B —
silent for the same reason S1-1 was: the failure only appears when the
write is exercised live.

**Disposition:** not fixed in this lane — the remedy (route prefix +
`client_txn_id` envelope + `issue_type`/`issue_to` alignment + a live
write battery on staging) belongs to a Workspace fix lane with its own
build and checker re-entry, exactly as S1-1 was remedied here; this
lane's scope guard forbids touching the Workspace app. Until that lane
lands, the new step-5b gate **fails by name on these four strings** in
every harness run — that is the guard holding the debt visible, not a
defect of this build. Severity for the Checker to adjudicate: it is the
S1 class (owner-visible features dead against the real service) on the
Workspace side.

## 5. S2-2 — observation for the overhaul flaw register (no code change)

Per the checker: the stored offline-payment receipt file is served from
the vendor's public `uploads/offline_payments/` path **without
authentication** (a bare unauthenticated curl received HTTP 200,
image/png). This is the vendor platform's standing uploads posture,
already recorded in the web audit; the app rides the vendor's own path
exactly as the school's web panel does. Recorded here so the overhaul
flaw register carries it against this wave too. No app change is made or
proposed in this lane — the fix, if any, is server-side (overhaul scope).

## 6. Verification evidence

| Check | Result |
|---|---|
| Unit suite (`tools/run_tests.sh`) | **OK (322 tests)** — unchanged count, as expected: the fixtures already matched the real routes; the mapper was never wrong |
| Contract gate, live (`tools/contract_check.py`) | Gate-2 checks PASS; SRC-ROUTE-LIVE **196/200 exist** — the only four failures are §4's staff-side strings; all 66 family routes exist |
| Guard fail-before (scratch, v2.10 strings) | **FAILED, exit 1**, naming the four module routes |
| Guard manifest form (real tree) | module routes proven; fails only on §4's four staff strings |
| Checker harness (tree + Connect v2.11 + Workspace v2.14) | **1 failed check group** — the new step 5b, on §4's staff strings only. All pre-existing groups PASS: layout budgets, source inspections incl. **SRC-NOSPACER-IN-ROW — 899 sites, 0 violations, 0 allowlist-excused**, banned-strings, both APK checks (metadata + dex mechanisms) |
| Metadata gate on the shipped APK | PASSED (package `pk.edu.iqrs.family`, versionCode 22, versionName 2.11, minSdk 26, targetSdk 34, INTERNET only, signature verifies) |
| Live module-catalogue probes (§1) | 4/4 routes HTTP 200, payloads fixture-identical, 25 modules all ON; 4/4 old names HTTP 404 |

## 7. Files changed in this lane

- `src/pk/edu/iqrs/app/data/FamilyRepository.java` — the four route strings (one block, nothing else)
- `config/family.properties` — versionCode 21 → 22, versionName 2.10 → 2.11, apkName
- `tools/contract_check.py` — SRC-ROUTE-LIVE check + manifest modes (Gate-2 checks 1–2 unchanged)
- `tools/checker/route_manifest.json` — NEW, captured from this lane's live probes
- `tools/checker/run_checker.sh` — step 5b wired + header documentation
- `tools/checker/README.md` — SRC-ROUTE-LIVE documented
- `BUILD-REPORT-wave2c.md` (goal files) — dated ERRATA appended; original text untouched

## 8. Still owed

- Checker re-entry on v2.11 (this lane is the builder; the verdict is the
  Checker's).
- The §4 staff-side fix lane (Workspace): route + payload alignment for
  Finance saves and Inventory issue/return, with a live write battery —
  after which step 5b goes fully green.
- The §6.4 device gate on this build, per the wave plan.
