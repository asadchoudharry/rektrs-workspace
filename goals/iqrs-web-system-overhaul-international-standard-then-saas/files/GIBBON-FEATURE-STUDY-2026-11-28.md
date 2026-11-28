# Gibbon Feature Study — what Gibbon does, and what our two school systems can learn from it

**Date:** 2026-11-28 · **Type:** STUDY-ONLY feature reference · **Subject:** Gibbon (github.com/GibbonEdu/core, gibbonedu.org), the open-source school platform built by educators and in production use in schools internationally since ~2011.

> **⚠️ LICENCE NOTE — read first.** Gibbon is licensed **GPL-3.0**. This study is a *feature and workflow reference only*: it describes what Gibbon does, in our own words, so we can decide which **ideas** are worth building ourselves. **No Gibbon code, text, or assets have been copied into any Rektrs/IQRS tree, and none may be** — GPL-3.0 code reuse would contaminate our proprietary products. Anything adopted from this study must be implemented independently, the same discipline we applied to the legacy-system feature references.

**Our two systems, as mapped for comparison:**
- **IQRS** = the live Smart School system at IQRS as reshaped by the PreSkool overhaul (staging state per `PRESKOOL-FEATURE-CENSUS-2026-11-20.md`, the 2026-11-17 disposition plan, and RE-AUDIT-2; the FC-1…FC-19 build cards have since been built on staging, with a few proof cycles still partial).
- **Rektrs ERP** = `rektrs-school-erp-lms` per `REKTRS-SCHOOL-ERP-GAP-AUDIT-2026-11-23.md` (17 source-complete / 13 partial / 4 missing of 34 areas; 0 acceptance-complete).

---

## 1. What Gibbon is, in one paragraph

Gibbon organises a school around **teaching first, administration second**. Its core is a set of ~24 modules grouped as Learn / People / Assess / Other / Admin, each switchable per role, plus a library of optional add-on modules schools install as needed. Its centre of gravity is the classroom chain — plan a unit → teach lessons → set and collect homework → grade in a continuous markbook → analyse progress over time — with student records, admissions, attendance, behaviour, fees and messaging wrapped around that chain. It is a single-school, self-hosted web application (PHP/MySQL); there are no official native mobile apps and no multi-tenant SaaS layer.

## 2. Gibbon's proven workflows, area by area (our own words)

**Planner & curriculum.** A teacher builds *units* of work, and inside them individual lessons assembled from reusable content blocks (text, media, links, files). Lessons can be shared with students and parents, not just staff. Learning *outcomes* are defined once and attached to units, so the school can map curriculum coverage across departments; department pages automatically gather their units into a chronological scope-and-sequence that parents and students can browse. Homework set in a lesson is collected online through the same screen and flows into grading. A teacher can also take the class register inside the planner and compare it with the official school register, and can leave reflection notes on how a lesson went. Guest accounts can be invited to view or join lessons.

**Assessment suite (five cooperating pieces).** (1) A **Markbook** that is a continuous gradebook rather than an exam tool: teachers record assessments all term, across every subject, in one longitudinal view per student, and choose per-column whether students/parents can see it; marked work can be returned as files, rubric scores, or voice notes, and personal targets can be set. (2) **Rubrics**: interactive, clickable criterion grids, reusable across classes, whose results accumulate so progress on a skill can be tracked over time and across a cohort. (3) **Formal Assessment**: captures internal and external/standardised test results (baseline tests ship preloaded), converts scores onto a common school scale, and computes a **value-added** signal per student by comparing test outcomes against markbook performance. (4) **Tracking**: graphs markbook + formal-assessment data per student or cohort over time to surface trends, with spreadsheet export for offline analysis. (5) **Crowd Assessment**: student work is shared to a chosen audience — classmates, a class, or wider — for structured peer review and discussion.

**Individual Needs (SEN).** Students with learning needs are flagged and given individual education plans; plans are archived as they are revised so progress is visible longitudinally. The flags surface as indicators inside the planner and the student profile, with differentiation material close at hand for the teacher.

**Student profile & alerts.** One profile assembles everything about a student from across the system. On top of it, the system **generates alerts automatically** — academic, behavioural, medical and SEN — from the underlying records and shows them to the staff who need to know. A fast student finder on the homepage makes the profile the hub teachers actually live in.

**Admissions.** A public application form feeds a priority-ordered queue. On acceptance, the system **creates the student and parent accounts and the family links automatically**, usernames and passwords included — enrolment is a conversion, not a re-typing exercise. A sibling workflow in the Staff module advertises **job openings**, takes applications against them, and converts a successful applicant into a staff member with an account, the same way.

**Attendance.** Registers by form group or individual, absence-pattern views per student, **future absences pre-recorded** so morning registration is faster, absence reports formatted for **emergency evacuation**, and parent visibility of attendance to discourage truancy.

**Behaviour.** Positive and negative notes described with school-defined descriptor and severity lists, free-text detail, and recorded follow-up; form tutors see a summary of recent activity for their group on their homepage.

**Data Updater.** Parents and staff can submit changes to personal and medical details for their own family; submissions sit in a queue for an administrator to process, can be amended by the submitter meanwhile, and the school can report on how current each family's data is (used, for example, before trips).

**People & structure.** Families are first-class (shared addresses, family-linked billing), form groups with tutors, houses as a school structure, staff directory with tiered detail visibility (parents see contact basics; admins see HR detail), staff contracts tracked, and a year-end **roll-over** process that moves enrolments into the new school year.

**Activities.** The school publishes an activities programme; students and parents sign up online, places are allocated first-come-first-served or by manual selection, and attendance registers can be printed for off-site activities.

**Library & resources.** The library catalogues anything loanable (books, devices, cameras), tracks loans, and lets students browse and share their reading record. Separately, a school-wide **Resources** bank catalogues teaching materials by category, purpose, tags and year group, and resources can be inserted directly into lesson plans.

**Timetable.** Individual timetables for any student or teacher, "where is this person now" lookup, **room and facility booking** visible in the calendar, and personal/school Google Calendar overlays.

**Finance.** Fee structures and billing schedules generate invoices that are emailed with receipts and reminders; payments are tracked against families with defaulter lists; and an **expense workflow** handles requests, approval, payment and reimbursement.

**Messenger.** Messages are addressed to audiences assembled from any grouping already in the system — a form group, a teaching class, an activity roster — and delivered by email, SMS, or a **Message Wall**: an individualised live bulletin each user sees on login. Attachments can be links, files, or material pulled from the resources bank.

**Add-on ecosystem (optional modules schools bolt on).** Highlights: **Meet the Teacher** (parents book parent-teacher meeting slots from their dashboard); **Course Selection** (students choose elective courses online and the system drafts suggested timetables); **House Points** (house point tallies accumulate school-wide); **Badges** (define and award achievement badges); **Query Builder** (privileged users run saved ad-hoc queries and export to spreadsheets; a maintained library of 90+ ready queries exists); **Free Learning** (student-driven, interest-based learning units); **Trip Planner** (trip planning with approvals); **Help Desk** (support tickets); **Policies** (policy documents); **Alumni** (alumni self-registration linked to accounts); **Higher Education** (university application tracking); **Mastery Transcript** (competency-based transcripts); plus integrations (Moodle, BigBlueButton) and smaller utilities (Committees, Clinics, Stream, Info Grid).

---

## 3. Gap analysis — Gibbon vs our two systems

Verdict key: **HAVE** = we match or exceed it · **PARTIAL** = the area exists but the named Gibbon depth is missing · **LACK — worth adopting** = we don't have it and the idea earns its place · **LACK — not relevant** = we don't have it and PK school reality doesn't call for it. Rows marked ⭐ are the flagged adoptions (also listed in §4).

| # | Gibbon capability | IQRS (Smart School + overhaul) | Rektrs ERP | Verdict |
|---|---|---|---|---|
| 1 | Lesson planner: units of lessons, reusable blocks, lessons shared with students/parents | PARTIAL — lessons/syllabus/homework built; unit grouping shallow, no lesson sharing to portal | PARTIAL — unit/lesson plans exist in the Curriculum Quality Center source; UI depth + acceptance pending | PARTIAL |
| 2 ⭐ | Curriculum outcome mapping: outcomes attached to units, coverage rolled up by department | LACK — syllabus is a topic list; no outcome construct or coverage roll-up | PARTIAL — curriculum frameworks exist; outcome-coverage roll-up not evidenced | **LACK — worth adopting** |
| 3 | Homework collected online and tied directly into grading | PARTIAL — homework built; grading link is manual | PARTIAL — LMS assignments + grading exist; not planner-tied | PARTIAL |
| 4 ⭐ | Continuous markbook: all-term, all-subject gradebook, one longitudinal view, per-column parent/student visibility, personal targets | LACK — marks are exam-event based (entry → result → report card); no continuous gradebook | PARTIAL — LMS gradebook exists; no school-wide markbook surface across subjects | **LACK — worth adopting** |
| 5 ⭐ | Interactive rubrics tied to outcomes, progress tracked over time/cohort | LACK | LACK | **LACK — worth adopting** |
| 6 ⭐ | Formal assessment: external/baseline test capture, conversion to a school scale, value-added signal | LACK | LACK | **LACK — worth adopting** |
| 7 | Tracking analytics: graph progress per student/cohort over time, spreadsheet export | PARTIAL — report compositions exist; cohort trend analytics thin | PARTIAL — staff analytics reads exist; no trend/builder depth | PARTIAL |
| 8 ⭐ | Crowd (peer) assessment of student work | LACK | LACK | **LACK — worth adopting** (minor) |
| 9 ⭐ | Individual Needs: IEPs archived longitudinally, SEN indicators in planner + profile | LACK — the medical module is a clinic register, not SEN/IEP | PARTIAL — Wellbeing Center holds safeguarding cases; no IEP construct | **LACK — worth adopting** |
| 10 ⭐ | Auto-generated cross-domain alerts (academic/behaviour/medical/SEN) synthesised onto the student profile | PARTIAL — a 360° profile exists; no alert synthesis from the domain records | PARTIAL — rich profile + wellbeing data; no alert roll-up evidenced | **LACK — worth adopting** (the synthesis layer) |
| 11 ⭐ | Data Updater: parent/staff-submitted record changes into an admin approval queue | LACK — all edits are staff-side | PARTIAL — governed profile corrections exist in SIS source; not a parent-facing updater | **LACK — worth adopting** |
| 12 | Admissions conversion: acceptance auto-creates student + parent accounts and family links | PARTIAL — online admission + governed intake built; auto-account/family creation on acceptance is not the shaped flow | HAVE — admissions with atomic admission→enrolment conversion is source-complete | PARTIAL |
| 13 ⭐ | Staff recruitment: job openings, applications, applicant→staff conversion with account | LACK | HAVE — recruitment sits inside source-complete Operations/HR | **LACK — worth adopting** (IQRS side) |
| 14 ⭐ | Activities programme: publish clubs/activities, online sign-up (FCFS or selection), printed registers | PARTIAL — sports built (FC-4); a general activities sign-up workflow is not | LACK — sports is one of the 4 missing modules; no activities workflow | **LACK — worth adopting** |
| 15 ⭐ | Meet the Teacher: parents book PTM slots from their dashboard | LACK — front-office appointments exist but are not PTM slot booking | PARTIAL — Family Engagement has appointments/requests; not a PTM booking flow | **LACK — worth adopting** |
| 16 ⭐ | Course Selection: students pick electives online; suggested timetables generated | LACK | LACK | **LACK — worth adopting** |
| 17 | House points accumulating school-wide | PARTIAL — behaviour records + rewards (FC-1) built; no house-points construct | PARTIAL — Wellbeing points exist; rewards module missing, no houses | PARTIAL |
| 18 ⭐ | Achievement badges defined and awarded | HAVE — rewards/badges built (FC-1) | LACK — rewards & gamification is a missing module | **LACK — worth adopting** (ERP side) |
| 19 ⭐ | Query Builder: saved ad-hoc queries + spreadsheet export for privileged users | HAVE — custom report builder built (FC-13) | LACK — no report builder (a named gap in its own audit) | **LACK — worth adopting** (ERP side) |
| 20 | Free Learning: student-driven self-paced units | PARTIAL — Online Course (LMS) kept, config-hidden | PARTIAL — LMS exists; self-directed pathway framing absent | PARTIAL |
| 21 | Resources bank inserted directly into lesson plans | PARTIAL — content/download centre exists; no planner-linked resource bank | LACK — no resource bank construct | PARTIAL |
| 22 | Room/facility booking inside timetable + calendar overlay | PARTIAL — classrooms register derived (FC-18); no booking workflow | PARTIAL — timetable source-complete; booking not evidenced | PARTIAL |
| 23 | Attendance extras: future absences pre-set, evacuation roll, class-vs-school register comparison | PARTIAL — leave + registers deep (incl. QR); evacuation roll and register comparison not shaped | PARTIAL — attendance source-complete incl. corrections; the extras not evidenced | PARTIAL |
| 24 | Behaviour notes with descriptor/severity lists + follow-up + tutor homepage summary | HAVE — behaviour built over governed records | HAVE — Wellbeing Center is source-complete at core | HAVE |
| 25 | Expense request → approval → reimbursement workflow | PARTIAL — income/expense registers exist; a claim workflow as such is shallow | PARTIAL — finance is source-complete; expense-claim depth not separately evidenced | PARTIAL |
| 26 | Messenger audiences assembled from any system grouping; message-wall bulletin | HAVE — communication centre + templates + schedules built; real SMS rides Sendqon | PARTIAL — campaign governance built, but **no channel actually sends** (providers unbound) | PARTIAL |
| 27 ⭐ | Trip Planner: trip planning with approvals (and current-data reports for the trip) | LACK | LACK | **LACK — worth adopting** (minor) |
| 28 | Higher Education: university application tracking | LACK | LACK | **LACK — not relevant** (typical PK school; only a senior-college niche) |
| 29 | Mastery Transcript: competency-based transcript | LACK | LACK | **LACK — not relevant** (board mark-sheets govern PK reporting) |
| 30 | Policies: policy document management | PARTIAL — privacy/GDPR built (FC-14) | HAVE — privacy/data-lifecycle is source-complete | PARTIAL |
| 31 | Alumni self-registration linked to accounts | HAVE — alumni directory/events built | HAVE — Career & Alumni Center source-complete | HAVE |
| 32 | Help desk / support tickets | HAVE — tickets built (FC-8) | HAVE — service-desk tickets source-complete | HAVE |
| 33 | Year-end roll-over of enrolments | HAVE — promotion built | HAVE — Academic Year Rollover Center source-complete | HAVE |

**Flagged counts:** IQRS carries **13** flagged gaps (rows 2, 4, 5, 6, 8, 9, 10, 11, 13, 14, 15, 16, 27 — counting rows where its cell is LACK, or PARTIAL only where the flagged missing piece is the verdict's subject). Rektrs ERP carries **14** (rows 2, 4, 5, 6, 8, 9, 10, 11, 14, 15, 16, 18, 19, 27, on the same counting rule). Both systems share the same pedagogical core gaps (rows 4, 5, 6, 9) — Gibbon's centre of gravity is exactly where both of ours are thinnest.

---

## 4. ⭐ The adoption shortlist — LACK and worth it

1. **Continuous markbook / gradebook** (both systems) — the single biggest idea in Gibbon. Our assessment is exam-event shaped; a term-long, all-subject gradebook with parent visibility per column is what teachers and parents actually live in between exams, and it feeds everything below.
2. **Rubrics tied to outcomes** (both) — criterion-based grading for projects, presentations, and primary classes where marks alone say little; rubric results accumulating over time double as skills tracking.
3. **Curriculum outcome mapping + coverage roll-up** (both; ERP partially framed) — outcomes attached to units, coverage visible by department/class. Directly strengthens the lesson-plan surfaces we already built, and is a visible quality signal to parents.
4. **Individual Needs / IEP records** (both) — longitudinal individual education plans with indicators in the planner and profile. Inclusion expectations in PK private schools are rising; neither of our systems has any SEN construct today (a clinic register is not one).
5. **Auto-alert synthesis on the student profile** (both) — academic/behaviour/medical/SEN alerts generated from records we already hold. High perceived intelligence for near-zero new data: it is a read-side layer over existing tables.
6. **Meet the Teacher (PTM booking)** (both; ERP partially framed) — parents booking parent-teacher meeting slots is a core ritual of PK school life; today both systems only have generic appointments/enquiries.
7. **Data Updater** (IQRS especially) — parents submit record corrections into an approval queue instead of paper forms and office visits; keeps guardian contact data — the data our SMS/notice flows depend on — current.
8. **Course/subject-group selection** (both) — students choosing elective groups online (the matric science/computer/biology choice is the PK instance), with the selection feeding timetable generation.
9. **Activities sign-up workflow** (ERP entirely; IQRS beyond sports) — publish clubs/societies, take sign-ups first-come or by selection, print registers. ERP also still lacks the sports module itself.
10. **ERP-only quick wins already named in its own audit, confirmed by Gibbon's ecosystem**: badges/rewards module and a query/report builder — Gibbon shows both as small, self-contained add-ons rather than platform surgery.
11. **Formal assessment + value-added** (both, lower priority) — capture baseline/board-style test results, normalise to one scale, and derive a value-added signal. Valuable for a data-led school; needs the markbook (item 1) first.
12. **Peer (crowd) assessment and trip planner** (both, minor) — small, well-bounded workflows; adopt opportunistically, not as programme items.

---

## 5. Balance — where Gibbon is weaker than both of ours

For fairness: Gibbon is **not** ahead everywhere, and several of its absences are exactly our strengths.

- **Payroll: Gibbon has none.** Both of ours run staff payroll (IQRS built incl. payslips; ERP source-complete incl. bank export).
- **Transport: Gibbon has none at all.** IQRS has routes/vehicles/fees built; ERP has routes, vehicles, boarding events and GPS-event ingestion (partial).
- **Hostel and cafeteria: absent in Gibbon.** IQRS has both built (rooms/allocation; menus/orders/wallets); ERP has hostel core and meal events.
- **Native mobile apps: none.** Ours are published on Google Play (IQRS Connect + Workspace), with offline sync and QR attendance; the ERP's Flutter client is a shell but the API contract exists.
- **Pakistan rails: absent.** No JazzCash/Easypaisa, no local SMS-gateway story (its SMS is generic), no WhatsApp channel, no board-pattern exam machinery (date sheets, admit cards, BISE-style mark sheets — all built in IQRS), no fee fine/discount/installment practice of the depth PK schools run (both of ours model it; ERP's finance is source-complete with concessions and family ledgers).
- **Multi-tenancy / SaaS: Gibbon is one school per install.** The Rektrs ERP's entire platform layer (RLS multi-tenancy, provisioning, entitlements) has no Gibbon counterpart.
- **Digital ID cards with QR**: built in the IQRS overhaul; Gibbon has no equivalent.
- **Fee collection reality**: Gibbon emails invoices and tracks payments, with online payment only via third-party add-ons; both of ours are built around counter collection, receipts and arrears management as actually practised here.

**Bottom line:** Gibbon's lead over us is concentrated in *teaching-and-learning depth* — planner, markbook, rubrics, outcomes, SEN, peer assessment — while our lead is in *operations depth* — fees, payroll, transport, hostel, cafeteria, mobile, and PK-specific rails. The adoption shortlist in §4 is therefore deliberately pedagogical: it borrows Gibbon's classroom ideas to complete our operational platforms, implemented independently under our own licences.

---

## 6. Sources

Gibbon's public material as read 2026-11-28: gibbonedu.org feature/module descriptions (via the official partner mirror at everonlearning.com — Gibbon Features and Gibbon Extend pages), Gibbon documentation FAQ (docs.gibbonedu.org), the GibbonEdu/core repository description, and module listings (core + add-ons). Our side: `PRESKOOL-FEATURE-CENSUS-2026-11-20.md`, `PRESKOOL-FEATURE-DISPOSITION-AND-REPLACEMENT-PLAN-2026-11-17.md`, `PRESKOOL-REAUDIT-2-2026-11-23.md`, `REKTRS-SCHOOL-ERP-GAP-AUDIT-2026-11-23.md` (all in this goal's files/). All Gibbon descriptions above are paraphrased in our own words; no Gibbon text or code is reproduced.
