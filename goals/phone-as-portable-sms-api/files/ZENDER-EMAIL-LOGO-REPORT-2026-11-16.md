# Zender Email Logo — Investigation & Fix Report — 2026-11-16

**Symptom (owner):** the Settings → Email test message arrived, but the logo in it rendered as a broken "?" mark.

## How the mail logo is built (source evidence)

- Test mail: `App\Mail\TestEmail` (template `admin.test`) extends `App\Mail\BaseMailable`; sent synchronously by `SettingsController::testEmail` (`Mail::to($admin)->send(new TestEmail($admin))`, route `POST settings/mail/test`).
- Shared layout `resources/views/emails/default/html/layout.blade.php`: the header renders `$brand['logo_light']` / `$brand['logo_dark']` as `<img height="32">` when set; otherwise a 28×28 coloured cell holding a 20×20 "mark" glyph next to the site name as text.
- Brand data chain: `BaseMailable::content()` ← `App\Support\EmailTheme::resolve()` ← `App\Support\Branding`:
  - `logo_url` = `Branding::logoUrl(true)` = absolute `url('/storage/' . $site_logo)` when an admin logo upload exists. Setting keys: `site_logo`, `site_logo_dark`, `site_favicon` (group `branding`). Uploads live on the public disk under `branding/<type>-<24 random>.<ext>` and are served only via `/storage/*`.
  - Fallback marks (only when no logo): `Branding::defaultEmailMarkUrl()` = `url('/brand/mark-white.png')` / `url('/brand/mark-dark.png')` when those files exist in `public/brand/`. No CID embedding anywhere; all images are absolute APP_URL-based URLs.

## State found (before the fix)

- `site_logo` = NULL, `site_logo_dark` = NULL, `site_favicon` = NULL — **no logo was configured at all**. `EmailTheme::resolve()` returned `logo_url: null`, `logo_dark_url: null`, and the two `/brand/mark-*.png` mark URLs.
- A real render of the `TestEmail` mailable contained exactly 4 images, all absolute https on sendqon.rektrs.com: `mark-white.png`, `mark-dark.png`, `band-neutral-light-ltr.png`, `band-neutral-dark-ltr.png`.
- All 4 fetched from the public internet: **200, image/png**, valid PNGs (marks are 96×96 RGBA), also 200 with a GoogleImageProxy user-agent, Cloudflare cache HIT with clean headers. The fallback glyph chain was *not* 404ing.
- So the original email contained **no Sendqon logo at all** — only the vendor's tiny 20×20 abstract glyph beside the name. That, plus mail-client remote-image handling, is what presented as the broken "?" logo spot.

## The real platform defect (root cause of the 404 class)

- **`public/storage` symlink was missing in the running container** (`ls public/` showed no `storage` entry). Every `/storage/*` URL — the only route serving uploaded files (branding logos, media library, WA media) — answered **404** (Laravel fallback page, ~473 KB HTML).
- Why: the init lane created the link with `php artisan storage:link` inside the first container. The symlink lives in the container layer (only `storage/` is a volume), so the settle lane's image rebuild + container recreate silently dropped it. The custom entrypoint restored `.env` and permissions on start, but never the symlink.
- Proof: after placing a logo (below), settings and the rendered email pointed at `/storage/branding/logo-….png` and the file existed on the public disk, yet the plain public URL answered 404 while the origin (cache-busted request) served 200.

## Fix applied

1. **Temporary wordmark logos** generated in-container (PHP GD, DejaVu Sans Bold): the word "Sendqon", 1200×300 PNG, transparent background — near-black `#171717` text for light backgrounds, near-white `#FAFAFA` for dark (16,342 / 16,341 bytes).
2. **Registered through the vendor's own mechanism** — `Branding::store('logo' | 'logo_dark', UploadedFile, 'png')`, the same code path as a Settings > Branding upload (validated by `Branding::detectExtension()` = `png`). Current settings:
   - `site_logo` = `branding/logo-q1fxpoflsm1mfyl2bnntuc90.png`
   - `site_logo_dark` = `branding/logo_dark-ayojb001cxlrcszhbzbv52qq.png`
3. **`php artisan storage:link`** run in the live container → `public/storage -> /var/www/zender/storage/app/public`. Origin then served the files (200 from container nginx and via host :8081).
4. **Cloudflare edge had cached the first 404s**: the "Sendqon static assets" cache rule makes `.png` eligible with a 30-day edge-TTL override and had cached the error responses (plain URL: 404, `cf-cache-status: HIT`, Age > 0, while a cache-busted URL returned 200). Worked around without dashboard access by re-storing the logos so the settings point at fresh random filenames (the vendor upload design already rotates the name per upload; `store()` deleted the superseded files itself). No Cloudflare configuration was changed.
5. **Durability — patch register PR-002**: `docker-entrypoint.sh` now recreates the symlink when missing (new step 3 + a guarded `php artisan storage:link` before `exec`). Patched in the host build tree (`~/sendqon-build/src/`, `sh -n` syntax-checked), the goal-files copy, and both repo copies. **Caveat:** the patch takes effect from the *next image build*; a container recreate from the current image before that build loses the symlink again — the remedy is the same one command (`php artisan storage:link` in the app container).

No vendor templates or vendor PHP were edited.

## Verification (after the fix)

- `https://sendqon.rektrs.com/storage/branding/logo-q1fxpoflsm1mfyl2bnntuc90.png` → **200, image/png, 16,342 B** (fetched twice; the second hit is the edge-cached 200).
- `https://sendqon.rektrs.com/storage/branding/logo_dark-ayojb001cxlrcszhbzbv52qq.png` → **200, image/png, 16,341 B** (twice).
- Re-rendered `TestEmail`: the header now carries both logo URLs (`alt="Sendqon"`, height 32) plus the two band images (200-verified).
- The served wordmark file was downloaded and visually checked: clean bold "Sendqon".
- **One fresh test email** sent through the app's own code path (the identical call `SettingsController::testEmail` makes) → transport accepted it, no exception. The fixed header is visible in that message.
- Stack otherwise untouched: all containers Up; `https://sendqon.rektrs.com/` → 200.

## What remains / recommendations

- The wordmark is a **temporary placeholder** (plain bold text). Replace both Branding slots with the real Sendqon logo from the white-label kit when it arrives (Settings > Branding upload, or the same `Branding::store` path) — each upload gets a fresh URL, so no cache issue recurs. The favicon slot was left on the vendor default (serves 200); upload a Sendqon favicon with the kit.
- Cloudflare: the static-assets cache rule caches *error* responses for image extensions for up to 30 days ("Ignore cache-control header" + edge-TTL override). Consider not caching 4xx, or purge the two now-unreferenced dead URLs (`/storage/branding/logo-jyjtlqxjcyaaewjlpjawbfo9.png`, `/storage/branding/logo_dark-rj2vocj70jxjfl4wweastcur.png`) — cosmetic only; nothing references them.
- PR-002 lands with the next image build; until then, any recreate needs the one-command symlink restore noted above.
