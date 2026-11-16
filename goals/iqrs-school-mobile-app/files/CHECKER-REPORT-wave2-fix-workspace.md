# CHECKER REPORT — IQRS Workspace v2.15 (Wave 2 fix build)

**Checked:** 2026-11-07 · **Checker:** independent lane (did not build v2.15)
**Artefact:** `IQRS-Workspace-App-v2.15.apk` — 1,700,425 B, sha256 `5e1feda46431bc09260062c2bc5165d22ff1799db6d25393bd54a5023767a116` (re-measured on disk, matches the build report), versionCode 28 / versionName 2.15, package `pk.edu.iqrs.admin`
**Sources:** BUILD-REPORT-wave2-fix-workspace.md; BUILD-REPORT-wave2c-fix.md §4 (defect spec); CHECKER-REPORT-wave2b.md; tree `~/workspace/iqrs-app-v2/`; server masters `~/workspace/iqrs-api/staff-ext/`

## Overall verdict: PASS-WITH-NOTES — v2.15 is CLEARED for the device gate

No S1, no S2 against this build. Every claim in the build report was re-derived from the code, the shipped dex, or my own live staging calls. The two notes are evidence-form observations (§4, §6), not defects. On the performance item I give **code-level clearance only**: the one proven defect is fixed in the shipped code; whether the owner's phone now *feels* fast is the owner's device re-proof, which remains owed before the 2D production swaps — exactly as the build report states.

---

## 1. The four writes — PASS (verified live, with my own calls)

**Server contract (read from Staffsync.php, not from the report):** all four endpoints open with `w2_sync_begin`, which refuses any call without `client_txn_id` and claims the id through `api_sync_log` (`sync_claim` returns the stored answer flagged `duplicate: true` on a replay). `w2_finance_save` requires a valid `head_id`, non-empty `name`, a valid `date`, numeric `amount` ≥ 0 (optional `invoice_no`/`note`/`id`). `inventoryIssue` requires an existing `item_id`, `issue_type` ∈ {staff, student}, `issue_to` = the member's own id validated against the staff/students tables, `quantity` > 0 and ≤ the vendor-computed availability. `inventoryReturn` takes `issue_id` + optional `return_date` — **no quantity exists in its contract**.

**Shipped code (read in the tree):** `SyncPayloads.endpointFor` routes the four kinds to `staffsync/…`; the builders emit exactly the contract fields on a `client_txn_id` base (optionals only when non-empty), `inventoryIssue` sends `issue_type`/`issue_to` in the server's semantics with **no `issue_to_id` anywhere**, `inventoryReturn` sends **no quantity**. Both activities mint via `sender.mintTxnId()` → `OutboxEngine.newTxnId()` (a UUID — the same established shape every other saved write uses; `enqueue` refuses a payload whose `client_txn_id` is missing) and enqueue through the existing "Waiting to send" outbox with the same dismiss/toast/reload-after-1,200 ms pattern as sibling flows. The two new payload tests exist and pin this (`Wave2BPayloadsTest:123,147`, including `assertFalse(iss.has("issue_to_id"))`).

**My own live battery (staging, staff fixture 113, UUID txn ids, app-shaped bodies) — 17/17 PASS:**

| Write | Landed | Read-back (app's own read endpoints) | Replay (raw answer inspected) |
|---|---|---|---|
| `staffsync/incomeSave` | status 1, id **11**, amount 55.5 | `staffapi/incomeList`: "W2F-CHECK Income Verify …" exactly once, amount 55.5 | stored answer returned with `"duplicate":true`, same id 11; list still one row |
| `staffsync/expenseSave` | status 1, id **11**, amount 66.25 | `staffapi/expenseList`: my row exactly once | `"duplicate":true`, same id; still one row |
| `staffsync/inventoryIssue` (item 2 → staff 114, qty 1) | status 1, id **11**, `available_after` 14 | `staffapi/itemIssueList` (outstanding): row present, `issue_type=staff`, `issue_to=114` | `"duplicate":true`, same id, `available_after` still 14 (a re-issue would have answered 13 under a new id) |
| `staffsync/inventoryReturn` (issue 11) | status 1 | row no longer outstanding; `itemCatalog` item 2 final state `available_quantity` 15, `issued_quantity` 0 — the pre-battery state | `"duplicate":true`; state unchanged |

The four writes are live-functional end to end. My fixtures remain on staging, clearly named (income id 11, expense id 11, item-issue id 11 — issued and returned).

## 2. SRC-ROUTE-LIVE — PASS (gate re-run live by me)

I ran `tools/contract_check.py` in its live form myself: dummy-login and 401 probes pass, then **200/200 source route strings exist on staging — CONTRACT GATE: PASSED**, and the manifest was rewritten from *my* probes (probed_at 2026-11-07T18:35:16Z, base `https://staging.iqrs.edu.pk/api/`). The manifest refresh is honest: it is the tool's designed refresh path, the base is staging, and the four `staffsync/…` routes are present with `exists: true` (HTTP 401 = the auth layer refusing an unauthenticated probe, i.e. the route exists). The four dead `staffapi/…` strings no longer appear anywhere in the sources (grep: none). This is the first fully green route run in the programme, and it is green on my probes, not the builder's.

## 3. Question Bank crash + null audit — PASS

- **Shipped render path cannot NPE on a null subject.** `OnlineAuthoringData.Question.caption()` is null-safe by construction (`subject == null || subject.isEmpty() ? "" : " · " + subject`), and `StaffQuestionBankActivity` line 91 renders `q.caption()` — no dereference of `q.subject` remains anywhere in the UI tree.
- **The regression test is genuine.** `Wave2BMapperTest.questionBankCaptionSurvivesNullSubject` loads the real capture `fixtures/w2b_question_bank.json` (staging rows whose `subject` is JSON null — I inspected the fixture), asserts the mapped subject **is** null (the crash precondition), and asserts `caption()` returns exactly the type words. Against the old inline expression (`q.subject.isEmpty()`) the same rows throw NPE by Java semantics — the fail-before holds by construction, with the precondition asserted, not assumed. The companion test pins the named-subject caption (`One answer · Mathematics`). The field's nullability is real: `OnlineAuthoringMapper` reads it via the nullable accessor `W2Json.ns`.
- **The other five claimed fixes are all present in source:** Transport `RoutePoint.pickupTime` (null-or-empty guard, StaffTransportActivity:83), `RouteVehicle.driverContact` (:110), `Vehicle.driverContact` (:147 — the one that printed the literal "null"), Inventory `IssueEntry.returnDate` (:187), Certificates `IdCard.templateName` (`!= null &&` guard, StaffCertificatesActivity:230).
- **My independent sweep:** I extracted every `.isEmpty()/.equals()/.length()/.trim()` dereference on fields whose names match the nullable-accessor key set (57 sites; 45 not guarded within their own statement) and resolved each receiver's provenance positionally through its mapper. **Every one of the 45 resolves to a never-null source** — a `Json.s` feed (exam grade/division, SubjectMark grade/note, leave reasons ×3 mappers, fee-line due dates ×3 mappers, visitor times, profile transport fields, library/homework/timetable/lesson-plan subjects, enquiry notes, behaviour `created_at`, documents `created_at`, offline-payment date, receipt payment mode), a model-side normalisation (`SyncPayloads.Mark.remark`), or an `optString`/guarded expression (`StaffSession.designation`). No remaining unguarded dereference of a nullable-fed field was found.

## 4. Performance claim — PASS (claims match the code), one observation

- **Cache arithmetic verified from the shipped source.** `PhotoLoader.sizeOf()` returns `getByteCount()/1024` (KB); capacity is now an explicit `MEMORY_KB = 8 * 1024`. One design-size avatar is 288×288 ARGB_8888 = 331,776 B = **324 KB**, so the previous capacity of 64 (KB) could never retain even one bitmap — every `put` self-evicted and the memory tier never hit. That defect is real and is fixed: 8,192 KB ≈ 25 design-size avatars.
- **Observation (not a defect):** the decode sampler keeps the source's min side ≥ 288 px, so an individual bitmap can exceed 324 KB (up to ~4× for near-threshold sources); "≈25 avatars" is the design-point figure the report and code comment both state ("roughly"), and the cache remains functional in the worst case. The claim as written is honest.
- **The "refuted" items are as described.** `StaffRepository` runs network + mapping inside `io.execute(...)` on the injected 3-thread IO pool (`IqrsApp` constructs it so) and posts callbacks to the main handler — no main-thread network/JSON path exists to remove. The directory is server-side paged (`staffDirectory` slices by page/page_size; the app passes page numbers) and staff-only; no screen renders the 1,662-student enrolment — rosters are per class+section. I did not re-prove host latency (not asked); the report's framing — perceived slowness tracks measured shared-host latency, device re-proof decides — is consistent with everything in the code.

## 5. Regression sweep — PASS (all re-run by me)

- **Unit suite:** `tools/run_tests.sh` → **OK (326 tests)** — the claimed count exactly (322 baseline + 2 payload + 2 caption tests).
- **Checker harness** (`run_checker.sh --apk-workspace` on tree + shipped APK) → **0 failed check groups**: source checks all pass (incl. SRC-NOSPACER-IN-ROW), banned-strings gate PASS (language lockdown intact), SRC-ROUTE-LIVE manifest form 200/200, metadata gate PASS, APK check PASSED.
- **Metadata from the harness's own gate:** package `pk.edu.iqrs.admin`, versionCode 28, versionName 2.15, minSdk 26, targetSdk 34, CAMERA + INTERNET, signature verifies.
- **Signer:** the APK's certificate SHA-256 is `F7:87:4C:3F:69:E4:EE:1C:FB:F5:4E:F3:61:6B:2D:DE:92:04:23:BA:A1:6F:70:D2:57:24:77:1F:3B:DA:46:2E` — identical to every previous build (`f7874c3f…462e`).
- **Staging target proven in the shipped dex:** `ApiConfig.baseUrl()` disassembles to `const-string "https://staging.iqrs.edu.pk/api/"` + return (dexdump on the shipped `classes.dex`).
- **Connect untouched:** `IQRS-Connect-App-v2.11.apk` re-hashed — 1,614,409 B, sha256 `8faef355ec0b39b0b95580a50f77a1580ffda80a10fc483cadb0949c180ca6b2`, byte-identical to its delivery state.
- **Submit-disable intact:** both rewired save handlers keep the established pattern (`if (busy) return; busy = true; W2Ui.busy(...)`, reset on both paths; a failed finance enqueue now surfaces the generic error toast instead of swallowing).

## 6. Notes (evidence form only — neither blocks the gate)

1. §4's avatar-size figure is a design-point approximation, as its own wording states ("roughly 25"); worst-case decodes are larger, the fixed cache still functions.
2. In §1, the mid-round-trip availability evidence rests on the server's own `available_after` answers (14 on issue, 14 again on the flagged replay — a re-issue would have answered 13 under a new record id), closed by the catalog's final state (15 available / 0 issued) read directly after the return. The chain is complete; it is recorded here in its exact form.

## Clearance statement

**Workspace v2.15 is cleared for the §6.4 device gate** alongside Connect v2.11. Work items 1 and 2 are proven at code + live-service level; work item 3 is cleared at code level (proven defect fixed, refutations accurate), and its device re-proof — on the owner's phone, on this build — remains the hard gate before any 2D production swap is proposed, per the programme sequence.
