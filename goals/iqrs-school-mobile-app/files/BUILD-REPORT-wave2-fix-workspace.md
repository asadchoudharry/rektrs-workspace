# BUILD REPORT — IQRS Workspace v2.15 (Wave 2 fix release)

**Built:** 2026-11-07 · **App:** IQRS Workspace, `pk.edu.iqrs.admin`, staging-pointing
**Version:** versionName **2.15** / versionCode **28** (was 2.14 / 27)
**APK:** `~/workspace/your_files/iqrs-app/IQRS-Workspace-App-v2.15.apk`
**Size:** 1,700,425 bytes · **SHA-256:** `5e1feda46431bc09260062c2bc5165d22ff1799db6d25393bd54a5023767a116`
**Signer:** cert SHA-256 `f7874c3f69e4ee1cfbf54ef3616b2dde920423baa16f70d25724771f3bda462e` — identical to every previous build.
**Scope honoured:** production never touched; the Connect app was not rebuilt; no server file changed (the Staffsync endpoints already existed on staging from Wave 2A).

## Gates — all green

| Gate | Result |
|---|---|
| Unit suite (`tools/run_tests.sh`) | **OK (326 tests)** — baseline 322 + 4 new |
| Contract gate, live (`tools/contract_check.py`) | **PASSED** — SRC-ROUTE-LIVE probed 200 route strings from the sources: **200/200 exist on staging**; manifest refreshed |
| Checker harness, tree + shipped APK (`run_checker.sh --apk-workspace`) | **0 failed check groups** — source checks ALL PASS (incl. SRC-NOSPACER-IN-ROW, 899 sites), banned-strings gate PASS, SRC-ROUTE-LIVE (manifest form) 200/200, metadata gate PASS (package / code 28 / name 2.15 / minSdk 26 / targetSdk 34 / CAMERA+INTERNET / signature verifies), APK check PASSED |

One harness iteration note: the first run failed the banned-strings group on a single word — my own code comment in StaffFinanceActivity used the word "queue", which the language-lockdown lint bans anywhere in the sources. The comment was reworded ("saved-write machinery"), the APK rebuilt, and the harness re-run came back **0 failed groups**. No user-visible string was involved.

---

## Work Item 1 — the four dead writes (Finance / Inventory) — FIXED + LIVE-PROVEN

### Evidence
The app called `staffapi/incomeSave`, `staffapi/expenseSave`, `staffapi/inventoryIssue`, `staffapi/inventoryReturn`. None of these routes exist (the Wave 2C checker's SRC-ROUTE-LIVE guard proved all four 404; Finance add-income/expense and Inventory issue/return could never have worked). The real endpoints are the Staffsync twins, read from the server code in `~/workspace/iqrs-api/staff-ext/Staffsync.php` before any app code was written:

- `incomeSave` / `expenseSave` → require `client_txn_id`, a valid `head_id`, non-empty `name`, a valid `date`, numeric `amount` ≥ 0; optional `invoice_no`, `note`, `id`.
- `inventoryIssue` → requires `client_txn_id`, an existing `item_id`, `issue_type` ∈ {staff, student}, `issue_to` = the member's own id (validated against the staff/students tables), `quantity` > 0 and ≤ the service-computed availability.
- `inventoryReturn` → requires `client_txn_id`, an existing outstanding `issue_id`; optional `return_date`.

Two app-side defects beyond the dead routes: the app sent **no** `client_txn_id` at all, and the inventory-issue form sent the fields **transposed** — `issue_to` carried the type string ("staff"/"student") and a non-contract `issue_to_id` carried the member id. The return form also sent a `quantity` the contract does not take.

### Changes (app only)
- `model/OutboxItem.java` — four new saved-write kinds: `income_save`, `expense_save`, `inventory_issue`, `inventory_return`, with a dated comment recording why they exist.
- `api/SyncPayloads.java` — `endpointFor` routes the four kinds to `staffsync/incomeSave|expenseSave|inventoryIssue|inventoryReturn`; four new builders (`incomeSave`, `expenseSave`, `inventoryIssue`, `inventoryReturn`) emit exactly the server contract's fields, in the file's established style (base `client_txn_id`, optionals only when non-empty).
- `ui/staff/StaffFinanceActivity.java` — the add-income/expense save handler no longer posts to the dead route; it mints a transaction id (`sender.mintTxnId()`, the same shape every other saved write uses), builds the payload via `SyncPayloads`, and enqueues it, then dismisses, toasts "Saved", and reloads after the established 1,200 ms beat. A failed enqueue now surfaces the generic error toast (previously a bad amount was swallowed silently).
- `ui/staff/StaffInventoryActivity.java` — issue form and return action rewired the same way; the issue payload now sends `issue_type` = the segmented choice and `issue_to` = the member id; the return payload drops the non-contract `quantity`.

**Routing decision (the one judgment call in this lane):** all four writes ride the existing offline "Waiting to send" outbox machinery. That is how the codebase's Staffsync form saves predominantly flow (18 of the 25 Staffsync write endpoints are outbox kinds with `SyncPayloads` builders — tasks, enquiries, visitors, syllabus are the exact shape). The direct-post minority (library issue/return, marks save, behaviour, lesson plans, transport assign) are flows whose screens consume a server-computed answer inline; none of these four screens do — each only toasts and reloads. A server refusal (e.g. quantity above availability) now lands in the Waiting screen's "Needs attention" state with the service's own words, exactly like a refused fee collection. One tension recorded honestly: a Wave 1B comment in `OutboxItem` says money-state changes were deliberately not made kinds *in that wave's desk scope*; fee collection — a money record of the same class as an income/expense entry — has been a kind since Phase B, and these four follow it.

### Live proof (staging, fixture staff 113 — Super Admin; battery 22/22 PASS)
Each write was sent **exactly as the fixed app sends it** (same endpoint, same field names, minted `client_txn_id`), then read back through the app's own Staffapi read endpoints, then replayed with the identical `client_txn_id`:

| Write | Landed | Read-back | Replay |
|---|---|---|---|
| `staffsync/incomeSave` | status 1, record id **10**, amount 123.5 | `staffapi/incomeList`: "W2F Income Fixture" exactly once, amount 123.5 | stored response returned with `duplicate: true`, same id; list still one row |
| `staffsync/expenseSave` | status 1, record id **10**, amount 77.25 | `staffapi/expenseList`: "W2F Expense Fixture" exactly once | `duplicate: true`, same id; still one row |
| `staffsync/inventoryIssue` | status 1, record id **10**, `available_after` 14 (was 15) | `staffapi/itemIssueList`: row outstanding, type staff, issued to 114; `staffapi/itemCatalog`: availability 15 → 14 | `duplicate: true`, same id; still one issue row, availability unchanged |
| `staffsync/inventoryReturn` | status 1, record id **10** | issue row no longer outstanding; catalog availability restored 14 → 15 | `duplicate: true`; state unchanged |

**W2F fixtures left on staging (clearly named, kept):** income record id 10 "W2F Income Fixture" (head 14 "W2A Other Income", invoice `W2F-INV-1`), expense record id 10 "W2F Expense Fixture" (head 18 "W2A Other Expense"), item-issue record id 10 on "W2A Probe Item" (item 2, issued to staff 114 and returned — the full round trip is visible in the issue list). Transaction ids used: `w2f-inc-…`, `w2f-exp-…`, `w2f-iss-…`, `w2f-ret-…` (one timestamped set, 2026-11-07).

### Tests added
`Wave2BPayloadsTest`: `financePayloadsRouteToTheSavedWriteEndpoints` (contract fields, empty invoice omitted, both routes), `inventoryPayloadsUseTheServiceFieldNames` (pins `issue_type`/`issue_to` semantics, asserts **no** `issue_to_id`, asserts the return carries **no** `quantity`, both routes).

---

## Work Item 2 — Question Bank crash + tree-wide null audit — FIXED

### Evidence
Owner's bug-report screenshot (2026-11-07): `NullPointerException … String.isEmpty() on a null object reference at StaffQuestionBankActivity.render(StaffQuestionBankActivity.java:91)`, via the repository callback. The genuine captured fixture `fixtures/w2b_question_bank.json` carries `"subject": null` on **every** row — the mapper (`OnlineAuthoringMapper`) reads the subject through the nullable accessor, so the field is legitimately null and the caption expression `q.subject.isEmpty()` threw on exactly the data the service returns.

### Fix
- `model/OnlineAuthoringData.java` — `Question.caption()` added beside `typeWords()`: type words plus the subject only when one is named (null-safe by construction, and unit-testable — the `PublishGate`/`MarksEntryRules` pattern).
- `StaffQuestionBankActivity` — the render line now calls `q.caption()`.

### Tree-wide audit (method + full result)
The nullable set = every model String field fed by the nullable JSON accessors (`W2Json.ns` / `Json.sn` — 46 assignments across 13 mappers). Every dereference site (`.isEmpty()`, `.equals()`, `.length()`, `.trim()`, concatenation) of those fields was checked, and the audit was re-run after the fixes, including an independent sweep of all `.isEmpty()` receivers in the UI tree plus spot-checks that the remaining receivers' mappers use zero nullable accessors (`StudentCardMapper`, `NoticesMapper`: 0). **Six unguarded instances existed; all six are fixed:**

| # | Site | Field (nullable source) | Fix |
|---|---|---|---|
| 1 | `StaffQuestionBankActivity` (the crash) | `Question.subject` | `caption()` (above) |
| 2 | `StaffTransportActivity` point row | `RoutePoint.pickupTime` | null-or-empty guard before the time is appended |
| 3 | `StaffTransportActivity` route vehicles | `RouteVehicle.driverContact` | null-or-empty guard |
| 4 | `StaffTransportActivity` vehicle list | `Vehicle.driverContact` | guarded — previously printed the literal text "null" beside a driver's name |
| 5 | `StaffInventoryActivity` issue row | `IssueEntry.returnDate` | null-or-empty guard |
| 6 | `StaffCertificatesActivity` ID-card sheet | `IdCard.templateName` | `!= null &&` guard |

Everything else in the nullable set was verified already-guarded (exam result grade/division/remarks, payroll payment mode/date, own-attendance in/out times, fee-line due dates, library fine note, report reason, W2Ui opened-file fields) or never dereferenced / fed by the never-null accessor — the full per-site list was worked through during the audit; no further instances exist.

### Regression tests added (`Wave2BMapperTest`)
- `questionBankCaptionSurvivesNullSubject` — parses the **genuine** capture, asserts the mapped subject really is null (the crash precondition) and that `caption()` returns exactly the type words. The old inline expression throws NPE on these same rows, so this test fails against the old logic by construction and passes now.
- `questionBankCaptionAppendsNamedSubject` — a question with a subject captions as `One answer · Mathematics`.

---

## Work Item 3 — performance / stability pass

### Proven defect — FIXED: the photo memory cache could never hold a photo
`ui/components/PhotoLoader.java` sized its `LruCache` at **64** while `sizeOf()` reports each bitmap's size in **KB**. One decoded avatar is 288×288 ARGB_8888 = 331,776 B ≈ **324 KB** — larger than the whole cache — so every `put` evicted itself and the memory tier **never hit**: every avatar bind on every list re-decoded from disk or re-fetched over the network on the 2-thread IO pool, despite the class's own "decoded near avatar size" design. On photo-heavy screens (staff directory, student rosters) this is a continuous decode/fetch churn tax on exactly the screens the owner called slow.
**Fix:** capacity is now an explicit `MEMORY_KB = 8 * 1024` (8 MB ≈ 25 full-size avatars — a screenful of rows with headroom), with the arithmetic recorded in a comment so the unit mismatch cannot silently recur. Decode itself was already sound (off-thread, bounds-sampled to 288 px) and is unchanged.

### Stability — the closes are partly this release's Work Item 2
The one crash mechanism actually evidenced (the owner's own bug report) is the null-subject NPE family; all six unguarded instances are fixed. No other crash mechanism could be evidenced from the code.

### Examined and REFUTED by evidence — no change made
- **Main-thread network/JSON:** `StaffRepository` runs all network + mapping on its IO executor and posts callbacks to the main thread; `postAction` follows the same path. There is no main-thread network or parse work to remove.
- **Payload weight:** measured live on staging this session — dashboard 210 B, income/expense lists < 400 B, question bank 4.0 KB, item catalog 5.3 KB, staff directory page 11 KB; every call ~0.9–2.2 s of *server/shared-host latency*, not transfer or parse cost. Nothing in the app can shrink the host's response time; the cache-first load idiom already hides it behind cached content.
- **Marks rosters:** per class+section (≤ ~60 rows); the entry screen's text watcher only updates the problem line and sticky bar. No full-list rebuild per keystroke exists.
- **Student search:** the service caps results (`limit(50)`) and the app requires 2 characters before asking. The "1,662 students" figure is the school's total enrolment, not a rendered list — no screen renders it; rosters are per class+section and the directory is staff-only (110 members, paged 20 at a time).
- **Directory full rebuilds:** the staff directory re-renders accumulated rows on each repository emission (cache-then-fresh → two builds per page; ≤ 110 avatar rows total). The mechanism is real but the scale is small, and after the PhotoLoader fix repeat binds are memory hits; a diffing rewrite was **not** attempted — changing it on this evidence would be redesigning on a guess.

**Honest limit:** the owner's "lag / slow / sometimes closes" is only partly explained by what code + staging can prove (photo churn + the NPE family). The remaining perceived slowness is consistent with the measured ~1 s+ per-call staging/shared-host latency. Device re-proof on this build is the deciding evidence and is still owed before the 2D production swaps.

---

## What did NOT change
- No server file (Staffapi/Staffsync) was modified — the endpoints were already live from Wave 2A; the route manifest was regenerated by the contract tool, which is its normal refresh path.
- Language lockdown intact (banned-strings gate green); submit-disable pattern untouched; the Waiting screen shows the four new kinds by their item summaries with discard-only rows, like the task/enquiry kinds.
- Lesson/topic *creation* remains unbuilt (the syllabus read still lacks `subject_group_class_sections_id`) — unchanged from the Wave 2B report, still a future API amendment.

## Remaining sequence (unchanged)
Riders → this fix release was one of them → **device gate on the owner's phone (HARD, before 2D)** → 2D per-file production swaps with owner approval each.
