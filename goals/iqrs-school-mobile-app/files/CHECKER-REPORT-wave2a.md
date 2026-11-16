# CHECKER REPORT — Wave 2A API (Gate G1, staging contract gate)

**Checker:** independent lane (did not build this API) · **Date:** 2026-11-07
**Scope:** the 87 Wave 2A endpoints live on **staging** as Staffapi.php 569,947 B (md5 `f4f73b9c…`) + Staffsync.php 144,076 B (md5 `aa087ca8…`). Local masters md5-verified identical to the shipped sizes/hashes before any check ran. Production was never touched; no code or battery files were edited by this lane.

## VERDICT: **REJECT — one S1** (everything else passes; re-check scope is a single probe)

| # | Check | Result |
|---|---|---|
| 1 | Battery re-run (independent) | **PASS=305 FAIL=0 SKIP=0** |
| 2 | Wrong-role matrix (limited 115 / teacher 114) | PASS — 16/16 limited probes refused at application level; teacher scope exact |
| 3 | Honesty contracts | PASS on every contract probed (one defect found under #6, not here) |
| 4 | Idempotency (sync claim replay) | PASS — stored response + `duplicate:true`, effect applied once |
| 5 | Money truth (fee setup ↔ statement ↔ report) | PASS — reconciled three ways to the rupee |
| 6 | Static sweep — defect Families A & B | Family A extinct; **Family B has one live survivor → S1** |
| 7 | Additivity vs `.pre-wave2a` baselines | PASS — single pure-insertion hunk per file, zero baseline lines changed |

**S1 (must fix before G1 can pass):** `behaviourAssign`'s optional first comment is silently dropped on every call — explicit `null` into NOT NULL `student_incident_comments.student_id` (Family B). The incident and score persist and the endpoint reports success; the comment never exists. Evidence §6.
**S2 (debt):** `questionSave` UPDATE with a nonexistent class/subject id reports "Successfully." while the FK rejects the write and nothing persists. Evidence §6.

---

## 1. Battery re-run

Ran `test-wave2a-api-staging.sh` once, independently: **RESULT: PASS=305 FAIL=0 SKIP=0** — identical to the coordinator's run 4. (Run created its own fixture set: exam group 13, exam 5, roster 48.)

## 2. Wrong-role matrix (live probes, staging)

**Limited staff 115** (valid token, role with zero `roles_permissions` rows) — all refused with HTTP 200 + `status:0` + a plain permission message (never data, never a bare 401):

| Probe | Refusal message |
|---|---|
| examCatalog | "You do not have permission to view exams" |
| examGroupSave | "You do not have permission to manage exam groups" |
| examMarksRoster | "You do not have permission to view exam marks" |
| feeSetup / feeGroupSave | "…to view fee setup" / "…to manage fee groups" |
| staffSave / staffPayroll | "…to manage staff" / "…to view payroll" |
| reportRun (`report_key: due_fees_report`) | "You do not have permission to run this report" |
| fileOpen (fee_receipt) | "You do not have permission to view fee receipts" |
| libraryCatalog / contentList / itemSave | capability refusals, same shape |
| examMarksSave / libraryIssue / behaviourAssign (Staffsync) | capability refusals stored through the sync claim/finish pattern, same shape |

`appVersions` answered `status:1` for 115 — **by design** (contract: any staff session; it returns `configured:false`, §3).

**Teacher 114** (class teacher of Four–Daffodils (3,2) only), against exam 5 (48 assigned: 22 in (3,2) + 26 in (3,6)):

- `examMarksRoster`: admin sees **48** rows (22 + 26 by class/section); teacher sees **exactly 22**, all (3,2).
- Marks save for a foreign-section student (exam_student 188): `saved:0`, refused — *"This student is not in your classes"*.
- `myAttendance {staff_id:113}` → refused *"You do not have permission to view other staff attendance"*; `{staff_id:114}` → `status:1` (contract #10 holds).
- `staffPayroll` (any staff_id, incl. own) → *"You do not have permission to view payroll"* (category-gated, view-only per D-W2-3).

## 3. Honesty contracts (live probes)

- **Library fine:** issued book 1 to student 3699 with `duereturn_date` 2026-11-02, returned 2026-11-07 → `{"days_late":5, "fine":null, "fine_note":"This library does not record fines; the return is recorded with its days late."}`. Member history echoes `days_late:5, fine:null`. No invented amount anywhere.
- **fileOpen:** bogus receipt id → `{"kind":"fee_receipt","file":null,"reason":"Receipt not found."}`; unknown kind → `file:null, "Unknown document kind."`. No URL appears in any fileOpen response (grep-verified on raw bodies).
- **reportCatalog** (admin): **57 reports — 19 available** (exactly the implemented engine list in the build report) **and 38 `available:false`**, each with reason *"This report is not available in the app yet."* (samples: guardian_report, student_history, student_login_credential_report, class_subject_report). Nothing fabricated.
- **appVersions:** `{"configured":false,"connect":null,"workspace":null}` — the `api_app_versions` table does not exist and the endpoint says so.
- **Partial exam result:** exam 5 has marks for one of two subjects (41/50 in Art; second subject added by this lane, unentered) → `result_status:"incomplete", subjects_entered:1, subjects_total:2, percentage:82` — the percentage is over the entered subject only; the unentered subject reads `obtained:null`, never zero.
- **Over-max marks:** entry of 999 against max 50 → refused per-row: *"Marks 999 are above the maximum 50 for this subject"*; roster read-back afterwards still shows the previously stored **32** — not clipped to 50, not overwritten.

## 4. Idempotency

`examMarksSave` as teacher 114, one entry (exam_student 145 → 41), `client_txn_id` `checker-idem-<stamp>`, called twice with byte-identical bodies:

- Call 1: `{"status":1,…,"saved":1,"refused":[]}`
- Call 2: the **same stored response plus `"duplicate":true`** — the Phase B claim pattern marking the replay.
- Roster afterwards: exactly **one** result row (result_id 7) holding 41. Effect applied once.

## 5. Money truth (three-way reconciliation, live)

Created fee group "Checker Money" (fee_session_group_id 2021) with one line of **2,750** and assigned it to the fixture student (student_session 3699):

- `feeSetup`: the group goes `affects_students` **0 → 1** after the single assignment; `total_amount` **2750** = the line sum.
- `feeStatement(3699)`: balance **7,500 → 10,250** (+2,750); the group appears in the statement at exactly 2,750.
- `reportRun balance_fees_report`: the same student's row **7,500 → 10,250** — identical to the statement; school-wide totals **8,444,360 → 8,447,110** (+2,750 exactly, no other movement); the report's 1,663 row balances sum exactly to its stated totals (internal consistency).

## 6. Static sweep — the two defect families

### Family A (CI3 shared query-builder corruption) — **extinct in the shipped code**

Every retained-builder site in the Wave 2A regions was read end-to-end (assignment → execution):

- Staffapi: `lessonPlanList` (scope hoisted before the chain — the round-1 fix, with its explanatory comment in place), `libraryCatalog`, `contentList` (restructured exactly as the fix report describes: all scope/visibility queries complete before the `share_contents` chain is built), `itemCatalog`, `itemStockList`, `itemIssueList`, `staffPayroll`, `questionBankList` (scope hoisted), the four `reportRun` engine chains (income/expense, student, book issue/due, payroll) — each built and executed in one uninterrupted sequence; per-row helper queries run only **after** `get()`.
- `examCatalog`: the class/section filter ids are precomputed in a completed query before the main chain starts (round-1 fix verified in code); per-row counts run after execution.
- `examMarksSave` (Staffsync): all in-loop lookups are complete statements; no chain is retained across the `w2_sync_pair_allowed()` / group-student lookups.
- Staffsync `lessonSave` link resolution (round-2 fix): both candidate chains are built and executed with only `where()` calls in between.
- Grep over both 2A regions for a helper call evaluated **inside** a builder-chain argument (the `routePickupPointSave` disease): **zero hits**. `money_fmt()` / `getSetting()` (which query) occur only in standalone assignments or post-execution record building — never mid-chain. `valid_ymd()` and `w2_exam_record()` verified pure (no queries).

### Family B (explicit null into NOT NULL / FK columns) — **one live survivor (S1) + one masked-update edge (S2)**

All `=> null` and ternary-to-null sites in the 2A regions were cross-checked against the staging-export DDL. The fixed instances hold (itemStockSave defaults — battery proves totals move 15 → 12 → 15; inventoryIssue `note:''`; contentUpload content-type resolution + hollow-share guard; questionSave class_id — §below). Two do not:

**S1 — `behaviourAssign` comment silently dropped (Staffsync.php, behaviourAssign, ~line 2824).**
The optional-comment insert is
`insert('student_incident_comments', […, 'student_id' => null, …])`,
but the schema is `student_incident_comments.student_id int(11) NOT NULL` with **no default** (staging export DDL). This is round 1's Family B mechanism verbatim: the insert fails silently (db_debug off), the endpoint still answers success.
*Live proof:* as admin, `behaviourAssign {student_id:3699, incident_id:1, comment:"Checker probe comment <stamp>"}` → `status:1`, incident id 7, score 28 → 33. `studentBehaviour(3699)` immediately after: the new incident's `comments: []` — and **0 of the 7 incidents** on that student carry any persisted comment, although the battery also passes a comment on every assign. The incident and its points persist; only the comment text is lost, on every call.
*Correct value:* the incident's student — the vendor model (`Studentincidents_model::addmessage`) and the read side both treat `student_id` as the student the comment thread belongs to; `w2_behaviour_record` joins/displays it as such. Fix is one line (`'student_id' => $student_id`) plus a battery strengthening: assert the assign's comment round-trips in `studentBehaviour`. (Contrast: the sibling insert into `lesson_plan_forum` also passes `student_id => null`, but that column **is** nullable — `DEFAULT NULL` — and is safe; verified against the same DDL.)

**S2 — `questionSave` update masks an FK failure (Staffapi.php, questionSave update branch).**
Fix-3's existence checks run only on create. On update, a positive-but-nonexistent `class_id`/`subject_id` reaches the `update()` unwatched; the FK rejects it, the return value is ignored, and the endpoint re-reads the old row and answers `status:1 "Successfully."`.
*Live proof:* teacher created question 17 (class 3), then updated it with `class_id:999999` → `status:1`, record still class 3; read-back via `questionBankList` confirms nothing changed. No corruption (old values survive), but the success claim is untrue. Reachable only with deliberately invented ids — hence S2, not S1. Recommended fix: mirror the create-branch existence checks on update when the ids are present and positive.

Fix-3 itself verified live: `questionSave` without `class_id` → `status:0 "class_id is required — a question is filed under a class"`; with `class_id:999999` → `"Class not found"` — the deployed staging behaviour matches the current master's strings verbatim.

## 7. Additivity

`diff` of the shipped masters against `Staffapi.php.pre-wave2a` / `Staffsync.php.pre-wave2a`:

- **Staffapi.php: exactly one hunk, `4463a4464,9761` — +5,298 lines / −0.** A single contiguous insertion under the `WAVE 2A` banner, between the last Wave 1A endpoint and the Wave 1A helpers section.
- **Staffsync.php: exactly one hunk, `2044a2045,2990` — +946 lines / −0.**

Every Wave 0/1A line in both files is byte-identical to its baseline — stronger than the spot-check this gate requires: no pre-2A method body changed anywhere. All round-1/2/3 fixes landed inside the inserted regions. `php -l` (PHP 8.3.6): no syntax errors in either master.

## Notes & residue

- **Deployed-byte identity:** the checker cannot read staging's files directly; identity rests on the coordinator's size-verified swap manifests plus this lane's behavioural probes matching the current masters' code verbatim (fix-3 refusal strings, the `duplicate:true` replay marker, the lesson link resolution, the comment-participation rule) — the same evidence standard as the Wave 1A G1.
- **Probe-side errors, all mine, all corrected in-run:** first `reportRun` probe used `key` instead of `report_key`; first `feeStatement` probe used `student_id` instead of `student_session_id`; first `libraryIssue` omitted `duereturn_date`. In each case the endpoint's refusal was explicit and correct; none is a finding.
- **Staging residue from this lane** (all clearly named, fixture scope): exam 5 gained a second subject (Rhymes & Activities, unentered — it is what makes the §3 partial-result evidence readable); marks 41 on exam_student 145 (single result row); fee group "Checker Money 1794068408" (2,750) assigned to the fixture student — its statement balance now reads 10,250 (the battery reconciles relatively, so later runs are unaffected); behaviour incident 7 on student 3699 (+5); library issue 7 issued and returned; question 17 (teacher-owned); sync claims under `checker-*` txn ids.

## Re-check scope after the S1 fix

One probe only: `behaviourAssign` with a comment → `studentBehaviour` shows the comment in the incident's `comments[]` with the incident's student id. Everything else in this report stands as passed and does not need re-running.

---

# G1 RE-ENTRY PASS — 2026-11-07 (post-fix verification)

**Checker:** independent re-entry lane (not the fixer) · **Scope:** the two G1 findings (S1 + S2), both fixed and re-deployed to staging as Staffapi.php 570,998 B (md5 `5a9be05a…`) + Staffsync.php 144,420 B (md5 `9989306c…`) — local masters md5-verified identical to those hashes before any check ran. Production never touched; no code or battery files edited by this lane.

## VERDICT: **PASS — Gate G1 is cleared.**

| # | Check | Result |
|---|---|---|
| 1 | S1 fix — `behaviourAssign` comment persists | **PASS** (live proof below) |
| 2 | S2 fix — `questionSave` update FK guard | **PASS** (live proof below) |
| 3 | Battery re-run (independent) | **PASS=307 FAIL=0 SKIP=0** — identical to the coordinator's run 6; both new pinning checks pass by name |
| 4 | Spot probes (wrong-role / honesty / idempotency) | PASS ×3 |
| 5 | Static confirmation of both fixed sites | PASS — lines quoted below |

## 1. S1 fix proof (live, staging)

As admin 113: `behaviourCatalog` type 1 ("Excellent Conduct", +5). `studentBehaviour(3699)` before: **score 43, 9 records**.

`behaviourAssign {client_txn_id:"checker-reentry-1794069716", student_id:3699, incident_id:1, comment:"Re-entry probe comment 1794069716"}` → `status:1`, incident **id 10**, `points:5`, `score:48`.

`studentBehaviour(3699)` after: **score 48** (delta exactly **+5** = the incident's points), 10 records, and the new incident's `comments[]` now carries the text:

```json
[{"id": 3, "comment": "Re-entry probe comment 1794069716", "type": "staff", "staff_id": 113, "staff_name": "", "student_id": 3699}]
```

The comment persists with the incident's own student id (3699) — the exact behaviour whose absence was the S1. **The fix holds.**

## 2. S2 fix proof (live, staging)

As teacher 114: `questionSave` create (class_id 3) → question **id 20**, stored `class_id:3, subject_id:null`.

- Update `{id:20, class_id:999999}` → `{"status":0, "message":"Class not found"}` — explicit refusal, no false success. Read-back via `questionBankList`: record **byte-identical** to the post-create snapshot.
- Update `{id:20, subject_id:999999}` → `{"status":0, "message":"Subject not found"}`. Read-back again byte-identical.

The update path now honours the same FK truth as create. **The fix holds.**

## 3. Battery re-run

Ran `test-wave2a-api-staging.sh` once, independently: **RESULT: PASS=307 FAIL=0 SKIP=0** (coordinator's run 6: identical). The two checks added to pin these fixes both pass by name: *"behaviourAssign comment round-trips into studentBehaviour"* and *"questionSave update with bogus class refused explicitly (FK contract)"*.

## 4. Spot probes

- **Wrong-role:** limited 115 `examCatalog {}` → `status:0 "You do not have permission to view exams"` — application-level refusal with a valid limited token, same shape as the original matrix.
- **Honesty:** `fileOpen {kind:"fee_receipt", id:99999999}` → `{"kind":"fee_receipt","file":null,"reason":"Receipt not found."}` — no URL, no fabricated file. Bonus: `appVersions` → `{"configured":false,"connect":null,"workspace":null}`.
- **Idempotency:** the §1 assign replayed with the identical body and `client_txn_id` → same stored response plus `"duplicate":true`; score stayed **48**, the incident still carries exactly **1** comment, record count unchanged at 10. Effect applied once.

## 5. Static confirmation (local masters)

**Staffsync.php, `behaviourAssign()`** — the comment insert now carries the incident's student, with the defect's history recorded in the comment above it:

```php
            // student_incident_comments.student_id is NOT NULL with
            // no default: the vendor rows carry the student the
            // incident belongs to, so the comment takes the same
            // student_id (passing null sank the insert silently and
            // the comment was lost — checker G1 S1, 2026-11-07).
            $this->db->insert('student_incident_comments', array(
                'student_incident_id' => $id,
                'comment'    => trim((string) $params['comment']),
                'type'       => 'staff',
                'staff_id'   => (int) $staff->id,
                'student_id' => $student_id,
            ));
```

**Staffapi.php, `questionSave()` update branch** — existence checks run before the `update()` call:

```php
            // The UPDATE path honours the same FK truth as create:
            // a class/subject id that does not exist would be
            // rejected by the server silently while the endpoint
            // reported success (checker G1 S2, 2026-11-07) — check
            // up front and refuse explicitly instead.
            if (isset($data['class_id'])) {
                $u_class = $this->db->from('classes')->where('id', (int) $data['class_id'])->get()->row();
                if ($u_class == null) {
                    json_output(200, array('status' => 0, 'message' => 'Class not found'));
                    return;
                }
            }
            if (isset($data['subject_id']) && $data['subject_id'] !== null) {
                $u_subject = $this->db->from('subjects')->where('id', (int) $data['subject_id'])->get()->row();
                if ($u_subject == null) {
                    json_output(200, array('status' => 0, 'message' => 'Subject not found'));
                    return;
                }
            }
            $this->db->where('id', $id)->update('questions', $data);
```

## Residue from this lane (staging, fixture scope, clearly named)

Behaviour incident 10 on student 3699 (+5, with its persisted probe comment — it is the §1 evidence and stays readable); question 20 (teacher-owned, "Re-entry S2 probe 1794069762"); one sync claim under `checker-reentry-*`; the battery's own run fixtures.

## Gate statement

The original report's §§1–7 stand as passed; its single S1 and single S2 are both fixed, proven live above, and pinned by named battery checks. **Gate G1: PASS.**
