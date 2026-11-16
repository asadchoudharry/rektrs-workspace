# BUILD REPORT — Wave 2B FIX: IQRS Workspace v2.14 (versionCode 27)

**⚠ BUILD TARGET: STAGING.** This APK points at `https://staging.iqrs.edu.pk/api/`
(ApiConfig.baseUrl → STAGING_BASE_URL; proven in the shipped dex, §3). It is the
Wave 2 device-gate build: the gate must exercise the staging-only Wave 2A
endpoints before any 2D production swap. The production-pointing build comes
only after 2D. **Do not treat this binary as a production build.**

**Lane:** Wave 2B FIX BUILDER (checker re-entry fixes for CHECKER-REPORT-wave2b.md)
**Date:** 2026-11-07 (PKT)
**Fixes exactly:** S1-1, S2-1, S2-2, S2-3, S2-4 — nothing speculative, nothing else.

## 1. The artefact

| Fact | Value |
|---|---|
| File | `IQRS-Workspace-App-v2.14.apk` in `~/workspace/your_files/iqrs-app/` |
| Size | 1,684,041 bytes |
| SHA-256 | `eadeea78fa093d9f453b4223bec2ef6e5df2f728bb6df6ce8d2e1704bf6061ed` |
| Package / version | `pk.edu.iqrs.admin` · versionCode 27 · versionName 2.14 |
| minSdk / targetSdk | 26 / 34 |
| Signature | verifies; signer cert SHA-256 `f7874c3f…462e` — **identical to v2.13** |
| Active base URL (dex-proven) | `https://staging.iqrs.edu.pk/api/` (see §3) |

## 2. Fixes, per finding

### S1-1 — Publish is now a real gate (StaffExamDetailActivity + new PublishGate)

- **New pure-logic class `api/PublishGate`** (the MarksEntryRules pattern): each
  subject settles exactly once — loaded with entered/total, or failed — and the
  first terminal result stands. Verdicts: PENDING (a register unsettled),
  BLOCKED (any register failed, or the exam has no subjects), READY (all loaded,
  no gaps), GAPS (all loaded, gaps present). Only READY/GAPS may proceed.
- **Publish button** now calls `runPublishCheck(button, true)`: it loads every
  subject's register live and settles the gate. A **cached copy never settles a
  subject** (`fromCache` deliveries are ignored for the gate), so a subject whose
  fresh count cannot be had settles as failed — an incomplete or failed check can
  no longer read as "ready" (the v2.13 defect: all loads failed → empty gap list
  → "ready" message).
- **The check sheet lists EVERY subject** with its entered/total count
  (`w2b_publish_subject_count`), names each gap in words (existing
  `w2b_publish_gap`), and shows the ready line only on READY. On BLOCKED it shows
  honest wording (`w2b_publish_blocked` / `w2b_publish_no_subjects`), names the
  subjects that could not be checked, and offers **no way forward**.
- **The only road to the write:** sheet → Continue → the existing FORM-4
  confirmation ("Publish — families will see these results") → `doPublish`.
  `publish()` no longer opens the confirmation directly. GAPS proceeds only as
  that deliberate two-step act with the gaps in view, per proposal §3.2 ("ahead
  of the existing FORM-4 confirmation; nobody publishes blind"). The standalone
  Check button runs the same check in review mode (no Continue). Unpublish is
  unchanged (the gate governs publishing only).
- **Tests:** new `PublishGateTest`, 9 tests — unrun check cannot proceed; partly
  settled cannot proceed; **every register failed is BLOCKED, never ready** (the
  shipped defect, pinned); one failure blocks an otherwise complete check; a
  zero-subject exam cannot proceed; all-complete is READY; the listing carries
  every subject with its entered/total/missing counts; the first terminal result
  stands; settle signals fire once per subject.

### S2-1 — B14 librarian pair assertion (Wave2BLayoutTest)

`libraryIsTheLibrariansFirstSlot` now also builds a capabilities map in the real
envelope shape (library/books+issue_return view, calendar_to_do_list present —
crafted in-test and labelled as such, because fixture 115's live map is empty and
cannot prove the pair) and asserts through `NavSlots.slotsFor(caps, "Librarian")`
the **ordered pair: slot 1 = LIBRARY ("Library"), slot 2 = TASKS ("Tasks")** —
not the label alone.

### S2-2 — Staging-pointing device-gate build

- `config/admin.properties`: versionCode 26 → **27**, versionName 2.13 → **2.14**,
  apkName → `IQRS-Workspace-App-v2.14.apk`. Package id unchanged.
- `ApiConfig.baseUrl()` returns `STAGING_BASE_URL` for this build, with the
  reason written in the javadoc (device gate exercises staging-only 2A endpoints;
  production-pointing returns only after 2D). Dex proof in §3.
- Note for the coordinator: ApiConfig is shared source. No Connect APK was built
  or shipped from this tree (Connect untouched, per orders); the return to a
  production-pointing baseUrl after 2D is a one-line change in that shared file.

### S2-3 — Fee check-sheet Change links (StaffFeeGroupActivity)

- **Fee-line rows** (charge type / amount / due date) no longer pass null: each
  Change link reopens the line form with the values as entered still in place
  (new `lineForm` overload carrying draft type/amount/due date) and lands focus
  on the named field — type picker for a new line; for an existing line the type
  is the form's title, so its Change lands on the first editable field (amount),
  as the code comment states.
- **Fee-group assignment rows** (group name / student id) now focus the real
  fields, exactly as group/discount rows do: `nameField.requestFocus()` and the
  assignment student field (promoted from a render-local to `assignStudentField`)
  `.requestFocus()`.

### S2-4 — Build-report errata (documentation)

A dated ERRATA section is **appended** to `BUILD-REPORT-wave2b.md` correcting
`staffapi/payroll` → `staffapi/staffPayroll` in §2 B6. The original text is
unchanged; the note is the correction of record.

## 3. Verification (all run by this lane)

- **Unit suite: OK (296 tests)** — before: OK (287). Delta: +9 PublishGateTest;
  the S2-1 layout test was strengthened in place (same count). Full suite run
  after all edits.
- **Checker harness — tree:** 0 failed check groups.
- **Checker harness — shipped APK:** 0 failed check groups; APK CHECK PASSED;
  metadata gate PASSED (package, versionCode 27, versionName 2.14, minSdk 26,
  targetSdk 34, signature verifies); banned-strings lint PASSED;
  **SRC-NOSPACER-IN-ROW PASS — 848 sites examined, 0 allowlist-excused**.
- **Dex proofs on the shipped APK:** `ApiConfig.baseUrl()` disassembles to
  `const-string "https://staging.iqrs.edu.pk/api/"` → return (the same mechanism
  the checker used to prove v2.13 production-pointing); `PublishGate` is present
  in the shipped dex.
- **Contract gate:** PASSED (dummy login rejected; unauthenticated call 401) —
  staging, as the tool is written.
- **Staging smoke, publish-gate flow (curl, read-only, fixture admin 113):**
  staffauth login status 1; `examDetail` for exam 4 ("W2A Script Monthly",
  48 students) and exam 9 ("W2B-CHK Overmax Probe", 22 students) status 1;
  `examMarksRoster` for **every subject of both exams** status 1 with the gate's
  exact inputs — Art: entered 2 / total 48; Rhymes & Activities: entered 1 /
  total 22 (both would verdict GAPS and be named on the sheet). No publish was
  performed and nothing was written: the smoke proves the gate's live inputs,
  and the gate's decisions are pinned by the unit tests above. (The app drives
  the sheet itself only on a device — that remains the device gate's job.)

## 4. Boundaries held

- **No production contact of any kind.** All live calls went to staging.
- **Connect app untouched:** no Connect source changes beyond the shared
  ApiConfig note in S2-2, no Connect build, the shipped Connect v2.9 binary is
  unchanged.
- Surgical diff only: StaffExamDetailActivity (publishing section),
  StaffFeeGroupActivity (line form + two check-sheet call sites + one field
  promotion), ApiConfig (baseUrl), strings.xml (5 new publish strings),
  config/admin.properties, tools/run_tests.sh (one test-class line),
  Wave2BLayoutTest (one test strengthened), PublishGate + PublishGateTest (new),
  BUILD-REPORT-wave2b.md (appended errata only).

## 5. Still owed (not this lane's to close)

- Checker spot re-entry on v2.14 (publish-gate path, suite, harness) per the
  checker's own re-entry conditions.
- The §6.4 device gate on the owner's phone — now to be run with this
  staging-pointing v2.14, per the Wave 2 sequence (device gate before 2D).
