# CORE — Files & Storage

**Status: core-owned (purchased).**
Sources: Lane 2 (Storage), Lane 4 §B, Lane 5 §§2, 4.

## Purpose
Tenant file manager + the platform's only storage layer: media from
messages, recordings, imports/exports, tickets, logos. **Local disk
only — this release has no working S3** (see `05-INFRA.md`).

## Screens / pages (tenant, Lane 4)
- Files: 27 files / 532 KB in demo; a "Recordings" folder (8 items);
  filters Source / Type / Channel / Size / Date; New Folder / Upload.
- Media handling: message attachments, voice notes (ffmpeg
  transcoding), call recordings land here via `stored_files`.

## Rules
- Layout under `storage/app`: `private/wa-media` (WhatsApp media),
  `private/` (imports, exports, tickets), `public/` (Messenger logos).
- Access via **signed short-lived links**; uploads in 5MB chunks.
- 80% usage warning; when storage is full, inbound messages are saved
  **without** their files (message text is never lost to a full disk).
- `php artisan storage:recalculate [--tenant=ID]` rebuilds usage.
- Media library plumbing: spatie/laravel-medialibrary 11.23.1.

## Data (tables)
`stored_files`, `file_folders`, `message_attachments`.

## Plan gates
`max_storage_mb` and `max_file_size_mb` per plan; exceeding storage →
422 `storage_quota_exceeded`.

## Keep / extension notes
- Core-owned. Backup rule: tenant storage is part of the consistent
  snapshot (real files, not symlinks) — `05-INFRA.md`.
- Disk sizing is an infra decision: WA media + call recordings grow
  fastest; recordings pruning exists (`calls:prune-recordings` daily).
- Our plugins must store files through core storage services
  (`MarketFileStorage` contract exists for market files) — never write
  ad-hoc paths.
