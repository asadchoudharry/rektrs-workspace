# Decision Proposals D1 + D2 — Subjects and Exams

**For:** Assad (owner) · **Programme:** IQRS web system overhaul, Wave 4 seed data
**Status:** Ready to approve. Each proposal has ONE recommended choice, marked ✅. Approving means we build it on **staging first**, prove it, and only then — with your separate go-ahead — put it on production.

---

## Why these two decisions matter

Today the system knows **only 2 subjects** (Computer + Computer Practical) and **zero exams**. Because of that, whole parts of the school are switched off:

- Teachers cannot pick a subject when creating **homework** (the picker is empty — this already blocked the Workspace app's homework feature).
- There is **no timetable**, because a timetable is built from subjects.
- The **Exams & Results** screens in the web app and in IQRS Connect are empty — there is nothing to show.
- **Lesson plans, syllabus progress** and **report cards** all depend on subjects and exams existing first.

D1 fixes the subjects. D2 fixes the exam year. Together they switch on the academic half of the system.

### What your school actually looks like (from the live class data)

| Level | Classes | Sections |
|---|---|---|
| Montessori | Playgroup, KG 1, KG 2 | 10 + 6 + 7 |
| Primary | One, Two, Three, Four, Five | 6 + 7 + 6 + 6 + 6 |
| Middle | Six, Seven, Eight | 6 + 4 + 2 |
| Hifz stream | Hifz sections inside Four, Five, Six, Seven + the separate **Shoba Hifz** class | 11 sections in Shoba Hifz alone |

77 class-sections in total. The school runs Playgroup to Class Eight, plus a strong Hifz programme. There are no Class 9/10 (board) classes today — the exam proposal below respects that.

---

# D1 — Subject Catalogue

## The proposal

Create the full subject list below, once, and organise it into **subject groups**: one group per class (all sections of a class study the same subjects), with separate groups for the Hifz sections and for Shoba Hifz. That is **15 groups** covering all 77 sections.

### Montessori — Playgroup, KG 1, KG 2 (assessment-based, no written exams)

| Subject | Code |
|---|---|
| English | IQRS-ENG |
| Urdu | IQRS-URD |
| Mathematics | IQRS-MAT |
| General Knowledge | IQRS-GK |
| Islamiat | IQRS-ISL |
| Nazra-e-Quran | IQRS-NQ |
| Art & Craft | IQRS-ART |
| Rhymes & Activities | IQRS-ACT |
| Computer (KG 1–2 only) | IQRS-CS *(already exists)* |

### Primary — Classes One to Five

| Subject | Code | Notes |
|---|---|---|
| English | IQRS-ENG | |
| Urdu | IQRS-URD | |
| Mathematics | IQRS-MAT | |
| General Science | IQRS-SCI | Classes 4–5; Classes 1–3 take General Knowledge instead |
| General Knowledge | IQRS-GK | Classes 1–3 |
| Social Studies | IQRS-SST | Classes 4–5 |
| Islamiat | IQRS-ISL | |
| Nazra-e-Quran | IQRS-NQ | |
| Computer Science | IQRS-CS | *(already exists)* |
| Computer Practical | IQRS-CS01 | *(already exists)* |
| Art | IQRS-ART | |
| Physical Education | IQRS-PE | |

### Middle — Classes Six to Eight (Punjab board pattern)

| Subject | Code |
|---|---|
| English | IQRS-ENG |
| Urdu | IQRS-URD |
| Mathematics | IQRS-MAT |
| General Science | IQRS-SCI |
| Social Studies (History, Geography, Pakistan Studies) | IQRS-SST |
| Islamiat | IQRS-ISL |
| Arabic | IQRS-ARB |
| Computer Science | IQRS-CS |
| Computer Practical | IQRS-CS01 |
| Art | IQRS-ART |
| Physical Education | IQRS-PE |

### Hifz stream — Hifz sections of Four–Seven, and Shoba Hifz

The Hifz day has three parts, so it gets three subjects — this is how marks and progress stay honest instead of one blurred number:

| Subject | Code | What it covers |
|---|---|---|
| Hifz-e-Quran | IQRS-HFZ | New memorisation (sabaq) |
| Sabqi | IQRS-SBQ | Revision of the recent portion |
| Manzil | IQRS-MNZ | Revision of the completed portion |
| Tajweed | IQRS-TAJ | Correct recitation |
| English | IQRS-ENG | Core academics continue at a lighter load |
| Urdu | IQRS-URD | |
| Mathematics | IQRS-MAT | |
| Islamiat | IQRS-ISL | |

**Total: 21 subjects** (19 new + the 2 Computer subjects that already exist). Codes follow the same `IQRS-…` pattern the school already uses.

## ✅ Recommendation — D1

**Approve the catalogue exactly as above, and let us apply it as a prepared configuration pack — on staging first.**

The alternative is the office typing all of this into the admin panel by hand (Academics → Subjects, then Subject Groups, then assigning each group to each class-section). It is roughly a full day of careful clicking, and one wrong tick silently gives a class the wrong subjects. Our pack is reviewed SQL: it creates the subjects and groups in one pass, we verify it on staging (homework picker, a test timetable, a test exam), and the office's only remaining job is assigning **teachers** to subjects — a decision only the school can make anyway.

## Effort and effect

- **Our effort:** about half a day to build the pack and verify it on staging. Production application is a separate, later step and needs your separate approval at that time.
- **Office effort:** teacher assignment only (they know who teaches what; we cannot guess it).
- **Approving unlocks:** the homework subject picker (web + Workspace app), timetables, lesson plans, syllabus tracking — and it is the foundation D2 stands on.
- **Deferring costs:** every academic feature stays dark. Wave 4's data work and the apps' homework/exam features remain blocked no matter how much code is finished.

---

# D2 — Exam Structure for the Session

## What already exists

The system already has **8 exam groups** seeded — Monthly Test, Unit Test, First Term, Mid Term, Second Term, Final / Annual Examination, Send-Up / Pre-Board, Mock. They are empty shells: not one exam has ever been created in any of them. It also already has a **grading scale** seeded as a template. So D2 is not building from zero — it is deciding which of these to actually use, and on what calendar.

## The proposal

### Use 5 groups, leave 3 unused

| Exam group | Use it? | Purpose |
|---|---|---|
| Monthly Test | ✅ Yes | Short test every month, per subject |
| Unit Test | ✅ Yes | Teacher-level test at the end of a unit/chapter |
| First Term | ✅ Yes | Term examination |
| Mid Term | ✅ Yes | Term examination |
| Final / Annual Examination | ✅ Yes | The year's deciding examination |
| Second Term | Leave unused | We run a 3-term year (First / Mid / Final). A fourth term group only creates confusion in every dropdown. |
| Send-Up / Pre-Board | Leave unused | These exist for board classes (9/10). The school has none today. The day Class 9 opens, we switch this on — nothing is lost by waiting. |
| Mock / Practice | Leave unused | Same reason; can be switched on for Class Eight's final-term practice later if the school wants it. |

### The year's calendar (session 2025-26, as the system is configured)

| When | What |
|---|---|
| Every month (except exam months) | Monthly Tests |
| End of each unit | Unit Tests (teacher's choice of date) |
| March | **First Term** examination |
| July | **Mid Term** examination |
| November | **Final / Annual** examination + result and report cards |

*(This follows the session calendar already set in the system. If the office actually runs the year on different months, only the month names in this table move — the structure stays identical.)*

### Marks defaults

| Level | Term exams (per subject) | Monthly Tests | Unit Tests |
|---|---|---|---|
| Montessori | 50 — assessment-based, grades carry the meaning | — | — |
| Primary (1–5) | 50 (Computer Practical 25) | 25 | 10 |
| Middle (6–8) | 100 | 25 | 20 |
| Hifz subjects | Hifz-e-Quran 100 · Sabqi 50 · Manzil 50 · Tajweed 50 | 25 | — |

### Grades and passing

**Confirm the grading scale already seeded in the system** — it is the standard Punjab school scale:

| Grade | Marks % | | Grade | Marks % |
|---|---|---|---|---|
| A+ | 90–100 | | D | 50–59 |
| A | 80–89 | | E | 40–49 |
| B | 70–79 | | F | Below 40 (fail) |
| C | 60–69 | | | |

**Pass mark: 40%** in every subject — it lines up exactly with the F boundary above.

## ✅ Recommendation — D2

**Approve the 5-group structure, the March / July / November term calendar, the marks defaults, and the seeded grading scale with a 40% pass mark — as one package.**

## Effort and effect

- **Set once (by us, on staging first):** which groups are active, the grading scale confirmation, the marks defaults. After that, each term the office does only three things: create that term's exams from the defaults (a short, guided routine), set the date sheet, and enter marks. Monthly and unit tests are created by teachers as they go.
- **Approving unlocks:** results in the web app and in IQRS Connect (the Exams & Results screens are already built — they are simply empty today), positions/ranks, and **report cards** — the flagship document of the print programme (Wave 3 designs them; without D2 there is no result data to print).
- **Deferring costs:** results and report cards stay impossible for this session. A term that passes without its exams being created in the system cannot be reconstructed later — marks would have to be back-entered by hand.

---

## How approval flows from here

1. You approve D1 and/or D2 (they are independent — either can go first, but D2's exams need D1's subjects to exist).
2. We build the configuration pack(s) and apply them to **staging**.
3. We show you the proof on staging: homework with a real subject picker, one class's timetable, one term exam with sample marks and a printed report card.
4. Only then do we ask for production approval — separately, as always.

---

# Appendix — Technical mapping (Smart School 7.2)

## A. D1 mechanics

- **Subjects** live in `subjects` (`name`, `code`, `type` = theory/practical). The existing rows are Computer (`IQRS-CS`, theory) and Computer Practical (`IQRS-CS01`, practical) — the pack adds 19 rows and reuses both.
- **Subject groups** are the Smart School pattern: `subject_groups` → `subject_group_subjects` (subjects in the group) → `subject_group_class_sections` (which class-sections study that group). One group per class works because every section of a class shares the same subject set; the exceptions in this school are the Hifz sections (Four–Seven) and Shoba Hifz, which get their own groups — 15 groups total:
  - 12 class groups (Playgroup, KG 1, KG 2, One, Two, Three, Four, Five, Six, Seven, Eight — with the 1–3 / 4–5 subject split handled by class, so Primary is effectively 5 class groups with per-class subject sets) plus Hifz-sections group(s) for Four–Seven and 1 Shoba Hifz group.
- **Teacher assignment** (`teacher_subjects` / class-teacher assignment in the admin UI) is deliberately NOT in the pack — it is a school decision. Note from Wave 0 findings: this install's schema uses the `subject_group_*` family; the pack targets those tables only, verified against the staging export.
- **Office click-path if done manually instead:** Academics → Subjects → Add Subject (×19) → Academics → Subject Group → create each group, tick its subjects, tick its class-sections (×15). Estimated 5–6 hours with checking. The pack does the identical end state in minutes and is diff-verifiable against this document.
- **Class/section reference (from the staging export, 2026-11-07):** classes `Playgroup (10 sections)`, `KG 1 (6)`, `KG 2 (7)`, `One (6)`, `Two (7)`, `Three (6)`, `Four (6 — Hifz: King Boys, Queen Girls)`, `Five (6 — Hifz: Captain Boys)`, `Six (6 — Hifz: Heaven Boys, Smile Girls)`, `Seven (4 — Hifz: Diamond Boys, Imperial Girls)`, `Eight (2)`, `Shoba Hifz (11 — Baneen 1–7 and others)`. 77 class-sections total.

## B. D2 mechanics

- **Exam groups** live in `exam_groups` (all 8 already present, `exam_type = basic_system`, active). "Leaving a group unused" means simply never creating exams under it — no deletion, no schema change; it can be activated in any later session by creating the first exam.
- **Exams** are created per group per class/batch in `exam_group_class_batch_exams`, with the date sheet in the exam schedule and per-subject `max_marks` / `min_marks` (pass) taken from the defaults table in this proposal (pass = 40% of max, stored per subject at exam creation).
- **Grades** live in `grades` under `exam_type = school_grade_system`; the seeded rows (A+ 90–100 … F 0–39.99) match the scale in this proposal exactly, so "confirming" them is a no-op write — we verify and leave untouched.
- **Report cards** (print programme, Wave 3) read term results from these same tables; the Final term additionally produces the annual consolidated card. The Connect app's results screens read the vendor API's exam endpoints, which return data only once exams + marks exist.
- Session in scope: `sessions.id 21 = 2025-26` (the current production session).
