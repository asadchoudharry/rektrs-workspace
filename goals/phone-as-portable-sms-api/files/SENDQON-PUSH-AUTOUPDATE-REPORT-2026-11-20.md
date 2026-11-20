# Sendqon — Push + Panel Auto-Update Report — 2026-11-20

Owner's order (chat, 2026-11-20 13:26 PKT): "Ab Push + panel auto-update set kar do."
This lane executed the auto-update half and re-verified the push half. Both halves end
**blocked**, for two different, precisely identified reasons. No production data was
changed by this lane: the only production write attempted was refused by Zender core
itself before any write happened (details below), and device rows were never touched.

| Part | Result |
| --- | --- |
| Panel auto-update (register our gateway v5.3.0 in the production `android_gateway` slot) | **BLOCKED by core's app-bundle rule** — DEV rehearsal passed end-to-end; production refuses any gateway APK whose signing certificate differs from the installed vendor bundle's certificate |
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
in the goal's `hidden_files/slot-preservation-2026-11-20/`:

- `vendor-gateway-5.0.4.apk` — copy of the slot file; SHA-256 re-verified equal to
  the live slot (`2b8af65b…f8f`).
- `app_file_android_gateway-row.json` — the full `system_settings` row (id 94) with
  its decoded value, the file's container path and mode (0664), the required-floor
  value before change (null), and the rollback recipe.

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

### Decision the owner needs to make (nothing here was executed)

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

### Rollback

No rollback is needed for this lane (nothing changed). When a registration is
eventually performed under option 1, rollback = restore
`hidden_files/slot-preservation-2026-11-20/vendor-gateway-5.0.4.apk` to its recorded
container path (mode 0664), restore the `app_file_android_gateway` setting row from
`app_file_android_gateway-row.json`, reset
`app_file_android_gateway_required_floor` to null, and clear the app cache — or
restore the 2026-11-20 backup set below.

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

- No production setting, file, or device row was changed (the single attempted
  write was refused by core's own validation before any write).
- No Firebase credential was copied, moved, or printed anywhere.
- No companion slot was removed and no bundle was fabricated — the ecosystem
  switch in "Decision the owner needs to make" was deliberately **not** executed
  on the strength of the auto-update order alone.
