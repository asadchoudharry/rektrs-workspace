# CHECKER REPORT — Wave 0 RE-ENTRY (NAV-3 rebuild)

Date: 2026-11-07 · Checker: independent Checker role (FEATURE-AND-DESIGN-PLAN §6.1) — not the
builder of this rebuild. This is the re-entry pass ordered by `CHECKER-REPORT-wave0.md`
(verdict REJECT, one S1) against its four re-entry conditions.
Scope: the Wave 0 visual-repair slice only (bottom nav, Home wallet strip, dialog themes).
Wave 0's other items (API-00, API-01, staging fixtures) remain separate deliverables, not
covered or approved by this report.

## Builds checked

| App | File | versionCode / name | SHA-256 |
|---|---|---|---|
| IQRS Connect | `IQRS-Connect-App-v2.9.apk` (1,454,514 B) | 20 / 2.9, `pk.edu.iqrs.family` | `9b4a49bc73938d893bf3aa009f283d0ddddd0c87beb4b9fb712972cf6e57355e` |
| IQRS Workspace | `IQRS-Workspace-App-v2.10.apk` (1,397,170 B) | 23 / 2.10, `pk.edu.iqrs.admin` | `3c15c604c166ee11d51721ec71e2619097fca231c6e0c181af7ef95e0ae81298` |

Hashes recomputed by the Checker from the shipped files — identical to the build report's.
Badging (Check-run `aapt2 dump badging`): labels 'IQRS Connect' / 'IQRS Workspace',
versionCodes 20/23, versionNames 2.9/2.10. Endpoint builds: none (app-only wave).
Fixtures/accounts used: none (no staging contact in this pass).

## VERDICT: **PASS**

F1 (the S1 that rejected the previous builds) is **closed by construction**, F2 and F3 are
closed, and all three founding regressions pass. Two **S2** items are recorded below as
accepted debt with named fix paths (§6.2 permits a PASS on that basis): the 320dp × font-1.3
corner (F1b — a documented physical limit, outside the baseline and outside this pass's
re-entry conditions) and a defect in the Checker harness itself (H1). **This is a harness
pass, not a phone pass** (§6.5): the §6.4 screenshot checklist has still not been executed on
a device — re-entry condition 3 remains owed on these exact APKs, and nothing in this report
upgrades the result into "works on the phone".

## Gate-by-gate

### G1 Contract — N/A (in scope: nothing to test)
App-only wave: no new or changed endpoints; the builds call only pre-existing endpoints.

### G2 Logic — PASS
Full JVM suite re-run independently by the Checker (`tools/run_tests.sh`): **OK (199 tests)** —
matches the builder's count (197 baseline + the wave's 2 new slot-model tests; the 4 amended
assertions re-pin the NAV-3 anatomy and the 84dp strip, each justified in the build report and
spot-verified by the Checker against the shipped source constants — see G3). The wave's pure
decision classes (`NavFit`, `CardPreviewLayout`) are additionally exercised by the Checker's
own real-font suite under G3.

### G3 Visual — PASS (two S2 debts recorded: F1b, F5-carried)
Founding regressions (§6.7), verified by mechanism — the Checker's own harness run from
scratch (`tools/checker/run_checker.sh`, tree level: **0 failed check groups**; budget JUnit
**OK (5 tests)**; source inspections **11/11 PASS**), plus the Checker's direct source
inspection of `BottomNav`, `NavFit` and `CardPreviewLayout`:

| Regression | Verdict | Evidence |
|---|---|---|
| REG-NAV-ATTENDANCE | **PASS** | NAV-3 anatomy confirmed in source: each destination is an equal slot (`LayoutParams(0, MATCH_PARENT, weight 1)` — LAY-NAV-1 by construction), carrying a WRAP_CONTENT column: 56×32dp indicator pill (present in both states, so selection never shifts geometry) with the 24dp icon centred, label below on a 2dp gap, `setSingleLine(true)`, bundled Jakarta 700. `NavFit` re-expressed for the anatomy: `FLOOR_SP = 10` (NAV-2's floor — the 9.5sp selection path is gone), `START_SP = 12`, item width = `max(56, label width)`, fit ⇔ widest item ≤ **its own slot** (`avail/count`). Real-font table (Check-run, exact glyph advances from jakarta-700.ttf): 360dp × 1.0 → **12.0sp**, total 278.8 of 316dp, FITS · 360dp × 1.3 → **10.0sp**, total 302.0 of 316dp, FITS — "Attendance" at the floor = 75.5dp inside its 79dp slot (3.5dp headroom, replacing the old anatomy's 0.2dp luck) · 320dp × 1.0 → **11.5sp**, FITS · 411dp × 1.0 → 12.0sp, FITS. The fit no longer depends on measure order: slots are pre-sized, so no label's survival can starve another's — the F1 mechanism is gone, not merely re-tuned. All three re-entry configurations from the first report (360 × 1.0, 360 × 1.3, 320 × 1.0, labels ≥ 10sp, complete, one line) are green. |
| REG-HOME-CARD | **PASS** | Unchanged forced-height mechanism, now at the plan's number: `CardPreviewLayout.HEIGHT_DP = 84`, sanctioned band re-set to the budget itself (`MIN 82 / MAX 86` = LAY-CARD-2's 84 ± 2). Harness: SRC-CARD-STRIP-FORCED, SRC-CARD-ASPECT-CR80, SRC-CARD-STRIP-NOSPACER, SRC-CARD-STRIP-TEXTS-1LINE, SRC-HOME-STRIP-CONDITIONAL, SRC-STAFF-CARD-CONDITIONAL all PASS — the strip renders only with card data, at exactly 84dp, and the full card keeps CR80 (LAY-CARD-1). |
| REG-DIALOG-TEXT | **PASS** | Theme pins verified in **both shipped APKs' compiled resources** by the Check-run `check_apk.sh` (textColorPrimary=@color/ink 17.8:1, textColorSecondary=@color/ink_2 8.0:1, windowBackground=@color/surface — identical rendering in both modes). |

**F1b — S2 (accepted debt, recorded). The 320dp × font 1.3 corner.** The Checker's own table
reproduces the builder's disclosed boundary exactly: at 320dp the slot is 69dp and
"Attendance" at the 10sp floor measures 75.5dp — it would clip ≈ 6.5dp on that one label.
The Checker's ruling on scope: this corner is **outside the plan's baseline** (§6.5 anchors
the matrix at 360dp, the owner's device class; the 320dp step's re-entry bar, set by the
first Checker report, was font 1.0 — now green) and **outside REG-NAV-ATTENDANCE's own
§6.7 scope** (360dp, fonts 1.0 and 1.3 — both green). It is also a genuine physical limit,
not a tuning miss: equal slots (LAY-NAV-1) + the 10sp floor (NAV-2) + the word "Attendance"
in the bundled bold typeface cannot all hold in 69dp — one plan constraint must yield, and
choosing which is a Designer/plan decision, not a builder fix. The behaviour at the corner
is the least-bad available: the floor is respected, the label stays on one line, other
destinations are unaffected (the old anatomy overflowed this corner by 71.8dp *and* failed
two baseline configurations outright). **Required follow-up (named):** before Wave 1B is
delivered, the plan must either (a) amend §6.5/LAY-NAV-2 to state which width × font-scale
combinations are guaranteed, or (b) adopt a narrow-width provision (shorter label or
non-equal slots at ≤ 320dp). Until then this corner is a known, documented limitation —
if the owner considers 320dp phones at font 1.3 in scope, this finding escalates to S1.

**F5 — S2 (carried from the first pass).** Workspace student detail renders the full card
expanded; HOME-3 wants it collapsible, default collapsed to the strip. Proportions are exact
CR80 and no founding defect recurs. Fix wave: **Wave 1B**, as recorded previously.

Screenshot states (§6.4): **not executed** — no device in the Checker's hands. Re-entry
condition 3 (`CHECKER-SCREENSHOT-CHECKLIST.md` on the §6.5 matrix, founding regressions
first) remains owed on these APKs regardless of this PASS.

### G4 Language & metadata — PASS
Banned-strings lint **15/15 PASSED** in the Checker's own harness run (incl. retired-name
checks). Metadata gate **PASSED for both APKs** (Checker-run `check_apk.sh` with this wave's
versions — see H1): packages, versionCodes 20/23, versionNames 2.9/2.10, minSdk 26 /
targetSdk 34, permissions within {INTERNET, CAMERA} (Connect INTERNET only; Workspace
INTERNET + CAMERA), **apksigner verifies**. Mechanism classes (`NavFit`, `CardPreviewLayout`,
`BottomNav`, `StudentCardView$PreviewStrip`) confirmed present in **both shipped dexes**
(Checker-run). F3 is closed within this gate's evidence: the Checker's own grep of the tree
finds **15 `AlertDialog.Builder` sites and every one passes `R.style.AlertDialogTheme`** —
including all 9 sites in the 7 files the first report named (DailyAssignments ×2,
ProfileEdit ×2, Leaves, LessonPlan, OfflinePayments, OnlineExamAttempt, Timeline);
Workspace's sites were already themed. SRC-DIALOG-SITES-THEMED: PASS.

### G5 Data truth — N/A (in scope: nothing to reconcile)
The change surface is presentation only (BottomNav, NavFit, CardPreviewLayout constant,
dialog theme arguments). No count, fee, marks or list logic is touched (Checker-verified from
the change surface in source), so there is no figure whose reconciliation this wave could break.

## H1 — S2 (harness defect, recorded against the Checker harness itself)

**The builder's process note is correct, and the hardcoding is a harness defect.**
`run_checker.sh` step 6 passes literal versionNames — `pk.edu.iqrs.family 2.8` and
`pk.edu.iqrs.admin 2.9` — to `check_apk.sh`. The Checker proved the effect directly: running
the orchestrator against these (correct) APKs produced **2 failed check groups, both solely
"FAIL: versionName mismatch"**, while every substantive check in the same run passed
(metadata fields, dex classes, theme pins, signature). The builder's workaround — invoking
`check_apk.sh` directly with 2.9/2.10 — is legitimate, changed nothing in the harness, and
the Checker independently reproduced its result (PASSED ×2). The defect does not block this
PASS, because the underlying G4 checks were run and passed against the correct expectations.
It must still be fixed: an orchestrator that cries wolf on every version bump trains its
operator to ignore failures. **Fix (named): harness maintenance before the Wave 1 checker
pass** — derive the expected versionNames from the APKs' badging (or take them as required
arguments) and delete the literals; the fixed orchestrator must then be demonstrated green
end-to-end, APKs included, as part of that wave's entry evidence.

## Re-entry conditions from the first report — disposition

1. NAV-3 nav, harness green at 360 × 1.0 / 1.3 and 320 × 1.0, labels ≥ 10sp — **MET** (G3).
2. F2 resolved (strip at 84dp or a signed budget amendment) — **MET** by conformance: the
   constant and its band now *are* the plan budget; no amendment was needed or made.
3. Screenshot checklist executed on the §6.5 matrix — **NOT MET — still owed** (no device);
   it is a delivery-to-device-verification step, not a bar to this harness PASS, and it must
   be the first thing run when these APKs reach a phone.
4. Harness re-run end-to-end on the new APKs; new CHECKER-REPORT before delivery — **MET**
   (this report; tree harness 0 failed groups, APK checks passed via `check_apk.sh` — with
   H1 recorded against the orchestrator's version literals).

## What is verified good (safe to tell the owner)

- "Attendance" — and every nav label — now fits **whole, on one line, at the plan's 10sp
  floor or above**, at the phone's size and at the accessibility font size, by slot
  construction rather than by measurement luck. The mid-word break cannot recur at any
  baseline configuration.
- The Home card strip is exactly the plan's **84dp**, still incapable of inflating, and
  still absent when there is no card data — the giant empty slab cannot recur.
- Every dialog in both apps now renders on the pinned theme (readable text by construction,
  17.8:1 / 8.0:1, verified inside the shipped APKs) — the seven unthemed Connect screens are
  closed.
- 199/199 JVM tests, 15/15 language lint, metadata + signature gates — all independently
  re-run by the Checker on the shipped artefacts.

## Outstanding after this PASS

- **Device pass (owed):** `CHECKER-SCREENSHOT-CHECKLIST.md` on these APKs (§6.5 matrix,
  founding regressions first) — until it runs, these builds are harness-verified, not
  device-verified.
- **F1b decision** (plan amendment or narrow-width provision) before Wave 1B delivery.
- **H1 fix** (harness version literals) before the Wave 1 checker pass.
- **F5** (Workspace detail collapse-to-strip) in Wave 1B.
