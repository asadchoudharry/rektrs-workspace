# FEATURE RESEARCH — Wave 2 input (Feature Research lane, 2026-11-07)

Read-only research per APP-TEAM.md. Everything below was checked against
FEATURE-AND-DESIGN-PLAN.md (§2 matrix, §3 contracts, §4 Connect list, §7.2 build
order) — **nothing already planned is re-proposed**. Where a proposal extends a
planned API, it is marked as an extension of that number; genuinely new endpoint
families are given the next free §3-style numbers (API-64, API-65, API-55, API-73)
so the Planner can adopt or renumber them.

**Local facts verified in the tree (2026-11-07):** the apps contain **no**
NotificationManager/NotificationCompat code, **no** WorkManager, **no**
BiometricPrompt, **no** AppWidget provider, **no** launcher app shortcuts — the
only "notification" in the code is the Notice Board read (`getNotifications`),
and the only "shortcuts" are in-app bento tiles. The vendored ZXing core
(QR + Code 128 + decoder) is present and already used for the Student Card and
QR attendance. Current builds: Connect v2.9, Workspace v2.11 (v2.12 layout fix
in flight), Wave 1C API live on production.

Ranking is by value ÷ effort (S/M/L). School-side setup and owner-decision
items are flagged explicitly, per the charter.

---

## Ranked proposals

### 1. Family fees summary — all children, one honest total (Connect)
- **What:** A "Family fees" view for signed-in parents: one combined Due total
  for the household plus a per-child breakdown row (each child's Amount /
  Discount / Paid / Balance), tapping through to that child's existing fees
  screen. Totals are the exact sum of the per-child splits — CARD-2 honesty
  rules unchanged, discount never folded into paid.
- **Evidence:** Multi-child families are our tested norm, not an edge case —
  the family's own device testing used a parent of two (Shakeel Ahmad), and
  the first question a parent of siblings asks the office is the combined
  "kitna dena hai". PowerSchool markets exactly this consolidation ("Parents
  or guardians with multiple students can align all students to a single
  account"); Pakistani competitor Schooliee describes its design centre as
  "families with several children". Connect today forces child-switching and
  mental addition.
- **Stack:** Existing APIs only — the family session already returns
  `parent_childs`, and the per-child fees read is already used by the fees
  screen. App-only aggregation. **No new endpoint, no setup.**
- **Effort:** S. **Wave:** 2 (Connect).

### 2. Local notifications + background refresh — "notifications done right" without Firebase (both apps)
- **What:** A notification engine that needs **no server push at all**: a
  periodic background refresh (WorkManager/AlarmManager + the existing
  retry machinery) re-reads what the app already reads, and posts **local**
  notifications on proper Android channels when something changed:
  - Connect: child marked absent today; new homework set / due tomorrow;
    leave application decided; fee due date approaching / overdue; new
    notice published; exam result published (once exams exist).
  - Workspace: my worklist counts changed (unmarked registers, leave
    approvals waiting, bank payments to review — API-02); "Waiting to send"
    items still unsent after N hours; my leave decided.
  Each notification deep-links to the exact screen/list. Per-channel opt-in
  in settings, quiet hours respected. Copy must be honest: these arrive on
  the next background sync, not in real time — and when Wave C's FCM
  (plan C-10) eventually lands, this engine becomes its local half rather
  than being thrown away.
- **Evidence:** This is the single most-marketed capability in every
  competitor checked: Fedena — "notified instantly when your kid is marked
  absent", fee-due push reminders; PowerSchool — push on absent marks and
  grade changes is the feature parents praise by name in reviews; Classter —
  "instant push notifications" headline. Our apps today have **zero**
  notification code (verified in tree) — a parent learns about an absence
  only by opening the app. Push-via-FCM is parked behind school-side
  Firebase setup (C-10, Wave C); local notifications close most of the gap
  with no setup at all.
- **Stack:** Existing APIs only (family vendor reads + API-02/51/60/82
  family). Android framework notification channels + WorkManager. **No new
  endpoint, no setup.** Battery/data discipline is part of the build
  (backoff, sync only on change-worthy reads).
- **Effort:** M. **Wave:** 2 (both apps). Ranked #2 on ratio; highest
  absolute value of anything in this file.

### 3. Biometric / PIN app lock (both apps)
- **What:** Optional app lock: on open (and after a configurable idle
  timeout) the app asks for fingerprint/face or a device PIN before showing
  content; the stored session itself is untouched, so unlocking never means
  signing in again. Recommended default-on prompt for Workspace (it shows
  money, children's records and staff data, often on shared office phones)
  and offered at first sign-in in Connect.
- **Evidence:** The pattern parents and staff already trust from WhatsApp
  and banking apps; Classter sells its app partly on "data protection".
  Our context makes it concrete: Workspace's fees desk and student records
  sit on phones that get handed around an office, and Connect holds
  children's data on family phones that children themselves use.
- **Stack:** Android BiometricPrompt (framework API, no new dependency
  class beyond androidx.biometric or the framework prompt). Existing
  sessions/tokens. **No new endpoint, no setup.**
- **Effort:** S–M. **Wave:** 2 (both apps).

### 4. Launcher app shortcuts (both apps)
- **What:** Long-press the app icon → direct actions. Workspace: *Scan QR*,
  *Mark attendance*, *Collect fees*, *Waiting for you*. Connect: *Fees*,
  *Attendance*, *Student Card*, *Homework*. Static shortcuts in the
  manifest plus, for Workspace, dynamic ones shaped by the signed-in role
  (the same capability map that shapes the nav).
- **Evidence:** Android's own guidance separates the mechanisms cleanly —
  shortcuts for "open this exact screen" actions a user already knows;
  our daily-driver actions (a teacher's register, the QR scanner) are
  textbook cases, currently buried 2–3 taps deep. Fedena markets the same
  idea in-app ("your upcoming class on the dashboard itself") — shortcuts
  take it one level further out, to the launcher.
- **Stack:** App-only (manifest shortcut XML + intent routing into
  existing screens). **No new endpoint, no setup.**
- **Effort:** S. **Wave:** 2 (both apps).

### 5. Digital permission slips + notice acknowledgement (both apps) — NEW API-64
- **What:** When the office sends a notice that needs a response (trip
  consent, photo consent, "I have seen the fee schedule"), it is marked
  *response needed*. In Connect the parent sees the request on the notice
  and taps **Agree** or **Decline** — recorded with their name, the child,
  and a timestamp. In Workspace the office opens the notice and sees the
  per-class response list: responded / still pending, so the teacher knows
  exactly which families to chase. This replaces the paper slip that goes
  home in a school bag and may never come back.
- **Evidence:** Classter's Play listing carries "**Consents: Submit
  consents for school activities**" as a named parent feature — it is a
  standard expectation in international school apps, and entirely absent
  from Smart School's notice board (a notice today is one-way, with no
  proof of receipt at all).
- **Stack:** Needs **one new endpoint family in the extension pattern**
  (proposed **API-64**: consent create-on-notice, family respond, office
  response list) + an extension-owned table (the extension already owns
  tables — `api_staff_sessions`, `api_sync_log` — so the pattern is
  proven). Rides on API-60 notices. Explicit, logged, safeguarding-
  friendly by design — deliberately *not* passive read-tracking (see
  Rejected). **No school-side setup.**
- **Effort:** M. **Wave:** 2 (builds directly on the shipped API-60).

### 6. Home-screen widgets (both apps)
- **What:** At-a-glance widgets in Calm Campus styling, fed from the app's
  own cache and refreshed whenever the app syncs (plus the proposal-2
  background refresh):
  - Connect "**Today**": child's next classes today, attendance state
    today (Present/Absent/not marked yet), fees-due balance with a
    "last updated" caption (never unlabelled stale money data).
  - Workspace "**My day**": my classes today, unmarked-register count,
    approvals waiting (from API-02's cached worklist).
  Tapping any element opens the exact screen in the app.
- **Evidence:** Android Developers' widget guidance defines widgets as
  "'at-a-glance' views of an app's most important data" on the home
  screen; PowerSchool's current mobile marketing leads with dashboard
  widgets (grades, attendance, fees) as the engagement surface. Our Home
  screens already compute exactly these three numbers — the widget is
  the same data one surface earlier.
- **Stack:** App-only: AppWidgetProvider + RemoteViews (framework APIs,
  compatible with the Gradle-free build). Data strictly from cache.
  **No new endpoint, no setup.**
- **Effort:** M. **Wave:** 2 (Workspace first — its data is already
  cached by the worklist), Connect in the same wave if build capacity
  allows, else early Wave 3.

### 7. Scan-to-find in Library and Inventory (Workspace) — micro-add inside planned Wave 2 scope
- **What:** In the planned API-100 library catalogue and API-110 stock
  screens, add a **Scan** button: scan a book's ISBN barcode to find/add
  the book, or an item's barcode label to find the stock record.
- **Evidence:** The school's library and inventory both sit at **zero
  records** (plan standing conditions) — the moment the office starts
  keying in books, typing ISBNs one by one is the friction that kills the
  module; every library system treats barcode-first entry as the default.
- **Stack:** Free on our rails — the vendored ZXing decoder already in
  the tree reads EAN/ISBN; the QR scanner UI exists. Folds into the
  already-planned API-100/110 builds. **No new endpoint, no setup.**
- **Effort:** S. **Wave:** 2 (as part of the library/inventory build,
  not a separate item).

### 8. In-app version check + update prompt (both apps)
- **What:** On sign-in (throttled to once a day) the app checks the
  current published version; if a newer build exists it shows a calm
  notice — "A newer version of IQRS Workspace is available" + the
  download link — dismissible, never blocking. Matters because the apps
  are side-loaded APKs until the store milestone: families silently run
  stale builds (the owner himself had to re-ask for the current APK
  during Wave 1C week).
- **Stack:** One tiny read — extend the **API-230** `systemStatus`
  family (already planned, Wave 3) with `app_versions`, or an equivalent
  minimal family-side read for Connect; pulling just this forward is
  cheap. Needs the school to keep publishing the APK at one stable URL
  (already the distribution practice). **No school-side setup beyond
  that.**
- **Effort:** S. **Wave:** 2.

### 9. WhatsApp channel for reminders, absence alerts and receipts (Workspace → families) — ⚠ SCHOOL-SIDE SETUP
- **What:** Add `channel:whatsapp` to the planned messaging design
  (API-29 `feeReminderSend`, API-61 `messageSend`): fee reminders, absence
  alerts and payment receipts delivered as approved WhatsApp template
  messages from the **school's own number**, consent-based per guardian,
  with the same delivery log the plan already specifies (API-61 log).
- **Evidence:** This is the decisive local-market finding. **Every**
  Pakistani school system researched leads with WhatsApp as the primary
  family channel: Skoo ("Parents don't open portals. They open
  WhatsApp" — fee reminders, absence alerts, receipts via the official
  Meta Business API), Schooliee (absence WhatsApp the moment the register
  is saved; receipt on WhatsApp at the desk), Rehnuma, One School,
  SchoolPortal.pk (fee vouchers as PDF on WhatsApp). Our plan's channels
  are email/SMS/push only — for this school's parents, WhatsApp is the
  channel that is actually read.
- **Stack:** Extension of planned API-29/61 (server-side sender in the
  extension family). ⚠ **Flags: requires school-side setup — a Meta
  WhatsApp Business account + a school number + message-template
  approvals — and per-message cost borne by the school.** Not a paid
  add-on, but a third-party account the school must own. Consent capture
  rides proposal 5's machinery nicely.
- **Effort:** M (after setup). **Wave:** 3, conditional — sequence with
  the other school-setup items (C-10/C-11).

### 10. PTM booking — parent–teacher meeting slots (both apps) — NEW API-65 · ⚠ OWNER DECISION
- **What:** Structured meeting booking, **not chat**: the office (or each
  teacher) publishes PTM availability — a PTM day with time slots, or
  weekly windows. A parent books a slot for a child + teacher in Connect
  and gets a confirmation; the teacher sees the day's meeting list in
  Workspace (child, parent, slot, optional one-line topic chosen from a
  list — Progress / Behaviour / Fees / Other). Reminders ride proposal
  2's local notifications. Every booking is logged and visible to the
  office — the safeguarding properties chat lacks.
- **Evidence:** Classter's parent portal markets "schedule meetings with
  teachers" as a core parent capability; Pakistani competitor Skoo lists
  "**PTM booking**" in its parent-app headline features. PTMs are a fixed
  ritual of Pakistani school life and today run on paper slips and phone
  calls to the office.
- **Stack:** **No vendor data model exists** → net-new endpoint family in
  the extension pattern (proposed **API-65**) + extension-owned tables.
  ⚠ **Flag: owner decision first** — it creates a new school workflow
  (like the plan's chat decision in §2.5/C-16, but deliberately
  structured: no free-text messaging, no always-on inbox).
- **Effort:** M–L. **Wave:** 3 (late Wave 2 only if the owner
  prioritises it).

### 11. Progress trends for families (Connect)
- **What:** On the results side of Connect, a per-child **Progress**
  view: subject-wise percentage across exams as simple term-over-term
  bars, plus the attendance percentage trend — the family's own child
  only. Deliberately **no class rank and no comparison with other
  children** (API-42's rank stays staff-side; see Rejected).
- **Evidence:** PowerSchool markets "grade trends" visualisations and
  dashboard progress arrows as a headline parent feature; Classter
  markets a "Session Dashboard: quick view of academic progress".
  Parents today can see each exam in isolation but cannot answer "is my
  child improving in Maths?" without doing arithmetic across result
  screens.
- **Stack:** App-only aggregation over the exam-result reads Connect
  already makes. ⚠ **Condition:** production has **0 exams configured**
  (plan §2.7 standing condition) — the view ships with its honest
  not-set-up state and lights up when exams exist; the D2 staging
  fixtures give it real data to be checked against.
- **Effort:** M. **Wave:** 3 (value arrives with exam data; build is
  safe to do in Wave 2 alongside API-40–44 if capacity allows).

### 12. Pickup pass — authorised dismissal (both apps) — NEW API-73 · ⚠ OWNER + POLICY DECISION
- **What:** For today only, a parent designates who is collecting their
  child (name + relation — e.g. an uncle or driver instead of the usual
  guardian) and Connect generates a **pickup pass**: a QR + short code
  expiring at end of day. The duty teacher/gate staff scan it in
  Workspace (the proven QR rails) and see the child's name, class,
  photo and the authorised person's name before releasing; the release
  is timestamped and logged, and the parent sees "collected at 2:41 pm"
  in Connect. (Distinct from plan API-120's transport *pickup points*,
  which are bus-route stops — this is person authorisation at the gate.)
- **Evidence:** Pickup authorisation is an entire product category —
  PikMyKid sells schools exactly this: delegated pickup persons,
  verified release, timestamped dismissal, "minimize custody issues".
  Our school tops out at Class Eight with a large Playgroup/KG cohort —
  precisely the ages where "who took the child?" must have an answer
  better than memory.
- **Stack:** Net-new extension endpoint family (proposed **API-73**) +
  extension-owned table; QR payload discipline mirrors the Student Card
  (`IQRS-<id>` pattern). ⚠ **Flags: owner decision + a school dismissal
  policy decision** (who may release, cut-off for same-day changes)
  before any build.
- **Effort:** L. **Wave:** 3 / later.

### 13. Early-years daily report (both apps) — NEW API-55 · ⚠ OWNER DECISION (teacher workload)
- **What:** For Playgroup / KG 1 / KG 2 — **23 of the school's 77
  sections** — the class teacher files one short end-of-day report
  **per class** (activities covered, meal/snack note, nap for
  Playgroup, a one-line class note, optional photo) and parents see
  "Today in class" in Connect. Class-level first, by design: per-child
  daily reporting is the workload trap that makes teachers abandon
  such systems.
- **Evidence:** Lillio (formerly HiMama), the leading early-years
  platform, is built on daily reports: 91% of parent users rate them
  important or highly important (GetApp review data), and centres cite
  them as the feature families love most. Our early-years cohort is
  proportionally far larger than a typical Smart School install's.
- **Stack:** Net-new — proposed **API-55** in the learning family +
  extension-owned storage; family read via Connect. Photo part must
  respect consent (proposal 5). ⚠ **Flag: owner decision — the real
  cost is teacher minutes per day, not code.**
- **Effort:** M (class-level). **Wave:** later (post-Wave 3 candidate).

---

## Checked and rejected

- **Free-text chat / messaging (parent↔teacher).** Already examined and
  decided in the plan (§2.5, C-16): no vendor backend exists and chat is
  a safeguarding/logging product decision, not a feature. Competitors
  (Classter, Fedena) market it, but the plan's position stands — not
  re-proposed. Proposal 10 (PTM booking) covers the legitimate need in
  structured, logged form.
- **Face-recognition attendance.** Biometric processing of children for
  a problem QR scanning already solves. Privacy risk vastly outweighs
  any convenience. Rejected outright.
- **GPS live bus tracking.** The web system holds no vehicle-location
  data (plan §2.13 says so plainly); competitors offering "live
  tracking" run their own GPS hardware in the buses — a school-side
  hardware purchase, not an app feature. Rejected unless the school
  buys trackers.
- **Substitution / cover-teacher plans** (EduPage's signature feature).
  Smart School has no substitution data model — there is nothing for an
  app to read. Rejected: no data exists.
- **Cantina menu / meal ordering** (EduPage). No cantina module or data
  at IQRS. Rejected.
- **Wear OS companion app** (EduPage offers one). No evidence of staff
  smartwatch ownership or a workflow it would serve here. Rejected.
- **Passive notice read-receipts** ("seen by 214 parents"). An app-open
  is not a read; the number would give the office false confidence and
  feels like surveillance to families. Proposal 5's *explicit*
  acknowledgement is the honest version of the same need. Rejected in
  passive form.
- **Family-facing class rank / leaderboards.** API-42 computes rank for
  staff use. Showing a child their rank position (or a parent their
  child's standing vs classmates) invites comparison pressure and
  complaints, and no parent-workflow evidence supports it. Kept
  staff-side deliberately (see proposal 11).
- **AI-written notices / AI fee-recovery messaging** (marketed by
  Pakistani competitor Rehnuma). Machine-written messages sent to
  parents in the school's name — in Urdu and English — without a
  human draft-and-approve workflow is a trust risk the school doesn't
  need; its notices are short and written by people today. Rejected
  for now; revisit only as draft-and-approve with an owner decision.
- **Geofenced / location-verified staff check-in.** Location
  surveillance of staff, trivially spoofable, and unnecessary — the
  planned API-81 QR check-in proves presence at the office code
  without tracking anyone. Rejected.
- **Student health / medical records.** No vendor module in use,
  highly sensitive data, no demonstrated demand from the school.
  Rejected.
- **Hand-rolled payment collection (direct bank/Raast integration in
  the app).** C-11 already defines the safe path — the gateway's own
  hosted checkout. Building our own collection path would pull bank
  credentials toward the app and duplicate a planned item with a
  riskier design. Rejected.
- **Offline online-exam attempts.** Connect's attempt flow is online by
  design; offline attempts raise answer-integrity and timing problems
  with no evidence of demand. Rejected.
- **Tablet dual-pane redesign.** Staff work on phones and the office on
  desktop web; no tablet fleet evidence. Existing layouts scale;
  a separate tablet design programme is spend without a user.
  Rejected for now.
- **Hostel / multi-currency.** Already plan C-18 "skip" — no evidence
  IQRS uses either. Not re-proposed.

---

*Method note: competitor claims are from the vendors' own Play
listings / product pages (Classter, Fedena, PowerSchool, EduPage,
PikMyKid, Lillio) and Pakistani market pages (Skoo, Schooliee,
Rehnuma, One School, SchoolPortal.pk), read 2026-11-07; platform
claims from Android Developers' widget/shortcut guidance. Plan
cross-checks are against FEATURE-AND-DESIGN-PLAN.md as of the same
date.*
