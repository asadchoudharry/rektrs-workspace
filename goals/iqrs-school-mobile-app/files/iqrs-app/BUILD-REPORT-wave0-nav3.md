# BUILD REPORT — Wave 0 re-entry: NAV-3 rebuild (F1) + strip budget (F2) + dialog themes (F3)

Date: 2026-11-07 · Builder's report for the Checker's re-entry pass on the Wave 0 repair wave.
Responds to `CHECKER-REPORT-wave0.md` (verdict REJECT, one S1) and its re-entry conditions 1–2
(condition 3, the screenshot checklist, remains a device pass owed on these APKs; condition 4 is
the Checker's own re-run).

## Builds delivered

| App | File | versionCode / name | Size | SHA-256 |
|---|---|---|---|---|
| IQRS Connect | `IQRS-Connect-App-v2.9.apk` | 20 / 2.9, `pk.edu.iqrs.family` | 1,454,514 B | `9b4a49bc73938d893bf3aa009f283d0ddddd0c87beb4b9fb712972cf6e57355e` |
| IQRS Workspace | `IQRS-Workspace-App-v2.10.apk` | 23 / 2.10, `pk.edu.iqrs.admin` | 1,397,170 B | `3c15c604c166ee11d51721ec71e2619097fca231c6e0c181af7ef95e0ae81298` |

Labels (`aapt2 dump badging`): `application-label:'IQRS Connect'` / `'IQRS Workspace'` — unchanged.
Permissions unchanged: Connect INTERNET only; Workspace INTERNET + CAMERA. No server changes.

## F1 (S1) — NAV-3 icon-above-label bottom navigation — CLOSED

**What changed.** The shared `ui/components/BottomNav` was rebuilt to the plan's NAV-3 anatomy
(§5.2). Each destination is now a vertical content column inside an **equal slot**: the slot is a
`LinearLayout` child with `LayoutParams(0, MATCH_PARENT, weight 1)` — identical for every
destination, so slot widths are equal by construction (LAY-NAV-1) — and it carries the click
target. Inside it, a content-sized (`WRAP_CONTENT`) column holds a 56×32dp pill (the Material 3
**active indicator**) with the 24dp icon centred in it, and the label below on a 2dp gap. The
pill is present in both states (highlight background when selected, transparent when not), so
selecting a destination never resizes or shifts anything. Selected = gold icon + gold label;
unselected = white at 70%, fully visible. Bar height is unchanged at 64dp (NAV-4); destinations
in both apps are unchanged (this is a layout rebuild, not an IA change). `BottomNav` ships in
both APKs (the Checker verifies its class in both dexes); Connect renders it today, and
Workspace — which currently navigates from its home screen — inherits the same component.

**The fit mechanism.** `api/NavFit` keeps its public decision API (the harness drives it
directly) but its geometry is re-expressed for the slot anatomy — same constants the view lays
out with, so the decision *is* the layout:

- `availDp(w) = w − 2·BAR_MARGIN_DP(16) − 2·ROW_PAD_DP(6)` — unchanged (316dp at 360dp).
- A destination's content width is `max(label width, INDICATOR_WIDTH_DP = 56)` — the icon is
  above the label, so it adds height, not width; the indicator pill is the widest fixed element.
- `fits` ⇔ `count × widest item ≤ avail` ⇔ the widest label fits **its own slot**
  (`avail / count` = 79dp at 360dp). The fit no longer depends on measure order: no item's
  survival can starve another item, because every slot is pre-sized.
- The size range is now `[FLOOR_SP, START_SP] = [10sp, 12sp]` — the floor was raised from 9.5sp
  to the plan's NAV-2 floor of **10sp**, and the start to the M3 label size of 12sp. `onMeasure`
  still chooses the size with a real `Paint` measurer over the bundled typeface before the
  children are measured.

**Real-font results** (Checker harness §3 table, this build): 360dp/font 1.0 → chosen **12.0sp**,
total 278.8 of 316dp, FITS · 360dp/font 1.3 → chosen **10.0sp**, total 302.0 of 316dp, FITS
("Attendance" at the floor = 75.5dp inside its 79dp slot) · 320dp/font 1.0 → chosen **11.5sp**,
FITS · 411dp/font 1.0 → 12.0sp, FITS.

**One honest boundary.** At 320dp × font scale 1.3 — a corner outside the report's re-entry
configurations — "Attendance" at the 10sp floor measures 75.5dp against a 69dp slot, so no
layout can satisfy NAV-2's floor there in equal slots; `NavFit` returns the floor and the
single-line label would clip ~6.5dp rather than wrap or shrink below 10sp. The harness's
evidence table prints this row as an overflow (its per-item narration is sequential, but the
numbers are the slot-model item widths). This is a physical limit of that matrix corner, not a
regression: the old anatomy overflowed the same corner by 71.8dp *and* failed 360dp/1.3 and
320dp/1.0 outright.

## F2 (S2) — Home wallet strip at the plan budget — CLOSED

`api/CardPreviewLayout.HEIGHT_DP`: **92 → 84**, the plan's LAY-CARD-2 number (HOME-3). The
mechanism is untouched — `PreviewStrip.onMeasure` still forces
`CardPreviewLayout.measuredHeightPx(density)` under `EXACTLY` specs, and Home still adds the
strip only when card data exists. The class's sanctioned band was re-set to the plan budget
itself (`MIN_HEIGHT_DP` 82 / `MAX_HEIGHT_DP` 86, i.e. 84 ± 2), so the constant now conforms to
the plan rather than to the fix brief's wider band — conformance, not a budget amendment. The
strip's content (42dp avatar, three single-line texts, 38dp QR in its padded box) fits the
84dp height with room to spare (60dp of content height inside the strip's vertical padding).

## F3 (S2) — Unthemed Connect dialog sites — CLOSED

All nine `AlertDialog.Builder` call sites in the seven named Connect files now pass
`R.style.AlertDialogTheme` as the second constructor argument — theme only; no title, message,
button, listener or behaviour was touched:

- `DailyAssignmentsActivity` (×2), `ProfileEditActivity` (×2), `LeavesActivity`,
  `LessonPlanActivity`, `OfflinePaymentsActivity`, `OnlineExamAttemptActivity`,
  `TimelineActivity` — each `new AlertDialog.Builder(this)` →
  `new AlertDialog.Builder(this, R.style.AlertDialogTheme)`.

Workspace was swept the same way: it has no unthemed sites (its builders, in
`StaffProfileActivity` and the shared `LoginActivity`, already passed the theme). Verification:
the harness's `SRC-DIALOG-SITES-THEMED` inspection now reports PASS — *all* `AlertDialog.Builder`
sites in the tree pass the pinned theme — and `REG-DIALOG-TEXT` still passes (17.8:1 / 8.0:1,
pinned in both shipped APKs' resources).

## Tree-suite assertion changes (each justified)

`tests/pk/edu/iqrs/app/api/VisualLayoutTest.java` — 197 → **199 tests** (2 added, 4 amended):

| Test | Change | Justification |
|---|---|---|
| `previewHeightIsTheDesignedStripHeight` | 92 → **84** | F2: the plan's LAY-CARD-2 budget replaces the fix-brief constant. |
| `previewHeightPxScalesWithDensityOnly` | 92/184/276/242 → **84/168/252/221** | Same change, in pixels (84 × 2.625 = 220.5 → 221). |
| `longestLabelFitsItsItemAtTheFloorSize` → `longestLabelFitsItsSlotAtTheFloorSize` | old pin `item = 45 + label` (2·10 padding + 20 icon + 5 gap) → new pin `item = max(INDICATOR_WIDTH_DP, label)` and `item ≤ slotWidthDp(avail(360), 4)` | NAV-3 anatomy: the icon is above the label (no side gap/padding in the width), the indicator pill is the fixed wide element, and the guarantee is per-slot. The old formula pinned the retired side-by-side anatomy — exactly what F1 ordered removed. |
| `chosenSizeFitsAndStaysAtOrAboveTheFloor` | expected chosen 10.0sp → **START_SP (12sp)** under the conservative stand-in | Under equal slots the stand-in no longer squeezes the bar (Attendance = 72dp in a 79dp slot at 12sp), so the designed start size is chosen; fits + ≥ floor still asserted. |
| `availableWidthAt360dpIsTheDesignBudget` | added slot pin: `slotWidthDp(316, 4) = 79` | Makes the slot — the quantity the guarantee is about — an explicit pinned value. |
| **new** `labelsFitTheirSlotsAtFontScale13UnderPessimisticWidths` | — | Pins the F1 configuration (font 1.3) in the tree suite with the pessimistic stand-in (Attendance = 78dp ≤ 79dp slot at the floor). |
| **new** `labelsFitTheirSlotsAt320dpUnderPessimisticWidths` | — | Pins the 320dp matrix step under the slot model. |

Unchanged and still passing: `previewMeasuredHeightNeverExceedsTheCap`,
`everyLabelFitsAtTheFloorSizeUnderPessimisticWidths`,
`realisticWidthsKeepTheDesignedStartSize`, `impossibleWidthFallsBackToTheFloorAndNeverBelow`
(the floor is returned, never crossed), `degenerateInputKeepsTheStartSize`.

`NavFit.FLOOR_SP` 9.5 → 10 and `START_SP` 10.5 → 12 are the NAV-2/M3 values; the retired
constants `ITEM_PAD_DP` / `LABEL_MARGIN_DP` (side-by-side anatomy) were removed with the layout
they described.

## Gates — all run on this tree / these APKs

- **Tree JVM suite** (`tools/run_tests.sh`): **OK (199 tests)**.
- **Banned-strings lint** (`tools/banned_strings.sh`): **PASSED** (15/15).
- **Checker harness, tree level** (`tools/checker/run_checker.sh`): **0 failed check groups** —
  budget JUnit **OK (5 tests)** (LAY-NAV-2 @360×1.0, @360×1.3, @320×1.0; LAY-CARD-2;
  REG-HOME-CARD), source inspections **11/11 PASS** (incl. SRC-NAV-HEIGHT-64,
  SRC-NAV-SINGLELINE, SRC-NAV-FIT-MECHANISM, SRC-DIALOG-SITES-THEMED, REG-DIALOG-TEXT),
  banned strings PASS. Full output below.
- **Checker APK step** (`tools/checker/check_apk.sh`, the harness's own script): **PASSED for
  both APKs** — metadata gate, mechanism classes present in both shipped dexes
  (`NavFit`, `CardPreviewLayout`, `BottomNav`, `StudentCardView$PreviewStrip`), shipped
  `AlertDialogTheme` pins verified in both resources. *Note:* the orchestrator's §6 step
  hardcodes the previous wave's versionNames (`2.8`/`2.9`) in its `check_apk.sh` arguments, so
  the APK step was run by invoking `check_apk.sh` directly with this wave's versions
  (`2.9`/`2.10`); the harness itself was not modified.
- **Metadata gate** (`tools/metadata_check.sh`): PASSED for both (packages, codes 20/23,
  names 2.9/2.10, minSdk 26, targetSdk 34, permissions as above, **apksigner verifies**).

## Checker harness output (tree level, this build)

```
== 1. real-font metrics (jakarta-700.ttf) ==
UNITS_PER_EM=1000
WIDTH.Home=2.92100
WIDTH.Attendance=5.80800
WIDTH.Fees=2.32400
WIDTH.More=2.53100
== 2. layout-budget tests (JUnit, real font) ==
JUnit version 4.13.2
.....
Time: 0.058

OK (5 tests)

== 3. nav fit table (evidence) ==
screen=360dp font=1.0 avail=316.0dp chosen=12.0sp total=278.8dp FITS
screen=360dp font=1.3 avail=316.0dp chosen=10.0sp total=302.0dp FITS
screen=320dp font=1.0 avail=276.0dp chosen=11.5sp total=267.2dp FITS
screen=320dp font=1.3 avail=276.0dp chosen=10.0sp total=302.0dp OVERFLOWS by 26.015991dp
    (out-of-matrix corner — see F1 boundary note above)
screen=411dp font=1.0 avail=367.0dp chosen=12.0sp total=278.8dp FITS
== 4. source mechanism inspections ==
SRC-NAV-HEIGHT-64 PASS — BottomNav self LayoutParams height is Ui.dp(c, 64) — LAY-NAV-1's 64dp ± 2dp by construction
SRC-NAV-SINGLELINE PASS — labels are setSingleLine(true) inside WRAP_CONTENT items — a wrap is impossible by construction
SRC-NAV-FIT-MECHANISM PASS — onMeasure chooses the label size via NavFit with a real Paint measurer over the real typeface
SRC-CARD-STRIP-FORCED PASS — PreviewStrip.onMeasure forces its height to CardPreviewLayout.measuredHeightPx with EXACTLY specs, whatever it is offered
SRC-CARD-ASPECT-CR80 PASS — full card onMeasure forces height = round(width x 54/85.6) EXACTLY — LAY-CARD-1 within rounding (<=0.5px)
SRC-CARD-STRIP-NOSPACER PASS — walletPreview's row gap is Ui.hspacer; its single Ui.spacer sits inside the vertical texts column (the founding slab mechanism cannot recur)
SRC-CARD-STRIP-TEXTS-1LINE PASS — strip label and name are single-line (name ellipsises at line end per checklist state 8 — never mid-word, never tall)
SRC-HOME-STRIP-CONDITIONAL PASS — Home adds the wallet strip only when StudentCardMapper.fromChild returns data — no data, no surface at all
SRC-STAFF-CARD-CONDITIONAL PASS — Workspace student detail renders the full CR80 card only when card data exists
REG-DIALOG-TEXT PASS — AlertDialogTheme pins windowBackground=surface (#FFFFFF), textColorPrimary=ink (#14181F, 17.8:1), textColorSecondary=ink_2 (#4A5160, 8.0:1) — background is pinned, so both modes render identically
SRC-DIALOG-SITES-THEMED PASS — all AlertDialog.Builder sites pass R.style.AlertDialogTheme
SOURCE CHECKS: ALL PASS
== 5. banned-strings lint (G4) ==
BANNED-STRINGS GATE: PASSED
PASS — banned strings
== 6. shipped APKs ==
(none given — tree-level run; the APK step was run separately via check_apk.sh — PASSED ×2)
CHECKER HARNESS: 0 failed check group(s)
```

## Still owed (not this build's scope)

- Re-entry condition 3: `CHECKER-SCREENSHOT-CHECKLIST.md` executed on a device against these
  APKs — the harness pass above is a harness pass, not a phone pass (plan §6.5).
- F5 (Workspace detail card collapse-to-strip) — Wave 1B scope, per the Checker report.
