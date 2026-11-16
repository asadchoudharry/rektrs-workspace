# ZENDER PACKAGE INVENTORY — 2026-11-15

Owner order: "Zendor ko sendqon per push ker do" (2026-11-15 ~16:21 PKT).
Result: **PUSHED + VERIFIED** to `asadchoudharry/Sendqon` in the approved
per-component branch layout.

## Package facts (from the licence certificate + the package's own files)

| | |
|---|---|
| Product | Zender – WhatsApp & SMS Messaging SaaS with Shared Inbox, Campaigns and Chatbots |
| Version | Zender v5.0 (`composer.json` description; `autosetup.sh` header) |
| Marketplace | CodeCanyon, item **26594230** |
| Author | **titansys** (Envato username per certificate; composer package `titansystems/zender-laravel`) |
| Purchased | 2026-11-15 08:42:48 UTC |
| Licence | Envato **Regular License** ("ONE REGULAR LICENSE" per certificate) |
| Licensee | Asad Choudhary |
| Purchase code | first-4 `7780` — full code and certificate file held locally only, **never committed** |
| Download | "All files & documentation" zip, 142,077,109 B, in `~/workspace/browser_downloads/sess-4013504447/` |
| Extracted | `~/workspace/zender-package/` — 365 MB, 26,887 files |
| Role | Base product for Rektrs' SMS/WhatsApp brand **Sendqon** |

## Inventory — what the package actually contains

Exactly two top-level components; the app is a **single indivisible web
application** (no separately-shippable variants, no nested archives):

| Component | Files | Notes |
|---|---|---|
| `Install/` | 26,797 | The complete application release. Laravel 13 + PHP ^8.4 backend; React 19 + Inertia 3 + Tailwind CSS 4 frontend; shipped `vendor/` tree (245 MB) and compiled `public/build` included — vendor docs state the release needs no dependency install or asset build. Plugin system inside the app (`app/Plugins`: Channels, Integrations, PaymentGateways with bundled PayPal + BankTransfer, SmsProviders, WaProviders, WabaProviders, AiIntegrations, TelegramExtensions, Tools). One-shot VPS installer `autosetup.sh` (Ubuntu 24.04: nginx + PHP-FPM 8.4 + MySQL 8 + Reverb + SSL). |
| `Documentation/` | 90 | Vendor owner documentation: HTML site (`index.html`, assets, screenshots) + Markdown guides in `md/` (installation, VPS setup, channels, campaigns, plugins, API, payment gateways, backups, upgrade guide, …) + `llms.txt`/`llms-full.txt`. |

**Not in the package** (measured, not assumed): no Android gateway app source
and no APK/AAB anywhere in the tree; no separate addons bundle; no nested
zip/rar archives. The Android device gateway and the vendor's WhatsApp
backend binary are separate vendor artefacts (the installer script itself
notes the WhatsApp backend "is deployed separately").

## Exclusions / safety checks

- Licence certificate: **excluded** (never staged; it lives only next to the
  download). Grep of the extracted tree for the order number: no hits.
- `.env`: the package ships only `.env.example`, verified **placeholders
  only** (all secret values empty) — included as shipped. No real `.env`
  exists anywhere in the tree.
- Oversize files: **none** — largest file 23 MB (`vendor/mpdf` font), far
  under GitHub's 100 MB limit. No file excluded for size.
- `vendor/` **included in full**: it is part of the shipped release and the
  vendor installer relies on it (fidelity over size, per standing rule).
- Nothing else excluded. `database/.gitignore` (ships in the package) ignores
  `*.sqlite*`, but no sqlite files ship — zero files lost to it.

## Branch map (asadchoudharry/Sendqon)

| Branch | Contents | Files (staged = remote) | Commit |
|---|---|---|---|
| `main` | Authored `README.md` (package index + licence facts) + `PRODUCT.md` (Sendqon product note) + vendor `Documentation/` as shipped | 92 | `b296ba2094babd26409eed35d23274b454eb4713` |
| `app` | Package `Install/` contents at branch root, as shipped + authored branch `README.md` (stack, structure map, install/run from vendor docs) | 26,798 | `73252b4837a4121176c99d5f6caa6c08d31acc05` |

Push route: SSH with the repo's dedicated deploy key
`~/.ssh/id_ed25519_gh_sendqon` (IdentitiesOnly), author
"Rektrs Automation <dev@rektrs.com>". Staged trees remain at
`~/workspace/zender-branches/{main,app}`.

## Verification (all passed)

- `git ls-remote`: HEAD → `main` at `b296ba2…`; `refs/heads/app` at
  `73252b4…` — both match the local push commits.
- Remote re-fetch + `git ls-tree -r` counts: main **92**, app **26,798** —
  delta 0 vs staged counts on both branches.
- GitHub connector read-back of `README.md` on `main` (account
  490f14431f384250855c8c62516f08ca): content live exactly as authored,
  resolved at commit `b296ba2094babd26409eed35d23274b454eb4713`.
