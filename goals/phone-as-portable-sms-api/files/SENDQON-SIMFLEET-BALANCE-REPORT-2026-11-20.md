# Sendqon — Panel-Side SIM Balance Surfacing (sim_fleet v1.1.0)

**Date:** 2026-11-20 · **Lane:** sim_fleet balance capture + display (the recorded follow-up from the v5.4.0 report §1) · **Authorisation:** owner "Proceed" (chat, 2026-11-20 21:23 PKT) + standing approval for routine lane tooling.

**Outcome: LIVE on production.** The panel now stores every SIM balance the gateway app reports and shows it on the SIM Fleet page. No core patch, no app change.

---

## 1. The capture route — evidence first

The gateway app (v5.4.0+) attaches five keys to each SIM entry of `PUT /api/v1/internal/android/device/sims` (reconstructed from the app source, `SimHelper.simsPayload` + `BalanceLogic.payloadFields`, branch `app-own-android` @ fb92573):

| key | value |
|---|---|
| `balance_amount` | parsed amount (number) or `null` when the reply could not be read |
| `balance_text` | the carrier's raw reply, ≤160 chars |
| `balance_checked_at` | ISO-8601 timestamp of the on-device check |
| `balance_status` | `never` / `ok` / `unparseable` / `failed` |
| `balance_low` | boolean — the phone's own verdict against its per-SIM threshold |

Core's `DeviceController::syncSims` validates only `slot / phone_number / operator / country` (+ companion blocks), so the balance keys are silently dropped and stored nowhere. The candidate routes:

- **(a) Event/listener during sync — does not exist.** `syncSims` dispatches no event; the `Sim` model events that do fire never see the balance values (validation strips them before any model write).
- **(b) Plugin-registered route — out of scope.** The app calls only core's endpoint and this lane does not change the app.
- **(c) Plugin middleware on the sync request — CHOSEN, proven on DEV.** Core's `PluginServiceProvider` registers every discovered tool plugin's provider on every request, API included. sim_fleet's provider now pushes `CaptureSimBalance` onto the `api` middleware group. The middleware is a strict observer: it passes every non-sync request through untouched, and for a sync it reads the raw payload only **after** core has produced its (unchanged) response, only on a 2xx, and inside a guarded block — a capture failure is logged and swallowed, it can never break a sync. It self-gates on the sim_fleet plugin row being `active`.
- **(d) Reading the values from wherever core leaves them — nowhere.** The dropped keys exist only in the request body, which is exactly what (c) reads.

**Storage:** a dedicated plugin table `sim_fleet_balances` (one row per SIM: `user_id`, `device_id`, `sim_id` unique, `balance_amount` decimal nullable, `balance_currency`, `balance_text`, `balance_status`, `balance_low`, `balance_checked_at`). A dedicated table — rather than the `health_detail` JSON on `sim_fleet_states` — because state rows are enrollment/tick-managed and the tick rewrites `health_detail`; balance reports arrive independently of enrollment. Capture rules: an entry carrying **none** of the balance keys leaves the stored row untouched (older app versions, SIMs with no check state); an unknown `balance_status` is refused, never stored; values are stored **exactly as reported** — an unread reply stays `amount = NULL, status = unparseable` with the raw text kept.

**Display:** the fleet page gains a **Balance** column — `Rs X · checked <relative time>` (+ a red **low** badge when the phone reports low), `couldn't read balance` with the carrier's raw reply shown, `check failed`, `Not checked yet` (app reported a never-checked state), and `Not reported yet` for SIMs that have never carried balance fields. Balances are loaded scoped by tenant `user_id`, like every other row on the page.

**Install mechanics finding (recorded for future plugin lanes):** `PluginManager::installFromZip` cannot complete an *update* when run as www-data on this stack — its backup step is an unchecked `@rename()` from the app overlay to the storage volume (cross-device, silently fails), and the app tree is not www-data-writable, so the subsequent copy dies with permission errors (DEV log 2026-11-20 16:27/16:30 UTC, both attempts rolled back cleanly by the manager). The installer therefore runs as **root** — the zip's stored modes land files root:root 0644/0755 — and every verification then runs **as www-data**. Fresh installs and updates both proven this way on DEV, then production.

## 2. DEV battery (sendqon-dev, zender_dev) — 26/26 + 3 supplementary

Fixtures: device 2 (tenant user 36, SIMs Jazz/Zong) and device 1 (tenant user 1), real HTTP syncs with the app's exact header set and payload shape.

- **Capture:** sync with `ok` 32.75 + `balance_low=true` and `unparseable` + raw text → both rows stored verbatim (amount NULL + raw kept for the unread SIM) · entry without balance keys → stored row untouched · `failed` status stored · a brand-new SIM created by core's own sync got its balance row in the same request · unknown/failed validation (slot 99) → core's 422 unchanged and **no** balance write.
- **Core regression:** every sync response byte-identical in shape (`{synced, sims:[{slot, phone_number, is_active}]}`); sync behaviour unaffected with the plugin inactive.
- **Plugin gate:** with sim_fleet flipped `inactive`, syncs still returned 200 and **nothing** was captured; back to `active`, capture resumed.
- **Display + tenant isolation (UI-surface checks):** tenant 36's page showed `Rs 32.75`, the low badge, `check failed`, later `Rs 999.99` and `couldn't read balance` + the raw reply; tenant 1's page showed only its own `Rs 500.00`; neither page leaked the other tenant's amounts or raw text (asserted both directions, two rounds).
- **Honest empty state (supplementary):** a SIM synced without balance keys renders `Not reported yet` beside a sibling SIM's real balance.
- **www-data probes:** all plugin files readable, all four new/changed classes load, model reads rows — as www-data.
- **Logs:** the battery window (16:37–16:50 UTC) added no ERROR entries and no capture warnings. (One DEV ERROR at 16:31:43 UTC — a core count against a `messages` table the DEV fixture schema lacks — predates the battery, is unrelated to this plugin, and is recorded here only so it is not rediscovered as a mystery.)

## 3. Production

- **Backup first:** `backup.sh` run 2026-11-20 16:35 UTC — `status=OK`, db 8,959,553 B / config 30,003,681 B / storage 50,328,173 B, all three artifacts `gzip -t` clean, `push=OK`.
- **Pre-state:** sim_fleet v1.0.1 active; no `sim_fleet_balances` table; device 2 on app 5.4.0, SIMs id 3 (Zong +923180735877) and id 4 (Ufone +923328776333).
- **Install:** `sim-fleet-1.1.0.zip` (md5 `e4eac0a6b571bd747b665b85a01f85d6`) via `PluginManager::installFromZip` as root → plugin row **v1.1.0, active**, both manifest migrations recorded; views cleared.
- **Verification as www-data:** every plugin file readable (sweep), all classes load, table present, `balance_rows=0` at install (honest start — nothing fabricated for the owner's SIMs); unauthenticated `GET /sim-fleet` → 302 (route + middleware stack healthy); site home 200.
- **First real report — captured from the owner's own phone, same evening:** a 10-minute watch after install caught device 2's next balance-carrying sync at **16:46:48 UTC**. Both rows landed verbatim: SIM id 3 (Zong) — `unparseable`, amount NULL, raw reply *"Please try again later"*, checked 16:45:48 UTC; SIM id 4 (Ufone) — `unparseable`, amount NULL, raw reply *"Dear customer, you have insufficient balance. Please recharge your account."*, checked 16:45:50 UTC. No amount was invented for either: Zong's session returned a try-again message this time, and Ufone's reply is the known empty-SIM answer. The fleet page now shows both SIMs as *couldn't read balance* with the carriers' own words attached — the honest state, end to end: real phone → real sync → capture → panel. Production log for the install + capture window: zero capture-failure warnings, zero ERROR entries.

## 4. Honest limits

- **Currency is PKR by construction, not by payload.** The payload carries no currency key; the app's parser accepts only rupee-marked figures (Rs / PKR / روپے), so stored amounts are PKR and the column is stored as such.
- **The low flag is the phone's verdict** against the threshold set on the phone (default Rs 50); the panel does not recompute it.
- **The panel shows only what syncs carry.** A SIM whose app has never run a balance check shows `Not reported yet` / `Not checked yet`; the fleet page is a mirror of the phone's reports, not a live carrier query.
- **Parsed amounts display only when the phone itself parsed one.** The owner's first captured reports were both `unparseable` (carrier wording, not a panel gap); the first `ok` report — from a check whose reply carries a rupee-marked figure — will render as `Rs X · checked …` exactly as proven on DEV.
- DEV fixtures (device session hashes, web passwords for users 1/36, test balance rows) were created/changed inside the DEV sandbox only; production fixtures were not touched.
- The plugin source branch is `plugin-sim_fleet` (underscore — the name the remote has always carried).

## 5. Pushes

- Plugin source: Sendqon repo branch `plugin-sim_fleet` 94777f1 → **6e6df18** (ls-remote verified).
- This report: Sendqon `rebuild-tree` planning/ + rektrs-workspace `main` goals/phone-as-portable-sms-api/files/ — hashes in the lane summary.
