# Checker Screenshot Checklist — §6.4 device pass

**Owner:** the Checker (never the wave's builder). **Source:** FEATURE-AND-DESIGN-PLAN §6.4–§6.5.
**Rule (§6.5):** a harness pass is a harness pass. A wave is *device-verified* only when this
checklist has been executed on the device matrix below and every shot is judged PASS/FAIL
against the criteria — the verdicts go into `CHECKER-REPORT-<wave>.md` with the shot set's location.

## Device matrix (§6.5) — run in this order

| Step | Configuration | Font scale | Mode |
|---|---|---|---|
| 1 (baseline) | 360×640dp (owner's phone class) | 1.0 | light |
| 2 | 360×640dp | 1.3 | light |
| 3 | 360×800dp | 1.0 | light |
| 4 | 320dp narrow | 1.0 | light |
| 5 | 411dp wide | 1.0 | light |
| 6 | 360×640dp | 1.0 | **dark** |
| 7 | Owner's actual phone before the wave is called device-verified | as set | as set |

States that cannot occur on a screen are marked **N/A + reason** — never silently skipped.

## Founding regressions — capture FIRST, on every build (§6.7)

| ID | Shot | PASS criteria |
|---|---|---|
| REG-NAV-ATTENDANCE | Connect bottom nav, 360dp, font 1.0 **and** 1.3, light **and** dark, "Attendance" tab active and inactive | "Attendance" is one complete word on one line; **every** other label (Home, Fees, More) is also complete — no clipped or ellipsised label anywhere in the bar, in any of the four configurations |
| REG-HOME-CARD | Connect Home with a real child record; again with a child who has **no photo**; Workspace student detail | Home shows the bounded wallet strip (slim, content-complete: photo/initials, name, class, admission, mini-QR, caret); the full card on its own screen keeps CR80 proportions; **no mostly-empty card surface in any data state** |
| REG-DIALOG-TEXT | Sign-out confirmation (Connect More tab; Workspace Profile), light and dark | Title, body and both buttons fully readable against the dialog background in both modes |

## The 12 states — for EACH screen in the wave

| # | State / shot | Pass criteria |
|---|---|---|
| 1 | Populated (rich fixture) | Hierarchy reads in 3 seconds: title → primary datum → action. No card exceeds its §5 budget. Real-looking data (never lorem, never a developer string) |
| 2 | Loading | Skeleton matches the final layout's shape; no blank flash, no full-screen spinner (sign-in and camera start excepted) |
| 3 | Empty (true) | EMPTY-1/2/3 anatomy and copy; block ≤ 160dp inline |
| 4 | Not configured | Names the setup owner (school office / system settings); no dead button; no error voice |
| 5 | No search results | Query echoed, Clear action present, filters intact (LIST-2) |
| 6 | Offline with cache | Cached data + quiet "Last updated" caption only where the design system allows; **no status pill, no banner, no domain text** |
| 7 | Error without cache | The approved error copy + Retry; nothing raw (no codes, no stack words) |
| 8 | Long content | Longest names/titles wrap by word or ellipsise at line end — **never mid-word**; amounts never truncate. Fixtures: 40-character name, longest class name in the school |
| 9 | Form with an error | Error under the field, all input preserved, primary action reachable above the keyboard |
| 10 | Review/confirm step (money & approvals) | CARD-3 completeness: student, fee line, amount, discount, fine, method, total, date — all visible before the commit button, which repeats the total |
| 11 | Success | Confirmation states what happened in plain words + the reference (receipt no., count saved) |
| 12 | Role-denied | The module is absent from nav/More for that role; a deep link explains plainly that it is not available for their role |

## Archetype additions

- **Scanner (QR attendance):** frame guide visible, torch reachable, result card readable at arm's length, duplicate-scan state in amber words.
- **Register / marks grid:** sticky summary visible while scrolling, segment labels are words with text equivalents, on-screen totals reconcile with the roster (G5 spot-check).
- **Card screen:** QR decodes with a stock scanner app, barcode scans, the flip keeps the same bounds (LAY-CARD-1 in both flip orientations); in Workspace, scan the card's QR with QR attendance and confirm it resolves the same student.
- **Money screens:** Paid / Discount / Balance always separate words with figures (CARD-2); a discount is never coloured or worded as a payment.

## Wave 0 screen list (apply the 12 states to each)

**IQRS Connect:** Home (incl. wallet strip) · Student Card screen (front + back) · Attendance ·
Fees overview + fee detail · More grid · Sign-out dialog · Profile.
**IQRS Workspace:** Home · Student detail (card) · Profile + sign-out dialog · QR attendance (archetype).

## Recording

For every shot: `wave / app / versionCode / device-config / screen / state# / PASS|FAIL|N/A(reason)`.
Any FAIL gets a severity (§6.6: S0 blocker, S1 major, S2 minor) and a defect line in the
wave's CHECKER-REPORT. An unreviewed golden diff blocks delivery exactly like a failure (§6.6).
