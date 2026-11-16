# Wave 2A — Battery-1 Fix Report

**Scope:** classify all 24 FAILs (+1 SKIP) from battery run 1 (`PASS=253 FAIL=24 SKIP=1`) and fix the defects locally. No server was touched by this lane except read-only/probe curl calls against **staging** (fixture accounts 113/114/115); all probe shares were deleted afterwards and the one probe inventory issue was returned.

**Headline:** **Zero FAILs were transient.** Every cluster has a deterministic mechanism, proven by file bytes, schema, or live probes. Two defect families explain almost everything:

- **Family A — CI3 shared query-builder corruption.** In CodeIgniter 3, `$this->db` is a *single* query-builder object. Any `get()` executed while a chain is being built (a retained `$q`, or a helper evaluated as a chain argument) *runs the accumulated state and resets it*; the outer chain then compiles with no `FROM`, the query errors, and — because the staging API runs with `db_debug` off (the Wave 1 `prodcution`-typo fix made `ENVIRONMENT='production'` effective) — `get()` returns `false` and `->result()` / `->row()` on `false` is a PHP fatal: **HTTP 500, empty body**.
- **Family B — explicit `null` into NOT NULL columns.** On this MariaDB, an insert that *omits* a NOT NULL column succeeds (implicit default), but an insert that passes an explicit `null` for a NOT NULL column without a default **fails silently** (`db_debug` off): the endpoint reports success, `insert_id()` is 0, nothing persists. Proven live (see Cluster 7).

---

## Cluster 1 — Logins (10 FAILs) → **(b) BATTERY defect**

FAILs: `login teacher 114`, `login limited 115`, `examMarksRoster (teacher 114)`, `teacher reading another staff member's attendance refused`, `teacher reading OWN attendance…`, `questionSave (teacher)`, `questionBankList (teacher sees own)`, `limited staff: examCatalog/feeSetup/examMarksSave refused` (all downstream calls carried empty tokens → 401).

**Evidence (conclusive, not inference):** the battery script's on-disk defaults for `TEACHER_PASSWORD` and `LIMITED_PASSWORD` were the literal 10-character string `<redacted>` — extracted byte-exact and hash-matched (`md5('<redacted>') = ee1f0218…` = the extracted defaults, identical for both). `ADMIN_PASSWORD` in the same file is correct (hash matches), which is exactly why admin passed and the other two failed deterministically. The coordinator's manual curl logins used the real passwords and succeeded — there was **no staging stall** involved; the transient hypothesis is refuted. The placeholder almost certainly entered the file when the 2A battery was authored by copying the Wave 1A script through a redacting view (the 1A file's on-disk bytes are correct; only its *rendered* form shows `<redacted>`).

**Fix (battery B1):** restored both defaults to the real fixture passwords and verified by hash (teacher `6bb92a81…`, limited `09a38424…` — matching the known fixture values). ⚠️ **Warning for future editors:** writing this file through a redacting editor silently re-replaces those two values with `<redacted>` (it happened on this lane's first edit attempt and was caught only by the hash check). Verify the two hashes after any edit of the battery.

## Cluster 2 — examStudentsAssign (4 FAILs) → **(a) ENDPOINT defect**

FAILs: `examStudentsAssign Four-Daffodils` ("No students given…"), `assign created 0 exam students`, `roster has fewer than 2 students — marks checks skipped`, `rank generated for 0 students`.

**Evidence:** the endpoint's class/section branch filtered `student_session.is_active = 'yes'`. In the staging export, **all 1,681 session-21 `student_session` rows have `is_active='no'`** — including the 22 students of class 3 / section 2 (counted directly from `u238632175_test123-2026-11-07.sql`). The Wave 0/1A house rule (e.g. the class-count query in pre-2A Staffapi) is `student_session` by session/class/section **joined to `students.is_active='yes'`**; `student_session.is_active` is never the enrolment flag. The endpoint's own error message documented `class_id + section_id` correctly — the query behind it could never match.

**Fix (Staffapi):** both places that select a class roster by class/section — `examStudentsAssign` **and `onlineExamAssignSave`** (same defect, unexercised in run 1 because the whole online-exam block was skipped) — now join `students` and filter `students.is_active='yes'`, qualified columns throughout.

## Cluster 3 — fileOpen marksheet (1 FAIL) → **cascade of Cluster 2** (endpoint behaviour correct)

**Evidence:** with the roster empty, the battery's `FIRST_ES` was empty, so its request body was malformed JSON (`"exam_student_id":}`); `json_body()` decoded nothing, `kind` arrived as `""`, and the endpoint honestly answered `file:null` + "Unknown document kind." `fileOpen` does handle `kind:"marksheet"` (the branch exists and is gated on `exam_result/view`). No endpoint change.

**Fix (battery B3):** the marksheet check is now guarded — with no roster student it reports a SKIP instead of manufacturing a misleading FAIL.

## Cluster 4 — contentList (2 FAILs) → **(a) ENDPOINT defect ×2 (Family A + Family B)**

FAILs: `contentList finds the share` (empty body), `share missing from contentList`.

**Evidence (live probes, staging):** `contentList` returned **HTTP 500 / size 0 whenever `share_contents` contained ≥1 row**, and 200 when empty — even for `{"page":2}` (record loop never runs) and for filters matching zero rows. Root cause is Family A: the method built `$q = $this->db->from('share_contents')`, added filters, and *then* called `is_admin_scope($staff)` — whose `staff_role_names()` runs its own `get()` on the same shared builder. That inner `get()` executes the merged builder state and resets it; the final `$q->order_by(...)->get()` compiles with no `FROM`, errors, returns `false`, and `->result()` on `false` fatals. (With an *empty* table the inner cross-join returns no roles, the method detours through the non-admin early-return, and the answer merely *looks* like a correct empty list.) The non-admin branch had the same disease internally (its visibility `get()`s ran while `$q` was retained).

**Second defect in the same cluster (Family B):** `contentUpload` inserted `upload_contents.content_type_id = null` when the caller sent none — the column is `NOT NULL` with no default, so the material insert failed silently and every share was **hollow** (upload responses showed `"contents":[]`; a probe upload *with* `content_type_id=3` produced a real content row, id 1, file stored). The battery did not detect this because it only checked the share id.

**Fixes (Staffapi):**
- `contentList` restructured: scope + visibility id-list are computed **first** (all queries completed), then the `share_contents` chain is built and executed in one uninterrupted sequence. Response shape unchanged.
- `contentUpload` resolves a real content type before inserting: the caller's valid `content_type_id`, else the first configured type (the choice is visible in the returned record), else a clean refusal when the install has no content types. Added a guard: if the material insert yields no id, the endpoint refuses ("The content could not be saved") instead of reporting a hollow share.

## Cluster 5 — routePickupPointSave (1 FAIL) → **(a) ENDPOINT defect (Family A)**

FAIL: `routePickupPointSave (fee 800)` — empty body.

**Evidence (live probes):** bogus ids → clean `status 0` JSON; valid route+point ids → **HTTP 500 / size 0**, for every parameter variant. Root cause: the duplicate-check chain evaluated `$this->w2_session_id($params)` *as an argument mid-chain* — `w2_session_id()` reads `setting_model->getSetting()`, which builds and executes a full query on the same shared builder, corrupting the half-built dupe chain; its `get()` then returns `false` and `->row()` fatals. This was the **only** mid-chain helper call in either file (verified by grep).

**Fix (Staffapi):** `$session_id` is resolved into a local before the dupe chain is built and reused for the insert.

## Cluster 6 — transportAssign (2 FAILs) → **cascade of Cluster 5** (endpoint rule correct; not a battery fault)

FAILs: `transportAssign` ("client_txn_id required"), `assignment not visible`.

**Evidence:** the battery **did** send `client_txn_id` (script line verified). But `RPP_ID` was empty (Cluster 5's 500), making the request body malformed JSON (`"route_pickup_point_id":}`), so the server decoded *no* parameters — hence "client_txn_id required". Requiring `client_txn_id` is correct Phase B behaviour and is unchanged.

**Fix (battery B4):** the transport block now also requires a non-empty `RPP_ID`, otherwise it SKIPs with an explanatory note instead of emitting misleading FAILs.

## Cluster 7 — Inventory (4 FAILs) → **(a) ENDPOINT defect ×2 (Family B)**

FAILs: `available after stock wrong`, `available_after wrong`, `inventoryReturn` ("Issue not found"), `available after return wrong`.

**Evidence (live probes):** the totals *logic* is correct (vendor semantics: total = `item.quantity` + signed `item_stock` movements; outstanding = `item_issue` with `is_returned=1`). The writes never landed:
- `itemStockSave` passed `purchase_price: null` and `description: null` — both `item_stock` columns are NOT NULL without defaults → insert failed silently; `itemStockList` stayed empty and totals never moved.
- `inventoryIssue` (Staffsync) passed `note: null` — `item_issue.note` is NOT NULL without a default → insert failed; response carried `id: 0` and an in-memory `available_after` for a row that does not exist; the return then correctly reported "Issue not found".
- Proof by contrast: `itemStockSave` **with** `purchase_price`+`description` → total 5 → **15**, row listed; `inventoryIssue` **with** a note → real `id: 1`, `available_after: 12`; without → `id: 0`, nothing persisted. `itemSave` succeeds precisely because it *omits* its NOT NULL fields rather than nulling them.

**Fixes:** `itemStockSave` defaults `purchase_price` to `0.0` and `description` to `''` when absent; `inventoryIssue` defaults `note` to `''`. (Other 2A inserts were audited for the same pattern: exam/fee/HR/lesson/topic/marks inserts either cover their NOT NULL columns or omit them; `exam_group_exam_results.note`/`exam_group_student_id` are nullable.)

## The SKIP — lesson/syllabus section → **(b) BATTERY defect**

**Evidence:** the battery's catalogue walk searched for a key named `subject_group_class_sections_id`; the Wave 0 `academicCatalog` actually exposes the link as **`class_section_id`** inside each subject group's `class_sections[]` (with `class_id`/`section_id` alongside) — verified live. `GCS_ID` was therefore always empty and the section always skipped.

**Fix (battery B2):** extraction now walks `subject_groups[]`, takes a subject link and the (class 3, section 2) `class_section_id` **from the same group**, falling back to the previous skip behaviour if none matches.

---

## Additional latent defects found and fixed (not in the 24 — same families, would have failed next)

The Family A audit swept every retained-builder and mid-chain pattern in the 2A code. Three more instances of the contentList disease were found in endpoints the battery never honestly exercised in run 1:

1. **`lessonPlanList`** — retained `$q` across `is_admin_scope()` → broken for *all* callers (the battery's lesson section was skipped, so this never surfaced). Fixed by hoisting the scope check before the chain.
2. **`questionBankList`** — same pattern, same fix. (Run 1 only reached it with a dead token.)
3. **`examCatalog` with `class_id`/`section_id`** — the main exams chain was started, then the enrolment subquery's `get()` executed/reset it, leaving the final `get()` without a `FROM`. Run 1 called it with `{}` only. Fixed by resolving the filter ids *before* the main chain.

Verified clean after the sweep: `libraryCatalog`, `itemCatalog`, `itemStockList`, `itemIssueList`, `staffPayroll`, `reportRun` engines (chains executed uninterrupted; per-row helper calls happen after `get()`), `lessonPlanDetail`, `contentDelete`, `questionSave` (scope checks after completed fetches), and all of Staffsync (no retained builders; its one `getSetting()` mid-expression use is in standalone assignments, which are safe).

## Swap manifest (coordinator)

Baselines on staging are the run-1 builds; back them up before replacing (suggested names `Staffapi.php.bak-2026-11-07-wave2a-fix`, `Staffsync.php.bak-2026-11-07-wave2a-fix`).

| File | Before (staging now) | After (local master) | Change |
|---|---|---|---|
| `Staffapi.php` | 563,365 B · md5 `78956f1474b13688b122eacae2eb8182` | **567,430 B · md5 `87c8ca3eedebc45ae632760be5dc93c5`** | 9 targeted edits: examStudentsAssign roster rule; onlineExamAssignSave roster rule; contentList restructure; lessonPlanList + questionBankList scope hoists; examCatalog filter precompute; routePickupPointSave session hoist; contentUpload content-type resolution (×2 branches) + hollow-share guard; itemStockSave NOT NULL defaults. All inside Wave 2A-added methods; no Wave 0/1A code touched. |
| `Staffsync.php` | 140,772 B · md5 `e276a536be5ce82dbd8f896717dd8820` | **140,958 B · md5 `453ba58cac2b4061d985dbcccc342b7e`** | 1 edit: inventoryIssue `note` default `''`. |
| `test-wave2a-api-staging.sh` | — (runs from local) | — | B1 password defaults restored (hash-verified); B2 catalogue extraction (`class_section_id`, same-group, (3,2)-scoped); B3 marksheet guard; B4 transport guard. `bash -n` clean. |

Both PHP masters pass `php -l` under PHP 8.3.6 (installed in this VM during the fix lane; brace/paren balance also 0/0). Behavioural proof remains the staging re-run.

**Probe residue on staging (all clearly named, harmless):** routes "W2A Probe Route/B/C" (ids 2–4), pickup points (ids 2–4), item "W2A Probe Item" (id 2) with one +10 stock row; the probe issue was returned (availability restored). All probe *shares* were deleted via the API. The battery's own run-1 fixtures remain, as designed.

## Prediction for the re-run

- All **24 FAILs flip to PASS** (each mechanism is removed, not masked).
- The lesson section **un-skips** (~8 new PASSes: lessonSave, topicSave, syllabusTopicStatus, syllabusStatus reconciliation, lessonPlanSave/List/Detail, commentSave — the last three also proving the `lessonPlanList` fix live).
- Checks that silently never ran in run 1 will execute for the first time: the online-exam block (questionSave → questionBankList → onlineExamQuestionSave/Detail/Results, ~6 checks, also proving the `questionBankList` and `onlineExamAssignSave` fixes), teacher roster restriction + foreign-section marks refusal, and the full marks cycle (save / over-max per-row refusal / idempotent replay / result reconciliation). These paths were audited against both defect families, but they carry first-exercise risk — a small number of new FAILs there would not be surprising and would be genuine finds, not regressions.
- Expected shape: **PASS ≈ 290+, FAIL 0, SKIP 0–1** (a SKIP remains possible only if staging fixture data shifts, e.g. library books).
