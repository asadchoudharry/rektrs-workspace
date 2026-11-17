# Sendqon White-Label Kit — Site Branding Applied — 2026-11-17

**Scope:** apply the new Sendqon white-label kit to the live site's own branding, replacing the temporary GD wordmark (2026-11-16 email-logo fix) and the vendor default favicon. Done entirely through the vendor's own `App\Support\Branding::store()` path — the same mechanism as a Settings → Branding upload. No vendor code edited.

## Kit source files

From `files/whitelabel-kit/`:

| Kit file | Dimensions | Size |
|---|---|---|
| `logo.png` (dark-ink wordmark, light backgrounds) | 1760×440 | 28,047 B |
| `logo-dark.png` (light wordmark, dark backgrounds) | 1760×440 | 28,079 B |
| `favicon-512.png` | 512×512 | 20,239 B |

## Pre-check

- `public/storage` symlink **present** in the running container (`public/storage -> /var/www/zender/storage/app/public`) — the PR-002 failure mode from 2026-11-16 did not recur; no `storage:link` run was needed.
- All 7 containers Up before and after.

## Settings changed (group `branding`, filenames only)

| Setting | Before | After |
|---|---|---|
| `site_logo` | `branding/logo-q1fxpoflsm1mfyl2bnntuc90.png` (temporary wordmark) | `branding/logo-o6useyxeliyh2bllrha1m8bd.png` |
| `site_logo_dark` | `branding/logo_dark-ayojb001cxlrcszhbzbv52qq.png` (temporary wordmark) | `branding/logo_dark-g1aj33we0kz2nma8l2xl1ksm.png` |
| `site_favicon` | *(null — vendor default)* | `branding/favicon-hyymtvzkob0nbqt3perks6oz.png` |

Each registration went through `Branding::detectExtension()` (= `png`) + `Branding::store('logo' | 'logo_dark' | 'favicon', UploadedFile, 'png')` and returned `true`. Fresh random filenames per store — so no Cloudflare cached-404 risk (the 2026-11-16 trap) applies to these URLs. `store()` removed the superseded temporary wordmark files itself.

## Verification

- `https://sendqon.rektrs.com/storage/branding/logo-o6useyxeliyh2bllrha1m8bd.png` → **200, image/png, 28,047 B** (byte size matches the kit file).
- `https://sendqon.rektrs.com/storage/branding/logo_dark-g1aj33we0kz2nma8l2xl1ksm.png` → **200, image/png, 28,079 B** (matches kit).
- `https://sendqon.rektrs.com/storage/branding/favicon-hyymtvzkob0nbqt3perks6oz.png` → **200, image/png, 20,239 B** (matches kit).
- Homepage (`https://sendqon.rektrs.com/` → 200) HTML references the new logo and the new favicon storage paths.
- A rendered `App\Mail\TestEmail` carries both new logo URLs in its header; **one fresh test email** was then sent through the app's own code path (the identical `Mail::to($admin)->send(new TestEmail($admin))` call `SettingsController::testEmail` makes) → transport accepted it, no exception. The owner can see the new kit logo in that message's header.
- `https://sendqon.rektrs.com/login` → 200. All 7 containers Up (sendqon, sendqon-db, sendqon-queue, sendqon-reverb, sendqon-scheduler, sendqon-whatsapp, sendqon-smpp).

## Notes

- The site's own branding is now fully on the white-label kit. Remaining kit assets (`icon-master-1024.png`, `play-store-512.png`, `favicon-64.png`, `sendqon-app-icons.zip`) are for the portal app build, not the website, and were not touched here.
- PR-002 caveat still stands for the future: the storage symlink lives in the container layer until the patched entrypoint ships in the next image build; a recreate before that build needs the one-command `php artisan storage:link` restore.
