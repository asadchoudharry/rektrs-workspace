# BigBlueButton — Feasibility Study for Live Online Classes
## Rektrs School ERP + LMS · Study-only (no installs, no code reuse) · 2026-11-28

> **LICENCE NOTE (read first).** BigBlueButton is licensed **LGPL-3.0**. What that means for our use, stated precisely and without legal overclaiming:
> - **Running BBB unmodified as a separate service and calling it over its HTTP API from our own (proprietary) code is the project's intended integration mode** and does not, by itself, make our ERP code a derivative work of BBB — the LGPL's copyleft attaches to the LGPL-covered work and derivatives of it, not to independent programs that merely communicate with it at arm's length. This is how the entire LMS ecosystem integrates BBB (Moodle ships it as a core activity; commercial LMSs do the same).
> - **If we modify BBB itself**, the LGPL obligations attach to *those modifications* when we *convey* (distribute) the modified software: source for the modified BBB parts must be offered under LGPL terms, licence notices preserved, no extra restrictions imposed on recipients' LGPL rights.
> - **LGPL-3.0 has no network-use (AGPL-style) clause.** Merely running BBB — even modified — as a hosted service that users reach over the network is not, under the LGPL alone, a "conveyance" that triggers source disclosure. (This is a summary of the licence's widely understood mechanics, not legal advice; a lawyer should confirm before any commercial launch that depends on the edge cases.)
> - **One adjacent trap:** **Scalelite**, the standard BBB load balancer for multi-server pools, is **AGPL-3.0**, not LGPL. AGPL *does* have a network clause. Any future SaaS pool design that touches Scalelite needs its own licence review — it is not covered by this note.

---

## 1. What BigBlueButton is

BigBlueButton (BBB) is an open-source **virtual classroom** — not a generic meeting tool. It is built specifically for teaching, and it shows in the feature set:

- **Live class core:** multi-user video/audio (WebRTC), screen sharing, presentation upload (slides become the canvas), public/private chat, shared notes, live closed captioning / transcription features.
- **Teaching tools:** **multi-user whiteboard** with annotation on slides, **polls** (incl. anonymous polls and smart slides), **breakout rooms** (with capture of slides/notes back into the main room), raise-hand / emoji reactions, multi-user whiteboard cursor controls.
- **Recordings + playback:** sessions can be recorded; recordings are post-processed into a browser playback format (slides + audio + webcams + chat synchronised), with `getRecordings` API access, publish/unpublish/delete, and MP4 export paths (~150 MB/hour at 720p per BBB's own help docs).
- **Learning Analytics Dashboard (LAD):** a live, moderator-only dashboard (in-product since 2.4, still current in 4.0) showing per-student join time, attendance duration, talk time, webcam time, chat/emoji/raise-hand counts, **poll responses**, and a per-student **activity score**, with CSV download. This is the piece Zoom/Meet do not give a school system for free.
- **Maturity / version state (verified 2026-11-28):** **4.0.0 released 14 Oct 2026; latest 4.0.4 on 24 Nov 2026.** The **3.0 line remains supported** (3.0.42, also 24 Nov 2026). The project is actively maintained (26 releases in the last 12 months across lines), is the default virtual classroom across the LMS world (Moodle core integration since Moodle 4.0; Canvas, Sakai, D2L, Schoology etc.), and BBB 4.0 moved the media stack onto a LiveKit-based bridge. This is mature, production-proven software — feasibility risk is **not** in the product.

## 2. Integration shape

### 2.1 The BBB API (what we'd actually call)

BBB exposes a small, stable, checksum-signed HTTPS API at `/bigbluebutton/api` (shared secret, SHA checksums, XML responses — unchanged in shape for a decade):

| Need | API surface |
|---|---|
| Create a class | `create` (name, meetingID, moderator/attendee passwords, `record`, `maxParticipants`, `logoutURL`, meta fields for course/class/tenant tagging) |
| Join | `join` (fullName, meetingID, password → role; redirect into the HTML5 client) |
| End / monitor | `end`, `isMeetingRunning`, `getMeetings`, `getMeetingInfo` |
| Recordings | `getRecordings` (filter by meetingID/meta, paginated), `publishRecordings`, `deleteRecordings`, `updateRecordings`, caption-track upload |
| Live events back to us | **Webhooks** (separate `bbb-webhooks` app on the BBB server): meeting created/ended, user joined/left, recording processing started/finished — POSTed to our callback URL; plus the `meetingEndedURL` callback on `create` |
| Alternative door | **LTI 1.3** — BBB can act as an LTI tool, if a surface prefers launch-based integration over raw API |

### 2.2 How Moodle does it (the reference integration)

Moodle has shipped BBB as a **core activity since Moodle 4.0** (Blindside Networks' plugin before that). The whole integration is: admin enters **server URL + shared secret** once → teacher adds a "BigBlueButton" activity to a course → the plugin calls `create` with the course context, `join` with teacher=moderator / student=viewer, restricts students until a teacher joins, lists recordings back inside the course, and can end classes from the LMS. **No BBB code lives inside Moodle.** That is exactly the shape available to us.

### 2.3 What it would concretely take in Rektrs School ERP + LMS

Our gap audit (`REKTRS-SCHOOL-ERP-GAP-AUDIT-2026-11-23.md`) already places this: **LMS live-class is PARTIAL** — "Online Course/Gmeet/Zoom → LMS + add-on mappings, providers unbound (P)", and completion block **F (Provider & device bindings)** budgets 2–3 weeks for *all* providers (payments, SMS/WhatsApp/email, Zoom/Meet, push, storage). BBB slots into that same seam as **one more provider adapter**, not a new subsystem:

1. **Provider config (per tenant):** BBB server URL + shared secret, stored like every other provider credential (selection/config pattern, never free-typed secrets in odd places). One shared Rektrs-run BBB service *or* a tenant's own server — config supports both.
2. **Live-class adapter (~the create/join/end trio):** from the LMS course / timetable surface — schedule a class → `create` with meta = {tenant, course, class, session}; teacher joins as moderator, students as viewers; "students wait until teacher joins" is a native BBB/plugin pattern.
3. **Webhooks receiver:** meeting-ended + user-joined/left events → **attendance evidence** for the class session; recording-ready event → recording appears in the LMS course's recording list via `getRecordings`.
4. **Recording lifecycle:** retention setting per tenant (days), `deleteRecordings` job, storage accounting (see §3 — this is an ops feature, not a nicety).
5. **What we should NOT build:** LAD import (the dashboard lives inside BBB; teachers open it there — pulling its CSV/API data into our analytics is a later luxury), breakout-room management UI (native to BBB), any whiteboard/poll code (all native).

**Effort estimate:** the adapter + webhooks + recording list/retention ≈ **1–1.5 weeks of lane work** inside the existing provider-binding block — *excluding* infrastructure (§3), which is the real cost. For comparison, the incumbent approach costs zero build: IQRS's Smart School system already keeps **Gmeet/Zoom add-ons as KEEP-OURS** (2026-11-17 disposition) — link-out classes where the teacher pastes/creates a Meet/Zoom link and the system just carries it. That approach has no recordings-in-system, no attendance evidence, and a 40-minute cut on free Zoom — but it also has **no server, no bandwidth bill, and nothing to operate**.

## 3. Server reality — the honest costs

This is where BBB stops being a feature and becomes an infrastructure commitment.

### 3.1 BBB's own requirements (official install docs, 4.0 line)

- A **clean, dedicated** server — "won't be used for anything else besides BigBlueButton"; ports **80/443 must not be held by another web server or reverse proxy**; Ubuntu 24.04 (4.0) / 22.04 (3.0); Docker.
- **16 GB RAM** (swap enabled), **8 CPU cores with high single-thread performance**; on cloud VMs the docs explicitly recommend **dedicated-CPU** instance types (AWS c5a.2xlarge-class named).
- **500 GB free disk with recordings enabled** (50 GB if recording is disabled).
- **250 Mbit/s symmetrical bandwidth minimum**; the official FAQ **recommends 1 Gbit/s in both directions** and warns 100 Mbit/s "will only lead to audio and video issues."
- UDP 16384–32768 open + built-in TURN (UDP/TCP 3478); public hostname + TLS; IPv4 (IPv6 recommended).

### 3.2 Capacity and per-user bandwidth (official FAQ)

- **Rule of thumb: one minimum-spec server ≈ 200 simultaneous users** (e.g. 3 sessions × 50, 6 × 25); a single session should stay ≤ ~200. Scaling beyond that = a **pool of servers behind Scalelite** (Scalelite's own docs recommend ≥ 3 nodes).
- **Per student:** ≥ **0.5 Mbit/s up / 1 Mbit/s down** recommended. Webcam ≈ 0.25 Mbit/s per stream at default resolution; voice ≈ 0.04 Mbit/s each way. Server-side fan-out is the killer: one teacher webcam to 50 students ≈ 12.5 Mbit/s out; if many students turn cameras on, outbound multiplies by viewers — which is why the bandwidth floor is what it is.
- **Why it doesn't share a small VPS happily:** WebRTC media is real-time CPU + bandwidth work — every stream is received, mixed/forwarded and re-sent continuously; burstable/shared vCPU (the kind small VPSs sell) stalls under sustained media load and audio degrades first; and **recording post-processing** (a 1-hour class can take 30–120 min of CPU to process) runs on the same box and competes with live classes. BBB's "dedicated, high single-thread, dedicated-CPU" language is the project telling you this directly.

### 3.3 Recording storage growth

- Official FAQ (older 0.81-era measurements): ~122 MB/h (audio) to ~309 MB/h (audio + desktop share) total archive+publish. Modern operator data: **~150 MB median per 1-hour class playback; ~200–800 MB/h all-in** depending on formats/cameras; raw capture is 2–5× the published size during processing.
- **Worked example:** a school running a modest online programme — 20 recorded class-hours/day — generates roughly **4–16 GB/day**, i.e. the 500 GB disk is full in **~1–4 months** without a retention policy and offloading (S3/NFS). Recordings are therefore a *managed lifecycle* (retention days, deletion jobs, storage accounting), not a checkbox.

### 3.4 Against our actual fleet (MEMORY.md)

| Machine | Known size | BBB verdict |
|---|---|---|
| Oracle **offbox-1** | 2 OCPU / 12 GB / 100 GB | **Below minimum on every axis** (needs 8 cores / 16 GB / 500 GB) |
| Oracle **micro-1 / micro-2** | 1 OCPU / 1 GB each | Not candidates at all |
| Oracle A1 free allowance (total) | 2 OCPU / 12 GB across the tenancy | The *entire free fleet combined* is smaller than one minimum BBB server |
| Operqon VPS (Hostinger, srv2107420) | Size not on record in MEMORY | **Disqualified by role regardless of size:** it is a shared production host (Operqon + Dokploy/Postiz workloads) whose 80/443 are already owned by its reverse proxy — BBB demands a clean dedicated box with exclusive 80/443 |

**Conclusion: no current machine can carry BBB. Any BBB path starts with new dedicated infrastructure** — a bare-metal-class server or a dedicated-CPU cloud instance (c5a.2xlarge-class or better), with 250 Mbit/s–1 Gbit/s symmetric bandwidth.

### 3.5 One school vs multi-tenant SaaS

- **One school (e.g. IQRS, 1,684 students):** one dedicated server covers ~200 *concurrent* users. Real school use is timetable-staggered, so one node is a plausible fit for an online *programme*; a whole-school simultaneous closure day (all classes live at once) would exceed one node and need either staggering by design or a second node.
- **Multi-tenant SaaS:** BBB has **no tenant concept** — isolation is by meetingID + metadata discipline on a shared pool behind one shared secret. A SaaS offer means: a Scalelite pool (≥3 dedicated nodes, AGPL review for Scalelite), shared TURN, per-tenant recording storage accounting and retention enforcement, bandwidth as the dominant recurring cost, and an ops duty (BBB upgrades are full-server affairs). **That is a new infrastructure product line, not a feature toggle** — priced into any tenant plan that includes it, or not offered.

## 4. The need question — an IQRS-like Pakistani school

**When live online classes actually get used** at a school like IQRS (Rahim Yar Khan, Punjab): closure days (Punjab's recurring smog/heat/flood closures are the standing example), evening academy / extra classes, board-exam revision weeks, and teacher-absence cover. It is **episodic, surge-shaped demand** — not a daily timetable load — unless the school deliberately runs an online programme.

**What schools use today:** Zoom (free, 40-minute cut), Google Meet links, and — for most real communication — **WhatsApp** (voice notes, video calls, recorded lessons shared as files) plus YouTube recordings. Zero cost, already installed on every parent's phone, teachers already know them.

**Student-side reality:** BBB's floor is a sustained ~0.5/1 Mbit/s and a modern browser. On a shared family Android phone over prepaid 4G, an hour of live class consumes on the order of **300–700 MB of mobile data** (audio+slides at the low end, cameras on at the high end) — a real, recurring expense for the families least able to pay it, and the first thing to fail in weak-signal areas. Zoom/Meet mobile apps are more forgiving at low bandwidth and are already on the devices.

**BBB's genuine edges** — whiteboard/polls/breakouts built for teaching, recordings landing inside the LMS, live attendance/engagement analytics (LAD), no 40-minute cut, class data on the school's own server — only convert into value **if the school runs live classes often enough for recordings, attendance evidence and analytics to matter**. For occasional closure-day cover, the link-out add-ons the school system already has deliver 90% of the practical value at 0% of the infrastructure cost.

**Honest verdict on need:** BBB is a *real product for a real job* — but for an IQRS-like school today it is **a solution to a programme the school has not started**. As a SaaS feature it is a *credible differentiator later* ("live classes + recordings + attendance inside your school system") — and a distraction if built before any tenant is asking for it, because its cost is standing infrastructure and ops, not code.

---

## VERDICTS

### (i) IQRS itself — **NO-GO** (for now)
Do not stand up BBB for IQRS. The school has no scheduled online-teaching programme; episodic closure/evening use is already covered by the KEEP-OURS Gmeet/Zoom link-out add-ons at zero infrastructure cost, and BBB would require a new dedicated server + bandwidth + recording ops for surge-shaped demand.
**Trigger that changes it:** the school starts a *scheduled* online programme (evening academy, a term of planned closure teaching, or paid online classes) where in-system recordings and attendance evidence are explicitly wanted — then pilot BBB for one term on a rented dedicated server, one node, recordings with a 30–60-day retention, and judge by actual usage.

### (ii) Rektrs School ERP + LMS (SaaS roadmap) — **WATCHLIST**
Do not build it into the pilot. **Do** keep the provider-adapter seam from the gap audit's block F shaped so BBB can slot in as one live-class provider beside Zoom/Meet link-out (the adapter work is only ~1–1.5 weeks when triggered). The standing cost is infrastructure, so BBB belongs behind a paid plan tier, never in the base product.
**Triggers that change it (any one):** (a) a signed/paying tenant whose requirements name integrated live classes with recordings; (b) two or more pilot/prospect schools independently asking for it; (c) a decision to sell an "online academy" tier — at which point evaluate **hosted BBB providers first** (per-concurrent-user pricing, zero infra) before self-hosting a Scalelite pool, and run the separate AGPL review Scalelite requires.

---

### Sources
- BBB official install docs (requirements, dedicated server, dedicated-CPU guidance): https://docs.bigbluebutton.org/administration/install/
- BBB official API reference (create/join/end, recordings, callbacks): https://docs.bigbluebutton.org/3.0/development/api/
- BBB official FAQ (200-user rule of thumb, 1 Gbit/s recommendation, per-user bandwidth, recording disk usage): https://bigbluebutton.github.io/support/faq.html
- Learning Analytics Dashboard (official): https://bigbluebutton.com/docs/help/moderator-guide/learning-analytics-dashboard
- Version state: 4.0.0 (14 Oct 2026) / 4.0.4 (24 Nov 2026), 3.0.42 supported — https://endoflife.date/bigbluebutton
- Moodle core integration model (URL + secret, activity plugin): Moodle documentation via https://tips.webtech360.com/en/network-admin/how-to-integrate-bigbluebutton-with-moodle-lms-hp0/99901370
- Local grounding: `REKTRS-SCHOOL-ERP-GAP-AUDIT-2026-11-23.md` (LMS live-class PARTIAL; block F provider bindings), `PRESKOOL-FEATURE-DISPOSITION-AND-REPLACEMENT-PLAN-2026-11-17.md` (Gmeet/Zoom KEEP-OURS), MEMORY.md fleet records (Oracle offbox-1 2 OCPU/12 GB; micros 1 OCPU/1 GB; Operqon VPS shared production host).
