# Study — listmonk (knadh/listmonk)

**Date:** 2026-11-28 · **Studied for:** (a) Rektrs' own marketing/newsletter tool, (b) a possible Sendqon-side email-campaign offering
**Sources:** GitHub repo + releases page (checked live 2026-11-28), listmonk.app documentation (Introduction/Concepts/Messengers/APIs/Transactional), AGPL-3.0 full text (gnu.org). Every claim below traces to one of these; where the docs are silent, that is stated. Licence analysis is an engineering reading of the licence text, not legal advice.

## What it is

A standalone, self-hosted, **one-way** mailing-list and newsletter manager: subscribers, lists, campaigns, templates, bounce processing, and a transactional send API, packed into a **single Go binary** whose only dependency is a **PostgreSQL** database (≥ 12). Backend Go, admin frontend Vue/Buefy (v6 line; v7 replaces it with a new lightweight UI), served on port **9000** by default. It is **not** a mail server and not a CRM/automation-journey platform: sending goes out through an external SMTP service you configure, and the docs describe no multi-step drip/journey builder (sequences are built via the API or external tools). Repo stats at study time: **24,500 stars, 2,839 forks, 143 watchers, 2,365 commits, 43 releases**, created 2019-06-26, not archived, licence detected by GitHub as **AGPL-3.0**. (GitHub repo page, 2026-11-28)

## Licence — AGPL-3.0, mechanics per use

listmonk is licensed under the **GNU AGPL v3** (README "License" section + repo `LICENSE` file; no project-specific additional terms under §7 were found in the repo materials reviewed — the licence in the tree is the stock AGPL-3.0). The clauses that decide our four scenarios:

- **§2 (Basic Permissions):** "This License explicitly affirms your unlimited permission to run the unmodified Program." Running it costs nothing and triggers nothing.
- **§0 / §5 (aggregation):** "Mere interaction with a user through a computer network, with no transfer of a copy, is not conveying," and a compilation of a covered work with "separate and independent works … not combined with it such as to form a larger program" is an **aggregate** — inclusion in an aggregate "does not cause this License to apply to the other parts of the aggregate."
- **§13 (Remote Network Interaction) — the clause AGPL adds over GPL:** "if you modify the Program, your modified version must prominently offer all users interacting with it remotely through a computer network … an opportunity to receive the Corresponding Source of your version … from a network server at no charge." Note the trigger precisely: it fires on **modification + remote interaction**, not on hosting alone.
- **§5(c) / §10:** a modified work you convey must be licensed **as a whole** under AGPL, and you "may not impose any further restrictions" on recipients' exercise of their rights — recipients of the source may use, modify and redistribute it.

Applied:

### (a1) Internal use, unmodified — clean
Run the released binary/image as-is for Rektrs' own lists. No source offer, no notices beyond what the software itself shows, no fee. Configuration, SMTP settings, lists, templates and content are *data*, not modifications of the Program.

### (a2) Internal use, modified — obligation exists but stays inside the house
If we patch the code and only Rektrs staff interact with it over the network, §13 textually requires the modified version to offer its Corresponding Source to **those users** — i.e. our own people, who can be given an internal source link. Nothing in §13 requires offering source to the general public when the public does not interact with the modified program. One nuance: listmonk serves **public subscription pages/forms** — if a *modified* build serves pages the public interacts with, public visitors are plausibly "users interacting remotely" too. The low-risk posture for (a) is therefore: **stay unmodified**, and do all customisation through the supported surfaces (config, settings, templates, `--static-dir` public templates), which are designed for exactly this and do not require touching the binary.

### (b1) Hosted for tenants, unmodified, standalone — clean, and this is the only clean SaaS shape
AGPL does **not** close the SaaS door for unmodified software: §13's source-offer duty is conditional on modification. Giving tenants access to **unmodified, per-tenant listmonk instances** (their own container + database, configured — not patched — by us) triggers no source-offer obligation and no licence fee. Charging for hosting/support is unrestricted (§4 expressly allows charging for copies and for support/warranty; network access pricing is not restricted either).

### (b2) Hosted for tenants, modified / white-labelled — the trap
The moment we patch listmonk for tenants (white-label the code, add Sendqon-specific features inside it) and tenants interact with it remotely, §13 obliges us to **prominently offer every tenant user the complete Corresponding Source of our modified version, free, over the network**. Consequences, mechanically:
- Any tenant (and anyone they pass it to) can legally take, run and redistribute our modified build — the modifications cannot be kept proprietary.
- §10 bars us from contractually restricting that redistribution as a licence condition.
- Changing logos/colours is itself a modification; there is no "just branding" exemption. (Pure configuration and template/static-dir customisation on an *unmodified* binary is the only branding route that stays in b1.)
- If a modified build is ever *conveyed* (e.g. shipped to a tenant's own server), §5(c) forces the whole work under AGPL with prominent modification notices.

### (d) Embedding/linking into Sendqon vs standalone
- **Standalone + HTTP integration (recommended posture):** listmonk runs as its own service; Sendqon talks to it via its REST API, and listmonk talks to Sendqon (if at all) via the messenger webhook (below). Two separate programs exchanging JSON over HTTP is the §5 aggregate shape — Sendqon's own code stays entirely outside AGPL. This matches how Sendqon already treats companions.
- **Embedding/forking (avoid):** merging listmonk code into the Sendqon codebase, or shipping a combined work, makes the combined work a work based on the Program — §5(c) whole-work AGPL on conveyance, §13 source offers on network use. There is no product reason to pay this price: the API and messenger surfaces already expose everything needed.

## What it adds vs Sendqon today

Sendqon today has an **Email channel** (companion server: conversational/transactional mail in the panel) and campaign machinery for SMS/WhatsApp — but **no email-campaign class at all**: no subscriber lists, no opt-in lifecycle, no email templates-for-campaigns, no bounce processing, no open/click analytics. listmonk is precisely that missing class:

- **Lists & subscribers:** unlimited lists; single or double opt-in; public/private lists; per-subscriber JSON **attributes**; statuses per list-membership (`unconfirmed` / `confirmed` / `unsubscribed`); CSV import; list archival; public subscription forms and pages; one-click unsubscribe via `List-Unsubscribe` header.
- **Segmentation:** subscribers are filtered into target groups by **SQL-based queries** over attributes and membership (the docs' segmentation model), saved/reused at campaign creation.
- **Campaign engine:** regular and opt-in campaigns; schedule for later; test sends; per-campaign messenger choice; content in HTML / Markdown / plain text / visual builder / raw HTML, all rendered through **Go templates + Sprig functions** with per-subscriber attribute interpolation and campaign-level JSON attributes; media manager (filesystem or S3).
- **Analytics:** tracking pixel (views) and per-link click tracking, both optionally anonymised and globally disableable (v6.1+); per-campaign and per-list analytics (views, clicks, bounces, subscriptions/unsubscriptions; v7 adds per-subscriber activity breakdowns and public campaign archives/RSS for public lists). **No native A/B testing** is documented — docs silent; treat as absent.
- **Bounces:** automatic processing two ways — scanning a configured **POP3 mailbox**, and **provider webhooks for AWS SES and SendGrid** (Postmark spam-complaint handling is in core; v7 adds Azure webhooks and mandates SES SNS-topic allow-listing + Azure shared secret). Bounced subscribers can be auto-blocklisted or deleted per settings.
- **Transactional API:** see next section.
- **Admin/security:** multi-user with **user roles** (permission sets) and **per-list roles**; API users + tokens; OIDC login and TOTP 2FA (v6+); i18n. **There is no multi-tenancy/workspace concept** — one instance = one organisation's lists and users; the docs describe no tenant isolation, billing, or per-customer partitioning (docs silent because the feature does not exist in the model).

## API surface

"All features that are available on the listmonk dashboard are also available as REST-like HTTP APIs" (docs), JSON in/out, auth by **BasicAuth or `Authorization: token` header** with per-user permissions; an auto-generated **OpenAPI (Swagger) spec** is published. Surface, by area:

- **Subscribers:** CRUD, bulk import, blocklist, per-subscriber list memberships, activity (v7: `DELETE /api/subscribers/:id/activity/:type`).
- **Lists:** CRUD, archive, membership management.
- **Campaigns:** `POST /api/campaigns` (fields include `lists`, `template_id`, `messenger` — `'email'` or a custom messenger name — `headers` with template expressions, campaign `attribs`), status control (draft/send/pause/cancel), stats endpoints.
- **Templates:** CRUD for campaign and transactional templates.
- **Transactional:** `POST /api/tx` — sends a preconfigured transactional template to one or many recipients. Parameters: `subscriber_email` / `subscriber_id` / `subscriber_emails[]` / `subscriber_ids[]`, `template_id` (required), `data` (JSON, exposed to the template as `{{ .Tx.Data.* }}`), `from_email`, `subject`, `headers[]`, `content_type` (`html`/`markdown`/`plain`), `altbody`, `messenger` (default `email`), and attachments via `multipart/form-data` (`file` parts). Recipient resolution modes: `default` (must exist as subscribers), `fallback` (send anyway if not found), `external` (send to arbitrary addresses with no DB lookup — added in v6.0.0). Targeting existing subscribers via the API requires the `subscribers:get` permission (tightened further in v7).
- **Bounces, media, settings, users/roles:** all exposed (e.g. `GET /api/bounces`).

## The messenger model — the strategically interesting part

listmonk's sending backends are called **Messengers**. `email` (built-in SMTP pool) is the default; arbitrary others can be registered in **Settings → Messengers** and selected per campaign (and per transactional send, via the `messenger` parameter). A messenger is **not** a plugin inside listmonk — it is an **external web service** listmonk pushes to:

- When a campaign runs, listmonk **POSTs each message as JSON** to the messenger endpoint and expects **`200 OK`**; optional **BasicAuth** on the endpoint.
- Payload: `{ subject, body, content_type, recipients: [{ uuid, email, name, attribs: {...}, status }], campaign: { uuid, name, tags } }`.
- The delivery address (phone number, FCM ID, …) is **not** a first-class field — it is expected to live in **subscriber attributes** (`attribs.phone`, `attribs.fcm_id` in the docs' own example). Docs verbatim: the model enables "not just e-mail campaigns, but arbitrary message campaigns such as SMS, FCM notifications etc."
- Community messenger servers already exist for: **AWS Pinpoint SMS, Verimor (SMS), Mailersend, Novu, Google FCM, and Resend** — proof the pattern is real and used, including one for a provider Rektrs already uses.

**Can Sendqon be a messenger? Yes — mechanically this is a small shim, and it is the single most valuable finding of this study.** A tiny standalone service (our own code, our own licence) that accepts listmonk's POST, reads `attribs.phone`, and calls Sendqon's existing send API would let a listmonk campaign broadcast as **SMS through a tenant's Sendqon channels** (Android SIM gateway, SMPP, etc.). The same shim shape works for WhatsApp if the attribute carries a WhatsApp ID. Honest limits, from the protocol as documented:

- **Fire-and-forget:** the contract is "POST → 200 = accepted." The docs describe **no delivery-status/bounce callback from a messenger back into listmonk** (docs silent on any return channel) — so listmonk-side campaign stats for an SMS campaign would show *handed-off*, not *delivered/failed*; delivery truth stays in Sendqon where it belongs.
- **Throughput mismatch:** listmonk is built to push large volumes fast; SIM-gateway SMS is a slow, carrier-tolerance-bound channel (per the capcom6 evaluation: batch sending via SIMs is explicitly not recommended by that project either). An SMS messenger must queue and throttle on the Sendqon side; listmonk will not pace it for you.
- **Subscribers are email-keyed:** every listmonk subscriber is identified by an e-mail address; a phone-only contact still needs a (possibly synthetic) email identity in listmonk, with the real phone in attributes. Workable, but it is a modelling wart to design around, not discover later.

## Stack / ops fit (offbox-1)

- **Footprint:** one Go binary + one Postgres. Official `docker-compose.yml` pairs `listmonk/listmonk` with `postgres:17-alpine`; install/upgrade is idempotent (`--install` / `--upgrade` run on start in the compose flow). No Redis, no queue service, no worker fleet. Exact RAM/CPU figures are **not published in the docs** (docs silent); the binary class is tens-of-MB idle — trivial next to the existing ServerKit stack on offbox-1 (2 OCPU / 12 GB), as one more compose app behind Caddy (e.g. `lists.rektrs.com` for (a), per-tenant subdomains for (b)).
- **Upgrades:** replace binary/image, run `--upgrade`, done — the releases repeat this verbatim; DB backup before upgrade is the documented discipline (our backup.sh pattern already fits).
- **Deliverability stack it expects:** listmonk sends via **SMTP servers you configure** (multiple servers, pooled; v6.2 adds selection by From domain; Gmail relay preset exists). It is not an MTA and documents **no built-in DKIM signing** — signing, SPF alignment and IP reputation are the **SMTP provider's** job (SES / Postmark / SendGrid are the docs' named examples). PTR/reverse-DNS only matters if we ever run our own MTA, which this study does not recommend.
- **Against Rektrs' actual mail facts:** rektrs.com mail is **Hostinger** (MX + Hostinger SMTP) and the transactional subdomain **send.rektrs.com runs on Resend**. Hostinger SMTP will technically accept listmonk's mail but is the wrong pipe for campaigns (shared-IP reputation, volume limits, no bounce webhooks into listmonk). The sane wiring for (a): send campaigns from a **dedicated subdomain** (e.g. `news.rektrs.com`) via **Resend SMTP or SES**, with that subdomain's SPF/DKIM/DMARC published, keeping rektrs.com's own reputation and the send.rektrs.com transactional stream separate. Bounce feedback: SES/SendGrid webhooks are core-supported; **Resend is not in the core bounce-webhook list** (docs silent on Resend bounce ingestion — the community `listmonk-resend` messenger exists for sending, but bounce/complaint return into listmonk via Resend is not documented), so SES is the lowest-surprise provider if automated bounce hygiene matters from day one.

## Maintenance health

Very healthy, single-maintainer-led (Kailash Nadh / Zerodha) with a wide contributor tail (the v7 beta notes list 35+ first-time contributors). Signals at 2026-11-28:

- **Releases:** 43 total. The v5.0.x → v5.1.0 (security: CVE-2025-58430 CSRF fix) → v6.0.0 (TOTP 2FA, tx-to-non-subscribers, list archival) → v6.1.0 → **v6.2.0 (2026-06-26, latest stable)** line shows steady major/minor shipping through 2025–2026; **v7.0.0-beta.1 landed 2026-10-20 and v7.0.0-beta.2 is the current newest release** — a major release (full admin-UI rewrite, ~80% smaller bundle, new analytics) in active beta, plus automated **nightly builds**. This is a project mid-stride, not in maintenance mode.
- **Responsiveness:** security issues get point releases (v5.0.2/v5.1.0 were security-driven); the v7 betas carry long fix lists including permission-check hardening — relevant if tenants ever touch it.
- **Risk note:** v7 is a breaking-change release (settings API shape, from_email array, SES/Azure webhook requirements, tx permission tightening). For any adoption, pin **v6.2.0 stable** now and treat v7 as a later, deliberate upgrade.

## Effort estimate (lane-sized)

### Use (a) — Rektrs' own marketing tool
- **Lane A1 (deploy + deliverability):** compose app on offbox-1 + Caddy route + Postgres; sending subdomain DNS (SPF/DKIM/DMARC); SES (or Resend SMTP) account hookup in Settings → SMTP; bounce webhook wired; one seed list + test campaign to a Rektrs mailbox, bounce path verified. ~1 lane.
- **Lane A2 (content + go-live):** branded templates (config/static-dir surfaces only — stays unmodified per §(a2)), subscription form/page linked from rektrs.com, import of Rektrs' existing contacts, first real campaign. ~1 lane, mostly content work.
- **Total: ~2 lanes, no code written, no licence exposure.**

### Use (b) — Sendqon-side offering
- **Lane B1 (packaging design):** instance-per-tenant pattern on the ServerKit model (compose template, subdomain, backup inclusion, plan gating in the panel as a *link-out/SSO convenience only* — no code inside listmonk). Design + proof with one pilot tenant instance, unmodified v6.2.0. ~1–2 lanes.
- **Lane B2 (messenger shim, optional but the differentiator):** standalone "Sendqon messenger" service: listmonk POST in → Sendqon API send out (SMS first), with queueing/throttle and per-tenant API-key mapping; tested against a pilot instance's campaign. Our code, our licence, ~1–2 lanes.
- **Ongoing:** per-tenant instance ops (upgrades are cheap but multiply by tenant count), deliverability support per tenant sending domain. This is an **ops product**, not a plugin — price it like one.
- **Explicitly not estimated:** any modified/white-labelled fork — see verdict.

## Verdicts

### (a) Rektrs' own marketing tool — **GO**
Unmodified, self-hosted listmonk fills a real gap (Rektrs has no newsletter/campaign capability anywhere in the family) for ~2 lanes of work and zero licence friction. Pin v6.2.0, send from a dedicated subdomain via SES/Resend, keep every customisation in config/templates. Nothing else in this study's scope comes close on effort-to-value.

### (b) Sendqon-side offering — **GO, with hard conditions** (and a NO-GO inside it)
- **GO** for: unmodified, standalone, **instance-per-tenant** listmonk offered alongside Sendqon, integrated only over HTTP (panel link/SSO convenience + the optional messenger shim that lets listmonk campaigns send SMS via Sendqon). AGPL is fully satisfied by *not modifying it*; the shim is our own separate program.
- **NO-GO** for: embedding listmonk into Sendqon, forking it into a white-labelled "Sendqon Email Campaigns" module, or any modified build tenants interact with — §13 would force us to offer the modified source to every tenant user, for free, forever, and §10 stops us contracting around it. The product differentiation would be published by design.
- **Sequencing note:** (b) should follow (a). Running listmonk for Rektrs first proves the deliverability playbook (SPF/DKIM/bounces/provider) on our own domain before any tenant's reputation depends on it.
