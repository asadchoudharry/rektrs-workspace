# IQRS Design System v2 — "Calm Campus"

**Product:** IQRS Family App (Student & Parent) + IQRS Staff App — IQRA REHMANIA TUL ATFAL HIGH SCHOOL
**Motto:** Knowledge. Faith. Excellence.
**Version:** 2.0 · Design Lead specification for the engineering team · Status: ready to build from
**Rule zero:** This spec replaces the v1.x design entirely. Nothing visual carries over except the school crest artwork itself.

---

## 1. Design direction

Three directions were researched against what is winning on Behance/Dribbble and in top-grossing education products right now. One is chosen; the other two are documented so the decision is auditable.

### Direction A — "Heritage Editorial"
Crest-forward, ivory paper background, gold rules and serif headlines (Georgia), formal university-brochure language.

- *References:* traditional university brand sites; the school's own printed identity kit.
- *Strength:* unmistakably "IQRS", dignified.
- *Why rejected:* this is exactly the register the v1 attempt used, and it reads as **dated** on a phone. Serif + ivory + gold on small screens looks like a scanned prospectus, not an app. Parents compare us to WhatsApp and Facebook, not to brochures. Heritage survives in v2 only as an accent (see crest rules §2.7), never as the layout language.

### Direction B — "Playful Learning"
Duolingo / StudyStream-style: pastel tiles everywhere, chunky rounded shapes, streaks, mascots, celebration states.

- *References:* Duolingo (streak + progress-ring habit loops); StudyStream redesign, Behance 2025 (cleaner hierarchy, interactive stats, achievement tracking — https://www.behance.net/gallery/234712873/StudyStream-Study-Mobile-App-Design); StudySpark planner case study (warm greeting-led home, calm pastel system).
- *Strength:* joyful, proven engagement mechanics, great for young students.
- *Why rejected as the base:* IQRS serves ages ~5–16 plus their parents plus staff doing fee collection. Full-playful feels childish to a Class 10 parent and unprofessional in the Staff app; the previous pastel build was also rejected by the owner as generic — pastel tiles are now the visual cliché of every template school app on Dribbble. We **borrow its mechanics** (progress ring, week dots, warm greeting, encouraging microcopy) and discard its costume.

### Direction C — CHOSEN: "Calm Campus"
Consumer-grade restraint with a navy-and-gold spine. Think the calm of Facebook/Muse-grade product surfaces, the structure of Material 3 Expressive, and the warmth of ClassDojo's parent feed — executed in the school's own navy and gold.

- *References:*
  - **Material 3 Expressive** (Google, Aug 2025): expressive shapes (16–28dp radii), tonal surface layers instead of shadows, bento dashboards, shape-matched skeleton loading with 1.2s shimmer, feedback hierarchy (snackbar < banner < dialog). https://m3.material.io
  - **ClassDojo** (95% of US K-8 schools): teacher-first simplicity, a single warm feed of "what happened today", photo-led updates, plain-language parent communication. https://www.classdojo.com
  - **Seesaw**: portfolio warmth, one obvious action per screen, big friendly type for non-technical parents.
  - **Studyx LMS**, Behance Jan 2026 (modular dashboard, progress analytics as first-class cards): https://www.behance.net/gallery/242556385/Studyx-Learning-Management-System-%28LMS%29-UIUX
  - **VOYA student app**, Behance 2026 (modular layouts, personalisation inside a strict visual system): https://www.behance.net/gallery/256676977/AI-Powered-Student-Mobile-App-Design-Vrinsoft
  - **2026 mobile UX consensus** (GMI trend report; uidesignz best-practice review): "restraint, intelligence, empathy" — user-first over visual noise, accessibility built in from wireframes (WCAG 2.2), micro-interactions as *feedback*, not decoration; motion needs a budget.
- *Why it wins for IQRS:*
  1. **One system, two apps.** The same tokens/components serve a parent checking fees and a teacher marking 40 students — playful can't do the second, heritage can't do either on a phone.
  2. **Identity without costume.** Deep navy is our primary surface colour and gold is our single precious accent — the school is recognisable in one screenshot, yet the app looks like a 2026 product, not a uniform.
  3. **Data is the decoration.** Real numbers (attendance %, fee due, today's periods) in big confident type are what make award-level school dashboards look good — not gradients. v1 failed partly because screens were designed around placeholder chrome instead of the real payloads (§6.2).
  4. **Calm earns trust with money.** Fees are the most sensitive screen for parents; a calm, precise, bank-like presentation in navy/white outperforms cheerful tiles.

### Design principles (tie-breakers for every future decision)

1. **Today first.** Every home surface answers "what matters today?" in the first viewport — no scrolling to find the point of the app.
2. **One job per screen, one primary action.** If a screen has two equal CTAs, one is wrong.
3. **Plain words, human warmth.** We write like a good class teacher speaks to a parent — never like software ("§6.3 banned list").
4. **Big, forgiving targets.** Parents on budget Android phones, one-handed, outdoors: 48dp minimum, 56dp for primary actions.
5. **The crest is a signature, not wallpaper.** It appears at moments of trust (start, sign-in, about, receipts) at full quality — nowhere else.
6. **Status is invisible unless it changes what the user should do** (§3.13). This is the direct fix for the "LIVE/OFFLINE everywhere" complaint.

---

## 2. Design tokens

Implementation note: tokens are named semantically (`surface/primary`, `text/secondary`) so engineering maps them 1:1 to CSS variables / Flutter / React Native theme objects. Values below are the single source of truth.

### 2.1 Colour

Brand spine: **Deep Navy** (trust, the school's primary) + **Heritage Gold** (precious accent — used sparingly, ~5% of any screen). Backgrounds are warm paper, not the rejected lavender and not cold grey.

| Token | Hex | Use |
|---|---|---|
| `brand/navy-900` | `#081731` | Darkest navy — splash background, dark-mode surface-0 |
| `brand/navy-800` | `#10204D` | Primary brand navy — headers, primary buttons, nav active |
| `brand/navy-700` | `#002147` | Live-site navy — gradients pair with 800, links on light |
| `brand/navy-600` | `#1B3A6B` | Pressed state of primary buttons |
| `brand/navy-100` | `#DCE4F2` | Navy tint — selected rows, icon tiles |
| `brand/navy-50` | `#EDF1F8` | Subtle fills, skeleton base on navy |
| `brand/gold-500` | `#C9A227` | Heritage gold — primary accent: ring progress, key numbers, crest ring |
| `brand/gold-400` | `#D4AB42` | Light gold — highlights, gradient pair |
| `brand/gold-100` | `#F6ECD2` | Gold tint — "due soon" soft fills, award chips |
| `surface/bg` | `#FAF8F3` | App background (warm paper) |
| `surface/card` | `#FFFFFF` | Cards, sheets, rows |
| `surface/raised` | `#FFFFFF` + shadow S2 | Floating nav, menus |
| `surface/sunken` | `#F1EEE6` | Input fills, timetable grid lines area |
| `text/primary` | `#101828` | Headings, body (16.9:1 on card) |
| `text/secondary` | `#5B6472` | Captions, metadata (7.4:1 on card) |
| `text/on-navy` | `#FFFFFF` | Text on navy surfaces |
| `text/on-navy-soft` | `#C7D2E8` | Secondary text on navy |
| `line/divider` | `#E7E2D6` | Hairlines on paper bg |
| `line/card` | `#EDEAE2` | Card borders (cards are outlined-first, §2.5) |

Semantic (never used decoratively):

| Token | Hex | Meaning |
|---|---|---|
| `state/present` | `#1E9E6A` | Present, paid, success |
| `state/present-bg` | `#E3F4EC` | |
| `state/absent` | `#D64550` | Absent, overdue, destructive |
| `state/absent-bg` | `#FBEAEA` | |
| `state/leave` | `#D98E04` | Leave / late / due-soon (amber, darkened for contrast) |
| `state/leave-bg` | `#FBF0DA` | |
| `state/info` | `#2E6BE6` | Neutral information |
| `state/holiday` | `#7A5AE0` | Holiday / event (violet, used only in calendar contexts) |

Subject colour system (timetable, homework, results — always icon + colour + label, never colour alone):

| Subject group | Tint bg | Strong |
|---|---|---|
| English | `#E3F0FB` | `#1D6FB8` |
| Urdu | `#E7F6E9` | `#2E7D46` |
| Mathematics | `#FDEBD9` | `#C2620A` |
| Science | `#E6F4F1` | `#0E7C6B` |
| Islamiyat | `#EFE9FB` | `#6A4BC4` |
| Social Studies / Pakistan Studies | `#FBE7EF` | `#B83A6E` |
| Computer | `#E4E9FD` | `#3D4FB8` |
| Art / Other | `#F1EDE3` | `#7A6A3F` |

Dark mode (ship in v2; tokens defined now so engineering doesn't retrofit): bg `navy-900`, card `#12264F`, raised `#182F5E`, text `#F4F6FB` / secondary `#A9B7D4`, dividers `#22386A`, gold unchanged, semantic strong colours lightened one step (present `#3ECF8E`, absent `#FF7A85`, leave `#F2B544`). Paper warmth is a light-mode property; dark mode is "night navy" — it deepens brand identity instead of greying it.

### 2.2 Typography

Two free Google Fonts, chosen deliberately:

- **Plus Jakarta Sans** — display + headings + UI labels. Geometric, warm, contemporary; the face behind many current award-level fintech/education apps. Weights: 500 Medium, 600 SemiBold, 700 Bold, 800 ExtraBold.
- **Inter** — body text for long reading and **all tabular data** (fees, marks, dates) with `font-feature-settings: "tnum"` so numbers align in columns. Weights: 400, 500, 600.

Scale (sp; line-height in multiples):

| Style | Font | Size / LH | Weight | Use |
|---|---|---|---|---|
| `display` | Jakarta | 30 / 36 | 800 | Home greeting name, big numbers (attendance %, fee total) |
| `headline` | Jakarta | 24 / 30 | 700 | Screen titles (in collapsing app bar) |
| `title-lg` | Jakarta | 20 / 26 | 700 | Card titles, section heads |
| `title` | Jakarta | 17 / 23 | 600 | Row titles, list headers |
| `body-lg` | Inter | 16 / 24 | 400 | Notice body, paragraphs |
| `body` | Inter | 15 / 22 | 400 | Default text — **minimum body size app-wide** |
| `body-strong` | Inter | 15 / 22 | 600 | Emphasis inside rows |
| `caption` | Inter | 13 / 18 | 500 | Metadata, dates, "last updated" |
| `micro` | Jakarta | 11.5 / 15 | 700, +0.4 tracking, uppercase | Eyebrow labels ("TODAY", "TERM 2") — sparing |

Rules: never below 13sp for anything a parent must read; numbers in fees/marks are always Inter tnum; headings never use the motto's serif — Georgia is retired from product UI (it survives only inside the crest artwork itself).

### 2.3 Spacing & layout grid

- Base unit 4. Scale: 4, 8, 12, 16, 20, 24, 32, 40, 48.
- Screen padding: **20** sides (24 on ≥400dp wide). Bottom content padding: 32 + nav clearance.
- Card padding: 16 compact / 20 standard. Gap between cards: 12. Section gap: 24.
- Vertical rhythm: eyebrow → title → content stacked at 4/8/12; nothing arbitrary.

### 2.4 Radii (Material 3 Expressive shapes)

| Token | Value | Use |
|---|---|---|
| `radius/sm` | 10 | Small tiles, image thumbs |
| `radius/md` | 14 | Icon tiles, inputs |
| `radius/lg` | 20 | Cards (standard) |
| `radius/xl` | 24 | Hero cards, bento tiles |
| `radius/sheet` | 28 (top only) | Bottom sheets, dialogs 24 |
| `radius/full` | 999 | Buttons, chips, floating nav, ring buttons |

Buttons and the bottom nav are always full-pill — the single most recognisable "2026" shape cue, and the easiest for thumbs.

### 2.5 Elevation

Tonal first, shadow last (M3 Expressive doctrine). Cards: white on paper + 1dp `line/card` border, **no shadow** at rest.

| Token | Spec | Use |
|---|---|---|
| `shadow/S1` | 0 1px 2px rgba(16,32,77,.06), 0 1px 3px rgba(16,32,77,.05) | Sticky app bar on scroll |
| `shadow/S2` | 0 8px 24px rgba(16,32,77,.12) | Floating bottom nav, FAB |
| `shadow/S3` | 0 16px 40px rgba(16,32,77,.18) | Sheets, dialogs, menus |

### 2.6 Iconography

- Library: **Phosphor Icons** (free, MIT) — rounded 2px-stroke feel matches Jakarta's geometry; *Bold* weight for active nav states, *Regular* elsewhere; *Duotone* allowed only for empty-state spot icons. (Lucide is an acceptable substitute if engineering prefers; do not mix both.)
- Grid 24dp, stroke 1.8, corner radius consistent; icon tiles 40dp (48dp in grids) on tinted subject/semantic backgrounds.
- Core set is fixed and named in the component specs (home, calendar-check, wallet, clock/timetable, book/homework, megaphone/notice, chart/result, bus, library, user, qr, plus, search, chevron). No icon is ever invented per-screen.

### 2.7 Crest & brand artwork rules (the fix for "identity executed in a dated way")

- The crest appears **only** at: splash, sign-in, About, printed-style receipts (fee receipt header), and as a 28dp mark in the Home app bar. Nowhere else. Scarcity is what makes it feel premium.
- Always whole, never cropped, never stretched, never recoloured, never on a busy/photo background. Minimum clear space = height of the crest's crown band on all sides.
- On light surfaces: crest in its white circular badge with a **2dp gold ring** (`brand/gold-500`) — this is the one sanctioned treatment (fixes the v1 clipping bug by construction: fixed-size badge, aspect-locked).
- On the navy splash: crest sits in the same badge; motto beneath in Jakarta 600 letterspaced caps, ivory `#FAF7EF` — the only place the motto is displayed.


---

## 3. Component library

Every component lists anatomy, key metrics and states. Engineering builds these once; screens in §4 are compositions of them only — **no screen may invent a one-off component**.

### 3.1 App bar (collapsing)

- **Home variant:** height 64 + greeting block. Left: crest badge 28dp (Family) or staff avatar. Centre-left: greeting line. Right: notification bell with gold dot (only when unread), avatar/child-switcher.
- **Inner variant:** back chevron (48dp target), `headline` title that collapses to 17sp on scroll, optional trailing action (search, filter).
- On scroll >8dp: background becomes `surface/card` + shadow S1; before that it sits flat on `surface/bg`.
- Never contains: domain names, session text, connection text. (Banned — §6.3.)

### 3.2 Child switcher (Family app, parents with 2+ children)

- A pill under the app bar on Home and persistent in Profile: child photo/initial avatar 28dp + name + class, chevron. Tap → bottom sheet listing children (avatar, name, class, section), radio-selected.
- Switching animates content cross-fade (200ms) and re-scopes **every** tab. Single-child accounts never see it.
- Students logging in as themselves never see it.

### 3.3 Bottom navigation (both apps)

- **Floating pill bar**: inset 16dp sides, 12dp above bottom safe area, `surface/raised` + shadow S2, radius full, height 64. This floating treatment (iOS 26 / M3 Expressive idiom) is a deliberate step beyond the v1 fixed bar.
- 4 destinations per app (5th = "More" grid in Family). Item: icon 24 + label 11.5 Jakarta 700. Active: navy-800 filled pill behind icon+label (width animates 180ms), inactive: `text/secondary` icon only + label.
- Labels always visible (parents must not have to guess icons).
- Family: **Home · Attendance · Fees · More** (Homework/Timetable/Notices live one tap inside Home & More — research consensus: >5 tabs hurts discoverability, NN/g). Staff: **Home · Classes · Scan (centre, raised gold circle button) · Activity · More**.

### 3.4 Buttons

| Variant | Spec | Use |
|---|---|---|
| Primary | navy-800 bg, white text, pill, h 52 (56 on key parent flows), Jakarta 700 16 | The one main action per screen |
| Gold CTA | gold-500 bg, navy-900 text, pill, h 52 | Reserved: money actions only ("Pay fees" when online payment exists, "Collect fee" in Staff) — scarcity keeps it meaningful |
| Secondary | white bg, 1.5dp navy-100 border → text navy-800 | Alternate actions |
| Ghost | text-only navy-700, underline on press | Tertiary ("View all") |
| Destructive | absent-strong text on absent-bg | Reject/delete confirmations only, inside dialogs |
| FAB (Staff only) | 56dp gold circle, shadow S2, icon only | QR scan on Classes; "+" create on Homework/Notices lists |

States: pressed = scale .98 + colour one step darker; disabled = 40% opacity, no shadow; loading = label replaced by three-dot pulse (never a full-screen spinner for a button action).

### 3.5 Cards & bento tiles

- Standard card: `surface/card`, radius lg, padding 16/20, 1dp border, no shadow.
- **Bento dashboard tile**: radius xl; three sizes — Wide (full width, hero data), Half (2-col), Tall. Tiles carry ONE datum + one spark of context + tap-through. Tile icon top-left in 40dp tint tile; big number in Jakarta `display` or `title-lg`.
- Hero card (Home attendance): navy-800 background variant — white text, gold ring (see 3.8). Only one navy hero per screen; everything else stays light so it keeps its punch.

### 3.6 List rows

- Height 64 standard / 72 with subtitle. Left: 44dp avatar or icon tile (radius md). Title `title` 15–17, subtitle `caption` secondary. Right: meta (time/amount) + chevron 18 `text/secondary` 40%.
- Press state: bg `navy-50` wash. Dividers: inset hairlines (start after avatar), never edge-to-edge.
- Group headers: `micro` eyebrow + 8dp gap ("TODAY", "THIS WEEK", "EARLIER").

### 3.7 Chips

- Filter chips (Attendance months, Results terms, Fees status): pill, h 36, unselected = white + border; selected = navy-800 + white text; horizontal scroll row, 8dp gaps.
- Status chips (Present/Absent/Paid/Due): h 24, tint bg + strong text, 11.5 Jakarta 700, **always text** (never a bare coloured dot — colour-blind safety + clarity for parents).

### 3.8 Attendance ring (signature component)

- SVG ring, 112dp on Home hero (72dp compact in Attendance header), stroke 10, rounded caps, track = white 18% on navy (or navy-100 on light), progress = **gold-500**.
- Centre: percentage in Jakarta 800 28 (e.g. "86%"), beneath it `micro` "THIS TERM".
- Animates 0→value on first view, 900ms ease-out, once per session. Value comes from the real dashboard payload (`student_attendence_percentage`).
- Colour rule: ring stays gold at every value — no red/green shaming of a child's attendance; the *copy* carries nuance ("12 of 14 days this month" beneath the hero, outside the ring).

### 3.9 Week strip

- 7 day cells (Mon–Sun or as per school week), each 44×56 pill: day letter + date; state encoded three ways — fill tint (present/absent/leave/holiday semantic bg), a 16dp status glyph (✓ / ✕ / L / ★) under the date, and today = navy outline + bold. Tap a day → that day's periods/homework below.
- Used on Home ("This week") and Attendance. This replaces any calendar grid for the common case; full month calendar lives inside Attendance as a secondary view.

### 3.10 Fee summary (signature component)

- Card, white. Top row: "Fees" + term chip. Centre: **split bar** (h 10, radius full): paid portion `state/present`, remaining `gold-100` with gold edge — plus two figures in Inter tnum: **Paid Rs 5,000** / **Due Rs 4,500** (from the real payload: nested `student_due_fee[].fees[]` + `transport_fees`, totals from `grand_fee`).
- If due > 0: due date line in `caption` ("Due by 10 Nov") + Gold CTA "View fee details" (→ Fees screen; "Pay now" only when a gateway is actually configured — never a dead button).
- If fully paid: bar all-green, copy "All fees paid for this term. Thank you." + receipt row.
- Amounts always formatted `Rs 4,500` (thousands separators, no decimals).

### 3.11 Timetable

- Mobile pattern: **day pager**, not a shrunken grid. Top: week strip (3.9 variant, day names) or Mon–Sat segmented row. Body: vertical period list — time column (Inter tnum, 52dp), subject tile (subject tint, radius md), subject name `title`, teacher + room `caption`.
- **Now-line:** current period gets navy left border 3dp + "Now" chip; next period subtly raised. Breaks shown as slim dashed rows ("Break · 10:30–10:50").
- Data source is the real `result_list` payload (day / subject_name / staff_name / time_from / time_to) — the spec is written against it, not against an imagined grid.
- Empty day: holiday state (3.15) — "No classes — school holiday."

### 3.12 Homework & notice cards

- Homework row/card: subject tint tile + subject, task text 2 lines max (ellipsis, tap to expand in detail), due chip ("Due tomorrow" amber / "Due Mon" neutral / "Overdue" red — computed from dates, words not codes), teacher name caption.
- Notice card: megaphone icon tile (navy tint), title `title`, 2-line preview, date caption, unread = gold dot + title weight 700. Detail opens as a sheet/full screen with full text — notices are read, not "opened in browser".

### 3.13 Connectivity & status — the consumer way (READ CAREFULLY)

This is the component that fixes the owner's loudest complaint. Rules are absolute:

1. **No status pills. No "LIVE"/"OFFLINE" text anywhere. No domain names. No "Dashboard unavailable".** If engineering is tempted to render a system string, it goes through this section first.
2. **Content is cached by default.** When the phone is offline, screens show the last good data with a single quiet caption in `caption` style where freshness matters: *"Last updated today, 9:41 AM"* (Fees, Attendance, Timetable only). No banner, no colour change, no interruption. Parents in low-connectivity areas must feel the app simply works (WhatsApp/Facebook behaviour).
3. **Staff app pending-work bar** — the ONLY persistent connectivity element in either app, and only in Staff, only when the outbox is non-empty: a slim bar (40dp, `gold-100` bg, navy text) above the bottom nav: cloud-up icon + *"3 items waiting to send — they'll go on their own when you're back online."* + "View" (→ Waiting to Send screen). It is warm, factual, non-alarming; it disappears by itself when the queue drains.
4. **Reconnect toast:** after a successful background sync, a toast (3.14): *"You're back online — everything is up to date."* Once per reconnection, never stacked.
5. **Failed action** (user explicitly tapped something and it couldn't complete): inline message inside the affected card + Retry ghost button, in human words (§3.16 copy table). Never a global error screen for a partial failure.
6. Pull-to-refresh exists on every data screen and is the user's manual "try again" — with the standard spinner-in-strip treatment, no full-screen loaders after first load.

### 3.14 Toasts & snackbars

- Bottom-anchored above the floating nav, dark navy-900 pill, white text 14, h 48, radius full, auto-dismiss 3s (4s with an action like "Undo"). One at a time. Success check icon in gold.
- Per M3 feedback doctrine: snackbar = transient confirmation; banner = persistent actionable condition (only 3.13-3 qualifies); dialog = destructive/irreversible confirmations only.

### 3.15 Empty states

- Anatomy: 96dp spot illustration (single-weight navy line art + one gold accent; Phosphor Duotone acceptable), one warm headline (Jakarta 600 17), one sentence of guidance, optional single CTA.
- Copy is product copy, written per screen in §4 (e.g., Fees empty: "No fees due — you're all paid up." with a small celebration treatment). An empty state is a designed screen, never an accident and never the words "No data found".

### 3.16 Loading & error states

- **Skeletons, not spinners**, for all structured content (M3 doctrine: skeleton preserves the spatial model). Shape-matched grey blocks on `navy-50`/paper, shimmer sweep 1.2s, staggered fade-in of real content (150ms). First load of Home: skeleton of hero + 4 tiles. Lists: 6 skeleton rows.
- Full-screen spinner: only during sign-in and QR camera start.
- **Error copy table (the only approved strings):**

| Situation | Copy | Action |
|---|---|---|
| Load failed, has cache | (show cache + caption) "Couldn't refresh — showing the latest we have." | Pull to retry |
| Load failed, no cache | "We couldn't load this right now. Please check your connection and try again." | Retry button |
| Sign-in failed | "That username or password doesn't look right. Please try again." | — |
| Fee post rejected (Staff) | "This payment couldn't be recorded: [reason in plain words]. It has NOT been saved — you can fix it and send again." | Edit |
| Session expired | "For your security, please sign in again." | Sign in |

### 3.17 Bottom sheets & dialogs

- Sheets: radius 28 top, grabber 36×4, padding 20, max-height 90%, scrim navy-900 40%. Used for: child switcher, filters, fee detail breakdown, mark-attendance confirmations, more-actions.
- Dialogs: radius 24, title Jakarta 700 18, body Inter 15, actions right-aligned pills. Only for destructive or payment-confirming moments.

### 3.18 Search (Staff app)

- Search field: sunken fill, radius full, h 48, leading search icon, placeholder in human words ("Search by name or admission number"). Results as list rows (3.6) with avatar initials. Recent searches as chips. This powers student lookup for fee collection and QR fallback.

### 3.19 Avatars & photos

- Student photo where the system has one; otherwise initials on a per-student stable tint (from subject palette family). Photo/initial size 44 list / 72 profile / 96 profile hero. Staff avatars identical treatment. Never a generic grey silhouette.


---

## 4. Screen-by-screen specification

Wireframe notation: blocks are listed top→bottom; `[ ]` = component from §3; indented lines = content/hierarchy inside the block. Every screen lists its **states**. All screens: `surface/bg`, 20dp side padding, floating bottom nav (§3.3) except sheets/full-screen flows.

### 4.A FAMILY APP (Student & Parent — view-only)

**F0 · Splash** (≤1.2s, only while first data loads)
- Full `navy-900` field. Centred: crest badge 96dp (§2.7), school name Jakarta 800 22 ivory, motto letterspaced beneath.
- No progress text, no version strings. A thin gold indeterminate line (2dp) at the bottom is the only motion.
- *State:* if first load fails → crest stays, one line appears: "Please check your connection" + Retry pill. Never a raw error.

**F1 · Sign in**
- Paper bg. Top third: crest badge 72 + "Welcome to IQRS" `headline` + subline "Sign in with the same username and password you use on the school portal." (One human sentence — it teaches, since many parents' first login is here.)
- Card: Username field, Password field (eye toggle), Primary button "Sign in" h56. Below: ghost "Forgot password? Please contact the school office." (No self-serve reset exists in the system — the copy must be honest, not a dead link.)
- Segmented note, not a control: a quiet caption "Students and parents sign in here." (Staff have their own app — said once, here, and never repeated as chrome.)
- *States:* loading (button dot-pulse), error (§3.16 sign-in string, field borders absent-red 1.5dp + message above button), success → F2 with shared-element crest/avatar transition.

**F2 · Home (Dashboard)** — the most important screen in the product
- [App bar: crest mark + bell] [Child switcher pill if 2+ children]
- Greeting block: "Assalam-o-Alaikum," caption secondary → child name `display` — "Aika Sajid" — then caption "Class Four · Daffodils (Girls)".
- [Hero card — navy] Left: attendance ring (§3.8) with real %. Right column: "This month" — "12 of 14 days present" + mini week dots (5 dots, filled = present). Tap → F3.
- [Section: "Today"] Timetable preview card: next/current 3 periods as compact rows (time, subject tile, subject, teacher) + ghost "Full timetable" → F5. If school is over: "School day finished — see tomorrow" + tomorrow's first period.
- [Fee summary card §3.10] → F4.
- [Section: "Homework"] Up to 3 homework cards (§3.12) + "View all" → F6. Empty → one-line warm state inside the card: "No homework pending. Enjoy the evening." (Designed emptiness, not a hole.)
- [Section: "Notices"] Latest 2 notice cards → F7. Unread count chip on section head.
- [Bento row: Results tile (latest exam + %) · Transport tile (route + stop) · Library tile (books issued count)] → F8/F9/F10.
- *States:* first-load skeleton (hero + tiles shapes); offline → cached + "Last updated" caption under greeting (§3.13-2); per-card failure degrades that card only (inline retry), never the whole screen — **the v1 "whole Home is dead" failure mode is designed out here.**

**F3 · Attendance**
- Header card: ring 72dp + term % + three figures (Present / Absent / Leave counts, Inter tnum).
- [Week strip §3.9] then [Month calendar] — month grid where each date cell carries the status glyph + tint (same triple encoding as week strip); month switcher chevrons + filter chips (All / Absent / Leave) that list matching days below as rows (date, weekday, status chip, remark if any).
- Data: real records shape `{date, type}` — the design needs only date + status, which is exactly what exists. No screen may promise a reason field the API doesn't return; remarks show only when present.
- *States:* month with no records → empty state "No attendance recorded for this month yet."; loading skeleton rows.

**F4 · Fees**
- [Fee summary card §3.10 expanded] — term selector chips (Term 1/2/3 or month chips per school practice).
- Breakdown list: each fee head as a row — name, amount Inter tnum; transport fees shown as their own group (payload keeps them separate — the UI mirrors the real structure, §6.2). Discount row when present (green, "− Rs …").
- History section: paid instalments as rows (date, amount, receipt icon) → tap opens **receipt sheet**: crest header, school name, receipt no., lines, total, "Paid" stamp chip — designed to be screenshotted/shared to WhatsApp, which is how parents actually use receipts.
- Due items: due-date caption + amount strong; overdue gets absent tint on the *amount only*, copy stays factual ("Due since 10 Nov"), never threatening.
- *States:* all-paid celebration empty state; no-fees empty state ("No fees have been issued for this term yet."); offline → cached + last-updated caption.

**F5 · Timetable**
- Day pager per §3.11 with week segmented control (Mon…Sat). Swipe between days (page transition 220ms) + tap.
- *States:* holiday empty ("No classes today — school holiday." with holiday violet accent); weekend same pattern; skeleton period rows on load.

**F6 · Homework**
- Grouped list (§3.6 headers): "Due today", "This week", "Earlier". Cards per §3.12; tap → detail screen: full task text, subject header band (subject tint), due date, teacher, and any attachment row if the payload carries one.
- Filter chips by subject (horizontal scroll).
- *States:* empty → "No homework right now." + illustration; this is a *good-news* empty state, styled warm, not grey.

**F7 · Notices**
- List of notice cards (§3.12), newest first, unread gold dot; tap → detail: title `headline`, date, full body `body-lg`, issuer line ("School Office" / teacher name).
- *States:* empty → "No notices yet. We'll put school announcements here."; pull-to-refresh.

**F8 · Exams & Results**
- Term chips. Summary card: overall % (Jakarta display) + grade chip + a simple subject bar list (subject, mark, thin bar in subject strong colour, Inter tnum marks) — bars, not charts-with-axes; parents read bars instantly.
- Exam schedule section (upcoming): rows date + subject + time.
- Report detail: full marks table (subject / obtained / total / grade) in Inter tnum with hairline rows; "Position" shows only if the system returns it (never fabricated).
- *States:* results-not-published empty: "Results for this term aren't published yet." — a normal, expected state styled as information, not error.

**F9 · Transport**
- Route card: route name/number, bus stop, pickup + drop times (Inter tnum), driver/attendant name if the system provides it. Simple vertical day-independent layout; a static route-stop list (stops as timeline rows, child's stop highlighted navy).
- *States:* not-enrolled → "Your child isn't using school transport." information state.

**F10 · Library**
- Issued books rows: book title `title`, author caption, due-date chip (amber when ≤2 days, red when overdue). History section below (returned books, muted).
- *States:* none issued → "No books issued right now."

**F11 · Profile**
- Hero: photo/initials 96, name `headline`, class + section, admission no. (Inter tnum) — the identity card parents show at the school gate; give it a subtle navy gradient header band with gold rule (the one decorative flourish allowed).
- Detail rows (label caption / value body-strong): date of birth, gender, blood group (only fields the real profile payload returns — `student_result` — §6.2), parent/guardian names + phone (tap-to-call), address.
- Parent view adds: "My children" list (switch). Both views: Settings rows (Notifications on/off, About school → crest + motto + contact, Sign out in absent colour inside a confirm dialog).
- *No* edit controls — view-only honesty; caption under details: "To change any detail, please contact the school office."

**F12 · More (modules grid)**
- 2-column grid of large tiles (icon tile 48 + label) for everything not in the tab bar: Homework, Timetable, Notices, Results, Transport, Library, Profile. This replaces the v1 "54-module catalogue" — **parents get the 10 things the Family app actually does, presented as a clean grid; the full web-app module list never appears in the app.**

### 4.B STAFF APP (Staff / Admin — work tool + offline queue)

Design shift: same tokens, denser rhythm (card padding 16, row height 60), efficiency over delight — a teacher marks a class of 40 between periods. Delight is spent on speed: fewer taps, sticky actions, generous undo.

**S0 · Splash / S1 · Sign in** — as F0/F1 with staff copy: "Sign in with your staff email and password." Sub-caption: none about students (different app, no cross-talk). Error copy identical table.

**S2 · Staff Home (Dashboard)**
- App bar: staff avatar + name + role caption ("Teacher · Class Eight In-charge" when the dashboard payload provides it).
- [Pending-work bar §3.13-3 — only when queue non-empty]
- Today card (navy hero, lighter use than Family): today's date, classes scheduled today as compact rows (class, section, period, room) from the staff dashboard payload; each row's trailing action "Mark" → S4.
- Bento stats row: "Attendance today" (% of classes marked), "My classes" count, "Homework given" count — only figures the dashboard endpoint actually returns (§6.2 rule).
- Quick actions row (4 icon buttons): Mark attendance · Scan QR · New homework · New notice.
- Recent activity list: latest own actions (attendance marked, notice posted…) as rows with time captions — builds trust in the sync system without ever saying "sync".

**S3 · Classes**
- List of my classes: rows (class + section, student count, today's status chip: "Marked" green / "Not marked" amber). Tap → S4.
- FAB: gold QR button (bottom-right, above nav) → S5. Also a "Scan" centre nav action (§3.3).

**S4 · Mark attendance** (the highest-frequency screen in the Staff app — optimise ruthlessly)
- Header: class + date (date stepper ‹ Today ›), count summary right ("38 present · 2 absent" live-updating, Inter tnum).
- Sticky top actions: "Mark all present" secondary pill + search field (jump to a name).
- Student rows (h 60): roll no. (Inter tnum, 32dp), avatar/initials, name; right side: **segmented P / A / L control** (three 44dp segments; selected = semantic fill + white letter; default = Present pre-selected for speed, since most students are present — deliberate senior decision, with one-tap change per row).
- Sticky bottom action bar (above nav): summary + Primary "Save attendance" h52. After save: toast "Attendance saved for Class Eight — 40 students." (If offline: toast "Saved on this phone — it will send automatically when you're back online." + pending bar appears. Same control, honest wording, zero jargon.)
- Undo: 5-second undo in the toast for an accidental save.
- *States:* already-marked class opens in edit mode with an "Edited" caption; empty class list state.

**S5 · QR attendance**
- Full-screen camera viewfinder: rounded-corner frame guide (gold corners), torch toggle, school crest watermark small at top.
- On scan: instant haptic + student card slides up (photo, name, class) with Present marked and a 1.2s auto-dismiss; rapid consecutive scanning supported (class sets). Duplicate scan of the same student: card shows "Already marked present" in amber — not an error buzz of failure.
- Fallback row under the viewfinder: "Can't scan? Type admission number" → S3.18 search → tap student → marked.
- Works fully offline (writes to the same queue); pending bar reflects count on exit.

**S6 · Homework**
- List (mine): cards with class + subject + due chip + "sent/waiting" caption only when queued (worded as §3.13).
- Create (FAB +): form in a sheet-flow — Class (picker), Subject (picker of *configured* subjects only), Due date (date chips: Tomorrow / Next class / pick date), Task (multiline), Primary "Save homework". Offline → same save copy pattern as S4.
- Validation in plain words ("Please write the homework task") inline under fields.

**S7 · Notices**
- List (mine + school): cards §3.12 with audience caption ("Students & parents", "Staff").
- Compose (FAB +): Title, Message, Audience segmented (Students & Parents / Staff / Everyone), Primary "Post notice". Confirm dialog summarises audience before posting (notices are broadcast — one careful moment is worth it).

**S8 · Fee collection**
- Step 1: search (§3.18) → student row tap → Step 2: student header card (photo, name, class) + open invoices as selectable rows (invoice no., total, paid so far, balance — Inter tnum) → Step 3: amount field (prefilled with balance, editable), payment method segmented (Cash / Bank / Other as the office uses), Primary gold "Collect Rs X".
- Confirm sheet: student, invoice, amount, method + "Collect" — then **success screen**: big gold check ring animation, amount, receipt number, "Share receipt" (system share sheet — WhatsApp) + "Collect another".
- Offline: the whole flow works; success copy becomes "Recorded on this phone — the receipt will reach the school system when you're back online." and the item joins the queue. Idempotency is invisible by design (the same transaction can never post twice — engineering guarantee, never explained to the user).
- Rejected-by-system items (e.g., invoice settled meanwhile): the Waiting screen (S9) shows them with the §3.16 plain-words reason + Edit/Discard.

**S9 · Waiting to send (the outbox, humanised)**
- Reached from the pending bar or More. Title "Waiting to send". Explainer line, warm and short: "These are saved safely on this phone. They'll send on their own when the internet is back — you don't need to do anything."
- Rows per item: type icon (attendance/homework/notice/fee), one-line summary ("Attendance — Class Eight, 40 students"), time saved caption. Items needing attention are grouped first under "Needs your attention" with the plain-words reason + Edit / Discard (discard behind confirm dialog).
- When empty: success empty state "Everything has reached the school. You're all caught up."
- **The words "outbox", "queue", "sync", "pending sync" never appear.** (§6.3)

**S10 · Students (lookup)**
- Search (§3.18) + class filter chips → rows → read-only student mini-profile sheet (class, guardian phone tap-to-call). Lookup only; no editing.

**S11 · Staff profile & settings**
- Avatar, name, role, staff ID; rows: My classes, Notifications toggle, About (crest + motto), Sign out. If the session has expired: §3.16 session copy → S1, with queued work **preserved** and a caption after re-login: "Your waiting items are still here." (Trust-critical detail.)


---

## 5. Motion, micro-interactions & accessibility

### 5.1 Motion system (a budget, not a garnish)

2026 consensus (GMI; M3 Expressive): motion exists to confirm action and preserve spatial continuity — anything else is cut.

| Interaction | Spec |
|---|---|
| Screen push/pop | 240ms, ease-out cubic; shared-element on avatar → Profile hero |
| Tab switch | Content cross-fade + slide 8dp, 180ms; nav pill indicator slides (spring, damping .8) |
| Sheet present/dismiss | 280ms spring; grabber drag follows finger 1:1 |
| Attendance ring | 900ms ease-out count + sweep, once per session, only when on screen |
| Numbers (fees, %) | Count-up 600ms on first view only |
| Save success (Staff) | Check-ring draw 350ms + light haptic; fee success adds the gold ring (§S8) |
| Pull-to-refresh | Standard; content fades in staggered 40ms per card, no bounce |
| Skeleton shimmer | 1.2s linear sweep (§3.16), stops the moment content lands |
| Button press | Scale .98, 100ms — everywhere, consistent |
| QR scan success | Card slide-up 200ms + haptic tick; auto-dismiss 1.2s |

Forbidden: parallax, looping decorative animation, animated gradients, splash theatrics beyond F0, transitions >300ms.

### 5.2 Haptics (Staff-heavy, subtle)

Light tick: segmented P/A/L change, chip select, QR scan success. Medium: fee collected, attendance saved. Error buzz: **never** for user mistakes — only for a genuinely failed scan read. Family app: haptics only on primary button success states. All haptics off when the OS silent/accessibility settings say so.

### 5.3 Accessibility (WCAG 2.2 AA — designed in, not audited in later)

- **Targets:** ≥48dp everything; 56dp primary CTAs; P/A/L segments 44dp wide × 48 high (dense screen exception, still above the 44 floor).
- **Contrast:** all text ≥4.5:1 on its surface (tokens in §2.1 were chosen to pass: navy-800 on white ≈ 13.5:1; gold-500 is **never** used for text on white — gold text only on navy, or navy-900 text on gold fills).
- **Type scaling:** layouts must survive 135% system font size without truncation of amounts or names (rows grow; fee figures never shrink below 15sp).
- **Never colour alone:** attendance, fees and results always pair colour with a glyph or word (✓/✕/L, "Paid", "Due") — colour-blind safe and literacy-friendly.
- **Screen readers:** every icon button labelled in human words ("Mark all present", "Scan QR code"); ring announces "Attendance 86 percent this term"; images/crest marked decorative where redundant.
- **Reduced motion:** OS `reduce motion` disables ring animation, count-ups and shimmer (static placeholders), keeps fades ≤150ms.
- **One-handed use:** primary actions live in the bottom third; the floating nav and sticky action bars are thumb-reachable on 6.7" screens.
- **Language:** English UI, but sentence case, short sentences, no idioms — written for parents whose first language is Urdu even though the text is English.

---

## 6. How this spec fixes the owner's complaints — point by point

### 6.1 "Design is not enjoyable / not like Facebook, Muse, university apps"

| Root cause in v1 | v2 fix |
|---|---|
| A borrowed pastel template look — generic, "every school app on Dribbble" | Named direction **Calm Campus** (§1-C): consumer-grade restraint, M3 Expressive shapes (pill buttons, floating pill nav, 20–28dp radii), bento dashboards — the visual grammar of current award-level products (Studyx, VOYA, StudyStream references) |
| Identity pasted on as decoration (crest everywhere, dated kit colours dominating layouts) | Identity as a **spine**: navy primary + gold precious-accent system (§2.1), crest restricted to trust moments in one fixed badge treatment (§2.7) — recognisable in one screenshot, costume nowhere |
| No typographic confidence — small grey text, placeholder energy | Jakarta/Inter pairing (§2.2), big real numbers as the visual hero (attendance %, fee totals), minimum 15sp body for parents |
| Screens built around chrome instead of content | Principle 1 "Today first" + §4 layouts: Home's first viewport is greeting → attendance hero → today's classes → fees due. Nothing decorative precedes data |
| Staff side was an afterthought panel bolted onto a bundle | Staff app is a first-class citizen here (§4.B) with its own density rules and its highest-frequency screen (S4) optimised tap-by-tap |

### 6.2 "No data is coming" — screens designed against the REAL payloads

v1's fatal flaw was transforms written against imagined API shapes. This spec is written against the verified production payloads, and engineering must build to this table:

| Screen | Real data source (verified) | Design consequence |
|---|---|---|
| Home hero | dashboard → flat object incl. `student_attendence_percentage` | Ring % is real; month counts labelled as counts only when returned |
| Fees | **nested** `{ student_due_fee: [ { fees: [...] } ], transport_fees: [...], grand_fee: {...} }` | Fee card flattens groups in UI exactly as §3.10/§F4; transport kept as its own group because the payload does |
| Profile | `{ student_result: {...} }` | Profile shows only fields inside `student_result` — no invented fields (§F11) |
| Timetable | `{ result_list: [...] }` (day, subject_name, staff_name, time_from/to) | Day-pager of period rows (§3.11) — not a calendar grid the payload can't fill |
| Attendance | `{ data: [ {date, type} ] }` | Calendar needs only date+status (§F3); remarks optional |
| Notices | notifications endpoint | Title/date/body only — no fake categories |
| Staff home, homework, notices, fees, QR | Staff extension endpoints (login, dashboard, sync writes) — all live | Staff screens promise exactly what those endpoints return; the offline queue is a client concern surfaced only via §3.13-3/S9 |

Plus the structural rule from §F2: **per-card failure isolation** — one failing module degrades its own card with an inline retry; it can never again blank the whole Home screen behind a "Dashboard unavailable" message (a string that is now banned, §6.3).

### 6.3 "Everywhere just LIVE / OFFLINE and development notices" — the language lockdown

**Banned strings (must not appear in any build, any state):** LIVE · OFFLINE · "Dashboard unavailable" · "Live data unavailable" · iqrs.edu.pk or any domain/URL as visible text · "API" · "sync" / "outbox" / "queue" as user-facing words · "session expired (401)" and any status code · "STAFF SYNC" · module names copied from the web admin panel.

**Replacement doctrine (§3.13):** cached data + a quiet "Last updated" caption where freshness matters; one warm pending-work bar in Staff only; one toast on reconnect; error copy only from the §3.16 table. Connectivity becomes something the app *handles*, not something it *announces* — the WhatsApp/Facebook behaviour the owner asked for.

**Copy voice (all screens):** written like the school speaking kindly to a parent — "Assalam-o-Alaikum", "All fees paid for this term. Thank you.", "Saved on this phone — it will send on its own when you're back online." Every string in §4 was written to this voice; new strings must match it or be reviewed against it.

### 6.4 What engineering receives as "done" criteria for design

1. Tokens in §2 implemented as a single theme source — no hard-coded hex/sp outside it.
2. Components in §3 built once with all listed states (incl. skeleton, empty, error, offline-cache).
3. Screens in §4 composed only from §3 components; any missing component returns to design, not improvisation.
4. §6.3 banned-string list wired as a lint/review checklist item on every build.
5. Accessibility §5.3 verified at 135% type + TalkBack pass on Home, Fees, Mark Attendance before release.

*End of spec — Design Lead, v2.0.*
