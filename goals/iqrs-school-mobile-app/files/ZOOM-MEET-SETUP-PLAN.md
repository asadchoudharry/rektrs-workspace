# Zoom + Google Meet Setup Plan — IQRS (Smart School 7.2)

**Purpose:** take the two live-class addons from "installed" to "a teacher schedules a class and a student/parent joins it from the app" — staging first, then production.
**Status of this document:** plan only. Nothing in it has been executed. Settings saves on production are **owner actions** (his accounts, his credentials) — Muse never receives, sees, or enters Zoom/Google secrets.

**Sources used (held evidence, no web guessing):** staging-tree vendor code (`Zoom_api.php`, `Google.php`, `admin/Conference.php`, `admin/Gmeet.php`, API-tree `Conference_model.php` / `Gmeet_model.php`, `Webservice.php` lines 2929–3070), the staging DB export of 2026-11-07 12:14 PKT, the coordinator's live API probes, and the read-only production admin verification of 2026-11-07 23:31 PKT.

**Version note (read first):** production's Addon Manager reports **Zoom Live Classes v8.0** and **Gmeet Live Class v7.0** (the Gmeet addon's own `addon_info.json`, product 28941973, also says 7.0). The held staging code copy is an older build (its config files say Zoom 7.0 / Gmeet 6.0). Every field and flow below was either read in that code **or** observed live on the production panel tonight — they agree. If an executor ever faces a screen that differs from this plan, the live panel wins and the difference should be reported back.

---

## 1. Where things stand (verified)

### Both sites
- Addons installed and active; sidebar menus exist for **Zoom Live Classes** and **Gmeet Live Classes** on production (verified live tonight) and staging (module catalog + owner's install).
- The family API module catalog lists **"Zoom Live Classes"** and **"Gmeet Live Classes"** as ON.
- **Zero classes are scheduled anywhere** — `liveclasses` and `gmeetclasses` probes return empty lists, and production shows 0 Zoom / 0 Gmeet classes. Nothing can appear in any app until a class is created; this is expected, not a fault.
- No database or code change is needed for any step in this plan. All tables (`zoom_settings`, `gmeet_settings`, `conferences`, `conference_sections`, `gmeet`, `gmeet_sections`) already exist.

### Zoom
| | Staging | Production |
|---|---|---|
| Settings row (`zoom_settings`) | **Does not exist** — API `getzoomsettings` returns null | Page exists; **Zoom API Key + Zoom API Secret both EMPTY** |
| Access token | Not generated | Banner on the Setting page: *"Access Token not generated, Please authenticate your Account."* |
| Classes | 0 | 0 |

### Gmeet — read this carefully, the evidence disagrees with itself
| | Staging | Production |
|---|---|---|
| Settings row (`gmeet_settings`) | **A row exists** (in the DB since before today; the API returns it) — **but** the 12:14 export shows that row with `api_key`/`api_secret` stored as **empty strings** and `use_api = 0` | Setting page: **API Key EMPTY, API Secret EMPTY, "Use Google Calendar Api" = Disabled, "Parent Live Class" = Disabled** |
| Classes | 0 | 0 |

**Position:** Gmeet is **not "configured" anywhere**. On staging a settings row exists but its contents are unproven and possibly stale (blank in the only hard snapshot we hold). On production it is simply empty. The plan therefore treats Gmeet as unconfigured on both sites: staging starts with an eyeball-and-test step, production starts with credential entry regardless.

### The app
- IQRS Connect has **no Live Classes screen yet**. That screen is already scoped in the in-flight wiring lane (always-present Live Classes option; three honest states — classes listed with Join / none scheduled yet / not set up yet; Join opens the meeting via the system). It is the app deliverable for this programme; this plan's test protocol uses it, with API probes as the fallback proof if the build has not landed when a test runs.

---

## 2. How the two addons actually work (from the vendor code — this decides every step)

### Zoom (one school account, connected per browser session)
- The Setting page is **Zoom Live Classes → Setting** (`/admin/conference`). It asks for exactly two values: **Zoom API Key** and **Zoom API Secret**, plus toggles (below). Saving creates the single `zoom_settings` row (upsert — first save creates it, which is why staging has no row yet).
- In the code (`Zoom_api.php`), those two values are used as an **OAuth app's Client ID and Client Secret** — *not* a Server-to-Server OAuth app and *not* a JWT app:
  - "Authenticate" opens `zoom.us/oauth/authorize?...&client_id={Zoom API Key}&redirect_uri={site}/admin/conference/generatetoken`.
  - The callback exchanges the code at Zoom's `/oauth/token` with Basic auth `base64(Client ID : Client Secret)` and stores the **access token in the admin's browser session** (not in the database). A refresh token is held the same way.
  - Creating a class calls `POST /v2/users/me/meetings` with that token — **the meeting is created on the Zoom account of whoever authenticated**.
- Consequences that shape the plan:
  1. The values must come from an **OAuth app** created in the school's Zoom account (Zoom App Marketplace → Build App → **OAuth**, user-managed). A Server-to-Server OAuth app's Account ID / Client ID / Secret set will **not** fit — there is no Account ID field anywhere in this addon.
  2. The OAuth app must whitelist the redirect URLs or Zoom refuses the sign-in:
     - `https://iqrs.edu.pk/admin/conference/generatetoken` and `https://iqrs.edu.pk/admin/conference/stafftoken`
     - `https://staging.iqrs.edu.pk/admin/conference/generatetoken` and `https://staging.iqrs.edu.pk/admin/conference/stafftoken`
  3. The OAuth app needs permission to create meetings on the connected user's account (the meeting-write scopes Zoom offers during app setup). If class creation later fails with a Zoom scope/permission error, this is the place to fix it.
  4. **"Authenticate" is a per-person, per-browser step.** Whoever creates a class must have clicked Authenticate and signed in to Zoom in that same browser session; the Add Class form refuses without it — that refusal is exactly the banner production shows today. Re-authenticating when the token expires is normal routine, not a breakdown.
- Setting-page toggles (same form): **Use Teacher API** (off = one global school account for everyone; on = each teacher saves their *own* Zoom OAuth app credentials under their staff profile and classes run on teachers' own Zoom accounts), **Use Zoom App for staff / for students** (join via the Zoom app vs browser), **Parent Live Class** (whether parents see live classes in the web student/parent panel — the mobile API feed does not apply this flag, but set it for web-portal parity).
- **Recommendation: Use Teacher API = OFF (global mode).** One school Zoom account, one credential pair, no per-teacher app setup.

### Gmeet (two modes — pick one)
The Setting page is **Gmeet Live Classes → Setting** (`/admin/gmeet/index`), gated by the `gmeet_setting` privilege (Super Admin / admin). Fields: **API Key**, **API Secret**, **Use Google Calendar Api** (`use_api`), **Parent Live Class**. In the code (`Google.php`), API Key/Secret are fed to Google as an **OAuth 2.0 Client ID and Client Secret** (`setClientId(api_key)`, `setClientSecret(api_secret)`), scope = full Google Calendar, redirect URI = `{site}/admin/gmeet/authenticate`.

- **API mode (`Use Google Calendar Api` = Enabled):** the class creator must also connect their Google account once per browser session (the Gmeet pages prompt for it when no `google_token` is in session; callback is `/admin/gmeet/authenticate`). Creating a class then makes a **Google Calendar event** on that Google account and stores the event's Meet link (`hangoutLink`) as the class URL.
  - Owner-side Google Cloud work: a Google Cloud project with the **Google Calendar API enabled** and an **OAuth 2.0 client (Web application)** whose **Client ID → API Key** field and **Client Secret → API Secret** field, with authorized redirect URIs `https://iqrs.edu.pk/admin/gmeet/authenticate` and `https://staging.iqrs.edu.pk/admin/gmeet/authenticate`.
  - If the Google Cloud OAuth consent screen is left in "Testing" mode, Google limits who can connect and expires tokens after 7 days — publish the consent screen (or at least add every class-creating staff Google account as a test user). Owner-side setting; flag it, don't discover it mid-term.
- **Manual mode (`Use Google Calendar Api` = Disabled):** no credentials at all. The Add Class form gains a required **Gmeet URL** field — the teacher creates a meeting at meet.google.com themselves and pastes the link. Simplest possible start; the trade-off is links are made by hand, outside school control.
- **Recommendation:** start Gmeet in **manual mode** for the first real classes (zero credential risk, proves the whole chain), and treat API mode as a phase-2 upgrade once the office is comfortable.

### How a class reaches a student (both providers, same pattern)
- Add Class forms (Zoom: `admin/conference` Add Class; Gmeet: `admin/gmeet` Add Class) require: **Class Title, Date & Time, Class, Section(s) (multi-select), Duration (minutes)**; Zoom additionally requires **Meeting Password, Host Video, Participant Video**; Description is optional on both.
- Saving writes one class row plus one link row per chosen section (`conference_sections` / `gmeet_sections`, keyed by class-section).
- The API then returns the class to **any student whose own class + section matches a linked section, in the current session** (`getByStudentClassSection`). There is **no date filter** in the API query — past and upcoming classes for that section are all returned, newest first — and Zoom rows carry a `join_url` extracted from the stored Zoom response; Gmeet rows carry their `url` directly.
- Practical meaning: targeting is everything. A class created for the wrong section is invisible to the intended students; a class for the right section cannot be missed by the API.

---

## 3. Remaining steps — in order

Legend — **WHO:** Owner personally / School office (admin-panel user) / Muse. **Rule:** every credential value is typed by the owner or office directly into the panel or the provider's site. Nothing secret goes through chat, and Muse never enters one.

### Phase A — Zoom on staging
| # | Who | Where | What | Verified by |
|---|---|---|---|---|
| A1 | Owner | School Zoom account → Zoom App Marketplace → Develop → Build App → **OAuth** (user-managed) | Create the app; add all four redirect URLs from §2 (staging pair + production pair — one app can serve both sites); grant the meeting-create scopes Zoom offers | The app shows a **Client ID** and **Client Secret** |
| A2 | Owner / office | Staging panel → Zoom Live Classes → Setting (`staging.iqrs.edu.pk/admin/conference`) | Paste **Client ID → "Zoom API Key"**, **Client Secret → "Zoom API Secret"**; set **Use Teacher API = No**, Parent Live Class = Yes; Save | Page reloads with both fields filled (values masked on screen) |
| A3 | Muse | API probe | — | `getzoomsettings` **stops returning null** and returns the settings row — proves the save landed |
| A4 | Office (signed in as admin/teacher on staging) | Same Setting page → **Authenticate** | Sign in with the **school Zoom account**; approve the app | Banner gone; no "access token not generated" message |
| A5 | Office | Staging → Zoom Live Classes → Add Class | Create ONE test class: title e.g. "TEST Zoom Class", targeted at the **staging fixture child's class/section (Seven – Diamond)**, a near-future time, duration 30, any password | Form returns success; class appears in the staging class list |
| A6 | Muse | API probe `liveclasses` for the fixture student | — | The class is returned **with a `join_url`** — proves targeting + stored Zoom response |
| A7 | Muse + owner | Connect app (Live Classes screen, wiring-lane build) on staging data | Open Live Classes for the fixture child; tap **Join** | Class listed; Join opens the Zoom meeting link |
| A8 | Office | Staging class list | Delete the TEST class after A6–A7 | List and probe both empty again |

### Phase B — Gmeet on staging (prove or replace the mystery row)
| # | Who | Where | What | Verified by |
|---|---|---|---|---|
| B1 | Office | Staging panel → Gmeet Live Classes → Setting (`/admin/gmeet/index`) | **Look, don't touch:** record what API Key / API Secret / Use Google Calendar Api / Parent Live Class actually show today (held evidence disagrees — §1) | The true current state is known and written down |
| B2 | Office | Staging → Gmeet Live Classes → Add Class | Create ONE test class for **Seven – Diamond**. If the form asks for a **Gmeet URL**, the staging row is in manual mode — paste a Meet link from the school Google account and save. If it instead demands a Google sign-in / tries the API, it is in API mode with whatever credentials the row holds | Save succeeds — **this is the verdict on the staging row**: manual-mode save proves the display chain; API-mode success proves the stored credentials genuinely work; any failure proves they don't |
| B3 | Muse | API probe `gmeetclasses` for the fixture student | — | The test class is returned **with its `url`** |
| B4 | Muse + owner | Connect app, Live Classes, staging data | Open the class; tap Join | Meet link opens |
| B5 | Office | Staging Gmeet list | Delete the test class | Probe empty again |
| B6 | Owner | Decision point | Choose production mode: **manual** (recommended first) or **API** (needs Phase C2's Google Cloud work). Staging's result in B2 informs but does not decide this | Decision recorded |

### Phase C — Production
Production saves are **owner actions**. Production was verified tonight: both providers' settings are empty, so production starts from zero regardless of what staging's row turns out to be.

| # | Who | Where | What | Verified by |
|---|---|---|---|---|
| C1 | Owner / office | Production → Zoom Live Classes → Setting (`iqrs.edu.pk/admin/conference`) | Same Zoom Client ID + Client Secret as A2 (same OAuth app — the production redirect URLs were whitelisted in A1); Use Teacher API = No; Parent Live Class = Yes; Save. Then **Authenticate** with the school Zoom account | Banner gone. Muse re-probes production-facing behaviour on request (admin read-only check: fields filled, banner cleared) |
| C2 | Owner | **Only if Gmeet API mode was chosen in B6:** Google Cloud Console, school Google account | Create/open the project → enable **Google Calendar API** → OAuth consent screen (publish it) → Credentials → **OAuth client ID (Web application)** → add redirect URI `https://iqrs.edu.pk/admin/gmeet/authenticate` (staging's too, if staging API mode is wanted) → note Client ID + Client Secret | Client ID/Secret exist in the console |
| C3 | Owner / office | Production → Gmeet Live Classes → Setting (`iqrs.edu.pk/admin/gmeet/index`) | **Manual mode:** set Use Google Calendar Api = Disabled, Parent Live Class = Enabled, Save (no key/secret needed). **API mode:** paste Client ID → API Key, Client Secret → API Secret, Use Google Calendar Api = Enabled, Parent Live Class = Enabled, Save | Page reloads with the chosen state saved |
| C4 | Office | Production, both providers | One **real** class each, properly targeted (real class + section, real timetable slot): Zoom via Add Class after Authenticate; Gmeet via Add Class (API mode: connect Google when prompted; manual: paste the teacher's Meet link) | Classes visible in the production class lists |
| C5 | Muse + office | API probes + one parent/student login | Probe `liveclasses` / `gmeetclasses` for a student of the targeted section; check the web portal and — once the wiring-lane build is in hand — the app | Each class returns with its join link for the right students only |
| C6 | Office | Routine from here | Teachers create classes from the same Add Class screens; Zoom creators click Authenticate first whenever the banner reappears; Gmeet API-mode creators reconnect Google when prompted | Ongoing |

---

## 4. End-to-end test protocol (the acceptance ladder)

Run per provider, staging first, production second. A provider is "live" only when every rung passes on production.

1. **Settings rung** — Setting page saved; for Zoom, `getzoomsettings` probe returns a row instead of null (staging) / banner cleared on the production Setting page.
2. **Auth rung** — Authenticate (Zoom) or Google connect (Gmeet API mode) completes with the school account, no error.
3. **Create rung** — a class targeted at a known class+section saves successfully and appears in the panel class list.
4. **API rung** — `liveclasses` / `gmeetclasses` for a student of that section returns the class **with a working join link** (`join_url` / `url`); a student of a *different* section does not receive it.
5. **App rung** — the Connect Live Classes screen lists the class for that child and **Join** opens the meeting; a sibling in another section doesn't see it.
6. **Cleanup rung (staging only)** — test classes deleted; probes empty. Production keeps its real classes.

**Rollback:** there is nothing to roll back in the destructive sense. No step changes code or schema. A wrong settings save is fixed by editing the same form (single-row upsert); turning Gmeet's API mode off returns it to manual mode; deleting a class from its list removes it for students (Zoom deletion also cancels the Zoom meeting). The only irreversible-ish item is the Zoom/Google app creation in the owner's own accounts — and even that is just an unused app if abandoned.

---

## 5. Limits the owner should know

- **The connected Zoom account's plan is the ceiling.** Classes are created on the account that authenticated. A Zoom **Basic (free)** account caps group meetings (3+ people) at **40 minutes** and one host cannot run two meetings at the same time — a real constraint for whole-school timetabling. Treat a paid school Zoom account as the practical requirement for daily live classes; this plan takes no position on which plan to buy, and no price is quoted here because no held source states one.
- **The Zoom access token lives in the browser session, not the database.** Expect "please authenticate" to reappear over time (new browser, cleared cookies, expired token). It is a 30-second sign-in, not a fault — but it means class creation is tied to a person + browser, and the office SOP should say so.
- **Global mode = one Zoom identity.** With Use Teacher API off, every class is hosted by the school Zoom account that authenticated, even when different teachers create them. If the school later wants classes on teachers' own Zoom accounts, that is what Use Teacher API + per-teacher credentials (each teacher creates their *own* Zoom OAuth app) is for — a deliberate phase-2, not a fix.
- **Gmeet API mode = a Google account dependency.** Meet links are minted as Calendar events on the connected Google account's calendar; that account's Google Workspace/free-tier rules govern Meet features (recording, attendance tracking, breakout rooms are Workspace-edition features). Manual mode avoids the dependency but links are hand-made by teachers with whatever Google account they used — the office owns link discipline in that mode.
- **Google Cloud consent-screen trap (API mode only):** Testing-mode consent screens expire connections after 7 days and only allow listed test users. Publish the consent screen before term starts.
- **No date filtering in the API:** students see past classes of their section too (newest first). Housekeeping — deleting old classes from the panel lists — keeps the app list clean; nothing technical enforces it.
- **Parent Live Class flag:** enable it on both providers so parents also see live classes in the **web** portal. (The mobile API feed does not apply this flag — verified in the API model — but the web student/parent panel is governed by it.)
- **What cannot be determined from held sources:** whether the credentials inside staging's existing Gmeet row (if any are really there) are the school's own valid Google credentials — only step B2's test class answers that; the current installed **version behaviour on staging** after tonight's install (held code is an older build; the panel in front of the executor is the authority); and any addons' licence/renewal state in the owner's CodeCanyon account, which no held source covers.

---

## 6. Decision / inputs checklist — only the owner can supply these

- [ ] **School Zoom account** — which account (login) will host classes, and its plan (Basic vs paid) accepted against the 40-minute / single-host limits above.
- [ ] **Zoom OAuth app** (Phase A1): created in that account; Client ID + Client Secret in hand; all four redirect URLs whitelisted. *(Owner creates; owner/office pastes into the panels.)*
- [ ] **Mode decision — Zoom:** global (recommended) vs per-teacher API.
- [ ] **Mode decision — Gmeet:** manual first (recommended) vs Google Calendar API mode.
- [ ] **School Google account** — and, only for API mode, a **Google Cloud project** on it with Calendar API + OAuth client (Client ID/Secret) created and consent screen published.
- [ ] **Parent Live Class** = Yes on both providers (recommended).
- [ ] **Who creates classes day-to-day** (admin office vs teachers themselves) — decides whose browser does the Authenticate / Google-connect step and who needs the panel roles.
- [ ] **One staging test window** — a few minutes with the fixture child's section (Seven – Diamond) for Phases A5/B2.

---

## 7. One-paragraph summary

The addons are installed on both sites but **nothing is configured**: Zoom has no settings row on staging and blank key/secret on production (with the "please authenticate" banner showing); Gmeet is blank on production and carries an unproven, possibly stale settings row on staging; and no class has ever been scheduled. Zoom needs an **OAuth app** (Client ID/Secret — *not* Server-to-Server) created in the school's Zoom account, pasted into Zoom Live Classes → Setting by the owner, followed by an **Authenticate** sign-in — after which `getzoomsettings` returning a row, a test class for Seven–Diamond, and `liveclasses` returning it with a `join_url` prove the chain. Gmeet can start in credential-free **manual mode** (teacher pastes a Meet link) and be upgraded later to Calendar-API mode with a Google Cloud OAuth client. Staging proves every rung first; production then repeats it with settings saves done personally by the owner, ending with one real class per provider verified through the API and the Connect Live Classes screen (already in build in the wiring lane).
