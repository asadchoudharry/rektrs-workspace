# CHECKER REPORT — Wave 2D production-pointing builds (Connect v2.14-prod / Workspace v2.18-prod)

**Checked:** 2026-11-08 (PKT) · **Checker:** independent checker lane (built neither app; every measurement below is the checker's own — dex disassembled off the shipped APKs, badging and certificates read off the shipped files, the suite and harness re-run on the tree as-left, and the production route set re-probed live by the checker under guard-level limits)
**Artefacts:** IQRS-Connect-App-v2.14-prod.apk (code 25, versionName 2.14; 1,643,376 B; sha256 `fd5cbb710380d9ef2b9510e5057132add62943f4f0178b0119518f9d44667c09`) · IQRS-Workspace-App-v2.18-prod.apk (code 31, versionName 2.18; 1,729,392 B; sha256 `0939d25ad5ea16218cc4357c6fdfbb993c7c596ab8e14d2c65aa8f98e676074b`) — sizes and hashes re-measured on disk by the checker, identical to the task pins and the build report.

## Overall verdicts

- **Connect v2.14-prod — PASS-WITH-NOTES.** The production twin of the device-gate-cleared v2.13: its only accessor returns the production base URL, proved in the shipped dex; permissions and signer are the staging line's, measured; the whole 210-route surface it will call answers on production with codes identical to staging. The single note is Item 1's precision point (an inert declared constant), evidence-form only — no code path in this artefact can reach staging.
- **Workspace v2.18-prod — PASS-WITH-NOTES.** The same, for the production twin of v2.17 (CAMERA retained in its permission set).
- **No S1 and no S2 against either build.** Every testable claim in BUILD-REPORT-wave2d-prod-apps.md was reproduced independently by this pass; the one place where this checker's brief was worded more strongly than the build report ("the staging URL appears NOWHERE in either dex") is corrected with the measured fact in Item 1 — the build report itself did not make that claim (it discloses "Both URL constants remain declared, as before").

---

## Item 1 — Target and change set — **PASS-WITH-NOTES**

**Dex proof (checker's own `dexdump -d` on both shipped APKs):** in both, `Lpk/edu/iqrs/app/api/ApiConfig;` disassembles as

```
baseUrl:()Ljava/lang/String;
  0000: const-string v0, "https://iqrs.edu.pk/api/"
  0002: return-object v0
```

— the production constant is what the single accessor returns, in both apps, with no other code in the method. The production URL appears as exactly 2 `const-string` instructions per dex (the accessor body plus its compile-time inlining at the class's own value), and there are **zero `const-string` instructions carrying the staging URL** anywhere in either dex, and no `sget` of the staging field anywhere — nothing in either artefact can be made to call staging.

**The precision note:** the staging URL string is **not** literally absent from the dexes. It occurs **exactly once per dex** (confirmed identically by a whole-APK string scan of every zip entry): as the stored `value` of the declared static field `STAGING_BASE_URL` inside `ApiConfig` — the compile-time constant the source still declares beside `BASE_URL`, never read by any instruction. This is the exact mirror of the posture this programme's checker accepted for the staging twins, where the *production* constant sat declared-but-unreturned in the v2.13/v2.17 dexes (CHECKER-REPORT-wave2-fix2.md, Item 6). The substance the flip exists for — the apps talk to production and cannot be pointed at staging by anything in the shipped code — is fully proven; only the word "nowhere" overstates the artefact, and the build report does not use it.

**Change set is exactly the declared one:** the tree is not a git checkout, so the checker swept file mtimes instead: under `src/` and `config/`, the **only** files modified after the v2.17 build (2026-11-07 19:20) are the three declared files — `src/pk/edu/iqrs/app/api/ApiConfig.java`, `config/family.properties`, `config/admin.properties`. The checker read all three: `baseUrl()` returns `BASE_URL` with the 2D comment as reported; `family.properties` carries versionCode 25 / versionName 2.14 / `apkName=IQRS-Connect-App-v2.14-prod.apk`; `admin.properties` carries 31 / 2.18 / `IQRS-Workspace-App-v2.18-prod.apk`. No other source drift exists to find. The route manifest was **not** rewritten by the prod lane or by this pass (`base` still `https://staging.iqrs.edu.pk/api/`, `probed_at` still `2026-11-07T19:26:18Z`, 210 routes), as the harness design intends.

## Item 2 — Permissions and signer — **PASS**

Checker's own `aapt2 dump badging` on the shipped files:

- **Connect v2.14-prod** — package `pk.edu.iqrs.family`, versionCode 25, versionName 2.14; permissions exactly `INTERNET`, `POST_NOTIFICATIONS`, `USE_BIOMETRIC` — no more, no fewer.
- **Workspace v2.18-prod** — package `pk.edu.iqrs.admin`, versionCode 31, versionName 2.18; permissions exactly `INTERNET`, `CAMERA`, `POST_NOTIFICATIONS`, `USE_BIOMETRIC`.
- Both sets are byte-for-byte the staging twins' sets (the checker's badging of v2.13/v2.17 in the same run agrees), so the flip changed no permission posture.

**Signer (checker's own `apksigner verify --print-certs`):** SHA-256 `f7874c3f69e4ee1cfbf54ef3616b2dde920423baa16f70d25724771f3bda462e` on **both prod APKs and both staging twins** — one signer across the whole line, so these prod builds install as updates over the staging builds on the owner's phone.

## Item 3 — Production route proof, re-run independently — **PASS**

The checker re-ran the proof itself, under the brief's hard limits: the SRC-ROUTE-LIVE manifest's 210 routes, probed against `https://iqrs.edu.pk/api/` with the contract gate's own probe shape (unauthenticated POST, vendor `Client-Service`/`Auth-Key` headers, `Content-Type: application/json`, empty `{}` body, **curl only**). No logins, no credentials beyond the vendor's public client identifiers the gate itself uses, no `User-ID`/`Authorization` headers, no accounts created, nothing written — every probe was refused at a guard or by input validation, as the shape guarantees.

**Result — identical to the build report's claim in every particular:**

- **210/210 routes answer; 0 transport failures; 0 × 404; 0 × 5xx.**
- **Exact-code parity with the staging manifest: 210/210.** The HTTP-code distributions are identical on both sides: **401 × 200, 200 × 8, 400 × 2**.
- **Bodies match the reported refusal shapes (checker's own captures):** all 200 of the 401 answers carry the single uniform body `{"status":401,"message":"Unauthorized."}`; the extension surfaces the apps depend on (`staffapi/capabilities`, `staffapi/appVersions`, `staffsync/visitorSave`, `familydocs/fileOpen`, `familydocs/appVersion`) are among them — present and guarded on production, none missing, none erroring. `auth/login` and `staffauth/login` answer 200 with `{"status":0,"message":"Invalid Username or Password"}` (an empty-body attempt refused; nothing authenticated). The six vendor routes (`addTask`, `updatetask`, `deletetask`, `deletedailyassignment`, `deletetimeline`, `deleteforummessage`) answer 200 with the vendor's field-validation errors (missing-field lists) — input guards answering before any write is possible. The two 400s are `webservice/forgot_password` (field validation) and `webservice/getLibraryBooks` (`{"status":400,"message":"Bad request."}`).

The Wave 2 surface is therefore live and guarded on production exactly as on staging; the guard-level proof is complete. What it cannot and does not claim is an authenticated end-to-end session — see the closing statement.

## Item 4 — Regression sweep — **PASS**

All re-run by the checker on the tree as-left (production configuration) and the shipped prod artefacts:

- **Unit suite:** `tools/run_tests.sh` → **OK (352 tests)** — the claimed count exactly, unchanged from the staging twins (the flip touched no behaviour the suite pins).
- **Checker harness:** `run_checker.sh --apk-connect <v2.14-prod> --apk-workspace <v2.18-prod>` → **CHECKER HARNESS: 0 failed check group(s)**, with expectations derived from the tree's own config (2.14 / 2.18): both metadata gates PASSED with the exact permission sets itemised and signatures verified; mechanism classes present in both dexes; REG-DIALOG-TEXT present in shipped resources; the source gates (including SRC-NOSPACER-IN-ROW and the offline SRC-ROUTE-LIVE manifest check at 210/210) inside the zero-failure summary.
- **Prior artefacts byte-identical:** every APK in `~/workspace/your_files/iqrs-app/` was hashed at this pass's opening and again at its close — the full 39-artefact listing is unchanged; the pins that matter most are exact (staging **v2.13 `5d091c8e…`**, staging **v2.17 `63928534…`**, and the wiring artefacts v2.12 `a499bd03…` / v2.16 `d3fd65b3…` all re-measured identical to their own checker reports). Only the two prod APKs carry the build day's mtime; nothing pre-existing was touched.

---

## Closing statement — what remains between these builds and real use

**The production apps are built, proven at the guard level, and cleared by this pass.** Between these artefacts and real use there remain exactly two things, neither of them a build item:

1. **The owner's first sign-in on his phone.** No production test accounts exist and none may be created, so the authenticated end-to-end proof on production — a real parent/staff sign-in with these builds, against the production extension masters the 2D rollout landed — can only be the owner's own first use. These builds install over the staging builds under the same signer, so that first sign-in is an update, not a reinstall. (The §6.4 device-gate checklist on the staging twins remains the programme's standing device proof; this pass adds no new device scope.)
2. **Store publication — the separate M5 stage.** Play Store release is its own step after device proof: production signing under the owner's custody of the keystore password, the REKTRS metadata pack, and the open package-id decision (`pk.edu.iqrs.*` vs `com.rektrs.iqrs.*`). Nothing in this pass touches or prejudges it.

**Fixtures/state noted:** this pass created no fixtures and changed no state anywhere; its only production contact was the 210 unauthenticated, empty-body guard probes of Item 3. The route manifest is untouched (staging base, 2026-11-07 probe stamp).
