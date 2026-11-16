# BUILD REPORT — Wave 2C-A API amendment (staging wave)

**Built:** 2026-11-07 · **Builder:** API builder lane (local build complete; **staging swap NOT executed by this lane** — see §6)
**Scope:** the two additive endpoints that close the Wave 2C build report's gaps **G-1** (visitor registration) and **G-2** (authorised family document read, decision D-W2-4a).
**Masters:** `~/workspace/iqrs-api/staff-ext/Staffsync.php` (amended) + `~/workspace/iqrs-api/staff-ext/Familydocs.php` (NEW)
**Battery:** `~/workspace/iqrs-api/staff-ext/test-wave2ca-api-staging.sh` (written; **run pending the swap**, §7)

---

## 1. Files

| File | Before | After |
|---|---|---|
| Staffapi.php | 570,998 B · md5 `5a9be05adacec777a1f214a71356c6a4` | **UNTOUCHED** — byte-identical (this amendment needed no Staffapi change) |
| Staffsync.php | 144,420 B · md5 `9989306c7bfb837f381089fbeafc71b3` | **151,515 B · md5 `ecc33f6047dd660218cb1797d5579651`** |
| Familydocs.php | — (did not exist) | **NEW · 26,322 B · md5 `3884308c5d876d55090e4bf8ec6970bf`** |

**Additivity:** the Staffsync diff against the kept baseline `Staffsync.php.pre-wave2ca` (md5-verified copy of the staging-live master) is **+153 lines / −0 lines** — one inserted section, no existing line edited. Familydocs.php is a wholly new controller file. **No vendor file is edited by this amendment** (Webservice, Auth_model and every other vendor file keep their bytes; the family controller *calls* the vendor Auth_model, it does not modify it). All three files pass `php -l` (PHP 8.3.6).

## 2. Endpoint 2 first (the side determination) — `visitorSave` closes G-1

### Which side registration belongs to — the evidence

- **Families never register visitors.** The vendor family service's only visitor surface is `Webservice::getVisitors` — a *read* of `visitors_model->visitorbystudentid(student_session_id)`: the book entries tied to *your child*. The FEATURE-AND-DESIGN-PLAN's own C-3 row ("endpoints exist — `getVisitors`, `addvisitor`") was written against the legacy client's route table; the 2C lane searched this install's controllers and models and found **no `addvisitor` anywhere** (verified again in this lane against the staging tree copy: `getVisitors` exists, no add-save visitor method does). The plan's API-71 contract is the design's own answer: *"Staffsync `visitorCheckIn`/`visitorCheckOut` + `staffapi/visitorList`"*, gated **Receptionist / Super Admin / Admin** — registration is a front-desk act.
- **What already existed (Wave 1A):** `staffapi/visitorList` (read; gate `front_office / visitor_book / view`) and `staffsync/visitorCheckIn` + `visitorCheckOut` (the offline desk writes; gates `…/add` and `…/edit`; `client_txn_id` idempotency through `api_sync_log`). Staffapi's own section header states the split: *"enquiry/visitor creates and follow-up saves are Staffsync's, so the desk works offline."*
- **The actual hole:** a caller on the direct (non-queued) route shape had no registration door — the only create lived behind the offline outbox machinery. That is the gap behind G-1's "one additive extension endpoint".

### The endpoint — `POST /api/staffsync/visitorSave` (API-71, online half)

Placed in Staffsync beside its twin (the file that owns every `visitors_book` write in the extension), mirroring `visitorCheckIn`'s field contract, requireds and insert **exactly** — one registration behaviour in the extension, two doors.

**Guard (identical to every Staffsync write):** POST only → the extension client guard (Client-Service / Auth-Key) → staff session (`api_staff_sessions`) → **permission gate `front_office / visitor_book / add`** (the same gate as `visitorCheckIn`; refusal text "You do not have permission to register visitors") → `client_txn_id` **required**, claimed through the same `api_sync_log` claim/finish pair as its siblings (the sibling write endpoints all use it, so the conditional in the assignment resolves to *yes, idempotent*).

**Request** (JSON):
```json
{ "client_txn_id": "…", "name": "W2CA Visitor One", "phone": "03001234567",
  "purpose": "W2CA Script visit",
  "meet_student_id": 3699,            // = student_session_id; or "student_session_id"
  "meet_staff_id": 113,               // alternative meeting target
  "source": "", "email": "", "id_proof": "", "no_of_people": 1,
  "note": "", "image": "" }
```
`name`, `phone` (or `contact`) and `purpose` are required. A named meeting target must exist (staff row / student_session row) or the save is refused ("Staff member not found" / "Student not found"); no target = a walk-in (`meeting_with` `''`).

**Write:** one `visitors_book` insert with `date` = today, `in_time` = now, `out_time` = `''`. Every NOT NULL column of the live table (`purpose, name, contact, id_proof, no_of_people, date, in_time, out_time, note, meeting_with` per the staging DDL) receives an explicit value — no null can sink the insert.

**Response** (HTTP 200): `{"status":1,"message":"Successfully.","record":{"visitor_id":N, …the stored fields…}}`, and the row is **read back after insert** before the success is stored/returned (db_debug is off in this tree; a silent insert failure releases the claim and answers `status:0 "Internal server error."` instead). Refusals keep the sync shape (HTTP 200 + `status:0` + plain message) and are stored through `sync_finish`, so a replayed refusal replays identically; a replayed success returns the stored answer with the **same** `visitor_id` and creates no second row.

## 3. Endpoint 1 — `familydocs/fileOpen` closes G-2 (D-W2-4a)

### Why a new controller

The API-04 rails live behind the *staff* session (`api_staff_sessions`); the vendor family session lives in `users_authentication` — the two can never cross (Staffapi's own header documents this). A family document door therefore cannot be a Staffapi method, and the vendor Webservice must not be edited. `Familydocs.php` is a new additive controller in the API tree, routed as `/api/familydocs/fileOpen`.

### Guard — the vendor's own validation, exactly

POST only (else HTTP 400, the extension shape) → `Auth_model::check_auth_client()` (the vendor model compares the Client-Service / Auth-Key headers against its own properties — the identifiers are never restated in the new file; failure = the vendor's HTTP 200 + `{"status":0,"message":"Unauthorized."}`) → `Auth_model::auth()` itself (User-ID + Authorization against `users_authentication`, with the vendor's expiry answer HTTP 401 `{"status":401,"message":"Unauthorized."}` / "Your session has been expired." and its renewal write). A **staff token can never open this door** (staff ids have no `users_authentication` row); a family token gains nothing staff-side either. After auth, the session user is resolved from `users` (id, user_id, role); a non student/parent role is refused 401.

### Ownership (the IDOR fix the overhaul audit requires)

- **Student session:** `users.user_id` IS the student id (the vendor login's own shape) — only that student's documents exist for the request.
- **Parent session:** only students with `students.parent_id = <the parent's users.id>` (the linkage every vendor family read uses).
- `report_card` checks ownership of the requested `student_id` **before** any exam lookup; `fee_receipt` derives the owner from the deposit itself (deposit → `student_fees_master` → `student_session` → student — the Wave 1A defect-5 lesson: the deposit table carries no student_session_id) and checks *that* student, never a caller-supplied one.
- A foreign id, a nonexistent id and an unowned receipt all answer the **identical** shape — HTTP 200, `status:1`, `record.file = null`, `record.reason` = "This report card is not available for your account." / "This receipt is not available for your account." — no document, and no hint about whether the foreign record exists.

### Kinds

**`report_card`** — `{kind:"report_card", exam_id, student_id}`. Beyond ownership, **publication is part of the family contract**: an exam with `is_publish != 1` answers `file:null` + "Results for this exam have not been published yet." (the staff door shows working results; the family door shows only what the school published). The card is rendered on the server with this tree's own mPDF (`M_pdf`, the library the vendor Webservice itself loads) using the extension's marksheet computation mirrored line-for-line (totals over entered subjects only; `result_status` stays `incomplete` until every subject is entered; grades/divisions resolved the family API's way; rank + teacher remark from the exam-student row). Answer on success: `record = {kind, file:{format:"pdf", filename:"report-card-<exam>-<student>.pdf", mime:"application/pdf", size, content_base64}, reason:null, published:true}`.

**`fee_receipt`** — `{kind:"fee_receipt", invoice_id, sub_invoice_id}`. Rides the same rails cleanly because the B13 pattern is ownership-agnostic until the identity step: the deposit's `amount_detail` entry is rendered exactly as API-04 renders it (amount / discount / fine / total, payment mode, received-by, the school's letterhead) once ownership of the master row's student is proven. Same file payload shape (`fee-receipt-<invoice>-<sub>.pdf`). A missing deposit → "Receipt not found."; a missing entry → "That payment entry is not on this receipt." — the B13 reasons verbatim.

**Any other kind** → `file:null` + "Unknown document kind."

### Deliberate deviations from API-04, named

1. **Session + ownership model** (above) — the entire point of the amendment.
2. **Publication gate on `report_card`** — family-only; Staffapi's marksheet has no such gate.
3. **Helpers are mirrored, not shared** — `result_card`, the PDF/payload/header helpers and `fee_student_identity` are duplicated in small inside Familydocs because a family session can never reach Staffapi's private copies. Same tables, same joins, same computation; if the staff card's computation ever changes, this mirror must change with it.
4. Every query in the new file is a completed `get()` before the next chain starts (the CI3 shared-builder rule — no helper is evaluated mid-chain; the fee-name lookup runs only after the deposit/master/session reads have all completed).

## 4. Self-checks performed (local)

- `php -l` clean on Staffapi.php (untouched), Staffsync.php, Familydocs.php (PHP 8.3.6).
- Staffsync additivity: diff vs `Staffsync.php.pre-wave2ca` = **+153 / −0**.
- Column audit against the staging export DDL: `visitors_book` NOT NULL set fully covered by the insert; `users(id, user_id, role)`, `students(id, parent_id)`, `student_fees_deposite(id, student_fees_master_id, fee_groups_feetype_id, student_transport_fee_id, amount_detail)` all exist as used; `exam_group_class_batch_exam_students` carries `rank`/`teacher_remark` (selected explicitly).
- The vendor contracts were read from the staging tree copy, not from memory: `Auth_model::check_auth_client()/auth()/login()` (token store + renewal), `Webservice::getVisitors` (read-only family visitor surface), `Auth_model::checkLogin` (parent linkage `students.parent_id = users.id`), `Visitors_model` availability (the web-side model is `Frontoffice_model` in this build — the extension writes the table directly, as `visitorCheckIn` already does).

## 5. ⚠️ A live defect found in the EXISTING batteries (not caused by this amendment)

`test-wave2a-api-staging.sh` (and the wave0/wave1a/student-update batteries, which share the lines) currently carry staff-fixture password defaults whose md5s do **not** match the checker's pinned values, and live login with them answers "Invalid Username or Password" for all three fixtures. The values recorded in the programme's own context — staff 113 `TestStaff@2026` (md5 `fee3c980…`), 114 `TestTeach@2026` (`6bb92a81…`), 115 `TestLib@2026` (`09a38424…`) — match the pins exactly and log in cleanly (all three re-verified live in this lane). This is the battery1 incident class (a redacting view mangled the stored defaults); **the old batteries were NOT edited by this lane** — repairing them is a coordinator decision, and any repair must be hash-verified, never eyeballed. The new battery (§7) therefore takes all five fixture credentials **via the environment only**, with no defaults in the file, and refuses to run when one is unset.

## 6. Staging swap manifest (for the coordinator's browser lane — NOT executed here)

This lane is a generic subagent and cannot operate the live browser; the established route is a CEO-operated File Manager swap under the **"IQRS Hostinger" browser profile `p0b17e5065f41`**. Staging controllers folder: `staging/api/application/controllers/` under the staging site root `/home/u238632175/domains/iqrs.edu.pk/public_html/staging`.

| Step | File | Preflight (staging now) | Backup name | New size | New md5 |
|---|---|---|---|---|---|
| 1 | Staffsync.php | 144,420 B · md5 `9989306c…` — **stop if different** | `Staffsync.php.bak-2026-11-07-wave2ca` | **151,515 B** | `ecc33f6047dd660218cb1797d5579651` |
| 2 | Familydocs.php | must NOT exist yet — **stop if it does** | — (new file) | **26,322 B** | `3884308c5d876d55090e4bf8ec6970bf` |

Staffapi.php is **not** in this manifest (untouched). Production is **not** in this manifest. After the swap, the two no-token probes flip from 404 to the guard answers (staffsync/visitorSave → 401; familydocs/fileOpen → 401 JSON), which is the landing signal; then run the battery (§7).

## 7. The battery — `test-wave2ca-api-staging.sh` (written, run pending the swap)

~55 checks: guard probes for both routes (incl. the landing signal above); the five fixture logins; an exam fixture built through the staff API (group → exam → subject → assign Seven–Diamond (7,33) + Four–Daffodils (3,2) → marks for one student of each section); **report_card**: unpublished → `file:null` + reason → publish → parent PDF (magic bytes) → student's own PDF; **ownership proof**: the fixture parent requesting student **2397** (a real student of another parent) is refused `file:null` + reason, the student session requesting 2397 likewise, a nonexistent student id gets the *identical* answer, and a staff token at the family door gets 401; **fee_receipt**: a Rs 100 `feeCollect` against the fixture child's own master (invoice pair discovered from `feeStatement`), then parent + student PDFs and a nonexistent-receipt refusal; **visitorSave**: registration → read-back on `visitorList` (the write proven, not just answered), idempotent replay (same `client_txn_id` → same `visitor_id`, exactly one register row), missing-purpose / nonexistent-meet-staff / missing-txn refusals, the limited role 8 refusal, and the teacher's answer recorded as a note (role 2's `visitor_book add` grant is the school's own data). Fixtures are left in staging clearly named ("W2CA Script" / "W2CA Visitor").

**Run command** (credentials via env — the values are the staging fixtures recorded in §5):
```bash
cd ~/workspace/iqrs-api/staff-ext
ADMIN_PASSWORD=… TEACHER_PASSWORD=… LIMITED_PASSWORD=… \
PARENT_PASSWORD=… STUDENT_PASSWORD=… \
./test-wave2ca-api-staging.sh
```
Expected once swapped: `RESULT: PASS=… FAIL=0`. Until the swap lands, the battery's first section fails by design (it names the 404 as "not swapped into staging yet").

---

## ADDENDUM — 2026-11-07 · battery first-run diagnosis (PASS=35 FAIL=4 SKIP=1 → PASS=47 FAIL=0 SKIP=0)

**Lane:** diagnosis + fix lane for the battery's first full run. **Headline: every defect was in the battery; no endpoint was defective and no server file changed.** All diagnoses were proven against live staging data and endpoint source, not inferred.

### FAIL 1 — `examStudentsAssign Seven-Diamond` → BATTERY defective

- The battery hardcoded the pair `class_id 7, section_id 33` for "Seven / Diamond (Hifz Boys)". Section ids are install-local: on **staging**, `staffapi/classes` (session 21) shows Seven's sections as 12 Leader (Boys), **13 Diamond (Hifz Boys, 15 active students)**, 45 Silver (Girls), 48 Imperial (Hifz Girls). Staging's section 33 belongs to Playgroup (class 5, "Playgroup (House E)"). The pair (7,33) matches **zero** `student_session` rows, so the endpoint's `status:0 "No students given — pass student_session_ids or class_id + section_id"` is its correct contract answer for an empty roster, not a parse failure.
- Manual reproduction on a fresh lane-created exam (group "W2CA Diag Group …", exam 11): the battery's exact request `{"exam_id":11,"class_id":7,"section_id":33}` returned the identical refusal; the corrected pair `(7,13)` returned `status:1, assigned:15`, and `examMarksRoster` carries the fixture child. The endpoint code's class branch (session + class + section join, `students.is_active='yes'`, the documented enrolment rule) is sound and consistent with its full 2A battery + G1 pass — weighed and verified, not assumed.
- The battery's other suspect assumption was **proven correct**: the roster row for student 3699 carries `student_session_id: 3699` on staging, so `CHILD_SS=3699` stands.
- **Fix (battery):** assign call and the roster's second-section filter now use section_id **13**; the comment records that section ids are install-local and what staging's 33 actually is.

### FAILs 2–4 — roster + both report-card legs → pure cascade of FAIL 1

With the child never assigned, `examMarksRoster` correctly lacked them and Familydocs correctly answered "This student is not assigned to the exam". Familydocs was never implicated (its unpublished / foreign / nonexistent refusals all passed in the first run too). After the FAIL 1 fix, the whole chain passes: marks entered for both sections, unpublished → `file:null` + reason, publish → real PDF (magic bytes) for the parent **and** the student's own session, `published=true` on the family answer.

### SKIP — `fee_receipt` → BATTERY defective (extraction read the wrong level)

- The battery searched each fee **line** for `student_fees_master_id`. `feeStatement`'s builder (`fee_student_lines` in Staffapi.php) emits that key on the **group**; lines carry only `fee_groups_feetype_id`. The lookup therefore found nothing on any response, however many masters the child has.
- The fixture child's statement in fact exposes collectable masters (e.g. master **5154** / line **2015**, from the 2A battery's own "W2A Script Fees" groups against this child) — proven by running the battery's exact extraction snippet on the live response (yields `('','')`) versus the group-level read (yields `('5154','2015')`).
- **Fix (battery):** the master id is read from the group (the transport group's `null` master id is skipped by the same truthiness check). The SKIP is **eliminated, not explained away**: `feeCollect` Rs 100 passes and both the parent's and the student's fee receipts return real PDFs, plus the nonexistent-receipt refusal.

### Additional latent battery defect found while iterating — replay row count

Not among the first run's failures (it passed there only because that run was the day's first). The "exactly one register row" check counted `visitorList` rows **by name** across the whole day register; every battery run mints a unique `client_txn_id` and leaves its own "W2CA Visitor Replay" row (first run: visitor 9; this lane's runs: 11, then 13), so any second same-day run falsely failed it. `visitorSave`'s idempotency itself is proven sound — same txn → same `visitor_id`, exactly one row per txn on the register. **Fix (battery):** the count is scoped to this run's replay `visitor_id`. Post-fix run 1 exposed this (PASS=46 FAIL=1 SKIP=0); the final run is clean.

### Fixes applied — all in `test-wave2ca-api-staging.sh`; zero endpoint changes

1. Seven–Diamond pair `section_id 33 → 13` (assign call + roster filter + explanatory comment).
2. Fee-master extraction reads `student_fees_master_id` from the group, not the line (+ comment).
3. Replay register-row count scoped to the run's own `visitor_id` (+ comment).

The script still carries no credential values (env-only, verified by grep) and was edited only through the file tools, never a redacting path. No swap is needed for these fixes — the §6 manifest already landed (the battery's guard legs confirm both endpoints live: familydocs 401 JSON, visitorSave 401).

### Final counts

| Run | Result |
|---|---|
| First run (as delivered) | PASS=35 FAIL=4 SKIP=1 |
| After battery fixes, run 1 | PASS=46 FAIL=1 SKIP=0 (the latent replay-count defect) |
| **After battery fixes, run 2 (final)** | **PASS=47 FAIL=0 SKIP=0** — script exit 0 |

The check total grew 40 → 47 because legs that previously collapsed into single FAIL/SKIP lines (marks ×2, report-card PDFs, the fee_receipt chain) now execute individually. The one NOTE stands as designed: teacher 114's `visitorSave` answers status 0 — role 2's `visitor_book add` grant is the school's own RBAC data, recorded, not asserted. Fixtures left on staging by this lane and the green runs are all clearly named (W2CA Diag exam 11, unpublished; the battery's own W2CA Script groups/exams, its Rs 100 "W2CA Script collection" deposits, and W2CA Visitor register rows). Production was never contacted.
