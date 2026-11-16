# DESIGN RESEARCH — Wave 2 (Design Research lane)

**Date:** 2026-11-07 · **Lane:** Design Research (standing team, APP-TEAM.md) · **Status:** research deliverable — nothing here is work until the CEO folds it into the Wave 2 scope.
**Re-filed complete, 2026-11-07:** the first filing was truncated on disk inside §4(a); §§4(b)–(d), 5, 6 and 7, the Top 5 and the Rejected list were restored in full the same day. Nothing that survived was rewritten.
**Inputs:** FEATURE-AND-DESIGN-PLAN.md (§2 matrices, §3 API contracts, §5 rules, §7.2 Wave 2 row), design-system-v2.md ("Calm Campus"), BUILD-REPORT-wave1b-app.md (what v2.11 actually shipped).
**Cost key:** **S** = fits inside the already-planned screen build, no new endpoint · **M** = new component/flow work or a minor API addition · **L** = new endpoint family or cross-app work.
**Standing facts that shape every suggestion:** production has **0 exams configured** and **0 library books**; payroll is *displayed* only (generation stays web, plan §2.8); every file moves through the authorised API-04 pattern, never a vendor URL (plan §2.16); all copy obeys the language lockdown (design-system §6.3/§3.13 — no "sync/queue/API/LIVE/OFFLINE", statuses are always words, money always split).

---

## 1. Exams & marks entry (Workspace — API-40/41/42/43)

### (a) Patterns found
- **NN/g, "Data Tables: Four Major User Tasks":** tables serve find / compare / edit-one-row / act-on-rows; edit-in-place only works when the table is *narrow*, modal editing fails because users copy values from adjacent records, save states must be explicit, and failed saves must be surfaced per record with the field and reason. (https://www.nngroup.com/articles/data-tables/)
- **Classbook (teacher gradebook):** "type marks like a spreadsheet, **M for missing**" — rapid keyboard-first entry with a one-keystroke absent shorthand is the speed feature teachers actually praise; the register equivalent ("everyone starts present… a register of 28 takes about 20 seconds") is the same lesson. (https://classbook.tdot.app/)
- **SAP Fiori, mass editing + message handling:** batch changes to homogeneous rows happen as one operation, and the result handling must itemise the items that could not be processed — never a silent partial success. (https://www.sap.com/design-system/fiori-design-web/v1-136/foundations/best-practices/global-patterns/object-handling/mass-editing)
- **GOV.UK "Complete multiple tasks" (task list) + HMRC status tags:** a multi-part job is a list of verb-named tasks carrying word statuses — "Not started / In progress / Completed" — that users demonstrably understand. (https://design-system.service.gov.uk/patterns/complete-multiple-tasks/ · https://design.tax.service.gov.uk/hmrc-design-patterns/status-tags-in-task-list-pages/)

### (b) Suggestions for our screens
1. **Marks roster is one editable column, never a grid.** Sticky header: subject + "Out of 50" + live entered count. Each row: roll (Inter tnum) · name · one numeric field (decimal keyboard; the keyboard's Next action moves to the next student) · a labelled **Absent** chip per row. No horizontal scrolling at any font scale. *(Classbook speed, NN/g narrow-table rule, adapted so the absent shorthand is a word, not a letter code.)*
2. **Live reconciliation in the sticky save bar (LIST-4 made literal):** "32 of 40 entered · 2 absent · 6 still blank". Save stays disabled until every row is a mark inside 0–max or Absent, and the bar names what is missing. Typing above the maximum flags the field immediately in plain words — "Highest possible is 50" — under the field (FORM-2), never a clipped value (API-41 already refuses per row; the UI must make refusal nearly impossible to reach).
3. **Partial-result sheet after every batch save:** the save returns `saved` + `refused[]` (API-41 contract) — show "Saved 38 marks" and, if any, the refused students by name with the server's plain reason, each tappable back to its row. No bare "Saved", no silent drops (Fiori message handling).
4. **Resume where the teacher stopped:** the roster reopens with existing marks pre-filled from the roster read and the first blank row highlighted; the Exam Centre list carries per-subject entry progress ("Mathematics — 32 of 40 entered"). Progress at two levels — per subject and per exam — is the learning-platform pattern (Coursera/Duolingo progress research: per-unit + per-course, framed as "32 of 40", not a bare percentage).
5. **Exam Centre home is a task list; publishing is a check-answers moment.** Groups → exams with word status tags: "Not started", "Marks being entered", "Ready to publish", "Published". Publish/unpublish keeps the FORM-4 affected-count confirmation and adds a completeness sheet first: every subject listed with its entered/total count, incomplete subjects named in words ("Urdu — 6 students have no mark yet") so the office publishes with its eyes open. This is the GOV.UK check-answers pattern applied to the school's most embarrassment-prone action.
6. **Not-configured state (production today):** with zero exams, the Exam Centre shows the EMPTY-4 state driven by `modules_configured`: "Examinations are not set up for this session yet. The school office sets up exam groups and subjects on the school system." No dead button, no error voice.
7. **Staff result view (API-42):** summary card (class average, highest, entered count) + student rows with grade and division as word chips; rank appears only as the list order the service returns — never computed on the phone.

### (c) Cost
1: **S** · 2: **S** · 3: **S** (contract already returns both halves) · 4: **S** · 5: **M** · 6: **S** · 7: **S**

### (d) Rules
Supports **LIST-4, LIST-1, FORM-2, FORM-4, HOME-6, EMPTY-4, CARD-4**. **Amends LIST-4** — add one clause: *"On a phone, a bulk list is one editable column with a sticky summary; a horizontally scrolling multi-column grid is not a bulk list."*

---

## 2. Results & report-card views for families (Connect — F8 today, C-8 document)

### (a) Patterns found
- **Standards-based report cards (PowerSchool districts, e.g. Grafton PS FAQ):** parents interpret results through **mastery words** ("Meeting expectations", "Progressing towards expectations") beside the numbers, plus a teacher comment; a bare number/scale alone was the comprehension failure the redesign fixed. (https://www.graftonps.org/apps/pages/index.jsp?uREC_ID=4365249&type=d&pREC_ID=2564899)
- **SCCPSS on PowerSchool:** the report card is a *document* in the portal — the school can see when it was viewed and captures an electronic acknowledgement; the card also carries next-term placement, i.e. it answers "what happens next", not only "what happened". (https://www.sccpss.com/news/news-landing-page/~board/district-news/post/sccpss-unveils-new-and-improved-report-card)
- **NN/g preattentive processing (via dashboard/table research summaries):** length and position are judged almost instantly; area and angle (pies, donuts) are misread — the design system's own choice of subject bars over charts (F8) is the evidence-backed one and should not regress.

### (b) Suggestions for our screens
1. **Every subject row carries its grade word.** F8 already shows marks + thin bars; add the grade band's *name as the service returns it* (from the school's configured Marks Grade bands) as a word chip on each subject row — "A+" beside 92/100 — so a parent who does not know the scale still reads the result. Never invent descriptor words the school did not configure.
2. **The official report card is a document row inside Results (C-8).** Once an exam is published, a "Report card" row appears: crest header per design-system §2.7 (a trust moment), then **View · Save to phone · Share** — sharing to WhatsApp is how parents actually move receipts and cards (§F4 doctrine). Delivered only through the authorised family document read (API-04 pattern, plan §2.16 security rule). States: before publication, the existing honest copy stands ("Results for this term aren't published yet."); the row simply is not there — no greyed teaser.
3. **Optional, API-lane's call:** record a first-viewed timestamp server-side when the card is opened (SCCPSS evidence that schools value knowing a card was seen). Only if it is a one-column addition; it is not a launch requirement and no UI depends on it in this wave.

### (c) Cost
1: **S** · 2: **M** (needs the C-8 family document decision, already queued) · 3: **S**

### (d) Rules
Supports **CARD-4, EMPTY-3, §2.7 (crest at trust moments), §2.16 (authorised files only)**. No amendment.

---

## 3. Library (Workspace — API-100)

### (a) Patterns found
- **Self-check circulation (Columbia Libraries, RWTH Aachen, UniSC, Basel):** the working transaction everywhere is **two scans** — member card first, then the item barcode — with a running list of what has been scanned in this session, and *per-item error states in plain words* ("Barcode not found — scan the library barcode, not the publisher's ISBN"). Every deployment also keeps a **typed-number fallback** when a barcode will not scan (UniSC: "Type the barcode number rather than scanning"). (https://library.columbia.edu/using-libraries/borrowing/self-check.html · https://libguides.usc.edu.au/new/selfcheck · RWTHapp self-loan FAQ, RWTH Aachen University Library)
- **School-library practice in Pakistan (WCV Digital):** member shows a card or *says their roll number* → scan member, scan book → system checks limits and fines → due date set; a return is one scan that shows the delay and calculates the fine; "a full transaction takes about ten seconds". (https://www.wcvdigital.com/library-management-system-development/)

### (b) Suggestions for our screens
1. **Issue desk = the two-scan flow, built on the shipped S5 scanner anatomy.** Step 1 "Who is borrowing?" — scan the Student Card QR (`IQRS-<id>`, CARD-5) or search by name/admission number (§3.18 search). Step 2 "Scan the book" — camera scan of the book number with a **type-the-number fallback** on the same screen. Due date defaults to the system's loan period, adjustable with date chips (the homework due-chip pattern). A CARD-3 review sheet names member + book + due date before the primary button "Issue book". Consecutive issues to the same member stay in one session with a running list — "Issued in this visit: 3" — exactly the self-check session pattern.
2. **Return = one scan.** Scan the book → the screen shows the member, the due date, and — if late — the fine as its own money line (CARD-2: the fine is never folded into anything) → primary "Record return". 
3. **Catalogue rows state availability as a word chip:** "Available" / "Issued — due back 12 Nov" (CARD-4). Search covers title, author and book number (API-100 `query`); the no-results state echoes the query with a Clear action (LIST-3).
4. **The zero-books state is a first-class design, not an embarrassment.** For most roles: "No books in the library yet. Once the librarian adds books, they will appear here." For the librarian/admin role, the same state carries its one allowed action — "Add a book" (API-100 `bookSave`) (EMPTY-2's single action, EMPTY-4's named owner).
5. **Member activation lives inside the issue flow.** If a scanned student is not yet a library member, the review sheet says so in plain words — "Areeba is not a library member yet." — with "Add as a library member" as the sheet's action for office roles (API-100 `libraryMemberSave`). Never a dead end (EMPTY-3 doctrine).

### (c) Cost
1: **M** · 2: **S** · 3: **S** · 4: **S** · 5: **S**

### (d) Rules
Supports **CARD-3, CARD-4, CARD-5, CARD-2, EMPTY-2/3/4, LIST-3**. No amendment — the wave's job is to *reuse* the S5 scanner and §3.18 search rather than invent library-specific chrome (design-system §3: no screen invents a one-off component).

---

## 4. Money setup + income/expenses (Workspace — API-25/26, API-95)

### (a) Patterns found
- **GOV.UK Service Manual, "Structuring a form":** start with **one thing per page** — one decision, one question — especially where an error is costly; user research, not habit, decides when pages merge. The UK Parliament design system adds the repeat-user nuance: people who do a task daily may carry more per page, with progressive disclosure for conditional fields. (https://www.gov.uk/service-manual/design/form-structure · https://designsystem.parliament.uk/how-tos/designing-forms/)
- **GOV.UK check answers + the DfE design-history standardisation:** a summary list with a **Change** link per value, the heading "Check details before [doing thing]", and a confirm button that reads "Confirm and [do thing]". (https://design-system.service.gov.uk/patterns/check-answers/)
- **Expensify SmartScan (product help):** the expense flow is **photo first, details second, confirm before create** — capture the receipt at the moment of the expense, in the in-app camera, with plain capture guidance (flat, full receipt, no glare). (https://help.expensify.com/articles/new-expensify/reports-and-expenses/Create-an-Expense)
- **SAP Fiori action placement:** one primary action per page, and workflow actions (Save/Post) live in the footer bar, not the header. (https://www.sap.com/design-system/fiori-design-web/v1-151/foundations/best-practices/global-patterns)
...[truncated 30167 chars]
### (b) Suggestions for our screens
1. **Fee-setup editors are one thing per page.** Fee group, fee type, discount, assignment — one decision per screen, conditional fields disclosed progressively (GOV.UK form structure; the Parliament repeat-user nuance is honoured by keeping the *list* screens dense for the office staff who live in them, while each *editor* stays single-question). No mega-form with every fee field on one scrolling page.
2. **Every fee-setup save ends on a check-details sheet.** The sheet lists every value being set with a **Change** link per value (GOV.UK check-answers), and it carries the service's own `affects_students` count (API-25/26) in the sheet **and** on the confirm button — "Confirm and save — affects 214 students". A school-wide money change is never committed from a bare Save at the bottom of a form.
3. **One primary action, in the footer.** Following the Fiori placement rule, each setup screen has exactly one primary action and it lives in the sticky footer bar with the running state ("3 changes"), never competing buttons in the header (FORM-3).
4. **Expense capture is photo first, details second, confirm before create** (the SmartScan sequence). At the moment of the expense: take or attach the receipt photo with the in-app camera → type the details → a CARD-3 review sheet (photo, amount, category, date) before "Record expense". The amount is **always typed by a human** — see Rejected R2: there is no OCR read anywhere in this flow.
5. **The income/expense summary is a split bar and two money lines, never a chart.** "Income · Expenses · Balance" as three separated figures (CARD-2 discipline), with a single split bar for proportion — length, not angle (see Rejected R4). Lists carry the LIST-3 states; each row is one entry with its own amount — an expense is never silently netted against income inside a row.
6. **Deleting an income/expense entry is a FORM-4 action:** the confirmation names the entry, its amount and its date ("Delete the expense 'Generator fuel — Rs 4,500, 3 Nov'?"), and the deletion is online-only. Money records are never removed by a swipe.

### (c) Cost
1: **M** · 2: **M** · 3: **S** · 4: **M** · 5: **S** · 6: **S**

### (d) Rules
Supports **FORM-1, FORM-2, FORM-3, FORM-4, CARD-2, LIST-3, HOME-6**. **Amends CARD-3** — the review-sheet rule extends beyond payments and approvals to **school-wide setup changes**: *"A change that alters money or assignments for many students (fee setup, discounts, fee assignment) also ends on a review sheet listing every value with a Change link per value, and the confirm button carries the service's affected-students count."*

---

## 5. HR depth incl. payroll (Workspace — API-80 write side, API-81, API-83, API-84)

### (a) Patterns found
- **SAP Fiori employee services ("My Pay-Stubs" pattern):** payslips are presented as a **period list** — one row per month — and one tap opens that single period's payslip as a *document*: earnings, deductions and net as separate groups. A payslip is something you read and keep, never a form you edit.
- **GOV.UK check-answers applied to record editing:** changing a person's official record ends on a summary of exactly what will change (field → new value) before the change is committed; status changes (starters/leavers in HMRC-adjacent services) are worded states with explicit effect statements, never silent toggles.
- **NN/g, confirmation for consequential actions:** an action that changes someone else's access or status needs an unambiguous confirmation naming the person and the consequence, in the moment — not a generic "Are you sure?".
- **ClassDojo doctrine (already adopted in plan §5.1):** feedback about a person is shown **with its reasons** and is moderated before it is treated as published — the pattern the plan already applies to behaviour points applies unchanged to teacher ratings.

### (b) Suggestions for our screens
1. **Staff record editing grows out of the shipped directory/detail anatomy** — no new chrome. From the staff detail screen, each editable group (personal, contact, bank, documents) opens a one-thing-per-page editor (the §4 form rule), and saving ends on a "Check the changes" sheet listing field → new value before the API-80 save commits. The photo change reuses the shipped photo discipline (same picker, same size/type checks).
2. **Staff status is a word chip everywhere and a FORM-4 action to change.** "Active" / "Not active" (CARD-4) on directory rows and the detail header. Changing it confirms with the person and the effect named: "Areeba Khan will no longer be able to sign in to the app." — and the change is online-only.
3. **Staff attendance marking reuses the class-register anatomy.** A staff register is the same one-editable-column problem as a class register (§1): one column, word statuses, sticky summary + save bar (LIST-4). **My attendance (API-81) is a read-only month list** with word statuses and the month totalled as counts — a member never gets an edit affordance on their own record.
4. **Payroll is display-only in the app (plan §2.8 — generation stays web).** Month picker → payroll rows carrying **gross · deductions · net** as three separated figures (API-83 returns integer rupees; CARD-2 discipline — deductions are their own line, never pre-netted in the row's main figure). The payslip detail is a document view — earnings, deductions, net — and where the service provides the file it opens/saves through the authorised API-04 pattern only. **My payslips** is the same period list scoped to self, reachable from every staff member's own profile.
5. **Teacher ratings show the number with its evidence (API-84).** The summary is a number plus its count — "4.6 · from 23 ratings" — never a bare star row. Comments list beneath it, each carrying its moderation state as a word chip ("Waiting", "Shown", "Hidden"); a teacher sees only their own summary, office roles moderate, and a comment in "Waiting" is never presented to the teacher as published feedback.
6. **The staff timeline reuses the shipped timeline row anatomy** (date · entry · visibility as a word — "Office only" / "Visible to the member"). Adding an entry (API-84 save) is online-only and the visibility choice is made in words at the moment of writing, not buried in settings.

### (c) Cost
1: **M** · 2: **S** · 3: **M** · 4: **S** · 5: **M** · 6: **S**

### (d) Rules
Supports **CARD-2, CARD-4, FORM-4, LIST-3, LIST-4, §2.16 (authorised files only)**. No amendment — HR depth is a reuse wave: register anatomy, timeline anatomy, directory anatomy and the money-split rules all already exist; the design risk would be inventing HR-specific chrome.

---

## 6. Content / download centre (Workspace — API-140; Connect reads the same rows)

### (a) Patterns found
- **NN/g download guidance (file-type and size disclosure):** users decide whether to open a file from its **type and size stated before the tap**; an unlabelled link or bare filename is a comprehension and trust failure, worst on metered connections — the normal case for our families.
- **GOV.UK publishing patterns (upload → details → audience → check):** publishing a file is a checked sequence, and validation failures are named per field in plain words at the field — the same form doctrine as §4, applied to files.
- **System-player doctrine (plan C-4, already decided):** video opens in the **system player**; no app embeds a WebView player. The list's job is identification and launch, nothing more.

### (b) Suggestions for our screens
1. **Content rows are self-describing — never a bare filename.** Title · type as a word ("PDF", "Video", "Image") · size · audience in words ("Shared with: Seven – Diamond · All staff") · validity where set ("Until 30 Nov"). API-140 rows already carry type, audience, validity and the file ref; the screen's job is to say all of it (NN/g disclosure rule).
2. **Upload is a stepped flow on the proven photo-upload discipline:** pick the file (type and size checked server-side, API-140) → title and type → **audience picker fed by the API-01 catalogues** (classes, sections, staff groups — never free-typed) → a CARD-3-shaped review sheet → "Share this file". A refused file is refused in plain words under the field with the reason ("This file is larger than the limit") and everything already entered is preserved (FORM-2).
3. **Sharing is editable from the row.** "Change who can see this" opens the same audience picker (API-140 `contentShares` read + save) and ends on the check-details pattern; removing every audience is confirmed for what it is — the file becomes visible to no one.
4. **Delete is online-only and FORM-4 confirmed**, naming the file and its reach: "Delete 'Science notes.pdf'? It is shared with 3 classes." No swipe-to-delete on shared records.
5. **Video tutorials are their own list** (API-140 `videoTutorials`): title · class · length where known; a tap opens the system player (plan C-4) — the app never embeds a player. Adding a tutorial is **link/metadata only**; large video uploads are not assumed (hosting limits unverified — the plan says so, and the screen must not promise what the host may refuse).
6. **Connect reads the same rows.** A family's Download Centre shows exactly what was shared with their child's class, with the same type/size labelling, and the file itself opens only through the authorised API-04 pattern (plan §2.16) — the Wave 1B rule that no screen ever links a raw vendor file URL applies here unchanged.

### (c) Cost
1: **S** · 2: **M** · 3: **S** · 4: **S** · 5: **S** · 6: **S**

### (d) Rules
Supports **FORM-2, FORM-4, CARD-3, LIST-3, §2.16 (authorised files only)**. No amendment.

---

## 7. Timetable & lesson plans (Workspace — API-54; timetable reads shipped in Waves 0–1A)

### (a) Patterns found
- **Coursera syllabus pattern (progress at two levels):** progress is stated at the course level *and* the item level, as **counts completed of total at both levels** — the learner always sees "how much of this subject" and "how much of this lesson" in the same glance. (The goal-gradient framing behind §1(b)4's per-subject + per-exam progress.)
- **NN/g mobile-calendar research + Google Calendar's schedule view:** on a phone, the **agenda list beats the week grid** — a grid cell cannot hold a readable lesson at 360dp, and at 135% font (FORM-5) a seven-column week is physically unreadable. Every mainstream calendar's phone default is the day agenda for this reason.
- **SAP Fiori reuse/copy patterns:** recurring structured work (a plan, a roster) is created by **copying the previous instance and editing the difference**, with the source and target both named before the copy runs — never by re-typing.

### (b) Suggestions for our screens
1. **Syllabus status is a two-level tree stated in counts.** Subject → lessons → topics; every level states its progress as words and counts — "3 of 5 topics covered" — and the subject list itself carries the roll-up ("English — 12 of 20 topics covered"). A bare percentage never appears on its own at either level (this is Top-5 #5 below).
2. **"Covered" is a one-tap toggle per topic — and it is a saved write** (Staffsync `{topic_id, complete}`). After every toggle the on-screen counts must reconcile with the server read (HOME-6); a toggle made without a connection reads "Waiting to send" (language lockdown) until it lands — it never pretends to be saved.
3. **Lesson plans are a day agenda, not a week grid.** Date chips (the homework due-chip pattern) pick the day → my lessons that day as rows (time · class · subject · topic) → tap to read or edit the plan text. The week is navigated day by day; there is no seven-column grid at any font scale.
4. **Copy is offered, never automatic (API-54 `lessonCopy`, online-only).** From a previous session's matching lesson, "Copy this plan" opens a review sheet naming source and target (session, class, subject, week) before anything is written — the Fiori copy discipline, and FORM-4's naming rule.
5. **Lesson comments are a plain thread on the lesson** (API-54 `syllabusComments`). Moderation actions are worded ("Hide this comment") and confirmed; a hidden comment carries its state as a word chip visible to office roles only — students and parents never see moderation chrome.
6. **The timetable keeps the shipped day-agenda form and an honest empty state.** "Today" first, day chips to move, period rows showing subject + teacher as words; the current period, if any, is marked with a word chip — "Now" — never colour alone (CARD-4). Where no timetable is configured, the state names the owner (EMPTY-4): "The timetable is not set up for this class yet. The school office sets up timetables on the school system." — no dead button, no error voice. The same EMPTY-4 shape covers a subject with no syllabus structure set up yet ("The syllabus for English is not set up yet…") in the syllabus list itself.

### (c) Cost
1: **M** · 2: **S** · 3: **M** · 4: **S** · 5: **S** · 6: **S**

### (d) Rules
Supports **HOME-6, CARD-4, EMPTY-4, LIST-3, FORM-4, FORM-5**. No amendment.

---

## Top 5 — the ranked recommendations

The five the CEO should fold into the Wave 2 scope as build rules, in order:

1. **Marks-entry anatomy pinned before build (cost S).** One-column roster — roll · name · one numeric field, keyboard-Next chaining down the roster, a labelled **Absent** chip per row — with the sticky bar reconciling entered/absent/blank live, and a Fiori-style partial-result sheet after each batch save naming what saved and what was refused, per student, with the server's plain reason (API-41 already returns `saved` + `refused[]`). Evidence: NN/g narrow-table research + Classbook's rapid-entry pattern (§1).
2. **The publish gate is a GOV.UK check-answers moment (cost M).** The Exam Centre is a task list with word status tags; before publishing, a per-subject completeness sheet names every gap in words ("Urdu — 6 students have no mark yet") ahead of the existing FORM-4 affected-count confirm. Nobody publishes blind (§1).
3. **The library issue desk is the universal two-scan transaction (cost M).** Scan the member (Student Card QR) → scan the book, typed-number fallback on the same screen, a running session list, and a CARD-3 review sheet before "Issue book". Return is one scan, with a late fine as its own money line (§3).
4. **Fee-setup saves end on a check-details sheet (cost M).** One-thing-per-page editors, a Change link per value on the sheet, and the service's own `affects_students` count in the sheet **and** on the confirm button — "Confirm and save — affects 214 students" (§4).
5. **Syllabus status is two-level worded progress (cost M).** Subject → lesson → topic, stated as counts ("3 of 5 topics covered") over any bare percentage, with one-tap Covered toggles as saved writes whose on-screen counts reconcile with the server read (§7).

### Rule amendments proposed (both carried in place above)

- **LIST-4 gains a one-editable-column clause for phone bulk entry** (§1(d)): *"On a phone, a bulk list is one editable column with a sticky summary; a horizontally scrolling multi-column grid is not a bulk list."*
- **CARD-3's review-sheet rule extends to school-wide setup changes** (§4(d)): fee setup, discounts and assignments end on a review sheet listing every value with Change links, and the confirm button carries the service's affected-students count.

---

## Investigated and rejected

- **R1 — Spreadsheet-style multi-column marks grid.** NN/g's table evidence is against it: wide tables fail on small screens, and at 135% system font the grid violates FORM-5 outright. The one-editable-column roster (§1) carries the same speed teachers praise in spreadsheet tools, via keyboard-Next chaining instead of horizontal sprawl.
- **R2 — OCR auto-fill of expense amounts (Expensify SmartScan's read).** There is no OCR service on our stack, and a misread figure silently entering a money field breaks the CARD-2 trust rule the whole money surface is built on. Adopted instead: the SmartScan *sequence* — photo first, then a **human-typed** amount, then the review sheet (§4).
- **R3 — Duolingo-style streaks/XP for teachers' syllabus coverage.** A pressure mechanic aimed at the wrong audience: it would costume professional staff work as a game — the playful costume the design system already rejected for staff surfaces. Progress is stated as honest counts (§7); nothing is gamified.
- **R4 — Donut/pie charts for the finance summary.** Preattentive-processing evidence: angle and area are misjudged where length and position are not. The split bar and per-subject bars win; no circular chart ships in the money surfaces (§4).
- **R5 — Family-facing rank positions and behaviour leaderboards.** The plan's ClassDojo doctrine (§5.1): points are always shown **with their reasons**, never as a shaming wall. Rank stays an office-side artefact (API-220 reports); families see their own child's results and behaviour record, with reasons (§2).
- **R6 — Desktop-style question-bank grid editor on the phone.** Deep-editing evidence is against dense grid editors on small screens. API-90 authoring therefore goes **one question per page** — the feature ships in Wave 2; the grid form factor does not.
- **R7 — AI first-pass grading.** No such service exists on our stack, and official marks are audited records — what a mark *is* cannot be delegated to a model as a design pattern. This is a governance and product decision for the owner, not a design recommendation; the lane makes none.

---

*End of deliverable. Standing facts honoured throughout: production's 0 exams and 0 library books are designed EMPTY-4 states, not errors (§1, §3); payroll is display-only in the app (§5); every file moves through the authorised API-04 pattern (plan §2.16), never a vendor URL.*
