# CHECKER REPORT — Wave 0 (visual-repair builds)

Date: 2026-11-07 · Checker: independent Checker role (FEATURE-AND-DESIGN-PLAN §6.1) — not the builder of these fixes.
Scope of this report: the two app builds of the Wave 0 repair slice (Home card slab + bottom-nav wrap).
Wave 0's other items (API-00 capabilities, API-01 academic catalogue, staging fixtures) are separate
deliverables with their own evidence and are **not** covered or approved by this report.

## Builds checked

| App | File | versionCode / name | SHA-256 |
|---|---|---|---|
| IQRS Connect | `IQRS-Connect-App-v2.8.apk` (1,454,514 B) | 19 / 2.8, `pk.edu.iqrs.family` | `50bcea2ae105aca4330a6bae46a52e5aabcaad28d19d4b769cb7244ebb88c44d` |
| IQRS Workspace | `IQRS-Workspace-App-v2.9.apk` (1,397,170 B) | 22 / 2.9, `pk.edu.iqrs.admin` | `b781df09df145f9af43db85568486e17371590e32a1f75a219095b1f6bb721f6` |

Hashes recomputed by the Checker from the shipped files — identical to the build report's.
Endpoint builds: none (app-only wave; no server file changed). Fixtures/accounts used: none (no staging contact in this pass).

## VERDICT: **REJECT**

One **S1** defect (F1) is open. Under §6.2/§6.6 a wave with any S0/S1 defect is rejected outright.
The rejection is narrow and specific — see "what is verified good" below: both defects the owner
caught are genuinely closed at the phone's default settings. What fails is the plan's own
guarantee at font scale 1.3, an explicit baseline configuration of the Checker protocol
(§6.3 LAY-NAV-2, §6.5, §6.7). The fix path already exists in the approved plan (NAV-3).

## Gate-by-gate

### G1 Contract — N/A (in scope: nothing to test)
App-only wave: no new or changed endpoints. The builds call only pre-existing endpoints.

### G2 Logic — PASS
Full JVM suite run independently by the Checker (`tools/run_tests.sh`): **OK (197 tests)** —
matches the builder's count. The wave's new pure decision classes (`NavFit`,
`CardPreviewLayout`) are additionally exercised by the Checker's own real-font suite under G3.

### G3 Visual — REJECT (one S1: F1; two S2 debts: F2, F5)
Founding regressions (§6.7), verified by mechanism — source inspection + the app's own pure
classes driven by **exact glyph advances from the bundled jakarta-700.ttf** (the Checker's
harness, `tools/checker/`; Android's `Paint.measureText` returns the shaped advance sum, and
shaping/kerning can only narrow it, so these widths are the conservative truth):

| Regression | Verdict | Evidence |
|---|---|---|
| REG-HOME-CARD | **PASS** | `PreviewStrip.onMeasure` forces its height to `CardPreviewLayout.measuredHeightPx(density)` under `EXACTLY` specs — no code path back to a taller strip (JUnit mechanism test passes at densities 1.0–4.0). The founding mechanism is gone: the strip's row gap is `Ui.hspacer`; the only `Ui.spacer` in `walletPreview` sits inside the vertical text column. Home adds the strip **only** when card data exists (`if (preview != null)`), Workspace detail likewise (`if (cardData != null)`). Strip texts are single-line. Full card forces `height = round(width × 54/85.6)` EXACTLY (LAY-CARD-1, within 0.5px rounding) in both hosts. |
| REG-NAV-ATTENDANCE | **PASS at font 1.0 · FAIL as a guarantee at font 1.3** | Font 1.0, 360dp: NavFit (real Paint measurer on device) chooses **10.0sp**; total label width **315.8dp of 316.0dp** — fits, whole words, by mechanism (`setSingleLine(true)` + content-sized items make a wrap impossible). Font 1.3: see F1. |
| REG-DIALOG-TEXT | **PASS** | `AlertDialogTheme` pins `windowBackground=@color/surface` (#FFFFFF), `textColorPrimary=@color/ink` (#14181F, **17.8:1**), `textColorSecondary=@color/ink_2` (#4A5160, **8.0:1**) — computed WCAG contrast, both ≥ 4.5:1; background pinned, so light/dark render identically. The compiled theme with exactly these pins is present in **both shipped APKs' resources** (aapt2 dump). All sign-out dialogs (Connect More + Profile, Workspace Profile, Login) construct with `R.style.AlertDialogTheme`. |

**F1 — S1 (the rejection). LAY-NAV-2 fails at font scale 1.3 on the 360dp baseline.**
Real-font arithmetic, using the mechanism's own constants (`NavFit.availDp`, item = 45dp + label):

| Config | Chosen size | Total needed | Available | Result |
|---|---|---|---|---|
| 360dp, font 1.0 | 10.0sp | 315.8dp | 316.0dp | fits (margin 0.2dp) |
| 360dp, font 1.3 | 9.5sp (floor) | **347.8dp** | 316.0dp | **overflows by 31.8dp** |
| 320dp, font 1.0 | 9.5sp (floor) | **309.0dp** | 276.0dp | **overflows by 33.0dp** |
| 320dp, font 1.3 | 9.5sp (floor) | 347.8dp | 276.0dp | overflows by 71.8dp |
| 411dp, font 1.0 | 10.5sp | 322.6dp | 367.0dp | fits |

At 360dp/font 1.3, LinearLayout measures items in order, so the first three labels survive and
the **last item ("More") is truncated** to the 44.5dp remaining of the 76.3dp it needs — a clipped
nav label, which §6.6 names an S1 broken state. "Attendance" itself survives only by measure
order — luck of position, not a layout guarantee, which is exactly what §6 exists to forbid.
The same overflow at 320dp (a §6.5 matrix configuration) at font 1.0 confirms the side-by-side
anatomy is out of room, not the numbers. Two plan rules fall with it: NAV-2's 10sp floor (the
mechanism *selects* 9.5sp at font 1.3) and LAY-NAV-1's slot geometry. **Remedy (already the
plan's): NAV-3 icon-above-label** — at 360dp each destination gets a ~79dp slot; "Attendance"
at 10sp × font 1.3 measures 75.5dp and fits *at the design floor size*, which the harness will
re-verify. Fix wave: the Wave 0 NAV-3 rebuild (plan §7.2), then this harness re-runs.

**F2 — S2 (accepted-debt candidate, recorded). LAY-CARD-2 budget missed: strip is 92dp, plan
says 84dp ± 2dp.** The mechanism is exactly right (one forced constant, cannot inflate, content
complete); the constant sits inside the fix brief's 84–104dp band but outside the approved
plan's HOME-3/LAY-CARD-2 budget. Resolution, one of: the NAV-3 rebuild sets `HEIGHT_DP = 84`,
or the Designer + Checker amend HOME-3/LAY-CARD-2 as a recorded golden change (§6.1/§6.6).
Not a rejection ground on its own; must not silently persist past the NAV-3 rebuild.

**F5 — S2 (observation). Workspace student detail renders the full card expanded;** HOME-3
wants it collapsible, default collapsed to the strip. Proportions are exact CR80 and the card
is content-complete — no founding-defect recurrence. Alignment is Wave 1B scope.

Screenshot states (§6.4): **not executed** — no device in the Checker's hands. The 12-state
checklist is delivered (`files/CHECKER-SCREENSHOT-CHECKLIST.md`) and the device pass remains
owed on the rebuilt APKs regardless; per §6.5 nothing in this report upgrades a harness result
into "works on the phone".

### G4 Language & metadata — PASS
Banned-strings lint **15/15 PASSED** (incl. the retired-name checks). Metadata gate **PASSED
for both APKs** (Checker-run): packages, versionCodes 19/22, versionNames 2.8/2.9, minSdk 26 /
targetSdk 34, permissions within {INTERNET, CAMERA} (Connect INTERNET only; Workspace
INTERNET + CAMERA), labels 'IQRS Connect' / 'IQRS Workspace', **apksigner verifies (v2+v3)**.
Mechanism classes (`NavFit`, `CardPreviewLayout`, `BottomNav`, `StudentCardView$PreviewStrip`)
confirmed present in **both shipped dexes** (dexdump).

### G5 Data truth — N/A (in scope: nothing to reconcile)
The wave changes presentation only (BottomNav, StudentCardView, NavFit, CardPreviewLayout,
`Ui.hspacer`). No count, fee, marks or list logic is touched, so there is no figure whose
reconciliation this wave could break. (Checker-verified from the change surface in source.)

## Further findings

**F3 — S2 (debt). Seven Connect `AlertDialog.Builder` sites do not pass the pinned theme:**
DailyAssignmentsActivity, LeavesActivity, LessonPlanActivity, OfflinePaymentsActivity,
OnlineExamAttemptActivity, ProfileEditActivity, TimelineActivity (all pre-existing Wave A/B
screens; untouched by this wave). They resolve through the light-only AppTheme's platform
default — dark text on a light dialog (the tree has no `values-night`) — so REG-DIALOG-TEXT's
readability criterion holds today by platform default rather than by construction. Debt for
the next Connect wave: pass `R.style.AlertDialogTheme` at every Builder site; the harness
check `SRC-DIALOG-SITES-THEMED` must go green then.

**F4 — S2 (observation). Baseline margin is 0.2dp.** At 360dp/font 1.0 the bar fits at 10.0sp
with 0.2dp to spare under advance-sum metrics. The on-device decision is safe (it measures
with the real Paint and steps down), but there is no headroom — one reason the NAV-3 anatomy,
not a bigger squeeze, is the right remedy.

## What is verified good (safe to tell the owner)

- The giant navy slab **cannot recur**: the strip's height is one forced constant, its content
  is complete, and with no card data the strip does not render at all.
- At the phone's default font size, **all four nav labels render whole on one line in both
  apps' shared component**, chosen by real-typeface measurement — "Attendance" included.
- The sign-out dialog text is pinned at 17.8:1 / 8.0:1 contrast in both shipped APKs.
- 197/197 JVM tests, 15/15 language lint, metadata + signature gates — all independently re-run.

## Re-entry conditions for the rebuilt wave

1. NAV-3 icon-above-label bottom nav (plan §5.2), with this harness green at 360dp × font
   1.0 **and** 1.3 and at 320dp × 1.0 — labels ≥ 10sp, complete, one line.
2. F2 resolved (strip at 84dp, or the plan budget amended with Designer + Checker sign-off).
3. `CHECKER-SCREENSHOT-CHECKLIST.md` executed on the §6.5 matrix; founding-regression shots first.
4. This harness re-run end-to-end on the new APKs; a new CHECKER-REPORT issued before delivery.

## Harness

`~/workspace/iqrs-app-v2/tools/checker/` (`run_checker.sh`, README inside) — new files only;
no app source was modified by the Checker. Raw run of record: JUnit budget suite 5 tests /
3 failures (LAY-CARD-2, LAY-NAV-2 @1.3, LAY-NAV-2 @320dp) — the failures are findings F1/F2
above; source inspections 10 PASS / 1 FAIL (F3); APK checks PASS ×2.
