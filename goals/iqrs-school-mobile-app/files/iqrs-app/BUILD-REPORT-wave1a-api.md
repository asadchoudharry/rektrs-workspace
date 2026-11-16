# Wave 1A API — Build Report (Staffapi + Staffsync)

**Scope:** FEATURE-AND-DESIGN-PLAN §7.2 Wave 1A — API-02 worklist, API-30 register,
API-31 student leave, API-20/21/22/23/24 fees desk, API-60 notices, API-80 directory
(read), API-82 leave (mine + approvals), API-66 calendar/tasks, API-70/71/72
front-desk core, homework unblock (API-51/52; API-01 already exists).
**Built locally only.** Nothing was uploaded, executed, or run anywhere. Staging swap
+ the verification script run are the parent's next step.
**Verification script:** `~/workspace/iqrs-api/staff-ext/test-wave1a-api-staging.sh`
(written, syntax-checked, **not run** — staging was stalled by instruction).

## Files

| File | Before | After | Change |
|---|---|---|---|
| `~/workspace/iqrs-api/staff-ext/Staffapi.php` | 97,285 B / 2,019 lines | **281,482 B / 5,859 lines** | +28 endpoints, +~35 private helpers, ride-along guard swap (14 call sites), +`studentfeemaster_model` in the constructor's model list |
| `~/workspace/iqrs-api/staff-ext/Staffsync.php` | 36,780 B / 844 lines | **97,572 B / 2,335 lines** | +12 sync endpoints, capability helpers, ride-along guard swap (6 call sites) |

Backups: `Staffapi.php.pre-wave1a`, `Staffsync.php.pre-wave1a` (alongside the earlier
`.pre-wave0` / `.pre-m3`). Line endings preserved (LF in both files).
**Additivity, proven by diff:** the only changed lines in either original file are
the guard call sites (`auth_model->check_auth_client()` → `check_client()`) and the
one Staffapi constructor line. Every existing endpoint body is byte-identical.

## The ride-along (client-guard normalisation)

Root cause (vendor `Auth_model::check_auth_client()`, API tree): on missing/wrong
Client-Service/Auth-Key headers it answers **HTTP 200** with body
`{"status":0,"message":"Unauthorized."}` — while the no-token branch (session guard)
answers a proper **HTTP 401**. This is why the Wave 0 verification showed 4 cosmetic
"FAIL"s that were in fact correct refusals with the wrong status code.

Fix, without touching the vendor model (its behaviour backs every vendor Webservice
endpoint): both extension controllers now call their own private `check_client()`,
which performs the **identical comparison against the same values** — the Auth_model's
own public `client_service` / `auth_key` properties, so the identifiers are not
restated anywhere in the extension — and on failure answers **HTTP 401 with a
byte-identical body** (`json_output()` exits, exactly as the vendor path did).
Applied to all 14 Staffapi + 6 Staffsync existing call sites and every new endpoint.
**Not changed:** `Staffauth.php` (the login issuer) still calls the vendor guard —
it is outside this wave's file set; noted as a future one-line consistency item.

## Conventions every new endpoint follows

- POST-only (else HTTP 400) → `check_client()` → `require_staff_session()` (401 JSON)
  → capability self-check via the API-00 mechanism (`staff_can()` — same
  roles_permissions intersection API-00 reports; superadmin bypass exactly as
  reported; when the install has no roles_permissions structure,
  `role_names_fallback` degrades the check to the surface 'all' grant only, so an
  endpoint can never claim more than API-00 shows).
- Success `{status:1, message:"Successfully.", record}` or, for lists,
  `{status:1, message, records, summary, page:{page,page_size,total}, total}`.
  Refusals `{status:0, message}` in plain words. A foreign record reads exactly
  like a missing one.
- Identity always from the session; no client-sent staff id is trusted anywhere.
- Lists paginate (`page` ≥ 1, `page_size` clamped 1–100, default 20).
- Money numeric fields stay numbers (floats rounded 2dp — the values the checker
  reconciles); headline figures additionally carry a `*_formatted` display twin
  (school currency symbol from the general setting + 2dp). This honours §3's
  "integer rupees plus formatted string" without changing the numeric fields the
  contracts name.
- Staffsync writes keep the established claim/finish discipline: deterministic
  refusals are stored against the `client_txn_id` (a retry returns the same
  answer); internal failures release the claim for a later retry.

## Per-endpoint detail

### API-02 — `POST /api/staffapi/dashboardWorklist` (new)
- **Gate:** session only; each card is individually capability-gated and omitted
  when its capability is absent (the endpoint itself never refuses).
- **Record:** `{date, session_id, cards:[{key,label,count,detail,route}], generated_at}`.
- **Cards (count rule = the list's own rule, so Home and the list always agree):**
  `attendance_unmarked` (student_attendance/view — in-scope sections with ≥1 active
  student and 0 marks for the date; detail lists them) · `student_leave_pending`
  (approve_leave/view — the API-31 counter) · `staff_leave_pending`
  (approve_leave_request/view — status 'pending', others only, current session) ·
  `offline_payments_pending` (offline_bank_payments/view — is_active '0') ·
  `fees_due_students` (search_due_fees/view — the API-20 engine's count) ·
  `enquiries_due` (admission_enquiry/view — status 'active' AND follow_up_date ≤ today) ·
  `complaints_open` (complaint/view — derived status 'open') ·
  `homework_to_check` (homework_evaluation/view — submissions with no evaluation,
  own homework or office scope).

### API-30 — `POST /api/staffapi/attendanceRegister`
- **Gate:** student_attendance/student_attendance `view` + class in the caller's
  visible scope (`scope_allows`; office scope = all).
- **In:** `{class_id, section_id, date}` (period fields accepted and ignored — see
  Limitations). **Out record:** `{class_id, section_id, class, section, date,
  period_supported:false, types:[{id,type}] (the full 10-row verified table),
  students:[{student_session_id, student_id, name, roll_no, admission_no, image,
  existing_type_id, remark, on_approved_leave}], summary:{students, marked,
  unmarked, present, absent, on_approved_leave}}`.
- `on_approved_leave` = an approved (status 1) student_applyleave covers the date.
- **Staffsync::attendance is unchanged** — it already accepts the v2 payload's core
  (`records:[{student_session_id, attendence_type_id, remark}]`, upsert per
  student_session+date, txn-idempotent).

### API-31 — `studentLeaveList` / `studentLeaveReview` (Staffapi)
- **Gate:** student_attendance/approve_leave `view` (list) / `edit` (review).
- **Scope (the web's own rule, `Apply_leave_model::canApproveLeave`):** office role
  names (Super Admin/Admin) decide school-wide; anyone else only for class/section
  pairs where they are class teacher OR teach a subject (subject_timetable via
  subject_group_subjects). The visible-scope 'all' **fallback** (no assignments on
  file) is deliberately NOT used here — it must not widen a write. (Staff 114 holds
  approve_leave view-only, so on staging the capability gate admits the list and the
  pair-scope is the real protection, exactly as designed.)
- **List in:** `{status: pending|approved|disapproved|all, class_id?, section_id?,
  page, page_size}` (numeric statuses accepted). **Review in:**
  `{leave_id, decision: approve|reject, remark?}` — **online-only** (Staffapi).
- **Semantics mirrored from the web review** (`admin/Approve_leave::status`):
  approve → status 1 + approve_by = decider; reject → status 2 + approve_by = 0;
  `approve_date` is **not** set (the web doesn't set it). Non-pending → refused.
  `remark` is accepted for contract compatibility; student_applyleave has no remark
  column, so it is not persisted (the web review stores none either).
- **Record:** leave + student identity + class/section + status int + `status_name`
  + approver name.

### Fees desk (API-20…24) — one engine, vendor arithmetic
All five endpoints share `fee_student_lines()`, which reproduces
`Webservice::fees()` exactly: per line, paid/discount/fine are the sums over the
deposit row's `amount_detail` entries; **balance = amount − (paid + discount)**
(discount is never folded into "paid" — the school's discount-honesty rule);
status unpaid/partial/paid with the vendor's final reconciliation rule; the
is_system per-student amount override is applied by the vendor model itself.
Assessed late fines are reported separately as `fine_assessed` / totals `fee_fine`
and are **never** in the balance. Transport lines join the statement as their own
group ("Transport"), with the transport branch's fine rule (percentage computes on
the fee; the fees branch uses the stored fine_amount for both fix and percentage —
the vendor's own quirk, mirrored deliberately).

- **API-20 `feeDueSearch`** — gate search_due_fees/view. In `{session_id?,
  class_id?, section_id?, fee_group_id?, query?, due_on_or_before?, page,
  page_size}` (session defaults to current). Out records per §3.2 + 
  `summary:{students, balance, balance_formatted}`. Candidates are prefiltered in
  SQL; balances come only from the engine, so **this list, the statement totals and
  the worklist count reconcile by construction**.
- **API-21 `feeStatement`** — gate search_due_fees/view OR collect_fees/view.
  In `{student_session_id}`. Out `{record:{student:{…identity}, groups:[{name,
  lines:[{feetype, amount, discount, fine, fine_assessed, paid, balance, status,
  due_date}]}], deposits:[{date, invoice_id, sub_invoice_id, amount, discount,
  fine, mode, received_by, fee}], totals:{amount, discount, fine, paid, balance,
  fee_fine}}}`.
- **API-22 `feePaymentSearch`** — gate search_fees_payment/view. In `{date_from?,
  date_to?, query?, invoice_no?, payment_mode?, page, page_size}`. Rows = deposit
  entries session-wide (fees + transport merged, newest first) in the deposits
  shape + student identity; `invoice_no` matches the invoice id or the
  "invoice/sub" pair; `summary:{count, amount, amount_formatted}`.
- **API-23 `feeReceipt`** — gate search_fees_payment/view OR fees_statement/view.
  In `{invoice_id, sub_invoice_id, format}`. Resolves via the vendor
  `getFeeByInvoice()`; out `{record:{receipt:{…full view-model…}, file:null,
  format}}` — all three formats return the view-model in this wave; the printable
  files are API-04's job (a later wave), stated in the response shape rather than
  faked. `total_received` = amount + fine (discount is relief, never received
  money), with `total_received_formatted`.
- **API-24 `offlinePayments` / `offlinePaymentReview`** — gate
  offline_bank_payments/view (list) and /view (review; see note). List in
  `{status: pending|approved|rejected, page}`; statuses map to is_active
  '0'/'1'/'2' (the web model's own mapping). Review in `{id, decision:
  approve|reject, reason?}`, **online-only**. Approval mirrors the web approval
  (`OfflinePayment_model::update`) step for step: fee_transaction with
  fee_category fees|transport by the row's transport id, amount_detail
  `{amount = submitted amount, amount_discount 0, amount_fine 0, date =
  payment_date, description "Amount credited through offline bank payment Request
  ID: <id>", collected_by "Name(employee_id)", payment_mode "bank_payment",
  received_by = reviewer}` → **the vendor `fee_deposit()`** (the only money-write
  path) → the row's invoice_id becomes "<invoice_id>/<sub_invoice_id>", row marked
  approved with approved_by + approve_date. The deposit is posted **first**; the
  row is marked only on success. Non-pending rows are refused ("already been
  reviewed") — the web does not guard re-approval; double-posting money is exactly
  what this endpoint must not allow. Rejection writes is_active '2' + reply =
  reason + approver fields. **Note on the review gate:** the category enables
  `view` only on this install, and the web's own review is likewise a view-gated
  desk action — so review requires offline_bank_payments/view (not an edit action
  the install doesn't define). On staging, roles 1/7 effectively hold it
  (configuration/bypass); the Accountant role holds **no** offline_bank_payments
  grant at all and is refused — the endpoint follows the install's own
  configuration rather than inventing one.

### API-60 — notices
- **`noticeList` / `noticeDetail`** (Staffapi) — gate communicate/notice_board view.
  Visibility: visible_staff='Yes' AND (untargeted OR one of the caller's roles) OR
  own creation; office roles see the whole board. List in `{mine?, audience?,
  page}`; records carry audiences, role_ids, `published` (is_active='yes'),
  `can_edit`, and **`version` = the row's updated_at**. Publish state is reported,
  not filtered — drafts the caller may see are visible as unpublished.
- **`noticeUpdate` / `noticeDelete`** (Staffsync) — gates notice_board edit /
  delete + editor rule (creator, or office scope). Update **requires the loaded
  `version`**; a mismatch is refused with "This notice has changed since you
  loaded it. Please reload it and try again." Role targeting is replaced when
  `role_ids` is sent. Delete removes the notice + its notification_roles rows.

### API-80 — directory (read)
- **`staffDirectory` / `staffDetail`** — session-gated (any signed-in staff, plan
  §1.3 ALL). **The staff table is never selected with `*`** — an explicit column
  list; credentials and bank fields are excluded by construction. Limited view:
  id, employee_id, name, image, designation, department, roles, gender. Full view
  (adds email, contact numbers, joining date, addresses, qualification, marital
  status, dob, is_active) requires human_resource/staff `view` **or the record
  being the caller's own**. Directory lists active staff; detail resolves any id
  (needed to resolve names from other records). Filters: query (name/employee
  id/email), department_id, designation_id, role name.

### API-82 — staff leave
- **`myLeaves`** (Staffapi) — own data; identity from the session (no staff_id
  input exists). Balances reproduce the web's rule (`Leaverequest_model`):
  allotted from staff_leave_details (current session); applied = Σ leave_days
  where status != 'disapprove' — **pending counts as applied, exactly as the
  web's "total applied" figure does**; balance = allotted − applied. When no
  allotment rows exist, the active leave-type list is returned instead so the
  apply screen still works.
- **`myLeaveApply`** (Staffsync) — gate human_resource/apply_leave add. In
  `{leave_type_id, from_date, to_date, reason, document?, half_day?}`; days =
  inclusive span, 0.5 for a single-day half-day; status starts 'pending'
  (the web's self-apply shape); employee_remark truncated to the column's 200;
  `document` accepts an already-stored path string only (upload is out of scope).
- **`staffLeaveApprovals`** — gate approve_leave_request/view; the queue excludes
  the caller's own requests by construction. **`staffLeaveReview`** — gate
  approve_leave_request/edit, **online-only**; in `{leave_id, decision, remark?}`;
  writes the web's status strings ('approved'/'disapprove') + admin_remark +
  approve_date on any decision; **self-approval is refused before anything else**
  (plan §1.3), and non-pending requests are refused.

### API-66 — calendar + tasks
- **`calendarEvents`** — session-gated; school events (events table, non-task)
  overlapping the range + annual_calendar holidays for the current session
  merged with kind 'holiday', sorted by start. In `{date_from?, date_to?}`
  (defaults today → +30 days).
- **`myTasks`** (Staffapi read) + **`taskSave` / `taskDelete`** (Staffsync) —
  own data only, no capability gate (plan §1.3 ALL). Tasks are events rows of
  type 'task' keyed **`event_for = 'staff:<staff_id>'`** — the namespace
  guarantees isolation: the vendor pattern keys family tasks by the *numeric*
  users id, and 'staff:113' can never equal one (and the family public-events
  query's loose comparison coerces the prefixed string to 0, so staff tasks
  never surface in a family's list either). `done` maps to is_active 'yes';
  new tasks are created 'no' (open) — matching the vendor incomplete-counter's
  semantics. (The vendor's own family addTask creates 'yes' while its counter
  treats 'no' as incomplete — an upstream inconsistency we do not replicate.)
  Updates/deletes match on (id, type, owner key) — a foreign task reads as
  "Task not found".

### API-70/71/72 — front desk
- **API-70:** `enquiryList` / `enquiryDetail` / `enquiryFollowUps` (Staffapi;
  gates admission_enquiry/view, follow_up_admission_enquiry/view for the
  timeline) + **`enquirySave`** (create; Staffsync, admission_enquiry/add, so
  the desk works offline) + **`enquiryFollowUpSave`** (Staffsync,
  follow_up_admission_enquiry/add). Statuses are the config vocabulary
  (active/passive/dead/won/lost); new enquiries are 'active'. **Judgment call
  (documented):** a follow-up save also moves `enquiry.follow_up_date` to the
  agreed next_date — the desk's due lists and the worklist read that column, so
  leaving it stale would keep a handled enquiry "due" forever. created_by =
  acting staff id, as the web stores it.
- **API-71:** `visitorList {date}` (Staffapi; visitor_book/view) +
  **`visitorCheckIn` / `visitorCheckOut`** (Staffsync; add / edit). Check-in in
  `{name, phone (or contact), purpose, meet_staff_id? / meet_student_id? (=
  student_session_id), note?, …}`; `meeting_with` stores the web column's own
  vocabulary ('staff' | 'student', '' when neither — both are optional in the
  contract); in_time = now, out_time ''. Check-out refuses an already-out
  visitor. The list resolves the meeting target's name (and admission number
  for students).
- **API-72:** `callLogList` / `callLogSave` (phone_call_log view / add / edit —
  §3.4 places these saves in Staffapi), `postalList` / `postalSave`
  (dispatch_receive; `type` ∈ dispatch|receive selects the postal_dispatch /
  postal_receive capability for both list and save; `image` is a stored-path
  string — multipart upload follows the photo discipline of a later wave),
  `complaintList` / `complaintSave` / `complaintStatusSave` (complaint
  view/add/edit; status save online-only). **The complaint table has no status
  column** (evidence: staging export DDL) — the status shown is *derived*:
  action_taken non-empty → 'resolved', assigned non-empty → 'assigned', else
  'open'; the list filter applies the same derivation, and the worklist counts
  the same 'open' rule, so all three always agree. `complaint_type` stores the
  type name string verbatim (the picklist table's values), as the web does.

### API-51/52 — homework unblock
- **`homeworkList` / `homeworkDetail`** (Staffapi; homework/homework view).
  A teacher's default list is their own homework (`mine` defaults to true for
  non-office roles, false for office scope); class/section filters are
  scope-checked. Records carry hand-in/evaluation/roster counts computed by the
  same joins the submissions screen reports. Visibility for detail: own
  homework, or office scope — foreign reads as "Homework not found".
- **`homeworkSubmissions`** (Staffapi; homework_evaluation/view) — the class
  roster for the homework's class/section/session, LEFT JOINed to
  submit_assignment and homework_evaluation; per-student state follows the
  vendor model's own precedence (evaluated > submitted > pending); summary
  counts submitted/evaluated.
- **`homeworkUpdate` / `homeworkDelete`** (Staffsync; homework edit / delete +
  own-or-office rule). Update covers content fields only (dates, description,
  max marks, document) — class/section/subject are not re-targetable here.
  Delete also removes the homework's submissions and evaluations (the web's
  referential cleanup — no orphaned hand-ins).
- **`homeworkEvaluate`** (Staffsync; homework_evaluation add, or edit when an
  evaluation already exists). Addressed by `submission_id` (the contract);
  `homework_id + student_session_id` is accepted as an alias resolving to the
  same submission. Writes the vendor's evaluation shape (status 'Complete',
  date stamped, homework.evaluation_date/evaluated_by stamped; marks refused
  above the homework's max when one is set — the web controller's rule). It
  deliberately does **not** reproduce the web's delete-others behaviour in
  addEvaluation (a full-roster save deletes evaluations outside the submitted
  set — a single-student mobile evaluate must never delete classmates').

## NOT built — with the concrete, evidenced reason

1. **API-30 period attendance (the register's `period` variant + Staffsync
   attendance v2 period fields).** There is no period storage to write to:
   `student_attendences` has no period/subject column and no period table
   exists in the staging export (the only "period" table is the unrelated AFM
   custom `afm_period_locks`). The register therefore returns
   `period_supported: false` honestly, and Staffsync::attendance is untouched
   (it already accepts the v2 core payload). Building period attendance needs
   a schema decision (Wave 2 "Conditional" in the plan matrix) — not an
   endpoint invention.
2. **API-23 file output (format pdf/thermal) and API-24's payment-slip file.**
   Both are API-04 file-staging outputs (a later wave per the plan). The
   receipt endpoint returns the complete view-model with `file: null` and the
   requested format echoed — nothing is faked.
3. **API-72 postal `image` upload / API-82 leave `document` upload /
   API-70 attachment handling.** These endpoints accept already-stored path
   strings; the multipart upload itself follows the established photo
   discipline and belongs with the file wave. No upload behaviour was
   invented.
4. **API-81 (staff attendance)** — not in the 1A wave-table scope (it is a
   later wave); nothing built.
5. **Staffauth's client guard** keeps the vendor call (see ride-along note) —
   outside this wave's two files.

## Verification performed locally (and its limits)

- **Diff vs the pre-wave backups:** the only modified original lines are the 20
  guard call sites + 1 constructor line; everything else is pure addition.
- **Bracket/paren/bracket balance:** a string/comment-aware scanner reports both
  files BALANCED (baseline files also balanced under the same scanner).
- **Cross-reference check:** every `$this->…()` method called by the new code
  resolves to a definition in the same file (52 in Staffapi, 14 in Staffsync);
  no duplicate method names in either file.
- **Schema claims** were taken from the staging export DDL (373 tables) and the
  vendor models/Webservice source in the local production copy — notably:
  complaint has no status column; dispatch_receive exists (postal is real);
  send_notification.updated_at exists (the version token); enquiry statuses
  from config/payroll.php; staff leave statuses are the strings
  'pending'/'approved'/'disapprove'; homework_evaluation keys on
  (homework_id, student_session_id) with student_id also stored.
- **LIMIT, stated plainly: there is no PHP binary in this VM**, so no `php -l`
  was possible. The staging smoke after the swap is the parse test — the
  established pattern for this codebase. The verification script's §1 probes
  will surface a parse failure immediately (HTML error page instead of 401
  JSON) before any happy-path section runs.

## The verification script (written, NOT run)

`test-wave1a-api-staging.sh` (38,080 B, bash-syntax-checked) — staging-pinned
(refuses any other BASE), in the wave0 script's style:
- **§1** unauthenticated probes for all 45 new endpoints: no-token → 401 JSON;
  **no-client-headers → HTTP 401 with body status 0 (the ride-along assertion)**,
  including on two pre-existing endpoints; GET → 400.
- **§2** admin (113) happy paths + **reconciliation assertions**: worklist
  fees_due_students count == feeDueSearch total; feeStatement totals
  (balance = amount − paid − discount; Σ deposits = paid; Σ line balances =
  balance); feeReceipt against a real deposit; register shape +
  `period_supported:false`; an attendance flip → register read-back → restore
  cycle that only touches an already-marked student and restores the original
  type; full CRUD round trips for notices (incl. the stale-version refusal),
  tasks, enquiries + follow-ups (incl. the follow_up_date move), visitors
  (incl. double-check-out refusal), call log, postal, complaints (derived
  status open → assigned); the homework flow driven off academicCatalog
  (NOTE-skips cleanly when no subject group is configured).
- **§3** teacher (114): deterministic wrong-role refusals (all fees endpoints,
  front-office lists, staff-leave approvals/review), directory limited-view
  assertions (no email/contact_no for colleagues; full record for self),
  register own-vs-foreign **when the install scopes the teacher 'assigned'**
  (NOTE-skips with the reason when the fallback makes scope 'all'), and the
  full staff-leave loop — 114 applies → 113's queue contains it → approve →
  114 sees 'approved'; **113's self-approval is refused** (the admin's own
  test application stays pending on staging as a named fixture row).
- **§4** the family student-leave round trip (guarded): vendor login as the
  Wave 0 fixture parent, `webservice/addLeave` for child 3699 → the
  application appears in 113's pending list → approve → status verified.
  NOTE-skips cleanly if the vendor flow refuses (its file-upload callback is
  the known risk).
- **§5** regressions: capabilities / academicCatalog / dashboard / me /
  classes / student(2397) / feeInvoice, plus the studentUpdate suite
  invocation copied from the wave0 script (SKIP_REGRESSION honoured).

## What the parent does next

1. Swap both files into **staging** with the established pattern
   (`<name>.bak-2026-11-07-wave1a` backups first, size-verify after:
   Staffapi.php 281,482 B, Staffsync.php 97,572 B).
2. Run `test-wave1a-api-staging.sh` (expect some NOTE-skips on a fresh staging:
   attendance write cycle, homework flow before D1/D2 data is exercised,
   family leave if the vendor upload callback refuses).
3. Independent checker pass per plan §6 (the script's §1/§3 refusals and §2
   reconciliations are the checker's G1 evidence).
4. Production remains untouched; per-file production swaps need Assad's tap,
   as always.
