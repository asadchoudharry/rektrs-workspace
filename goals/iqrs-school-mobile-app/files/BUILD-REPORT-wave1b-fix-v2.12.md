# BUILD REPORT — Wave 1B fix: Workspace v2.12 (code 25)

**Lane:** urgent fix, commissioned after the owner's device report on v2.11.
**Deliverable:** `IQRS-Workspace-App-v2.12.apk` — **1,520,201 B, sha256 `28287e7e067ce970e9d9b8788321d4a93be17e2e49bc12f17c70170df9a59de5`**, package `pk.edu.iqrs.admin`, versionName 2.12 / versionCode 25, signer certificate SHA-256 `f7874c3f…462e` — identical to v2.11, so it installs over v2.11 as an update.
**Connect:** unchanged — v2.9 / code 20, not rebuilt (see §5).

## 1. What the owner saw

Workspace v2.11 on production: the Home "WAITING FOR YOU" worklist rows rendered as giant empty bands — labels crushed invisible, counts (77, 0, 0, 0, 1662, 0) floating in tall empty rows. Everything else on Home (stats, quick actions, tools, recent activity, bottom nav) rendered correctly, and the data itself was right (77 unmarked sections, 1,668 students). A pure layout defect in one row construction.

## 2. Diagnosis — confirmed in code

`Ui.spacer(c, h)` builds a view with **MATCH_PARENT width** and a fixed height — a vertical gap for columns (`src/pk/edu/iqrs/app/ui/components/Ui.java:167`). `Ui.hspacer(c, w)` is the row-safe twin, and its own javadoc (Ui.java:174–180) documents this exact failure: a MATCH_PARENT-width view inside a horizontal row eats the row's whole width budget, starves weighted siblings to zero width, and a zero-width multi-line sibling then measures enormously tall — the mechanism of the founding Wave 0 giant slab.

`StaffHomeActivity.renderWorklist()` (v2.11 line 377) built each worklist row as a `Ui.row` containing: the weighted texts column (`Ui.llp(0, WRAP_CONTENT, 1)`), the count, **`Ui.spacer(this, 6)`**, and the caret icon. The spacer took the row's width, the weighted texts column collapsed to zero width, and its two-line label measured enormously tall — precisely the owner's screenshots. The coordinator's diagnosis is confirmed without modification.

## 3. Fixes (layout only — no data, navigation, or behaviour change)

1. **`StaffHomeActivity.renderWorklist`** — `row.addView(Ui.spacer(this, 6))` → `row.addView(Ui.hspacer(this, 6))`, with a SPACER-AUDIT comment recording why (the method's other spacers go into `worklistBox`, a vertical column, and stay `Ui.spacer`).
2. **`StaffHomeworkActivity.onCreate`** (found by the tree-wide audit, §4) — `chips.addView(Ui.spacer(this, 0))` inside the due-date `Ui.row` → `Ui.hspacer(this, 0)`, with a SPACER-AUDIT comment. Benign in practice (height 0; sibling chips are wrap-content with their own leftMargins, so nothing visibly starved), but it is the same banned mechanism — a MATCH_PARENT-width view inside a row — and is fixed on the same principle.

## 4. Tree-wide audit — every Ui.spacer site in both apps

**696 `Ui.spacer(` call sites** exist in the v2.11 tree (counted by occurrence, not by line — two lines carry two calls each). Every site was resolved to the container its spacer view is actually added into, by receiver tracing: factory assignments (`Ui.row` / `Ui.column` / `Ui.card`), `setOrientation` calls, helper returns (`StaffUi.page()` → column; `FamilyScreen.Page.content` → column), local-variable indirection (`View sp = Ui.spacer(...)` then `addView(sp)`), and bare `addView` in component classes. **Verdicts: 694 column-safe, 2 row defects — the two fixed in §3. No other row-context misuse exists in either app.**

Risk classes checked individually, beyond the automated resolution:

- **Ever-row variable names** (variables called `row`, `head`, `chips`, … that hold a row in some other method): 8 sites — each traced inside its own method. All safe: e.g. `StaffStudentActivity`/`StaffStudentEditActivity`/`StaffProfileActivity` add their spacers into `head`, a `Ui.card` (column), never into the sibling row they build; `ExamResultScreen`'s `chips` is, despite the name, a `Ui.column`.
- **Parameter receivers** (spacer added to a container passed into the method): 15 sites across 5 helpers (`HomeworkDetailActivity.evalRow`, `OfflinePaymentsActivity.render`, `ProfileScreen.row`/`person`, `StaffMoreActivity.section`, `StaffTimetableActivity.appendDays`) — every call site traced; all callers pass `Ui.card` / `Ui.column` containers.
- **Helper-returned rows** (`StaffUi.linkRow` / `studentRow` / `detailRow` results, 6 assignments): none of them ever receives a spacer.
- **Hand-rolled orientation flip**: `ProfileScreen.togglePill` flips a container to HORIZONTAL after constructing it as a column — it receives only its knob view, no spacer.
- **Not a Ui.spacer site**: `OnlineExamAttemptActivity` builds its nav-row gap as a weighted `new View` with `Ui.llp(0, 1, 1)` — the correct flexible-space pattern; left untouched.
- **`SectionCard`** (bare `addView(Ui.spacer(c, 10))` on the component itself): the class extends LinearLayout and sets `setOrientation(VERTICAL)` in its constructor — column-safe.
- **Component internals**: `WeekStrip` cells, `BrandBand` texts, `Skeleton`, `StudentCardView` (f/qc/bc/right/inner/texts) — all columns, verified in source.
- **Wave 1B-new screens** (fees desk, register, waiting, directory, front office, homework, notices, calendar, tasks, timetable, my leaves, leave approvals, bank payments): every spacer site in them is in the table in Appendix A; all column-safe except the two §3 defects (Home worklist + homework compose chips).

The full per-site table (file, line, method, receiver, verdict) is Appendix A.

## 5. Connect — no change

Both defects are in Workspace (`ui/staff`) code. The audit found **zero** row-context spacer defects in Connect (`ui/family`) code, so per the fix-lane rule Connect is **not** bumped and **not** rebuilt: it stays at the delivered v2.9 / code 20, byte-identical to the build the Wave 1B checker passed. It was re-verified green in this lane's harness run (§7) using the delivered APK.

## 6. Permanent guard — SRC-NOSPACER-IN-ROW

The Wave 0 checker covered this mechanism only where it was hand-aimed (`SRC-CARD-STRIP-NOSPACER`, walletPreview only) — which is how the same mechanism shipped again in a new screen one wave later. The guard is now generalised in `tools/checker/check_sources.py` and runs as part of the standard harness (run_checker.sh step 4, whose header now names it):

- Every `Ui.spacer(` site in `src/` is located (direct receiver or local-variable indirection) and attributed to its smallest enclosing method (brace-counted; constructors and package-private helpers recovered as fallback spans).
- The receiver's orientation is resolved from the code — factory assignments and `setOrientation`, method-local first, then conflict-free file scope; structural facts (`StaffUi.page()`, `Page.content`) and a LinearLayout subclass's own orientation included.
- **Resolved into a row → FAIL. No allowlist entry can excuse a proven row site**; the only fix is `Ui.hspacer`.
- Inside a row-building method, a spacer whose receiver **cannot** be resolved → FAIL unless the (file, method) pair is in the explicit `SPACER_GUARD_ALLOWLIST` in check_sources.py **and** the method carries a `SPACER-AUDIT:` comment stating where its spacers go. The allowlist is empty today — every site in the tree resolves.
- Coverage is total: on the pre-fix tree the guard examines the full 696-site population and fails on its 2 row sites; on the fixed tree 694 `Ui.spacer` sites remain (the 2 converted sites are now `Ui.hspacer`) and the guard examines every one of them — see the proof lines below. (An earlier iteration of the guard silently skipped 9 sites in package-private `StaffUi` helper methods, and double-counted one local-variable indirection; both flaws were caught and fixed inside this lane before the proof runs, and the examined counts now reconcile exactly with the tree's occurrence counts.)

**Proof (both directions, run 2026-11-07 in this lane):**

Pre-fix tree (a scratch copy of `src/` with exactly the two §3 fixes reverted — the v2.11 defect state), all other source checks unchanged and passing:

```
SRC-NOSPACER-IN-ROW FAIL — Ui.spacer-in-row violations: src/pk/edu/iqrs/app/ui/staff/StaffHomeActivity.java:377 renderWorklist — Ui.spacer added into ROW receiver 'row'; src/pk/edu/iqrs/app/ui/staff/StaffHomeworkActivity.java:129 onCreate — Ui.spacer added into ROW receiver 'chips'
SOURCE CHECKS: 1 FAIL   (exit 1)
```

Post-fix tree:

```
SRC-NOSPACER-IN-ROW PASS — no Ui.spacer site resolves into a horizontal row and no row-building method leaves a spacer receiver unresolvable (694 sites examined, 0 allowlist-excused) — the giant-slab mechanism cannot recur anywhere in the tree
SOURCE CHECKS: ALL PASS   (exit 0)
```

## 7. Gates

| Gate | Result |
|---|---|
| Unit suite (`tools/run_tests.sh`) | **OK (232 tests)** — unchanged count, all green |
| Banned-strings lint (language lockdown) | **PASSED** (15/15) |
| Metadata gate (Workspace v2.12) | **PASSED** — pk.edu.iqrs.admin, code 25, versionName 2.12, minSdk 26, targetSdk 34, permissions {INTERNET, CAMERA}, signature verifies |
| Checker harness (`run_checker.sh`, both APKs) | **0 failed check groups** — real-font nav table FITS at 360dp × 1.0/1.3, 320dp × 1.0, 411dp; JUnit layout budgets OK (5 tests); all 12 source inspections PASS incl. the new SRC-NOSPACER-IN-ROW and the permanent regressions REG-NAV-ATTENDANCE / REG-HOME-CARD / REG-DIALOG-TEXT; APK checks PASS for Workspace v2.12 and for the delivered Connect v2.9 |
| Contract gate (`tools/contract_check.py`) | **Not run — by constraint.** This lane was local-only (no server contact of any kind). The contract gate is a live staging smoke with dummy credentials; this fix changes two view-construction calls and cannot affect any API contract. It remains available to the checker lane's normal staging pass. |

## 8. What remains device-unverified

This build is harness-verified, not device-verified. Owed on the owner's phone, on this exact APK:

- **The fix itself**: sign in and open Home — the "WAITING FOR YOU" rows must render at normal height with label, detail, count and caret all visible, and each row must open its list (navigation behaviour unchanged by construction, but not yet exercised on a device in this build).
- The §6.4 device screenshot checklist for Workspace v2.12 remains outstanding, as it was for v2.11.
- No server-side behaviour was touched or re-tested in this lane (no server contact was made).

## Appendix A — every Ui.spacer site, with verdict

Population: the 696 call sites of the v2.11 tree. Lines refer to the v2.11 sources for the two fixed sites and to the current (v2.12) sources elsewhere; the two fixed sites are the only lines whose content changed (the StaffHomeActivity comment block shifts its own method's later line numbers by +7 in the v2.12 tree; the site is listed at its v2.11 line, 377).

| File | Line | Method | Receiver | Verdict |
|---|---|---|---|---|
| SplashActivity.java | 36 | onCreate | root | column-safe |
| SplashActivity.java | 42 | onCreate | root | column-safe |
| SplashActivity.java | 52 | onCreate | root | column-safe |
| ui/BaseLoginActivity.java | 64 | onCreate | root | column-safe |
| ui/BaseLoginActivity.java | 69 | onCreate | root | column-safe |
| ui/BaseLoginActivity.java | 73 | onCreate | root | column-safe |
| ui/BaseLoginActivity.java | 79 | onCreate | root | column-safe |
| ui/BaseLoginActivity.java | 86 | onCreate | card | column-safe |
| ui/BaseLoginActivity.java | 93 | onCreate | card | column-safe |
| ui/BaseLoginActivity.java | 96 | onCreate | card | column-safe |
| ui/BaseLoginActivity.java | 130 | onCreate | card | column-safe |
| ui/BaseLoginActivity.java | 138 | onCreate | root | column-safe |
| ui/BaseLoginActivity.java | 143 | onCreate | root | column-safe |
| ui/LoginActivity.java | 70 | showForgotDialog | form | column-safe |
| ui/LoginActivity.java | 72 | showForgotDialog | form | column-safe |
| ui/LoginActivity.java | 77 | showForgotDialog | form | column-safe |
| ui/LoginActivity.java | 79 | showForgotDialog | form | column-safe |
| ui/LoginActivity.java | 97 | showForgotDialog | form | column-safe |
| ui/LoginActivity.java | 102 | showForgotDialog | form | column-safe |
| ui/components/BrandBand.java | 62 | create | texts | column-safe |
| ui/components/SectionCard.java | 38 | <class-init> | this | column-safe |
| ui/components/Skeleton.java | 48 | card | l | column-safe |
| ui/components/Skeleton.java | 50 | card | l | column-safe |
| ui/components/Skeleton.java | 65 | rows | texts | column-safe |
| ui/components/Skeleton.java | 70 | rows | l | column-safe |
| ui/components/StudentCardView.java | 180 | buildFront | f | column-safe |
| ui/components/StudentCardView.java | 224 | buildFront | f | column-safe |
| ui/components/StudentCardView.java | 238 | buildFront | f | column-safe |
| ui/components/StudentCardView.java | 309 | buildBack | qc | column-safe |
| ui/components/StudentCardView.java | 338 | buildBack | bc | column-safe |
| ui/components/StudentCardView.java | 348 | buildBack | right | column-safe |
| ui/components/StudentCardView.java | 352 | buildBack | right | column-safe |
| ui/components/StudentCardView.java | 377 | buildBack | inner | column-safe |
| ui/components/StudentCardView.java | 516 | walletPreview | texts | column-safe |
| ui/components/WeekStrip.java | 55 | build | cell | column-safe |
| ui/components/WeekStrip.java | 74 | build | cell | column-safe |
| ui/family/AboutActivity.java | 39 | onCreate | root | column-safe |
| ui/family/AboutActivity.java | 46 | onCreate | root | column-safe |
| ui/family/AboutActivity.java | 52 | onCreate | root | column-safe |
| ui/family/AboutActivity.java | 60 | onCreate | root | column-safe |
| ui/family/AboutActivity.java | 66 | onCreate | root | column-safe |
| ui/family/AboutActivity.java | 97 | render | card | column-safe |
| ui/family/AboutActivity.java | 97 | render | card | column-safe |
| ui/family/AboutActivity.java | 102 | render | card | column-safe |
| ui/family/AboutActivity.java | 102 | render | card | column-safe |
| ui/family/AboutActivity.java | 108 | render | contacts | column-safe |
| ui/family/AboutActivity.java | 123 | contactRow | texts | column-safe |
| ui/family/AttendanceScreen.java | 60 | build | page.content | column-safe |
| ui/family/AttendanceScreen.java | 76 | build | summary | column-safe |
| ui/family/AttendanceScreen.java | 80 | build | page.content | column-safe |
| ui/family/AttendanceScreen.java | 90 | build | page.content | column-safe |
| ui/family/AttendanceScreen.java | 96 | build | page.content | column-safe |
| ui/family/AttendanceScreen.java | 100 | build | page.content | column-safe |
| ui/family/AttendanceScreen.java | 125 | legend | card | column-safe |
| ui/family/AttendanceScreen.java | 333 | renderCalendar | calendarSlot | column-safe |
| ui/family/AttendanceScreen.java | 410 | renderDetail | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 61 | showList | root | column-safe |
| ui/family/DailyAssignmentsActivity.java | 113 | render | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 118 | render | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 132 | render | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 138 | render | root | column-safe |
| ui/family/DailyAssignmentsActivity.java | 177 | showForm | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 180 | showForm | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 183 | showForm | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 187 | showForm | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 190 | showForm | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 197 | showForm | card | column-safe |
| ui/family/DailyAssignmentsActivity.java | 221 | showForm | root | column-safe |
| ui/family/DocumentsActivity.java | 55 | showList | root | column-safe |
| ui/family/DocumentsActivity.java | 106 | render | root | column-safe |
| ui/family/DocumentsActivity.java | 116 | showForm | card | column-safe |
| ui/family/DocumentsActivity.java | 119 | showForm | card | column-safe |
| ui/family/DocumentsActivity.java | 142 | showForm | root | column-safe |
| ui/family/DownloadsScreen.java | 52 | build | page.content | column-safe |
| ui/family/DownloadsScreen.java | 102 | render | body | column-safe |
| ui/family/DownloadsScreen.java | 106 | render | body | column-safe |
| ui/family/DownloadsScreen.java | 112 | render | body | column-safe |
| ui/family/DownloadsScreen.java | 119 | renderSavedSection | body | column-safe |
| ui/family/DownloadsScreen.java | 121 | renderSavedSection | body | column-safe |
| ui/family/DownloadsScreen.java | 132 | renderSavedSection | card | column-safe |
| ui/family/DownloadsScreen.java | 134 | renderSavedSection | card | column-safe |
| ui/family/DownloadsScreen.java | 177 | entryCard | card | column-safe |
| ui/family/DownloadsScreen.java | 181 | entryCard | card | column-safe |
| ui/family/DownloadsScreen.java | 183 | entryCard | card | column-safe |
| ui/family/EventsScreen.java | 57 | build | page.content | column-safe |
| ui/family/EventsScreen.java | 143 | render | body | column-safe |
| ui/family/EventsScreen.java | 147 | render | card | column-safe |
| ui/family/EventsScreen.java | 150 | render | body | column-safe |
| ui/family/EventsScreen.java | 157 | render | body | column-safe |
| ui/family/EventsScreen.java | 167 | render | list | column-safe |
| ui/family/EventsScreen.java | 169 | render | list | column-safe |
| ui/family/EventsScreen.java | 177 | render | body | column-safe |
| ui/family/EventsScreen.java | 179 | render | body | column-safe |
| ui/family/EventsScreen.java | 184 | render | list | column-safe |
| ui/family/EventsScreen.java | 186 | render | list | column-safe |
| ui/family/EventsScreen.java | 193 | render | body | column-safe |
| ui/family/ExamResultScreen.java | 48 | build | page.content | column-safe |
| ui/family/ExamResultScreen.java | 52 | build | page.content | column-safe |
| ui/family/ExamResultScreen.java | 124 | renderResult | resultSlot | column-safe |
| ui/family/ExamResultScreen.java | 127 | renderResult | resultSlot | column-safe |
| ui/family/ExamResultScreen.java | 138 | summaryCard | left | column-safe |
| ui/family/ExamResultScreen.java | 141 | summaryCard | left | column-safe |
| ui/family/ExamResultScreen.java | 149 | summaryCard | chips | column-safe |
| ui/family/ExamResultScreen.java | 162 | summaryCard | card | column-safe |
| ui/family/ExamResultScreen.java | 164 | summaryCard | card | column-safe |
| ui/family/ExamResultScreen.java | 169 | summaryCard | card | column-safe |
| ui/family/ExamResultScreen.java | 175 | summaryCard | card | column-safe |
| ui/family/ExamResultScreen.java | 178 | summaryCard | card | column-safe |
| ui/family/ExamResultScreen.java | 192 | subjectBar | l | column-safe |
| ui/family/ExamResultScreen.java | 218 | marksCard | card | column-safe |
| ui/family/ExamResultScreen.java | 241 | marksCard | card | column-safe |
| ui/family/ExamResultScreen.java | 243 | marksCard | card | column-safe |
| ui/family/ExamResultScreen.java | 246 | marksCard | card | column-safe |
| ui/family/ExamResultScreen.java | 248 | marksCard | card | column-safe |
| ui/family/ExamResultScreen.java | 264 | renderSchedule | scheduleSlot | column-safe |
| ui/family/ExamResultScreen.java | 283 | renderSchedule | card | column-safe |
| ui/family/ExamResultScreen.java | 285 | renderSchedule | card | column-safe |
| ui/family/ExamsScreen.java | 35 | build | page.content | column-safe |
| ui/family/ExamsScreen.java | 83 | render | listSlot | column-safe |
| ui/family/ExamsScreen.java | 86 | render | listSlot | column-safe |
| ui/family/ExamsScreen.java | 98 | examCard | texts | column-safe |
| ui/family/ExamsScreen.java | 101 | examCard | texts | column-safe |
| ui/family/FamilyScreen.java | 146 | fullError | l | column-safe |
| ui/family/FamilyScreen.java | 164 | emptyState | l | column-safe |
| ui/family/FeesScreen.java | 44 | build | page.content | column-safe |
| ui/family/FeesScreen.java | 65 | refresh | body | column-safe |
| ui/family/FeesScreen.java | 97 | render | body | column-safe |
| ui/family/FeesScreen.java | 101 | render | body | column-safe |
| ui/family/FeesScreen.java | 105 | render | body | column-safe |
| ui/family/FeesScreen.java | 110 | render | body | column-safe |
| ui/family/FeesScreen.java | 142 | onSuccess | slot | column-safe |
| ui/family/FeesScreen.java | 156 | summaryCard | card | column-safe |
| ui/family/FeesScreen.java | 158 | summaryCard | card | column-safe |
| ui/family/FeesScreen.java | 165 | summaryCard | card | column-safe |
| ui/family/FeesScreen.java | 170 | summaryCard | paidCol | column-safe |
| ui/family/FeesScreen.java | 176 | summaryCard | dueCol | column-safe |
| ui/family/FeesScreen.java | 184 | summaryCard | card | column-safe |
| ui/family/FeesScreen.java | 186 | summaryCard | card | column-safe |
| ui/family/FeesScreen.java | 201 | summaryCard | card | column-safe |
| ui/family/FeesScreen.java | 232 | groupSection | wrap | column-safe |
| ui/family/FeesScreen.java | 237 | groupSection | card | column-safe |
| ui/family/FeesScreen.java | 239 | groupSection | card | column-safe |
| ui/family/FeesScreen.java | 255 | lineView | wrap | column-safe |
| ui/family/FeesScreen.java | 262 | lineView | wrap | column-safe |
| ui/family/FeesScreen.java | 271 | lineView | detail | column-safe |
| ui/family/FeesScreen.java | 325 | historySection | wrap | column-safe |
| ui/family/FeesScreen.java | 337 | historySection | card | column-safe |
| ui/family/FeesScreen.java | 339 | historySection | card | column-safe |
| ui/family/FeesScreen.java | 383 | showReceipt | l | column-safe |
| ui/family/FeesScreen.java | 387 | showReceipt | l | column-safe |
| ui/family/FeesScreen.java | 391 | showReceipt | l | column-safe |
| ui/family/FeesScreen.java | 393 | showReceipt | l | column-safe |
| ui/family/FeesScreen.java | 401 | showReceipt | l | column-safe |
| ui/family/FeesScreen.java | 407 | showReceipt | l | column-safe |
| ui/family/FeesScreen.java | 411 | showReceipt | l | column-safe |
| ui/family/HomeScreen.java | 86 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 99 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 129 | build | hero | column-safe |
| ui/family/HomeScreen.java | 135 | build | hero | column-safe |
| ui/family/HomeScreen.java | 147 | build | stats | column-safe |
| ui/family/HomeScreen.java | 150 | build | stats | column-safe |
| ui/family/HomeScreen.java | 156 | build | hero | column-safe |
| ui/family/HomeScreen.java | 160 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 168 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 175 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 180 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 185 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 190 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 203 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 215 | build | page.content | column-safe |
| ui/family/HomeScreen.java | 265 | bentoTile | t | column-safe |
| ui/family/HomeScreen.java | 476 | onData | l | column-safe |
| ui/family/HomeScreen.java | 478 | onData | l | column-safe |
| ui/family/HomeScreen.java | 559 | onData | l | column-safe |
| ui/family/HomeScreen.java | 590 | feeFigure | col | column-safe |
| ui/family/HomeScreen.java | 612 | onData | l | column-safe |
| ui/family/HomeScreen.java | 614 | onData | l | column-safe |
| ui/family/HomeScreen.java | 694 | onData | l | column-safe |
| ui/family/HomeScreen.java | 699 | onData | l | column-safe |
| ui/family/HomeworkDetailActivity.java | 77 | onCreate | root | column-safe |
| ui/family/HomeworkDetailActivity.java | 97 | onCreate | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 99 | onCreate | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 102 | onCreate | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 118 | onCreate | root | column-safe |
| ui/family/HomeworkDetailActivity.java | 121 | onCreate | root | column-safe |
| ui/family/HomeworkDetailActivity.java | 132 | evaluationCard | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 151 | evaluationCard | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 153 | evaluationCard | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 156 | evaluationCard | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 164 | evalRow | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 166 | evalRow | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 183 | submitCard | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 187 | submitCard | card | column-safe |
| ui/family/HomeworkDetailActivity.java | 210 | submitCard | card | column-safe |
| ui/family/HomeworkScreen.java | 47 | build | page.content | column-safe |
| ui/family/HomeworkScreen.java | 50 | build | page.content | column-safe |
| ui/family/HomeworkScreen.java | 186 | addSection | listSlot | column-safe |
| ui/family/HomeworkScreen.java | 188 | addSection | listSlot | column-safe |
| ui/family/HomeworkScreen.java | 193 | addSection | card | column-safe |
| ui/family/HomeworkScreen.java | 195 | addSection | card | column-safe |
| ui/family/HomeworkScreen.java | 212 | itemRow | texts | column-safe |
| ui/family/LeavesActivity.java | 70 | showList | root | column-safe |
| ui/family/LeavesActivity.java | 108 | renderLeaves | root | column-safe |
| ui/family/LeavesActivity.java | 128 | leaveCard | card | column-safe |
| ui/family/LeavesActivity.java | 132 | leaveCard | card | column-safe |
| ui/family/LeavesActivity.java | 137 | leaveCard | card | column-safe |
| ui/family/LeavesActivity.java | 151 | leaveCard | card | column-safe |
| ui/family/LeavesActivity.java | 201 | showForm | card | column-safe |
| ui/family/LeavesActivity.java | 204 | showForm | card | column-safe |
| ui/family/LeavesActivity.java | 207 | showForm | card | column-safe |
| ui/family/LeavesActivity.java | 209 | showForm | card | column-safe |
| ui/family/LeavesActivity.java | 213 | showForm | card | column-safe |
| ui/family/LeavesActivity.java | 237 | showForm | root | column-safe |
| ui/family/LeavesActivity.java | 263 | dateField | group | column-safe |
| ui/family/LessonPlanActivity.java | 129 | renderWeek | root | column-safe |
| ui/family/LessonPlanActivity.java | 152 | renderWeek | card | column-safe |
| ui/family/LessonPlanActivity.java | 160 | renderWeek | root | column-safe |
| ui/family/LessonPlanActivity.java | 164 | renderWeek | root | column-safe |
| ui/family/LessonPlanActivity.java | 180 | showForum | root | column-safe |
| ui/family/LessonPlanActivity.java | 185 | showForum | root | column-safe |
| ui/family/LessonPlanActivity.java | 190 | showForum | composer | column-safe |
| ui/family/LessonPlanActivity.java | 241 | renderForum | card | column-safe |
| ui/family/LessonPlanActivity.java | 244 | renderForum | card | column-safe |
| ui/family/LessonPlanActivity.java | 251 | renderForum | forumSlot | column-safe |
| ui/family/LibraryScreen.java | 52 | build | page.content | column-safe |
| ui/family/LibraryScreen.java | 65 | build | page.content | column-safe |
| ui/family/LibraryScreen.java | 78 | build | page.content | column-safe |
| ui/family/LibraryScreen.java | 177 | render | body | column-safe |
| ui/family/LibraryScreen.java | 182 | render | card | column-safe |
| ui/family/LibraryScreen.java | 184 | render | card | column-safe |
| ui/family/LibraryScreen.java | 190 | render | body | column-safe |
| ui/family/LibraryScreen.java | 192 | render | body | column-safe |
| ui/family/LibraryScreen.java | 197 | render | card | column-safe |
| ui/family/LibraryScreen.java | 199 | render | card | column-safe |
| ui/family/LibraryScreen.java | 205 | render | body | column-safe |
| ui/family/LibraryScreen.java | 234 | renderCatalogue | card | column-safe |
| ui/family/LibraryScreen.java | 236 | renderCatalogue | card | column-safe |
| ui/family/LibraryScreen.java | 241 | renderCatalogue | body | column-safe |
| ui/family/MainActivity.java | 157 | showChildSwitcher | list | column-safe |
| ui/family/MainActivity.java | 188 | showChildSwitcher | list | column-safe |
| ui/family/MoreScreen.java | 142 | render | content | column-safe |
| ui/family/MoreScreen.java | 160 | render | content | column-safe |
| ui/family/MoreScreen.java | 208 | render | content | column-safe |
| ui/family/MoreScreen.java | 213 | render | content | column-safe |
| ui/family/MoreScreen.java | 219 | render | kidsCard | column-safe |
| ui/family/MoreScreen.java | 221 | render | kidsCard | column-safe |
| ui/family/MoreScreen.java | 225 | render | content | column-safe |
| ui/family/MoreScreen.java | 236 | render | account | column-safe |
| ui/family/MoreScreen.java | 238 | render | account | column-safe |
| ui/family/MoreScreen.java | 248 | render | account | column-safe |
| ui/family/MoreScreen.java | 250 | render | account | column-safe |
| ui/family/MoreScreen.java | 289 | tile | t | column-safe |
| ui/family/NoticeDetailActivity.java | 52 | onCreate | root | column-safe |
| ui/family/NoticeDetailActivity.java | 56 | onCreate | card | column-safe |
| ui/family/NoticeDetailActivity.java | 62 | onCreate | card | column-safe |
| ui/family/NoticeDetailActivity.java | 64 | onCreate | card | column-safe |
| ui/family/NoticeDetailActivity.java | 67 | onCreate | card | column-safe |
| ui/family/NoticesScreen.java | 36 | build | page.content | column-safe |
| ui/family/NoticesScreen.java | 83 | render | listSlot | column-safe |
| ui/family/NoticesScreen.java | 111 | noticeCard | texts | column-safe |
| ui/family/NoticesScreen.java | 116 | noticeCard | texts | column-safe |
| ui/family/OfflinePaymentsActivity.java | 65 | showList | root | column-safe |
| ui/family/OfflinePaymentsActivity.java | 82 | onSuccess | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 85 | onSuccess | slot | column-safe |
| ui/family/OfflinePaymentsActivity.java | 140 | render | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 149 | render | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 155 | render | slot | column-safe |
| ui/family/OfflinePaymentsActivity.java | 251 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 273 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 276 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 281 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 284 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 289 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 292 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 295 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 298 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 301 | buildForm | card | column-safe |
| ui/family/OfflinePaymentsActivity.java | 325 | buildForm | root | column-safe |
| ui/family/OnlineExamAttemptActivity.java | 173 | showQuestion | root | column-safe |
| ui/family/OnlineExamAttemptActivity.java | 177 | showQuestion | card | column-safe |
| ui/family/OnlineExamAttemptActivity.java | 180 | showQuestion | card | column-safe |
| ui/family/OnlineExamAttemptActivity.java | 217 | showQuestion | root | column-safe |
| ui/family/OnlineExamResultActivity.java | 84 | render | card | column-safe |
| ui/family/OnlineExamResultActivity.java | 87 | render | card | column-safe |
| ui/family/OnlineExamResultActivity.java | 89 | render | card | column-safe |
| ui/family/OnlineExamResultActivity.java | 98 | render | root | column-safe |
| ui/family/OnlineExamResultActivity.java | 101 | render | q | column-safe |
| ui/family/OnlineExamResultActivity.java | 111 | render | q | column-safe |
| ui/family/OnlineExamResultActivity.java | 132 | render | q | column-safe |
| ui/family/OnlineExamsActivity.java | 76 | build | root | column-safe |
| ui/family/OnlineExamsActivity.java | 150 | render | card | column-safe |
| ui/family/OnlineExamsActivity.java | 153 | render | card | column-safe |
| ui/family/OnlineExamsActivity.java | 180 | render | card | column-safe |
| ui/family/OnlineExamsActivity.java | 184 | render | listSlot | column-safe |
| ui/family/ProfileEditActivity.java | 83 | buildForm | card | column-safe |
| ui/family/ProfileEditActivity.java | 86 | buildForm | card | column-safe |
| ui/family/ProfileEditActivity.java | 89 | buildForm | card | column-safe |
| ui/family/ProfileEditActivity.java | 114 | buildForm | root | column-safe |
| ui/family/ProfileScreen.java | 45 | build | page.content | column-safe |
| ui/family/ProfileScreen.java | 86 | render | body | column-safe |
| ui/family/ProfileScreen.java | 88 | render | body | column-safe |
| ui/family/ProfileScreen.java | 92 | render | body | column-safe |
| ui/family/ProfileScreen.java | 96 | render | body | column-safe |
| ui/family/ProfileScreen.java | 99 | render | body | column-safe |
| ui/family/ProfileScreen.java | 101 | render | body | column-safe |
| ui/family/ProfileScreen.java | 115 | hero | hero | column-safe |
| ui/family/ProfileScreen.java | 126 | hero | hero | column-safe |
| ui/family/ProfileScreen.java | 131 | hero | hero | column-safe |
| ui/family/ProfileScreen.java | 142 | detailsCard | card | column-safe |
| ui/family/ProfileScreen.java | 166 | familyCard | card | column-safe |
| ui/family/ProfileScreen.java | 187 | childrenCard | card | column-safe |
| ui/family/ProfileScreen.java | 212 | childrenCard | card | column-safe |
| ui/family/ProfileScreen.java | 214 | childrenCard | card | column-safe |
| ui/family/ProfileScreen.java | 229 | recordsCard | card | column-safe |
| ui/family/ProfileScreen.java | 231 | recordsCard | card | column-safe |
| ui/family/ProfileScreen.java | 240 | onSuccess | card | column-safe |
| ui/family/ProfileScreen.java | 242 | onSuccess | card | column-safe |
| ui/family/ProfileScreen.java | 258 | onSuccess | card | column-safe |
| ui/family/ProfileScreen.java | 260 | onSuccess | card | column-safe |
| ui/family/ProfileScreen.java | 292 | settingsCard | card | column-safe |
| ui/family/ProfileScreen.java | 305 | settingsCard | card | column-safe |
| ui/family/ProfileScreen.java | 307 | settingsCard | card | column-safe |
| ui/family/ProfileScreen.java | 320 | settingsCard | card | column-safe |
| ui/family/ProfileScreen.java | 322 | settingsCard | card | column-safe |
| ui/family/ProfileScreen.java | 343 | row | card | column-safe |
| ui/family/ProfileScreen.java | 345 | row | card | column-safe |
| ui/family/ProfileScreen.java | 360 | person | card | column-safe |
| ui/family/ProfileScreen.java | 362 | person | card | column-safe |
| ui/family/ProfileScreen.java | 368 | person | texts | column-safe |
| ui/family/StudentCardScreen.java | 50 | build | page.content | column-safe |
| ui/family/StudentCardScreen.java | 53 | build | page.content | column-safe |
| ui/family/SubjectsScreen.java | 34 | build | page.content | column-safe |
| ui/family/SubjectsScreen.java | 82 | render | body | column-safe |
| ui/family/SubjectsScreen.java | 100 | render | card | column-safe |
| ui/family/SubjectsScreen.java | 102 | render | card | column-safe |
| ui/family/SubjectsScreen.java | 107 | render | body | column-safe |
| ui/family/SyllabusActivity.java | 100 | renderSubjects | card | column-safe |
| ui/family/SyllabusActivity.java | 117 | renderSubjects | card | column-safe |
| ui/family/SyllabusActivity.java | 125 | renderSubjects | root (via local var sp) | column-safe |
| ui/family/SyllabusActivity.java | 174 | renderLessons | card | column-safe |
| ui/family/SyllabusActivity.java | 177 | renderLessons | card | column-safe |
| ui/family/SyllabusActivity.java | 190 | renderLessons | card | column-safe |
| ui/family/SyllabusActivity.java | 195 | renderLessons | root | column-safe |
| ui/family/TeachersActivity.java | 102 | render | card | column-safe |
| ui/family/TeachersActivity.java | 105 | render | card | column-safe |
| ui/family/TeachersActivity.java | 107 | render | card | column-safe |
| ui/family/TeachersActivity.java | 116 | render | card | column-safe |
| ui/family/TeachersActivity.java | 121 | render | card | column-safe |
| ui/family/TeachersActivity.java | 128 | render | card | column-safe |
| ui/family/TeachersActivity.java | 131 | render | card | column-safe |
| ui/family/TeachersActivity.java | 133 | render | card | column-safe |
| ui/family/TeachersActivity.java | 164 | render | root | column-safe |
| ui/family/TimelineActivity.java | 57 | showList | root | column-safe |
| ui/family/TimelineActivity.java | 99 | render | card | column-safe |
| ui/family/TimelineActivity.java | 104 | render | card | column-safe |
| ui/family/TimelineActivity.java | 118 | render | card | column-safe |
| ui/family/TimelineActivity.java | 124 | render | root | column-safe |
| ui/family/TimelineActivity.java | 160 | showForm | card | column-safe |
| ui/family/TimelineActivity.java | 163 | showForm | card | column-safe |
| ui/family/TimelineActivity.java | 165 | showForm | card | column-safe |
| ui/family/TimelineActivity.java | 170 | showForm | card | column-safe |
| ui/family/TimelineActivity.java | 172 | showForm | card | column-safe |
| ui/family/TimelineActivity.java | 176 | showForm | card | column-safe |
| ui/family/TimelineActivity.java | 199 | showForm | root | column-safe |
| ui/family/TimetableScreen.java | 50 | build | page.content | column-safe |
| ui/family/TimetableScreen.java | 53 | build | page.content | column-safe |
| ui/family/TimetableScreen.java | 188 | renderList | card | column-safe |
| ui/family/TimetableScreen.java | 190 | renderList | card | column-safe |
| ui/family/TransportScreen.java | 44 | build | page.content | column-safe |
| ui/family/TransportScreen.java | 129 | render | card | column-safe |
| ui/family/TransportScreen.java | 133 | render | card | column-safe |
| ui/family/TransportScreen.java | 135 | render | card | column-safe |
| ui/family/TransportScreen.java | 139 | render | body | column-safe |
| ui/family/TransportScreen.java | 153 | render | bus | column-safe |
| ui/family/TransportScreen.java | 162 | render | bus | column-safe |
| ui/family/TransportScreen.java | 164 | render | bus | column-safe |
| ui/family/TransportScreen.java | 172 | render | body | column-safe |
| ui/family/TransportScreen.java | 174 | render | body | column-safe |
| ui/family/TransportScreen.java | 180 | render | others | column-safe |
| ui/family/TransportScreen.java | 182 | render | others | column-safe |
| ui/family/TransportScreen.java | 213 | personRow | texts | column-safe |
| ui/family/WaveBActivity.java | 115 | emptyView | l | column-safe |
| ui/family/WaveBActivity.java | 130 | errorView | l | column-safe |
| ui/staff/StaffBankPaymentActivity.java | 58 | onCreate | root | column-safe |
| ui/staff/StaffBankPaymentActivity.java | 83 | onCreate | root | column-safe |
| ui/staff/StaffBankPaymentActivity.java | 111 | review | content | column-safe |
| ui/staff/StaffBankPaymentActivity.java | 117 | review | content | column-safe |
| ui/staff/StaffBankPaymentActivity.java | 123 | review | content | column-safe |
| ui/staff/StaffBankPaymentActivity.java | 132 | review | content | column-safe |
| ui/staff/StaffBankPaymentActivity.java | 145 | review | content | column-safe |
| ui/staff/StaffCalendarActivity.java | 46 | onCreate | root | column-safe |
| ui/staff/StaffCalendarActivity.java | 103 | render | box | column-safe |
| ui/staff/StaffCalendarActivity.java | 106 | render | box | column-safe |
| ui/staff/StaffCallLogActivity.java | 47 | onCreate | root | column-safe |
| ui/staff/StaffCallLogActivity.java | 51 | onCreate | root | column-safe |
| ui/staff/StaffCallLogActivity.java | 120 | renderForm | formBox | column-safe |
| ui/staff/StaffCallLogActivity.java | 123 | renderForm | form | column-safe |
| ui/staff/StaffCallLogActivity.java | 127 | renderForm | form | column-safe |
| ui/staff/StaffCallLogActivity.java | 131 | renderForm | form | column-safe |
| ui/staff/StaffCallLogActivity.java | 136 | renderForm | form | column-safe |
| ui/staff/StaffCallLogActivity.java | 141 | renderForm | form | column-safe |
| ui/staff/StaffCallLogActivity.java | 145 | renderForm | form | column-safe |
| ui/staff/StaffClassesActivity.java | 51 | onCreate | root | column-safe |
| ui/staff/StaffClassesActivity.java | 54 | onCreate | root | column-safe |
| ui/staff/StaffComplaintsActivity.java | 51 | onCreate | root | column-safe |
| ui/staff/StaffComplaintsActivity.java | 62 | onCreate | root | column-safe |
| ui/staff/StaffComplaintsActivity.java | 65 | onCreate | root | column-safe |
| ui/staff/StaffComplaintsActivity.java | 142 | row | col | column-safe |
| ui/staff/StaffComplaintsActivity.java | 151 | renderUpdateForm | form | column-safe |
| ui/staff/StaffComplaintsActivity.java | 158 | renderUpdateForm | form | column-safe |
| ui/staff/StaffComplaintsActivity.java | 165 | renderUpdateForm | form | column-safe |
| ui/staff/StaffComplaintsActivity.java | 169 | renderUpdateForm | form | column-safe |
| ui/staff/StaffComplaintsActivity.java | 215 | renderForm | formBox | column-safe |
| ui/staff/StaffComplaintsActivity.java | 218 | renderForm | form | column-safe |
| ui/staff/StaffComplaintsActivity.java | 223 | renderForm | form | column-safe |
| ui/staff/StaffComplaintsActivity.java | 227 | renderForm | form | column-safe |
| ui/staff/StaffComplaintsActivity.java | 231 | renderForm | form | column-safe |
| ui/staff/StaffComplaintsActivity.java | 236 | renderForm | form | column-safe |
| ui/staff/StaffDirectoryActivity.java | 55 | onCreate | root | column-safe |
| ui/staff/StaffDirectoryActivity.java | 81 | onCreate | root | column-safe |
| ui/staff/StaffDirectoryActivity.java | 128 | render | box | column-safe |
| ui/staff/StaffDirectoryActivity.java | 139 | render | box | column-safe |
| ui/staff/StaffDirectoryDetailActivity.java | 42 | onCreate | root | column-safe |
| ui/staff/StaffDirectoryDetailActivity.java | 86 | render | box | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 64 | onCreate | root | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 81 | onCreate | root | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 90 | onCreate | root | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 93 | onCreate | root | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 188 | renderForm | formBox | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 191 | renderForm | form | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 195 | renderForm | form | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 199 | renderForm | form | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 203 | renderForm | form | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 208 | renderForm | form | column-safe |
| ui/staff/StaffEnquiriesActivity.java | 212 | renderForm | form | column-safe |
| ui/staff/StaffEnquiryDetailActivity.java | 50 | onCreate | root | column-safe |
| ui/staff/StaffEnquiryDetailActivity.java | 95 | render | card | column-safe |
| ui/staff/StaffEnquiryDetailActivity.java | 103 | render | box | column-safe |
| ui/staff/StaffEnquiryDetailActivity.java | 105 | render | box | column-safe |
| ui/staff/StaffEnquiryDetailActivity.java | 118 | render | box | column-safe |
| ui/staff/StaffEnquiryDetailActivity.java | 138 | followUpForm | form | column-safe |
| ui/staff/StaffEnquiryDetailActivity.java | 144 | followUpForm | form | column-safe |
| ui/staff/StaffEnquiryDetailActivity.java | 149 | followUpForm | form | column-safe |
| ui/staff/StaffEnquiryDetailActivity.java | 152 | followUpForm | form | column-safe |
| ui/staff/StaffFeeReceiptActivity.java | 39 | onCreate | root | column-safe |
| ui/staff/StaffFeeReceiptActivity.java | 81 | render | card | column-safe |
| ui/staff/StaffFeeReceiptActivity.java | 83 | render | card | column-safe |
| ui/staff/StaffFeeReceiptActivity.java | 115 | render | card | column-safe |
| ui/staff/StaffFeeReceiptActivity.java | 145 | render | box | column-safe |
| ui/staff/StaffFeeStatementActivity.java | 46 | onCreate | root | column-safe |
| ui/staff/StaffFeeStatementActivity.java | 97 | render | box | column-safe |
| ui/staff/StaffFeeStatementActivity.java | 101 | render | box | column-safe |
| ui/staff/StaffFeeStatementActivity.java | 109 | render | card | column-safe |
| ui/staff/StaffFeeStatementActivity.java | 127 | render | box | column-safe |
| ui/staff/StaffFeeStatementActivity.java | 137 | render | box | column-safe |
| ui/staff/StaffFeeStatementActivity.java | 141 | render | box | column-safe |
| ui/staff/StaffFeeStatementActivity.java | 150 | render | box | column-safe |
| ui/staff/StaffFeesActivity.java | 126 | onCreate | root | column-safe |
| ui/staff/StaffFeesActivity.java | 135 | onCreate | root | column-safe |
| ui/staff/StaffFeesActivity.java | 139 | onCreate | root | column-safe |
| ui/staff/StaffFeesActivity.java | 160 | onCreate | root | column-safe |
| ui/staff/StaffFeesActivity.java | 282 | pickStudent | invoiceBox | column-safe |
| ui/staff/StaffFeesActivity.java | 285 | pickStudent | invoiceBox | column-safe |
| ui/staff/StaffFeesActivity.java | 303 | onError | invoiceBox | column-safe |
| ui/staff/StaffFeesActivity.java | 314 | renderInvoice | invoiceBox | column-safe |
| ui/staff/StaffFeesActivity.java | 317 | renderInvoice | invoiceBox | column-safe |
| ui/staff/StaffFeesActivity.java | 334 | renderInvoice | invoiceBox | column-safe |
| ui/staff/StaffFeesActivity.java | 381 | renderPayForm | payBox | column-safe |
| ui/staff/StaffFeesActivity.java | 383 | renderPayForm | payBox | column-safe |
| ui/staff/StaffFeesActivity.java | 388 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 391 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 394 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 397 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 400 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 403 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 411 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 414 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 420 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 422 | renderPayForm | form | column-safe |
| ui/staff/StaffFeesActivity.java | 534 | renderDone | doneBox | column-safe |
| ui/staff/StaffFeesActivity.java | 538 | renderDone | card | column-safe |
| ui/staff/StaffFeesActivity.java | 542 | renderDone | card | column-safe |
| ui/staff/StaffFeesActivity.java | 552 | renderDone | card | column-safe |
| ui/staff/StaffFeesActivity.java | 565 | renderDone | card | column-safe |
| ui/staff/StaffFeesDeskActivity.java | 78 | onCreate | root | column-safe |
| ui/staff/StaffFeesDeskActivity.java | 81 | onCreate | root | column-safe |
| ui/staff/StaffFeesDeskActivity.java | 106 | onCreate | root | column-safe |
| ui/staff/StaffFeesDeskActivity.java | 210 | renderDue | box | column-safe |
| ui/staff/StaffFeesDeskActivity.java | 221 | renderDue | box | column-safe |
| ui/staff/StaffFeesDeskActivity.java | 307 | renderPayments | box | column-safe |
| ui/staff/StaffFeesDeskActivity.java | 318 | renderPayments | box | column-safe |
| ui/staff/StaffFrontOfficeActivity.java | 32 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 88 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 93 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 96 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 100 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 103 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 112 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 122 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 125 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 148 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 151 | onCreate | root | column-safe |
| ui/staff/StaffHomeActivity.java | 184 | quickTile | tile | column-safe |
| ui/staff/StaffHomeActivity.java | 254 | renderStats | statsBox | column-safe |
| ui/staff/StaffHomeActivity.java | 261 | renderStats | statsBox | column-safe |
| ui/staff/StaffHomeActivity.java | 281 | renderStats | card | column-safe |
| ui/staff/StaffHomeActivity.java | 313 | statCard | card | column-safe |
| ui/staff/StaffHomeActivity.java | 343 | onError | worklistBox | column-safe |
| ui/staff/StaffHomeActivity.java | 346 | onError | worklistBox | column-safe |
| ui/staff/StaffHomeActivity.java | 358 | renderWorklist | worklistBox | column-safe |
| ui/staff/StaffHomeActivity.java | 361 | renderWorklist | worklistBox | column-safe |
| ui/staff/StaffHomeActivity.java | 377 | renderWorklist | row | row-fixed |
| ui/staff/StaffHomeworkActivity.java | 87 | onCreate | root | column-safe |
| ui/staff/StaffHomeworkActivity.java | 91 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 105 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 108 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 122 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 125 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 129 | onCreate | chips | row-fixed |
| ui/staff/StaffHomeworkActivity.java | 148 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 150 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 153 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 162 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 164 | onCreate | form | column-safe |
| ui/staff/StaffHomeworkActivity.java | 169 | onCreate | root | column-safe |
| ui/staff/StaffHomeworkActivity.java | 172 | onCreate | root | column-safe |
| ui/staff/StaffHomeworkActivity.java | 289 | pickSubject | col | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 57 | onCreate | root | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 113 | render | card | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 116 | render | card | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 143 | render | box | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 146 | render | box | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 148 | render | box | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 159 | render | box | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 210 | submissionRow | col | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 224 | submissionRow | col | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 276 | renderEditForm | editBox | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 279 | renderEditForm | form | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 287 | renderEditForm | form | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 304 | renderEditForm | form | column-safe |
| ui/staff/StaffHomeworkDetailActivity.java | 311 | renderEditForm | form | column-safe |
| ui/staff/StaffHomeworkListActivity.java | 46 | onCreate | root | column-safe |
| ui/staff/StaffHomeworkListActivity.java | 55 | onCreate | root | column-safe |
| ui/staff/StaffHomeworkListActivity.java | 58 | onCreate | root | column-safe |
| ui/staff/StaffLeaveApprovalsActivity.java | 52 | onCreate | root | column-safe |
| ui/staff/StaffLeaveApprovalsActivity.java | 61 | onCreate | root | column-safe |
| ui/staff/StaffLeaveApprovalsActivity.java | 124 | row | col | column-safe |
| ui/staff/StaffLeaveApprovalsActivity.java | 142 | review | content | column-safe |
| ui/staff/StaffLeaveApprovalsActivity.java | 155 | review | content | column-safe |
| ui/staff/StaffLeaveApprovalsActivity.java | 158 | review | content | column-safe |
| ui/staff/StaffLeaveApprovalsActivity.java | 168 | review | content | column-safe |
| ui/staff/StaffLeaveApprovalsActivity.java | 177 | review | content | column-safe |
| ui/staff/StaffMarkActivity.java | 95 | onCreate | root | column-safe |
| ui/staff/StaffMarkActivity.java | 121 | onCreate | root | column-safe |
| ui/staff/StaffMarkActivity.java | 135 | onCreate | root | column-safe |
| ui/staff/StaffMarkActivity.java | 319 | studentRow | col | column-safe |
| ui/staff/StaffMarkActivity.java | 322 | studentRow | col | column-safe |
| ui/staff/StaffMoreActivity.java | 45 | onCreate | root | column-safe |
| ui/staff/StaffMoreActivity.java | 166 | render | box | column-safe |
| ui/staff/StaffMoreActivity.java | 179 | section | box | column-safe |
| ui/staff/StaffMoreActivity.java | 181 | section | box | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 63 | onCreate | root | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 67 | onCreate | root | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 69 | onCreate | root | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 102 | renderForm | form | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 104 | renderForm | form | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 117 | renderForm | form | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 134 | renderForm | form | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 141 | renderForm | form | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 143 | renderForm | form | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 148 | renderForm | form | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 150 | renderForm | form | column-safe |
| ui/staff/StaffMyLeavesActivity.java | 160 | pickType | content | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 53 | onCreate | root | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 93 | render | card | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 95 | render | card | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 108 | render | box | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 135 | renderEditForm | editBox | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 138 | renderEditForm | form | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 142 | renderEditForm | form | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 149 | renderEditForm | form | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 151 | renderEditForm | form | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 169 | renderEditForm | form | column-safe |
| ui/staff/StaffNoticeDetailActivity.java | 171 | renderEditForm | form | column-safe |
| ui/staff/StaffNoticesActivity.java | 65 | onCreate | root | column-safe |
| ui/staff/StaffNoticesActivity.java | 69 | onCreate | form | column-safe |
| ui/staff/StaffNoticesActivity.java | 72 | onCreate | form | column-safe |
| ui/staff/StaffNoticesActivity.java | 75 | onCreate | form | column-safe |
| ui/staff/StaffNoticesActivity.java | 81 | onCreate | form | column-safe |
| ui/staff/StaffNoticesActivity.java | 84 | onCreate | form | column-safe |
| ui/staff/StaffNoticesActivity.java | 97 | onCreate | form | column-safe |
| ui/staff/StaffNoticesActivity.java | 99 | onCreate | form | column-safe |
| ui/staff/StaffNoticesActivity.java | 104 | onCreate | root | column-safe |
| ui/staff/StaffNoticesActivity.java | 107 | onCreate | root | column-safe |
| ui/staff/StaffNoticesBoardActivity.java | 44 | onCreate | root | column-safe |
| ui/staff/StaffNoticesBoardActivity.java | 53 | onCreate | root | column-safe |
| ui/staff/StaffNoticesBoardActivity.java | 56 | onCreate | root | column-safe |
| ui/staff/StaffNoticesBoardActivity.java | 128 | row | col | column-safe |
| ui/staff/StaffPostalActivity.java | 47 | onCreate | root | column-safe |
| ui/staff/StaffPostalActivity.java | 57 | onCreate | root | column-safe |
| ui/staff/StaffPostalActivity.java | 60 | onCreate | root | column-safe |
| ui/staff/StaffPostalActivity.java | 125 | renderForm | formBox | column-safe |
| ui/staff/StaffPostalActivity.java | 128 | renderForm | form | column-safe |
| ui/staff/StaffPostalActivity.java | 132 | renderForm | form | column-safe |
| ui/staff/StaffPostalActivity.java | 136 | renderForm | form | column-safe |
| ui/staff/StaffPostalActivity.java | 140 | renderForm | form | column-safe |
| ui/staff/StaffPostalActivity.java | 144 | renderForm | form | column-safe |
| ui/staff/StaffProfileActivity.java | 58 | onCreate | root | column-safe |
| ui/staff/StaffProfileActivity.java | 71 | onCreate | head | column-safe |
| ui/staff/StaffProfileActivity.java | 73 | onCreate | head | column-safe |
| ui/staff/StaffProfileActivity.java | 96 | onCreate | root | column-safe |
| ui/staff/StaffProfileActivity.java | 100 | onCreate | root | column-safe |
| ui/staff/StaffProfileActivity.java | 111 | onCreate | root | column-safe |
| ui/staff/StaffQrActivity.java | 125 | onCreate | root | column-safe |
| ui/staff/StaffQrActivity.java | 151 | onCreate | root | column-safe |
| ui/staff/StaffQrActivity.java | 162 | onCreate | root | column-safe |
| ui/staff/StaffQrActivity.java | 165 | onCreate | root | column-safe |
| ui/staff/StaffRegisterActivity.java | 91 | onCreate | root | column-safe |
| ui/staff/StaffRegisterActivity.java | 106 | onCreate | root | column-safe |
| ui/staff/StaffRegisterActivity.java | 119 | onCreate | root | column-safe |
| ui/staff/StaffRegisterActivity.java | 123 | onCreate | root | column-safe |
| ui/staff/StaffRegisterActivity.java | 287 | studentRow | col | column-safe |
| ui/staff/StaffRegisterActivity.java | 297 | studentRow | col | column-safe |
| ui/staff/StaffRegisterActivity.java | 316 | studentRow | col | column-safe |
| ui/staff/StaffRosterActivity.java | 59 | onCreate | root | column-safe |
| ui/staff/StaffRosterActivity.java | 112 | render | box | column-safe |
| ui/staff/StaffStudentActivity.java | 58 | onCreate | root | column-safe |
| ui/staff/StaffStudentActivity.java | 108 | render | head | column-safe |
| ui/staff/StaffStudentActivity.java | 110 | render | head | column-safe |
| ui/staff/StaffStudentActivity.java | 117 | render | box | column-safe |
| ui/staff/StaffStudentActivity.java | 128 | render | box | column-safe |
| ui/staff/StaffStudentActivity.java | 137 | render | box | column-safe |
| ui/staff/StaffStudentActivity.java | 141 | render | box | column-safe |
| ui/staff/StaffStudentActivity.java | 153 | render | box | column-safe |
| ui/staff/StaffStudentActivity.java | 156 | render | box | column-safe |
| ui/staff/StaffStudentActivity.java | 173 | render | box | column-safe |
| ui/staff/StaffStudentEditActivity.java | 90 | onCreate | root | column-safe |
| ui/staff/StaffStudentEditActivity.java | 145 | renderForm | head | column-safe |
| ui/staff/StaffStudentEditActivity.java | 147 | renderForm | head | column-safe |
| ui/staff/StaffStudentEditActivity.java | 171 | renderForm | box | column-safe |
| ui/staff/StaffStudentEditActivity.java | 177 | renderForm | box | column-safe |
| ui/staff/StaffStudentEditActivity.java | 184 | renderForm | box | column-safe |
| ui/staff/StaffStudentEditActivity.java | 207 | groupCard | card | column-safe |
| ui/staff/StaffStudentEditActivity.java | 212 | groupCard | card | column-safe |
| ui/staff/StaffStudentEditActivity.java | 215 | groupCard | card | column-safe |
| ui/staff/StaffStudentEditActivity.java | 221 | groupCard | card | column-safe |
| ui/staff/StaffStudentLeavesActivity.java | 55 | onCreate | root | column-safe |
| ui/staff/StaffStudentLeavesActivity.java | 65 | onCreate | root | column-safe |
| ui/staff/StaffStudentLeavesActivity.java | 131 | row | col | column-safe |
| ui/staff/StaffStudentLeavesActivity.java | 161 | review | content | column-safe |
| ui/staff/StaffStudentLeavesActivity.java | 165 | review | content | column-safe |
| ui/staff/StaffStudentLeavesActivity.java | 174 | review | content | column-safe |
| ui/staff/StaffStudentLeavesActivity.java | 182 | review | content | column-safe |
| ui/staff/StaffStudentsActivity.java | 64 | onCreate | root | column-safe |
| ui/staff/StaffStudentsActivity.java | 86 | onCreate | root | column-safe |
| ui/staff/StaffStudentsActivity.java | 146 | renderChips | chipsBox | column-safe |
| ui/staff/StaffTasksActivity.java | 56 | onCreate | root | column-safe |
| ui/staff/StaffTasksActivity.java | 60 | onCreate | form | column-safe |
| ui/staff/StaffTasksActivity.java | 66 | onCreate | form | column-safe |
| ui/staff/StaffTasksActivity.java | 71 | onCreate | root | column-safe |
| ui/staff/StaffTasksActivity.java | 112 | render | box | column-safe |
| ui/staff/StaffTasksActivity.java | 116 | render | box | column-safe |
| ui/staff/StaffTasksActivity.java | 118 | render | box | column-safe |
| ui/staff/StaffTimetableActivity.java | 47 | onCreate | root | column-safe |
| ui/staff/StaffTimetableActivity.java | 61 | onCreate | root | column-safe |
| ui/staff/StaffTimetableActivity.java | 121 | renderClassPicker | box | column-safe |
| ui/staff/StaffTimetableActivity.java | 166 | pickSection | col | column-safe |
| ui/staff/StaffTimetableActivity.java | 210 | appendDays | holder | column-safe |
| ui/staff/StaffTimetableActivity.java | 213 | appendDays | holder | column-safe |
| ui/staff/StaffUi.java | 154 | <class-init> | card | column-safe |
| ui/staff/StaffUi.java | 167 | <class-init> | inner | column-safe |
| ui/staff/StaffUi.java | 270 | <class-init> | content | column-safe |
| ui/staff/StaffUi.java | 295 | <class-init> | content | column-safe |
| ui/staff/StaffUi.java | 298 | <class-init> | content | column-safe |
| ui/staff/StaffUi.java | 306 | <class-init> | content | column-safe |
| ui/staff/StaffUi.java | 443 | <class-init> | content | column-safe |
| ui/staff/StaffUi.java | 447 | <class-init> | content | column-safe |
| ui/staff/StaffUi.java | 455 | <class-init> | content | column-safe |
| ui/staff/StaffVisitorsActivity.java | 49 | onCreate | root | column-safe |
| ui/staff/StaffVisitorsActivity.java | 53 | onCreate | root | column-safe |
| ui/staff/StaffVisitorsActivity.java | 123 | row | col | column-safe |
| ui/staff/StaffVisitorsActivity.java | 144 | renderForm | formBox | column-safe |
| ui/staff/StaffVisitorsActivity.java | 147 | renderForm | form | column-safe |
| ui/staff/StaffVisitorsActivity.java | 151 | renderForm | form | column-safe |
| ui/staff/StaffVisitorsActivity.java | 155 | renderForm | form | column-safe |
| ui/staff/StaffVisitorsActivity.java | 159 | renderForm | form | column-safe |
| ui/staff/StaffWaitingActivity.java | 126 | render | card | column-safe |
| ui/staff/StaffWaitingActivity.java | 131 | render | box | column-safe |
| ui/staff/StaffWaitingActivity.java | 136 | render | box | column-safe |
| ui/staff/StaffWaitingActivity.java | 141 | render | box | column-safe |
| ui/staff/StaffWaitingActivity.java | 150 | render | box | column-safe |
| ui/staff/StaffWaitingActivity.java | 155 | render | box | column-safe |
| ui/staff/StaffWaitingActivity.java | 164 | render | box | column-safe |
| ui/staff/StaffWaitingActivity.java | 173 | render | box | column-safe |
| ui/staff/StaffWaitingActivity.java | 197 | attentionRow | col | column-safe |
| ui/staff/StaffWaitingActivity.java | 199 | attentionRow | col | column-safe |
