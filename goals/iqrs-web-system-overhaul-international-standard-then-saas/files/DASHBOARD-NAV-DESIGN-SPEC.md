# Dashboard & Navigation Design Spec — Calm Campus Web

**Programme:** IQRS Web System Overhaul (staging-first; no live system changes under this spec)
**Companion mockup:** web artifact `iqrs-student-card-dashboard-mockup` (student card + dashboard wireframe, sample data)
**Design system:** Calm Campus Web — Direction A ("Calm SaaS Bento") with the governed borrowings from the design research: Direction C's warmth for the parent portal only, Direction D's journey discipline for parent-facing and money-moving flows, Direction E's Worklist ("items waiting for you") on the admin home.
**Source of findings:** `WEB-APP-AUDIT-AND-DESIGN.md` (audit, scorecard, roadmap) and `DESIGN-DIRECTIONS-SUPPLEMENT.md` (goal: iqrs-school-mobile-app).

---

## 0. Identity tokens (fixed — no other brand colours)

| Token | Value | Use |
|---|---|---|
| Navy | `#10204D` | Primary surfaces, sidebar, headings |
| Dark navy | `#081731` | Sidebar depth, night-navy dark theme base |
| Gold | `#C9A227` / `#D4AB42` | Accent, rules, active states, crest ring |
| Light gold | `#F1CC76` | Highlights on navy, chart accents |
| Ivory / paper | `#FAF7EF` / `#FAF8F3` | Page canvas |
| Pale blue | `#E9EFF5` | Tinted card fills, table striping |
| Type | Georgia (serif) for headlines; Inter / Plus Jakarta Sans for UI text | Tabular numerals for all money and marks figures |

**Crest rule (absolute):** the school crest appears only as a fixed-size circular badge with a gold ring — never stretched, cropped, or used as a loose rectangular logo inside the app chrome. The full horizontal lockup is reserved for the public website header, printed documents, and the login screens, where it is shown whole.

---

## 1. The Student Card (flagship — summary; full visuals in the mockup)

One card design serves three surfaces, so a parent, a teacher, and a gate guard all recognise the same object:

- **On-screen card** (student dashboard + student profile): landscape ID-card proportions. Front — crest badge, school name in Georgia serif, motto, photo (or styled initials until a photo exists), student name in serif, class/section, roll number, admission number, session, a **real QR code encoding `IQRS-<student id>`** (the same identifier the staff QR attendance already scans) and a **real Code128 barcode encoding the admission number**. Back — guardian name and phone, school address (New Aslam Town, Rahim Yar Khan) and phone (03006736049), signature strip, return-to-office line.
- **Print card:** the identical layout at **CR80, 85.6 × 54 mm**, produced by the unified print layer (see `PRINT-SYSTEM-PLAN.md`): 3 mm bleed, safe margins, 300 DPI artwork, one approved template — never a per-module hand-rolled print view again.
- **Sample in the mockup:** SUBHAN ALI, IQ-STU2134, Seven – Diamond (Hifz Boys), father Shakeel Ahmad, session 2025–26 (QR encodes `IQRS-2397`).

The card is also a data-quality instrument: it renders honestly from the record — a missing photo shows initials, a missing guardian phone shows as missing on the back — so incomplete records (a named audit finding) become visible at a glance instead of hiding in a form.

---

## 2. The admin dashboard — a department-wise feature-card launchpad

### 2.1 Layout (wireframe in the mockup, Section 2)

```
┌──────────┬───────────────────────────────────────────────────────┐
│  slim    │  Top bar: global search · session 2025–26 · user menu │
│  role-   ├───────────────────────────────────────────────────────┤
│  shaped  │  "Waiting for you" strip (Worklist):                  │
│  sidebar │  [4 classes: attendance not marked] [Fees awaiting]   │
│          │  [3 leave approvals] [2 new enquiries]                │
│  (dept.  ├───────────────────────────────────────────────────────┤
│  icons + │  Department groups, each a row/grid of feature cards: │
│  labels) │   Students        [cards…]                            │
│          │   Academics       [cards…]                            │
│          │   Fees & Accounts [cards…]                            │
│          │   … (only the departments this role owns)             │
└──────────┴───────────────────────────────────────────────────────┘
```

- The dashboard is **not** a chart wall. Charts move to Reports; the home screen answers two questions: *what needs me today?* and *where do I go for X?*
- Every feature card carries a **live signal** — a count, a queue, or a state — so the dashboard is a work surface, not a menu. Signals must say **what they count** (students vs records): the current dashboard tile "Fees Awaiting Payment 25/2,619" appears to count *paid* records; in this design that tile reads "Fees awaiting — 2,594 of 2,619 fee records" and links to the filtered list it counted.
- A card whose module is **not yet set up** shows a setup state ("Exams — not set up yet · Set up") instead of a fake zero — zeros in the current system hide the difference between "nothing today" and "never configured" (audit: 0 exams in all 8 groups looked like data, not absence).

### 2.2 Departments and their feature cards

**Students**
| Card | Live signal |
|---|---|
| Student list | Total on roll — 1,668 students |
| Admit student | Admissions this month |
| Student card | Opens the card (§1) for any student — print + screen |
| Promote / transfer | Classes awaiting promotion at session change |
| Records to complete | Students missing photo / DOB / guardian phone (audit: blank at scale) |
| Alumni | Leavers this session |

**Academics**
| Card | Live signal |
|---|---|
| Mark attendance | Classes not yet marked today — *n* of 12 |
| Attendance register | Today's school-wide % once marking closes |
| Timetable | Sections with no timetable set (audit: "Not Scheduled" everywhere) |
| Subjects & groups | Setup state — only 2 subjects exist today; card shows setup until the subject list is built |
| Homework | Given today / awaiting checking |
| Exams & results | Setup state until the first exam exists; then "marks entry open — *n* subjects left" |
| Online exams | Published / running now |
| Lesson plan | This week's plans submitted — *n* of *m* teachers |
| Live classes (Gmeet/Zoom addons) | Hidden until configured (§3.2) |

**Fees & Accounts**
| Card | Live signal |
|---|---|
| Collect fees | Collected today (Rs) |
| Fees awaiting | Records awaiting payment, correctly labelled (see §2.1) |
| Fee setup | Fee groups state — flags the ~951 per-student legacy-arrears groups for consolidation |
| Offline payments to verify | Parent-submitted bank payments waiting for the billing approver |
| Income | Recorded this month (audit: currently 0 — the card makes the gap visible) |
| Expenses | Recorded this month |
| Payroll | Next run date / staff paid this month |

**Human Resource**
| Card | Live signal |
|---|---|
| Staff directory | 110 staff · records with placeholder/shared phone numbers flagged for cleanup |
| Leave approvals | Applications waiting — *n* |
| Staff attendance | Marked today — *n* of 110 |
| Staff card | The staff twin of §1 (same design family) |

**Library** — hidden until configured (0 books today).
| Card | Live signal |
|---|---|
| Books | Catalogue size once the first book exists |
| Issue / return | Books out · due back today · overdue |

**Transport** — hidden until configured (0 vehicles/routes today).
| Card | Live signal |
|---|---|
| Routes & vehicles | Active routes |
| Transport fees | Linked to Fees & Accounts dues |

**Communication**
| Card | Live signal |
|---|---|
| Notice board | Last notice date (audit: none posted — card shows "No notices yet") |
| Messages (email/SMS/WhatsApp) | Sent this month |
| Public website (Front CMS) | Site state — today the homepage is an empty placeholder; card shows "Website needs content" until fixed |

**Front Office**
| Card | Live signal |
|---|---|
| Admission enquiries | New today · follow-ups due (audit: 0 recorded — the funnel is invisible today) |
| Visitors | Checked in today |
| Complaints | Open |

**Reports** — the 51 existing reports, regrouped under the same departments, one table + filter + export pattern, consistent report header (the reports centre from the audit roadmap).
| Card | Live signal |
|---|---|
| Report centre | Most-used reports for this role |
| Exports | Recent exports |

**System** (Super Admin / Admin only)
| Card | Live signal |
|---|---|
| Users & roles | Active staff logins |
| Modules | Every module with its state: On / Not set up — this is where hidden modules live (§3.2) |
| Payment gateways | State per gateway — today: none configured, JazzCash blank, fees cash-only; card shows setup until a gateway is live |
| Backups | Last backup time + restore-test state |
| Security | MFA adoption among staff; session/token policy state |
| Mobile app | API URL + app version state |

### 2.3 The "Waiting for you" strip

Borrowed from Direction E's Worklist floorplan: a single queue across departments, sorted by urgency, each item deep-linking to the exact filtered screen that clears it:

1. Attendance not marked — *n* classes (clears as teachers mark)
2. Fees awaiting — records past due date, correctly counted
3. Offline payments to verify — *n* (billing approver's queue)
4. Leave approvals — *n* (HR/Admin queue)
5. New admission enquiries — *n*, with follow-ups due today separated from new
6. Setup debts — exams not created, subjects incomplete, gateway not configured (shown to Admin/Super Admin only, dismissed permanently once set up)

---

## 3. Navigation model

### 3.1 Role-shaped sidebar

The sidebar is a **slim rail of departments** (icon + label, collapsible to icons), and a user sees **only the departments their role owns** — the current system shows one ~35-module tree to everyone, burying the two working areas (student records, fee collection) under unused add-ons.

| Role | Departments visible |
|---|---|
| Super Admin | All ten, incl. System |
| Admin (Principal) | Students, Academics, Fees & Accounts, HR, Library, Transport, Communication, Front Office, Reports (+ System view-only where permitted) |
| Teacher | Academics (own classes first), Students (own classes, read), Communication, HR (my leave, my payslip) |
| Accountant | Fees & Accounts, Reports (finance), Students (fee view), HR (payroll) |
| Librarian | Library, Students (read) |
| Receptionist | Front Office, Students (read), Communication |

Within a department, the second level is the feature-card list itself — the dashboard and the department page are the same surface, so there is exactly one way to reach any feature: sidebar → department → card, or search (§3.3).

### 3.2 Hidden until configured

A module **does not appear** in any sidebar or dashboard until it is set up. "Set up" is a concrete, checkable state per module, e.g.:

- Library: ≥ 1 book in the catalogue, or a librarian enables it in System → Modules
- Transport: ≥ 1 vehicle and route
- Hostel: addon activated + a hostel defined
- Live Classes / Online Course / CBSE: addon activated + its credentials/courses exist
- Chat: hidden until a real messaging backend exists (the audit and source study proved no chat endpoints exist — the menu item must not promise what the system cannot do)

Super Admin manages all of this in **System → Modules**, where every module shows On / Not set up. This single rule removes most of the current sidebar's noise without deleting any capability.

### 3.3 Global search

One search box in the top bar (keyboard-first, Ctrl+K), searching three things in one result list:

- **Students** — by name, admission number (`IQ-STU…`), roll number, or guardian phone; duplicate names are disambiguated with class/section and father's name on the result row (the current keyword search returns the wrong same-named child — a named audit finding).
- **Staff** — by name or employee ID.
- **Features & actions** — "collect fees", "mark attendance", "print card" jump straight to the workflow, respecting role permissions.

Recent items and the user's own classes/sections rank first.

### 3.4 Breadcrumbs

Every inner page carries **Department / Feature / Record** (e.g. *Students / Student list / Subhan Ali*). A record crumb always returns to the *filtered* list the user came from — never to a blank filter form.

### 3.5 Filter state persists — a named defect, fixed by design

**Defect (live-observed in the audit):** in Attendance and Class Timetable, the **Section dropdown resets to blank after searching**, and every list in the system demands Class + Section before showing anything.

Rules in this design:

1. Session, class, section, and date live in **one shared filter bar**, identical on every list screen.
2. Filter choices **persist** across searching, opening a record, and moving between modules in the same session; they are restorable from the URL so a bookmarked or shared link reopens the same view.
3. Lists open on the **last-used filter** (a teacher lands on her own class), never on an empty form.
4. Changing one filter never silently clears another.

**Acceptance test:** mark attendance for Seven – Diamond, open a student, return — class, section, and date are exactly as left; repeat on the timetable and fees-due screens (the two screens where the defect was observed).

### 3.6 Session and context

The current session (2025–26) is shown in the top bar and is switchable there — not buried in Settings — because half the audit's oddities (empty exams, December session start) trace back to staff working in the wrong session without realising it.

---

## 4. Mapping — today's ~35 modules → the ten departments

| Current module / addon | Department | Notes |
|---|---|---|
| Student Information | Students | incl. Student CV, Multi Class |
| Online Admission | Front Office | Feeds the Students roll on confirmation |
| Certificate | Students | Print family — one template set with §1 |
| Alumni | Students | |
| Behaviour Records (addon) | Students | Hidden until configured |
| Student Attendance | Academics | incl. QR Code Attendance (addon) |
| Academics (timetable, subjects) | Academics | |
| Homework | Academics | |
| Examination | Academics | incl. Online Examination |
| CBSE Examination (addon) | Academics | Hidden until configured |
| Lesson Plan | Academics | Hidden until configured |
| Live Classes — Gmeet / Zoom (addons) | Academics | Hidden until configured |
| Online Course (addon) | Academics | Hidden until configured |
| Annual Calendar | Academics | School calendar + events |
| Download Center | Academics | Study material for students |
| Fees Collection | Fees & Accounts | incl. Quick Fees Create (addon) |
| Income | Fees & Accounts | |
| Expense | Fees & Accounts | |
| Thermal Print (addon) | Fees & Accounts | Receipts move to the unified print layer |
| Human Resource | Human Resource | Staff, payroll, leave |
| Library | Library | Hidden until configured (0 books) |
| Transport | Transport | Hidden until configured (0 vehicles) |
| Communicate | Communication | Notice board, messages |
| Chat | Communication | Hidden — no backend exists (see §3.2) |
| Front CMS | Communication | The public website |
| Front Office | Front Office | Enquiries, visitors, complaints, postal/phone logs |
| Inventory | System | Back-office operations (stock & assets) |
| Hostel (addon) | Students | Residential — hidden until configured |
| Reports (51) | Reports | Regrouped by department, one pattern |
| System Settings | System | Users/roles, sessions, general settings |
| Two Factor Authentication (addon) | System | Security — enable for all staff (audit roadmap) |
| Multi Branch (addon) | System | Hidden; becomes relevant in the SaaS phase |

Personal items (Calendar To-Do List, own profile) live on the home screen and in the user menu, not in the department rail.

---

## 5. What this spec deliberately does not do

- It does not change any live system — implementation runs staging-first under the programme plan, in the audit roadmap's order (security → data → workflows → design).
- It does not invent signals: every count named above is one the system already computes or can compute from existing records; where the underlying data is broken (fees counting, HR placeholders), the card shows the honest state and the cleanup is tracked in the flaw register.
- Print layouts beyond the student card are specified in `PRINT-SYSTEM-PLAN.md`; this spec only fixes the rule that there is **one** print layer and the card is its flagship.
