# PreSkool — Screen-wise MATCH / DRIFT / MISSING List

Prepared: 2026-11-12 · Scope: IQRS web system on **staging only** (production untouched — D-027)
Source of truth: Round 3 Lane L2 design-vs-implemented comparison (`discovery/round3/lanes/L2-design-vs-implemented.md`), ratified D-037 (2026-11-12 ~16:50 PKT), cross-checked against Phase 1–4 execution records and `implementation-status.md`.

Verdicts are code/record/HTTP-evidence based. Anything that needs eyes is listed separately in §4 — it was **not** guessed.

---

## 1. Built surfaces — scoreboard

| # | Screen / surface | Verdict | What matches | What drifts / is missing |
|---|---|---|---|---|
| 1 | **Shell** — header, sidebar, menu, global search, notifications | **DRIFT** (minor) | Anatomy preserved; search (BL-013), notifications (BL-014), saved-view worklists live; dark-mode hooks present | Shell CSS is forked per workspace instead of one shared sheet (581→697 lines, BL-030→BL-044); icon mix (FontAwesome + pk- classes) vs the D-030 decision for one Phosphor sprite; demo theme-settings panel has no counterpart — intentional, superseded by Theme Store BL-138 |
| 2 | **Auth** — staff login, portal login, forgot password, 2FA | **DRIFT** | Two-door split (staff / family) matches IQRS's real structure; PreSkool auth pattern applied (BL-015, incl. Fix-1) | Demo's left "What's New" notice panel absent — screen reads plainer than the design; forgot-password restyle depth not yet visually verified; 32 hard-coded hex values in auth CSS; no loading/skeleton state |
| 3 | **Fee Workspace — pkfees** (BL-030–BL-033) | **MATCH** | All demo fee pages covered in one workspace: overview, assignments, billing, collections, allocations, arrears, discounts, fines, corrections, offline, income, expenses + reports (12 tabs); best token discipline in the programme — 0 hex in views | Only nuance: demo splits this across separate pages, IQRS consolidates into tabs — component-level match, not page-level 1:1 (see §5) |
| 4 | **Print & Document Center** (BL-034/BL-035) | **DRIFT** | Shell-conformant; receipt + thermal receipt, reprint history, receipt logging, exam documents (marksheet, admit card, rank, notices) | No demo twin exists — this is an IQRS-native surface, so there is no PreSkool page to match; print fidelity (thermal width, page breaks) can only be judged visually — §4 |
| 5 | **Exams Workspace — pkexams** (BL-042 + BL-035/BL-042F) | **DRIFT** | 7 tabs (exams, schedule, marks, results, grades, online, CBSE) cover the demo exam set; publish/withheld states are first-class | 71 hard-coded hex + 18 inline styles in views; demo's chart-led result analytics reduced to tables; chart presence per tab needs a visual pass |
| 6 | **Students Workspace — pkstudents** (BL-043 + BL-020 profile) | **DRIFT** | 8 tabs (overview, students, profile, lifecycle, promotion, behaviour, alumni, downloads); exemplary honest empty states (alumni, behaviour) | Largest view drift so far: 90 hex, 33 inline styles; demo's student **grid (card) view MISSING** — list only; demo profile photo/ID-card components not replicated |
| 7 | **Academics Workspace — pkacademics** (BL-040) | **DRIFT** | 5 tabs (overview, timetable, syllabus, homework, analytics) cover the demo set; CEO visual pass on all 5 tabs passed | Analytics tab is table-only — no ApexCharts evidence in code, while the demo analytics is chart-led; 32 hex in views |
| 8 | **Attendance Workspace — pkattendance** (BL-041) | **DRIFT** | 7 tabs (register, by-date, period, QR, staff, leave, biometric) — QR and biometric exceed the demo | Demo's calendar/**heatmap component MISSING**; register and by-date are table-led instead of calendar-led; 53 hex in views |
| 9 | **HR Workspace — pkhr** (BL-044, fully closed 2026-11-12 ~16:47) | **DRIFT** (tentative at L2 time — lane was in-flight; build has since closed, visual verdict still owed) | 7 tabs (overview, staff, profile, structure, review, payroll, ratings); payslip proven through Print Center; ratings render recorded data only (governed read) | Worst token ratio of any wave: 109 hex literals — a theme swap would not recolour this surface today; staff leave sits in pkattendance, demo puts it under HR (IA-only drift) |
| 10 | **Portal home** — parent / student (BL-016) | **DRIFT** (largest) | Welcome block, bounded notice lists, unread alerts, QR block present and token-driven; token-clean CSS | This is a **re-skin of the vendor dashboard, not the PreSkool portal anatomy** — the one built surface that does not yet meet D-024 ("optimized + improved into PreSkool arrangement, not merely re-skinned"); demo's bespoke widget stack (fees-due cards, attendance rings, homework lists) not built; portal shell has no PreSkool layer of its own |

**Built-surface totals (L2, ratified D-037): MATCH 1 · DRIFT 8 · MISSING 0**
No whole built surface is missing. Every gap is component-level, inside a surface that exists.

---

## 2. Component-level MISSING (inside built surfaces)

- Student grid / card view (pkstudents) — list only today
- Attendance heatmap / calendar visual (pkattendance)
- Auth left notice panel ("What's New" panel from the demo login)
- Chart layer: exam-results analytics, academics analytics, dashboard widget stack — tables exist, ApexCharts visuals not evidenced in BL-040–BL-044 view code
- Illustrated empty states — IQRS empty states are honest (never demo-filled) but plain text/table rows, not the demo's illustrated components
- Loading / skeleton states — absent across workspaces
- Portal bespoke widget stack (fees-due cards, attendance rings, homework lists)
- Theme-settings panel from the demo — **intentionally missing**, superseded by the Theme Store (BL-138, after the BL-150 token sweep)

## 3. Not yet built — whole surfaces still MISSING from the system

Sequenced under D-037; production cutover comes only after all of this, as one gated package (D-027).

- BL-045 Operations · BL-046 Front Office · BL-047 Communication + full portal · BL-048 Reports / Settings
- BL-049 new modules · BL-050 deterministic AI suite
- D-015 scoped features (cafeteria wallet, governed refund completion, attendance approver layer, safe-form restore, gate chain items) — in the D-037 sequence after BL-045 / gate chain
- Round 2 remainder: Identity Foundation BL-096–BL-098 (+BL-152), BL-082 pinning, BL-115, BL-133, chatbot surface BL-137, and the rest of BL-082–BL-136
- BL-150 token sweep (fixes the drift pattern in §5) → then BL-138 Theme Store, BL-139 Apps Store, BL-140 playbook conformance
- Phase 5 (database) and Phase 6 (verification + production cutover)

## 4. Only a visual (CEO browser) pass can settle these

1. Auth pages on staging — split-panel fidelity, served CSS version, error states
2. One page per workspace — sidebar active states, header density, real rendered dark mode (with the `?v=` cache-buster fresh — BL-012 cache trap)
3. Portal home for parent + student — how far the re-skin actually reads as PreSkool
4. Print Center outputs — receipt, thermal receipt, marksheet / admit-card PDFs
5. pkexams results + pkacademics analytics — charts rendered, or tables only
6. pkattendance register — heatmap / calendar presence in the rendered page
7. Admin / teacher dashboards vs the demo widget stack (demo performer/risk widgets are CLAIM-class and must stay absent or recorded-data-only)
8. pkhr — all 7 tabs now that BL-044 has closed, especially ratings

## 5. Why completion ≠ pixel-by-pixel identical

Under the currently approved plan, the finished system will **look and feel PreSkool** — same colours (#3D5EE1, ink #202C4B), same font (Inter), same components, spacing and shell — but it will **not** be a pixel-by-pixel copy of the demo, for deliberate reasons recorded in the programme:

- **Consolidation (P5):** the demo's 386 separate pages were built as tabbed workspaces (Fees = 12 tabs in one surface, Students = 8, Exams/Attendance/HR = 7 each). Fidelity lives at component level, not page level.
- **D-024:** existing features were ordered to be *optimized + improved into the PreSkool arrangement*, not preserved as a 1:1 clone.
- **Real data ≠ demo data:** real names, counts, amounts and list lengths change layout geometry screen by screen.
- **IQRS-native surfaces** (Print Center, household/family finance, governed workflows) have no demo page to copy.
- **Demo-only / CLAIM-class content** (performer ratings, risk matrices, demo notices) is deliberately not reproduced as visuals over invented data.

**Repeat drift patterns to fix before the Theme Store:** P1 token drift compounds per wave (shell-CSS hex 4 → 109 from BL-030 to BL-044 — BL-150 sweep is sequenced for this); P2 per-wave shell-CSS forks; P3 chart-led demo anatomy becoming table-led; P4 plain (but honest) empty states; P6 three icon systems coexisting vs the single adopted Phosphor sprite.

> If pixel-by-pixel "hu-ba-hu" is what is wanted, that is a **different, larger directive** that supersedes D-024's consolidation: separate 1:1 pages instead of tabbed workspaces, demo widget anatomy rebuilt over real data, and a screenshot-diff gate per screen. It is achievable only as an explicit new decision — it is not what the current build, even when 100% complete, will deliver.
