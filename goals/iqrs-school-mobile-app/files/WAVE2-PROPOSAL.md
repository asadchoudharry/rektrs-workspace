# WAVE 2 PROPOSAL — Depth (CEO's merged proposal for owner approval)

**Date:** 2026-11-07 · **Prepared by:** CEO / Release coordinator, merging the standing team's first research cycle
**Inputs:** FEATURE-AND-DESIGN-PLAN.md §7.2 + §3 · DESIGN-RESEARCH-WAVE2.md · FEATURE-RESEARCH-WAVE2.md · IMPROVEMENTS-BACKLOG.md · APP-TEAM.md charter
**What you are approving:** one wave, built in the Wave 1 pattern — **2A API (staging) → 2B Workspace app → 2C Connect app + riders → Checker → device gate → 2D production swaps (each file with your separate approval, as always)**. One approval here covers all staging work and both app builds (§7.3 rule 1). Nothing reaches production on this approval.

**Owner commitments first.** Three items come from your own legacy-app comparison (2026-11-07) and sit at the **top** of this wave — decided, not optional:
1. **Behaviour view in Connect** — families see the behaviour score + records for their child (the family side of API-170).
2. **Family profile depth in Connect** — the full tabbed record (Personal / Parents / Other, as the legacy app shows it), not the thin profile we ship today.
3. **Receipt-photo upload in Connect** — a parent reporting an offline/bank payment can attach the receipt photo (PDF/JPG/PNG), with the upload validated on the server (the web audit found the vendor's own upload unvalidated — ours will not repeat that).

---

## §1 The wave in one page

**Workspace gains the office's depth:** Exam Centre (catalogue, marks entry, results, publish), lesson plans + syllabus progress, the Library desk (catalogue, issue/return), income & expenses, fee setup (masters/groups/types/discounts + assignment), reports (catalogue + run + export), behaviour records (assign + view), student/staff ID cards and certificates as files, download-centre content, transport + inventory operations, HR depth (staff saves, staff attendance, payroll **view**, timelines + teacher ratings), and online-exam authoring.

**Connect gains the family's depth:** your three commitments above, plus the remaining parity items C-2…C-7 (behaviour, visitor records, video tutorials, personal-task writes, online-exam attachments, daily-assignment edit + homework re-submit), the household fees summary, and honest "not set up yet" tiles if you approve D-W2-1.

**Both apps gain:** local notifications without Firebase (absence, homework, leave decisions, fee-due, worklist changes — arriving on background refresh, honestly not real-time), a biometric/PIN app lock, launcher shortcuts, and an in-app "newer version available" notice. Tab behaviour stops destroying your place (both apps), staff buttons lock while a write is in flight, Workspace lists get pull-to-refresh.

**API work (staging-first):** endpoint families API-40–44, 54, 100, 95, 25/26, 04 (receipt/ID/certificate files), 220, 170, 14/150, 140, 120/110, 80 saves/81/83/84, 90 — built and contract-proven (G1) on staging before any screen is built on them, exactly as Wave 1A preceded 1B.

**Order and gates:** 2A API → G1 contract proof → 2B Workspace → 2C Connect + riders → Checker full pass (§6 five gates) → **device gate on your phone (new, hard — §6 of this proposal)** → 2D production swaps, Staffapi.php and Staffsync.php separately, each with its own approval from you at the time.

**Reality stated once:** production today has **0 exams configured and 0 library books**. The wave is therefore built and proven on staging fixtures first (§7, D-W2-2) and ships with honest not-set-up states; it lights up on production as the office creates real exams and keys in real books — the apps will not be the blocker.

---

## §2 Scope table

Cost key: **S** small · **M** medium · **L** large. "Stack" = what the item needs before a screen can be built on it.

### 2A — API (staging, Staffapi/Staffsync extension)

| # | Item | Source | Stack | Cost |
|---|---|---|---|---|
| A1 | Exams: catalogue, marks roster + save, result, saves/publish/rank, documents (API-40/41/42/43/44) | Plan §7.2, §3.3 | New endpoints (staging) | L |
| A2 | Lesson plans + syllabus status/manage/comments/copy (API-54) | Plan §7.2, §3.3 | New endpoints | M |
| A3 | Library: catalogue, book save, circulation, issue/return, member save (API-100) | Plan §7.2, §3.5 | New endpoints | M |
| A4 | Income/expenses: summary, lists, saves, deletes (API-95) | Plan §7.2, §3.4 | New endpoints | M |
| A5 | Fee setup: read + master/group/type/discount saves with `affects_students`, assignment save (API-25/26) | Plan §7.2, §3.2 | New endpoints | M |
| A6 | Files: receipt/ID-card/certificate/marksheet file opening (API-04) | Plan §3.1; Backlog #15 | New endpoint | M |
| A7 | Reports: catalogue, run, export (API-220) | Plan §7.2, §3.5 | New endpoints | M |
| A8 | Behaviour: catalogue, assign, student record (API-170) | Plan §7.2, §3.5 | New endpoints | M |
| A9 | ID cards view-model (API-14) + certificates list/generate (API-150) | Plan §7.2, §3.2/§3.5 | New endpoints (rides A6 files) | M |
| A10 | Content: list, upload (multipart, validated), shares, delete, video tutorials (API-140) | Plan §7.2, §3.5 | New endpoints | M |
| A11 | Transport overview + per-student assignment (API-120); inventory stock + issue/return (API-110) | Plan §7.2, §3.5 | New endpoints | M |
| A12 | HR depth: staff saves/status/photo (API-80 write side), staff attendance + my attendance (API-81), payroll list/detail + my payslips (API-83), staff timeline + teacher ratings (API-84) | Plan §7.2, §3.4 | New endpoints | L |
| A13 | Online-exam authoring: list/save, question bank, assign, results (API-90) | Plan §7.2, §3.4 | New endpoints | M |
| A14 | Version read: `app_versions` slice of API-230 pulled forward | Feature research #8 | One small read | S |

### 2B — Workspace app

| # | Item | Source | Stack | Cost |
|---|---|---|---|---|
| B1 | Exam Centre + marks entry + results + publish flow (built to Design rules §3.1–3.2 of this proposal) | Plan §7.2; Design §1 | A1 | L |
| B2 | Lesson plans + syllabus progress (two-level worded progress, §3.5) | Plan §7.2; Design §7-surfaces | A2 | M |
| B3 | Library desk: catalogue, two-scan issue, one-scan return, member activation (§3.3) | Plan §7.2; Design §3 | A3 | M |
| B4 | Income & expenses (photo-first expense capture, human-typed amount) | Plan §7.2; Design §4 | A4 | M |
| B5 | Fee setup editors + assignment (check-details sheet, §3.4) | Plan §7.2; Design §4 | A5 | M |
| B6 | Reports runner + export/share | Plan §7.2 | A7 (+A6) | M |
| B7 | Behaviour: assign incident, student behaviour record | Plan §7.2 | A8 | M |
| B8 | ID cards + certificates (view, share, print via files) | Plan §7.2 | A9/A6 | S |
| B9 | Content / download centre management | Plan §7.2 | A10 | M |
| B10 | Transport + inventory operations (scan-to-find inside inventory, Feature #7) | Plan §7.2; Feature #7 | A11 | M |
| B11 | HR depth screens: staff edit/status, staff attendance marking, payroll view, my payslips, timelines, ratings | Plan §7.2 | A12 | L |
| B12 | Online-exam authoring (one question per page — Design R6) | Plan §7.2; Design §6-surfaces | A13 | M |
| B13 | Receipt file on the Fees Desk receipt screen (share/print — closes the screen-only dead end) | Backlog #15 | A6 | S |
| B14 | Librarian nav pair restored to NAV-1 (Library · Tasks) + checker verifies every role's nav against the plan table | Backlog #10 (checker S2-1) | B3 | S |

### 2C — Connect app

| # | Item | Source | Stack | Cost |
|---|---|---|---|---|
| C1 | **Behaviour view for families** — score + incident records + comments, points always shown with their reason | **Owner commitment 1**; Plan C-2 | Existing family endpoints (`getstudentbehaviour` family); staff side = A8 | S–M |
| C2 | **Full tabbed family profile** — Personal / Parents / Other with the complete record the legacy app shows | **Owner commitment 2** | Existing family profile read; API lane verifies field coverage on staging first — extension read if fields are missing | M |
| C3 | **Receipt-photo upload on offline payment** — attach receipt/photo (PDF/JPG/PNG) to a bank-payment report; server-validated type + size | **Owner commitment 3** | App + upload support verified on staging (vendor field or extension upload, photo discipline) | M |
| C4 | Visitor records for my child + register a visitor | Plan C-3 | Existing endpoints | S |
| C5 | Video tutorials list (opens in system player, no WebView) | Plan C-4 | Existing endpoint | S |
| C6 | Personal tasks — write side (add/edit/delete/mark done), shapes verified on the staging family fixture first | Plan C-5 | Existing endpoints + staging verification | S |
| C7 | Online-exam descriptive-answer attachments | Plan C-6 | Existing attempt flow | S |
| C8 | Daily-assignment edit; homework re-submit after evaluation | Plan C-7 | Existing endpoints | S |
| C9 | Results polish: grade word chip on every subject row (the band name the school configured, never invented words) | Design §2.1 | Existing reads | S |
| C10 | Report-card document row inside Results (View · Save · Share) — **if D-W2-4 approved** | Design §2.2; Plan C-8 | Authorised family document read (A6 pattern, family session) | M |

### 2D — Riders (both apps) and quick wins

| # | Item | Source | Stack | Cost |
|---|---|---|---|---|
| R1 | Household fees summary — one combined Due total + per-child Paid/Discount/Balance rows | Feature #1 | Existing APIs only | S |
| R2 | Local notifications + background refresh (no Firebase, no school setup; becomes FCM's local half when C-10 lands) | Feature #2 | Existing APIs; Android channels + periodic refresh | M |
| R3 | Biometric / PIN app lock over the existing session | Feature #3 | App only | S–M |
| R4 | Launcher shortcuts (Workspace: Scan QR, Mark attendance, Collect fees; Connect: Fees, Student Card, Homework; Workspace dynamic set shaped by role) | Feature #4 | App only | S |
| R5 | "Newer version available" notice (calm, dismissible, once a day at sign-in) | Feature #8 | A14 | S |
| R6 | Tab state preserved in both apps; re-tap returns to top (NAV-6) — lands as the pre-wave standalone with the v2.12 device re-proof | Backlog #4 + #16 | App only | S |
| R7 | In-flight locks on staff review/decide buttons (no double-submit) | Backlog #7 | App only | S |
| R8 | Pull-to-refresh across Workspace desk screens + onResume reload for approvals lists | Backlog #5 | App only | M |
| R9 | "Last updated" caption threaded through Workspace cached screens (Home, Fees Desk, approvals first) | Backlog #9 | App only | S–M |
| R10 | Small-print bundle: list skeletons standardised at 6 rows; money figures at the 15sp floor; Workspace appearance (dark) toggle | Backlog #11, #13, #12 | App only | S |
| R11 | Paperwork: correct the Wave 1B build report's contract-gate paragraph to the checker-verified staging-only wording | Backlog #14 (checker S2-2) | None | S |

**Wave size, honestly:** this is the largest wave so far — the full §7.2 depth list plus riders. It is sequenced 2A→2B→2C so a stall in one family never blocks the others, and the Checker gates each stage before the next app's screens are built on it.

---

## §3 Design research — the top 5, as build rules for this wave

The Design Research lane's five ranked recommendations are adopted as **binding build rules**, not inspiration. The Checker tests them by name.

1. **Marks-entry anatomy is pinned before build** (NN/g narrow-table evidence; Classbook rapid entry). One editable column only: roll · name · one numeric field, keyboard-Next moving down the roster, a labelled **Absent** chip per row — never a letter code, never a spreadsheet grid. Sticky bar reconciles live ("32 of 40 entered · 2 absent · 6 still blank") and Save stays disabled until every row is a valid mark or Absent. After each batch save, a partial-result sheet names what saved and what was refused, per student, with the server's plain reason (API-41 already returns `saved` + `refused[]`). **Rule change proposed with this wave: LIST-4 gains the clause "on a phone, a bulk list is one editable column with a sticky summary; a horizontally scrolling multi-column grid is not a bulk list."**
2. **Publishing is a check-answers moment** (GOV.UK). The Exam Centre is a task list with word status tags ("Not started", "Marks being entered", "Ready to publish", "Published"). Before Publish, a completeness sheet lists every subject with its entered/total count and names the gaps in words ("Urdu — 6 students have no mark yet"), ahead of the existing FORM-4 affected-count confirmation. Nobody publishes blind.
3. **The library issue desk is the universal two-scan transaction** (Columbia/UniSC/RWTH self-check; Pakistani school-library practice). Scan the member (Student Card QR) → scan the book, typed-number fallback on the same screen, a running session list ("Issued in this visit: 3"), and a CARD-3 review sheet before "Issue book". Return is one scan; a late fine appears as its own money line, never folded in. Built on the shipped S5 scanner — no new scanner chrome.
4. **Fee-setup saves end on a check-details sheet** (GOV.UK forms + check-answers). Editors are one-thing-per-page; the sheet lists every value with a Change link; the service's own `affects_students` count appears in the sheet **and** on the confirm button ("Confirm and save — affects 214 students"). **Rule change proposed: CARD-3's review-sheet rule extends from payments/approvals to school-wide setup changes.**
5. **Syllabus status is two-level worded progress** (Coursera pattern). Subject → lesson → topic, stated as counts ("3 of 5 topics covered"), never a bare percentage; Covered toggles are saved writes whose counts must reconcile with the server read (HOME-6).

Supporting rules carried into the wave: grade words on family result rows (C9); expense capture is photo-first with a **human-typed** amount (OCR auto-fill rejected, R2 below); every new screen's not-configured state follows EMPTY-4 in its own composition — headline, guidance naming the setup owner, at most one action, spot icon ≤48dp (the shared empty-state helper rebuild itself is deferred, §5 — new screens must not inherit its limits).

---

## §4 Feature research — the 13 proposals, judged

The Feature Research lane ranked 13 proposals. My judgement against this wave's size (the §7.2 depth list alone is 14 API families):

**Ride Wave 2 (6):**
- **#1 Household fees summary (S)** — rides as R1. Existing APIs only; the first question every multi-child parent asks, answered in one screen.
- **#2 Local notifications (M)** — rides as R2. The highest absolute value in the file: every competitor markets notifications, we have none, and this needs **no** Firebase and **no** school setup. It is also not throwaway work — when Wave C's FCM lands, this engine becomes its local half. Sequenced last inside 2C so it builds on completed reads.
- **#3 Biometric/PIN lock (S–M)** — rides as R3. Workspace holds money and children's records on shared office phones; the pattern is already trusted from banking apps.
- **#4 Launcher shortcuts (S)** — rides as R4. The daily-driver actions (register, scanner, fees) one long-press away.
- **#7 Scan-to-find (S)** — rides inside B3/B10, not as a separate item: barcode-first lookup is what makes a zero-record library/inventory key-in survivable.
- **#8 Version check (S)** — rides as R5/A14. You personally had to re-ask for the current APK during Wave 1C week; side-loaded apps must be able to say "a newer version exists".

**Defer to Wave 3 (4):**
- **#5 Permission slips / notice acknowledgement (API-64, M)** — a genuinely good idea that deserves its own workflow design (a new endpoint family + table + a consent record the office relies on). This wave is already at capacity; it also pairs naturally with #9's consent capture. Wave 3 opener.
- **#6 Home-screen widgets (M)** — depends on #2's refresh engine existing first, and RemoteViews in our Gradle-free pipeline is unproven risk. Two platform novelties in one wave is how v2.11 happened. Wave 3, on #2's proven rails.
- **#9 WhatsApp channel (M, ⚠ school setup)** — the decisive local-market finding (every Pakistani competitor leads with WhatsApp), but it extends API-29/61, which are not in this wave, and it needs the school's own Meta Business account + template approvals. Wave 3, sequenced with the other school-setup items (C-10/C-11) as one office ask.
- **#11 Progress trends for families (M)** — honest value only once exams exist; production has 0. Building it now means shipping another empty state. Early Wave 3, when D2/office exam data gives it something to show.

**Later, each gated on its own decision (3):**
- **#10 PTM booking (API-65, M–L)** — Wave 3 at the earliest, and only if you decide D-W2-5's companion question in §7 (it creates a new school workflow; the structured, logged alternative to chat).
- **#12 Pickup pass (API-73, L)** — needs a school dismissal-policy decision before any code; post-Wave 3 candidate.
- **#13 Early-years daily report (API-55, M)** — the real cost is teacher minutes per day across 23 Playgroup/KG sections, not code; an owner/office workload decision first.

---

## §5 Backlog quick wins — what rides, what waits

**Ride this wave:**
- **#4 + #16 — NAV-6 tab behaviour, both apps (S).** Workspace slots stop stacking duplicate activities (CLEAR_TOP | SINGLE_TOP for every slot, as Home already has); Connect stops discarding pushed screens on a tab tap and re-tap returns to top. Lands as the pre-wave standalone so your v2.12 device re-proof covers it.
- **#7 — double-submit locks (S).** One in-flight guard in the shared review/decide helpers. The bank review is currently safe only by a dialog-dismiss trick; the leave review has no lock at all. Unacceptable to leave through another wave of approvals screens.
- **#5 — pull-to-refresh (M).** Mounted once in the shared desk page builder + onResume reload on approvals lists. In a shared office, stale approvals are a correctness problem, not a nicety.
- **#10 — librarian nav alignment (S).** Rides inside the library scope (B14); the Wave 2 Checker verifies every role's nav pair against the plan's NAV-1 table, closing checker debt S2-1 by construction.
- **#15 — receipt file (M).** API-04 (A6) + the Fees Desk receipt screen (B13). The office's most-asked artefact stops being a screen-only dead end.
- **#9, #11, #12, #13, #14 — the small-print bundle (R9–R11).** Last-updated captions, 6-row skeletons, the 15sp money floor, Workspace's missing dark-mode toggle, and the build-report correction. Each is S; together they close five recorded debts.

**Deferred, with reasons:**
- **#3 — NAV-7 work badges (M) → Wave 3.** Real value, but it is shared-component work on BottomNav in both apps plus a Connect notices read-model change; the wave's component budget is already spent on the spacer guard's fallout and NAV-6. First item in Wave 3's scope.
- **#6 — form drafts (M) → Wave 3.** Session expiry wiping a 25-field form is real pain, but autosave/restore for three long forms is a mini-project with its own failure modes (restoring a draft against changed server data). It must not ride as a side-task of the biggest wave; Wave 3, designed properly.
- **#8 — shared empty-state rebuild (M) → Wave 3.** Rebuilding both apps' shared helper mid-wave risks every existing screen's empty rendering. Instead, §3 binds all NEW Wave 2 compositions to the EMPTY-2 anatomy directly; the helper rebuild follows once, in Wave 3.
- **#17 — Workspace More as tile grid (M) → Wave 3 design pass.** Serviceable today (headed link rows); the redesign is polish, and Wave 2's design budget belongs to marks entry and the library desk.
- **#1 and #2 and #18** are process, not scope — they land in §6 below. **#2(b)'s measure-assertion rule** is adopted as a Checker gate for this wave: every new composed row/card builder in Wave 2 must carry a host-side measure assertion (VisualLayoutTest pattern) named in the build report; the Checker rejects the wave without them. This is the direct lesson of the v2.11 worklist slab.

---

## §6 Process change — the device checklist becomes a hard gate

From Backlog #1, the standing shame: **the §6.4 device pass has never been executed on any build.** Connect v2.9, Workspace v2.10 and v2.11 all shipped on harness PASS alone — which is exactly how the v2.11 worklist slab reached your phone minutes after a 232/232 + Checker-PASS delivery. §6.5 of the plan already said a harness pass is not "works on the phone"; this wave enforces it. Exactly how:

1. **It starts now, before Wave 2:** the v2.12 fix build receives the full 12-state §6.4 pass on your phone (starting with REG-HOME-CARD on the worklist), together with the scripted write-proof session (Backlog #18: one homework hand-in + one leave application on the staging family fixture, one photo upload, one student-card QR scan through Workspace attendance). Wave 2's build does not start on an unproven base.
2. **Per wave, the order is fixed:** Builder → Checker PASS → **APKs to you with the checklist** → you run the 12-state pass per new screen on your phone and return screenshots in chat → any S0/S1 found loops back as a fix build + Checker spot-pass + re-proof of the failed states only.
3. **Naming discipline:** a wave is called **"device-verified"** only when your checklist returns clean. Until then every report says "harness-verified, device-pending" — the words are not interchangeable.
4. **Production swaps wait for the device gate:** the 2D swap proposals (per file, your approval each) are made **only after** the wave is device-verified — previously they followed Checker PASS. A defect your phone would have caught will never again be proposed for production first.
5. **The checklist artefact** is CHECKER-SCREENSHOT-CHECKLIST.md, extended by the Checker with the wave's new screens before delivery — including the dark configuration arm for Workspace (Backlog #12).

**Your part in this is the one thing no agent can do:** ~one focused session per wave on your own phone. Everything else in the chain stays ours.

---

## §7 Decisions for the owner

Notes that need **no** decision: the office does not need to key in library books before the build (the librarian does it in-app once B3 ships); staging fixtures for every new family are the school-data coordinator's job, on staging only; D1/D2's production run remains its own separately-approved item and is not smuggled into this wave.

**D-W2-1 — Unconfigured modules in Connect: shown or hidden?**
Today Connect hides what the school has not set up. The legacy app shows everything. The plan's EMPTY-4 pattern argues for honesty: a tile that says what is true and names who sets it up.
- (a) **Show** honest "not set up yet" tiles in Connect (More catalogue + module lists), each naming the setup owner — e.g. Live Classes: "The school has not set up live classes yet."
- (b) Keep hiding unconfigured modules (status quo).
- (c) Show in the More catalogue only, never on Home.
- **CEO recommendation: (a).** A parent who finds a named tile asks the office once; a parent who finds nothing assumes the app is broken. Workspace already works this way; Connect should match.

**D-W2-2 — Exam data: build on staging fixtures now, or wait for the office?**
Production has 0 exams configured. The marks features can be fully built and Checker-proven against staging fixtures (the D2 exam groups already exist as seeded shells; the coordinator creates fixture exams on **staging only**). For production to become useful later, the school office must create the real exam structure on the web system — exam groups are already seeded; the office creates each term's exams and subjects — which rides as a prepared office task with the 2D rollout, not as a blocker now.
- (a) Proceed staging-first with fixtures (the Wave 1 pattern).
- (b) Pause the exams family until the office configures production exams.
- **CEO recommendation: (a).** Waiting couples the whole wave to an office task; the fixtures prove the machinery, and the honest not-set-up state (Design §1.6) covers production in the meantime.

**D-W2-3 — Payroll view in Workspace (sensitive capability, §7.3 rule 4).**
Wave 2's HR depth includes API-83: payroll list/detail for office roles and "my payslips" for every staff member. Generation stays on the web — this is view-only. It is nevertheless a sensitive capability, so it gets your explicit word before build, per the plan's own rule.
- (a) Include payroll **view** (capability-gated; only roles the office grants see amounts).
- (b) Defer payroll to Wave 3.
- (c) Exclude payroll from the apps entirely.
- **CEO recommendation: (a).** Staff asking the office to print a payslip is daily friction; view-only + capability gating keeps the office in control of who sees what.

**D-W2-4 — The family's official documents (report card + receipt PDFs).**
In-app rendering exists today; the official PDF is a web route, not an API (Plan C-8). Design research asks for the report card as a document row inside Results — View · Save · Share — delivered through an authorised family-side document read (the API-04 pattern, family session).
- (a) Build the authorised family document read in this wave (report card first; fee receipts on the same rails).
- (b) Accept the in-app rendering as the family's record; no document read.
- **CEO recommendation: (a).** Parents share report cards on WhatsApp; a screenshot of an app screen is not the school's document. The authorised-read pattern also keeps us off the vendor's unauthenticated certificate URLs, which the audit flagged.

**D-W2-5 — The rider set and the PTM question.**
§4 recommends six feature-research riders in this wave (household fees summary, local notifications, biometric lock, shortcuts, version check, scan-to-find) and defers widgets, consent slips, WhatsApp and trends. Separately, PTM booking (#10) creates a new school workflow and is not recommended before Wave 3.
- (a) Approve the six riders; PTM stays a Wave 3 decision.
- (b) Core depth only — all riders to Wave 3.
- (c) Approve the six riders **and** pull PTM booking into this wave.
- **CEO recommendation: (a).** The riders are cheap because they ride existing APIs; PTM is a workflow the office must agree to run, and it deserves its own decision when the office is ready.

**What your approval of this proposal means:** the §2 scope, the §3 build rules (including the LIST-4 clause and the CARD-3 extension), the §5 ride/defer split, the §6 device gate, and your five decisions above. Production swaps remain per-file approvals at 2D, as always.

---

## §8 Explicitly NOT in Wave 2

So expectations are exact — none of the following is in this wave, and none will be reported as part of it:

- **Wave 3 plan items:** CBSE (API-45 — and its unauthenticated vendor endpoint is the web overhaul's fix to make first), courses (API-200), live classes (API-210), hostel (API-130), alumni + online admissions (API-180), multi-branch (API-240), full system status + 2FA (API-230 — only the `app_versions` slice is pulled forward), fee carry-forward (API-27), fee void (API-28), fee reminders + messaging + templates + credential send (API-29/61/62/63).
- **Wave C school setups:** FCM push (C-10), online fee payment (C-11), Zoom/Gmeet live classes (C-12), Online Course (C-13), CBSE variant (C-9), Urdu language + RTL (C-14 — its own milestone).
- **Deferred research:** permission slips (API-64), home-screen widgets, WhatsApp channel, progress trends, PTM booking (API-65), pickup pass (API-73), early-years daily report (API-55) — each with its reason in §4.
- **Deferred backlog:** NAV-7 badges (#3), form drafts (#6), shared empty-state rebuild (#8), Workspace More tile grid (#17) — reasons in §5.
- **Rejected by research (will not be built on this evidence):** spreadsheet-style marks grids; OCR auto-fill of money amounts; streak/XP mechanics for teachers; donut/pie finance charts; family-facing rank or behaviour leaderboards; desktop-style question-bank grid editors on the phone; AI first-pass grading; free-text chat; face-recognition attendance; GPS bus tracking without school hardware; substitution plans and cantina (no data model exists); Wear OS; passive notice read-receipts; geofenced staff check-in; student health records; hand-rolled Raast/bank collection (duplicates C-11 with a riskier design); offline exam attempts; tablet dual-pane redesign.
- **Not parity, not proposed:** change password (C-15 — needs the web overhaul's credential work coordinated first; forgot-password remains the path), chat (C-16 — owner decision only, and this proposal does not ask for it), subject-wise attendance (C-19 — no backend data model exists), hostel details + multi-currency (C-18 — skipped on the school's facts).
