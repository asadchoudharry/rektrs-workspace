# CORE — Landing Builder, Custom Pages & Guided Tours

**Status: core-owned (purchased). This is the Phase 1 white-label
workbench (with `settings-admin.md`).**
Sources: Lane 2 (Landing Builder, Onboarding), Lane 4 §§A–B, Lane 5 §§4, 10.

## Landing Builder
- Admin UI separate from the main sidebar. Pages: Landing / Pricing /
  Blog / Channels / Contact. Sections available: Header, Hero, Trusted
  By (Logos), Channels, Shared Inbox, Automation, Features, AI
  Highlights, App Preview, Messaging, Workflows, Pricing, FAQ,
  Testimonials, Video, Rich Text, CTA, Footer.
- Draft / Publish / History (versions kept); per-language SEO fields.
- Data: `landing_contents`, `landing_drafts`, `landing_items`,
  `landing_sections`, `landing_versions`. Uploads swept by
  `landing:sweep-uploads` (daily).

## Custom Pages
- Admin > Custom Pages: Terms / Privacy / Cookie published in demo;
  New Page. Versioned content: `custom_pages`, `custom_page_contents`,
  `custom_page_versions`, `pages`.
- Public pages also accept Custom Code (CSS / Head / Footer) from
  Settings — public pages only, never the app (Lane 4 §D).

## Guided Tours & Onboarding
- Default tenant tour: 4 steps. Demo admin shows **8 active tours**
  (Dashboard 12 steps, Campaigns 5, Channels 5, Flows 4, AI Agents 4,
  API Keys 4, Messenger Overview 5, Status Page 5).
- Admin creates tours per audience / per plan; only one active tour per
  page+audience.
- Onboarding checklist: plan → email → contact → channel → **GSM
  modem** → first message → invite. Tenant Overview in demo ran a
  10-step welcome tour.
- Data: `onboarding_flows`, `onboarding_steps`,
  `onboarding_flow_contents`, `onboarding_step_contents`,
  `user_onboarding_progress`.

## Keep / extension notes
- Core-owned. Phase 1 white-label work = Landing Builder content +
  Settings branding + tenant Branding defaults; **no code changes**
  (Lane 5 §10 verdict: product name is configuration —
  `APP_NAME`/`site_name` — and "Powered by" lines render the operator's
  own site name, removable per plan via the White Label feature).
- The owner's white-label kit (brand assets) lands here when supplied.
