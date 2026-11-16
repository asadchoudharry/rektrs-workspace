# CHECKER REPORT — Wave 1B (Workspace app on the Wave 1A endpoints)

**Date:** 2026-11-07 · **Checker:** independent checker agent (did not build this wave)
**Protocol:** FEATURE-AND-DESIGN-PLAN §6 · **Build report under test:** BUILD-REPORT-wave1b-app.md

## Artefact identity

| Item | Claimed | Verified |
|---|---|---|
| IQRS Workspace v2.11 (code 24) | 1,520,201 B, sha256 `7ffad477…a6ee732` | **Exact match** — size and sha256 recomputed from `~/workspace/your_files/iqrs-app/IQRS-Workspace-App-v2.11.apk` |
| Package / version | pk.edu.iqrs.admin, 2.11 / 24 | aapt2 badging + metadata gate: package ✓, versionCode 24 ✓, versionName 2.11 ✓, minSdk 26, targetSdk 34, permissions CAMERA + INTERNET only |
| Signer continuity | (same key as v2.10) | **Same certificate** — Signer #1 SHA-256 `f7874c3f69e4ee1cfbf54ef3616b2dde920423baa16f70d25724771f3bda462e` on both v2.10 and v2.11 |
| Connect v2.9 | unchanged | Delivered APK sha256 `9b4a49bc…` — byte-identical to the Wave 0 checker-passed build; untouched by this wave as claimed |

## Gate results

### G1 Contract — PASS
- `tools/contract_check.py` re-run by the Checker: **PASSED** (dummy login refused with status 0 / "Invalid Username or Password"; unauthenticated dashboard call → HTTP 401). The script as shipped targets **staging only** (see S2-2).
- Endpoint-level contract proof (happy/refusal/wrong-role/foreign paths on staging) was the Wave 1A checker's PASS; this wave's consumption of those contracts is pinned by the fixture suite below — the mappers parse the service's real payload envelopes, including its refusal shapes.

### G2 Logic — PASS
- Unit suite re-run by the Checker (`tools/run_tests.sh`): **OK (232 tests)** — the claimed 199 baseline + 33 new (`Wave1BMapperTest` 23, `Wave1BPayloadsTest` 10). Count and composition match the build report exactly.
- Reconciliation arithmetic is inside the suite (fee split, worklist counts, register rules — including "an unmarked student carries no invented type").

### G3 Visual (harness arm) — PASS · device arm pending (see §6.4 note)
- Checker harness re-run by the Checker (`tools/checker/run_checker.sh` with both delivered APKs): **0 failed check groups**, exit 0.
- Layout-budget JUnit: OK (5 tests). Nav fit table: **FITS** at 360dp × 1.0 (12sp, 278.8/316dp), 360dp × 1.3 (10sp floor, 302.0/316dp), 320dp × 1.0, 411dp × 1.0. 320dp × 1.3 shows OVERFLOWS — the owner-accepted known limitation (§6.5 amendment, decided 2026-11-07), not a defect.
- Source mechanism inspections: ALL PASS — NAV-3 anatomy, single-line labels, NavFit real-font measure, strip height forcing, CR80 aspect forcing, SRC-HOME-STRIP-CONDITIONAL, **SRC-STAFF-CARD-CONDITIONAL**, REG-DIALOG-TEXT (17.8:1 / 8.0:1 pinned theme), all dialog sites themed.
- REG-NAV-ATTENDANCE: Connect is byte-identical to the previously passed build and the harness table + mechanism checks pass. REG-HOME-CARD: strip mechanism + F5 behaviour verified in code (below); device rendering is part of the pending §6.4 pass.

### G4 Language & metadata — PASS
- Banned-strings lint re-run standalone and inside the harness: **PASSED (15/15)**.
- Checker's own beyond-lint sweep (case-insensitive, string-literal context, all staff UI sources + w1b_* strings): **no hits** for sync/outbox/queue/offline/LIVE/API/domain text. The only user-visible waiting wording is "Waiting to send".
- Metadata gate: PASSED for both apps (run by the Checker directly on the Workspace APK and inside the harness for both).

### G5 Data truth (harness level) — PASS
- **Fixture base verified genuine:** 40 `fixtures/w1b_*.json` = 34 captures + 6 crafted. Captures carry the real staging envelopes (status/message/record), the real fixture identities (113/114/115), session 21. Crafted files are exactly the six `*_rows.json` (bank payment, calendar, staff leave, student leave, tasks, timetable rows) and are **labelled as crafted** in the `Wave1BMapperTest` header and test names (e.g. `bankPaymentRowMapsFromCraftedEnvelope`).
- **Teacher worklist correction confirmed:** the teacher capture holds 3 cards with `attendance_unmarked` count **1** whose sections list is exactly that one section (Four – Daffodils (Girls), 22 students) — count reconciles with its own list (HOME-6).
- **Fee truth:** the captured receipt *is* a discount entry (amount 0, discount 1,000, total_received 0, payment_mode "discount") — the honest case the school's data demands, pinned as a fixture.
- Full on-fixture G5 (hand-computed statement on a live fixture account) belongs to the device pass; the statement screen renders the service's own totals (below), so no app-side arithmetic can drift.

## Claim spot-checks (code-read by the Checker)

- **(a) F5 — CLOSED, verified.** `StaffStudentActivity` renders the shared wallet strip as the resting state; the full `StudentCardView` sits in a container starting `View.GONE`; the strip's tap toggles it open/closed (default collapsed). Strip height is the harness-forced 84dp; the full card's CR80 aspect is forced in `onMeasure`. Rendered only when card data exists.
- **(b) Capability gating — verified end to end.** `NavSlots.available()` gates every slot on `Capabilities.can/canAny` against the API-00 map; the teacher capture (114) genuinely has **no `fees_collection` module** (read from the capture itself), so the teacher gets no Fees slot, and `Wave1BMapperTest.teacherMapIsAssignedAndHasNoFeesDesk` pins it. The Fees Desk re-gates each segment by its own key (`search_due_fees` / `search_fees_payment` / `offline_bank_payments`); `StaffMoreActivity` wraps every entry in `caps.can(...)`; Home shapes quick actions from the loaded map.
- **(c) "Marking" label — verified, math recomputed.** Teacher slot 2 is `MARKING` → label "Marking" (`NavSlots`), opening the homework screens (titles stay "Homework"). Recomputed with `tools/checker/font_metrics.py` on the bundled jakarta-700.ttf at the 10sp floor × font-scale 1.3 (factor 13): **Marking 3.921em → 51.0dp**, Homework 5.407em → 70.3dp (would overflow), Checking 60.6dp, Students 57.9dp, Classes 48.9dp, Directory 59.9dp, Staff 31.9dp, Notices 49.3dp — all within the 63.2dp five-slot width at 360dp (316dp avail ÷ 5). Every label the bar can actually show fits whole at the guaranteed combinations.
- **(d) Fees statement / receipt — verified.** `StaffFeeStatementActivity` renders every charge line and the totals card through `StaffUi.moneySplit(amount, discount, fine, paid, balance)` using the **service's totals** (`totalAmount/totalDiscount/totalFine/totalPaid/totalBalance`) — CARD-2's Amount · Discount · Paid · Balance, with deposit discounts shown as discount, never as payment. `StaffFeeReceiptActivity` loads exactly one receipt by (invoice_id, sub_invoice_id) and renders only that entry's amount/discount/fine/total_received.
- **(e) Language lockdown — verified** (G4 above, including the Checker's own sweep beyond the lint's patterns).

## Not-built claims — verified honest (no fakes)
- **API-81 my-attendance:** no screen, endpoint reference or string exists anywhere in the tree — genuinely absent, not simulated.
- **Receipt file:** the capture carries `file: null`; the receipt screen offers no share/print/file action (no such intent in the activity) and carries the honest copy: *"This is the screen copy of the receipt. The school office can print the paper copy."*
- **Timetable:** the real class capture returns `"days": []`; the screen's not-configured copy names the owner and the remedy (*"The timetable has not been set up yet. The school office sets it up in the school system, and it will appear here once it exists."*) — EMPTY-3/EMPTY-4 compliant, no dead button, no fabricated periods.
- **Bank payment detail:** populated entirely from the list row's fields passed as intent extras; no single-record read exists in the repository and none is pretended. The review sheet's approve button repeats the amount (CARD-3).

## Findings

**S0 — none. S1 — none.**

**S2 (accepted debt / documentation):**
- **S2-1 Librarian nav pair deviates from NAV-1's table** (plan: Library · Tasks; shipped: Tasks · Directory via the fill order, because the Library slot is a Wave 2 module and a dead destination would be worse). Documented by the builder in the report and in `NavSlots`. Accepted debt — align when Wave 2 ships the library screens.
- **S2-2 Builder disclosure §6 overstates the contract gate's target.** The disclosure says the gate "probes the production host"; the script in the tree (`tools/contract_check.py`) points at **staging** only (`BASE = https://staging.iqrs.edu.pk/api/`, docstring "Read-only against staging"), and the Checker's own re-run hit staging. No production contact occurred in the gate as shipped. The disclosure should be corrected so the record matches the artefact.
- **S2-3 320dp × font-scale 1.3 nav overflow** — stands as the owner-accepted known limitation (§6.5 amendment); recorded here for completeness, not a defect.

## §6.4 device screenshot checklist — PENDING (out of this pass's scope)
Not executed: the 12-state checklist per new screen at 360dp on the owner's phone, including REG-NAV-ATTENDANCE with role-shaped slots at both font scales, REG-HOME-CARD (84dp strip + F5 collapse/expand on student detail), and REG-DIALOG-TEXT on device. Harness passes are reported as harness passes; nothing here upgrades them into "works on the phone". This is owed, not failed.

## Verdict

**PASS** — Wave 1B is fit to send to the owner (with the §6.4 device pass still owed on this exact APK, as the protocol requires before the wave is called device-verified).
