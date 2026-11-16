# Wave 1A API — Build Record (reconstructed 2026-11-07)

The builder lane's original report was delivered in chat on 2026-11-07 and never
filed (checker finding F2). This record is reconstructed the same day from the
delivery record and the shipped code itself; the endpoint inventory below is
derived by diffing the pre-wave baselines against the shipped files, so it is
code-exact. The fix round is documented separately in
BUILD-REPORT-wave1a-api-fixes.md, and the independent verdict in
CHECKER-REPORT-wave1a.md (PASS).

## Scope delivered

Staffapi.php 97,285 → 281,482 B (build) → **282,897 B** (after fix round);
Staffsync.php 36,780 → **97,582 B** (build + fix round). Additivity proven by
the checker: Staffapi +3,884/−15 lines (1 constructor line + 14 auth-guard
swaps), Staffsync +1,497/−6 (guard swaps) against the Wave 0 baselines.

**33 new Staffapi endpoints:** dashboardWorklist (API-02), attendanceRegister
(API-30), studentLeaveList, studentLeaveReview (API-31), feeDueSearch,
feeStatement, feePaymentSearch, feeReceipt, offlinePayments,
offlinePaymentReview (API-20–24), noticeList, noticeDetail (API-60),
staffDirectory, staffDetail (API-80), myLeaves, staffLeaveApprovals,
staffLeaveReview (API-82), calendarEvents, myTasks (API-66), enquiryList,
enquiryDetail, enquiryFollowUps (API-70), visitorList (API-71), callLogList,
callLogSave, postalList, postalSave, complaintList, complaintSave,
complaintStatusSave (API-72), homeworkList, homeworkDetail,
homeworkSubmissions (API-51/52).

**12 new Staffsync endpoints:** enquirySave, enquiryFollowUpSave, visitorCheckIn,
visitorCheckOut, noticeUpdate, noticeDelete, homeworkUpdate, homeworkDelete,
homeworkEvaluate, myLeaveApply, taskSave, taskDelete.

## Design points (from the delivery record)

- Fees run on one shared engine mirroring Webservice::fees() arithmetic
  (balance = amount − paid − discount); the only money write
  (offlinePaymentReview approval) goes through the vendor
  `Studentfeemaster_model::fee_deposit()`.
- Staff directory selects an explicit column list (credentials/bank fields are
  excluded by construction); contact fields appear only in the full view
  (human_resource/staff view holders, or the member's own record).
- Sync writes keep the Phase B `client_txn_id` idempotency via api_sync_log.

## Not built — with evidence (honesty contracts, checker-verified live)

- Period-wise attendance: no period storage exists in this install; the
  register answers `period_supported: false` rather than fabricating data.
- Receipt/slip FILE output: feeReceipt returns the view-model with
  `file: null` (file generation is API-04's wave).
- Multipart uploads for postal image / leave document; API-81 (directory
  write half) — not in this wave.

## Verification

Full battery on staging: first run 149 PASS / 24 FAIL → fix round →
**177 PASS / 0 FAIL** (incl. studentUpdate regression 18/18), independently
re-run by the checker with the same result. Known remaining debt (checker F3,
S2): teacher assigned-scope is unproven on this install (fixture teacher's
scope is 'all'; no assignments exist) — a staging-fixture item for Wave 1B
prep. Production untouched throughout; per-file owner approval still gates
Wave 1C.
