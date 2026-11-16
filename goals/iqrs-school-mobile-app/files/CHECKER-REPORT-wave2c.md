# CHECKER REPORT — Wave 2C: IQRS Connect v2.10

**Verdict: REJECT — one S1.** Everything else in the wave verifies, including all
three owner commitments live on staging. The S1 is small and precisely located
(four route strings), but it leaves an owner-approved feature dead against the
real service, and this programme does not call a wave verified with an S1 open
(same standard as the Wave 2B v2.13 reject).

**Artefact:** `IQRS-Connect-App-v2.10.apk` — 1,614,409 B, sha256
`98e228aed77d943f39823a78957d14ba573579daee26d793a1ad33c4603b2930`,
versionCode 21, package `pk.edu.iqrs.family` (all re-measured by the Checker).
**Checker pass:** 2026-11-07, 18:02–18:07 UTC, staging only, family fixtures only.

---

## S1-1 — The module-switch catalog is wired to four routes that do not exist

`FamilyRepository.loadModuleCatalog` (src, lines 1331–1334) POSTs to:

- `webservice/getELearningStatus`
- `webservice/getAcademicStatus`
- `webservice/getCommunicateStatus`
- `webservice/getOthersStatus`

None of these routes exists on the service. Proven three ways:

1. **Live (staging, family token, the app's own request shape `{"user":"parent"}`):**
   all four return the CodeIgniter 404 page. Final side-by-side at 18:06 UTC:
   `getstudentbehaviour` → **200**, `getAcademicStatus` → **404**,
   `getAcademicsModuleStatus` → **200**.
2. **Vendor source:** the staging `Webservice.php` declares only
   `getELearningModuleStatus`, `getAcademicsModuleStatus`,
   `getCommunicateModuleStatus`, `getOthersModuleStatus`; a case-insensitive
   search of the whole staging API tree finds no other variant, and `routes.php`
   carries no alias.
3. **The real routes answer:** all four `*ModuleStatus` calls return JSON
   `module_list` payloads that are **byte-identical to the pinned fixtures**
   (`w2c_modules_*.json`), with every switch ON (25 modules, none off).

**Why the tests did not catch it:** the mapper and its tests are correct — the
fixtures are genuine captures, but they were captured from the real
`*ModuleStatus` routes while the app was wired to different names. The mapper
was verified; the wiring was never live-proven.

**Blast radius:** `loadModuleCatalog` has exactly three consumers —
MoreScreen's not-set-up section (EMPTY-4, decision D-W2-1a), and the
known-off gates in `BehaviourActivity` and `VisitorsActivity`. With all four
calls 404ing, `answered == 0` on every run, so:

- The D-W2-1a not-set-up section can **never** populate from live data, on any
  install. If the school turns a module off, the app will never learn it.
- Behaviour and Visitors fail **open** instead of showing their not-set-up
  screens (the designed fallback for "unknown" — safe, but the known-off
  state is unreachable).

**Why this is not visible today:** on staging every switch is ON, so the
correct outcome (section renders nothing, gates open) coincides with the
failure outcome. The device gate would not catch it either, for the same
reason. It is a silent dead feature of exactly the kind the Wave 2A/2B
checkers were created to catch.

**Remedy (builder's, not the Checker's):** correct the four strings to the
`*ModuleStatus` names, re-run the suite (fixtures already match the real
routes), live re-probe, checker re-entry. The build report's §1/§2 should
also be corrected: the service data was probed, the app's own calls were not.

## S2 findings

- **S2-1 — Build-report quote imprecision (G-2).** §4 quotes the fileOpen
  refusal body as `{"status":401,"message":"Unauthorized."}`. The Checker's
  live probe returned **HTTP 401** with body
  `{"status":0,"message":"Unauthorized."}`. The gap is real; the quote is not
  exact. (Same class as Wave 2B's S2-4.)
- **S2-2 — Observation for the flaw register (not a build defect).** The
  stored offline-payment receipt is served from the vendor's public
  `uploads/offline_payments/` path without authentication (the Checker's
  bare curl received HTTP 200, image/png). This is the vendor platform's
  standing uploads posture, already recorded in the web audit; the app rides
  the vendor's own path exactly as the school's web panel does. Recorded so
  the register carries it, not graded against this build.

## What passed — independently verified

**Harness and suite (Check 1).** Unit suite re-run by the Checker:
**OK (322 tests)** — the builder's count exactly. Checker harness re-run on
tree + shipped Connect v2.10 (with Workspace v2.14 as second input):
**0 failed check groups**; source checks ALL PASS incl.
**SRC-NOSPACER-IN-ROW — 899 sites examined, 0 violations, 0 allowlist-excused**;
banned-strings lint PASSED; metadata gate PASSED on both APKs.

**Commitment 1 — Behaviour (live).** `behaviour_score` = **53**, and the
Check
...[truncated 4871 chars]

---

## RE-ENTRY — IQRS Connect v2.11 (Wave 2C fix build)

**Verdict: PASS-WITH-NOTES — no S1, no open S2 against this build. Wave 2C is
CLEARED for the §6.4 device gate.** The one note carried forward is the
Workspace-side route debt (item 3 below), which is explicitly not graded
against 2C and is owned by the separate Workspace fix lane (v2.15).

**Artefact re-measured by the Checker:** `IQRS-Connect-App-v2.11.apk` —
1,614,409 B, sha256
`8faef355ec0b39b0b95580a50f77a1580ffda80a10fc483cadb0949c180ca6b2`,
versionCode 22, package `pk.edu.iqrs.family`, signer certificate SHA-256
`f7874c3f…462e` — identical to v2.10 (apksigner, both files re-run).
**Checker pass:** 2026-11-07, staging only, family fixtures only; no
production contact; nothing fixed by the Checker.

### 1. S1-1 — CLOSED, proven three ways on the shipped artefact

- **Live (staging, parent fixture session, the app's own request shape
  `{"user":"parent"}` with User-ID + Authorization headers):** all four real
  routes answer **HTTP 200** — `getELearningModuleStatus` (8 modules),
  `getAcademicsModuleStatus` (8), `getCommunicateModuleStatus` (1),
  `getOthersModuleStatus` (8) — **25 modules, every switch ON**, and each
  payload is **identical to its pinned fixture** (`w2c_modules_*.json`,
  deep-compared). The four old names, same session and shape, all return
  **HTTP 404**. On staging's all-on data the correct outcome now comes from
  live data, not from the failure coincidence that hid v2.10's defect.
- **Source:** `FamilyRepository.java` lines 1331–1334 call the four
  `*ModuleStatus` names; no occurrence of any old name remains in the tree.
- **Shipped dex:** the v2.11 `classes.dex` contains all four
  `webservice/*ModuleStatus` strings and none of the four old names
  (strings dump inspected by the Checker).

### 2. SRC-ROUTE-LIVE guard — VERIFIED (implementation, provenance, teeth)

- **Implementation read in full** (`tools/contract_check.py`): route
  literals are regex-extracted from every Java source
  (`webservice/ staffapi/ staffsync/ auth/ staffauth/`); live mode probes
  each with an unauthenticated POST (vendor headers, empty body) where
  exists = HTTP ≠ 404 (the auth layer refuses real routes with 401 before
  controller logic runs, so the probe is read-only even for write routes)
  and writes the captured manifest; offline mode (`--use-manifest`, harness
  step 5b) additionally refuses a manifest whose base is not the staging
  base. The mechanism verifies the wiring itself — the exact half of the
  contract v2.10's tests never exercised.
- **Manifest provenance confirmed:** `tools/checker/route_manifest.json`
  carries base `https://staging.iqrs.edu.pk/api/`, probe description, and
  `probed_at 2026-11-07T18:10:38Z`, as documented in the fix report; its
  200 route keys are **exactly** the 200 route literals extractable from
  the current sources (set-compared both ways, no extras, no omissions) —
  consistent with a live capture from this tree, not a hand-written list.
- **Fail-before reproduced by the Checker:** a scratch copy of the sources
  with the four v2.10 strings restored in `FamilyRepository.java`, checked
  against the captured manifest → **CONTRACT GATE: FAILED (exit 1)**,
  naming all four module routes as absent from the manifest (alongside the
  four known staff strings of item 3).
- **Family surface pass:** all **66 family routes** (`webservice/*` +
  `auth/login`) stand `exists=true` in the manifest, and the Checker's own
  authenticated re-probes of the four S1 routes agree with it live (item 1).

### 3. Carried S-note — Workspace dead write routes (NOT graded against 2C)

The guard also names four Workspace-side routes that 404. Evidence,
independently re-confirmed by the Checker today: the manifest records all
four at **http 404**, and fresh unauthenticated probes return **404** for
`staffapi/incomeSave`, `staffapi/expenseSave`, `staffapi/inventoryIssue`,
`staffapi/inventoryReturn`, while their real `staffsync/` counterparts
answer **401** (they exist, behind the sync envelope). The fix report's
analysis stands unrefuted: the methods live only in `Staffsync.php`, the
sync gate demands `client_txn_id`, and `inventoryIssue` additionally
mismatches fields (`issue_type`/`issue_to`) — so Finance add-income /
add-expense and Inventory issue/return in Workspace have been dead against
the real service since Wave 2B, the same silent defect class as S1-1.
**Disposition:** S1-class on the Workspace side; owned by the separate
Workspace fix lane (v2.15: route prefix + sync envelope + field alignment
+ live write battery, then its own checker re-entry). Until that lane
lands, harness step 5b fails by name on exactly these four strings — the
guard holding the debt visible. This note is carried, not charged to 2C:
the Connect family surface is fully green on its own state.

### 4. S2 closures

- **S2-1 — CLOSED.** The dated ERRATA (2026-11-07) stands appended to
  `BUILD-REPORT-wave2c.md` at line 107; the original §§1–5 above it are
  intact. It corrects all three points: the §1 route names (real
  `*ModuleStatus` names + blast radius recorded), the §2 overstatement
  (service data probed; the app's own calls were not — now live-proven),
  and the §4 G-2 quote (HTTP **401**, body
  `{"status":0,"message":"Unauthorized."}`).
- **S2-2 — RECORDED.** The fix report's §5 carries the observation
  verbatim (stored receipt served from the vendor's public
  `uploads/offline_payments/` path without authentication; vendor standing
  posture; overhaul flaw-register scope). No app change made or proposed.

### 5. Regression sweep — clean, one tolerated failure

- **Unit suite re-run by the Checker: OK (322 tests)** — the builder's
  count exactly.
- **Checker harness re-run on tree + shipped Connect v2.11 + Workspace
  v2.14: exactly 1 failed check group** — step 5b (SRC-ROUTE-LIVE, offline
  form), failing on **exactly the four Workspace strings of item 3 and
  nothing else** (196/200 source routes proven live). Every other group
  PASS: layout budgets and nav tables, source inspections incl.
  **SRC-NOSPACER-IN-ROW — 899 sites examined, 0 violations, 0
  allowlist-excused**, banned-strings lint, and both APK checks (metadata
  gate PASSED on each: Connect `pk.edu.iqrs.family` code 22 / name 2.11,
  Workspace `pk.edu.iqrs.admin` code 27 / name 2.14, INTERNET-only on
  Connect, signatures verify; dex mechanism classes and REG-DIALOG-TEXT
  present in both).
- **Target:** staging — `ApiConfig.baseUrl()` returns
  `STAGING_BASE_URL` (`https://staging.iqrs.edu.pk/api/`, also present in
  the shipped dex), per the wave plan for the device-gate build.
- **Workspace artefact untouched:** v2.14 sha256 re-measured
  `eadeea78…61ed` — byte-identical to the Wave 2B re-entry record.

### Housekeeping note on this file

The v2.10 portion of this report above was truncated mid-sentence in its
original write (the file literally ends the "What passed" section with an
embedded truncation marker). The verdict and the S1/S2 findings graded by
this re-entry are intact at the head of the file; only the tail of the
v2.10 pass-detail narrative is unrecoverable from this file. Recorded so
no later reader mistakes the cut for a finding against either build.

**Bottom line:** S1-1 is closed with live proof on the shipped artefact,
the permanent guard has teeth and a genuine captured manifest, both S2s
are closed or carried as designed, and the only red anywhere in the sweep
is the four-string Workspace debt that belongs to the v2.15 lane.
**Wave 2C (Connect v2.11) is cleared for the §6.4 device gate.**
