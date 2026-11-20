# Sendqon — Push + Panel Auto-Update Report — 2026-11-20

Owner's order (chat, 2026-11-20 13:26 PKT): "Ab Push + panel auto-update set kar do."
The first lane executed the auto-update half as far as core allowed and re-verified
the push half: production refused the registration under core's app-bundle rule
(details below) and device rows were never touched. The owner then chose option 1
(2026-11-20 13:43 PKT, "Vendor companions hata kar hamari app register kar do") and
the ecosystem switch was carried out the same day — see "Part 1 — Execution" below.
Push remains blocked on the owner-only Firebase console step.

| Part | Result |
| --- | --- |
| Panel auto-update (register our gateway v5.3.0 in the production `android_gateway` slot) | **COMPLETE (2026-11-20 13:48 PKT)** — vendor Receiver/USSD companions removed, bundle record cleared, our v5.3.0 registered and verified; DEV rehearsal had passed end-to-end beforehand |
| Push notifications (FCM wake for the gateway app) | **BLOCKED on an owner-only Firebase console step** — production Firebase settings for the Android gateway are empty; the missing file (google-services.json) can only be minted in the owner's Firebase console |

---

## Part 1 — Panel auto-update

### State verified before any write (read-only)

- Production `android_gateway` slot: vendor white-label gateway **v5.0.4**, package
  `com.rektrs.sendqon` (same package as our app), file SHA-256
  `2b8af65be3a3042d8188ef1993cf3f62f8b68cb584640be9069422e07aed9f8f`, 5,447,604 bytes,
  uploaded 2026-11-17. Receiver and USSD slots hold the matching vendor companions
  (v5.0.4); the RCS slot is empty.
- **Correction to the earlier lane's trace:** `2b8af65b…` is the gateway file's own
  SHA-256, not its signer. The vendor app family's actual signing certificate
  (gateway + receiver + ussd + the `rcs_bundle` record) is
  `77f4e3df499f96907b679d50fa67488da58b90361b1d00cbbfdb105575d1e4f2`.
  Our app's custody certificate is `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee`.
- Required-floor setting `app_file_android_gateway_required_floor`: **null**.
- Devices: exactly 2 — id 1 (vendor app v5.0.4, signer `77f4e3df…`, paused) and
  id 2 (our app v5.2.2, signer `eba2c40d…`). Neither was touched.
- Fresh backup predating all work: `/var/backups/sendqon/` artifacts of 2026-11-20
  08:30 UTC (see "Backups" below), re-verified in this lane.

### Preservation (rollback kit)

Before the registration attempt, the current slot contents were preserved byte-exact
in the goal's `hidden_files/slot-preservation-2026-11-20/`. The kit was completed
ahead of the switch (all hashes re-verified equal to the live slots by the
completion lane before it acted):

- `vendor-gateway-5.0.4.apk` — SHA-256 `2b8af65b…f8f`, equal to the live slot.
- `vendor-receiver-5.0.4.apk` — SHA-256 `551f3209…58c2`, equal to the live slot.
- `vendor-ussd-5.0.4.apk` — SHA-256 `da2f717a…f6a`, equal to the live slot.
- `app_file_android_gateway-row.json` (settings id 94), `app_file_android_receiver-row.json`
  (id 95), `app_file_android_ussd-row.json` (id 96), `rcs_bundle-row.json` (id 97) —
  the full `system_settings` rows with decoded values, container paths and modes.
- `ROLLBACK.md` — the full restore recipe (core writers only), including the list
  of settings that were absent before the switch and must stay absent on rollback
  (all four `app_file_*_required_floor` rows were null).

### DEV rehearsal — PASSED end-to-end (sendqon-dev, offbox-1)

1. Staged our v5.3.0 APK (SHA-256 `c433ec61cd8143dab12c240beaa77cccbfc7a84040ed3e66cd4531ee001b0f35`,
   4,527,178 bytes) into the DEV container; hash verified inside.
2. Created one throwaway battery device (id 8, tenant 36) holding a known session
   secret, reporting version 5.2.2 with our package + signer.
3. **Baseline:** against DEV's then-current slot (our v5.2.0), `GET /app/update`
   offered 5.2.0 with a signed download link and checksum `76f0866b…` — the session
   and offer path resolve correctly.
4. **Registered v5.3.0** with the DEV tooling (`b7-dev.php register-apk`, which calls
   core's own `AppFiles::store()`). Resulting slot meta: version 5.3.0, package
   `com.rektrs.sendqon`, signer `eba2c40d…`, SHA-256 `c433ec61…`, uploaded
   2026-11-20T08:36:31Z.
5. **Our-signer check:** a 5.2.2-shaped request was offered **5.3.0** — signed
   `apk_url`, `checksum_sha256` = `c433ec61…`, `min_required_version` 5.0.0,
   `required_at` = 2026-11-23T08:36:31Z (upload + 72 h, see the rule below).
6. **Download check:** the signed link answered **HTTP 200**, 4,527,178 bytes, and
   the downloaded bytes hash to exactly `c433ec61…`.
7. **Foreign-signer check:** the same device session with an all-zero signer header
   received the empty offer (`latest_version` 1.0.0, empty `apk_url`, null checksum) —
   another app's phone is never offered our APK.
8. **Cleanup:** battery device deleted (DEV device count back to 2); DEV slot
   restored to its pre-rehearsal contents by re-registering the byte-identical
   v5.2.0 APK (SHA-256 `76f0866b…`); all staged temp files removed. (DEV
   `uploaded_at`/floor bookkeeping reflects the rehearsal; DEV is a scratch copy.)

### Production attempt — refused by core, nothing written

The v5.3.0 APK was staged into the production container (hash verified inside,
mode normalised to 0644) and `AppFiles::store()` was invoked **as www-data**
(`docker exec -u www-data -e HOME=/tmp`). Core refused with a validation error
before storing anything:

> "This APK must use the same signing certificate as the installed companions.
> Upload an app bundle instead."

Mechanism (read from the live code, `App\Services\Apps\AppFiles::storeLocked`):
while **any** companion slot (`android_receiver`, `android_rcs`, `android_ussd`) is
populated, a standalone gateway upload is accepted only if its certificate equals
the installed bundle's certificate (`rcs_bundle.cert_sha256` = the vendor family's
`77f4e3df…`). Ours is `eba2c40d…`, so the refusal is deterministic, not a fault.
Companion slots themselves can only be written through a bundle install.

The suggested alternative — an **app bundle** (`App\Services\Messaging\Rcs\RcsBundles::install`) —
is the vendor portal's build pipeline, and it is not mintable by us:

- the ZIP must carry gateway + receiver + ussd APKs (we ship no separate companion
  APKs; receiving and USSD are built into our gateway app by design),
- all apps must share one certificate **and one version equal to the site's Zender
  version (5.0.4)** — our app is 5.3.0,
- and `manifest.json` must carry a valid `manifest.sig` verified against the
  portal's signing key ("Build the app again on the portal, then upload the new
  bundle") — that key is Titan's, not ours.

**Production state after the attempt (verified read-only): unchanged.** Gateway
slot still vendor v5.0.4 / `2b8af65b…`, required floor still null, devices
untouched, staged temp files removed from the container and host.

### The 72-hour rule (applies whenever a registration does land)

`SlotRequirement::GRACE_HOURS = 72`. Once a new gateway upload is registered, it is
offered immediately, and at `uploaded_at + 72 h` it becomes **required**
(`min_required_version` rises to it): a phone of the same app family still below it
then stops receiving new messages until it updates. Phones of a *different* family
(different signer — e.g. the paused vendor device id 1) are never offered the upload
and are held only to the compat minimum (currently 5.0.0). This was the caveat
already given to the owner before this lane ran.

### Decision put to the owner (decided 2026-11-20 13:43 PKT — option 1)

1. **Switch the slot family to ours (ecosystem change).** Remove the vendor
   Receiver + USSD companions from their slots and clear the bundle record, after
   which the standalone store of our gateway is accepted (the DEV copy proves the
   path). Consequences: the panel stops offering the vendor companion downloads;
   the vendor-app device family (device id 1, already paused) loses its panel app
   source; every tenant's panel then serves **our** app family. Our gateway app
   needs no companions (receiver/USSD are built in), and phones already running
   the vendor apps keep working — they simply get no further panel updates.
   This is a deliberate product/ecosystem switch, so it waits for the owner's
   explicit word.
2. **Leave the slots with the vendor family (status quo).** Panel auto-update
   remains the vendor app's; our app keeps updating out-of-band (APK delivered
   directly, as with v5.2.1 → v5.3.0 today).
3. **A full own bundle** is not an available route (portal signature + version
   lock, above).

The owner chose **option 1** in chat on 2026-11-20 at 13:43 PKT: "Vendor
companions hata kar hamari app register kar do."

---

## Part 1 — Execution (2026-11-20, owner decision carried out)

### Interruption note (how the starting state was re-established)

A follow-up lane began the switch, completed the preservation kit and wrote
`ROLLBACK.md` (13:45–13:46 PKT), then ended without a final report, leaving it
unknown whether anything had been removed on production. The completion lane
therefore assumed nothing: at **2026-11-20T08:47:45Z** it ran a read-only probe
(as www-data, core services only) and established the starting state plainly —
**(a) nothing removed yet**: all three vendor slots still populated (gateway /
receiver / ussd at v5.0.4, file hashes identical to the preservation kit), the
`rcs_bundle` record (id 97, cert `77f4e3df…`) still set, no required-floor rows,
devices 1 and 2 exactly as recorded earlier. `ROLLBACK.md`'s past tense was
prospective writing, not a record of fact.

### Production steps (as www-data, core's own mechanisms only)

Executed in one bootstrapped run at **2026-11-20T08:48:55Z (13:48:55 PKT)**:

1. `AppFiles::remove()` on the `android_receiver` slot — returned the vendor
   receiver meta (v5.0.4, `551f3209…`); row forgotten, stored file deleted.
2. `AppFiles::remove()` on the `android_ussd` slot — returned the vendor USSD
   meta (v5.0.4, `da2f717a…`); row forgotten, stored file deleted.
3. Bundle record cleared via core's settings writer (`SystemSetting::remove('rcs_bundle')`,
   the same writer `AppFiles::remove` uses for slot rows — core has no dedicated
   bundle-uninstall service; `RcsBundles` exposes `install()` only), followed by
   `RcsAvailability::forgetCurrent()` and the related settings-cache clears.
   Read-back in the same run: `rcs_bundle` = null.
4. `AppFiles::store()` on the `android_gateway` slot with our
   `sendqon-gateway-own-v5.3.0.apk` (staged into the container at mode 0644,
   SHA-256 verified inside before the run). With the companion slots empty, the
   bundle-certificate guard no longer applies and the store was accepted.

### Proof (all checks after the run)

- **Slot state (fresh-process probe, not the writing process):**
  `android_gateway` = **v5.3.0**, package `com.rektrs.sendqon`, SHA-256
  `c433ec61cd8143dab12c240beaa77cccbfc7a84040ed3e66cd4531ee001b0f35`,
  signer `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee`,
  uploaded `2026-11-20T08:48:55Z`. Receiver, USSD and RCS slots all empty;
  the only remaining app-file setting row is the gateway row; **no
  required-floor rows were created** (the removals and the store all landed
  inside the previous uploads' 72 h grace window, so `SlotRequirement::preserve`
  correctly wrote nothing). Storage holds only the new gateway APK file; the
  vendor files are deleted from the live tree (preserved copies: see the kit).
- **Required-at:** `required_at` for the gateway slot =
  **2026-11-23T08:48:55Z (2026-11-23 13:48:55 PKT)** — registration + 72 h,
  exactly as the rule predicts. Until then v5.3.0 is offered, not required;
  `min_required_version` remains 5.0.0.
- **Update-offer checks (in-process, core's `GatewayAppVersions`):** a request
  shaped like our phone on v5.2.2 (our package + signer) → `matches` = true,
  update status **available** (v5.3.0 offered). A foreign-signer request (vendor
  family cert) → `matches` = false, device flagged mismatched — the empty offer,
  as designed; the paused vendor device id 1 is never offered our APK.
- **Download check:** an in-process signed download URL (core's own
  `URL::temporarySignedRoute`, 6 h validity) answered **HTTP 200** with
  4,527,178 bytes, and the downloaded bytes hash to exactly `c433ec61…`.
- **Devices untouched:** device id 1 row identical to the pre-switch probe
  (same `updated_at`, still paused). Device id 2's `updated_at` advanced only
  through its own live sync (it was mid-heartbeat during the run); the lane
  issued no device writes.
- **Panel smoke (guest):** `/` → 200; `/channels` → 302 to login (200 after
  redirect — normal for an authenticated page); `/channels/android/ussd` →
  302 to login (200). `/devices` → 404 because **no such route exists** in this
  app (devices are managed inside Channels, e.g. `/channels/android/{device}`) —
  pre-existing routing, unrelated to the switch.
- **Log:** today's Laravel log (`laravel-2026-11-20.log`) has no entries at all
  after 06:11 UTC — zero new errors in or after the switch window.
- Temp scripts and the staged APK copy were removed from the container and the
  host afterwards.

### Rollback

Rollback, if ever wanted, follows `hidden_files/slot-preservation-2026-11-20/ROLLBACK.md`
(core writers only): remove our gateway upload, copy the three preserved vendor
APKs back to their recorded container paths (mode 0664, hashes in the row
JSONs), restore the four settings rows (gateway / receiver / ussd / rcs_bundle)
from the preserved row JSONs, `RcsAvailability::forgetCurrent()` + cache clear,
and verify `AppFiles::current()` reports the vendor 5.0.4 family again. The
2026-11-20 backup set below also covers the pre-switch state.

---

## Part 2 — Push notifications

### State (spot-verified in this lane, lengths only — no values read or moved)

- Production `firebase_credentials` (the gateway/server Firebase service account):
  **empty**. `firebase_android_config` (the client config the app receives):
  **empty**.
- A Firebase service account for project `sendqon` exists **only** under the mobile
  key (`mobile_firebase_credentials`, an 11-key service-account record) — it powers
  the mobile app's push, not the gateway's.
- No `google-services.json` exists anywhere on the host (established by the earlier
  lane's trace). Core withholds the client config from the gateway app unless its
  project matches the service account's project, so the app currently receives no
  Firebase config, cannot register for FCM, and polls instead — both production
  devices show an FCM token length of **0**.
- **Disclosure:** in the earlier (stopped) lane, a shortcut that would have copied
  the mobile Firebase credential into the DEV copy was **refused by the safety
  policy and was not worked around**. This lane likewise moved no Firebase
  credential anywhere. The supported route is the owner's console step below,
  using the panel's own Configure fields.

### Owner steps (only the owner can do these — Firebase console sign-in)

1. Firebase console → project **`sendqon`** → add an **Android app** with package
   **`com.rektrs.sendqon`** → download the generated **`google-services.json`**.
2. Sendqon Admin → **Android plugin → Configure**:
   - paste the **Firebase Service Account JSON** — the same JSON already used for
     mobile push — into the service-account field;
   - upload the downloaded **`google-services.json`** in the **Firebase Android
     App** section.
3. Say the word here. A short verification lane then proves, in order: the device
   payload now delivers the Firebase config → the phone registers an FCM token
   (token length goes from 0 to real) → a push wake reaches the phone (message
   picked up by push instead of the polling interval).

Until then the gateway app keeps working on its polling cycle — push is a
latency/battery improvement, not a correctness gap.

---

## Backups

Artifacts from the earlier lane, re-verified in this lane before the production
attempt (all in `/var/backups/sendqon/`, created 2026-11-20 08:30 UTC):

- `sendqon-db-2026-11-20.sql.gz` — `gzip -t` OK
- `sendqon-config-2026-11-20.tar.gz` — `gzip -t` OK, tar listing 167 entries
- `sendqon-storage-2026-11-20.tar.gz` — `gzip -t` OK, tar listing 482 entries

## What did not happen

- In the first lane, no production setting, file, or device row was changed
  (the single attempted write was refused by core's own validation before any
  write). In the execution lane, the only production changes were the ones the
  owner authorised in the 13:43 PKT decision: the two companion removals, the
  bundle-record clear, and the gateway registration — nothing else.
- No device row was modified by any lane.
- No Firebase credential was copied, moved, or printed anywhere.
- No bundle was fabricated, and no vendor companion was removed before the
  owner's explicit decision — the ecosystem switch was deliberately **not**
  executed on the strength of the auto-update order alone.
