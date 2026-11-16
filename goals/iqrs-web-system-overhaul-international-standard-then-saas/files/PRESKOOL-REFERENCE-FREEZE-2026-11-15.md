# PreSkool Reference Freeze — PKG-0 (2026-11-15)

**Step:** PKG-0 of the PreSkool Deployment Plan (Package Provenance Swap),
executed 2026-11-15 under the owner's approval of the plan (~16:25 PKT).
**This is a records-only step: no server writes were made — staging and
production were not contacted at all.**

---

## 1. The frozen reference pack — identity

From this date, the **purchased vendor package** — never the live demo, never
the local reconstruction — is the only design source of truth for the PF
programme (deployment plan §1).

| Field | Value |
|---|---|
| Product | PreSkool — School, College, Education ERP & LMS Admin Dashboard Template, **v2.0** |
| Marketplace / item | ThemeForest (Envato) item **29532878**, author dreamstechnologies |
| Licence | ONE Regular License · licensee **Asad Choudhary** · purchased **2026-11-15 08:42:48 UTC** (purchase code first-4 `6368`; full code only in the locally held certificate, never committed) |
| Working variant | **HTML / Bootstrap** (the plan's working variant) |
| Repo | `asadchoudharry/rektrs-preskool`, branch **`html`** |
| Branch commit | **`ac39a717f1028d126aa8ca61134fde2fb971e2cf`** |
| Local frozen tree | `~/workspace/preskool-branches/html/` — git working tree verified **clean** at this commit at freeze time |
| Freeze date | 2026-11-15 |

## 2. Census of the frozen tree (measured at freeze)

| Area | Files |
|---|---:|
| Root — HTML pages | **426** |
| Root — other files (`README.md`, `package.json`, `package-lock.json`, `err3.log`) | 4 |
| `assets/css/` | 15 |
| `assets/fonts/` | 34 |
| `assets/img/` | 595 |
| `assets/js/` | 49 |
| `assets/plugins/` (29 plugin directories) | 5,098 |
| `assets/scss/` | 112 |
| **Total files** | **6,333** |
| **Total size** | **186,738,949 B (~186 MB)** |

## 3. Key asset hashes (SHA-256, from the filed manifest)

| Asset | Bytes | SHA-256 |
|---|---:|---|
| `assets/css/style.css` | 2,178,546 | `92103aba709c6e9f3210e2778947b17a54018f546bcbc62f6f5df6ea3d38aee5` |
| `assets/css/bootstrap.min.css` (Bootstrap v5.3.8) | 232,124 | `4749a2e836504ed8832e73e837e1b36a4180c41bc37d468c51710d609b1ef9ae` |
| `assets/css/bootstrap.rtl.min.css` | 232,925 | `17da0f3655887b2970474b48db13a3db838950a8d3f8e4304855f0218ec54b4d` |
| `assets/css/style.css.map` | 441,679 | `c9c8b8545ae9739a7131334faef5f8b62c0fcf881524a86a7680391feffda52f` |
| `assets/js/script.js` (main JS entry) | — | `6e9ed9d4c8d589862cc59a6a22efde6a15d29f3360efcd5a0bd279d075aa4d8c` |
| `assets/js/theme-script.js` (theme init entry) | — | `f695028aecdb41caf71166bf1f2316854bf191d6f635147a323b69b04a4f3ded` |
| `index.html` (flagship dashboard reference) | — | `18288eddd4a4f3e0d134e51a48caacbd460f7a11320902897e75ac3d7831293e` |

## 4. Full checksum manifest

- **Filed at:** `hidden_files/preskool/pkg0/REFERENCE-PACK-MANIFEST.sha256`
  (6,333 entries, one SHA-256 per file, paths relative to the tree root).
- **Manifest file's own SHA-256:**
  `7358bf825dceb883b34fbe8ade3f6e2d42c6ff17705e31a29da4424bf093ccb1`
- **How any later PKG step proves it is comparing against these bytes:** copy
  the tree (or the repo `html` branch checkout at commit `ac39a717…`), run
  `sha256sum -c REFERENCE-PACK-MANIFEST.sha256` inside it — every line must
  read OK — and confirm the manifest file itself hashes to the value above.

## 5. Freeze rules

1. This tree, at this commit, with these checksums, is the reference pack for
   PKG-1…PKG-6 and PF-8. Captures and diffs are taken against **these pages
   served locally**, per the deployment plan.
2. The vendor live demo is **not** a reference — later demo changes do not
   move the target (D-038 §3 rule, now bound to the package).
3. Any change to the frozen tree (a vendor update, a re-download, a local
   edit) requires a **new freeze record** superseding this one, with its own
   commit/census/manifest. Silent re-freezing is a gate failure.
4. The reconstruction (`hidden_files/preskool/package/preskool-bootstrap-
   reconstruction/` and `hidden_files/preskool/PreSkool_Bootstrap_
   Reconstruction.zip`) is **retired to archive / evidence-only** status: it
   is never re-deployed and never used as a design reference again. It stays
   in place, unmoved and unmodified, because dozens of programme records cite
   its paths as evidence of what the old build assumed. (Handling note: the
   deployment plan says "retire the reconstruction to archive (evidence
   only)"; PKG-0 implements that as a status designation in place rather than
   a physical relocation, for the reason just stated.)

## 6. Provenance notes (recorded, not design differences)

- **Inter:** the vendor package ships **no Inter font files**; `style.css`
  loads Inter via Google Fonts `@import`
  (`family=Inter:wght@400;500;600;700`). `assets/fonts/` holds icon fonts
  only (Feather, FontAwesome, Material Icons, Line Awesome). Staging's
  self-hosted Inter TTFs therefore remain the serving route (deployment plan
  §2a / PKG-1 note).
- **`err3.log`** sits at the frozen tree's root. It is not vendor design
  content; it was present in the staged tree as pushed and is part of the
  frozen bytes as-pushed. Flagged here so PKG-1's vendoring set excludes it
  consciously rather than by accident.
- Vendor documentation + changelog (the v2.0 version record) live on the repo
  `main` branch under `documentation/` and are part of the package record,
  not of this frozen design tree.

## 7. Licence gate

**D-008 is satisfied by this purchase** (ThemeForest 29532878, ONE Regular
License, licensee Asad Choudhary, 2026-11-15). Recorded in the programme
decision log as **D-046** at PKG-0. The production gate in deployment plan §4
still requires this position to be on record in the D-027 cutover package —
it now is.
