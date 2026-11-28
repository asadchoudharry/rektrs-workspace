# FET Automatic Timetable Generation — Study (IQRS-special batch #2)

**Date:** 2026-11-28 · **Status:** STUDY-ONLY — nothing installed, no FET code read into our codebase, no code reuse. Facts below are from FET's official site/manual/forum (lalescu.ro) and the FET manual (timetabling.de), read 2026-11-28; our-side facts are from this goal's census, FC-18/FC-19 lane records, the Rektrs School ERP gap audit (2026-11-23) and the RosarioSIS study (2026-11-28), all in this goal's `files/`.

> **Licence note (read first):** FET is **GNU AGPL-3.0-or-later** (© Liviu Lalescu, Volker Dirr; latest release **FET-7.13.0, 24 Nov 2026**). The real source is the author's site (lalescu.ro/liviu/fet); GitHub carries only unofficial mirrors. This study quotes no FET code and reproduces no manual text beyond short factual element/option names. §6 states the AGPL question precisely; it is a shape-of-the-question analysis, **not legal advice**.

---

## 1. What FET is, in one paragraph

FET is a mature (since 2002), single-purpose automatic timetabling engine: you describe the institution (days, periods, teachers, student sets, subjects, rooms), the teaching that must happen (**activities**), and the rules it must respect (**constraints**, each weighted), and its heuristic algorithm searches for a complete placement — every activity assigned a day, a starting period and (where space constraints demand it) a room — that violates no 100%-weight rule and minimises weighted soft-rule conflicts. It ships as a Qt GUI plus a headless command-line twin, **fet-cl**, over the same engine, with a documented-by-construction XML data format (`.fet`). That combination — a real solver, a file-based interface, a CLI — is exactly why it is the engine candidate behind the RosarioSIS study's flagged automated scheduler (§5.3).

## 2. The constraint model, in depth

### 2.1 Core entities

- **Grid:** a list of days (names) × a list of hours (period start labels). Everything is placed on this grid; there is no notion of clock-time arithmetic inside FET — a "double period" is an activity of duration 2 occupying consecutive grid slots.
- **Teachers** (name; FET 7 limits are far beyond school scale — thousands of teachers/rooms, tens of thousands of activities).
- **Students structure:** a three-level hierarchy — **years → groups → subgroups** — with a student count per set. Years/groups may overlap; subgroups must not overlap (a subgroup is the atomic audience). An individual student can be modelled as their own set. This maps naturally onto our class → section structure (§4.1), and — importantly — onto *elective subgroups within a section* (e.g. a section split into Computer/Biology groups), which is precisely the matric subject-group case our schools place by hand today.
- **Subjects** and **activity tags** (free labels — lab, lecture, practical — that constraints can target).
- **Activities — the unit of work.** An activity couples **one or more teachers × one subject × one or more students sets** (either side may be empty, e.g. a staff meeting or a free study period), with a **Duration** (slots per meeting) and a **Total_Duration** (slots per week). When Total_Duration > Duration, FET treats it as a **split activity**: it creates subactivities (sharing an `Activity_Group_Id`, each with its own Id) that the solver places separately, and inter-subactivity rules (min days between, etc.) apply to the group. *Example: "Class 9-A, Mathematics, Teacher X, 6 periods/week in meetings of 1" is one activity, Total_Duration 6, Duration 1 → six placeable subactivities.*
- **Rooms and buildings:** rooms have a name, an optional building and an optional **capacity**. Buildings exist so constraints can tax movement between them.

### 2.2 Time constraints (the catalogue that matters to us)

Every constraint carries a **Weight_Percentage (0.0–100.0)** and an Active flag. Weight 100% = the solver must respect it or declare impossibility; below 100% = a preference the solver trades off and reports as soft conflicts. Two constraints are structural and always 100%: **ConstraintBasicCompulsoryTime** and **ConstraintBasicCompulsorySpace** (no teacher/set/room double-booked, ever — this is the solver's floor, not an option).

- **Availability:** teacher not available (named slots), students-set not available, **break** (all teachers + all students unavailable — how a lunch break is modelled: as grid slots nobody can be placed in).
- **Load shape, per teacher / per students set (and "all teachers" variants):** max/min **hours daily**, max **hours continuously**, max **days per week**, min days per week, **max gaps per day / per week** (idle slots between placed activities), max span per day, min resting hours, "working in an hourly interval at most N days per week", max hours daily *with a given activity tag* (e.g. at most 2 lab hours/day), students "begin early" limits (at most N days starting at the second period rather than the first).
- **Activity-set relations:** **min/max days between** a set of (sub)activities (the classic "spread Maths across the week, never twice on one day unless a double"), **min gaps (hours) between** activities, **same starting time / day / hour**, **not overlapping**, **two/three activities consecutive**, **ordered**, **grouped** (same slot), an activity **ends the students' day**, a set of activities **occupies at most N slots from a selected slot set**, max simultaneous activities from a set in selected slots.
- **Preferences:** an activity's **single preferred starting time**, a set of **preferred starting times**, or **preferred time slots** for a filtered set of activities (by teacher/subject/tag/students set). A preferred starting time with `Permanently_Locked=true` is also FET's **locking mechanism** — how a human pins part of a timetable and lets the solver work around it (semi-automatic mode), and how a saved solution is represented (§3.3).

### 2.3 Space constraints

- **Room not available** (named slots).
- **Capacity is enforced through the model, not a "capacity constraint":** a room with a capacity cannot host a students set larger than it (sets carry `Number_of_Students`). A room with no capacity set is unconstrained — which is why unspecified rooms appear when no space constraints bind an activity (§3.3's read-back caveat).
- **Preferred rooms**, four granularities: for a **subject**, for an **activity tag**, for **subject + tag**, and **individually per (sub)activity** — each a weighted list of acceptable rooms.
- **Home rooms** for a teacher or a students set (their default room).
- **Building-change taxes:** max building changes per day/week and min gaps between building changes, for teachers and for students sets.

### 2.4 Weights and priorities — how "importance" works

There is no priority queue or rule ranking beyond the weight itself. 100% rules are inviolable; everything softer is a single scalar field the solver minimises in aggregate (it reports the **number of broken soft constraints and the total weighted soft-conflict value** in its conflicts output). Practical consequence for a bridge: our UI should expose at most a three-step vocabulary (must / should / nice) mapped to 100 / ~95 / ~50, rather than pretending a percentage dial is meaningful to a school office.

### 2.5 Infeasibility — how failure is reported

- FET pre-validates the data and refuses malformed inputs with messages.
- During generation the solver places activities in a computed difficulty order. If it cannot complete, generation stops as **impossible**, naming the difficult/unplaced activities and the constraints around them; the GUI additionally saves the **partial timetable** and a **conflicts** file, and can list "impossible activities" with their blocking constraints. In **fet-cl**, the console output is terser — it reports the outcome, the initial placement order and the maximum placed count, from which the next (blocking) activity is identifiable; the richer partial-timetable/conflicts artefacts are a GUI behaviour that the author has directed source-level customisers to wire up themselves (a fact that matters for §6: *patching fet-cl is the moment we would be modifying AGPL code* — the stock binary needs no patch for our design, §3.2).
- Soft failures are not failures: a solved timetable can still carry broken <100% constraints, enumerated in the conflicts output with their weights. Any bridge must surface these, not hide them behind a green tick.

### 2.6 Algorithm expectations

FET's own homepage sets the expectation honestly: a complicated timetable usually solves in **5–20 minutes at most**; simpler ones in **under 5 minutes, sometimes seconds**; **extremely difficult ones can take hours**. The solver is a heuristic search, not a prover: it cannot certify that no solution exists — "impossible" means "not found within the search", which is why the operating pattern is *loosen a soft rule or add slack and re-run*, and why generation must be an asynchronous job with a time budget, never a request/response click. fet-cl supports this directly: `--timelimitseconds` bounds a run (allow a little beyond the limit for it to write results), and sending **SIGTERM/SIGBREAK** asks it to stop and **write the best timetable found so far**. FET can also generate **multiple timetables** for the same input (alternative solutions to choose between), and can strip redundant constraints from a file.

### 2.7 Exports

From a solved run: **HTML** timetables (the full styled family — years/groups/subgroups, teachers, rooms, subjects, activities, days-horizontal/vertical, time-horizontal/vertical, free-periods views), **XML** (the machine-readable placement file, §3.3, plus the statistics/conflicts XML options), **CSV** (activities and timetable CSVs, configurable quoting/separator), and a **data+timetable `.fet`** — the input file re-saved with every placed activity locked by preferred-starting-time/room constraints, which is both an archive of the solution and the input for a "keep these, redo the rest" regeneration.

## 3. The integration question — the .fet bridge

### 3.1 Could our system GENERATE a .fet file? Yes — the schema is plain, stable XML

A `.fet` file is a single XML document (root `<fet version="…">`) with flat, name-referenced sections — no IDs cross-referencing beyond activity Ids in constraints, everything else joins **by name string**. The sections a generator must emit:

| Section | Shape (element → key children) |
|---|---|
| Header | `Institution_Name`, `Comments` |
| `Days_List` | `Day` → `Name` (e.g. Monday…Saturday) |
| `Hours_List` | `Hour` → `Name` (the period start label, e.g. `08:00`) |
| `Subjects_List` | `Subject` → `Name`, `Comments` |
| `Activity_Tags_List` | `Activity_Tag` → `Name` |
| `Teachers_List` | `Teacher` → `Name`, `Comments` |
| `Students_List` | `Year` → `Name`, `Number_of_Students`, `Group` → `Name`, `Number_of_Students`, `Subgroup` → `Name`, `Number_of_Students` |
| `Activities_List` | `Activity` → one `Teacher` per teacher, `Subject`, optional `Activity_Tag`, one `Students` per set, `Duration`, `Total_Duration`, `Id`, `Activity_Group_Id`, `Active`, `Comments` |
| `Buildings_List` / `Rooms_List` | `Room` → `Name`, `Building`, `Capacity`, `Comments` |
| `Time_Constraints_List` | one element per constraint, e.g. `ConstraintTeacherNotAvailableTimes` (teacher + `Day`/`Hour` slot list), `ConstraintMinDaysBetweenActivities`, `ConstraintActivityPreferredStartingTime` (`Weight_Percentage`, `Activity_Id`, `Preferred_Day`, `Preferred_Hour`, `Permanently_Locked`, `Active`, `Comments`), `ConstraintBreakTimes`, `ConstraintTeacherMaxHoursDaily`, … |
| `Space_Constraints_List` | e.g. `ConstraintSubjectPreferredRooms` (subject + `Preferred_Room` list), `ConstraintActivityPreferredRooms`, `ConstraintRoomNotAvailableTimes`, … |

Two generator obligations follow from the format: **(a) name discipline** — because joins are by name, the bridge must mint stable, unique, collision-free names (e.g. section sets as `Class 9::A`, teachers by a governed short code) and keep a name↔row map for read-back; **(b) activity synthesis** — FET consumes *demand* (who teaches what to whom, how many slots/week, in what meeting lengths), which is a planning artefact, not a placement (see §4.1 for what we do and don't store today).

### 3.2 fet-cl headless: invocation, outputs, exit behaviour

```
fet-cl --inputfile=<file.fet> [--outputdir=<dir>] [--timelimitseconds=<n>]
       [--htmllevel=<0..7>] [--language=<code>]
       [--writetimetablexml=true] [--writetimetablesstatistics=true]
       [--writetimetableconflicts=true] [--exportcsv=true] [view toggles…]
```

- **Inputs:** the `.fet` file only. No stdin protocol, no daemon mode — one process per generation job. That is operationally ideal for us: a job = write file → spawn → wait (with timeout) → read outputs → discard sandbox directory.
- **Outputs:** written under the output directory in a `timetables/<basename>-single/` folder: the HTML family, the placement XML (§3.3), statistics/conflicts files as toggled, and the run's messages on stdout.
- **Exit behaviour — the honest caveat:** fet-cl does not offer a documented machine contract of exit codes per outcome class. The reliable success test is **artefact-based**: the placement XML exists and parses, and stdout carries the success/impossible/time-exceeded markers. A bridge must classify outcomes from (stdout text + artefacts present), treat "time exceeded with a written best-so-far timetable" (the SIGTERM path) as a distinct *partial* outcome, and never equate process exit 0 with a good timetable. None of this needs a fet-cl patch; it is ordinary supervisor code on our side.
- **Runtime envelope:** minutes-scale (§2.6) → background job with progress = stdout tail, a per-school time budget, and one fet-cl process per tenant job (the binary is a self-contained Qt console program; on our Linux hosts it runs without a display).

### 3.3 Reading results back into our tables

The placement file **`<basename>_activities.xml`** is the read-back artefact: root `Activities_Timetable`, one `Activity` per placed subactivity carrying **`Id`, `Day`, `Hour`, `Room`** (Day/Hour as the grid names we ourselves emitted; Room possibly **empty** for activities no space constraint bound — the bridge must decide per activity whether "no room" means "keep the section's current room" or is an error, and say so in the run report). Read-back procedure:

1. Parse placements; join `Id` → our activity map (§3.1a) → (class-section, subject, teacher, meeting length).
2. Translate (Day, Hour-name) → our grid's start/end TIME values for that day.
3. **Validate before writing:** re-run FC-19's deterministic conflict rule over the candidate set (teacher/section/room overlap) — FET output should pass by construction, and the check is the belt-and-braces proof that the name map didn't corrupt anything.
4. Write into `subject_timetable` **through the editor's own save semantics** (per class-section/day replacement, as `timetable_save` does today), as a **new draft the office reviews and applies**, never as a silent overwrite of the live record — and keep the run's `.fet` + placement XML + conflicts report as the run's evidence pack.
5. Substitutes (FC-19's `pk_timetable_substitutes`) sit **on top of** whatever timetable is live and are untouched by generation; a regenerated base simply becomes the new substrate for the same substitute workflow.

### 3.4 What our current data can and cannot express

| FET needs | In IQRS today? | Source / gap |
|---|---|---|
| Days × periods grid | **Partial** | `subject_timetable` stores per-row `start_time`/`end_time` TIME values; the slot-marker table (`class_section_times`) is **empty (0 rows)** — there is no governed canonical period grid. Bridge v1 derives the grid from the distinct governed timings; a small governed grid config is the clean fix. |
| Teachers | ✅ | `staff` (115 on staging). Needs a stable short-name minting rule. |
| Student sets (year/group/subgroup) | ✅ (2 of 3 levels) | classes + sections map to Year/Group directly. **Subgroups (elective splits inside a section) are not a governed construct** — matric Computer/Biology splits would be modelled as FET subgroups synthesised from subject-group enrolments; the enrolment data exists in subject-group structures but is not shaped as "sets" today. |
| Subjects | ✅ | subjects + subject groups (`subject_group_subjects` — the editor's own unit). |
| Activities (demand: teacher × subject × set × slots/week × meeting length) | **Partial — the real gap** | The system stores **placements**, not demand. Demand is recoverable by decomposing the current timetable (count placed slots per teacher/subject/set) — good enough to *regenerate an equivalent or improved* timetable — but a forward plan ("next session: 9-A takes 6 Maths, in 2 doubles + 2 singles") has **no governed store**. Bridge v1 = decompose-and-adjust; a planning surface is a later, deliberate addition. |
| Rooms, capacity, features | **Partial** | FC-18 built `pk_classrooms` with **capacity + facilities** — the right shape — but the table **ships empty** and rooms enter it only by adoption; the live timetable's rooms are still free `room_no` strings (R-1, R-2, Lab…). Capacity/feature binding works exactly as far as room adoption has gone. |
| Subject → preferred room (e.g. Science → Lab) | ❌ not stored | No subject-room binding table. Historical placements imply it (Lab usage) but nothing governed. Small new store, or bridge emits it from a per-run office selection. |
| Teacher unavailability (recurring weekly) | ❌ **not stored anywhere** | The leave register (`staff_leave_request`) is *dated absence*, not a weekly pattern ("not Fridays after 12"). FET's not-available constraints would start empty; a small governed store is needed for this to be real. (Part-time teachers are exactly the case that needs it.) |
| Teacher load limits (max periods/day/week) | ❌ not stored | FC-19 computes workload as a **read** (periods/minutes/days per teacher); no limits table exists. FET defaults (none) apply until a limits store exists. |
| Breaks | **Partial** | Breaks are implicit in the timing gaps of placed rows. Once a grid exists, break slots are a grid property the bridge can emit as `ConstraintBreakTimes`. |
| Existing placements to preserve (locking) | ✅ derivable | Any subset of the current timetable can be emitted as locked preferred-starting-time activities (§2.2) — the "keep the board exams week fixed, regenerate the rest" pattern is expressible from day one. |

**Net:** a bridge can generate a *faithful* .fet from today's data for the core problem (sets, teachers, subjects, demand-by-decomposition, rooms as names), and every missing constraint family is a **small, named data store** — not a research problem. But the honest v1 claim is "regenerate/optimise from the current shape", not "plan next session from scratch": the demand-planning surface and the unavailability/limits stores are the difference.

## 4. Mapping against our systems

### 4.1 (a) IQRS Smart School timetable — manual today, conflict-checked since FC-19

Today's state (census + FC-19 record): the board is **hand-built** in the academics editor over `subject_timetable` (127 rows on staging, session 21, Mon–Sat); FC-19 added the honest deterministic layer the vendor's "AI timetable optimizer" page only performed — a printed **conflict rule** (same day + overlapping times ⇒ teacher/section/room pair), a live register that reports the seeded record's **231 conflict pairs** faithfully, teacher workload as governed counts, and **substitutes** as governed per-date records over approved leave. What FC-19 deliberately is *not*: a placer. Nothing in our system proposes *where a period should go*.

FET slots into exactly that hole, without disturbing what exists:

- **Generate (new):** office picks a scope (whole school / a wing / one class group) → bridge emits `.fet` from governed data (§3.1, §3.4) → fet-cl job → candidate placements + conflicts report.
- **Review (existing surfaces):** candidate rendered on the existing timetable board; FC-19's conflict register re-validates it (§3.3 step 3); soft-constraint breaks are shown as a list, in the same "report faithfully, never massage" register FC-19 established.
- **Apply (existing door):** accepted candidate written through the editor's save path; the previous record is the rollback (the lane discipline of exports-before-writes already governs timetable work — the teardown invariant `subject_timetable` md5 `dcbcfed3…` is the standing proof pattern).
- **Run the school (existing):** substitutes, leave, workload reads continue unchanged on the new base.

The composition is conservative by design: **FET proposes, our governed surfaces dispose.** The vendor-anatomy "optimizer" surface (FP-133's honest core, which FC-19 scoped as detection + workload) gains its missing third element — actual placement — without a single fabricated score.

### 4.2 (b) Rektrs School ERP (Laravel 13 SaaS)

The gap audit (2026-11-23) scores Academics **source-complete**: academic structure, timetable **entries** (a ~10 KB entries module) and a substitution workflow exist in source; there is **no scheduler and no requests layer** (the RosarioSIS study's row 1 marks the ERP LACK, same as IQRS). The bridge concept ports unchanged — the ERP's timetable model is entries-shaped like Smart School's — with three SaaS-specific deltas:

1. **Multi-tenancy mechanics:** one isolated job directory + fet-cl process per tenant run; minutes-scale runtimes make a queue with per-tenant time budgets and concurrency caps a requirement, not a refinement.
2. **Data-model gaps are the same list as §3.4** (no demand store, no unavailability store, no load limits) — in the ERP these should be designed **once, tenant-shaped**, rather than retrofitted per school.
3. **The licence question is sharper for SaaS** (§6): a paid multi-tenant service invoking an AGPL engine per tenant is the fact pattern that most needs the legal answer *before* the feature is sold, whereas IQRS's single-school, self-operated use is the mildest pattern there is.

### 4.3 (c) Composition with the RosarioSIS scheduler flag

The RosarioSIS study flagged **two different problems that are easy to conflate**:

- **RosarioSIS's scheduler** answers *"which students sit in which course period?"* — course **requests** in, placements into **already-existing** course periods out, with a test-mode clash check at request-save time and incomplete-schedule hunting.
- **FET** answers *"when and where does each course period meet?"* — it creates the period structure itself from demand + constraints.

They **compose as layers, not competitors**: a requests layer (the RosarioSIS idea, still unbuilt in both our systems) decides *who takes what*; FET decides *when/where it meets*; the resulting board feeds the same portals, attendance and substitute machinery. It is also the proven composition in the wild: RosarioSIS itself ships a FET-timetable **import** add-on — i.e. its ecosystem already treats FET as the external engine and the SIS as the system of record, which is precisely the architecture §3 proposes for us. Sequencing consequence: **FET first** (it removes the timetable-construction labour, the larger and more universal pain — every school builds a board every session, only some run request-based placement), requests later and only where a school actually runs elective choice at scale.

## 5. What FET does not do (scope honesty)

- It does not do **daily cover**: substitutes for today's absence remain FC-19's per-date governed workflow (FET could regenerate a whole board around a long absence, but that is not a cover tool and should not be sold as one).
- It does not collect **course requests** or place individual students (§4.3).
- It does not know our **semantics** it isn't told: board-exam weeks, Friday shortened days, Ramadan timings — all expressible (grid + breaks + not-available + locking), all requiring the office to *say* them in the constraint stores.
- Its solver gives **no optimality certificate** and no proof of impossibility (§2.5–2.6); "FET couldn't" always means "loosen something and re-run", and the product copy must say so.

## 6. The AGPL-3.0 question, stated precisely

FET is AGPL-3.0-or-later. This section states the *shape* of the question for a commercial SaaS calling fet-cl headless. It is not a legal conclusion; the owner should take the four numbered questions to counsel before the SaaS sells this feature. (Context that lowers the temperature: the owner's standing position on PreSkool — a commercial enterprise agreement with complete rights — does **not** extend to FET; FET has no equivalent commercial licence on public offer. The author accepts donations/sponsorship and has historically offered custom builds, which is a relationship route, not a licence route.)

**The architecture in question:** our proprietary system (i) writes a `.fet` data file, (ii) executes the **unmodified** fet-cl binary as a separate OS process, (iii) reads back output data files. No FET code is copied, linked, or called as a library; no FET code is modified.

1. **Mere aggregation / independent program?** The mainstream reading of GPL-family licences is that two programs communicating at arm's length — files and process boundaries, no shared internal structures — are separate works, and the copyleft of one does not reach the other (the same pattern as a proprietary IDE invoking GCC). Our bridge code, the `.fet` generator and the result parser are then simply our code, and the generated timetables are **data/output**, which no GPL-family licence claims. *This is the load-bearing question; everything else is secondary to it.*
2. **AGPL §13 (network interaction) — who is "interacting with" FET?** §13 obliges an operator of a *modified* AGPL program to offer its source to users interacting with it remotely. With an **unmodified** binary there is no §13 modification trigger; and in our design end users interact with **our** UI — FET has no network interface and no user ever addresses it. The question for counsel is whether a court could treat the combined service as the user "interacting with" FET through our intermediary — the deliberate design fact (engine is a batch file-in/file-out step, invisible and unaddressable) is the strongest available answer, and it is a *design* fact we control: **keep FET unmodified, unexposed, and never patch it** (cf. §2.5 — the one place a patch tempts, richer fet-cl failure artefacts, is exactly what to refuse; supervisor-side classification solves it instead).
3. **Distribution.** If fet-cl ever ships **inside** a distributed artefact — e.g. bundled into the IQRS desktop app or an on-prem tenant install — that *is* conveying AGPL software: source (or a valid written offer) for the exact FET version must accompany it, with licence notices intact. Manageable and routine, but it must be a deliberate, documented act, not an accident of packaging. Hosted-only invocation conveys nothing.
4. **Modification creep.** Any future "small patch" to FET (custom output, custom constraint) converts us into distributors/operators of a modified AGPL work with §13 source-offer duties toward anyone interacting with the modified program. The rule for every future lane: **FET is a pinned, checksum-verified, unmodified upstream binary, or the lane stops and the licence question reopens.**

**Residual risk statement:** questions 1–2 have a well-trodden mainstream answer in our favour for the hosted, unmodified, process-isolated shape; they have not, to this study's knowledge, been litigated on these exact facts anywhere. IQRS's pattern (single school, self-hosted, no distribution, no modification) sits at the lowest-risk end even under cautious readings. The SaaS pattern is the same architecture with paying third parties on the other side of it — same engineering, higher consequence if the mainstream reading were ever displaced — hence different verdicts below despite identical technology.

## 7. Verdicts

### 7.1 IQRS (Smart School overhaul) — **GO** (pilot-shaped)

Build the bridge as an **advisory generator** behind the existing editor: generate → FC-19-validated review → office applies through the existing save door. Rationale: the constraint core is fully expressible from today's governed data (§3.4); the missing stores are small and named; the use pattern is the lowest-risk AGPL shape (§6); and it completes the FP-133 honest core (detection + workload + **placement**) that FC-19 deliberately left open. Pilot scope: one class-group wing, demand by decomposition, locked board-critical periods, rooms as names (capacity binding only after room adoption is pushed through for the pilot wing).

**Effort — the .fet bridge (IQRS v1):**

| Block | Estimate |
|---|---|
| `.fet` exporter (grid derivation, name minting + map, entities, decomposed demand, base constraints: breaks, basic load caps from a small new limits store) | ~1.5 weeks |
| Job runner (sandbox dirs, fet-cl invocation, timeout/SIGTERM handling, outcome classification from stdout+artefacts) + placement-XML parser + FC-19 re-validation | ~1 week |
| Review/apply surface (candidate board, soft-conflict list, apply-through-editor, run evidence pack) | ~1 week |
| Constraint data stores v1 (teacher weekly unavailability; subject→preferred-room) + room-adoption push for pilot scope | ~0.5–1 week |
| Proof + UAT on staging (equivalence run vs the current board, an impossible-input run, a locked-partial regeneration) | ~0.5 week |
| **Total** | **≈ 4–5 weeks of lane work** |

### 7.2 Rektrs School ERP (SaaS) — **WATCHLIST** (path to GO named)

Same bridge, deliberately **after** three gates: **(1)** counsel's answers to §6 questions 1–2 for the paid multi-tenant pattern (the only genuinely external dependency in this study); **(2)** the IQRS pilot proving the bridge against a real school's board (the ERP then inherits a tested exporter/parser pair and a known constraint-store design, re-implemented tenant-shaped in Laravel — budget **≈ +2–3 weeks** beyond the pilot, mostly multi-tenant job plumbing and the ERP-side stores); **(3)** the ERP's own acceptance programme reaching academics (its gap-audit state is source-complete/acceptance-pending — a scheduler should not leapfrog its UAT queue). Until gates 1–2 fall, the ERP keeps the flag as a designed-for feature: the constraint stores (§3.4) should be modelled **FET-shaped from the start** (weighted must/should/nice, named slots, set hierarchy with subgroups) so the bridge, when it lands, is a translation, not a retrofit.

### 7.3 NO-GO items (any system)

- Patching or forking fet-cl, or linking FET code — reopens §6 in its hardest form for zero needed benefit.
- Bundling fet-cl into the desktop app or any distributed installer before the §6.3 distribution mechanics are deliberately implemented.
- Auto-applying generated timetables without office review — a governance NO-GO regardless of licence: the solver's soft-conflict list is part of the answer.

## 8. Sources

**FET (read 2026-11-28):** official homepage lalescu.ro/liviu/fet (version, licence, solve-time expectations); FET Manual, timetabling.de/manual/FET-manual.en.html (constraint catalogue, weights, definitions); fet-cl man page (Debian) and the FET README's command-line section (options, SIGTERM behaviour, CSV toggles); author's forum answers on fet-cl output/partial results and on the `.fet` XML constraint shape (lalescu.ro/liviu/fet/forum); FET FAQ (lalescu.ro/liviu/fet/doc/en/faq.html — activities model, `_activities.xml` read-back, unspecified-room behaviour).
**Ours:** `PRESKOOL-FEATURE-CENSUS-2026-11-20.md` (FC-19 card, FP-133), FC-18 lane record (`pk_classrooms` shape), FC-19 lane record (`subject_timetable` shape, conflict rule, substitutes, teardown invariant), `REKTRS-SCHOOL-ERP-GAP-AUDIT-2026-11-23.md` (Academics row), `ROSARIOSIS-FEATURE-STUDY-2026-11-28.md` (§scheduler flag + FET import add-on). All FET descriptions are paraphrased in our own words; no FET text or code is reproduced beyond short factual element/option names.
