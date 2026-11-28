# Standalone-App Studies — Documenso · Cal.diy · Formbricks (2026-11-28)

**Owner order (main chat, 2026-11-28 ~21:41 PKT):** "Han in sab ko study main
dalo" — full app-first studies of three standalone open-source apps as Operqon
tenant-feature candidates, in the same method as the Frappe-app knowledge base
(`FRAPPE-APP-KNOWLEDGE-BASE-2026-11-28.md` + `...-PART2-2026-11-28.md`).
**Read-only research — nothing was installed anywhere.**

**Evidence method (today):** each repo was shallow-cloned from its real
upstream (`~/workspace/app-census-20261128/standalone/`) and read directly —
root LICENSE, EE/commercial licence files and feature lists, README licence
sections, package manifests, module/API trees. Repo health (stars, last
commit, releases) was read through the GitHub API on 2026-11-28. The standing
scan stack ran read-only over all three trees (Semgrep `p/security-audit`,
`--metrics=off`; Gitleaks; Bandit is Python-only and all three stacks are
TypeScript — recorded N/A, §S6). OCR delegation review was NOT run (paid key /
owner ChatGPT sign-in not configured — standing rule); the substitute applied
in the KB passes (manual licence/API-surface review) is applied here, and the
licence questions — the deciding questions of this study — are answered from
the vendors' own licence files and published licence docs, quoted at source.

**Why these three:** they are *standalone* apps, not Frappe apps. They cannot
ride the bench/image wave train; each would run as its own service beside the
platform, integrated through SSO, APIs and webhooks. The KB pass-2 e-sign
candidates (nesscale_sign, esign_app) are Frappe apps; Documenso is the
standalone heavyweight for the same slot. No Operqon surface today has
e-signing, a real booking engine, or surveys/feedback.

**Surfacing rule applied (owner, 2026-11-28):** L1 = the app's own frontend
re-themed inside our shell via Rektrs ID SSO; L2 = generic SPA screens over
its API; L3 = hand-built, exception only. The DreamsERP design condition and
the no-third-party-face rule apply at every level.

---

## §S1 — At a glance

| App | Licence (verified at source) | Adds what Operqon lacks | Level | Verdict |
|---|---|---|---|---|
| **Documenso** v2.22.0 | AGPL-3.0 core + `packages/ee` under Documenso Commercial License | Full e-signing: envelopes, templates, recipient roles, audit-sealed PDFs, embed signing, webhooks | L1 (own UI) + API seam; SSO paywalled (EE) | **GO — conditional** (API-first route; SSO gap named) |
| **Cal.diy** (post-split main) | MIT (whole tree; no EE folder) | Calendly-class booking: event types, availability, booking pages, embeds | L1 in shape only | **NO-GO for tenant production** (vendor's own non-production warning; teams/workflows/SSO removed; no release since the split) |
| **Formbricks** 6.1.8 / 6.2.3 | AGPL-3.0 core + `apps/web/modules/ee` under Formbricks EE License; survey SDK packages MIT | Surveys/feedback: link, website, in-app, email surveys, logic, analysis | L1 in shape only | **NO-GO as a tenant-facing surface on current terms; WATCHLIST** (white-label not offered; branding removal + SSO + multi-workspace all EE) |

**The pattern across all three (a method lesson for the app-first census):**
for standalone apps, the Frappe-pass questions (does it install, does it wire)
are replaced by two sharper gates — **(1) is SSO inside or outside the
commercial folder?** and **(2) may the vendor's face be hidden from tenants?**
In all three repos those two answers, read from the EE folders, decide the
verdict more than any feature list. Future standalone candidates get an
"EE-folder check" first, before any feature study.

---

## §S2 — Documenso — document e-signing

- **Identity / health:** documenso/documenso — **15,942 stars, 3,551 forks**;
  last commit **2026-11-27**; latest release **v2.22.0 (2026-11-13)**, with
  v2.21.x in October — a fast, steady release cadence through 2026. TypeScript
  monorepo (Next.js/React Router app `apps/remix`, Prisma/PostgreSQL,
  tRPC + a ts-rest REST API). Vendor: Documenso, Inc.; contributors sign a
  **CLA granting Documenso a sublicensable licence (incl. patent grant)** —
  the standard dual-licensing shape that funds the commercial edition.
  Governance note: external PR intake was narrowed in 2026 (invited
  contributors merge; others file issues) — upstream is vendor-steered, not
  community-steered.
- **What it adds:** the complete signing workflow Operqon has nowhere —
  documents/envelopes with multiple recipients and signing order, field
  placement (signature, initials, text, date, checkbox…), templates +
  direct-template links, team/organisation workspaces, custom branding,
  sealed completion certificates and a full audit log, reminder/expiry
  handling, embed signing for external signers, and a webhook + REST API
  surface (below). Signature level in the free edition is instance-sealed
  **simple electronic signature (SES)** under ESIGN/UETA/eIDAS-simple;
  AES/QES via CSC trust providers is Enterprise-only.
- **API + webhooks (read in tree):** `packages/api` carries a versioned
  ts-rest contract (`/api/v1/documents`, templates, recipients, fields,
  send/resend, download) with an OpenAPI document; v1 endpoints are marked
  deprecated-but-supported in favour of the current public API. Webhooks are
  a core (non-EE) server module (`packages/lib/server-only/webhooks/`,
  typed payloads in `types/webhook-payload.ts`) — document
  sent/viewed/signed/completed events can drive ERPNext status updates.
  Embedding splits: **embed signing (recipient side) is core**;
  **embed authoring and embed-authoring white-label are EE**.

### §S2.1 — DECIDING QUESTION: the AGPL position for offering Documenso to tenants

Read from the repo (root `LICENSE` = AGPL-3.0; `packages/ee/LICENSE` =
Documenso Commercial License; `packages/ee/FEATURES`) and the vendor's
published Enterprise Edition policy:

1. **What is AGPL and what is not.** Everything outside `packages/ee` is
   AGPL-3.0. Inside `packages/ee` sits code under the Commercial License —
   usable in production **only** with a paid Business/Enterprise
   subscription; its text forbids copying/distributing/selling without one.
   The canonical gated list (`packages/ee/FEATURES`, read verbatim):
   *Stripe Billing Module · Organisation Authentication Portal · Document
   Action Reauthentication (Passkeys and 2FA) · 21 CFR Part 11 · Email
   domains · Embed authoring · Embed authoring white label · CSC signing*.
2. **The §13 duty, concretely.** AGPL §13: if we **modify** Documenso and
   let users interact with the modified version over a network, we must
   prominently offer **all users of that instance** the Corresponding
   Source of the modified version, free of charge. The duty attaches to the
   *version interacted with*, not to tenants one by one:
   - **Unmodified + API-only integration** (our SPA/provider calls its API,
     tenants use its stock UI): the vendor's own published table records
     this as **Community Edition — sufficient**. No modification, no §13
     source-offer trigger beyond the app's own licence notices (we still
     ship the standard in-app source entry, as with every AGPL app — cheap
     and already our pattern).
   - **Modified** (e.g. a DreamsERP re-theme of its UI, our SSO bridge
     patched in): §13 triggers — the modified source must be offered to
     every user of the instance, *or* we buy the Commercial License, which
     is precisely the product that removes the disclosure duty. There is no
     third option; "modified + private + hosted for tenants" is the one
     combination AGPL forbids and the EE licence sells.
   - **Per-tenant vs single instance:** organisations and teams are
     Community features, so one instance can host one organisation per
     tenant. The §13 duty is instance-wide (one source offer covers the
     code every user interacts with); instance-per-tenant would multiply
     operations, not duties. Data isolation between tenants inside one
     instance is organisation-scoped — acceptable for signing metadata, and
     the lighter ops model; per-tenant instances remain available for any
     tenant whose contract demands it.
3. **SSO — the real cost of the free route.** The **Organisation
   Authentication Portal (SSO with SAML and OIDC) is EE**. Community
   sign-in is local accounts + social OAuth + passkeys. So the standing
   L1 pattern ("the app's own frontend, SSO via Rektrs ID") is **paywalled
   for this app**: tenant staff would hold separate Documenso credentials
   unless we (a) buy Business/Enterprise (owner spend decision; pricing is
   quote-only), or (b) run the **API-first route** — our SPA (already
   Rektrs-ID-authenticated) is the staff face: it creates envelopes from
   ERPNext documents via the API, tracks status via webhooks, and external
   signers use Documenso's stock signing pages (signers are outside
   parties; they never needed our SSO). Under (b) the only Documenso-UI
   users are tenant staff following a deep link for field placement —
   a named, bounded exception, recorded here rather than discovered later.

- **Fit into industry packs:** contracts everywhere (Sales/Purchase
  agreements, dealer agreements on the EV spine), HR onboarding (offer
  letters, policy acknowledgements — rides the HRMS wave), school admission
  forms (Education pack: guardian undertakings), clinic consent forms,
  tenancy agreements (Real Estate pack). In every case the ERPNext document
  stays the record; Documenso is the signing act + evidence trail, linked
  by webhook status.
- **Integration route (concrete):** one provider-operated instance →
  organisation per tenant at provisioning (API/admin) → provider API keys
  per organisation → SPA "Send for signature" on Sales Invoice / Contract /
  HR documents (L2 seam) → webhooks write status + signed-PDF link back to
  the ERPNext document → signers on stock signing pages (SES seal).
- **Effort estimate:** instance stand-up (Docker, PostgreSQL, SMTP,
  signing certificate, backups) **2–3 days**; provisioning hookup +
  webhook bridge + the SPA send/track seam **1–2 weeks** (one lane);
  per-pack document templates are configuration, days each.
- **Risks:** (1) SSO paywall (above) — the EE quote is an owner spend
  decision, deliberately not assumed; (2) SES-only signatures in CE —
  adequate for ordinary commercial contracts; regulated/PK-specific
  evidentiary weight is a counsel item, same class as FBR/ZATCA counsel
  notes; (3) vendor-steered roadmap + narrowed external contributions —
  our exposure is bounded because the integration is API/webhook-level,
  not a fork; (4) a second production stack to operate (PostgreSQL,
  SMTP deliverability, certificate custody) beside the bench.
- **Scans:** §S6.
- **VERDICT: GO — conditional.** Adopt as the platform's signing engine on
  the API-first route under AGPL (unmodified; §13 handled by the standard
  source-offer pattern if that ever changes). The EE/SSO question goes to
  the owner as a priced option only when a tenant-facing staff-UI need is
  proven; it does not block the engine adoption. This supersedes nothing in
  pass 2 — nesscale_sign/esign_app remain the in-bench fallbacks if a
  tenant must have signing fully inside ERPNext.

---

## §S3 — Cal.diy — appointment booking

- **Identity / health:** calcom/cal.diy — **50,456 stars, 15,787 forks**
  (accumulated over five years as Cal.com; they did not reset at the
  split). Last commit **2026-11-13** (community pace). **Latest release
  v6.2.0 is dated 2026-03-01 — pre-split; no release has been published
  since the April 2026 rename.** TypeScript monorepo (Next.js, tRPC,
  Prisma/PostgreSQL, API v2 app under `apps/api/v2`).
- **What happened (vendor's own words, README read in tree):** on
  2026-04-14/15 the `calcom/cal.com` repo was renamed `calcom/cal.diy`,
  relicensed AGPL→MIT, and stripped of enterprise code; Cal.com's
  production codebase went private/closed. The README carries, verbatim in
  substance: *"Use at your own risk… It is strictly recommended for
  personal, non-production use"* and *"For any commercial and
  enterprise-ready scheduling infrastructure, use Cal.com, not Cal.diy."*
  It describes itself as *"a fork of Cal.com with all enterprise/commercial
  code removed… 100% MIT-licensed with no proprietary 'Enterprise Edition'
  features… Community-maintained."*
- **What the MIT edition ACTUALLY includes (tree-verified):** the
  scheduling engine — event types, availability schedules, booking pages,
  the Booker UI, calendar integrations (Google/Outlook et al. via the
  app-store), video-conferencing apps, booking questions (form-builder),
  email notifications, webhooks (`packages/features/webhooks`), embeds
  (`packages/embeds` + features/embed), paid event types via the Stripe
  app (tenant's own Stripe), and a platform/API v2 surface
  (`apps/api/v2`, `packages/platform`). There is **no `ee/` directory and
  no workflows package anywhere in `packages/features`**.
- **What is MISSING vs the packs' needs (the deciding table):**

  | Pack need | Cal.diy CE | Consequence |
  |---|---|---|
  | **Teams / staff scheduling** (a clinic's doctors, a salon's stylists, round-robin) | **Removed** (README: Teams, Organizations removed) | The core industry use-case — many staff, one business — is the missing piece. Leftover team/org tRPC handlers and membership repositories remain in the tree (PERMISSIONS.md maps them), but the supported feature surface is single-user scheduling |
  | **Workflows / automated reminders** | **Removed** (README: Workflows removed) | No reminder/follow-up automation — the feature that cuts no-shows for clinics/salons. Only basic booking notification emails remain |
  | **SSO via Rektrs ID** | **Removed** (SSO/SAML was EE) | L1's defining mechanism does not exist; tenant staff get separate credentials |
  | Routing forms, Insights/analytics | Removed | Minor vs the three above |
  | Event types, availability, booking pages, payments, embeds, API | **Present** | A solo practitioner's Calendly — genuinely complete at that scope |

- **Licence position:** MIT is the most permissive of the three studies —
  commercial use, modification, white-labelling all allowed, no copyleft.
  The licence is not the problem; **the product's own stewardship is.**
- **Risks:** (1) the vendor **explicitly dis-recommends production use**
  and points commercial users to the closed product — adopting it for
  paying tenants means carrying a stack its maker won't stand behind;
  (2) **no tagged release since the split** — we'd ship from a moving
  `main` or pin an increasingly stale pre-split release; (3) security
  history: the pre-split codebase accumulated serious CVEs (incl. a
  CVSS-10 unauthenticated RCE in the bundled Next.js RSC handling,
  published July 2026 against pre-5.9.9) — patching cadence is now a
  community responsibility with no vendor SLA; (4) the missing features
  are exactly the ones that cannot be bolted on cheaply — rebuilding
  teams + workflows + SSO on top would be a fork-and-own commitment
  (MIT allows it; the effort is a product, not a lane).
- **Effort estimate (for the record):** stand-up 2–3 days; but reaching
  pack-grade (teams, reminders, SSO) is **not estimable as integration** —
  it is a fork-development programme. That asymmetry is the verdict.
- **Scans:** §S6.
- **VERDICT: NO-GO for tenant production.** Recorded, with the honest
  alternative paths: (a) booking stays on ERPNext's built-in Appointment
  doctype + SPA wiring for now (basic, but ours and supported); (b) if a
  paying Clinic/Salon/Gym tenant makes booking depth a closing condition,
  the priced comparison is closed-source Cal.com cloud vs a purpose-built
  booking lane on ERPNext — an owner decision at that time; (c) WATCHLIST
  trigger: Cal.diy publishes a post-split release with a stated production
  support position, or a community fork restores teams/workflows under a
  maintained release cadence.

---

## §S4 — Formbricks — surveys & feedback

- **Identity / health:** formbricks/formbricks — **13,316 stars, 2,632
  forks**; last commit **2026-11-27**; releases **6.1.8 (2026-11-27)** and
  **6.2.3 (2026-11-25)** — two active version lines, very active vendor
  (Formbricks GmbH). TypeScript monorepo (Next.js app `apps/web`, Prisma,
  an API v3 + OpenAPI spec at repo root, a built-in MCP server module,
  SpiceDB-backed permissions in newer lines). Contribution posture is
  vendor-controlled ("we can only facilitate code contributions as an
  exception" — README).
- **What it adds:** the survey/feedback layer no Operqon surface has —
  a no-code survey editor with logic/branching, link + website + in-app +
  email-embedded surveys, multi-language surveys, file upload, response
  analysis and exports, follow-up emails, API keys + REST API + webhooks
  (all core, tree-verified in `apps/web/modules`: `survey/`, `api/`,
  `integrations/webhooks/`, `mcp/`). Fits: post-service feedback on the
  EV/service spine, patient-satisfaction (Clinic), parent feedback
  (School), tenant-NPS for our own portal, HR pulse surveys.
- **The AGPL + EE split (root LICENSE, read verbatim):** everything is
  AGPL-3.0 **except** (a) `apps/web/modules/ee/**` — under the Formbricks
  EE License (production use requires a valid Enterprise licence **per
  user seat**; the EE code ships inside the same Docker image, key-gated),
  and (b) the survey SDK/renderer packages (`packages/surveys`,
  `packages/survey-ui`, `packages/js*`, `packages/api*`) — **MIT**.
  The EE folder census (tree-read) is the deciding evidence — EE holds:
  **`whitelabel` · `sso` · `auth` (OIDC/SAML + 2FA) · `teams` ·
  `role-management` · `contacts` (segments) · `workflows` · `audit-logs` ·
  `data-retention` · `quotas` · `ai-translation`/`analysis` ·
  `unify-feedback` · `feedback-directory` · `creatives` · `mailing`
  (white-label email) · `billing` · `license-check`**. The vendor's
  licence doc adds the Community ceiling: **one organisation, one
  workspace; every member is an owner** (no roles) without a key.
- **DECIDING QUESTION 1 — white-label:** the repo README states verbatim:
  *"We currently do not offer Formbricks white-labeled. That means that we
  don't sell a license which let's other companies resell Formbricks to
  third parties under their name nor take parts (like the survey editor)
  out of Formbricks to add to their own software products."* Concretely
  for us: (i) hiding **"Powered by Formbricks"** on respondent-facing
  surveys is an **EE-key feature** (`ee/whitelabel`); (ii) white-label
  respondent emails are EE; (iii) no licence they sell permits reselling
  Formbricks under our name. A newer vendor docs page softens the wording
  ("We offer Formbricks white-labeled in some cases — send us an email"),
  which makes it a *negotiable exception*, not a right. Against our
  standing rule — **no third-party face may show to tenants, and a
  tenant's customers (survey respondents) are the most public face of
  all** — the free route fails on its face, and the paid route is not
  purchasable off the shelf.
- **DECIDING QUESTION 2 — what we may/may not use:** the AGPL core
  (editor, surveys, responses, API, webhooks) may be used commercially,
  modified only if modifications are published under AGPL (§13 pattern as
  §S2.1). The EE folder may **not** be used in production without the
  per-seat Enterprise licence — which removes, in one stroke, SSO (so no
  Rektrs-ID L1), roles/teams, multi-workspace (so multi-tenancy means
  **instance-per-tenant**, one org each), branding removal and workflow
  automations. One nuance worth a counsel check before any future use:
  the **survey renderer packages are MIT**, so rendering surveys inside
  our own UI over the AGPL backend's API is not obviously foreclosed by
  the licence texts — but the vendor's stated anti-resale position means
  this route is taken only with written vendor confirmation, never on a
  unilateral reading.
- **Integration route (if terms ever change):** instance-per-tenant
  (CE ceiling forces it), API-key + webhook bridge to ERPNext (responses
  land as Feedback records), surveys distributed as links/embeds from the
  SPA — L1 in shape, minus SSO.
- **Effort estimate:** stand-up 1–2 days per instance class + 1 week for
  the API/webhook bridge; the blocker is not effort, it is terms.
- **Risks:** (1) terms risk dominates — building a tenant feature on a
  surface whose branding we cannot remove invites a public rule breach;
  (2) per-seat EE pricing, if ever quoted, taxes every tenant staff seat;
  (3) instance-per-tenant ops multiplication; (4) vendor-controlled
  contributions + a fast-moving codebase (two release lines) raise our
  upgrade-tracking cost.
- **Scans:** §S6.
- **VERDICT: NO-GO as a tenant-facing surface on current terms;
  WATCHLIST.** Triggers to reopen: (a) Formbricks confirms white-label /
  EE terms for resellers in writing (their docs invite the email — an
  owner-approved enquiry costs nothing and converts this verdict either
  way); (b) a scoped internal-only use appears where respondents are our
  own staff, not tenants or their customers (branding rule not engaged);
  (c) the MIT-renderer route gets written vendor confirmation. Until
  then, feedback needs ride ERPNext's built-in Web Form / Feedback
  doctypes — basic, licence-clean, ours.

---

## §S5 — What this changes in the plan

1. **Documenso** enters the candidate queue as the signing engine
   (API-first lane, post-W4 in the rotation; the EE/SSO quote is an owner
   option, not a dependency). Industry packs gain a "signature step"
   design note: EV dealer agreements, HR onboarding, school admissions.
2. **Cal.diy** closes the "just adopt Cal" question with evidence — the
   booking gap stays an ERPNext-native build/wiring item; no lane is
   created against Cal.diy.
3. **Formbricks** closes the "just adopt a survey tool" question on
   terms, not features; a no-cost vendor enquiry is the only follow-up,
   and only if the owner wants the survey capability enough to ask.
4. **Method amendment (recorded for future standalone studies):** run
   the EE-folder check (SSO? branding? multi-tenancy?) *before* the
   feature study — in all three cases it, not the feature list, decided
   the verdict.

---

## §S6 — Scan coverage record (exact) + caveats

Standing stack, run read-only over the shallow clones on 2026-11-28
(outputs in `~/workspace/app-census-20261128/scans-standalone/`). All three
stacks are TypeScript — **Bandit (Python-only) is N/A for all three**, and
Semgrep ran `p/security-audit` only (`p/python` not applicable). Semgrep
parse errors mean coverage is a floor, not a proof of cleanliness — the
same honesty standard as KB passes 1–2.

| App | Semgrep `p/security-audit` | Gitleaks | Assessment |
|---|---|---|---|
| Documenso | **2 findings** (react-dangerouslysetinnerhtml ×2); 5 parse errors | 21 findings | Semgrep hits: `app-banner.tsx` (admin-configured banner HTML — by design) and the internal html-to-pdf certificate route (renders own content server-side) — named review items, not blockers. Gitleaks: 17 generic-api-key + 3 curl-auth-header, **all inside `apps/docs/content` (documentation examples)**, + 1 pkcs12 file in `apps/remix/example` (sample signing certificate) — **all false positives; no live secret** |
| Cal.diy | **12 findings** (react-dangerouslysetinnerhtml ×7, var-in-href ×4, detect-child-process ×1); 19 parse errors | 206 findings | child-process hit is `packages/app-store-cli` build tooling (expected use, not a web surface); innerhtml/href hits are the codebase's long-standing template patterns — review items if this code were ever adopted (it is not, §S3). Gitleaks clusters: **i18n.lock ×164** (translation-lock entropy matches — false-positive class), platform examples, Playwright fixtures (test Stripe keys), CI fixtures — **no live production secret identified** |
| Formbricks | **76 findings** (jwt-hardcoded-secret ×65, react-dangerouslysetinnerhtml ×8, unknown-value-with-script-tag ×3); 267 parse errors | 236 findings | **All 65 JWT hits are in `*.test.ts` files** (test fixtures — false positives). The ×3 script-tag hits sit on the survey-rendering surface — a named review item for any future adoption. Gitleaks clusters: **i18n.lock ×116**, authzed migration data ×42, generic-api-key pattern matches across modules — **no live secret identified** |

**Caveats (standing):** (1) OCR full review not run — no paid key / owner
ChatGPT sign-in configured; the licence/API-surface manual review above is
the documented substitute. (2) These are `main`-branch snapshots of
2026-11-28; Formbricks runs two release lines (6.1.x/6.2.x) and Documenso
releases monthly, so version-specific facts expire — the licence facts
(EE folder contents, README positions) are the durable part of this study.
(3) Legal characterisations are engineering readings of the licence texts
for planning; a counsel pass is owed before any AGPL app is activated for
paying tenants — the same standing note as the Frappe AGPL set.


---

# Part 2 — Medusa (appended 2026-11-28, owner study-queue entry ~23:00 PKT)

**Owner study-queue entry (main chat, 2026-11-28 ~23:00 PKT):** full
app-first study of Medusa as an Operqon online-store / e-commerce surface
candidate. Same method as Part 1: the real upstream repo shallow-cloned
(`~/workspace/app-census-20261128/standalone/medusa/`, `develop` HEAD
`01f39c44`, 2026-11-27) and read at source — licences, the Enterprise
licence file, module/API trees, in-tree docs; repo health via the GitHub
API on 2026-11-28; the standing scan stack run read-only (Semgrep
`p/security-audit --metrics=off`, Gitleaks; Bandit N/A — TypeScript).
**Read-only research — nothing was installed anywhere, and nothing was
sent to Cursor.** Licence archaeology across release tags was done by
fetching individual files at tags v2.18.0–v2.21.0 (raw file reads, no
second clone).

## §S7 — Medusa — headless commerce platform

- **Identity / health:** medusajs/medusa — **37,483 stars, 5,580 forks**;
  tree version **2.23.1**; `develop` HEAD committed **2026-11-27** (repo
  pushed the same day this study ran). Release cadence is fast and
  steady: tag train v2.21.x → v2.22.x → v2.23.1, roughly monthly minors
  with dense patch releases (v2.19.0 is dated 2026-08-13 — see §S7.1).
  TypeScript monorepo, 35+ packages: commerce modules (product, cart,
  order, payment, pricing, promotion, inventory, fulfilment, region,
  sales-channel, tax, customer, store, stock-location, currency,
  settings, translation, search) over infrastructure modules (auth,
  user, api-key, file, notification, event bus, workflow engine,
  locking, cache), a vendor **Admin dashboard** (`packages/admin`), and
  three API surfaces counted in tree: **Admin API 257 route files**
  across ~65 resource groups, **Store API 48**, **Auth 16**. Vendor:
  MedusaJS, Inc.; their hosted arm (Medusa Cloud) is also the licensing
  channel for the Enterprise Edition (§S7.1).
- **What it adds:** the commerce edge no Operqon surface has at this
  depth — a headless storefront API (no storefront ships in this repo;
  the vendor's Next.js starter lives in a separate repo, or the
  storefront is our own SPA), a **promotion engine** (promotions,
  rules, campaigns with budgets), a **pricing engine** (price sets,
  price lists, price rules, tiered pricing, multi-currency, contextual
  price calculation), **multi-region markets** (each region = currency
  + country set + tax region), **sales channels**, **draft orders**,
  and order **edits / claims / exchanges / returns** as first-class
  flows, plus inventory **reservations** across stock locations.
  Tree-verified absences, equally decision-relevant: **no
  accounting/GL module exists** (Medusa can never post an invoice's
  financial life), **no tenant concept** (one store per instance —
  multi-tenancy is instance-per-tenant), and **no multi-vendor /
  marketplace module** (marketplace builds are custom modules on top,
  not core).
- **Fit vs what we already have (KB pass 1):**

  | | ERPNext **Webshop** (USE, Wave 3) | **Ecommerce Integrations** (USE, Wave 2) | **Medusa** |
  |---|---|---|---|
  | Shape | Storefront rendered by ERPNext's website engine, inside the bench | Sync bridge to external platforms (Shopify/Amazon/Unicommerce/Zenoti) | Standalone headless commerce platform beside the platform |
  | Catalogue / order / stock truth | ERPNext itself — one truth, zero sync | ERPNext ↔ external platform sync | Medusa holds its own product/order/inventory data — a second truth that must be synced |
  | Storefront | Server-templated pages tied to ERPNext website theming | The external platform's | Any frontend: vendor starter or **our SPA on the Store API** — the only one of the three that can carry the full DreamsERP face natively |
  | Promotions / pricing | Website Offer basics | The external platform's | Full engines: promotion rules + campaign budgets; price lists/rules, tiered + contextual pricing |
  | Multi-region / multi-currency | ERPNext company-level | External platform's | Native region model (currency + countries + tax region per market) |
  | Order aftercare | ERPNext Sales Order flows | Sync-dependent | Draft orders, edits, claims, exchanges, returns as designed flows |
  | Cost to Operqon | An install wave (needs Payments) | An install wave | A second production stack (Node/PostgreSQL/Redis) per tenant + a permanent sync bridge |

  Medusa's genuine edge over Webshop is the storefront class
  (headless, promotion/pricing depth, multi-region, marketplace
  patterns via custom modules). Webshop's edge is decisive for the
  SMB-essential path: the truth never leaves ERPNext, and it rides
  the existing wave train. Ecommerce Integrations is not a competitor
  to either — it serves tenants who already sell on Shopify/Amazon.
- **Where truth lives + the seam:** ERPNext must remain the system of
  record — GL, stock ledger, invoicing and tax all live there and
  Medusa has no GL at all. Medusa would be the **commerce edge**:
  catalogue presentation, cart, checkout, promotions. The implied seam
  is two-way sync: catalogue + price lists + stock *levels* flow
  ERPNext → Medusa (Admin API); orders flow Medusa → ERPNext (Sales
  Order → invoice), with Medusa's inventory reservations acting as an
  allocation mirror mapped 1:1 to ERPNext warehouses — never a second
  ledger. Integration mechanics in tree: an event bus (local/Redis)
  with **subscribers as app code** (there is no generic outbound
  webhook module in core — the bridge's Medusa side is subscribers/
  workflows we write in our own app layer; payment-provider webhooks
  land on Medusa's `/hooks` routes and are mirrored out by the same
  bridge). Classification in pass-2 vocabulary: **WIRES-WITH-SEAM**
  (server-workflow sync on both sides), surfacing **L1 in shape** —
  vendor Admin re-themed + our own storefront — with the §S7.1
  exception carved out of that L1.

### §S7.1 — DECIDING CHECK: the August-2026 Enterprise move (verified in tree + across tags)

The claim put to this study — *from Aug 2026, RBAC + SSO moved to an
Enterprise (proprietary) licence while the core stayed MIT* — is
**confirmed precisely**, from the repo itself:

1. **What moved, and when.** The root `LICENSE` at v2.18.0 is plain
   MIT and there is no `ENTERPRISE-LICENSE.md`; at **v2.19.0
   (released 2026-08-13)** the root licence gains the carve-out —
   *"Except for the Enterprise Edition materials identified in
   ENTERPRISE-LICENSE.md, the repository is licensed under the MIT
   License"* — and the Enterprise licence file appears (still present,
   unchanged in substance, at v2.23.1). It names exactly three
   **Enterprise Materials**, all present in this tree with their own
   EE licence files (`Copyright (c) 2026 MedusaJS, Inc.`;
   package.json: `SEE LICENSE IN LICENSE`):
   - `packages/modules/rbac/` — **@medusajs/rbac** (RBAC)
   - `packages/modules/providers/auth-oidc/` — **@medusajs/auth-oidc** (SSO)
   - `packages/modules/audit/` — **@medusajs/audit** (audit logs)

   *"RBAC (role-based access control), SSO (single sign-on), and audit
   logs are Medusa Enterprise Edition features."* Use without a
   commercial agreement is declared infringement, and *"circumventing,
   disabling, or removing any license validation or feature-gating
   mechanism… is itself a violation."* Everything outside those three
   paths stays MIT — the file expressly includes the integration code
   (HTTP middleware, the `/rbac/*` routes, workflows, SDK resources,
   admin dashboard pages, licence validation) in the MIT remainder.
2. **What the MIT core keeps.** The full commerce core, the Admin
   dashboard, and authentication via **emailpass, Google and GitHub
   providers — all MIT** (package licences verified). What it does
   *not* keep: (a) **RBAC granularity** — the framework's `authorize`
   middleware is, at source, *"a no-op when RBAC is disabled"* and
   passes the request through when the rbac module is not installed;
   without the EE module every authenticated admin user is effectively
   full-access, with no roles or policies (the module itself seeds a
   Super Admin wildcard role and `resource:operation` policies — all
   EE); (b) **audit logs** — none in core; (c) **SSO** — the in-tree
   docs' own Auth Providers list shows Emailpass / Google / GitHub
   and badges **"OIDC (SSO)" as Enterprise**, linking to
   `/enterprise/sso`; the Admin SSO guides carry the Enterprise
   notice.
3. **The SSO question, precisely.** `@medusajs/auth-oidc` is a generic
   OIDC provider whose README names **Keycloak** explicitly among its
   supported IdPs — it *is* the Rektrs ID bridge, and it is EE. Can
   the MIT core reach Keycloak another way?
   - **Technically, the door is open.** The auth-provider interface
     (`AbstractAuthModuleProvider`, `packages/core/utils`) is MIT;
     custom auth providers are a documented, ordinary app extension
     (the auth-providers reference + a worked phone-auth tutorial ship
     in-tree); and **no code gate was found**: no `enterprise`
     references exist in the framework or medusa package sources, and
     the licence check (`packages/medusa/src/commands/utils/
     license-check.ts`) runs only when a licence key is configured —
     it validates *that key* against Medusa Cloud at start-up and
     exits if the key is invalid/revoked; with no key configured it
     returns silently. Nothing inspects or blocks a custom provider.
   - **Contractually, it is contested — and that is the answer that
     matters.** The EE licence declares *SSO itself* an Enterprise
     feature. A self-written OIDC provider uses none of Medusa's
     Enterprise Materials (their code is never touched), yet delivers
     exactly the feature they sell. This is the same class of question
     as Formbricks' MIT renderer (§S4): technically unblocked,
     vendor-intent against it. **The platform's identity strategy is
     not built on a contested reading** — the route is recorded as
     available only with written vendor confirmation, never assumed.
   - **One asymmetry worth recording:** `@medusajs/rbac` **was MIT up
     to v2.18.0** (package licence verified at the tag) and the EE
     notice is expressly prospective — *"does not withdraw rights
     already granted for earlier versions of any material under the
     MIT License."* An MIT RBAC ancestor therefore exists legally;
     auth-oidc and audit have **no MIT version** (both paths 404 at
     v2.18.0 — they were born EE in v2.19.0). Pinning or forking the
     2.18 RBAC module against a moving 2.x core is version-lock
     engineering against a monthly release train — recorded as a
     footnote, not a plan.
4. **What this means for Rektrs ID.** On the free route, tenant staff
   cannot sign in to the Medusa Admin through Keycloak, hold no role
   granularity (every staff login is full-access), and leave no audit
   trail — three standing platform rules (one identity across
   console/portal/tenants, provisioning-time entitlement permissions,
   operator audit) fail on this surface at once. **Shoppers are
   unaffected**: customer auth (emailpass/Google/GitHub) is MIT, so a
   customer-facing storefront is licence-clean end to end. Enterprise
   pricing is **quote-only** (the licence file points to a contact
   page; nothing public in repo or docs) — an owner spend decision if
   it is ever taken, not a plannable line item.

- **Licence position for commercial/SaaS use (summary):** the MIT
  core is the cleanest licence in this whole study series — full
  commercial/SaaS use, modification and white-labelling, **no
  copyleft and no §13-style duty at all** (a real advantage over the
  AGPL Frappe set). The three EE packages grant no rights without a
  commercial agreement.
- **Integration route (concrete, if ever adopted):** instance-per-
  tenant (core has no tenant concept) → provisioning creates the
  instance + sales channel per tenant → sync bridge (our code on both
  sides): ERPNext → Medusa catalogue/prices/stock-levels via the
  Admin API; Medusa → ERPNext orders via event subscribers in our
  Medusa app layer calling ERPNext REST; payment status enters via
  provider webhooks to Medusa and is mirrored out by the same bridge →
  ERPNext issues the invoice and posts GL. Storefront = our SPA over
  the Store API (L1); staff Admin = the named exception (emailpass
  logins, no RBAC) unless/until EE terms are bought or the
  custom-provider route gets written vendor confirmation.
- **Effort estimate:** instance stand-up + provisioning automation
  **3–5 days**; sync bridge (catalogue/stock/orders) **2–3 weeks**;
  storefront on our SPA over the Store API **2–4 weeks** (re-theming
  the vendor's separate Next.js starter is ~1–2 weeks but parks a
  second frontend stack beside the SPA). EE/SSO, if ever bought, is
  configuration — days.
- **Risks:** (1) **the Aug-2026 direction itself** — the vendor has
  shown it will move exactly the operator-critical features (SSO,
  RBAC, audit) behind Enterprise; released MIT versions are
  irrevocable, so today's core is safe, but the feature frontier will
  keep landing EE-first and the platform would feel each move; (2)
  **double truth** — catalogue/order/inventory in two systems makes
  the sync seam a permanent failure surface (mitigated, not removed,
  by ERPNext-as-record + reservations-as-mirror); (3)
  **instance-per-tenant ops multiplication** (Node + PostgreSQL +
  Redis per tenant class) beside the bench; (4) **upgrade cadence** —
  roughly monthly minors is a fast train to track on a second stack;
  (5) **no GL** — Medusa can never be the whole answer for an ERP
  tenant; every order's financial life still crosses the bridge.
- **Scans:** §S8.
- **VERDICT: WATCHLIST.** The MIT commerce core is the strongest in
  its class and licence-clean for SaaS, and it beats Webshop on
  storefront, promotion/pricing and multi-region depth by a wide
  margin — but the SMB-essential path is already covered bench-natively
  by Webshop (USE, Wave 3) with the truth intact and zero new stack,
  while Medusa's adoption price is a second platform, a permanent sync
  seam, and the loss of Rektrs ID / RBAC / audit on that surface
  unless an unpriced Enterprise agreement is bought. Not a NO-GO —
  unlike Cal.diy the vendor stands behind production use and the
  shopper-facing core is fully MIT; not a GO — unlike Documenso there
  is no route that avoids the paywalled surface for staff. **Triggers
  to reopen:** (a) a commerce-led tenant whose storefront/promotion
  needs demonstrably exceed Webshop; (b) written Enterprise terms for
  SSO/RBAC/audit at a sane per-instance price (owner decision); (c)
  written vendor confirmation that a self-built OIDC auth provider on
  the MIT framework is acceptable — which would flip the SSO blocker
  without the EE purchase. Until a trigger fires, no lane is created
  and the Webshop wave proceeds as planned.

---

## §S8 — Scan coverage record (Medusa) + caveats

Standing stack, run read-only over the shallow clone on 2026-11-28
(outputs in `~/workspace/app-census-20261128/scans-standalone/`).
TypeScript stack — **Bandit (Python-only) is N/A**, Semgrep ran
`p/security-audit` only. Medusa's is the cleanest scan result of the
four standalone studies: **zero findings on any production server
surface.**

| App | Semgrep `p/security-audit` | Gitleaks | Assessment |
|---|---|---|---|
| Medusa 2.23.1 | **6 findings** (detect-child-process ×3, jwt-hardcoded-secret ×2, unknown-value-with-script-tag ×1); 8 parse errors | 21 findings | Child-process hits are all in the `create-medusa-app` CLI scaffolding tool (project generator spawning package managers — expected use, not a server surface). Both JWT hits and the script-tag hit are in **integration-test fixtures**. Gitleaks: clusters in integration tests (notification spec ×6, invite/totp/Adyen specs), documentation examples (the asymmetric-encryption doc's example private key + curl examples, `llms-full.txt`, cloud search docs), a Storybook story, and one commented **dummy scrypt hash constant** in `auth-emailpass` (a timing-attack mitigation, labelled as such in source) — **all assessed false positives; no live secret** |

**Caveats (standing):** (1) OCR full review not run — no paid key /
owner ChatGPT sign-in configured; the licence/API-surface manual
review above is the documented substitute. (2) The batch scan script's
gitleaks invocation failed on this environment's CLI (gitleaks 8.30.1
`dir` has no `--no-git` flag); the gitleaks result above is from a
corrected re-run (347.67 MB scanned) recorded in
`scans-standalone/MEDUSA-SUMMARY.txt`. (3) This is a `develop`-branch
snapshot at v2.23.1 (2026-11-27/28); Medusa releases roughly monthly,
so version-specific facts expire — the licence facts (EE file, the
three EE paths, the v2.18.0→v2.19.0 tag archaeology) are the durable
part of this study. (4) Legal characterisations are engineering
readings of the licence texts for planning; a counsel pass is owed
before any EE-adjacent route (notably the self-built OIDC provider
question in §S7.1) is relied on for paying tenants.
