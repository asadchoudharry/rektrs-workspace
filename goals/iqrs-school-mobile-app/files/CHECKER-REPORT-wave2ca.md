# CHECKER REPORT — Wave 2C-A API amendment (spot-gate)

**Checked:** 2026-11-07 (evening PKT) · **Checker:** independent checker lane (built neither the amendment nor its battery; did not write the diagnosis addendum)
**Scope:** the two additive endpoints live on STAGING — `POST /api/familydocs/fileOpen` (NEW controller, G-2 / D-W2-4a) and `POST /api/staffsync/visitorSave` (G-1, online half of API-71) — plus the battery that claims to prove them.

## Overall verdict: **PASS-WITH-NOTES**

**The Familydocs + visitorSave contracts are PROVEN SAFE for the app wiring lane.** Every ownership, publication, idempotency and refusal behaviour in the build report was reproduced by the checker's own independent probes (44/44 pass, sharing no code with the battery), and the battery itself reproduces at 47/0/0. The two notes below are an evidence-form note (item 5) and a minor hardening observation (item 3) — neither blocks wiring.

---

## Item 1 — Battery reproduction — **PASS**

The checker re-ran `test-wave2ca-api-staging.sh` itself, credentials via environment only:

```
RESULT: PASS=47 FAIL=0 SKIP=0   (script exit 0)
```

Identical to the diagnosis lane's final counts. The run history (35/4/1 → 46/1/0 → 47/0/0) and the addendum's three battery-side root causes (hardcoded section_id 33 vs the real Diamond section 13; fee-master id read off fee lines instead of the group; replay count scoped by name instead of the run's own visitor_id) are consistent with everything the checker's own probes observed independently — notably, the checker's fixture used section 13 for Seven–Diamond and assigned 15-student rosters without incident, and read `student_fees_master_id` at group level from a live `feeStatement`. No endpoint misbehaviour was observed in any run.

## Item 2 — Familydocs ownership (checker's own calls) — **PASS**

The checker built its **own** exam fixture through the staff API (group "Checker W2CA Spot Group …", exam, subject, both sections assigned, marks entered) and probed the family door directly:

- **Unpublished exam** → `file:null` with the exact publication reason `"Results for this exam have not been published yet."` — nothing leaks early.
- **After publish**, the parent fixture reads its own child's card: `content_base64` decodes to real PDF bytes (`%PDF` header, trailing `%%EOF`, declared `size` == decoded length, filename `report-card-<exam>-3699.pdf`, `published:true` on the record).
- **Student session** reads its **own** card (real PDF); the same session requesting foreign student 2397 is refused identically to the parent.
- **Foreign vs nonexistent are indistinguishable** for report_card: parent → student 2397 and parent → student 999999 both answer `file:null` with the **byte-identical** reason `"This report card is not available for your account."` and identical record key sets — ownership is checked before any document lookup, so existence never leaks.
- **Staff token at the family door → HTTP 401**; no-token → HTTP 401 with the vendor's `status:401` JSON; unknown kind → `file:null` + `"Unknown document kind."`; own child + nonexistent exam → `file:null` + `"Exam not found."`.

## Item 3 — fee_receipt — **PASS** (with Note 2)

- The checker's own Rs 100 `feeCollect` on the fixture child's master → the parent and the student each read a real PDF receipt (filename `fee-receipt-<invoice>-<sub>.pdf`, size field == decoded length).
- Bogus invoice 999999 → `file:null` + `"Receipt not found."`; real invoice + wrong entry id → `file:null` + `"That payment entry is not on this receipt."`.
- **Stronger than the battery:** the checker created a real, labelled deposit on **another student (2667)** and had the fixture parent request that receipt — refused `file:null` + `"This receipt is not available for your account."`. The deposit-chain ownership derivation (deposit → master → student_session → student) is therefore proven against an *existing foreign* record, not only against nonexistent ids.

> **Note 2 (minor, not a wiring blocker):** for `fee_receipt`, the reason *text* differs between a nonexistent invoice (`"Receipt not found."`) and an existing-but-foreign one (the ownership string). No document, owner identity, amount or any record content leaks either way, and invoice ids are sequential integers (existence is enumerable regardless), so the practical exposure is nil — but `report_card` makes no such distinction, and a uniform reason would be the tidier end state. Recorded for the overhaul flaw register as a hardening nicety; the current texts are B13's verbatim reasons, mirrored deliberately.

## Item 4 — visitorSave (checker's own calls) — **PASS**

- Own registration ("Checker W2CA Visitor", meeting the fixture child) returns `status:1` with a stored `visitor_id`, and the response record echoes the stored fields exactly as the local master's code composes them (`meeting_with: "student"`, `student_session_id: 3699`, contact from `phone`).
- The row **reads back on today's register** (`staffapi/visitorList`) — exactly one row for that visitor_id, fields matching. The write is proven, not just answered.
- **Replay** of the same `client_txn_id` returns the **same** `visitor_id`; the register still holds exactly one row for it.
- **Limited staff 115** (role 8, no `front_office / visitor_book / add`) refused: `status:0` + `"You do not have permission to register visitors"`. Three further exact-string refusals confirmed: missing `client_txn_id` (`"client_txn_id required"`), missing purpose (`"name, phone and purpose are required"`), nonexistent meet-staff (`"Staff member not found"`).

## Item 5 — Deployed files vs local masters — **PASS-WITH-NOTES** (evidence form)

Local masters verified on disk by the checker: Familydocs.php **26,322 B** md5 `3884308c…`, Staffsync.php **151,515 B** md5 `ecc33f60…`, Staffapi.php **570,998 B** md5 `5a9be05a…` — all exactly as the build report states; Staffapi's local master predates the swap window and is untouched by this wave, and every 2A-era Staffapi behaviour the checker exercised (catalogue, exam chain, roster shape, `feeStatement`'s group-level master id, publish) matches the 2A master.

> **Note 1 (evidence form):** PHP source is not HTTP-readable and this lane has no browser/File Manager route, so the *deployed* byte sizes cannot be re-read directly from here; they rest on the recorded swap (§6 manifest executed by the coordinator's browser lane: preflight Staffsync 144,420 B / Familydocs absent → postflight 151,515 B / 26,322 B). What the checker *can* establish independently is behavioural identity, and it is extensive: **thirteen exact refusal/answer strings** across the two controllers match the local masters byte-for-byte, as do the payload shapes, the `published:true` flag, both filename patterns and the idempotency semantics. Any materially different deployed file would have had to reproduce all of that by coincidence. Accepted as proven for the wiring lane; a direct size re-read can ride the next File Manager visit for the record.

## Item 6 — Battery credential hygiene — **PASS**

Grep of `test-wave2ca-api-staging.sh` for every fixture password value: **zero matches**. No `*_PASSWORD=` literal assignments exist in the file; the script refuses to run when any of the five env vars is unset (observed in its guard before any network call). The §5 warning about the *older* batteries' mangled on-disk defaults stands as a separate coordinator item — it does not touch this battery.

---

## Fixtures the checker left on staging (all clearly named)

- Exam group/exam "Checker W2CA Spot Group …" / "Checker W2CA Spot Monthly" (published; marks for the fixture child and one Four–Daffodils student).
- Two Rs 100 deposits described "Checker W2CA spot-gate collection" (fixture child 3699) and "Checker W2CA spot-gate FOREIGN receipt fixture (student 2667)".
- One register row "Checker W2CA Visitor".

Production was never contacted.
