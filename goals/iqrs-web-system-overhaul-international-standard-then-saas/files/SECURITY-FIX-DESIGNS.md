# IQRS Web System Overhaul — Wave 1 Security Fix Designs

**Workstream:** CISO Office + Security Engineering
**Programme:** IQRS Web System Overhaul — international standard, then SaaS
**System in scope:** iqrs.edu.pk — Smart School 7.2 (CodeIgniter 3 + MySQL/MariaDB) on Hostinger shared hosting: vendor mobile API (`api/application/`), the web application (staff admin panel + student/parent portal, same database), and IQRS's own additive staff API (`staff-ext/`).
**Date:** 2026-11-07 · **Status:** Design for build. Nothing in this document has been applied anywhere.
**Companion documents:** `PROGRAMME-PLAN.md` (Wave 1 = §1A quick wins, §1B structural trio, §1C), `FLAW-REGISTER.md` (flaw IDs FL-009…FL-027 are used throughout as cross-references), `files/WEB-APP-AUDIT-AND-DESIGN.md` in the school-mobile-app goal (§1, §2, §4), and the Lane A code audit (`audit-lane-a-workflows.md`).

---

## 0. Ground rules, evidence base and shared building blocks

### 0.1 Ground rules (binding on every design below)

1. **Staging first, always.** Every change is built and proven on `staging.iqrs.edu.pk` (separate tree + separate database, per Wave 0). Production is untouched until the owner approves a staging-proven build. No design below requires a production change to *test* it.
2. **Design only in this document.** File/function names are cited so the build lane can implement without re-deriving the audit. No credentials, keys or passwords appear in this document; where a design touches a secret-bearing file it cites the file and line, never the value.
3. **No family lockout, no forced app update.** The Family mobile app and the staff app must keep working against the changed backend with **no app release**. Every contract change below is therefore either invisible to clients (same fields, same shapes) or uses response shapes the apps already handle (see §0.3).
4. **Reuse the proven local patterns.** IQRS's own staff extension (`staff-ext/Staffauth.php`, `Staffapi.php`, `Staffsync.php`) already demonstrates, on this exact stack and database: `password_verify()` against bcrypt, `bin2hex(random_bytes(32))` tokens, an extension-owned session table (`api_staff_sessions`), session-derived identity (`require_staff_session()`), scope intersection before any read/write, `client_txn_id` idempotency over `api_sync_log`, and transactions around batches. Wave 1 ports those patterns into the vendor family API instead of inventing new ones.
5. **Additive before destructive.** Schema changes are new columns/tables with safe defaults, or widening alters. No column is dropped, renamed or re-typed in Wave 1. Every step names its rollback.
6. **Both trees, same window.** The API tree and the web-application tree share one database and (in the vendor's layout) near-identical model classes (`User_model`, `Auth_model` concepts exist on both sides). Any change to credential or session semantics must land in **both trees in the same staging step** before its data-writing half is enabled — a hashed password written by one tree must be readable by the other tree's login on the same day. Sequencing in §1.5 and §8 exists precisely to enforce this.

### 0.2 Evidence base and its limits

Designs are grounded in the local, byte-identical copy of the production API tree at `~/workspace/iqrs-api/production/api/application/` (`Webservice.php` md5 matches production, per the audit) and in `~/workspace/iqrs-api/staff-ext/`. The **web application's own controllers and views are not present locally** (see §9 for the full list of what could not be determined and what staging-tree access is needed). Where a design depends on web-tree behaviour, it is written at the shared **model layer** — the layer both trees use — and carries an explicit staging-verification step.

Line numbers cite the local API tree as `file:line`.

### 0.3 Client-compatibility contract (referenced by every section)

The existing clients already handle exactly these shapes; Wave 1 stays inside them:

| Situation today | Shape today | Wave 1 rule |
|---|---|---|
| Login failure | HTTP 200, `{"status": 0, "message": "Invalid Username or Password"}` | Unchanged, including for throttled/locked attempts (different message text only) |
| Auth (token) failure | HTTP 401, `{"status": 401, "message": "Unauthorized."}` / `"Your session has been expired."` (from `Auth_model::auth()`) | Unchanged strings and codes; ownership denials reuse this family (§3.4) |
| Validation failure in form endpoints | HTTP 200, `{"status": "0", "error": {field: message}}` | Unchanged |
| Server failure today | HTML error page (the bug, §4) | Becomes HTTP 500, `{"status": 500, "message": "Internal server error."}` — strictly better for clients, which already treat non-JSON as failure |

### 0.4 Shared building blocks built once, used by several sections

| Block | Where it lives | Used by |
|---|---|---|
| `Credential_lib` — one password verify/hash implementation (§1.2) | `application/libraries/Credential_lib.php`, **identical file in both trees** | §1 (all login + write paths), §7.1 throttling timing defence |
| Identity context — `Auth_model::auth_context()` (§3.2) | `application/models/Auth_model.php` (API tree) | §3 guard, §5 token policy, §7.3 audit actor |
| `Audit_lib::record()` — fail-open audit writer (§7.3) | `application/libraries/Audit_lib.php` (API tree; web tree gets the same writer when its Wave 1 items land) | §1, §3, §6, §7 |
| Security regression suite — scripted curl checks against staging with fixture accounts (§0.5) | Programme QA assets, run at every wave gate | All sections' acceptance tests |

### 0.5 Fixtures assumed (Wave 0 deliverables)

Staging fixture set, created in Wave 0 and reused by every acceptance test below: two fixture families — Family A (parent + 2 children) and Family B (parent + 1 child) — each with a student login and a parent login on **both** the web portal and the API; one fixture staff account per role already retained (113/114) plus one Super Admin fixture for §7.4; one dormant fixture account that is never logged in during the test window (to prove dormant behaviour). Fixture passwords are known to the test lane only and never appear in documents.

---

## 1. (a) Password migration — FL-009, FL-022, FL-024

**Finding.** Student/parent passwords in `users.password` are plaintext and are compared inside SQL: `Auth_model::checkLogin()` (`models/Auth_model.php:245`, `where('password', $password)` in both the student branch at :254 and the parent branch at :283), `User_model::checkLogin()` (`models/User_model.php:50`) and `User_model::checkLoginParent()` (:66, password condition at :85). `User_model::checkOldPass()` (:190) repeats the pattern for the web change-credential flows. The bcrypt machinery already exists in the same codebase — `Enc_lib::passHashEnc()` = `password_hash(..., PASSWORD_DEFAULT)`, `Enc_lib::passHashDyc()` = `password_verify()` (`libraries/Enc_lib.php`) — and the staff side already uses it. The design below migrates the family side onto that same machinery **without locking anybody out and without an app update**.

### 1.1 Schema changes (additive, staging first)

Preflight (read-only, staging DB, before any alter):

```sql
SHOW CREATE TABLE users;                       -- record password column type/length, verification_code length
SELECT role, COUNT(*) FROM users GROUP BY role; -- expect student + parent only; report anything else
SELECT COUNT(*) FROM users WHERE password IS NULL OR password = '';
```

Migration (one script, idempotent, run on staging; production only on owner approval):

```sql
ALTER TABLE users
  ADD COLUMN password_scheme TINYINT NOT NULL DEFAULT 0,        -- 0 = legacy plaintext, 1 = password_hash
  ADD COLUMN password_changed_at DATETIME NULL,
  ADD COLUMN verification_code_expires_at DATETIME NULL;
-- Only if preflight shows password shorter than 255:
ALTER TABLE users MODIFY password VARCHAR(255) NOT NULL;
-- Only if preflight shows verification_code shorter than 64:
ALTER TABLE users MODIFY verification_code VARCHAR(255) NULL;
```

Why a scheme column instead of sniffing the value: `password_get_info()` sniffing misclassifies edge cases (a plaintext password that happens to look like a hash prefix; a future algorithm change). The scheme flag is unambiguous, index-free, and — critically — **safe for every other reader of the column**: unpatched code that reads `users.password` and compares it as plaintext keeps working for `scheme = 0` rows, because those rows still hold plaintext until their owner logs in. The extra columns are ignored by all existing explicit SELECT lists; the `users.*` wildcard sites are handled in §2 (they gain two non-secret fields, and §2 narrows them anyway).

One preflight classification is required: if the staging scan finds any `users` row whose value already parses as a recognised hash (`password_get_info()['algo']` non-empty), set that row's `password_scheme = 1` in the migration script and **do not** rehash it. (Expected count is zero; the step exists so the migration is correct even if some admin-side path already hashed a few rows.)

### 1.2 `Credential_lib` — the single verify/hash choke point

New file `application/libraries/Credential_lib.php`, byte-identical in the API tree and the web tree:

- `is_hash($stored)` — `password_get_info()` recognition, used only by preflight/reporting, never by login.
- `verify($plain, $stored, $scheme)` — if `$scheme === 1`: `password_verify($plain, $stored)`. If `$scheme === 0`: `hash_equals((string)$stored, (string)$plain)` (constant-time; never `==`). This is the **dual-read** core.
- `hash($plain)` — delegates to the existing `Enc_lib::passHashEnc()` so the family side uses the identical algorithm/cost as the staff side.
- `verify_and_upgrade($users_id, $plain, $stored, $scheme)` — verifies; on success, if `$scheme === 0` **or** `password_needs_rehash($stored, PASSWORD_DEFAULT)`, performs the rehash-and-store of §1.3 and returns the verify result regardless of whether the upgrade write succeeded.
- `set_password($users_id, $plain)` — the **only** sanctioned password-write path (§1.4): hashes, sets `password_scheme = 1`, `password_changed_at = NOW()`, clears `verification_code` + `verification_code_expires_at`, deletes all `users_authentication` rows for the user (session revocation on credential change, §5.5), and writes an audit row (§7.3). Implemented as a thin wrapper in the library calling `User_model` primitives, so both trees share behaviour.
- `dummy_verify($plain)` — `password_verify()` against one fixed, library-held dummy hash; called when a username does not resolve, so "no such account" costs the same time as "wrong password" (blunts timing enumeration; complements §7.1).

### 1.3 The login refactor — dual-read, hash-on-next-successful-login

The structural change in all three login functions is the same: **the password leaves the SQL `WHERE` clause; identity resolution and credential verification become two separate steps.**

`Auth_model::checkLogin($username, $password)` (`models/Auth_model.php:245-307`) — the API login used by the Family app via `Auth::login()` → `Auth_model::login()`:

1. Keep both existing identity branches and their settings-driven alternates (student branch: `username` OR `students.admission_no` / `students.mobileno` / `students.email` per `student_login` settings; parent branch: `username` OR `students.guardian_phone` / `students.guardian_email` per `parent_login` settings) — but select candidate rows **without** the password condition, and select `users.password, users.password_scheme` for server-side use only.
2. Because the password condition no longer disambiguates, a branch may return more than one candidate (e.g. a shared guardian phone). Fetch up to 5 candidates per branch, student branch first (preserving today's precedence), and return the **first candidate for which `Credential_lib::verify()` succeeds**. If none verifies, fall through to the parent branch exactly as today; if none verifies anywhere, return `false` — the caller already maps that to the unchanged `Invalid Username or Password` response.
3. On a successful verify of a `scheme = 0` row, **rehash-and-store immediately, inside the same request**: `UPDATE users SET password = <hash>, password_scheme = 1, password_changed_at = NOW() WHERE id = ? AND password_scheme = 0`. The `AND password_scheme = 0` clause makes concurrent logins race-safe (second writer updates zero rows, harmless). If this write fails, the login still succeeds and a `log_message('error', 'SEC rehash failed …')` + audit row records it — a storage hiccup must never become a lockout.
4. The returned row object must have `password` unset before it leaves the model (today's `login()` builds `session_data` field-by-field and never emits it — verified — but the unset makes that structural, not incidental; see also §2).

`User_model::checkLogin($data)` (:50) and `User_model::checkLoginParent($data)` (:66) — the web-portal-side model functions (no API controller calls `checkLogin()` locally; `Auth_model::login()` calls `checkLoginParent()` at `Auth_model.php:140` for the parent branch): apply the identical two-step pattern. `checkLoginParent()`'s wide `users.*` select is narrowed per §2 at the same time. `User_model::checkOldPass()` (:190) becomes a `Credential_lib::verify()` against the row fetched by `id` — this keeps the web change-username/change-password flows working for both schemes during and after migration.

**Why the Family app needs no update:** the request (`username`, `password`, `deviceToken` to `auth/login`) and both response shapes (success with `token` + `record`, failure with `status 0`) are byte-for-byte unchanged. The migration is entirely server-side. The same holds for the web portal login forms, whose field names and redirects do not change.

### 1.4 Password-write paths — complete inventory and treatment

Every path that can write `users.password` must end up calling `Credential_lib::set_password()` or hashing at the model choke point. Inventory from the local tree, plus the web-tree paths the audit/model surface proves exist:

| # | Write path | Evidence | Treatment |
|---|---|---|---|
| W1 | API forgot-password reset completion (web reset page saves the new password) | Reset link issued by `Webservice::forgot_password()` (:732); code validated by `User_model::getUserValidCode()/getParentUserValidCode()` (:358/:423); save via `User_model::saveNewPass()` (:214) | Token redesigned in §1.7; the save step calls `set_password()` (hash + scheme + session revocation). `saveNewPass()` itself is re-pointed to reject a raw `password` key unless it arrives through `set_password()` — a tripwire against future plaintext writes |
| W2 | Admin-set passwords: student admission/edit and parent creation in the web panel | Model choke points exist locally: `User_model::add()` (:19, insert-or-update on `users`), `User_model::addNewParent()` (:30) | **Hash at the model layer:** in `add()` (both trees), if the data array contains `password` and does not contain `password_scheme`, hash the value and set `password_scheme = 1` before the insert/update. Every present and future caller (admission, online admission, imports that use the model) is covered without finding each controller. Direct-SQL user creation that bypasses the model, if any exists in the web tree, is a §9 staging-grep item |
| W3 | Registration / online admission account creation | Web-tree only; the API has no enrolment path (Lane A §2.1) | Covered by W2's model-layer rule if it uses `User_model::add()`; staging grep (§9) must confirm or the controller is patched to call `set_password()` after creation |
| W4 | Change-password (new, Wave 1C per programme plan) | Does not exist today — zero `changePassword` hits in the tree (Lane A §3.4) | New endpoint `Webservice::changePassword()`: session auth (§3 identity) → user changes **own** credential only (target is the session's `users.id`; any body-supplied id is ignored) → `Credential_lib::verify()` on current password → policy: minimum 8 characters, not equal to username or admission number → `set_password()` (which revokes the user's *other* sessions; the current session is re-issued or kept by explicit re-insert — implementer's choice, must be tested) → audit row. Web portal change-password screen, when built in the web tree, calls the same library |
| W5 | Staff passwords | `staff` table, **separate from `users`** | **Confirm and leave alone.** `Staffauth.php`'s docblock records verification against the staging database (2026-11-06): staff log in by email against `staff.password` (varchar(250)) with `password_verify()` — already bcrypt via the web login's `Enc_lib::passHashDyc()`. No schema change, no code change. The only Wave 1 staff-credential actions are throttling (§7.1) and 2FA (§7.4) |
| W6 | Bulk/legacy imports creating `users` rows | Not present in the API tree | §9 staging grep on the web tree; anything found routes through W2's rule or is patched before the §1.5 flag flip |

### 1.5 Sequencing — the flag that makes lockout impossible

A config flag in `application/config/config.php` (both trees, same name): `$config['iqrs_password_hashing']` ∈ `off | dual-read | hash-on-login`. Default in shipped code: `dual-read`.

- **Step S0 — Preflight (staging):** §1.1 read-only checks; full export of the staging `users` table retained as the migration backup; coverage baseline query saved (`scheme` counts by role).
- **Step S1 — Schema + dual-read, both trees, flag = `dual-read`:** deploy §1.1 alters + `Credential_lib` + the three login refactors + W2 model-layer hashing for *new* writes. In this mode logins verify both schemes but **never rehash an existing plaintext row**. Run the full login regression (web + API, student + parent, correct + incorrect passwords). At the end of S1 the system is exactly as safe as today and provably not one login worse — this is the no-lockout proof point.
- **Step S2 — Flip flag = `hash-on-login`, both trees in the same staging session:** from this moment every successful login upgrades its own row (§1.3 step 3). New/changed passwords are always hashed (W2/W4/`set_password()` are not flag-gated — there is no mode in which a *new* password is stored plaintext).
- **Step S3 — Coverage watch:** weekly coverage report (count and % `scheme = 1`, split by "logged in within 90 days" vs dormant). Expected shape: active families migrate themselves within the first fee cycle; no action is taken on the dormant tail (see §1.6).
- **There is deliberately no `hashed-only` mode.** A `scheme = 0` row must verify successfully in every future version of this code. The day a "reject plaintext rows" switch exists is the day a returning family gets locked out; the design forbids it. Residual plaintext risk is carried consciously and mitigated (§1.6), not wished away.

### 1.6 Dormant accounts — accounts that never log in

A dormant account's row simply stays `scheme = 0`, indefinitely, and **works the first time its owner returns**, through the same dual-read path — this is a requirement, not an oversight ("they keep working whenever they return"). The accepted residual risk is plaintext-at-rest for that shrinking tail. Mitigations already in this wave: the password no longer leaves the server in payloads (§2), login is throttled (§7.1), and database access itself is unchanged (hosting-level).

Optional later campaign (designed here, **not mandated**; programme decision D8, default = none):

1. After two full terms of S3 coverage data, the office may run a **nudge campaign**: for still-`scheme = 0` accounts with a guardian email/phone on file, generate a §1.7 reset link and send it through the school's normal channels with plain-language wording ("set your password again to keep your account secure").
2. Accounts that ignore the campaign **remain able to log in with their existing password**. The campaign is a security improvement offer, never a gate.
3. A separate, explicit owner decision would be required to convert the campaign into a forced reset (at which point dual-read for those rows is retired by setting a "reset required" state — a state this design deliberately does **not** add to the schema in Wave 1).

**Bulk-hash alternative — considered and staged as an owner decision, not silently adopted.** Hashing the stored plaintext values in bulk (`password = hash(current stored value)`, `scheme = 1`, one maintenance script) is cryptographically sound — logins keep working because the stored value *is* the password — and it would erase plaintext-at-rest in one night instead of one term. It is **not** the default path for one operational reason: Smart School's office workflow includes staff viewing a family member's current password to help them (the `getLoginDetails` family of queries in `User_model.php:272-326` exists for exactly that screen). Bulk hashing kills that workflow instantly and everywhere; hash-on-login kills it gradually, family by family, and `set_password()`-based admin reset is the replacement either way. Recommendation: proceed with hash-on-login now; put bulk-hash to the owner at Wave 1 close with S3 coverage numbers, framed as "the office stops reading passwords aloud and starts issuing resets instead" (§8, decision D8-companion).

### 1.7 Forgot-password redesign — FL-022

Current state (verified locally; note the audit's description matches the web-tree variant, the API variant differs in mechanism but not in weakness): `Webservice::forgot_password()` (:732-803) generates the reset secret as `$this->enc_lib->encrypt(uniqid(mt_rand()))` (:767) — a low-entropy seed (`mt_rand` + `uniqid`) wrapped in `Enc_lib`'s deterministic AES, whose keys are hard-coded static values inside the vendor library file, so the token is effectively reversible by anyone with the vendor source. It stores the value in `users.verification_code` with **no expiry**, never clears it after use in any code present locally, builds the reset link from the **client-supplied `site_url` parameter** (an attacker can have genuine school reset emails carry a look-alike domain), and answers unknown emails with HTTP 401 `"Invalid Email or User Type"` versus HTTP 200 for known emails (account enumeration).

Redesign (API issuer + web reset consumer change together; same link path shape so mail templates and the apps' expectations survive):

1. **Token:** `$token = bin2hex(random_bytes(32))` (64 hex chars, the staff-extension pattern). Only `hash('sha256', $token)` is stored, in `users.verification_code`; the raw token exists only in the email link. Lookup on the reset page compares `verification_code = SHA-256(presented token)` — a database leak no longer yields usable reset links.
2. **Expiry:** `verification_code_expires_at = NOW() + 60 minutes` (new column, §1.1). The reset consumer rejects expired codes with the same generic error as invalid ones.
3. **Single-use:** a successful reset calls `set_password()`, which clears both verification fields (§1.2). Requesting a new link overwrites (invalidates) the previous one. Password change (W4) also clears them.
4. **Link construction:** the base URL comes from server configuration (the web app's configured base URL / school settings), **never** from the request. The `site_url` field continues to be accepted (the app sends it; rejecting it would break the app) and is ignored.
5. **Uniform response:** known and unknown emails both receive HTTP 200 `{"status": 200, "message": "Please check your email to recover your password"}` and near-identical timing (the mail is queued/sent only for real accounts; the response is not). This changes the current 401-for-unknown behaviour — flagged as an app-compatibility checklist item in the acceptance tests (the message text the app displays is unchanged).
6. **Rate limit:** max 3 reset requests per account per hour and 10 per IP per hour, enforced through the §7.1 throttle table; excess requests still return the uniform response but send no mail.
7. **On successful reset:** all `users_authentication` sessions for the user are deleted (§5.5), an audit row is written (§7.3), and the throttle counters for that account are cleared.

### 1.8 Rollback position

- **Code rollback (any step):** redeploy the pre-change model/library files. Safe at S1 unconditionally. After S2 has written its first hash, rollback must retain `Credential_lib::verify()` (dual-read) in the rolled-back build — reverting to the old `WHERE password = ?` code after any row is hashed locks that row's owner out. The build checklist therefore marks `Credential_lib` + the three verify call-sites as **non-revertible** once S2 flips; everything else (flag, throttling hooks, UI) reverts freely. Setting the flag back to `dual-read` is always safe and instantly stops further rehashing.
- **Data rollback:** the schema changes are additive and need no rollback. Restoring the pre-migration `users` export is a data-loss decision (it would un-hash migrated rows and un-change changed passwords) reserved to the owner; it is never part of an engineering rollback.

### Staging acceptance tests — §1

- [ ] Preflight report produced from staging: `users` column types recorded; role census shows only expected roles; any already-hashed rows classified `scheme = 1` without alteration.
- [ ] S1 regression: every fixture account (student + parent × web portal + API) logs in with the correct password and is rejected with the wrong one; Family app (current build, pointed at staging) logs in and completes a full session with no app update.
- [ ] S1: after logins in `dual-read` mode, fixture rows are still `scheme = 0` with unchanged stored values (no silent writes).
- [ ] S2: a fixture student logs in once → row is now `scheme = 1`, stored value verifies with `password_verify()` and no longer equals the plaintext; second login succeeds; wrong password fails.
- [ ] S2: parent login via each enabled alternate identifier (username, guardian phone, guardian email per staging settings) verifies and upgrades the same way; a deliberately duplicated guardian phone across two fixture parents resolves to the correct account for each password.
- [ ] Dormant fixture: untouched through S1–S3, then logs in successfully at the end of the test window with its original password and is upgraded by that login.
- [ ] Admin-set password (web panel fixture flow) is stored hashed (`scheme = 1`) and the family member logs in with it on web + API.
- [ ] Change-password endpoint: wrong current password rejected; correct current + new password accepted; old password then fails everywhere; other sessions for that user are revoked; the calling session behaves as designed.
- [ ] Forgot-password: fresh link resets once and only once (reuse rejected); a link older than 60 minutes is rejected (test with a back-dated expiry); unknown email and known email produce indistinguishable responses; a request with a hostile `site_url` still produces a link on the school's real domain; reset requests beyond the rate limit send no mail but return the uniform response.
- [ ] Staff login (web + `staffauth/login`) is byte-for-byte unaffected throughout.
- [ ] Rollback drill on staging: flag returned to `dual-read` mid-test → already-migrated fixtures still log in; rehashing stops.

---

## 2. (b) Password out of payloads — FL-010

**Finding.** `users.password` is SELECTed by the core student-record queries and returned wholesale to any authenticated caller. Combined with §3's IDOR, any logged-in family member can harvest other students' credentials by iterating IDs — and after §1 lands, returning even the *hash* in payloads would remain a defect (offline-cracking material, and a needless disclosure). The rule for this section is absolute: **no response from any endpoint may contain a password value, a password hash, or a verification code, under any key name.**

### 2.1 Complete inventory (local tree, by grep for `users.password`, `users.*`, and `SELECT *` over `users`)

**Tier 1 — explicit `users.password` in the SELECT list, result reaches clients:**

| Site | Callers / exposure |
|---|---|
| `Student_model::get()` — `models/Student_model.php:83` | The single most-called query in the API (~35 call sites in `Webservice.php` plus `Payment.php:87,400`). Returned wholesale by `getStudentProfile()` (:429 → `student_result`), embedded by `gettransportroutes()` (:4541 → `data['route']` = the entire student record), `getCourseExamDetails()` (:6195 → `resp['student']`), `coursedownloadcertificatepdf()` (:6558, internal use), dashboard/homework/fees/attendance/exam flows (internal field use — they read `class_id`, `student_session_id`, etc., and do not emit the row, but they *receive* the credential in memory) |
| `Student_model::getByStudentSession()` — `Student_model.php:180` | Same mega-join keyed by `student_session_id`; same treatment (no direct controller caller in the local tree — fix regardless; it is one grep away from being wired up) |
| `Student_model::getStudentByClassSectionID()` — `Student_model.php:31` | Class/section student lists; no local API controller caller found, but it is the canonical "list students" query for panel-side use — fix regardless |
| `Course_model::get()` — `models/Course_model.php:484` | Called by `course_payment/Course_payment.php:25` (course payment flow loads the student record) |
| `User_model::getstudentcurrentlanguage()` — `models/User_model.php:454` (`users.*`) | **Directly returned to the client** by `Webservice::getstudentcurrentlanguage()` (:4215 → `data['result']`). A live credential leak endpoint in its own right, separate from the profile path |

**Tier 2 — `users.*` wildcard selects, internal use today (password rides along in memory; any future caller that emits the row leaks it):**

| Site | Actual consumption (verified) | Fix |
|---|---|---|
| `User_model::checkLoginParent()` :70 (`users.*` + joins) | `Auth_model::login()` reads enumerated fields only to build `session_data` | Replace `users.*` with the explicit list the login flow consumes (`users.id, username, role, is_active, lang_id, currency_id, user_id, parent fields come from `students``) **plus** `users.password, users.password_scheme` marked server-only and unset before return (§1.3) |
| `User_model::read_user_information()` :97 (`users.*`) | Login student branch; enumerated fields only | Explicit list: `users.id, users.user_id, users.username, users.role, users.lang_id, users.currency_id` + the already-enumerated `students.*` fields |
| `User_model::user_information()` :117, `read_teacher_information()` :135, `read_accountant_information()` :148, `read_librarian_information()` :163 (all `users.*`) | No local API callers (legacy staff-role helpers) | Same explicit list pattern; low risk, same pass |
| `User_model::getLoginDetails()` :272, `getStudentLoginDetails()` :279, `getUserLoginDetails()` :438, `getParentLoginDetails()` :445 (`SELECT users.*` / `SELECT * FROM users`) | `getUserLoginDetails()` is called by `dashboard()` (:837) which consumes **only `['id']`**; the rest serve the web panel's login-details screens | Replace with explicit non-credential lists. **Consequence to flag, not hide:** the web panel's "view login details" screen historically displays the password from these queries; after §1 + this fix it can display username and a "password is set / last changed" indicator (`password_changed_at`) but never the password itself. That is the intended end-state (§1.6 decision) — the screen degrades to a reset-action screen |
| `User_model::getStudentCurrency()` :463, `getstudentcurrentcurrency()` :475 (`users.*`) | Endpoints consume only currency fields (`getStudentCurrency()` controller builds a clean 3-field array — verified :5051; `getstudentcurrentcurrency()` reads `currency_id` only — verified :4897) | Explicit lists: `users.id, users.currency_id` + currency columns |

**Tier 3 — forgot-password helpers selecting the password under an alias:**

`User_model::getUserByEmail()` :339, `getUserValidCode()` :358, `getParentByEmail()` :389, `getParentUserValidCode()` :423 all select `users.password as user_tbl_password`. Verified: **no code in the API tree consumes `user_tbl_password`** (grep returns only the four SELECT sites). Fix: delete the alias from all four SELECTs — but first run the same grep on the **web tree** on staging (§9), because the reset page lives there; if the web consumer uses the field for anything, it is migrated to `set_password()` semantics in the same step. Nothing in the reset flow legitimately needs the old password.

**Tier 4 — the one legitimate server-side select:**

`Auth_model::checkLogin()` :251/:280 selects `password` because §1 verification needs it. This select **stays**, with a code comment (`// server-side credential verification only — never returned`), the §1.3 unset-before-return, and an entry in the §2.3 allowlist so the static gate does not flag it forever.

### 2.2 Fix approach

1. **Explicit exclusion at the query (primary).** In the four Tier 1 mega-joins the SELECT is already an explicit column list — the fix is literally deleting `users.password,` from each list (and in `getstudentcurrentlanguage()`, replacing `users.*` with `users.id, users.user_id, users.lang_id` + the language columns it already joins). No caller can be consuming `->password` from these rows legitimately; the staging regression suite (§2.3) proves that empirically per endpoint.
2. **No `users.*` survives in `models/`** except inside `Auth_model` verification internals. Wildcards are replaced with the explicit lists in the Tier 2 table. Rationale for lists over a post-fetch `unset()`: an unset is one forgotten call-site away from leaking again; a column that is never fetched cannot leak.
3. **Serializer scrub (defence in depth).** Add a recursive key-scrub to `json_output()` (`helpers/json_output_helper.php` — autoloaded, used by every JSON response in the API): before encoding, walk the payload and drop any key named `password`, `user_tbl_password`, or `verification_code` at any depth. Cost is negligible at these payload sizes; benefit is that a future model change cannot reintroduce the leak silently. If staging regression attributes any breakage to the scrub (no legitimate client consumes these keys — the Family app's models do not map a `password` field from responses), the fallback is to scope the scrub to `Webservice` + `Auth` responses only.
4. **Transport over-disclosure (boundary note).** After the purge, `gettransportroutes()` still returns the whole student record as `data['route']`. Slimming that payload to route fields is assigned to Wave 2 in the programme plan and is **not** smuggled into Wave 1; Wave 1's guarantee is the narrower, critical one — no credential material in it.
5. **Related observation (recorded, not fixed here):** the same mega-joins also select `students.app_key` / `students.parent_app_key` (push device tokens). They are not credentials for this system and the apps receive their own values legitimately, but §3's guard is what stops them being read cross-family; no change in this section.

### 2.3 Regression defence — payload key scan + static gate

- **Dynamic scan (staging, part of the security regression suite):** a script that, using Family A fixtures, calls the endpoint matrix — profile, transport routes, dashboard, fees, attendance, homework, exams, documents, language, currency, course list/detail/exam, offline payments list, timeline, visitors, leave — and recursively scans every JSON response body for the keys `password`, `user_tbl_password`, `verification_code` (case-insensitive) **and** for the fixture accounts' actual password values and current hash prefixes (`$2y$`) as raw substrings. Any hit fails the gate. The matrix explicitly includes `getstudentcurrentlanguage` and a `course_payment` student load.
- **Static gate (build-time):** `grep -rn "users\.password\|users\.\*" application/models application/controllers` on the API tree must return only the allowlisted `Auth_model` verification sites; the allowlist is a checked-in file so an exception is a deliberate, reviewed act.

### Staging acceptance tests — §2

- [ ] Profile response for a fixture student contains no `password` key at any depth (response-body diff against pre-fix capture attached to the staging change log).
- [ ] Transport-routes response (`route` object) contains no credential keys and still contains every route/vehicle/pickup field the app renders.
- [ ] `getstudentcurrentlanguage` returns language data with no `users` credential fields.
- [ ] Payload key scan (§2.3) passes over the full endpoint matrix for student **and** parent fixture tokens, including a scan for the fixtures' literal password strings.
- [ ] Course payment flow (`course_payment/Course_payment`) still loads the student record and reaches the gateway step on staging.
- [ ] Web panel login-details screen (staging web tree) renders username/status without a password value; the office reset action from that screen works (§1 W2).
- [ ] Static grep gate output matches the allowlist exactly.
- [ ] Family + staff apps complete their staging regression flows with no response-parsing errors attributable to removed fields.

---

## 3. (c) IDOR ownership enforcement — FL-011, FL-025, and the unauthenticated-endpoint findings

**Finding.** `Auth_model::auth()` validates only that a (`User-ID`, token) pair exists in `users_authentication` and is unexpired. No endpoint in `Webservice.php` then compares that identity to the `student_id` in the request body (Lane A §4.3). Every student-scoped endpoint is therefore an IDOR. The census for this design (all 143 public methods of `Webservice.php`, classified in Appendix A) also surfaced worse variants that the guard design must absorb:

- `cbseexamresult()` (:5666) performs **no client-gate check and no `auth()` call at all** — anyone who can reach the URL can read CBSE results for any `student_session_id`.
- `addTask()` / `updatetask()` / `deletetask()` (:584/:632/:667), `deleteforummessage()` (:2288), `deletedailyassignment()` (:4495) and `deletetimeline()` (:4696) check only the static client headers — **no user session at all** — and act on body-supplied `user_id` / object IDs.
- The certificate URL endpoints (`coursedownloadcertificatepdf()` :6538, `downloadCertificateFile()` :6676, `show_qr()` :6728, `deleteCertificateFile()` :6735) take `student_id` as a URL segment with no session check; the generated PDF embeds the student's name and course record.

### 3.1 Ownership rules (the whole policy, in four rules)

Identity always comes from the session (§3.2), never from the body. The body may *name* a student; the session decides whether that name is allowed.

- **R1 — student role:** the caller may access exactly one student: the `students.id` linked to their `users` row (`users.user_id` where `users.id` = session user and `role = 'student'`).
- **R2 — parent role:** the caller may access exactly the students whose `students.parent_id` = their `users.id` — the same set login already returns as `parent_childs` (computed in `Auth_model::login()` from `Student_model::read_siblings_students()`), recomputed server-side at guard time, never trusted from the client.
- **R3 — self-only user objects:** objects keyed by `users.id` (tasks/events, language/currency preferences, profile) may be read/written only when the target `users.id` (or the `users.user_id` → student mapping) is the session user themselves (for preferences keyed by `students.id` in the body — see `updatestudentlanguage()` :4182, which writes `users` rows keyed by the body's `student_id` — R1/R2 applies via that student).
- **R4 — indirect objects:** where the request names an object ID rather than a student (leave application, timeline entry, daily assignment, incident, forum message, homework submission), ownership is resolved through the object: object → its `student_session_id` → `student_session.student_id` → R1/R2. Fee objects resolve the same way (`student_session_id`, `student_fees_master_id`, `student_fees_deposite` ID, transport fee ID).

There are **no legitimately cross-student endpoints for family roles** in this controller. School-wide reference data (subjects, timetable structure, teachers, library catalogue, notices, settings/status probes) is not student data and is governed by §3.3 Group R — authenticated, not ownership-checked. Staff-facing work does not flow through `Webservice.php` at all: staff use `Staffapi`/`Staffsync` with `api_staff_sessions` and their own scoping (class-teacher intersection), which is **out of scope** here and unchanged.

### 3.2 Identity context — extend `auth()`, don't replace it

`Auth_model::auth()`'s contract (return array with `status`, or `json_output(401, …)` + exit on failure) is load-bearing in ~100 call sites; it is not changed. A sibling method is added:

```php
// Auth_model — new. Returns null (after emitting the standard 401) on failure,
// exactly like auth(); on success returns the identity context AND performs
// the same expiry/idle bookkeeping as §5's rewritten auth().
public function auth_context()
{
    // 1. Resolve (User-ID header, Authorization header) against
    //    users_authentication (the §5 policy lives here, shared with auth()).
    // 2. Load the users row: id, role, user_id, is_active. Inactive → 401.
    // 3. Compute and cache (per-request, private property) the permitted set:
    //      role student → array((int) users.user_id)
    //      role parent  → SELECT id FROM students WHERE parent_id = users.id
    //    Parent set is NOT filtered by current session or is_active at guard
    //    level: a child between sessions must not become "foreign"; the
    //    endpoints' own queries already scope by current session.
    // Returns: ['users_id'=>…, 'role'=>…, 'student_id'=>… (student role),
    //           'permitted_student_ids'=>[…]]
}
```

Existing endpoints keep calling `auth()` during the transition; each endpoint migrated in §3.3 switches its prologue to `$identity = $this->auth_model->auth_context(); if ($identity === null) return;` (the 401 has already been emitted in the failure case, mirroring today's control flow). The token bookkeeping must exist in exactly one private helper used by both, so §5's policy cannot drift between them.

### 3.3 The guard helper and the endpoint groups

One private section at the foot of `Webservice.php` (mirroring how `Staffapi.php` keeps `require_staff_session()` + `scope_allows()` in the controller):

```php
private function guard_student($identity, $student_id)          // R1/R2 on students.id
private function guard_student_session($identity, $ssid)        // resolves student_session.id → student_id, then guard_student
private function guard_self_user($identity, $users_id)          // R3
private function guard_object($identity, $table, $id)           // R4 resolver for leave/timeline/assignment/incident rows
```

Each returns `true` or emits the §3.4 denial and returns `false`. Call placement is mechanical: **immediately after authentication, before the first model read** — specifically before any `student_model->get($student_id)` dereference, which also removes a class of foreign-ID null-dereference 500s (the guard answers first; the separate null-guard hardening remains Wave 2 work). Endpoints that read the student record to *derive* other IDs (`fees()`, `getHomework()`, etc.) guard on the body's `student_id` before that read. `Payment::fees_pay()` (`controllers/Payment.php:365`), which authenticates and then derives `student_id` from the payment rows, gets `guard_student_session()` on the resolved session ID before any fee read.

The full enumeration is **Appendix A**. Summary of the groups:

- **Group S1 — direct `student_id` in body (guard_student).** ~70 endpoints, including: `getStudentProfile`, `dashboard`, `getDocument`, `getHomework`, `getstudentsubject`, `addhomework` (submission owner), `getOnlineExam`, `getOnlineExamQuestion`, `getOnlineExamResult`, `saveOnlineExam`, `getExamList`, `getAttendenceRecords` + `getAttendenceRecords1`, `examSchedule`, `getlessonplan`, `getsyllabussubjects`, `fees`, `class_schedule`, `getExamResult`, `cbseexamtimetable` (via session), `getLibraryBookIssued` (its `studentId` variable is `students.id` — verified against `Librarymember_model::checkIsMember('student', …)`), `getTransportroute`, `gettransportroutes`, `getHostelList`, `liveclasses`, `livehistory`, `gmeetclasses`, `gmeethistory`, `profileUpdateFields`, `editprofile`, `uploadDocument`, all online-course student endpoints (`courselist`…`getSubmitedAssignmentDetails`), `adddailyassignment`, `getdailyassignment`, `addeditdailyassignment`, `getVisitors`, `getTimeline` (body key is `studentId` — note the capitalisation), `addedittimeline`, `getstudentbehaviour`, `addincidentcomments`, `getstudentcurrentcurrency`, `updatestudentlanguage`, `updatestudentcurrency`, `getStudentCurrency`, `lock_student_panel`, `getOfflineBankPayments`, `getProcessingfees`, `getApplyLeave`, `addLeave`, `searchuser`, `addChatUser`, `addforummessage`, `getDownloadsLinks` (see special note), `saveCourseAssignment`.
- **Group S2 — `student_session_id`-keyed (guard_student_session).** `getBalanceFee`, `cbseexamresult` (also gains the missing authentication, below), `addofflinepayment` (its body carries `student_session_id` — the file fix is §6; the ownership check lands here), plus every S1 endpoint's *derived* session ID is implicitly covered because the S1 guard runs first.
- **Group S3 — object-ID-keyed (guard_object / R4).** `updateLeave` + `deleteLeave` (leave row → `student_session_id`), `deletetimeline`, `deletedailyassignment`, `deleteincidentcomments`, `getincidentcomments` (incident-assignment ID → student), `deleteforummessage` (message row → author student), `getAppliedDiscounts` (deposit ID → fee record → session), `getHomeworkById` (homework is class content, not student data — authenticated-only, but the *evaluation/submission* variant parameters, if supplied, are guarded; recorded as a deliberate authenticated-only exception).
- **Group U — user-keyed (guard_self_user) + gain authentication.** `addTask`, `updatetask`, `deletetask`, `getTask` (tasks are `events.event_for = users.id`): these gain `auth_context()` first (today: static headers only), then R3 on the body's `user_id` and, for update/delete, on the task row's `event_for`. `Parent_GetStudentsList` — body `parent_id` must equal the session `users.id` **and** role must be parent; the response then equals the login-time `parent_childs` set. `checkStudentStatus` — the queried `id`/`user_type` pair must resolve inside the caller's permitted set (own user row, own student row, or own child), else denial.
- **Group R — reference/school-wide (authenticated only, no ownership rule).** `getSchoolDetails`, `getSubjectList`, `getSubjectTimetable`, `getClassTimetable`, `getTeacherSubject`, `getTeachersList` (its `user_id` is used only to overlay the caller's own ratings — if it differs from the session user, the overlay is skipped, not denied), `getExamSchedule`, `getexamscheduledetail`, `getSubjectsLessons`, `getsyllabus`, `getforummessage` (class forum reads), `getLibraryBooks`, `getTransportVehicleDetails`, `getDownloadsLinksById`, `getVideoTutorial`, `get_currency_list`, and the module/status probes (`getModuleStatus`, `getELearningModuleStatus`, `getAcademicsModuleStatus`, `getCommunicateModuleStatus`, `getOthersModuleStatus`, `getMaintenanceModeStatus`, `getStudentTimelineStatus`, `getTimeLineStatus`, `getFeesDiscountStatus`, `getOnlineCourseSettings`, `getOfflineBankPaymentStatus`, `getOfflineBankPaymentInstruction`, `checkProfileUpdate`).
- **Group N — no authentication today; authentication + guard are added, not just guard.** `cbseexamresult()` gains `check_auth_client()` + `auth_context()` + `guard_student_session()` — the single most exposed endpoint in the controller. Certificate endpoints: `coursedownloadcertificatepdf()` and `deleteCertificateFile()` gain client-gate + `auth_context()` + `guard_student()` on the URL `student_id`; `downloadCertificateFile()` keeps its strict filename pattern and gains the same session requirement; `show_qr()` only renders a QR encoding the download URL — it stays reachable, since the URL it encodes becomes useless without a session (recorded trade-off: QR codes printed/shared earlier stop working as anonymous links; online courses are unused at IQRS per the audit, so the blast radius is nil in practice, and the staging test confirms).
- **Special cases.** (i) `getNotifications()` — not student-keyed, but its audience `type` comes from the body (FL-025): the type is **derived from the session role** and the body value ignored, closing the cross-role feed read. (ii) Course-exam guest flow (`getCourseExamDetails`, `getOnlineCourseQuestion`, `saveOnlineCourseExam` accept a guest identity for non-enrolled course exams): when the request carries a `guest_id` and no `student_id`, the endpoint stays authenticated-only; when a `student_id` is present, R1/R2 applies. Guest semantics are vendor course-shop behaviour, unused at IQRS — the staging suite verifies the family paths and leaves guest purchase flows disabled-by-scope (flagged in §9 for a product decision). (iii) `getCourseReviews` — course-scoped public content; authenticated-only.

### 3.4 Denial contract — JSON, familiar, non-oracular

On any guard failure:

```php
json_output(403, array('status' => 403, 'message' => 'Unauthorized.'));
```

- Same envelope family and same message string as the existing 401 (`Auth_model::auth()`), so no client sees a new *kind* of payload; the message deliberately does not distinguish "student does not exist" from "student is not yours" (no existence oracle).
- HTTP 403 (not 200/`status 0`) so the denial is visible in logs and monitoring as a security event. The known client risk — an app treating 403 like 401 and bouncing to the login screen — is acceptable and arguably correct UX for a forged request; it is **explicitly tested** with both apps in the acceptance suite. If, and only if, staging shows a current app build mishandling 403, the fallback is a single constant (`GUARD_DENY_HTTP = 401`) flipped without touching call sites.
- Every denial writes an audit row (§7.3: actor `users.id`, action `idor.denied`, endpoint, requested ID) with per-actor log throttling (first 20 per actor per hour, then a counter line) so a probing client cannot flood the log.
- Guard failures must be indistinguishable in *timing class* from ordinary misses — the guard performs the same permitted-set lookup for every request, hit or miss (it is one indexed query on `students.parent_id` / primary key), so no special timing defence is needed beyond that.

### 3.5 What this section does not do

It does not change `Staffapi`/`Staffsync` (already session-scoped), does not add authorisation to the web panel (its RBAC is the vendor permission system; not in local evidence — §9), and does not parameterise SQL (Wave 2). It also does not fix the endpoints' tendency to dereference a possibly-null student record for **legitimate** IDs — for foreign IDs the guard now answers first; for legitimate-but-unconfigured IDs the Wave 2 null-guard applies.

### Staging acceptance tests — §3

- [ ] IDOR matrix: Family B's parent token requests Family A's `student_id` against every Appendix A Group S1/S2 endpoint (scripted) — every response is the §3.4 denial, none contains Family A data; the same matrix with Family B's student token, and cross-wise (A→B).
- [ ] Positive control: every matrix endpoint succeeds for the caller's **own** student/children with payloads identical in structure to pre-fix captures.
- [ ] Parent with two children can access both children and only those two; a student token cannot access a sibling.
- [ ] `Parent_GetStudentsList` with a foreign `parent_id` is denied; with the caller's own ID it returns exactly their children.
- [ ] Session-keyed attacks: foreign `student_session_id` in `getBalanceFee`, `addofflinepayment`, `cbseexamresult` denied; `cbseexamresult` with **no headers at all** now returns 401.
- [ ] Object-keyed attacks: foreign leave ID in `updateLeave`/`deleteLeave`, foreign timeline/assignment/incident IDs — denied, and the target rows are verifiably unmodified afterwards.
- [ ] Header-only attacks: `addTask`/`deletetask`/`deleteforummessage` with only the static client headers (no user token) now return 401.
- [ ] `getNotifications` with a mismatched body `type` returns only the caller's own role feed.
- [ ] Certificate PDF URL for another student returns the denial; own certificate flow still completes.
- [ ] Both mobile apps (current builds, staging) run their full regression with zero guard-attributable failures; denial rows appear in the audit log with actor, endpoint and requested ID.
- [ ] `Payment::fees_pay` with a payment set belonging to another family is denied before any fee data is read.

---

## 4. (d) Environment, debug output and the JSON error envelope — FL-012, FL-021

**Finding.** `application/config/database.php:18` reads `'db_debug' => (ENVIRONMENT !== 'prodcution')` — "prodcution" is misspelled, so the comparison is true in **every** environment and CodeIgniter renders its full database error page (SQL text, table names) as HTML in production. The same file ships `'save_queries' => TRUE` (:27), holding every query in memory. Separately, PHP-level failures (e.g. the null dereferences of Lane A §3.2) surface as HTML or blank 500s. The API's contract is JSON (`helpers/json_output_helper.php`); errors are the one place it is violated.

### 4.1 How `ENVIRONMENT` is defined in this install (verified locally)

- API entry point: `api/index.php:60` — `define('ENVIRONMENT', 'production');` **hard-coded**, followed by the standard CI switch (:75): `production`/`testing` → `display_errors 0`, `error_reporting(E_ALL & ~E_NOTICE & ~E_DEPRECATED & …)`; `development` → full display. So PHP's own display is already off in production; the HTML leak is specifically CI's **DB error view**, which is governed by `db_debug`, not by `display_errors` — which is why the typo is decisive.
- There is no per-host or per-`.env` switching in this tree: staging is a **separate physical copy** of the tree with its own `index.php`, `config.php` (`base_url` differs) and `database.php` (the local copy carries empty credential fields, so the deployed files necessarily hold server-side values the local template does not — §9). Any fix must therefore be applied **per tree**, and the staging tree's files must be diffed, not assumed.
- The web application has its own entry point with the same pattern (not in local evidence — §9 staging diff item).

### 4.2 The fix (config layer — Wave 1A quick win)

1. `database.php` (API tree and web tree): replace the expression with a literal — `'db_debug' => FALSE` — **and** correct the spelling in the same edit, so neither a typo nor an environment mix-up can re-enable it. `db_debug` is never legitimately on outside a developer's local copy; if a developer needs it, they change their local file, not the deployed one.
2. Same file: `'save_queries' => FALSE` (FL-021). Nothing in production code reads the saved-query list; it is memory overhead and a disclosure surface in profiling/debug output.
3. `index.php`: no change required to the `ENVIRONMENT` value or the error-reporting switch on either environment (production values are already correct there). On the **staging tree only**, `ENVIRONMENT` may be set to `testing` during the §4.4 verification window to exercise the non-production branch, then returned to `production` so staging mirrors production behaviour for all other tests — staging must normally run the production branch, or staging proof proves nothing.
4. Defence in depth at the hosting layer (configuration, staging-verified): ensure the web server/PHP for the API vhost has `display_errors = Off` at the php.ini level too, so a future entry-point edit cannot re-expose PHP warnings. Record the effective value from a staging `phpinfo()`-equivalent check performed via a temporary, immediately-deleted probe (never left deployed — §6.4's `geeee()` lesson applies to our own probes).

### 4.3 The JSON error envelope (code layer)

With `db_debug = FALSE`, CI's DB layer calls the exceptions handler instead of rendering and halting; PHP exceptions and errors need the same treatment. Design, in two cooperating pieces, both confined to the API tree in Wave 1:

1. **`application/core/MY_Exceptions.php`** (CI3's subclass mechanism, `$config['subclass_prefix'] = 'MY_'` is the framework default): extend `CI_Exceptions` and override `show_error()` / `show_exception()` / `show_php_error()` so that, for API requests, they (a) log the real error server-side via `log_message('error', …)` with the request URI, (b) emit exactly `{"status": 500, "message": "Internal server error."}` with HTTP 500 and `Content-Type: application/json`, and (c) exit. "API request" detection: the routed controller is one of the API controllers (`webservice`, `auth`, `payment`, the `staffext` controllers) or the request carries the API client headers — implemented as a small URI-prefix/header check in the class, unit-verifiable on staging. Non-API requests fall through to `parent::` behaviour unchanged (the web panel keeps its own error pages for humans; its `db_debug` fix is §4.2 step 1 only).
2. **Fatal-error safety net in `MY_Controller`:** `Webservice`, `Auth` and the extension controllers are re-parented from `CI_Controller` to the existing `application/core/MY_Controller.php` (one-line change each; `Payment` already reaches it via `Admin_Controller`). `MY_Controller::__construct()` registers a shutdown function that, on a fatal (`E_ERROR`, `E_PARSE`, uncaught `Error`), performs the same JSON emission if no output has been sent yet. This catches the class of failure (null dereferences in current code) that bypasses the exceptions handler entirely.

The envelope reuses `json_output()`'s exact mechanics (`output->set_content_type('application/json')` + status header) so clients see one consistent JSON dialect. Under no circumstance does the envelope include exception class, message, file, line, SQL, or a stack trace — those go only to the application log (§7.2), correlated by a timestamp the log and the response share (the response carries no ID field in Wave 1; adding one is a compatible future improvement, noted not built).

### 4.4 Verification on staging without endangering production

- Production safety is structural: staging has its own tree and database; §4.2 edits are made to staging files only; the production file set is protected by a **checksum manifest** (Wave 0) re-verified at the end of the staging window to prove production files were not touched.
- A staging-only throwaway controller (`Secprobe`, deployed only on staging, deleted before the wave closes) exposes two actions: one executing a deliberately invalid query, one throwing an exception / dereferencing null. Before the fix they reproduce the HTML leak (baseline capture for the change log); after the fix they must return the §4.3 envelope. `Secprobe` is also the trigger used by §7.2's logging test.
- The dead `teacher_subjects` methods (Lane A §3.6) are a natural second trigger once routed in a test harness — optional; `Secprobe` suffices.
- Config-file handling rule for the build lane: staging `database.php` / `config.php` are edited **in place on staging** (they contain server-side values not present locally); the local mirror receives the same logical edits with placeholder values, and the two are diffed by structure, never copied over each other.

### Staging acceptance tests — §4

- [ ] `Secprobe` bad-query action returns HTTP 500 with the exact JSON envelope; body contains no SQL fragment, table name, file path, or HTML tag (asserted by string scan).
- [ ] `Secprobe` exception and null-dereference actions return the same envelope (no blank page, no HTML).
- [ ] A forced failure inside a real endpoint (e.g. temporarily mis-pointing a staging-only setting) returns the envelope on `webservice/*` and `auth/*` routes.
- [ ] The full error (SQL/exception detail) appears in the staging application log (§7.2) for each probe — the information moved server-side, it was not deleted.
- [ ] Staging `database.php` shows `db_debug = FALSE` and `save_queries = FALSE`; all normal API regression flows still pass (proving nothing depended on debug output).
- [ ] Web-panel staging tree: a triggered DB error no longer renders SQL to the browser (its own `db_debug` fix verified separately from the API envelope).
- [ ] Production checksum manifest unchanged at wave close; `Secprobe` absent from staging at wave close (deleted, verified by directory listing in the change log).

---

## 5. (e) Token redesign — FL-013, FL-017

**Finding.** `Auth_model::getToken(10)` (`models/Auth_model.php:309-319`) builds a 10-character token from `rand()` — not a CSPRNG, tiny search space. Login sets `expired_at = +8760 hours` (one year) at :80 and :165, and `auth()` (:332-353) **renews it to +8760 hours on every authenticated call** (:345) — a stolen token is effectively perpetual while used, and valid for a year after last use. There is no idle timeout, no per-user session inventory, and no revocation besides `logout()` deleting its own row (:321 — the one sound piece, kept). Unbounded rows also accumulate: every login inserts a new `users_authentication` row and nothing ever prunes old ones except expiry-at-read.

### 5.1 New token generation

`Auth_model::getToken()` keeps its name and call sites; its body becomes the staff-extension pattern (`Staffauth.php` already issues `bin2hex(random_bytes(32))` on this stack):

```php
public function getToken($randomIdLength = 32)   // parameter retained for signature compatibility; value ignored beyond a floor
{
    return bin2hex(random_bytes(32));            // 64 hex chars, 256-bit
}
```

Schema: verify `users_authentication.token` width on staging; if under 255, `ALTER TABLE users_authentication MODIFY token VARCHAR(255) NOT NULL;` (mirroring `api_staff_sessions.token VARCHAR(255)`). Hex encoding keeps the token header-safe in the existing `Authorization` header transport with no client change — the apps treat the token as an opaque string and store it verbatim.

### 5.2 Expiry model — absolute + idle, no self-renewal

Concrete values, chosen for this user base (parents who check fees around a monthly due cycle and at term events; students who use the app daily in term and barely in holidays; re-login costs a username + password the family already uses on the web portal):

| Parameter | Value | Justification |
|---|---|---|
| Token entropy | 256-bit CSPRNG | Matches staff extension; guessing is out of scope as an attack |
| **Idle timeout** | **30 days** without an authenticated call → session deleted | Covers the monthly fee-check cycle and short holidays; a token stolen from a lost phone dies within a month of the phone going quiet |
| **Absolute lifetime** | **180 days** from issuance, **never extended** | Roughly one academic term plus margin; bounds the value of any token regardless of use; families re-login at most about twice a year |
| Concurrent sessions per user | **5** (oldest pruned at login) | Two parents' phones + student's phone + a spare; prevents the current unbounded row accumulation |
| Legacy glide (existing tokens) | Hard cap **30 days from deployment**, then dead (see §5.4) | No mass logout; bounds the weak-token era |

Implementation: reuse existing columns where they already carry the right meaning, add what is missing.

- `expired_at` becomes the **absolute** deadline: login sets `NOW() + 180 days`. `auth()` never extends it again (the :345 renewal is deleted).
- Add `last_used_at DATETIME NULL` and `created_at DATETIME NULL` if absent from `users_authentication` (verify via `SHOW CREATE TABLE` on staging — `auth()` already writes `updated_at` at :346, so that column exists; `last_used_at` is added rather than overloading `updated_at`, so future code cannot confuse bookkeeping with activity). Backfill: `last_used_at = COALESCE(updated_at, NOW())`, `created_at = COALESCE(created_at, NOW())` for existing rows at migration time.
- Rewritten `auth()` / shared session validator (§3.2): fetch the row by (`users_id`, token); missing → existing 401 `"Unauthorized."`; `expired_at < NOW()` → delete row, existing 401 `"Your session has been expired."`; `last_used_at` older than 30 days → delete row, same 401 expired message; otherwise update `last_used_at`/`updated_at` and return authorised. Both 401 bodies are byte-identical to today's — clients already handle them (they occur today whenever a token finally lapses).
- Login prunes: after inserting the new row, delete the user's sessions beyond the newest 5, and delete that user's already-expired rows opportunistically.

### 5.3 Token storage note

Tokens are stored raw in `users_authentication.token`, matching the staff extension and the existing table's semantics; the lookup is an exact-match on a 256-bit value. Hashing tokens at rest (store SHA-256, look up by hash) is recorded as a **Phase S hardening item**, deliberately not bundled here: it touches every session read path in both the family API and any web-side consumer of the same table (§9 must first establish whether the web portal shares `users_authentication`), and the marginal gain is small once §1 removes plaintext passwords and §2 removes payload leakage from the same database. This is a conscious sequencing decision, not an oversight.

### 5.4 Migration — no mid-term mass logout

**Recommended: glide path (accept-old-until-cap), not a hard cutover.**

1. At deployment on staging (and later production): `UPDATE users_authentication SET expired_at = LEAST(expired_at, NOW() + INTERVAL 30 DAY) WHERE expired_at > NOW() + INTERVAL 30 DAY;` Existing 10-character tokens keep working, but none survives more than 30 more days; idle ones mostly die sooner by disuse (their owners re-login and receive strong tokens transparently).
2. All new logins from deployment onward receive §5.1 tokens under §5.2 policy.
3. After the 30-day cap passes, a cleanup deletes expired rows; a follow-up code tidy (next wave) may drop the legacy acceptance entirely — by then no legacy token can exist.

Why not a hard cutover: it would log out every family simultaneously, mid-term, for a purely internal improvement — the office would absorb hundreds of "the app logged me out" contacts in one morning, and any family that has forgotten its (never-rotatable, §1) password becomes a support case. The glide path's residual risk (weak tokens valid ≤ 30 more days) is bounded by §7.1 throttling on the *login* side, §2's removal of credential leakage, and §3's guard limiting what any token can reach. The same glide is applied to `api_staff_sessions` in a follow-up ticket (staff tokens are already 256-bit; only their +8760 h lifetime needs aligning to §5.2 values — a `Staffauth`/`Staffapi` change, scheduled with Wave 1C, not blocking this section).

### 5.5 Revocation

- **Logout:** unchanged — `Auth_model::logout()` already deletes the caller's row (:328). Kept and regression-tested.
- **Credential events (new, wired in §1):** password change, password reset, and admin-set password delete **all** `users_authentication` rows for that user (implemented inside `Credential_lib::set_password()`). A compromised password thus kills its sessions the moment it is rotated — today it does not.
- **Per-user session listing/kill for admins:** designed, built as a small extension-style endpoint in Wave 1C (not in `Webservice.php`): `POST staffapi/family_sessions` (staff session required, Admin/Super Admin roles via `require_staff_session()` + role check) listing a family user's sessions (`id`, `created_at`, `last_used_at`, `expired_at` — never the token value itself beyond a 6-character prefix for identification), and `POST staffapi/family_sessions/revoke` (`users_id`, optional session `id`; omitting `id` revokes all). Until that endpoint ships, the office runbook procedure is a documented, audited SQL delete by `users_id` — specified in the runbook, not improvised.

### 5.6 The static client gate — FL-017, kept and labelled

`Auth_model::check_auth_client()` gates every request on two static header values defined at `models/Auth_model.php:9-10`. Those values ship inside the vendor package and the legacy app: they are **published, not secret**, and authenticate an app build, not a user. Wave 1 position, explicitly:

- **Keep the gate exactly as-is.** Removing or rotating it breaks every installed app build instantly — the opposite of the no-app-update rule.
- **Rely on it for nothing.** After §§1/3/5, security rests on the per-user token + ownership guard; the static gate is treated in documentation and code comments as a routing/identification header, not an authentication factor. (§3's acceptance suite includes the register's FL-017 test: static headers with no valid user token must fail on every protected endpoint — including the Group N endpoints where that is true only after this wave.)
- **Phase S path (designed direction, not built):** per-integration scoped keys (one key per app build/integration, server-side scope list, rotatable without an app release via a key-version header), with the legacy static pair accepted only for the legacy scope during transition. This belongs to the SaaS phase, where third-party integrations make scoped keys a product requirement.

### Staging acceptance tests — §5

- [ ] New login issues a 64-character hex token; 1,000 generated tokens are pairwise distinct (scripted sample); `getToken()` source contains `random_bytes` and no `rand(`.
- [ ] A token used regularly survives to its absolute deadline and then returns the standard 401 expired body (tested with back-dated `expired_at`/`created_at` fixtures rather than waiting 180 days).
- [ ] A token idle for 31 days (back-dated `last_used_at`) is rejected with the standard expired body and its row is deleted; a token idle 29 days works and refreshes `last_used_at` **without** moving `expired_at`.
- [ ] Legacy-glide: a pre-migration 10-character fixture token works after deployment; its `expired_at` is capped at deployment + 30 days; a fixture token back-dated past the cap is rejected.
- [ ] Sixth concurrent login for one fixture user prunes the oldest session (that token then 401s); the newest five work.
- [ ] Logout deletes only the caller's session; a second device session for the same user keeps working.
- [ ] Password change and password reset each revoke **all** existing sessions for the fixture user (old tokens 401 immediately after).
- [ ] Admin session listing (Wave 1C endpoint, if shipped in this wave's window) shows fixture sessions without full token values; revoke-one and revoke-all both take effect on the next API call.
- [ ] Static client headers alone (no user token) fail on a sample of endpoints from every Appendix A group, including `cbseexamresult`.
- [ ] Family app regression: an app build logged in **before** the staging deployment keeps working after it (glide proof with a real client, not only curl).

---

## 6. (f) Upload validation — FL-015, FL-016, FL-018, FL-019

**Finding.** The codebase owns a guarded upload path — `Webservice::handle_upload_file()` (:169) and `handle_upload_file_compulsory()` (:205) check extension **and** MIME against the school-configured `Filetype_model` lists plus a size cap — and then bypasses it in the money-adjacent flow:

- `addofflinepayment()` (:5096) performs **no validation at all**: no form rule for `file`, and if `$_FILES['file']` exists it runs `move_uploaded_file(..., $upload_path . time() . "-" . uniqid(rand()) . "!" . $name)` (:5160-5163) with `$name` the **unsanitised client filename**, into `../uploads/offline_payments/`. Double extensions, path characters and executable types all pass. The same naming anti-pattern lives in the shared helper `Media_storage::fileupload()` (`libraries/Media_storage.php:33` — `time() . "-" . uniqid(rand()) . "!" . basename($original_name)`), used by homework submission (:1097), profile-photo upload (:3409) and course-assignment upload (:6140).
- `uploadDocument()` (:3517) does validate via `handle_upload_file_compulsory`, but stores under the original basename (spaces → underscores only, :3555-3558) inside `uploads/student_documents/<student_id>/`: predictable URLs, and a second upload of the same filename **silently overwrites** the first document.
- `uploadDocument()` also `die("Error creating folder $upload_path")` (:3550) — a raw filesystem path to the client (FL-019).
- `Webservice::geeee()` (:34-37) is a leftover debug endpoint echoing server time to **any** caller, with no client gate and no session check (FL-018).

### 6.1 One strict upload helper (the pattern every fix below reuses)

Add `Webservice::handle_upload_file_strict()` beside the existing helpers, and a shared naming function in `Media_storage`:

1. **Presence semantics:** two wrappers — `strict_compulsory` (file required) and `strict_if_present` (validate only when a file was actually submitted; several flows, including offline payment, legitimately allow no attachment).
2. **Checks, in order:** PHP upload error code is `UPLOAD_ERR_OK`; size > 0 and ≤ the `Filetype_model` cap; extension (lowercased, from the *final* suffix only — a name like `receipt.php.jpg` is judged as `jpg`, and `receipt.jpg.php` as `php` and rejected) is in the configured allowlist **and not in a hard-coded deny-list** (`php, phtml, php3-8, phar, exe, com, bat, sh, cgi, pl, py, rb, jsp, asp, aspx, shtml, htaccess` — the deny-list sits *beneath* the admin-configured allowlist, so a misconfigured allowlist cannot re-admit executables; this pulls the highest-value slice of FL-069 forward into Wave 1 for these paths, with the full helper hardening remaining Wave 2 as the register assigns); **server-side** MIME via `finfo_file()` on the temp file (never `$_FILES['file']['type']`, which is client-supplied — the existing helpers' known weakness) is in the configured MIME allowlist; for image types, `getimagesize()` must parse the file.
3. **Stored name:** `bin2hex(random_bytes(16)) . '.' . $validated_extension` — 128-bit random, no client input, no timestamp, no original name. The original filename, when a flow needs it for display, is stored as a **database metadata field only**, never as a path component.
4. **Failure shape:** validation failure behaves exactly like the existing helpers (form-validation message, endpoint returns its usual `status "0"` error array) — no new client-visible contract.

### 6.2 Offline-payment upload — FL-015

In `addofflinepayment()`:

1. Add the `file` rule via `strict_if_present` semantics (implement as: when `$_FILES['file']['name']` is non-empty, run the strict checks inside the validation phase; when absent, skip — preserving today's "payment without attachment" flow).
2. Replace the `time()-uniqid-"!"-$name` construction and bare `move_uploaded_file()` with the §6.1 stored name; `$data['attachment']` records the randomised name. Existing rows keep pointing at their existing files (no rename of history — old attachments remain reachable by the names already stored in `offline_payments.attachment`).
3. The §3 guard for this endpoint (`guard_student_session` on the body's `student_session_id`) lands in the same change — validation without ownership would still let any parent attach receipts to another child's fee record.
4. Audit row on successful creation (§7.3), including the stored filename and the SHA-256 of the uploaded bytes (cheap integrity anchor for a money-adjacent artefact).

### 6.3 Student documents — FL-016 (+ the `die()` — FL-019)

In `uploadDocument()`:

1. Validation stays `handle_upload_file_compulsory`-based but is swapped to `strict_compulsory` (§6.1), so the executable deny-list and server-side MIME apply here too.
2. Stored name becomes the §6.1 randomised name; `student_doc.doc` records it, `student_doc.title` keeps carrying the human label the app already sends. Same-named uploads now coexist; nothing overwrites. The per-student directory (`uploads/student_documents/<student_id>/`) is kept — with an unguessable filename inside it, the predictable directory name no longer yields a predictable URL.
3. The `die("Error creating folder $upload_path")` is replaced by: `log_message('error', 'SEC upload folder create failed: ' . $upload_path)` server-side, and the endpoint's own existing failure idiom to the client — HTTP 200 `{"status": "0", "error": {"file": "Upload failed. Please try again."}}`. `mkdir` gains the recursive flag + `0755` explicit mode so the failure itself becomes rarer.
4. The §3 guard (`guard_student` on `student_id`) lands in the same change; `getDocument()` (:919) is already in Group S1.

**Same randomisation, applied in the same pass** (identical one-line naming swap at each `move_uploaded_file` / helper site, all behind guarded validation that already exists at those call sites): leave documents in `addLeave()` (:146) and `updateLeave()` (:310) — today `<leave_id>.<ext>`, trivially enumerable; daily-assignment attachments (:4446, `<insert_id>.<ext>`); timeline documents (:4661, `<insert_id>.<ext>`); and `Media_storage::fileupload()` itself (:33), whose fix automatically covers homework submissions, profile photos and course assignments. Sites already using unpredictable-ish names (`saveOnlineExam`/`saveOnlineCourseExam` attachments, `time() . uniqid()` at :1399/:6397; `Customlib::uniqueFileName()` at :4286) keep their names in Wave 1 — they are validated and not client-controlled — and are normalised in Wave 2's sweep.

### 6.4 Storage location and execution defence

- **Location unchanged in Wave 1:** files stay under the configured `upload_path` (`config.php:529`, `"../uploads"`) in their existing subdirectories (`offline_payments/`, `student_documents/<id>/`, `student_leavedocuments/`, …). Moving the tree is FL-071 (Wave 2) and would break every stored filename reference if rushed. What changes now is only *what the files are called* and *what may become a file*.
- **Execution defence (configuration, staging-verified):** drop an `.htaccess` into `uploads/` (and confirm it is honoured on Hostinger's Apache) containing script-execution denial for the uploads tree (`php_flag engine off` where permitted, plus a `FilesMatch` deny on script extensions, `Options -ExecCGI`); where the host ignores `.htaccess` controls, the §6.1 deny-list + randomised names are the operative control and the limitation is recorded in the staging change log. Add a blank `index.html` to any uploads subdirectory lacking one (directory-listing hygiene, matching the convention already used across `application/`).
- Existing already-uploaded files are **not** renamed or moved (their names are already stored in the database); the residual predictability of historical leave/document filenames is accepted for Wave 1 and shrinks as new uploads dominate. A historical-rename sweep with DB updates is a Wave 2 data task if the owner wants it.

### 6.5 Debug-surface removals

- `geeee()` (:34): **delete the method.** With CI's default routing, the URL then 404s — which is the register's acceptance test. No replacement endpoint; server time is available from any response's `Date` header.
- The `uploadDocument()` `die()`: replaced per §6.3.3. A tree-wide grep for `die(`/`exit(` with variable interpolation in `Webservice.php` is part of the same change; any further path-leaking instance found gets the same log-server-side / generic-client treatment.

### Staging acceptance tests — §6

- [ ] Offline payment with a valid receipt image: accepted, stored under a 32-hex-character name, viewable through the normal flow; the DB `attachment` value matches the stored name.
- [ ] Offline payment with: an executable renamed to `.jpg`; a true script file; a double extension (`x.php.jpg` passes as image only if bytes are an image; `x.jpg.php` rejected); a spoofed MIME (script bytes claiming `image/jpeg`); an oversize file — each rejected with the endpoint's standard validation shape, and **no file appears** in `uploads/offline_payments/` for the rejected cases.
- [ ] Offline payment with no attachment still succeeds (flow compatibility).
- [ ] Two documents with identical original filenames uploaded for one fixture student: both stored, both listed, both downloadable, neither overwrote the other; neither URL contains the original filename.
- [ ] Document upload with the per-student directory made unwritable on staging returns the generic JSON failure and the staging application log contains the real path (client body does not).
- [ ] Leave, timeline, daily-assignment and homework uploads after the naming swap open correctly from their respective list screens; profile-photo upload still renders.
- [ ] `GET webservice/geeee` on staging returns 404.
- [ ] A script file placed in staging `uploads/` by hand cannot be executed via its URL (hosting control verified or limitation recorded per §6.4).
- [ ] Family app regression: offline-payment submission and document upload from the current app build succeed against staging.

---

## 7. (g) Cross-cutting controls — FL-014, FL-020, audit logging, FL-027

### 7.1 Login throttling and lockout — FL-014

**Finding.** No rate limiting or lockout exists anywhere in `Auth::login()`, `Auth_model`, `Staffauth` or (per the audit) the web logins — against plaintext-compared credentials (§1) this is the most urgent interim exposure, and it remains necessary after hashing (credential stuffing does not care how the password is stored).

**Design — one library, three integration points.** New `application/libraries/Login_throttle_lib.php` (identical in both trees), backed by one table:

```sql
CREATE TABLE IF NOT EXISTS `api_login_attempts` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `scope` ENUM('account','ip') NOT NULL,
  `key_hash` CHAR(64) NOT NULL,              -- sha256 of lowercased username, or of the IP; raw identifiers are not stored
  `success` TINYINT NOT NULL DEFAULT 0,
  `attempted_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_attempt_lookup` (`scope`, `key_hash`, `attempted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

Integration points: `Auth_model::login()` (family API — covers student + parent), `Staffauth::staff_login()` (staff API), and the web login controllers in the web tree (same library, staging-verified). The flow at each point is identical: **check → attempt → record**. `check()` runs before credential verification; a locked key short-circuits to the failure response without touching the credential check (so lockout state cannot be used as a password oracle).

**Policy (concrete values):**

| Counter | Threshold | Consequence |
|---|---|---|
| Per account (username hash) | 5 failed attempts in a rolling 15 minutes | Account lock: further attempts refused for 15 minutes; each subsequent lock within 24 h doubles the duration (30, 60, 120 minutes, cap 2 h) |
| Per IP | 30 failed attempts in a rolling hour across accounts | IP lock for that **account+IP pair** set (not a blanket IP ban — see NAT note) for 30 minutes |
| Per IP, extreme | 100 failed attempts in a rolling hour | Blanket IP refusal of login attempts for 30 minutes (credential-stuffing signature; a genuine school NAT will not produce 100 failures/hour) |
| Forgot-password issuance | §1.7 limits (3/account/hour, 10/IP/hour) | Same table and library |

- **Response shape (compatibility-critical):** a throttled login returns the *normal failure envelope* — API: HTTP 200 `{"status": 0, "message": "Too many attempts. Please try again later."}`; web: the panel's ordinary "invalid credentials"-style error with the same try-later wording. A distinct HTTP 429 is **not** used for login, because current app builds parse the 200/`status 0` shape; 429 is reserved for any future non-login rate limiting. The message does not reveal whether the account exists (counters are keyed by the *submitted* username hash, real or not).
- **Success clears the account counter** (delete that account key's failure rows on successful login); IP rows age out naturally. A nightly prune (the §7.2 housekeeping job) deletes attempts older than 7 days.
- **NAT reality:** the school office, and many families behind carrier-grade NAT, share IPs. That is why the primary control is per-account, why the mid-tier IP control is pair-scoped, and why the blanket tier is set at a level (100/hour) that legitimate shared use cannot reach. Locking a *family's account* never locks the office's other accounts.
- **Admin unlock:** an office runbook procedure (delete the account key's rows) plus, when §5.5's admin endpoint ships, a `family_sessions`-adjacent unlock action. No self-service unlock in Wave 1 (it would defeat the control); the lock durations are short enough for a school office workflow.
- Throttle events (lock start, blanket-IP trigger) are written to the application log as `SEC throttle …` lines (§7.2) and to the audit log (§7.3) at lock-start only, not per attempt.

### 7.2 Application logging — FL-020

**Finding.** `application/config/config.php:221` sets `$config['log_threshold'] = 0` — CodeIgniter writes nothing. Incidents, 500s and (§4) errors currently leave no application-side trace.

**Settings (both trees; staging first):**

- `$config['log_threshold'] = 1` (errors) in production-bound configuration. CI3 thresholds: 1 = Error, 2 = Debug, 3 = Info, 4 = All. Production runs at **1**: it captures `log_message('error', …)` — which is exactly the level §4.3's envelope, §1.3's rehash failures, §6.3's upload failures and all `SEC …` security events in this document are written at — without debug noise or per-request volume. Staging may run at 4 **during a named debugging window only**, and returns to 1 for acceptance testing, so staging proof reflects production behaviour.
- `$config['log_path']` stays default (`application/logs/`, which exists in the tree) unless the staging writability check fails, in which case it is set to an absolute path outside the web-served application tree where Hostinger permits — decided by the staging check, recorded in the change log. `$config['log_file_permissions']` tightened from the shipped 0644 to 0600 if the staging PHP user owns the files (verify; shared-hosting realities decide, and the attempt is recorded either way). Add a deny-all `.htaccess` in `application/logs/` if the directory is web-reachable on this vhost layout (verify on staging; the API's rewrite rules already route non-file requests to `index.php`, but log files are real files and would be served directly if the path were guessed).
- **Rotation reality on shared hosting:** CI writes one file per day (`log-YYYY-MM-DD.php`) and never deletes. There is no logrotate for application files on Hostinger shared hosting. The control is therefore a **housekeeping cron**: a small CLI-only controller (`Secops::prune_logs`, callable only via `is_cli_request()`) deleting log files older than **30 days** and `api_login_attempts` rows older than 7 days (§7.1), run weekly from an hPanel cron job. Expected volume at threshold 1 is small (errors + security events); the prune job also emits a one-line `SEC housekeeping` summary (files deleted, disk used by `application/logs/`) so silent disk growth is itself observable. If the hPanel cron cannot be created (plan limits), the fallback is the same controller invoked by the office's monthly checklist — recorded as an operational task, not left as a hope.

### 7.3 Audit log for money and record writes

**Finding.** The vendor API writes no actor-stamped audit row for anything (grep `audit` across the API tree: zero — Lane A §2.12/§4.8). "Who collected this cash, who edited this student, who uploaded this receipt" is unanswerable from API-side data. The staff extension's `api_sync_log` (`client_txn_id` UNIQUE + endpoint + `users_id` + stored response) proves the pattern on this database; this design generalises it.

**Table (additive, extension-owned naming to survive vendor updates):**

```sql
CREATE TABLE IF NOT EXISTS `api_audit_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `actor_type` ENUM('family','staff','admin','system') NOT NULL,
  `actor_users_id` INT NULL,                 -- family actor: users.id from the session (§3.2), never from the body
  `actor_staff_id` INT NULL,                 -- staff actor: staff.id from api_staff_sessions
  `action` VARCHAR(64) NOT NULL,             -- e.g. password.rehash, password.set, password.reset,
                                             --      auth.lockout, idor.denied, offline_payment.create,
                                             --      document.upload, profile.edit, leave.create, session.revoke
  `entity_type` VARCHAR(48) NOT NULL,        -- e.g. users, offline_payments, student_doc, student_leaves, students
  `entity_id` VARCHAR(64) NULL,
  `student_id` INT NULL,                     -- the child the record concerns, when applicable
  `before_hash` CHAR(64) NULL,               -- sha256 of the canonical before-state (see below)
  `after_hash` CHAR(64) NULL,
  `snapshot` TEXT NULL,                      -- redacted before/after JSON for non-money record edits (see rules)
  `client_txn_id` VARCHAR(64) NULL,          -- carried when the write already has one (staff-ext pattern)
  `ip_address` VARCHAR(45) NULL,
  `user_agent` VARCHAR(255) NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_audit_entity` (`entity_type`, `entity_id`),
  KEY `idx_audit_actor` (`actor_users_id`, `actor_staff_id`, `created_at`),
  KEY `idx_audit_student` (`student_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

**Hash/snapshot rules.** For money-adjacent writes, store **hashes, not copies**: `before_hash`/`after_hash` are SHA-256 over the canonical serialisation of the affected record's relevant fields (for the fee JSON world, over the exact `amount_detail` string), giving tamper-evidence and change-detection without duplicating financial data into a second table. For ordinary record edits (profile fields, leave status), `snapshot` may carry a before/after JSON **built from an allowlist of fields per entity** — credential fields (`password`, `verification_code`, tokens) are never snapshotted, under any entity, enforced inside the writer. Student PII in snapshots inherits the database's existing access controls; the table is never exposed through any family endpoint.

**Writer.** `Audit_lib::record($action, $entity_type, $entity_id, $opts)` (§0.4), resolving the actor from §3.2's identity context or the staff session — never from request parameters. **Fail-open:** if the audit insert fails, the business write proceeds and a `log_message('error', 'SEC audit write failed …')` is emitted. An audit outage must never take fee collection down with it; the log line makes the gap visible.

**Wave 1 write points** (the table and writer land with §1; coverage grows endpoint-by-endpoint within the wave): password rehash/set/reset/change (§1), login lockouts (§7.1), guard denials (§3.4, throttled as specified there), offline-payment creation (§6.2), document upload (§6.3), profile edit (`editprofile()`), leave create/update/delete, admin session revocations (§5.5). **Explicitly out of Wave 1 coverage:** vendor gateway fee deposits (they carry gateway-session evidence already and are reworked only under the fee-model programme), web-panel writes (the web tree gets the same writer when its Wave 1 items land; panel-side coverage is a Wave 2 completion item), and staff-ext writes (already covered by `api_sync_log` — cross-referenced, not duplicated; a unified audit *view* joining both tables is a reporting nicety for a later wave).

### 7.4 Two-factor authentication for staff/admin — FL-027 (configuration workstream)

**Position.** The capability already exists as the vendor add-on **"Smart School Two Factor Authentication v3.0"** (feature inventory: Setting + Setup 2FA screens). It is a web-panel add-on: its code is **not in the local tree** (§9), so this is designed as a *configuration and enrolment workstream on staging*, not a code build.

**Steps (all on staging first):**

1. **Verify presence and licence state** on staging: module listed and activatable in the panel; if the add-on is not installed or not licensed for this install, stop and report — procurement is an owner decision, not an engineering workaround. (Do not build a home-grown TOTP system in Wave 1 as a substitute; that is a larger security surface than the add-on.)
2. **Enable for the highest-privilege roles first:** Super Admin and Admin accounts enrol in the first session (authenticator-app TOTP per the add-on's flow); enforce "2FA required" for those roles before widening.
3. **Enrolment session discipline:** each staff member enrols their own authenticator; recovery/backup codes the add-on issues are printed and held by the school office under the same handling as other credential material (never in chat or documents); a named office procedure covers lost-device re-enrolment (admin resets the member's 2FA after identity check in person, and the reset is itself audit-logged once the web tree has the §7.3 writer).
4. **Widen** to Accountant and other staff roles with office access in a second step, once the first cohort has run for a week on staging without lockouts. Family accounts are **not** in scope — no family-facing 2FA in Wave 1.
5. **Known residual risk, stated plainly:** the add-on protects the **web panel** login. Staff **mobile** login (`Staffauth`) does not pass through it and remains single-factor (password + §5-class token + §7.1 throttling). That is accepted for Wave 1 because the staff app's blast radius is class-scoped (§3.1), and a TOTP step-up for `Staffauth` is recorded as the Phase-later follow-on — not silently forgotten.

### Staging acceptance tests — §7

- [ ] Throttling: 5 wrong-password attempts on a fixture family account → 6th attempt (even with the **correct** password) returns the try-later failure shape; after the lock window (tested via back-dated attempt rows), the correct password succeeds; a different fixture account from the same staging IP is unaffected by the first account's lock.
- [ ] Throttling applies identically on web portal login and `staffauth/login` (fixture staff account), and successful login clears the account counter.
- [ ] A scripted 100-failure burst from one source triggers the blanket tier and a `SEC throttle` log line; normal fixture logins from another source continue.
- [ ] Logging: with `log_threshold = 1`, the §4 `Secprobe` failures and a forced 500 produce timestamped entries in `application/logs/log-<date>.php`; a day of normal regression traffic produces no per-request log spam; log files are not fetchable over HTTP from the staging vhost.
- [ ] Housekeeping: `Secops::prune_logs` refuses non-CLI invocation (404/403), and a CLI run deletes only files/rows older than the retention windows and logs its summary line.
- [ ] Audit: each Wave 1 write point (§7.3 list) produces a row with the correct actor (from session, proven by attempting a write with a spoofed body actor field — the row must still show the session actor), action, entity and, for a profile edit, a snapshot containing no credential fields; killing the audit table's availability (staging-only rename drill) leaves the business writes succeeding with `SEC audit write failed` in the application log.
- [ ] Offline-payment audit row's `after_hash` matches a recomputed SHA-256 of the stored record state.
- [ ] 2FA: staging Super Admin login cannot complete without the second factor and succeeds with it; a wrong TOTP is rejected and throttled by the panel flow; recovery-code path works once and is then invalid; a non-enrolled lower role behaves per the step-2/4 enforcement state; family logins are untouched by the add-on.

---

## 8. Wave 1 dependency and sequence summary

Ordering logic: config-only changes first (they reduce exposure with zero contract risk), then the payload purge (it shrinks what any token can steal), then the guard (it shrinks what any token can reach), with the credential migration's dual-read deployed early but its hash-writing flip only after both trees prove dual-read, and tokens last among the structural items because their glide clock should start from the safest possible state. The programme plan's 1A/1B/1C grouping is preserved.

| Step | Item | Type | Depends on | Flaws |
|---|---|---|---|---|
| 1A-1 | `db_debug = FALSE` + typo corrected, `save_queries = FALSE` (both trees, in place) | **Config only** | §4.4 checksum discipline | FL-012, FL-021 |
| 1A-2 | Application logging on (`log_threshold = 1`) + logs `.htaccess` check | **Config only** | — | FL-020 |
| 1A-3 | Uploads `.htaccess` execution denial + blank `index.html` files | **Config only** | Staging verification of host behaviour | supports FL-015 |
| 1A-4 | `geeee()` deleted; `uploadDocument()` `die()` → JSON + log | Small code | 1A-2 (logging target exists) | FL-018, FL-019 |
| 1A-5 | JSON error envelope (`MY_Exceptions` + `MY_Controller` re-parenting) | Code | 1A-1, 1A-2 | FL-012 |
| 1A-6 | Payload purge: Tier 1–3 SELECT fixes + `json_output` scrub + static gate | Code | — (do before guard so denial tests aren't polluted by leak data) | FL-010 |
| 1A-7 | Upload strict helper; offline-payment + document fixes; `Media_storage` naming | Code | §3 guard for `addofflinepayment`/`uploadDocument` lands in the same commits (steps may merge) | FL-015, FL-016 |
| 1A-8 | Login throttling (table + library + 3 integration points) | Code + 1 table | §1 S1 not required; ship early — it protects the plaintext era | FL-014 |
| 1A-9 | General Settings stops rendering the server path (web tree view change) | Web-tree code | Web staging tree access (§9) | FL-026 |
| 1B-1 | Password migration **S0–S1**: schema, `Credential_lib`, dual-read in both trees, model-layer hashing for new writes | Code + additive schema | Web staging tree access (§9); fixture set | FL-009 |
| 1B-2 | Forgot-password redesign (issuer + reset consumer + uniform responses) | Code (both trees) | 1B-1 (`set_password`), 1A-8 (issuance limits reuse throttle) | FL-022 |
| 1B-3 | Password migration **S2**: flag flip to `hash-on-login` (both trees, same session) | **Config flip** | 1B-1 acceptance green; users-table backup taken | FL-009 |
| 1B-4 | IDOR guard: `auth_context()` + guard helpers + Appendix A endpoint migration (incl. Group N authentication additions, FL-025 role-derived notifications) | Code | 1A-6 recommended first | FL-011, FL-025, FL-017 (test) |
| 1B-5 | Token redesign: `getToken()`, expiry rewrite, legacy-cap UPDATE, session pruning | Code + data UPDATE | 1B-4 (shared session validator) | FL-013 |
| 1B-6 | Audit log table + `Audit_lib` + Wave 1 write points | Code + 1 table | 1B-4 (actor context); earlier steps emit `SEC` log lines until this lands, then dual-write | (Lane A §2.12) |
| 1C-1 | Change-password endpoint (§1 W4) | Code | 1B-3 | FL-024 |
| 1C-2 | Admin family-session listing/revocation endpoint (§5.5) | Code (extension-style) | 1B-5 | FL-013 |
| 1C-3 | 2FA add-on: verify, enable, enrol Super Admin/Admin (§7.4) | **Configuration workstream** | Add-on presence/licence verified on staging | FL-027 |
| 1C-4 | Staff-token lifetime alignment (`api_staff_sessions` → §5.2 values) | Code (staff-ext) | 1B-5 pattern proven | FL-013 (staff side) |
| Close | Coverage report (scheme %, token population, audit volume); bulk-hash decision paper to owner (§1.6); full security regression suite re-run; production checksum manifest re-verified | Reports | All above | — |

**Hard dependencies, stated once:** nothing that *writes* a hash (1B-3, 1C-1) may run before dual-read is proven in **both** trees (1B-1); the token glide clock (1B-5) starts only after the guard (1B-4) is live on staging; production rollout of any step is a separate owner approval after the whole wave's staging suite is green — steps are sequenced for staging, and are **not** separate production deployments unless the owner directs otherwise.

---

## 9. What could NOT be determined from local code — staging-tree access required

The local evidence is the **API tree** (byte-identical to production) plus the staff extension. The following items are load-bearing for the designs above and cannot be settled locally. Each names exactly what access or check resolves it. None of them blocks starting §4/§6/§2 (API-side) work; items 1–3 block the §1 flag flip (1B-3).

1. **The entire web application tree** (staff admin panel + student/parent portal: controllers, models, views) is absent locally. Needed on staging: (a) confirm the web tree's `User_model` matches the API tree's (same `checkLogin`/`checkLoginParent`/`checkOldPass`/`saveNewPass` semantics) or diff it; (b) find every web login controller and every `users`-writing controller (admission, online admission, imports, "login details" screens) for §1 W2/W3/W6; (c) grep the web tree for `user_tbl_password` consumers (§2 Tier 3), for direct-SQL `INSERT INTO users`, and for `Enc_lib->encrypt` uses beyond forgot-password; (d) the web `database.php`/`index.php` for the §4 fixes; (e) the General Settings view for FL-026 (step 1A-9); (f) whether the web portal login shares `users_authentication` with the API or keeps its own session mechanism (decides whether §5.3's token-storage note and §5.5's revocation reach web sessions).
2. **The web reset-password consumer** (`site/user/resetpassword/…`): the API-side issuer is fully visible, but the page that validates `verification_code` and saves the new password is web-tree code. The audit describes its token as `md5(uniqid(rand()+time()))`, while the local API issuer uses `Enc_lib::encrypt(uniqid(mt_rand()))` — the discrepancy itself proves the two trees diverge here and both must be read on staging before §1.7 is built. Also to confirm there: whether the save path is `User_model::saveNewPass()`.
3. **Live schema facts** (staging DB, read-only): `users.password` and `users.verification_code` column types/lengths (§1.1 alters are conditional on these); `users_authentication` full definition (does `created_at` exist? `token` width? indexes?); whether any `users` rows already hold hashed values; the `users.role` census (any non-student/parent rows); `filetypes` table's configured extensions/MIMEs/size (§6 allowlist reality); `students`/`student_session` key structure assumed by §3's resolvers (verified in code, to be confirmed against the live schema).
4. **The 2FA add-on's presence, version and licence state** on the install (inventory lists the add-on's screens; nothing local proves it is installed). Resolved by the §7.4 step-1 staging check; if absent/unlicensed, FL-027 becomes an owner procurement decision.
5. **Hostinger shared-hosting behaviours** that decide configuration options: whether `uploads/` and `application/logs/` `.htaccess` controls (`php_flag`, `FilesMatch`, deny rules) are honoured; whether `application/logs/` is web-reachable; PHP version (affects `password_hash` defaults and `random_bytes` availability — both assumed modern, both to be confirmed by the staging probe in §4.2); hPanel cron availability for §7.2 housekeeping; whether a per-vhost `display_errors` php.ini control exists.
6. **Client behaviour that only the real apps can prove:** the Family app's handling of HTTP 403 (§3.4 fallback decision), of the uniform forgot-password response (§1.7 step 5), and of the §5 401-expired body mid-session; whether any app screen renders a field removed by §2 (Tier 1 rows) — all covered by staging regression with the current builds, listed here because no amount of code reading substitutes for them.
7. **Vendor-update surface:** whether Smart School patching overwrites `application/models`, `application/core` and `application/helpers` in place (decides how the programme carries these changes forward — override copies + a patch manifest are recommended in the programme plan's pipeline rules, but the update mechanism itself is not in local evidence).

---

## Appendix A — `Webservice.php` endpoint census for §3 (all 143 public methods)

Classification key: **S1** guard on body `student_id` · **S2** guard on `student_session_id` · **S3** guard via object ID · **U** self-user guard · **R** authenticated-only (reference data) · **N** gains authentication in this wave · **X** not an endpoint (helper/internal) · **P** public-by-design (pre-auth flows).

| Group | Endpoints |
|---|---|
| **S1** | `getApplyLeave`, `addLeave`, `getStudentProfile`, `dashboard`, `getDocument`, `getHomework`, `getstudentsubject`, `addhomework`, `getOnlineExam`, `getOnlineExamQuestion`, `getOnlineExamResult`, `saveOnlineExam`, `getExamList`, `getAttendenceRecords`, `getAttendenceRecords1`, `examSchedule`, `getlessonplan`, `getsyllabussubjects`, `fees`, `class_schedule`, `getExamResult`, `getLibraryBookIssued`, `getTransportroute`, `gettransportroutes`, `getHostelList`, `liveclasses`, `livehistory`, `gmeetclasses`, `gmeethistory`, `profileUpdateFields`, `editprofile`, `uploadDocument`, `courselist`, `coursedetail`, `coursecurriculum`, `getquestionbyquizid`, `quizresult`, `saveanswer`, `submitquiz`, `resetquiz`, `markascomplete`, `courseperformance`, `addCourseRatingandReview`, `saveCourseAssignment`, `getSubmitedAssignmentDetails`, `adddailyassignment`, `getdailyassignment`, `addeditdailyassignment`, `getVisitors`, `getTimeline`, `addedittimeline`, `getstudentbehaviour`, `addincidentcomments`, `getstudentcurrentcurrency`, `updatestudentlanguage`, `updatestudentcurrency`, `getStudentCurrency`, `lock_student_panel`, `getOfflineBankPayments`, `getProcessingfees`, `searchuser`, `addChatUser`, `addforummessage`, `getDownloadsLinks`, `cbseexamtimetable` (derives session from the guarded student read) |
| **S2** | `getBalanceFee`, `addofflinepayment`, `cbseexamresult` (also **N**) |
| **S3** | `updateLeave`, `deleteLeave`, `deletetimeline`, `deletedailyassignment`, `deleteincidentcomments`, `getincidentcomments`, `deleteforummessage` (also **U-auth**), `getAppliedDiscounts`; `getHomeworkById` = authenticated-only exception (class content), recorded in §3.3 |
| **U** | `addTask`, `updatetask`, `deletetask`, `getTask` (all also gain `auth()` — today static-headers only), `Parent_GetStudentsList`, `checkStudentStatus` |
| **R** | `getSchoolDetails`, `getNotifications` (role-derived audience, FL-025), `getSubjectList`, `getSubjectTimetable`, `getClassTimetable`, `getTeacherSubject`, `getTeachersList`, `getExamSchedule`, `getexamscheduledetail`, `getSubjectsLessons`, `getsyllabus`, `getforummessage`, `getLibraryBooks`, `getTransportVehicleDetails`, `getDownloadsLinksById`, `getVideoTutorial`, `get_currency_list`, `getModuleStatus`, `getELearningModuleStatus`, `getAcademicsModuleStatus`, `getCommunicateModuleStatus`, `getOthersModuleStatus`, `getMaintenanceModeStatus`, `getStudentTimelineStatus`, `getTimeLineStatus`, `getFeesDiscountStatus`, `getOnlineCourseSettings`, `getOfflineBankPaymentStatus`, `getOfflineBankPaymentInstruction`, `checkProfileUpdate`, `getzoomsettings`, `getgmeetsettings`, `getCourseReviews`; course guest-flow endpoints `getCourseExamDetails`, `getOnlineCourseQuestion`, `saveOnlineCourseExam` per the §3.3 special case |
| **N** | `cbseexamresult` (no gates at all today), `coursedownloadcertificatepdf`, `downloadCertificateFile`, `deleteCertificateFile` (URL-segment endpoints gaining client-gate + session + guard); `show_qr` remains reachable per §3.3 trade-off |
| **P** | `forgot_password` (pre-auth by design; §1.7 redesign + §7.1 issuance limits), `logout` (operates on the caller's own presented token only — self-scoped by construction) |
| **X** | `__construct`, `validateCanUploadFile`, `handle_upload_file`, `handle_upload_file_compulsory`, `find_subject_array_exists`, `findSubjectAssessmentNotExists`, `forgotPasswordBody`, `getGradeByMarks`, `edit_handle_upload`, `getMarks`, `array_equal`, `getCertificateTextContent`, `getCertificateTextContent_for_template`, and the internal fee helpers `getStudentTransportFeetypeBalance`, `getStuFeetypeBalance`, `getNotAppliedDiscount` (not routed directly; reached only through guarded callers such as `getBalanceFee` — the build lane must confirm no route exposes them, and §3's staging matrix includes a direct-call probe for each) |
| **Removed** | `geeee` (§6.5) |

`Payment.php` (outside `Webservice.php`): `fees_pay()` gains `guard_student_session()` (§3.3); `pay($session_id)` is keyed by a server-side gateway session record rather than a family token and is out of §3's scope, with its student record load covered by §2's purge.

*End of document. Prepared by the CISO Office + Security Engineering workstream, 2026-11-07. Design only — no system was accessed or changed in its preparation; all evidence is from the local source trees cited.*
