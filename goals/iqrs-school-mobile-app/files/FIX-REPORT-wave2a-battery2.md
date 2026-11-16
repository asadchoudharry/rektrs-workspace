# Wave 2A — Battery-2 Fix Report

**Scope:** classify all 6 FAILs from battery run 2 (`PASS=296 FAIL=6 SKIP=0`, log `/tmp/w2a-battery-2.log`) and fix the defects locally. No server was touched by this lane except curl probes against **staging** (fixture accounts 113/114/115); probe residue is listed at the end. All 24 run-1 FAILs stayed fixed — run 2's failures are exactly the first-exercise finds the round-1 report predicted.

**Headline:** three endpoint defects, zero battery defects in the failing checks themselves (two battery *strengthenings* added). One defect is a new member of round 1's Family B; one is a contract mismatch between the Wave 0 catalogue and a Wave 2A write endpoint; one is a permission rule that faithfully mirrored the school's RBAC data but contradicted how the plan forum is actually used.

---

## FAIL 1 — `syllabusStatus counts off` → **(a) ENDPOINT defect** (`lessonSave`, Staffsync)

**Evidence:** the battery's round trip (lessonSave → topicSave → syllabusTopicStatus, all status 1) was invisible to `syllabusStatus`. A live probe of `syllabusStatus(3,2)` after run 2 returned `topics_total=0, topics_covered=0` across all 11 subjects with **no lessons listed at all**, although the battery's lesson and covered topic exist on staging.

**Mechanism (contract mismatch, proven from the code of both sides):**

- `lessonSave` requires `subject_group_class_sections_id` to be a **`subject_group_class_sections` row id** (it validates existence by `id` and stores the value verbatim into `lesson.subject_group_class_sections_id`), and `syllabusStatus` traverses lessons by link-row id.
- The only id a client can obtain is from the Wave 0 `academicCatalog`, whose `subject_groups[].class_sections[]` entries expose **`class_section_id` = the `class_sections.id`** (the select is `subject_group_class_sections.class_section_id AS class_section_id` — the FK value, not the link row's `id`). Round 1's battery fix B2 made the battery pass exactly that value.
- For (class 3, section 2) the catalogue value is `3` — which is `class_sections.id` 3 (verified in the export) and *coincidentally* also an existing `subject_group_class_sections` row id (an unrelated early link row), so `lessonSave`'s existence check passed and the lesson was stored under the wrong link. `syllabusStatus`, traversing the real link rows for the class section, never reaches it. The counting code in `syllabusStatus` itself is internally consistent (subject sums and totals accumulate in the same loop) and is **unchanged**.

**Fix (Staffsync `lessonSave`, create branch only):** resolve the link row **inside the subject's own group** before inserting. An exact link-row `id` match wins; otherwise the link row whose `class_section_id` equals the supplied value is used — current session pinned first, then unpinned. The insert then stores the resolved row's real `id`. Unresolvable pairs keep the original refusal ("A valid subject and class section are required"). Side benefit: a genuine link-row id from a *different* group than the subject's is now refused instead of silently cross-linking a lesson. No other endpoint consumes a client-supplied link id (grep-verified: remaining `subject_group_class_sections_id` uses are read-side joins on the stored value).

**Family audit:** each candidate chain is built and executed in one uninterrupted sequence; `getSetting()` is resolved into a local before the loop (no Family A pattern). The `lesson` insert covers all its NOT NULL columns (schema-checked: session_id, both link ids, name) — no Family B exposure.

## FAIL 2 — `lessonPlanCommentSave` → **(a) ENDPOINT defect** (permission rule too strict for the forum's semantics)

**Evidence (the school's own RBAC data, from the staging export + live capabilities probe):**

- The endpoint gated on `staff_can(lesson_plan, lesson_plan_comments, add)`. Category 263 `lesson_plan_comments` exists (group 29 `lesson_plan`), but its **only** `roles_permissions` row is for **role 1 (Admin)**. The Teacher role (role 2) has **no row at all** for the category — while holding `manage_lesson_plan` view/add/edit, `manage_syllabus_status` view/edit, `lesson` and `topic` full actions.
- The live `capabilities` probe for teacher 114 confirms the consequence: its `lesson_plan` module lists exactly those four categories — no `lesson_plan_comments` key. Teacher 114 (who *created* the plan the battery comments on) is therefore refused deterministically; only Admin-role holders and superadmins could ever comment.
- Limited staff 115 (role 8) has an empty capability map — refused under any rule, as required.
- The comment thread is the plan's own collaboration forum: `lessonPlanDetail` reads the same `lesson_plan_forum` rows back as the plan's `comments[]`, and plan participation in this codebase is defined by `created_by` / `created_for` / office scope (the exact test `lessonPlanDetail` applies to non-admin readers). A teacher locked out of commenting on their own plan's thread is an endpoint rule defect, not a data defect: the category grant pattern (added to the install later than the 2020 lesson/topic grants, and granted to Admin only) never reached the teaching role.

**Fix (Staffsync `lessonPlanCommentSave`):** the plan row is fetched first (the "plan and message required" refusal is unchanged), then commenting is allowed when **either**:

1. the caller holds the explicit category grant — `staff_can(lesson_plan, lesson_plan_comments, add)` (Admin role, any role the school grants later, superadmin bypass); **or**
2. the caller can view lesson plans (`manage_lesson_plan/view`) **and** is a participant on this plan — `admin_scope`, or `created_by == caller`, or `created_for == caller` (mirroring `lessonPlanDetail`'s participation test).

Otherwise the original refusal message is returned verbatim. Teacher 114 commenting on his own plan passes branch 2; limited 115 (no permissions at all) fails both branches; a foreign teacher with view rights but no stake in the plan also fails both — branch 2 is per-plan, not per-role.

**Battery strengthening (the battery had no refusal check for comments):** after the teacher's successful comment, the battery now also asserts (i) `lessonPlanCommentSave` is **refused (status 0) for limited staff 115** on the same plan, and (ii) an **admin comment succeeds** (branch 1 path). Family audit: the `lesson_plan_forum` insert is unchanged and safe — `student_id` is nullable, `type`/`message` NOT NULL are both set (schema-checked).

## FAILs 3–5 — online-exam attach cluster → **(a) ENDPOINT defect** (`questionSave`, Staffapi); attach itself is *correct*

FAILs: `onlineExamQuestionSave attach (5 marks)` ("Exam or question not found"), `total_marks wrong`, `questions_count wrong` — the last two are **cascades** of the first.

**Evidence (live probes, staging):**

- `questionSave` with the battery's exact payload answered `status 1` but with **`record.id = 0` and every record field null** — the insert silently failed, `insert_id()` was 0, the re-read found nothing, and `w2_question_record` emitted a hollow record. The battery's `Q_ID` was therefore the string `"0"` (non-empty, so its guard passed), and `onlineExamQuestionSave` with `question_id = 0` skips the question lookup (`$question_id > 0` guard) and honestly reports "Exam or question not found".
- Isolation probes pin the culprit column: **with `level` + `class_id` supplied → real id (3)**; **with `level` only (no `class_id`) → id 0, insert failed** (one auto-increment value burned); **with `class_id` only (no `level`) → real id (5), `level` stored as `''`**.
- Schema: `questions.class_id` is `int NOT NULL` with **no default** — this is round 1's Family B in its omission form: the write dies when the column is left out (and, per the same mechanism, when it is passed as an explicit null). `questions.level` (`varchar NOT NULL`, no default) tolerates omission on this server and lands as `''`.
- The attach endpoint is **exonerated by direct proof**: attaching a real question (probe id 3) to a real exam returned `attached: true, questions_count: 1, total_marks: 5`, and `onlineExamDetail` then showed `questions_count=1, total_marks=5`. `onlineExamQuestionSave`'s lookups (exam in `onlineexam`, question in `questions` — the same table `questionSave` writes) were already the right tables and keys.

**Fix (Staffapi `questionSave`, create path + a normalisation both paths share):**

- On create, `level` defaults to `''` and `class_id` to `0` when absent — both are documented optional in the endpoint's contract, and these are the values the table itself lands on; `w2_question_record` reports `class_id` 0 as `null`, so the record stays honest (unfiled, not invented).
- A caller-supplied `class_id <= 0` (which the field loop turns into an explicit null) is normalised to `0` before either the create or the update write.
- **Hollow-save guard** (round 1's `contentUpload` pattern): if the insert still yields `id <= 0`, the endpoint now refuses with "The question could not be saved" instead of reporting success over a phantom row.

## FAIL 6 — `results shape wrong` → **mixed: cascade + (a) ENDPOINT defect** (`onlineExamResults`, Staffapi)

Two separate things were wrong with the run-2 results response:

1. **`total_marks` 0 for every student** — pure cascade of FAIL 3 (no question was attached, so the exam's total was genuinely 0). Fixed by the `questionSave` fix; no results-code change.
2. **`student_id` 0 for all 22 students** — independent endpoint defect. `onlineexam_students` **has no `student_id` column** (schema-verified: id, onlineexam_id, student_session_id, is_attempted, rank, quiz_attempted, timestamps). The method selected `onlineexam_students.*` plus display fields and then read `$row->student_id`, which is never in the result set — while the names/admission/class it printed prove the `student_session → students` join already resolves the real student. The run-2 battery did not assert `student_id` (only attempted/total), so this shipped silently inside a "shape" failure caused by the cascade.

**Fix (Staffapi `onlineExamResults`):** the select now carries `student_session.student_id AS student_id` from the join the method already makes. Response shape otherwise unchanged. **Battery strengthening:** the results assertion now also requires `student_id > 0` for every row, pinning the fix.

---

## Swap manifest (coordinator)

Baselines on staging are the round-1-fix builds; back them up before replacing (suggested names `Staffapi.php.bak-2026-11-07-wave2a-fix2`, `Staffsync.php.bak-2026-11-07-wave2a-fix2`).

| File | Before (staging now) | After (local master) | Change |
|---|---|---|---|
| `Staffapi.php` | 567,430 B · md5 `87c8ca3eedebc45ae632760be5dc93c5` | **569,232 B · md5 `c7b2d4edd92545588507f4a89e22e51c`** | 3 targeted edits, all inside Wave 2A-added methods: `questionSave` class_id null-normalisation; `questionSave` create-branch `level`/`class_id` defaults + hollow-save guard; `onlineExamResults` aliased `student_session.student_id` select. No Wave 0/1A code touched. |
| `Staffsync.php` | 140,958 B · md5 `453ba58cac2b4061d985dbcccc342b7e` | **144,076 B · md5 `aa087ca8fefd93f3df5af859e21130e0`** | 2 targeted edits, both inside Wave 2A-added methods: `lessonSave` link-row resolution (group-scoped, id-then-class_section, session-pinned first); `lessonPlanCommentSave` two-branch comment permission (explicit grant OR view + plan participation) with the plan fetched before the gate. No Wave 0/1A code touched. |
| `test-wave2a-api-staging.sh` | — (runs from local) | — | Two strengthenings, no failing check altered: comment refusal check for limited staff + admin-grant comment check (+2 checks); results assertion gains `student_id > 0`. `bash -n` clean; all three password defaults hash-verified after editing (admin `fee3c980…`, teacher `6bb92a81…`, limited `09a38424…` — all MATCH). |

Both PHP masters pass `php -l` under PHP 8.3.6. Every fix was audited against round 1's two families: no retained-builder or mid-chain helper patterns introduced (Family A), and every NOT NULL column on the touched insert paths is covered, defaulted, or normalised (Family B).

**Probe residue on staging (all clearly named, harmless):** online exam "W2A Probe Online" (id 3) with probe question 3 attached (marks 5); questions "W2A Probe: 2 + 2 = ?" (failed insert — no row), "W2A Probe2: 3 + 3 = ?" (id 3), "W2A Probe4: 5 + 5 = ?" (id 5, class_id 3). Battery run 2's own residue stands as designed, including its lesson stored under link id 3 (the FAIL-1 evidence; the re-run's new lesson will land under the resolved link row).

## Prediction for the re-run

- All **6 FAILs flip to PASS**: the new battery lesson resolves to the real (group 8, class-section 3) link row, so `syllabusStatus` counts its covered topic (covered ≥ 1, sums reconcile); the teacher's comment saves via the participation branch; the battery's question now persists with a real id, so attach returns `total_marks = 5`, detail shows `questions_count = 1`, and results show `total_marks = 5` **and** real `student_id`s.
- The **2 new battery checks pass**: limited comment refused (empty capability map fails both branches), admin comment saved (explicit-grant branch).
- Expected shape: **PASS = 304, FAIL = 0, SKIP = 0** (302 run-2 checks + 2 new), assuming staging fixture data is unchanged.
