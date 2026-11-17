# PreSkool Side-by-Side Audit — 2026-11-16

**Ordered by the owner, 2026-11-16 ~22:48 PKT**, after his own signed-in staging check
rejected the state ("na student profile same, na koi internal pages same… sidebar main
menu ajeeb say button… ajeeb say tables or boht sa unsorted data or boht sa documented
(developers reference) text"). Method: staging and the purchased vendor package opened
side by side and read from **rendered pages** (CDP captures), not from records.

**Scope:** staging only. Production untouched. Audit only — no code was changed.
**Captures:** 63 staging screens (SA + Teacher sessions, disposable proof staff,
deleted after) + 13 vendor pages from the frozen package
(`rektrs-preskool` branch `html`). Evidence:
`hidden_files/preskool/sidebyside-2026-11-16/evidence/` (`staging/`, `vendor/`,
`paired/` composites).

---

## Headline verdict

**The owner is right.** The vendor *shell* (header, sidebar frame, cards, colours)
is genuinely in place. What sits inside that shell is, on most screens, **not the
vendor's pages**: it is the legacy Smart School menu and legacy data rendered in
vendor-shaped boxes, workspace pages whose main content is developer commentary,
plain legacy tables that overflow their cards, and lists whose first screens are
full of leftover test/fixture records from the build lanes themselves.

Honest count, signed-in admin screens captured (61):

| Verdict | Count | Meaning |
|---|---|---|
| Genuinely resembles the vendor page | **8** | Design language **and** composition recognisably the vendor's |
| Vendor shell only | **44** | Vendor frame/header/cards, but home-grown, signpost, stub or legacy content inside |
| Does not resemble at all | **9** | Legacy table/document renders, broken elements, or a 404 |

The 8 that resemble: Admin Dashboard, Teacher Dashboard, staff login,
Fees Overview, Print Studio, Print Section, Print Documents, Notifications list —
and even two of those (both dashboards) have their most prominent cards populated
by test records (below).

---

## Paired-capture index

Side-by-side composites in `evidence/paired/` (staging left, vendor right):

| Pair | Files |
|---|---|
| Sidebar (SA vs vendor) | `paired/sidebar-sa-vs-vendor.png` |
| Dashboard | `paired/dashboard.png` |
| Student profile | `paired/student-profile.png` |
| Students list | `paired/students-list.png` |
| Fees collections | `paired/fees-collections.png` |
| Fees arrears | `paired/fees-arrears.png` |
| Attendance register | `paired/attendance-register.png` |
| HR staff list | `paired/hr-staff.png` |

Full-page PNG + visible text + table dumps for every screen:
`evidence/staging/<tag>.{png,txt,json}`, `evidence/vendor/vendor-<page>.{png,txt,json}`.

---

## (a) Sidebar — what the "strange buttons" actually are

**The box style is the vendor's own.** In the purchased package, top-level sidebar
items also render as light rounded boxes with an icon tile and a "+" expander
(Application, Layouts, Students, Teachers…). The staging sidebar's frame, brand
card, section headers and spacing match the vendor's closely
(`paired/sidebar-sa-vs-vendor.png`). There is no rogue CSS inventing buttons.

**What is actually wrong is what fills the boxes:**

1. **The menu content is the legacy Smart School menu, not the vendor tree.**
   The sidebar is populated by the legacy dynamic menu (29 `submenu` groups,
   Font Awesome `ftlayer` icons — the vendor uses its own line-icon set) carrying
   legacy labels: *Student Information, Print & Documents, Alumni, Student CV,
   QR Code Attendance…*. Expanded sections show the full legacy sub-menus
   (Student Details, Student Admission, Disabled Students, Multi Class Student,
   Bulk Delete, Student Categories, Student House, Disable Reason, Households;
   Search Due Fees, Fees Master, Fees Group, Fees Type, Fees Discount, Fees Carry
   Forward, Fees Reminder…). 297 anchors in the SA sidebar. The vendor's tree
   (Students / Teachers / Parents / Guardians / Staff / Users under People &
   Admission) exists nowhere in it.
2. **Two dead mock links in the main menu.** *Student Dashboard* and *Parent
   Dashboard* are `pk-mock-item` placeholders (`href="javascript:void(0);"`) with
   the developer tooltip **"Portal dashboards are PF-3 scope"**
   (`application/views/layout/sidebar.php`). They look like menu items and do
   nothing when clicked.
3. **Broken user avatar.** The sidebar user card (and the header avatar) renders
   a broken-image icon with alt text spilling out ("Use…") whenever the signed-in
   staff member has no photo — instead of the vendor's default avatar/initials.
4. The Teacher sidebar is the same legacy tree, permission-trimmed (105 items).

So the owner's perception is accurate in effect: the *items* look and behave
strangely because they are the old system's menu wearing the new system's boxes,
with two dead entries and a broken avatar.

---

## (b) Student profile — `admin/pkstudents/profile/2667` vs vendor `student-details.html`

**Does not resemble the vendor page at all.** The vendor page is a 360° profile:
gradient hero card with photo, status chips and donut stats; ten stat mini-cards;
a tabbed right column (Overview, Attendance, Academics, Exams & Results, Fees,
Timetable, Health, Library, Documents, Timeline, Achievements, Discipline,
Communication, Notes, Audit Trail); Personal Information as label/value tiles;
Parent & Guardian, Transport, Hostel and Medical cards. The staging page shares
only the title "Student Profile", the breadcrumb and the Edit Student button.
Everything else differs:

- **The page is a scrolling document of prose paragraphs** — and the prose is
  developer working notes, printed as page copy (see §c): "(BL-020)… vendor CV
  builder, which is not rebuilt here", "(FP-060)… producer renders", "(BL-006(e):
  13 methods)… nothing is re-implemented here", "deposit + sub-key inside its
  `amount_detail`", "(BL-043 FP-017 fix)".
- **No photo** — an initials circle ("AI") where the vendor has a photo card with
  profile-completion bar and status chips. No stat cards, no tabs, no guardian
  card, no personal-information tiles.
- **The on-screen ID card is broken**: the barcode prints over its own caption
  ("IQ-STU14" struck through the bars), the QR caption is truncated ("IQRS…"),
  the admission number is truncated ("IQ-S…").
- **Enrolments table anatomy is broken**: the last column header ("Fee position")
  is missing from the header row and floats at the row's right edge.
- **Raw data-dump sentences**: "Behaviour points: 0 across 0 incident(s).
  Household: Household 1. Category: . House: ." — empty fields printed as dots.
- **Fee invoices table overflows the card** — the State column is clipped at the
  right edge ("Rece…" badge cut off).
- Sections are headed in developer language: "ID card", "Enrolments — current
  session (2025-26)", **"CV builder — labelled actions (vendor doors)"**,
  "Fee invoices — amounts actually received".

Source of the prose: `application/views/admin/pkstudents/profile.php` and the
shared partial `application/views/student/_pk_profile_header.php` — the same
partial feeds the family portal profile, so the portal carries the same text.

---

## (c) Developer / reference text visible on pages — full results

Two sweeps over the visible text of all 63 captured staging screens.

**Sweep 1 — code references and developer language: 18 of 63 pages, 146 lines.**

Worst offenders:

| Page | Lines | What the user reads |
|---|---|---|
| Students list | 51 | Every row's action cell: **"Profile · Vendor record"** |
| HR staff list | 50 | Same — **"Profile · Vendor record"** on every row |
| HR review | 13 | Same, on a register of lane-created "W2A script" staff |
| Fees corrections | 10 | "BL-141 P-3 cycle reversal — restore fixture shells", "staff:BL041PROOF" as business records |
| Student profile | 6 | BL-020 / FP-060 / BL-006(e) prose (§b) |
| HR profile | 3 | "read live from the vendor tables. Editing stays on the vendor record." |
| Fees arrears | 2 | "the legacy balances FL-080 carried into…", ageing-policy prose with codes |
| Fees discounts | 1 | "is BD-009 / BL-088's home and is **deliberately not built here**" |
| Attendance period, Alumni, Downloads, Lifecycle, Students overview, Exams online, HR payroll… | 1 each | The **"vendor doors" signpost family**: "Marking stays on the vendor doors", "Manage alumni on the vendor doors", "Admissions, edits, disable/restore… stay on the vendor doors" |

**Sweep 2 — the "vendor doors / stays on the vendor / read live" signpost pattern**
appears on at least 15 workspace pages. Several pages are **near-empty stubs whose
only real content is that signpost**: attendance *By date*, *Period*, *QR*,
*Biometric*, exams *CBSE*, students *Alumni* (all ≈1,060 px tall, no table, one
paragraph). These are not finished pages; they are notes saying the function
lives somewhere else.

**Sourced on-host** (staging tree grep, 2026-11-16):

- "Vendor record" → `views/admin/pkstudents/students.php`, `views/admin/pkhr/staff.php`,
  `views/admin/pkhr/review.php`, `views/admin/pkstudents/profile.php`
- "vendor doors" → `views/admin/pkstudents/{students,alumni,downloads,lifecycle,overview,profile}.php`,
  `views/admin/pkattendance/period.php`, `views/admin/pkhr/structure.php`
- Profile prose (BL-020 / FP-060) → `views/admin/pkstudents/profile.php`,
  `views/student/_pk_profile_header.php`, `controllers/admin/Pkstudents.php`
- Sidebar mock tooltip → `views/layout/sidebar.php`
- "deliberately not built here" → `views/admin/pkfees/discounts.php`
- "read live from the vendor" → `views/admin/pkhr/{overview,profile,payroll}.php`,
  `views/admin/pkstudents/overview.php`, `views/admin/pkops/{library,overview,transport,inventory}.php`
- HR overview even prints: **"Staff ID sequence: records run from #1 to #312 with
  124 present and 188 numbers absent — retired fixture and deleted records…"** —
  an on-screen explanation of the lanes' own test-data history.

**The notice board is part of this.** Communicate → Notices (the landing and
`/notices` render the identical page) lists internal system mail as school
notices: "Money Integrity Sweep — 2026-11-13" runs #1–#12, "Payables — weekly
direct-receipt report", and **"Smoke Test Notice (staging) — Automated staging
verification - please ignore."**

### Separate class: leftover test/fixture DATA inside real lists

Not code text — the staging database itself. Build-lane fixtures were never
cleaned out, and they sit at the top of the school's working lists:

- **Students, Class Four/Daffodils page 1: ~43 of 50 rows are junk** —
  BL021BOne/Two, BL030BOne/Two, BL036AOne/Two, BL042FTest Fixture, BL043Test
  Fixture, BL097 TRAP Fixture, BL141A/B Fixture, and **31 "DEMO Student NN Seed"**
  rows — between the real children.
- **Fees collections opens with 25+ BL141 fixture receipts** ("BL041PROOF" as
  collector); corrections register is largely BL-141 fixture reversals.
- **Exams list: the 8 real exam groups all show 0 exams**; beneath them sit
  10+ "W2A Script Group 1794…", "W2B-CHK Group", "W2CA Script Group" entries.
- **Dashboard hero cards**: "Best Teacher — **Test Teacher M3**", "Top Student —
  **Test Fixture W0**", "Performance Risk Matrix — **DEMO Assessment Group**",
  Activity Timeline admissions "**BL097 TRAP Fixture**", "**DEMO Student 31
  Seed**"; Parent Engagement includes a "**TEST Limited W1A**" role; the whole
  Transport/Fleet/Library block runs on W2A lane data ("W2A Test Book One",
  "W2A Script Route", "W2A Driver", "W2A Probe Route").
- Leave lists are headed by "TEST STAFF M3 / TEST TEACHER M3" applications;
  Behaviour shows 11 "TEST Fixture W0" records; HR review is a register of
  "W2A-1794…" script accounts; Fees income contains "W2F-INV-1 Fixture".

---

## (d) The five table pages vs vendor

Vendor lists are **record grids**: an avatar/photo cell, grouped columns
(STUDENT with name + admission + roll + class in one cell; FEE DETAILS;
PAYMENT DETAILS), a status chip, icon actions, ~16–20 rows per page.
Staging lists are **flat legacy tables** — every field its own column, no
avatars (initials chips), no grouped cells — and three of five overflow or
bury the user in rows:

| Page | Anatomy | Sort order (rendered) | Rows |
|---|---|---|---|
| Students | Flat 8-col table; actions column **clipped at the card's right edge** ("Profile · Vendor recc…"); filter selects are **unstyled browser-default boxes**; a cluster of small square legacy toolbar buttons above the grid | **None.** Admission nos 2328, 2349, 2348…; names AIKA before ANFAAL; rolls 872, 6024, 4075 — raw enrolment order, real and fixture rows interleaved | 50/page, paged |
| Fees collections | Flat 9-col table inside a scroll pane; toolbar is a developer console (search + Saved Views + Columns + icon cluster + "Quick: Counter 1601 / Household 5" chips); **FINE column clipped** | Receipt-id descending (newest first) — sorted, but the newest are the BL141 fixtures | **1,606 rows in one DOM table** |
| Fees arrears | Flat 11-col table; FLAG column empty | Due date, then amount descending — sorted | **951 rows on one page** |
| Attendance register | Month calendar (renders correctly) + marking table whose **Mark cell is naked radio buttons** spelt out as a text blob ("Present Late Absent Holiday Half Day App…") — no pills/segmented control. Page concept (monthly register) has no vendor counterpart; vendor is a daily record grid with status pills, check-in/out, attendance % | By admission no (2135, 2136, 2137…) — sorted | 17 |
| HR staff | Flat 8-col table; DEPARTMENT/DESIGNATION "—" and CONTACT blank for the top rows; action cell "Profile · Vendor record" | Employee-id string order: 9000, IQ-STAF10050, IQ-STAF1… — not a clean order | 50/page |

Class/section pickers repeat the disorder: the register and academics pages list
classes as *Four, KG 1, Playgroup, Eight, Seven, Six, Five, Three, Two, KG 2,
One, Shoba Hifz* — database order, not class order.

---

## (e) One page per module — blunt difference lists

- **Dashboard (Admin)** — Closest to the vendor in design language (welcome
  card, stat chips, chart cards). Differences: hero cards fed by test records
  (Test Teacher M3, Test Fixture W0, DEMO Assessment Group); timeline and
  engagement widgets carry fixture admissions and a TEST role; the entire
  Library + Transport/Fleet block (fuel 3,284 gal, fleet map, "W2A Probe
  Route") is seeded demo content for operations the school does not run here;
  page is a 5,421 px scroll of ~20 widgets vs the vendor's tighter composition.
- **Students — list & profile** — §b and §d. Neither resembles its vendor page.
- **Fees — Overview** — Resembles in language (command-center cards, real
  governed figures). Differences: prose is developer-speak ("the one governed
  fee position", "FINANCE COMMAND CENTER"); the vendor's fees-master is a
  fee-structure table page — composition is our own.
- **Fees — Collections / Arrears / Corrections** — §d. Developer reconciliation
  prose on Collections ("Every collection **on staging**, generalised from the
  Phase 2 slice… must agree to the paisa"); corrections is a fixture register.
- **Academics — Overview** — Stat tiles in vendor language, then a plain table
  of classes **in no order** (Four, KG 1, Playgroup, Eight…); "Manage on the
  governed screens" signpost prose. Timetable is a home-grown grid; vendor's is
  a styled class-time-table.
- **Attendance — Daily Register** — §d. Calendar heatmap renders (the one
  clean fix visible); marking controls are naked radios; intro prose explains
  the "portal convention" for percentages. By-date/Period/QR/Biometric are
  signpost stubs.
- **Exams — Exams** — Real groups all empty (0 exams this session — true on
  staging, but the page reads as unfinished); 10+ script-created groups below
  them; raw `basic_system` key shown as the grade system. Vendor exams page is
  a styled exam list with status chips and actions.
- **HR — Staff / Review / Profile** — §d; profile is the same prose-document
  pattern as the student profile ("read live from the vendor tables… Open the
  vendor record — Edit on the vendor door"), not the vendor's staff-details
  layout (documents + attendance tables, grouped work details).
- **Communicate — Notices** — §c: identical page at both URLs; content is
  internal ops/test notices; intro prose describes the plumbing ("this list,
  the portal feed and the bell all read the same notice record").
- **Front Office** — A "live position" signpost table (all zeros except 7
  enquiries) wrapped in vendor-doors prose; **`/admin/pkfrontoffice/overview`
  is a themed 404** ("Oops, something went wrong — Error 404 Page not found").
- **Portal (public)** — The public landing and family login render in the new
  design (login redirects to the vendor-style `gauthenticate/userlogin`). The
  signed-in portal was not re-captured in this audit (no family proof session);
  note the portal profile shares the `_pk_profile_header.php` partial that
  carries the BL-020/FP-060 prose (§b).

---

## Census classification (61 signed-in admin screens)

- **Resembles (8):** dash-sa, dash-te, auth-login, pkfees-overview, printstudio,
  printsection, printdocuments, notification.
- **Shell only (44):** pkstudents-overview, pkacademics-overview, pkacademics-timetable,
  pkacademics-syllabus, pkacademics-homework, pkacademics-analytics,
  pkattendance-staff, pkattendance-leave, pkexams-schedule, pkexams-marks,
  pkexams-results, pkexams-grades, pkexams-online, pkexams-cbse,
  pkfees-assignments, pkfees-billing, pkfees-allocations, pkfees-discounts,
  pkfees-fines, pkfees-offline, pkfees-income, pkfees-expenses, pkfees-reports,
  pkpayables, pkhr-overview, pkhr-departments, pkhr-designations, pkhr-leave,
  pkhr-payroll, pkhr-ratings, pkstudents-lifecycle, pkstudents-promotion,
  pkstudents-behaviour, pkstudents-alumni, pkstudents-downloads,
  pkattendance-bydate, pkattendance-period, pkattendance-qr, pkattendance-biometric,
  pkcommunicate, pkcommunicate-notices, pkfrontoffice, pkhr-profile.
- **Does not resemble (9):** pkstudents-profile, pkstudents-students,
  pkfees-collections, pkfees-arrears, pkfees-corrections, pkattendance-register,
  pkhr-staff, pkhr-review, pkfrontoffice-overview (404).

---

## Prioritised fix list

**P0 — user-visible internal text and broken-looking elements**
1. Strip all developer prose from rendered pages: BL/FP/PF/D-code paragraphs,
   "vendor doors / stays on the vendor / read live from the vendor" signposts,
   "deliberately not built here" — sources listed in §c. Replace with product
   copy or nothing.
2. Row action text "Profile · Vendor record" → "Profile" (students, staff,
   review lists — `pkstudents/students.php`, `pkhr/staff.php`, `pkhr/review.php`).
3. Sidebar: remove the two `pk-mock-item` dead links + "PF-3 scope" tooltip
   (`layout/sidebar.php`); fix the broken staff avatar (header + sidebar user
   card) to fall back to initials/default image.
4. Purge lane fixture/test data from staging lists (BL*/DEMO/W2*/TEST students,
   receipts, exam groups, staff, leave, behaviour, notices incl. "Smoke Test
   Notice (staging)" and the Money Integrity Sweep notices) — or move staging
   verification to a segregated fixture session so working lists show only
   real records.
5. Fix table overflow: students list and profile fee table clip their last
   column at the card edge; collections clips FINE.

**P1 — profile and main lists**
6. Rebuild the student profile on the vendor `student-details.html` anatomy
   (hero card, stat tiles, tabbed sections, label/value tiles) with real data;
   same treatment for the HR profile vs `staff-details.html`. Fix the on-screen
   ID card (barcode/caption overlap, truncations).
7. Convert the five main lists to the vendor record-grid anatomy (grouped
   cells, avatar, status chip, icon actions); style the filter selects;
   replace the legacy toolbar-button cluster.
8. Impose real default sorts: students by class → roll (or name), classes in
   class order everywhere they are listed; paginate collections (1,606 rows)
   and arrears (951 rows) like the vendor's 20-row pages.
9. Attendance marking: replace naked radio rows with the vendor's status
   pill/segmented control.

**P2 — composition**
10. Replace the legacy sidebar menu content with the vendor tree structure
    (labels + vendor icon set), keeping permission population underneath.
11. Dashboard: drop or gate the seeded demo blocks (Fleet/Fuel/Library) until
    they run on real data; tighten to the vendor composition.
12. Fill or remove the signpost stub pages (by-date, period, QR, biometric,
    CBSE, alumni); fix the front-office `/overview` 404; de-duplicate the
    communicate landing/notices routes.
13. Enrolments table header fix (missing "Fee position" header) and the
    empty-field "Category: . House: ." data-dump sentences on the profile.

---

## Closing count

Of **61** signed-in admin screens opened side by side with the purchased
package: **8 genuinely resemble the vendor pages, 44 wear the vendor shell over
home-grown content, and 9 do not resemble them at all.** The shell work is real;
the page-level work the owner was promised is, on this evidence, mostly not
done — and the build lanes' own test data and developer notes are sitting in
the school's working screens. His rejection tonight was correct.

*Evidence: `hidden_files/preskool/sidebyside-2026-11-16/evidence/` — 63 staging
+ 13 vendor captures (PNG + visible text + table DOM dumps), 8 paired
composites, sidebar DOM dumps for both trees. Proof staff 311/312 created for
this audit were deleted after; staging census returned to 122.*
