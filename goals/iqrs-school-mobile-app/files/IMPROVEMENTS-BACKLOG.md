# IMPROVEMENTS BACKLOG — IQRS Connect + IQRS Workspace (current apps)

**Lane:** UX Analyst (improvements), standing app team (APP-TEAM.md) · **Date:** 2026-11-07
**Scope:** the CURRENT builds (Connect v2.9, Workspace v2.11 + the in-flight v2.12 fix) — not future modules.
**Sources mined:** FEATURE-AND-DESIGN-PLAN §5/§6, CHECKER-REPORT-wave0 / -wave0-reentry / -wave1a / -wave1b, PRE1B-DEBTS-REPORT, BUILD-REPORT-wave1b-app, MEMORY.md device-feedback history, and a code audit of `~/workspace/iqrs-app-v2/src` (248 Java files).

**Status of old debts, for the record:** Wave 0 S2s are all closed (strip 92→84dp, dialog themes, F5 in 1B, H1 harness fix in PRE1B-DEBTS-REPORT). Wave 1A S2s F1–F3 are closed (F3 by the class_teacher fixture + battery run 9, 179/179). The 320dp × font-1.3 corner (wave0 F1b / wave1b S2-3) is an owner-accepted known limitation, not an open item. What remains open is listed below, ranked by user pain.

---

## Tier 1 — has hurt the owner, or will hurt daily users

### 1. The §6.4 device pass has never been executed — on any build
- **Evidence:** CHECKER-REPORT-wave1b.md closes with "§6.4 device screenshot checklist — PENDING … owed, not failed"; the same pass is still owed for Connect v2.9 / Workspace v2.10 (MEMORY.md) and now v2.11. CHECKER-SCREENSHOT-CHECKLIST.md exists and has never been run. Every wave so far shipped on harness PASS alone — which is exactly how the v2.11 worklist slab (giant empty rows, owner's screenshots 2026-11-07 ~18:54 PKT) reached the owner's phone minutes after a 232/232 + checker-PASS delivery.
- **Fix:** Make the checklist a hard gate, not a follow-up: the v2.12 fix build gets the full 12-state pass on the owner's phone (starting with REG-HOME-CARD on the worklist) before Wave 2 ships anything, and no future wave is called "device-verified" without it (§6.5 already says this — enforce it).
- **Cost:** S (process, no code) · **Vehicle:** v2.12 fix wave gate.

### 2. Layout composition is invisible to our tests beyond nav / strip / dialogs
- **Evidence:** The unit suite (232 tests) is mapper/payload arithmetic; the only layout test class, `tests/…/VisualLayoutTest.java`, covers NavFit label fitting and the wallet-strip height — nothing else. The checker harness's 11 source inspections (tools/checker/check_sources.py) are hand-aimed at BottomNav, StudentCardView and dialogs. StaffHomeActivity.renderWorklist() composed a MATCH_PARENT spacer inside a horizontal row and no gate could see it (MEMORY.md, "the named verification gap"). The v2.12 lane's generalised SRC-NOSPACER-IN-ROW guard closes the spacer subclass, but any other bad composition (weight/MATCH_PARENT misuse, unbounded text height) in ~90 screens remains invisible — there are 692 `Ui.spacer(` call sites in 81 files as a measure of the hand-built-layout surface.
- **Fix:** (a) Land the v2.12 spacer guard (in flight). (b) For every NEW composed row/card builder in Wave 2, require a host-side measure assertion in VisualLayoutTest style (pure width/height arithmetic, the MottoFit pattern) named in the wave's build report; the checker rejects a wave whose new compositions have none.
- **Cost:** M · **Vehicle:** (a) v2.12 fix wave; (b) Wave 2 gate rule.

### 3. NAV-7 badges do not exist — work waiting is invisible outside Workspace Home
- **Evidence:** Plan NAV-7: badges are counts of work waiting and must reconcile with their lists. Grep of the whole UI tree finds no badge implementation at all (`ui/components/BottomNav.java`, `ui/staff/StaffNav.java`, `ui/family/MainActivity.java` — zero badge code). A teacher who opens the app on the Classes slot sees no signal that leaves are pending; a parent sees no unread-notice signal in Connect.
- **Fix:** Add a badge slot to BottomNav/StaffNav items; feed Workspace badges from the API-02 worklist counts already fetched on Home, and Connect's from the notices read model; hide at zero, per NAV-7.
- **Cost:** M · **Vehicle:** Wave 2 (small standalone possible).

### 4. Workspace tab switching destroys state and grows the back stack (NAV-6)
- **Evidence:** Plan NAV-6: switching tabs preserves scroll/filter state. In Workspace each bar slot is a separate Activity launched by `StaffNav` with plain `startActivity` (StaffNav.java:126–172); only Home gets `FLAG_ACTIVITY_CLEAR_TOP | SINGLE_TOP` (:112–114). Every bar tap creates a fresh activity — the Students search, Fees Desk segment and scroll position reset — and repeated taps stack duplicate activities that Back then walks through one by one.
- **Fix:** Give every slot destination the same CLEAR_TOP | SINGLE_TOP treatment Home already has (or reorder-to-front), so the bar behaves like tabs instead of a launcher.
- **Cost:** S · **Vehicle:** standalone small fix (pairs naturally with the v2.12 wave's device re-proof).

### 5. No pull-to-refresh anywhere in Workspace; most desk lists go stale (LIST-3)
- **Evidence:** LIST-3 requires pull-to-refresh everywhere. `PullRefreshLayout` is used only by `ui/family/FamilyScreen.java` (Connect tab screens) and `ui/staff/StaffWaitingActivity.java`. All Wave 1B desk screens load once in onCreate; only 9 of 42 staff files reload in onResume, and the approvals / directory / front-office lists are not among them — in a shared office, a colleague's decision isn't visible until you leave and re-enter the screen.
- **Fix:** Mount PullRefreshLayout in the shared DeskActivity page builder (one place, all desk screens) wired to each screen's existing load call, and add onResume reload to the approvals list screens.
- **Cost:** M · **Vehicle:** Wave 2 opener (or standalone).

### 6. Session expiry wipes all unsaved work; no form drafts exist (FORM-2 / FORM-3)
- **Evidence:** `StaffUi.sessionExpired()` (StaffUi.java:317) clears the session and restarts with `NEW_TASK | CLEAR_TASK` — every open form dies with it. FORM-3's "long office forms autosave a local draft" is implemented nowhere (no draft persistence anywhere in `src/`; the only "draft" hits are a model field name in FamilyRepository). Homework compose, student edit (25 fields) and leave apply are exactly the long forms at risk, and staff tokens expire on the server's schedule, not the user's.
- **Fix:** Autosave the three long forms' field state to local storage on every change and offer restore on return; at minimum, preserve in-progress input across the session-expired re-login for the form that was open.
- **Cost:** M · **Vehicle:** Wave 2.

### 7. Staff-side action buttons never disable — double-submit rests on one dialog trick (FORM-3)
- **Evidence:** FORM-3: "the button disables" on submit. `setEnabled(false)` appears in 10 family files and in **zero** files under `ui/staff/`. The bank-payment review is safe only because its sheet dismisses itself before `decide()` fires (StaffBankPaymentActivity.java:127–130); the leave review `decide()` (StaffLeaveApprovalsActivity.java:187) and other live writes have no in-flight lock of their own. The outbox's client_txn_id protects queued writes server-side, but live review actions are one fast double-tap from a duplicate call.
- **Fix:** Add an in-flight guard to the shared StaffUi review/decide helpers (disable the confirming button and ignore re-entry until the callback returns), and apply it at the existing call sites.
- **Cost:** S · **Vehicle:** standalone small fix.

---

## Tier 2 — plan rules the current builds do not yet honour

### 8. Empty states share one anatomy and cannot express LIST-3's no-results state (EMPTY-1/2, LIST-3)
- **Evidence:** Both apps' shared empty state is a greyscaled crest + one message line: `FamilyScreen.emptyState()` (crest ghost 56dp) and `StaffUi.emptyState()` (52dp) — EMPTY-2 budgets the spot icon at ≤48dp and requires headline + guidance + at most one action. The component takes only a message string, so there is no slot for an action: StaffStudentsActivity's no-results state ("No students match that search…", strings.xml:248) neither echoes the query nor offers the Clear action LIST-3 specifies, and the same shape serves truly-empty, not-configured and no-results alike (EMPTY-1 wants five distinguishable states).
- **Fix:** Rebuild both emptyState helpers to the EMPTY-2 anatomy (icon ≤48dp, headline, guidance, optional single action) and wire query-echo + Clear into the search screens (Students, Fees Desk due search).
- **Cost:** M · **Vehicle:** Wave 2.

### 9. "Last updated" cached-data caption is missing across Workspace (LIST-3)
- **Evidence:** Connect honours the offline-cached state (`FamilyScreen.updatedCaption()`, used by HomeScreen). In Workspace only StaffRosterActivity renders `R.string.last_updated`; StaffHomeActivity's dashboard and worklist callbacks receive `fromCache`/`fetchedAt` and ignore them (StaffHomeActivity.java:223, :330). A staff member looking at cached approvals or fees cannot tell stale data from live.
- **Fix:** Thread fromCache/fetchedAt through DeskActivity screens to the same quiet caption Connect uses, starting with Home, Fees Desk and the approvals lists.
- **Cost:** S–M · **Vehicle:** Wave 2.

### 10. Librarian nav pair deviates from NAV-1 (checker S2-1, still open)
- **Evidence:** CHECKER-REPORT-wave1b.md S2-1: shipped pair is Tasks · Directory; NAV-1's table says Library · Tasks. Accepted because the Library slot is a Wave 2 module and a dead destination would be worse — but nothing currently forces the realignment to happen.
- **Fix:** When Wave 2 ships the library screens, restore the NAV-1 pair for the Librarian role and have the Wave 2 checker verify NavSlots against the plan table for every role.
- **Cost:** S · **Vehicle:** Wave 2 (inside its library scope).

### 11. Family list skeletons are 3–4 rows where LIST-3 specifies 6
- **Evidence:** LIST-3's loading state is 6 skeleton rows matching the final layout's bounds. Staff register/roster/mark use `Skeleton.rows(…, 6)`, but family lists use 3–4: NoticesScreen 3, ExamsScreen 3, SubjectsScreen 3, DownloadsScreen 3, LibraryScreen 3, FeesScreen 3; HomeworkScreen / TimetableScreen / EventsScreen 4 — the loading state visibly jumps when content lands.
- **Fix:** Standardise list-screen skeletons at 6 rows (cards keep their own skeleton shapes).
- **Cost:** S · **Vehicle:** standalone tidy, any wave.

### 12. Dark mode is unreachable in Workspace; LAY-DARK-1 has no test arm
- **Evidence:** The night palette exists (Tokens.apply dark set) and IqrsApp applies the stored preference at startup, but the only toggle in the tree is Connect's ProfileScreen (ProfileScreen.java:409). The apps are separate packages with separate preferences, so no Workspace user can ever switch Workspace to dark — and no harness or checklist arm has ever rendered a Workspace screen in dark (LAY-DARK-1).
- **Fix:** Add the same appearance toggle to StaffProfileActivity, and include the dark configuration (checklist step 6) in the item-1 device pass for Workspace screens.
- **Cost:** S · **Vehicle:** standalone small fix.

### 13. Money figures render at 14.5sp in fee detail rows (FORM-5 floor is 15sp)
- **Evidence:** FORM-5: figures never shrink below 15sp. `StaffUi.detailRow()` renders values at 14.5sp, and `StaffUi.moneySplit()` routes the Amount / Discount / Paid lines of every fee statement and receipt through detailRow (only the Balance row is set at 15sp). The amounts a parent or accountant reads most are the ones under the floor.
- **Fix:** Raise detailRow's value size to 15sp (or give moneySplit a money variant of the row at 15sp).
- **Cost:** S · **Vehicle:** standalone tidy, any wave.

### 14. Wave 1B build report's contract-gate disclosure is still factually wrong (checker S2-2, still open)
- **Evidence:** CHECKER-REPORT-wave1b.md S2-2 proved `tools/contract_check.py` targets staging only; BUILD-REPORT-wave1b-app.md:77 still states it "probes the production host with exactly two refusal-path calls". The record does not match the artefact.
- **Fix:** Correct that one paragraph in the build report to the staging-only wording the checker verified.
- **Cost:** S (paperwork) · **Vehicle:** immediate, with the v2.12 paperwork.

---

## Tier 3 — dead ends and friction provable from the code

### 15. The fee receipt is a screen-only dead end (API-04 not built)
- **Evidence:** BUILD-REPORT-wave1b-app.md §3 + CHECKER-REPORT-wave1b.md: the API returns `file: null`; StaffFeeReceiptActivity offers no share/print/file action and tells the user the office can print the paper copy. Honest, but the office's most-asked artefact still strands the user at the screen.
- **Fix:** Build API-04 (receipt file) in Wave 2's fees depth and wire share/print into the receipt screen.
- **Cost:** M · **Vehicle:** Wave 2.

### 16. Connect: tab switch destroys pushed screens; re-tapping a tab doesn't return to top (NAV-6)
- **Evidence:** `MainActivity.showTab()` (MainActivity.java:80–92) removes every pushed screen's view and clears the stack on any tab tap — a parent deep in a pushed flow (homework detail, a leave form) loses it by touching the bar. NAV-6's second clause (re-tap returns the tab to its top/root) is also unimplemented: showTab re-shows the tab but never scrolls it to top.
- **Fix:** Preserve each tab's pushed stack across switches (or confirm before discarding a dirty form), and scroll the active tab to top on re-tap.
- **Cost:** S–M · **Vehicle:** standalone.

### 17. Workspace More is a link list where HOME-5 specifies a grouped tile grid
- **Evidence:** HOME-5: More tiles are content-sized 88–104dp in headed groups so a 30-module catalogue stays scannable. Connect's MoreScreen is a tile grid; Workspace's StaffMoreActivity is full-width StaffUi.linkRow rows under headings — serviceable, but the app with the most modules got the less scannable treatment.
- **Fix:** Rebuild StaffMoreActivity's groups as tiles on the Connect More pattern, keeping the capability gating the checker verified.
- **Cost:** M · **Vehicle:** Wave 2 design pass.

### 18. Write paths and photo/card flows remain device-unproven (data-truth gap)
- **Evidence:** Mapper fixtures prove the apps parse responses; nothing proves the server accepts our writes on real-shaped data. Still owed per MEMORY.md: Connect v2.5 Wave B writes' first live proof, Workspace v2.6 photo flows end-to-end on device, and the student-card QR scan through Workspace QR attendance. These are the same class as item 1 but for writes — a fixture cannot catch a server-side refusal shape.
- **Fix:** One scripted proof session on the owner's phone during the item-1 device pass: staging family fixture for Wave B writes + photo upload, and one card-QR scan against the staging staff fixture.
- **Cost:** S (a session, no build) · **Vehicle:** v2.12 device pass.

---

## Not re-listed (checked and honouring the rules)
FORM-1 labels-above-fields (StaffStudentEditActivity.java:214, ProfileEditActivity.java:88 — labels present, hints used only as examples); CARD-2/CARD-3 money split and amount-repeating review buttons (checker-verified in wave1b); LIST-4 sticky summary + save bar on the register (StaffRegisterActivity.java:142–159); HOME-6 count/list reconciliation (pinned by Wave1BMapperTest against real captures); capability gating end-to-end (checker-verified); REG-DIALOG-TEXT and the dialog theme (closed in Wave 0).
