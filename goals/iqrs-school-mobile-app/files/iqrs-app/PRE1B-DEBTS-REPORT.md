# Pre-Wave-1B Debts — Report

Two paperwork/tooling debts from the Wave 0 checker cycle, closed 2026-11-07 before the Wave 1 checker pass:

1. **Plan amendment** — the nav layout guarantee is scoped to the 360dp baseline (owner decision).
2. **Harness defect H1** — `run_checker.sh` no longer hardcodes versionNames.

F5 (Workspace detail collapse-to-strip) is **not** in this report — it belongs to the Wave 1B app build.

---

## Debt 1 — Plan amendment (FEATURE-AND-DESIGN-PLAN.md)

File: `~/workspace/goals/iqrs-school-mobile-app/files/FEATURE-AND-DESIGN-PLAN.md`. Two surgical insertions; no other section touched.

### 1a. Scope note directly under the §6.3 assertion table (after LAY-RTL-1, before §6.4)

> **LAY-NAV-2 scope (amended 2026-11-07).** The font-scale-1.3 arm of LAY-NAV-2 is asserted at **360dp and wider**; at **320dp** the assertion runs at font scale **1.0** only. The 320dp × 1.3 corner is a documented known limitation, not a gated combination — see the §6.5 amendment below.

### 1b. Amendment in §6.5 (Device matrix), immediately after the matrix paragraph

> **Amendment — guaranteed width × font combinations (owner decision, 2026-11-07).** The bottom-nav label guarantee (NAV-2, tested by LAY-NAV-2) holds, and is Checker-gated, for exactly these combinations: **360dp and wider at font scales 1.0 and 1.3**, and **320dp at font scale 1.0**. The remaining matrix corner, **320dp × font scale 1.3**, is a **documented known limitation — not a defect and not a design target**. The physical reason: under NAV-3's equal slots, a 320dp nav leaves a ≈69dp slot per label, while the standing test word “Attendance” measures 75.5dp at the NAV-2 floor of 10sp in the bundled typeface at scale 1.3 — an ≈6.5dp overflow that no layout honouring both equal slots and the 10sp floor can absorb. The Wave 0 Checker measured this corner directly (CHECKER-REPORT-wave0.md, finding F1; confirmed in CHECKER-REPORT-wave0-reentry.md, which records it as an S2 debt outside the §6.5 baseline), and on **2026-11-07 the owner decided** the guarantee stays at the 360dp baseline rather than commissioning a narrow-width nav variant. The corner may be revisited only on a new owner decision.

The harness's own nav fit table corroborates the corner (it is evidence, not a gate): `screen=320dp font=1.3 … total=302.0dp OVERFLOWS by 26.0dp` at the 10.0sp floor.

---

## Debt 2 — Checker harness H1 fix (tools/checker/run_checker.sh)

### The defect

Step 6 passed literal versionNames from the first Wave 0 builds to `check_apk.sh`:

```bash
"$HERE/check_apk.sh" "$APK_CONNECT"   pk.edu.iqrs.family 2.8
"$HERE/check_apk.sh" "$APK_WORKSPACE" pk.edu.iqrs.admin  2.9
```

When the NAV-3 re-entry builds shipped as Connect **2.9** / Workspace **2.10**, the orchestrator produced two false `FAIL: versionName mismatch` results against correct APKs, and the Checker had to bypass it by calling `check_apk.sh` directly (CHECKER-REPORT-wave0-reentry.md, §H1 — which itself prescribes this fix).

### The fix

The orchestrator now derives each app's expected **package and versionName from the tree's own build config** — `config/family.properties` / `config/admin.properties`, the same files `build.sh` reads (`grep '^versionName='` at build.sh:22) — so the expectation can never go stale independently of the build, and a `--expect-connect` / `--expect-workspace` argument overrides the derived versionName when the Checker deliberately tests an off-config build. `check_apk.sh` and `metadata_check.sh` are **unchanged**: the gate compares the APK's real badging against the expectation exactly as before, so nothing is weakened — a stale APK still fails.

Changes, all inside `run_checker.sh`:

1. **Header comment** — usage line gains `[--expect-connect <versionName>] [--expect-workspace <versionName>]`, plus a paragraph recording the H1 history and the derivation rule.
2. **Argument parsing** — two new options populate `EXPECT_CONNECT` / `EXPECT_WORKSPACE`; a `cfg()` helper reads one key from a `config/*.properties` file.
3. **Step 6** — the two literal calls are replaced by:

```bash
if [ -n "$APK_CONNECT" ]; then
  C_PKG=$(cfg family.properties applicationId)
  C_VER=${EXPECT_CONNECT:-$(cfg family.properties versionName)}
  [ -n "$C_PKG" ] && [ -n "$C_VER" ] || { echo "FAIL — cannot derive Connect expectations from config/family.properties"; exit 2; }
  if [ -n "$EXPECT_CONNECT" ]; then C_SRC="--expect-connect"; else C_SRC="config/family.properties"; fi
  echo "expected Connect: $C_PKG versionName $C_VER (source: $C_SRC)"
  "$HERE/check_apk.sh" "$APK_CONNECT" "$C_PKG" "$C_VER" || FAILED=$((FAILED + 1))
fi
```

(and the mirror block for Workspace). If the config cannot yield an expectation the harness stops with exit 2 (a harness error, per the script's existing convention) instead of silently passing or guessing. The only remaining mentions of “2.8/2.9” in the file are in the historical header comment.

### Demonstration 1 — GREEN end-to-end on the current delivered builds

Command:

```
tools/checker/run_checker.sh \
  --apk-connect   ~/workspace/your_files/iqrs-app/IQRS-Connect-App-v2.9.apk \
  --apk-workspace ~/workspace/your_files/iqrs-app/IQRS-Workspace-App-v2.10.apk
```

Exit code **0**. Steps 1–5 all pass (real-font metrics; JUnit `OK (5 tests)`; nav fit table; source inspections; banned-strings lint). Step 6, verbatim:

```
== 6. shipped APKs ==
expected Connect: pk.edu.iqrs.family versionName 2.9 (source: config/family.properties)
== sha256 ==
9b4a49bc73938d893bf3aa009f283d0ddddd0c87beb4b9fb712972cf6e57355e  …/IQRS-Connect-App-v2.9.apk
== metadata gate (tree tool) ==
ok   package = pk.edu.iqrs.family
ok   versionCode = 20 (>= 10)
ok   versionName = 2.9
ok   minSdk = 26
ok   targetSdk = 34
ok   permission android.permission.INTERNET
ok   signature verifies
METADATA GATE: PASSED
PASS — metadata gate
… (dex mechanism classes ×4 PASS; REG-DIALOG-TEXT ×3 PASS)
APK CHECK: PASSED
expected Workspace: pk.edu.iqrs.admin versionName 2.10 (source: config/admin.properties)
== sha256 ==
3c15c604c166ee11d51721ec71e2619097fca231c6e0c181af7ef95e0ae81298  …/IQRS-Workspace-App-v2.10.apk
== metadata gate (tree tool) ==
ok   package = pk.edu.iqrs.admin
ok   versionCode = 23 (>= 10)
ok   versionName = 2.10
ok   minSdk = 26
ok   targetSdk = 34
ok   permission android.permission.CAMERA
ok   permission android.permission.INTERNET
ok   signature verifies
METADATA GATE: PASSED
PASS — metadata gate
… (dex mechanism classes ×4 PASS; REG-DIALOG-TEXT ×3 PASS)
APK CHECK: PASSED
CHECKER HARNESS: 0 failed check group(s)
```

The APK hashes match the re-entry report's PASS artefacts (Connect `9b4a49bc…`, Workspace `3c15c604…`) — the same builds, now green through the orchestrator with **no false failures**.

### Demonstration 2 — the harness still FAILS on wrong-version APKs

Same command pointed at the stale Wave 0 builds (`IQRS-Connect-App-v2.8.apk`, sha256 `50bcea2a…`; `IQRS-Workspace-App-v2.9.apk`, sha256 `b781df09…`). Exit code **2**:

```
expected Connect: pk.edu.iqrs.family versionName 2.9 (source: config/family.properties)
ok   package = pk.edu.iqrs.family
ok   versionCode = 19 (>= 10)
FAIL: versionName mismatch
…
METADATA GATE: FAILED
FAIL — metadata gate
APK CHECK: FAILED
expected Workspace: pk.edu.iqrs.admin versionName 2.10 (source: config/admin.properties)
ok   package = pk.edu.iqrs.admin
ok   versionCode = 22 (>= 10)
FAIL: versionName mismatch
…
METADATA GATE: FAILED
FAIL — metadata gate
APK CHECK: FAILED
CHECKER HARNESS: 2 failed check group(s)
```

Every other check inside those APK runs (package, versionCode floor, SDK levels, permissions, signature, dex mechanisms, REG-DIALOG-TEXT) still passes — the failure is precisely the version gate doing its job against stale artefacts.

### Demonstration 3 — the `--expect-*` override path works

`--apk-connect …/IQRS-Connect-App-v2.8.apk --expect-connect 2.8 --apk-workspace …/IQRS-Workspace-App-v2.10.apk` → exit **0**, with the expectation line reading `expected Connect: pk.edu.iqrs.family versionName 2.8 (source: --expect-connect)` — the override is explicit and visible in the run log, never silent.

---

## Status

- **Debt 1: closed.** §6.5 and LAY-NAV-2 now state the guaranteed combinations (360dp+ × 1.0/1.3; 320dp × 1.0), the 320dp × 1.3 known limitation with its physical reason, the checker citations, and the owner's 2026-11-07 decision.
- **Debt 2 (H1): closed.** The orchestrator derives expectations from build config (overridable via `--expect-*`); demonstrated green end-to-end on the delivered builds and failing on stale builds. The pre-Wave-1B requirement in CHECKER-REPORT-wave0-reentry.md (“literals must be fixed before the Wave 1 checker pass, with the fixed orchestrator demonstrated green end-to-end”) is met.
