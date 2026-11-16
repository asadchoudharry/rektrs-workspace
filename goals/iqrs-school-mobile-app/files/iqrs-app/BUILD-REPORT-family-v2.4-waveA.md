# IQRS Family App v2.4 — Wave A build report

**APK:** `IQRS-Family-App-v2.4.apk` — 1,102,258 bytes
**sha256:** `d4b0377b58af3cfadf674f8e3436d1d5b876073d743bc2cb19d4c8f80ebd5cf0`
**Package:** `pk.edu.iqrs.family` · versionCode **15** · versionName **2.4** · minSdk 26 · targetSdk 34
**Permissions:** `INTERNET` only (unchanged — downloads live in app-private storage; no storage permission, no new permission of any kind).
**v2.3 APK untouched** (sha256 still `04f5f83f…`). The Admin flavour still builds clean and is unchanged (code 19 / v2.6); the two shared-touch changes are behaviour-neutral for it (see "Shared files" below).

Wave A delivers the six parity features from `FAMILY-PARITY-PLAN.md` §4 that the vendor student/parent API already supports: Downloads + a shared file pipeline, Events/Calendar + tasks, My Subjects, the Library catalogue, Forgot password, and Share App. Everything follows the v2 design system (brand band, tinted cards, per-card failure isolation) and the language lockdown (no connectivity-pill vocabulary anywhere; a failed save says plainly it couldn't be saved).

## Per-feature notes

### 1. Downloads + file pipeline
- **Screen** (`ui/family/DownloadsScreen.java`): entries from `getDownloadsLinks`; when the payload names a class, files group under **Assignments / Study material / Syllabus / Other documents** in that fixed reading order (see surprise #1 for how the category is derived). Each file row shows its name, type badge and size when the server gives one. Video entries (the payload's video-link shape) open in the browser/player directly, exactly like the web app. Below the entries, a **"Saved on this phone"** section lists everything previously saved, so saved files stay reachable without any connection.
- **Pipeline** (`data/FileDownloader.java` + `data/SharedFileProvider.java`): one authenticated helper used by every feature below. It sends the family session headers, streams to `files/downloads/` under a `.part` name and renames on completion (a cut-off save never masquerades as a finished file), reports progress, and classifies failures honestly (server refusal vs unreachable). Opening uses a view intent against a minimal in-tree content provider — the tree has **no AndroidX**, so `SharedFileProvider` was written by hand: read-only, serves **only** the downloads directory, rejects any path that escapes it, and is `exported=false` with per-URI grants. Saved files persist in app-private storage and remain available with no connection.
- **Dead end (a) — homework documents:** `HomeworkDetailActivity` now renders the teacher's document (already mapped as `HomeworkItem.documentPath`) as an attachment row wired to the same pipeline: Save → progress on the row → Open.
- **Dead end (b) — notice attachments:** the notice detail's attachment row (previously a dead label) is now wired the same way.

### 2. Events / Calendar
- **Screen** (`ui/family/EventsScreen.java`): month grid (Mon-first) for the month being viewed, with gold dots on event days and blue dots on task days; tapping a day lists what falls on it; an **"All my tasks"** section sits under the grid with done tasks chipped in green. Prev/next month re-queries, because the server only returns events overlapping the requested window. Module-gated by `getModuleStatus` code `calendar` where the school has it configured (fail-open, like the existing gates).
- Events come from the `public_events` + `date_lists` the dashboard response **already carried** and the app used to discard; tasks come from `getTask` with the same user id the dashboard call uses for each role. Multi-day events are expanded across their span (capped at 62 days).

### 3. My Subjects
- **Screen** (`ui/family/SubjectsScreen.java`) over `getstudentsubject`: subject rows with the shared monogram badge, subject-code chips, and a teacher line **only when a row actually carries one** (see surprise #2). Reached from a Home bento tile and a More grid tile (ungated — no module code for subjects exists in the evidence).

### 4. Library catalogue
- `LibraryScreen` gains two mode chips: **"Books with me"** (the existing issued/returned view, byte-for-byte behaviour unchanged) and **"All books"** — the full catalogue from `getLibraryBooks` with a search field filtering by title or author as you type (pure, unit-tested). Rows show title, author · subject · publisher, total copies, and the book-number chip. Honest empty states for an empty catalogue and for a search with no match.

### 5. Forgot password
- "Forgot password?" under the family sign-in card (staff sign-in untouched — the hook in `BaseLoginActivity` is a no-op the staff screen doesn't override). The dialog explains plainly that a reset link will be **emailed**, takes the registered email, and asks Student or Parent (the service needs the account type to find the address). The confirmation shown follows the **actual response** (see surprise #4): only a real "check your email" answer produces the sent confirmation naming the address; an unknown address, a mail failure, or any other answer keeps the dialog open with the matching plain message.

### 6. Share App
- A **"Share the app"** row in the More → account card (above Sign out): system share sheet with the school's name (from the signed-in session) and the school site link. Pure intent — no new permission, no data leaves the phone except what the user picks in the sheet.

## Endpoint-shape surprises vs the plan (stated plainly)

1. **Downloads payload has NO category column.** `share_contents` rows carry title/description/validity but nothing that says "assignment" vs "syllabus". The mapper reads a `content_type`/`type` field **if a future payload ever carries one**, and otherwise groups by the title's own words (assignment / study material / syllabus), falling back to "Other documents" — never inventing a category the school didn't write. Also: the response is a **bare top-level array** (not wrapped in an object), and `getDownloadsLinksById` returns the same documents unwrapped — the mapper tolerates both shapes.
2. **`getstudentsubject` carries NO teachers.** The vendor query joins subjects and subject-groups only — no teacher column exists in the row. The mapper picks a teacher up if a payload ever includes one, but on today's server the Subjects screen shows codes and names only; no teacher names were invented.
3. **`getLibraryBooks` is GET-only.** A POST earns HTTP 400 from the vendor. `ApiClient` therefore grew a `getRaw` sibling (identical headers and status classification) used only by the catalogue call. Its answer is `{success:1, data:[…]}` — and `success:0` + message when the library is empty, which the mapper already treated correctly.
4. **Forgot password's "wrong email" answer is HTTP 401 with a JSON body** (`Invalid Email or User Type`) — the same status the transport layer uses for an expired session. The repository maps that one call's 401 to the honest "no account matches" outcome instead of a session-expired logout. Also note the service only claims success when the mail actually went out; a "Sending of message failed" 200 is surfaced as its own message, not as success.
5. **Homework documents may be a bare filename.** The only fixture row has the field empty; where a value exists it can be either a stored path (`uploads/homework/…`) or a bare file name. Bare names are resolved under `uploads/homework/` per the vendor's own homework-upload convention — flagged here as a convention assumption, not a verified live example (no production homework row with a document was available to check).
6. **Notice attachments are site-root-relative paths** (`uploads/notice_board_images/<file>`). They must resolve against the site origin, **not** under `/api/` (under `/api/` they 404) — the same rule the photo pipeline already proved; `FileLinks.urlFor` reuses `ImageUrls.resolve` for exactly this.

## Tests & gates

- **JVM suite: 153 tests, OK** (was 138; +15 in `FamilyWaveATest` covering the downloads mapper incl. video entries and category grouping, events + `date_lists` merge, tasks, subjects, the catalogue mapper + search matching, the forgot-password outcome mapping incl. the mail-failure distinction, and the file pipeline's pure logic — filename sanitising, URL resolution, homework-path resolution). Full suite = family + shared baseline, as run by `tools/run_tests.sh`.
- **Banned-strings lint: PASSED** (all checks, incl. the new strings).
- **Metadata gate:** aapt2 badging = `pk.edu.iqrs.family`, versionCode **15**, versionName 2.4, INTERNET-only; `apksigner verify` OK; packaged manifest contains the file provider with authority `pk.edu.iqrs.family.files`, `exported=false`. Dex contains the new screens/pipeline classes (verified by dexdump).
- **Admin regression:** `./build.sh admin` still builds (code 19 / v2.6, unchanged properties).

## Shared files touched (Admin-neutral)

- `api/ApiClient.java` — added `getRaw` (GET sibling of `postRaw`); `api/ApiConfig.java` — added `SITE_URL` (allowlisted file) and made the four header-name constants public so the download helper sends byte-identical headers.
- `AndroidManifest.xml.tpl` — the file-provider entry (both flavours get their own authority from `__PACKAGE__`; admin behaviour unchanged).
- `ui/BaseLoginActivity.java` — one no-op hook call (`addBelowCard`); only the family login overrides it.
- New shared classes: `data/FileDownloader.java`, `data/SharedFileProvider.java`, `api/FileLinks.java`, and the Wave A mappers/models — family code paths only.
