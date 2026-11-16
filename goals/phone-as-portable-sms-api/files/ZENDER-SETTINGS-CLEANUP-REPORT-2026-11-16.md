# Sendqon — Admin Settings Cleanup Report (2026-11-16)

**Scope:** the settings cleanup the browser lane could not finish (the admin session had signed out), done server-side through the app's own settings mechanism on the LIVE Sendqon (Zender 5.0.4) app on offbox-1, plus installation of the bundled Bank Transfer payment-gateway plugin.

**Result: COMPLETE, with one owner-input blocker.** Every stored demo value in scope was cleared or corrected; most of what the browser lane suspected turned out to be **UI placeholders, not stored values** (proven below). The Bank Transfer plugin is **installed** via the vendor mechanism; its **activation is refused by the vendor's own code until real bank details are configured** — no bank details were invented or entered (§5).

---

## 1. Mechanism used (the app's own save path — no raw SQL)

- Reads and writes went through `App\Models\SystemSetting` — the exact class the admin `SettingsController` saves with (`SystemSetting::set($key, $value, $type, $group)` per key, inside the controller's transaction). Encryption of `encrypted_json` keys and all cache invalidation (per-key cache, group cache rebuild, model `saved` hooks) are handled inside that class, so nothing was bypassed.
- Plugins went through `App\Services\PluginManager` (`install()` / `activate()`) — the same code path as the admin UI's Install button and the vendor's own seeders.
- No secret value was printed at any point; secret-adjacent fields are reported as presence/length only. No app container was restarted or recreated by hand (one vendor-mechanism side effect is disclosed in §5).

## 2. Ground truth — what was actually stored (before)

Read via `SystemSetting::get()` / `getGroup()` in a fresh process:

**Group `contact`** — all demo-suspect fields were **already stored empty**; nothing to clear:

| Key | Stored value |
|---|---|
| contact_email | `asadchoudhary@rektrs.com` ✓ (already correct) |
| contact_phone | empty string |
| contact_whatsapp_number | empty string |
| contact_facebook_url / contact_x_url / contact_instagram_url / contact_linkedin_url / contact_youtube_url | empty strings |

**Group `custom_code`:**

| Key | Stored value |
|---|---|
| custom_code_enabled | `true` |
| custom_head_code | NULL (no row value — no code stored) |
| custom_footer_code | NULL (no code stored) |
| custom_css | NULL (left untouched, per scope) |
| custom_head_code_category / custom_footer_code_category | `marketing` (consent categories — not code; untouched) |

**Group `mail`:**

| Key | Stored value |
|---|---|
| admin_recipient | NULL (never set) |
| driver | `log` (no delivery — owned by the SMTP step, not touched) |
| from_address | `hello@example.com` ⚠️ a real **stored** demo value — owned by the SMTP step, **not touched** (see §4) |
| from_name | NULL |
| host / username | NULL |
| password (SMTP) | EMPTY |
| port / encryption | 587 / tls |
| server_alerts_enabled | `true` |

**Group `auth` — social sign-in:** `google_client_id`, `facebook_client_id`, `github_client_id` all **NULL**; the three client secrets **EMPTY**. Nothing fake is stored — the providers are simply unconfigured.

## 3. The demo-value hunt — where "Main Street" / "example.com" / "555" actually live

Every row in `system_settings` was searched (decrypted string values, plus a second pass over json/array values) for `Main Street`, `example.com`, `555`, `Austin`:

- **Exactly one hit in stored settings:** `mail.from_address = hello@example.com`.
- **"Main Street" is not stored anywhere in settings.** Its only occurrence in the codebase is a sample content block inside the campaign email-builder's frontend defaults (`resources/js/components/campaigns/email/builder/design.ts` — "Visit us at 120 Main Street, Austin, TX 78701" in a starter block), not a setting and not rendered on this site unless a user builds a campaign from that block.
- **"555" numbers are input `placeholder=` attributes** in the React UI (e.g. Sender IDs page `+1 201-555-0100`, contacts import dialog, subscribe-form fields, campaign create) — they show as grey hint text in empty fields and are never saved.

**Conclusion:** the browser lane's suspicion is confirmed — the contact/address/phone values it saw were form placeholders over empty stored fields. The contact group needed no changes.

## 4. Changes applied (before → after, re-read in a fresh process)

| Key (group) | Before | After | Note |
|---|---|---|---|
| `custom_code_enabled` (custom_code) | `true` | **`false`** | Load Custom Code toggle OFF — no custom code can load on public pages |
| `custom_head_code` (custom_code) | NULL (nothing stored) | **empty string** | Explicitly cleared via the save path |
| `custom_footer_code` (custom_code) | NULL (nothing stored) | **empty string** | Explicitly cleared via the save path |
| `admin_recipient` (mail) | NULL | **`asadchoudhary@rektrs.com`** | Admin notification emails (alerts + new support tickets) now go to the owner |

**Deliberately NOT touched:**
- `custom_css` — left exactly as found (NULL), per scope.
- Mail `driver`, `from_address`, `from_name`, `host`, `port`, `username`, `password`, `encryption` — the SMTP step owns these. ⚠️ **Handover for that step:** `from_address` still holds the stored demo value `hello@example.com` and `driver` is still `log`; both must be replaced when SMTP is configured, or outgoing mail will keep the demo sender and go nowhere.
- Contact group — no changes needed (§2/§3).
- Social sign-in client IDs/secrets — nothing stored, so nothing to clear; the providers stand **unconfigured rather than fake-configured**, which is the state the cleanup wanted. No save-path forcing was needed or attempted.

## 5. Bank Transfer plugin — installed; activation blocked on owner's real bank details

- Bank Transfer is a **bundled core plugin** (`app/Plugins/PaymentGateways/BankTransfer`, `plugin.json`: slug `bank-transfer`, type `payment_gateway`, `is_core: true`); its files already ship in the image. It had **no row** in the `plugins` table.
- **Installed** with `PluginManager::install('bank-transfer')` — the same call the admin UI's Install button and the vendor's `DemoSeeder` use. Row verified afterwards: `bank-transfer | status=inactive | is_core=1`, config EMPTY.
- **Activation attempted** with `PluginManager::activate('bank-transfer')` and **refused by the vendor path**: `RuntimeException: Configure the plugin before activating it.` — `BankTransferPlugin::isConfigured()` requires `bank_name` + `account_name` + `account_number`, and `activate()` enforces it (`assertConfigured()`).
- **No bank details were invented or entered.** The vendor seeder's sample values (`Example Bank` / `Acme Demo Inc.` / `000123456789`) were deliberately **not** used on the live system — planting them would show customers a fake bank account, the opposite of this cleanup.
- **Owner step to finish:** Admin → Plugins → **Bank Transfer → Configure** — enter Rektrs' real bank name, account title and account number, save, then flip the plugin Active (the same toggle will now accept). Until then the gateway correctly stays inactive.
- **PayPal:** not installed (no `plugins` row), per instructions.
- **Disclosed side effect:** `PluginManager::install()` internally calls the vendor's `restartQueueWorkers()` (`queue:restart`). The queue worker logged `Worker STOPPED — Received restart signal` at 08:20:03 UTC and its container came back under Docker's restart policy (RestartCount 1, StartedAt unchanged since, jobs processing normally before the signal — `FlagSlaBreachesJob` / `RecordQueueHeartbeatJob` DONE). This is the mechanism's designed behaviour — the identical signal fires when an admin clicks Install in the UI. No container was restarted or recreated by hand in this lane.

## 6. Verification evidence

- Fresh-process re-read of every changed key: `custom_code_enabled=false`, `custom_head_code=''`, `custom_footer_code=''`, `admin_recipient=asadchoudhary@rektrs.com` ✓
- Untouched keys confirmed unchanged: `custom_css` NULL; contact group identical to §2; social client IDs still NULL; `from_address`/`driver` unchanged (SMTP step's scope) ✓
- Plugins table after: `android, legacy_importer, smpp, sms_providers, waba, waba_embedded_signup, whatsapp` all **active** (unchanged) + `bank-transfer` **inactive** (new, §5); no `paypal` row ✓
- `curl http://127.0.0.1:8081/` (app container port) → **200**; `curl https://sendqon.rektrs.com/` → **200** ✓
- Queue container `sendqon-queue` Up and stable (StartedAt 2026-11-16T08:20:03Z, RestartCount 1 — the §5 vendor signal, not a loop) ✓

## 7. UNVERIFIED / open items (labelled)

- **Bank Transfer activation** — blocked on the owner's real bank details (§5); not forceable without inventing data.
- **Admin-UI eyeball** — not done; the signed-out session is why this lane ran server-side. All state above is proven via the app's own model/DB reads.
- **`from_address = hello@example.com` + `driver = log`** — real stored demo mail values left in place **by instruction** for the SMTP step; flagged in §4 so that step replaces them.
