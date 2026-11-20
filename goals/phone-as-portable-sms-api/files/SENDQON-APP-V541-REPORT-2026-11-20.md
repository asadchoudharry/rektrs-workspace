# Sendqon Gateway App v5.4.1 — Report (2026-11-20)

**Release:** `sendqon-gateway-own-v5.4.1.apk` · 4,587,543 bytes · SHA-256 `8ab5b9d12f2886e54042acf68755ca8921f47b7d8ad6f1f838834fc5a1ed1f40`
**Identity:** package `com.rektrs.sendqon`, version 5.4.1 / code 50401, signer `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee` (custody key, verified from the built APK with apksigner — in-place update over 5.4.0 holds)
**Source:** branch `app-own-android`, commits `1420e74` + `1af10f4` (pushed, ls-remote verified)
**Slot:** registered in the production `android_gateway` slot 2026-11-20T16:56:27Z (21:56:27 PKT) — proof in §6. (A first 5.4.1 build, sha `e0e8bbe2…`, was registered at 16:45:26Z and superseded eleven minutes later by this build — same version, folded-in field evidence, §1 — before any phone had taken 5.4.1.)

v5.4.1 is a single-purpose release: v5.4.0's balance check read **neither** of the owner's SIMs on his phone (field screenshot, 2026-11-20 16:08 PKT — both SIM cards showed "Couldn't read balance" with "checked now"). It hardens the parser against real carrier reply families, fixes the one thing no parser could fix (the Ufone default code pointed at the bundle-resources service, §2), reads multi-message USSD sessions whole, and carries the SIM 2 "Disabled" diagnosis (§5, report-only — no state was changed).

**Evidence note:** the lane began from public evidence (the owner never sent the Carrier-reply screenshots), and the corpus in §2 is marked **[S]** source-backed / **[I]** inferred accordingly. Mid-lane, the parallel sim_fleet lane captured the owner's phone's real sync panel-side (2026-11-20 16:46:48 UTC) — **the actual two replies are now known verbatim and are §1's root cause**; both were folded into this release before it closed (§3, verdict layer) and are pinned in the test corpus as field-verbatim [S]. Nothing about his actual balances is claimed anywhere in this report — neither reply contained one.

---

## 1. What the field failure actually was

**Root cause, from the phone's own synced raw replies** (panel-side capture, 2026-11-20 16:46:48 UTC — the checks behind the 16:08 PKT screenshot): at check time, **neither carrier returned a figure at all.**

- **Zong (SIM 1): the carrier deferred the inquiry.** Verbatim reply: **"Please try again later"** — a transient carrier failure. There was no balance in the reply to parse; v5.4.0's single "Couldn't read balance" label was the wrong story for it. In this release a deferral surfaces as a check failure — "Carrier busy — try again" (§3) — which is what it is.
- **Ufone (SIM 2): the carrier reported an empty SIM.** Verbatim reply: **"Dear customer, you have insufficient balance. Please recharge your account."** — the SIM held nothing (the same SIM the owner confirmed had no SMS balance). That is a verdict, not an unreadable reply and not "Rs 0": this release gives it its own state (§3) and never fabricates a number for it.

Two further defects stood behind the same screenshot, independent of what the carriers answered that day:

- **Ufone's default code was wrong.** v5.4.0 dialled `*706#` — per Ufone's own FAQ and every current code guide, the **bundle / Super Card resources** inquiry (minutes/SMS/MBs + expiry), whose substantive answer contains no money figure. The money-balance code is `*124#` (§2); v5.4.1 dials it.
- **The parser was narrower than real reply families.** v5.4.0 accepted only `Rs`/`PKR`/روپے-marked figures near the single English word "balance", and its multi-figure rule fell back to the *first* marked figure. Roman-Urdu markers and phrasings, Urdu-script replies, fee figures and validity dates (§2) defeat that logic; §3 is the hardened rule set, and §4 pins it.

## 2. Corpus — codes and reply families

Codes (all **[S]**):

| Carrier | Money-balance code | Sources |
|---|---|---|
| Zong | `*222#` | Zong's own payment-methods page (via pakera.pk); dareecha.pk (codes taken from operator sites, checked 2026-11-03); csinfo.pk |
| Ufone | `*124#` — `*706#` is bundle resources (minutes/SMS/MBs + expiry), *703# Super Card detail | Ufone's own FAQ (via pakera.pk); propakistani.pk code table ("Balance *124# / Super Card Balance *706#"); csinfo.pk; beyourownboss.pk ("*124# shows your base rupee balance"); apnsettings.org; tajassus.com |
| Jazz | `*111#` | Jazz FAQ (Rs 0.24/check, via pakera.pk and csinfo.pk) |
| Telenor | `*444#` | csinfo.pk; beyourownboss.pk (Telenor moved codes in late 2024; *444# is current) |

Reply families the parser is now pinned against (amounts in tests are illustrative, never the owner's):

| # | Family | Mark |
|---|---|---|
| 1 | Zong English: "Your current balance is Rs 250.75", optionally ", valid till 25/12/2026" | [I] wording; [S] that the reply shows balance + validity |
| 2 | Zong Urdu script: "آپ کا موجودہ بیلنس 250.75 روپے ہے" | [I] |
| 3 | Roman Urdu, no marker: "Apka mojuda balance 89.90 hai" / "Balance: 45" | [I] |
| 4 | Roman-Urdu markers spelled out: "120 Rupay", "120.50 Rupaye" | [I] |
| 5 | Ufone `*124#`: balance figure + account expiry date in one reply | [S] content (mobilebazaar.pk, newsimpackages.com, dakaan.pk all describe balance + expiry); [I] exact wording |
| 6 | Ufone `*706#`: "Remaining: 500 MBs, 100 SMS, 200 Mins. Expiry: 25-12-2026" — quotas only | [S] content; must NEVER parse |
| 7 | Jazz: "Rs. 12 remaining" | [S] quoted phrasing (beyourownboss.pk: 'The screen might say "Rs. 12 remaining"') |
| 8 | Fee figure in the same reply: "Rs 0.24 will be charged for this inquiry. Your balance is Rs 100.50"; a reply that is only "Rs 0.24 has been deducted for balance inquiry" | [I] |
| 9 | Main + bonus split: "Balance Rs 75.00. Bonus balance Rs 10.00" | [I] |
| 10 | Competing prices, no balance keyword: "Get 500MB in Rs 50 or 2GB in Rs 100" | [I] — must stay unread |
| 11 | Helpline/instruction lines: "Balance janne ke liye 333 dial karein", "Balance check karne ke liye *124# dial karen" | [I] — must stay unread |
| 12 | Multi-message session: "Please wait…" then the substantive reply; menu-only sessions | [I] |
| 13 | **Zong deferral: "Please try again later"** | **[S] field-verbatim** (owner's phone, 2026-11-20) |
| 14 | **Ufone empty SIM: "Dear customer, you have insufficient balance. Please recharge your account."** | **[S] field-verbatim** (owner's phone, 2026-11-20) |

## 3. Parser rules (v5.4.1)

The honesty contract is unchanged — a wrong number is worse than none — and now has three tiers, applied in order (all on digit-normalised text; Arabic-Indic digits map 1:1 so positions stay valid):

1. **Currency-marked figures win, keyword-anchored.** Markers: `Rs`, `Rs.`, `PKR`, روپے, plus the Roman-Urdu spellings `Rupay`/`Rupaye`/`Rupya` (word-bounded, so "rs" inside "yours" can't match). Anchors: *balance, credit, remaining*, Roman-Urdu *mojuda/mojooda/maujuda, baqaya/bakaya*, Urdu بیلنس، بقایا، موجودہ. The marked figure nearest an anchor wins.
2. **No keyword → single-figure fallback only.** Exactly one usable marked figure is accepted; several competing figures stay unread (corpus #10).
3. **No marked figure → one keyword-glued unmarked figure.** A decimal figure inside a keyword's phrase ("mojuda balance 89.90 hai"), or an integer punctuation-glued to a keyword ("Balance: 45"), is accepted when it is the only such figure (corpus #3).

**Exclusions on every path:** figures inside calendar dates (validity/expiry); figures glued to quota units (MB/GB/SMS/minutes/days — corpus #6); digits belonging to phone numbers, USSD codes (`*…#`) or longer digit runs; and **fee figures** — a figure whose clause names a charge and whose charge word sits nearer the figure than any balance keyword is the price of asking, never the answer (corpus #8; if every marked figure is a fee figure, the reply is unread).

**Sessions:** `BalanceChecker` now collects *all* messages a USSD session delivers (first message within the existing 30 s, then a grace window of 4 s of silence, capped at 15 s) instead of latching the first one. The full transcript is stored as the raw record, and `BalanceParser.parseSession` reads the **last** substantive message first, then earlier ones — an opening menu or acknowledgement can no longer shadow the reply (corpus #12). A menu-only session still ends UNPARSEABLE with the transcript one tap away.

**Verdicts, not just amounts:** on top of the amount parser sits a classifier (`BalanceParser.classify` / `classifySession`) with four outcomes, because a figureless reply is not automatically "unreadable" (§1 proved it twice in one screenshot). **AMOUNT** — a figure read with confidence, as above. **INSUFFICIENT** — the carrier's own empty-SIM wording ("insufficient balance/credit", Roman-Urdu *balance khatam*, Urdu بیلنس ختم): stored as its own status, displayed "Insufficient balance (carrier)", counts as low for the alert, and carries **no amount — Rs 0 is never fabricated**. **DEFERRED** — the carrier put the inquiry off ("try again", "temporarily unavailable", busy/unavailable phrasings; a lone short "Please wait" counts, a mid-session one cannot shadow a real answer because amounts and insufficient verdicts are read first): stored as a check failure with the note `carrier_deferred`, displayed "Carrier busy — try again" — a failure to retry, explicitly NOT "couldn't read". **UNREADABLE** — everything else, as before. The raw reply stays viewable under every outcome.

**Code change:** `BalanceCodes` Ufone default `*706#` → `*124#`, with the reason recorded in the code. Overrides are untouched: a code the user edited in Settings still wins, and because Settings only stores an override that differs from the default, the corrected default reaches every phone that never edited it — including the owner's.

## 4. Battery

JVM battery over the pure logic, **38 tests, all passing** (`OK (38 tests)`): the full v5.4.0 suite re-run for regressions (22 — parser 11, codes 2, threshold/gate/payload 5, battery-read 4; the codes test's Ufone expectation updated to `*124#`), 12 corpus tests covering §2 families 1–12 including every must-not-parse trap (bundle quotas, expiry dates, fee-only replies, competing prices, helpline numbers, menu-only sessions), and 4 field-evidence tests: both verbatim replies of §2 families 13–14 classify to their own verdicts with **no amount attached**, a deferral after an acknowledgement stays a deferral, an early insufficient message never shadows a figure delivered later in the session, and the carrier-insufficient state counts as low for the alert.

Run the v5.4.0 way, for the same reason: Gradle's test executor dies on this box, so classes were compiled by Gradle (`compileDebugKotlin` + `compileDebugUnitTestKotlin`, clean) and executed with JUnitCore 4.13.2 over the compiled classes. The battery earned its keep twice during development — both finds were in the new fee-clause logic, both fixed and re-pinned: (a) a fee figure in a clause that also contained the word "balance" ("…deducted for balance inquiry") initially counted as usable; the clause test now compares which word — charge or keyword — sits nearer the figure; (b) clause splitting initially broke on the decimal point inside "0.24" itself; a dot flanked by digits is no longer a clause break. Full debug + release builds are clean; nothing outside the balance feature was touched (Balance.kt parser/codes/verdicts, BalanceChecker session collection + verdict mapping, the Home balance line and its EN/UR strings, version bump, tests).

## 5. SIM 2 "Disabled" — diagnosis (report-only; nothing was changed)

**Where the state lives:** the panel, not the phone. Core's `sims` table, row id 4 (device 2 — the owner's phone on our app — slot 1, Ufone +923328776333): **`is_enabled = 0`**, `carrier_paused_at = null` (so this is the enable/disable flag, not a carrier pause), `is_active = 1`. The Zong row (id 3, slot 0) has `is_enabled = 1`.

**How the app gets it:** the app has no local per-SIM switch and no write path for this flag. The panel serves `sim_controls` (slot, enabled, carrier_paused) inside the device-settings payload and every pending-messages page; the app renders the pill from it (Enabled / Carrier paused / Disabled) and obeys it for **sending only** — the send loop skips a disabled SIM, receiving is never gated. That matches the field evidence exactly: SIM 2 showed "Disabled" while still receiving (1 received that day). The app's own SIM sync payload carries no enabled field, so neither the app nor the re-pair could have written it.

**Who set it:** the flag is writable only from the panel side — core exposes `POST api/v1/sims/{sim}/disable` and `/enable` (Api\V1\SimController), surfaced in the panel's per-device SIM management. The row keeps no audit columns, so *which* panel session flipped it is not recorded; its `updated_at` (2026-11-20 09:24:13 UTC, 14:24 PKT) is the re-pair sync touching both SIM rows and proves nothing about when the flag itself changed — only that it was already 0 by the time the phone came back and rendered it. It was not set by the app, not by the carrier, and not by this lane.

**Where the owner flips it back, if he wants:** Sendqon panel → Channels → Android → his device → SIM management — enable the Ufone SIM (the same per-SIM switch that disabled it; the SIM also appears on the SIM Fleet page). This lane deliberately did not call the enable endpoint: the diagnosis was the assignment, and for all anyone knows the disable was intentional.

## 6. Slot registration proof (production)

Via core `AppFiles::store()` as www-data (one bootstrapped run; APK staged host → container by tar-pipe, SHA-256 verified at every hop):

- Before: 5.4.0, sha `94740924…`, uploaded 2026-11-20T10:10:59Z (the first 5.4.1 build, sha `e0e8bbe2…` at 16:45:26Z, sat in the slot for the eleven minutes between the two registrations).
- After: **5.4.1**, sha `8ab5b9d1…`, size 4,587,543, package `com.rektrs.sendqon`, signer `eba2c40d…`, uploaded **2026-11-20T16:56:27Z (21:56:27 PKT)**.
- Offer matching (in-process `GatewayAppVersions::matches`): our signer → **true**; the real vendor cert `77f4e3df…` → **false** (empty offer).
- `required_at` = **2026-11-23T16:56:27Z (2026-11-23 21:56:27 PKT)** — registration +72 h exactly; `min_required_version` stays 5.0.0 until then.
- Signed download URL (the same `api.internal.android.app.download` link the update check hands out) fetched over HTTPS: **HTTP 200, 4,587,543 bytes, SHA-256 = `8ab5b9d1…`** — byte-identical to the built APK.
- Device rows 1 and 2 read identically before and after (id 2's `updated_at` moved only by its own live sync); staging files removed from container and host.

## 7. Honest limits

- **Live proof is still the owner's phone — one layer down.** The figureless-reply layer is now field-proven (§1: both real replies are known and handled by their own states). What remains unproven against a live carrier is a successful *money-figure* read: after his phone takes 5.4.1, a Zong check when the carrier actually answers exercises the hardened parser against the true `*222#` wording, and a Ufone check after a recharge (now dialling `*124#`) should show a money figure with its expiry date. Anything still unreadable keeps the raw reply one tap away ("Carrier reply"), and one screenshot of that dialog would pin the exact wording for a 5.4.2.
- **Super Card caveat:** on a Ufone Super Card line, `*124#` shows the base rupee balance, which is usually near zero because value sits in bundle resources (beyourownboss.pk). The app will report that figure honestly; if the owner's Ufone is a Super Card line and he wants the bundle view instead, the per-SIM code in Settings → SIM balance can be set back to `*706#` — whose reply will (correctly) stay "Couldn't read balance", since it contains no money figure.
- The balance check now holds a session up to ~15 s when a carrier drips multiple messages (4 s of silence ends it sooner); single-message replies — the normal case — pay only the grace window after the reply.
- The panel still does not store or display balance (core drops the sync fields — unchanged, no core patch); the phone remains the working surface.
- Dark theme remains knowingly unbuilt, as in v5.4.0.
