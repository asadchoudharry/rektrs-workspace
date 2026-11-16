# CHECKER REPORT — Wave 1B fix spot-pass: Workspace v2.12 (code 25)

**Checker:** independent spot-pass (not the fix lane). Local work only; no server contact.
**Artefact:** `IQRS-Workspace-App-v2.12.apk`
**Fix-lane report under test:** BUILD-REPORT-wave1b-fix-v2.12.md

## Verdict: **PASS**

No S0, no S1. Every claim in the fix report that this spot-pass was scoped to test was independently reproduced.

## 1. APK identity — PASS

| Check | Expected | Measured |
|---|---|---|
| Size | 1,520,201 B | 1,520,201 B |
| sha256 | `28287e7e067ce970e9d9b8788321d4a93be17e2e49bc12f17c70170df9a59de5` | identical |
| Badging (aapt2) | pk.edu.iqrs.admin, versionName 2.12 / versionCode 25 | `package: name='pk.edu.iqrs.admin' versionCode='25' versionName='2.12'`, minSdk 26, targetSdk 34 |
| Signer (apksigner) | identical to v2.11 | v2.12 and v2.11 both `f7874c3f69e4ee1cfbf54ef3616b2dde920423baa16f70d25724771f3bda462e` — the update installs over v2.11 |

Tree config agrees (config/admin.properties: versionCode=25, versionName=2.12).

## 2. The two fixes are real, and nothing else changed — PASS

- **StaffHomeActivity.renderWorklist** (read whole): the row is texts column (`Ui.llp(0, WRAP_CONTENT, 1)`) + count + **`row.addView(Ui.hspacer(this, 6));`** (line 383) + caret icon, with the SPACER-AUDIT comment recording the mechanism. The method's other spacers go into `worklistBox` (vertical column) and remain `Ui.spacer`, as they should. Data flow, click target (`StaffNav.openWorklistCard`), divider and padding logic untouched. (The tree is not a git checkout, so no v2.11 baseline file exists to diff; the method was read whole, and its construction matches the v2.11 state except for the spacer call and the comment.)
- **StaffHomeworkActivity.onCreate** (due-date region read whole): `chips` is a `Ui.row`; the gap is now **`chips.addView(Ui.hspacer(this, 0));`** (line 133) with its SPACER-AUDIT comment. The sibling chips keep their own leftMargins; listeners and form flow unchanged.
- Both changes are single view-construction calls — layout only, no data, navigation, or behaviour change, as claimed.

## 3. Checker harness re-run — PASS

`tools/checker/run_checker.sh --apk-connect <Connect v2.9> --apk-workspace <Workspace v2.12>` (expectations derived from the tree's own config, per the H1 fix): **CHECKER HARNESS: 0 failed check groups**, exit 0. Real-font nav table FITS at the gated combinations; JUnit layout budgets OK; banned-strings gate PASSED; both APK checks PASSED (metadata, mechanism classes in dex, shipped REG-DIALOG-TEXT resources).

`tools/checker/check_sources.py` run standalone against the tree: **SOURCE CHECKS: ALL PASS (13 checks, 0 FAIL)**, including:

```
SRC-NOSPACER-IN-ROW PASS — no Ui.spacer site resolves into a horizontal row and no
row-building method leaves a spacer receiver unresolvable (694 sites examined,
0 allowlist-excused) — the giant-slab mechanism cannot recur anywhere in the tree
```

## 4. Guard teeth — independently proven — PASS

In a scratch copy of `src/` under /tmp (the real tree was never modified):

1. Unmodified scratch: SRC-NOSPACER-IN-ROW **PASS** (694 sites) — the scratch setup is faithful.
2. The v2.11 defect reintroduced (line 383 changed back to `row.addView(Ui.spacer(this, 6));`): 
   ```
   SRC-NOSPACER-IN-ROW FAIL — Ui.spacer-in-row violations:
   src/pk/edu/iqrs/app/ui/staff/StaffHomeActivity.java:383 renderWorklist —
   Ui.spacer added into ROW receiver 'row'
   SOURCE CHECKS: 1 FAIL   (exit 1)
   ```
   The guard fails, names the file, line, method and receiver.
3. Scratch copy discarded; the real tree verified untouched (line 383 still `Ui.hspacer`).

## 5. Unit suite + language lint — PASS

- `tools/run_tests.sh`: **OK (232 tests)** — the claimed 232/232.
- `tools/banned_strings.sh` standalone: **BANNED-STRINGS GATE: PASSED** (also passed inside the harness run, §3).

## 6. Connect untouched — PASS

Delivered `IQRS-Connect-App-v2.9.apk`: sha256 `9b4a49bc73938d893bf3aa009f283d0ddddd0c87beb4b9fb712972cf6e57355e` — byte-identical to the previously passed build; badging `pk.edu.iqrs.family` versionCode 20 / versionName 2.9; metadata gate PASS in the harness run above. Correctly not rebuilt: both defects were in Workspace (`ui/staff`) code.

## Notes

- The fix lane did not run the contract gate (live staging smoke), by its local-only constraint. That is consistent with this spot-pass's scope and with the fix's nature (two view-construction calls; no API surface touched). It is not a finding against the fix.
- The v2.12 APK is the same byte size as v2.11 (1,520,201 B) with a different hash — expected for a two-call dex delta; identity is pinned by the hash in §1.

## Pending gate (not a failure)

The **§6.4 device screenshot checklist on this exact APK** remains owed on the owner's phone: sign in, open Home, confirm the "WAITING FOR YOU" rows render at normal height with label, detail, count and caret visible, and that each row opens its list. This build is harness-verified, not device-verified.
