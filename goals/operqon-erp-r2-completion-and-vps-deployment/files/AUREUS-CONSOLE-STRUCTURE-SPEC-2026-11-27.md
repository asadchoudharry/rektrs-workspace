# Aureus ERP SaaS Console — Structural Spec for the Operqon Provider Console

Source: full read-only assessment of the live demo at https://saas-demo.aureuserp.com/saas
on 2026-11-27 (owner's Chrome). Every screen, menu, table, form and overlay below was
visited and recorded. Owner's instruction: our admin/provider console is to be organised
exactly this way — where each thing sits, in which order, with which pattern.

Scope note: this spec governs STRUCTURE and ORGANISATION (shell, navigation, screen
patterns, tokens). Product names/labels adapt to Operqon (Tenants, Plans, Apps/Plugins,
Gateways, etc. map 1:1 onto the console concepts already assigned to Cursor today).
The floating "LIVE DEMO" bar is a demo-only artefact — do NOT build it. The top promo
banner is a marketing element — build the slot, content is ours to decide.

---

## 1. Global shell (every screen)

1. **Top promo banner** (full width, above everything): vivid violet→indigo gradient;
   cloud icon + pill badge ("CLOUD HOSTING") + one line of text + white CTA button
   ("View plans →") at the right.
2. **Topbar** (near-black, left→right): logo mark at far left (links home) → global
   Search field centre-right (magnifier icon, placeholder "Search") → bell
   "Notifications" icon button → user avatar button (initials) at far right.
   - Avatar dropdown (dark card, anchored top-right under the avatar): user name +
     role line, a "Version x.y.z" line, a **Theme** group with 3 icon buttons
     (Light / Dark / System — System is the default), then "Sign out" in red.
   - Notifications opens a **right-side drawer** over a dimmed/blurred backdrop:
     heading "Notifications", Close × top-right, empty state = bell-slash icon +
     "No notifications" + "Please check again later."
3. **Left sidebar** (~300px, near-black, full height, own vertical scroll, no collapse
   button): first item ungrouped — **Dashboard**. Then groups, each with a small muted
   ALL-CAPS group label and flat items beneath (NO expandable sub-menus anywhere):
   - TENANTS: Tenants, Dumps
   - BILLING: Subscriptions, Payments, Manual invoices, Gateway events, Exchange rates
   - CATALOG: Plans, Plugins
   - CONTENT: Landing pages, Mail templates, Site builder
   - PLATFORM: Super admins, Database servers, Health, Settings
   Active item: dark blue-grey filled background + blue text/icon + thin blue vertical
   bar at its left edge, rounded corners. Inactive: muted grey text. Hover: slightly
   lighter dark fill.
4. **Content area**: dark-grey background, ~32px padding, max width ~1130px,
   left-aligned. Every page opens with a large bold **H1** (page title) + one smaller
   muted one-line description directly beneath. No breadcrumb on list/dashboard pages;
   breadcrumbs appear on detail/edit pages only.

## 2. Design tokens (verbatim from the demo's Brand settings)

- Primary **#2D5BE3** · Success **#12A37F** · Warning **#D97706** · Danger **#DC2626**
  · Info **#2563EB** · Neutral **#5C6880**
- Surfaces: sidebar/topbar near-black (#121417 range); page background slightly darker
  than cards; cards dark grey (#2a–#2e range), 1px subtle border, ~10–12px radius,
  flat (border-defined, almost no shadow).
- Type: H1 ~28–30px bold white; card headings ~15–16px semibold white; body ~14px;
  page descriptions ~13–14px muted; table headers ~11–12px UPPERCASE letter-spaced
  muted grey; cell sub-lines ~12px muted.
- Icons: thin outline (Lucide-style), ~16–18px, muted grey; coloured only inside KPI
  cards (tinted rounded square) and status pills.
- Buttons: primary = solid blue, white text, ~8px radius, ~36px tall; outline =
  dark fill + 1px grey border; danger = solid red; "Edit" = blue text link + pencil
  icon; "Delete" = red text link + trash icon.
- Inputs: dark fill, 1px grey border, ~8px radius, ~36–40px tall, label ABOVE the
  field (small semibold); selects show a chevron; date fields show a calendar icon;
  booleans are iOS-style switches (blue on / grey off); multi-values are tag chips
  with × plus a combobox/add box.
- Status pills: small, fully rounded, tinted background + matching coloured text.
  Green = Active / Succeeded / OK / Connected · Amber = Not registered · Grey =
  Base / Subdomain · Dark-red/maroon = Owner.
- Booleans in tables are ICONS, never text: Yes = green circle + white check;
  No = red circle + white ×.
- Modals: centred, dark, ~860px wide, ~12px radius, internal scroll; title +
  description at top, Close × top-right; footer = Cancel (left, grey) + primary
  action (right, blue). A brief "Loading…" state appears on open.
- Dropdowns/menus: dark card, 1px border, ~8px radius, icon + label items,
  destructive items red, anchored directly below the trigger.
- Tabs: segmented pill control (active = filled dark blue-grey pill + blue text).
- Empty states: centred inside the table card — bold heading ("No X yet") + one
  muted explanatory line.
- Density: dense admin; ~16–24px gaps between cards.

## 3. The list-screen pattern (applies to 12 screens)

H1 + description → **toolbar row**: "Filter" button with a count badge (left; opens a
dropdown card: heading "Filters", red "Reset" link top-right, filter fields, blue
"Apply filters" button at the bottom) → search box (centre; placeholder
"Search <plural>…") → primary "+ New / + Add / + Create" button (right, ONLY where
creation is allowed) → optional **KPI stat strip** (small cards) directly under the
toolbar → **one table card**:

- First column: row-selection checkbox (select-all in the header).
- Column headers uppercase muted; sortable columns show ↓.
- First data column = record name as a BLUE LINK (opens detail/edit); secondary facts
  sit as a smaller muted sub-line under the main value.
- Last column: ACTIONS.
- Footer inside the card: "<n> result(s)" left; pagination right (page numbers +
  Previous/Next, disabled at the ends). 10 rows per page where pagination exists.
- Row hover: slightly lighter fill.

Screens and their exact columns (in order):

| Screen | Toolbar extras | Columns |
|---|---|---|
| Tenants | + New tenant (opens modal, §5) | ☐ / TENANT / OWNER / PLAN / STATE / DOMAIN / CREATED↓ / ACTIONS (View icon, Sign-in-as-owner icon, ⋯ Actions menu) |
| Dumps | no create (made from a tenant) | ☐ / TENANT / REASON / SIZE / CREATED↓ / EXPIRES / PURGED |
| Subscriptions | KPI strip: Active / Past due / Cancelled; no create | ☐ / TENANT / PLAN / STATE / GATEWAY / PERIOD END / CREATED↓ |
| Payments | KPI strip: Succeeded / Failed / Refunded; no create | ☐ / TENANT / GATEWAY / STATUS / AMOUNT / WHEN↓ / ACTIONS (⋯) |
| Manual invoices | no create (made from a tenant) | ☐ / TENANT / NUMBER / STATUS / AMOUNT / ISSUED↓ / ACTIONS |
| Gateway events | no create | ☐ / GATEWAY / TYPE / STATUS / RECEIVED↓ / ACTIONS |
| Exchange rates | KPI strip: Base currency card; outline "Update rates" + blue "+ Add rate" | ☐ / CURRENCY / RATE / SOURCE / UPDATED↓ / ACTIONS (Edit/Delete links) |
| Plans | + Create plan (form page, §6) | ☐ / PLAN / PRICE / BILLING PERIOD / TRIAL DAYS / TENANTS / ACTIVE / FEATURED / CREATED↓ / ACTIONS (Edit/Delete) |
| Plugins | KPI strip: Total / Active / Inactive; no create | ☐ / PLUGIN / TYPE / DESCRIPTION / TENANTS / VERSION / STATUS / CREATED↓ / ACTIONS (Edit/Delete) |
| Landing pages | + Create page | ☐ / TITLE / SLUG / STATUS / UPDATED↓ / ACTIONS |
| Mail templates | no create | ☐ / TEMPLATE / KEY / LOCALE / UPDATED↓ / ACTIONS (Edit/Delete) |
| Super admins | + New admin | ☐ / NAME / EMAIL / ROLE / MFA / CREATED↓ / ACTIONS (Edit/Delete) |
| Database servers | + Add server | ☐ / NAME / HOST / PORT / TENANTS / STATUS / CREATED↓ / ACTIONS (Edit/Delete) |
| Health | NO toolbar at all | one card "Checks": NAME / STATUS (green "OK" pills) — Database, Cache, Queue, Storage, Mail, Tenant provisioning, Payment gateway |

## 4. Dashboard (two tabs, one screen)

H1 "Dashboard" + description; top-right a segmented pill control **Revenue | Operations**.

**Revenue tab**: a full-width filter card (two labelled controls side by side:
"Date range" read-only textbox with calendar icon; "Currency" select) → **9 KPI cards
in a 3×3 grid** — each card: tinted rounded-square icon top-left, large bold value,
small % change with ↗/— arrow, muted label beneath the value, thin coloured
sparkline/bar along the bottom edge. (Demo metrics: Monthly recurring revenue, Gross
revenue, Net revenue, Refunds, Open disputes, Lost disputes, Failed payments, New paid
tenants, Churn.) → 2-column chart row (wide "Net revenue" line/area card with H2 +
description; "Revenue by gateway" bar card) → second chart row ("Plan distribution"
donut; "Signups vs conversions") → two full-width table cards ("Recent payments",
"Recent refunds and disputes") with the standard columns and in-card empty states.

**Operations tab**: no filter card. **4 KPI cards in one row** (Active tenants, Active
subscriptions, New this week, On trial) — each also carries a small "Last week: n"
line → 2-column row: wide area chart "Tenants and revenue" (two-series legend) +
"Plan distribution" donut (centre total + legend) → full-width "Recent tenants" table
card (TENANT / PLAN / STATUS / DOMAIN / CREATED; "1 result" top-left, "Open" link
top-right) → 2-column row: "Recent payments" table card ("Open" link top-right) +
"Platform health" card (plain 2-column definition list, no table headers) → bottom
2-column row: "Need attention" card (icon + status text) + "Quick links" card
(blue links with icons).

## 5. Detail screen + create modal (Tenants)

**Tenant detail**: breadcrumb "Tenants > <Name> > View" → H1 "View <Name>" +
description → top-right actions: outline "Sign in as owner", solid red "Lock",
outline "⋯ Actions" → **pill tab bar** (Overview | Subscription | Domains | Dumps |
Activity; tab switches reload the panel with a brief "Loading…"):
- Overview: 2-column layout — left column stacked detail cards ("Tenant", "Owner"),
  right column one card ("Dates"); each card is a definition list (small bold muted
  term, value beneath; pills/icons inline where the value is a status/boolean).
- Subscription / Domains / Dumps / Activity: tables in the same card shell with the
  columns recorded in the assessment (Subscription: PLAN/STATE/GATEWAY/PERIOD END/
  Action-"Open"; Domains: DOMAIN/TYPE/PRIMARY/VERIFIED; Dumps: REASON/SIZE/CREATED/
  EXPIRES/PURGED; Activity: TYPE/MESSAGE/ACTOR/WHEN).

**Create = modal, not a page** (except Plans and Landing pages, which open a form
page like §6). New-tenant modal fields, in order: Tenant name; Subdomain (with the
platform domain as a suffix); Plan (select); Billing period (select); Owner name;
Owner email; Payment reference; Paid on (date); Paid amount (number); Currency;
switch "Account is locked"; Owner password (placeholder "Leave blank to
auto-generate"). Footer: Cancel (left) / "Create tenant" (right).

Tenant row **⋯ Actions menu** items, in order: Lock (red), Change owner, Resend
sign-in link, Assign private plugin, Dump now, Restore (amber), Record payment.

## 6. Form/edit screen pattern (Plan edit is the reference)

Breadcrumb "Plans > <Name> > Edit" → H1 "Edit <Name>" → top-right actions: outline
secondary action ("Roll out to existing subscribers") + solid red "Delete" →
**two-column layout**: main column (wider, left) holds the primary section cards;
right column holds secondary cards. Each card = bold heading + muted description +
fields with labels above. Footer bar: "Save changes" (right, blue) + "Cancel" (left).

Plan edit cards, in order — main column: **Plan details** (Name; Slug; Sort order;
Description; switch "Plan is active"; switch "Featured plan") → **Prices** (small
table: CURRENCY / MONTHLY PRICE / YEARLY PRICE / ACTIONS, with blue "Add currency"
button bottom-left) → **Plugins** (tag chips with × + combobox "Select a plugin to
add") → **Add-ons** (small table NAME / PRICE / ACTION + "Add add-on" button).
Right column: **Visibility and terms** (switch "Is visible"; Trial period (days);
Grace period (days); Billing cycles; Refund policy; switch "Proration enabled";
switch "Public plan"; switch "Allow multiple subscriptions") → **Features** (tag
chips + combobox + "Add feature" button).

Rules: booleans are ALWAYS switches; multi-values are ALWAYS tag chips + combobox;
money matrices are ALWAYS small tables; nothing auto-saves — every form has an
explicit Save/Create button.

## 7. Settings pattern (5 sub-pages)

Layout: **left sub-navigation column** (~300px, a dark card listing the sub-pages
with icons — Billing, Lifecycle, Gateway, Mail, Brand; active item uses the same
highlight as the sidebar) + right column (~2/3) of stacked form cards. Each card:
bold heading + muted description → 2-column field grid (label above field) → the
card's OWN footer bar with a blue Save button bottom-right (labelled per page:
"Save settings", "Save lifecycle settings", "Save gateway settings",
"Save mail settings", "Save brand settings").

- **Billing**: cards "Billing" (Default currency; Default plan; Default billing
  period; Trial days; Grace period (days); switch Enable taxes; Tax rate (%); Tax
  label) · "Invoices" (Invoice prefix; Invoice next number; Invoice footer textarea;
  switch Send invoice emails) · "Payments" (Payment methods checkboxes; switch Allow
  manual payments; switch Auto-retry failed payments; Retry attempts; Retry delay
  (hours)).
- **Lifecycle**: cards "Trial" (Trial length (days); switch Require card for trial;
  switch Trial ends at midnight) · "Locking and suspension" (Lock after failed
  payments; Suspend after (days); Delete after (days)) · "Retention" (Keep dumps for
  (days); Keep activity logs for (days); switch Allow tenant restore) ·
  "Notifications" (tag inputs: Notify on lock; Notify on payment failure).
- **Gateway**: one card per gateway (Stripe, Razorpay) with the same anatomy:
  description line; definition list — Status (pill), Webhook (pill), Webhook
  endpoint (URL + copy button), Webhook secret; "Missing events" as code chips;
  "Required events" as code chips each with a copy button; footer blue button
  "Register webhook". Plus a "Partner account" card (switch "Use partner account";
  select partner account; "Connect" button).
- **Mail**: card "Mail" (From address; From name; Reply-to address; switch Send mail
  as HTML) · card "SMTP" (Host; Port; Username; Password; Encryption select; switch
  Verify peer; grey outline "Send test email" button bottom-right).
- **Brand**: card "Logo" (upload dropzone: "Upload a file or drag and drop", "PNG,
  JPG, GIF up to 10MB", "Browse files" button; Preview row with current logo +
  filename) · card "Colours" (6 colour fields, each a swatch + hex text input —
  the §2 tokens) · card "Theme" (three radio-style cards: Light / Dark / System) ·
  card "Favicon" (same dropzone + preview pattern).

## 8. Site builder pattern

Split view: left ~55% editor card, right ~45% **live preview** (iframe of the public
site). The editor card has a section bar at its top (General | Features | Sections |
Footer); each section = heading + muted description + plain fields (label above).
Saving sits in a footer below the fold — keep one persistent Save affordance visible.

## 9. Mail templates (content inventory)

The demo ships exactly 10 templates, keyed: auth.verify-email ("Verify your email
address"), auth.reset-password, tenant.welcome, tenant.locked, tenant.unlocked,
tenant.restored, billing.payment-succeeded, billing.payment-failed,
billing.subscription-cancelled, billing.subscription-expired — all locale "en".
Adopt the same keying convention (namespace.key) for our templates.

## 10. Route map (structure reference)

`/saas` (Revenue) · `/saas?tab=operations` · `/saas/tenants` · `/saas/tenants/:id`
(detail; tabs via query) · `/saas/dumps` · `/saas/subscriptions` · `/saas/payments`
· `/saas/manual-invoices` · `/saas/gateway-events` · `/saas/exchange-rates` ·
`/saas/plans` · `/saas/plans/:id/edit` · `/saas/catalog-plugins` (note: NOT
`/saas/plugins`) · `/saas/landing-pages` · `/saas/mail-templates` ·
`/saas/site-texts` (labelled "Site builder") · `/saas/super-admins` ·
`/saas/db-servers` (labelled "Database servers") · `/saas/health` ·
`/saas/settings/manage-billing-settings` · `manage-lifecycle-settings` ·
`manage-gateway-settings` · `manage-mail-settings` · `manage-brand-settings`.

## 11. Build rules for Cursor (summary)

1. One shell for every screen (§1); grouped flat sidebar, no sub-menus; active item
   = blue-grey fill + blue text + left blue bar.
2. Every list screen follows §3 exactly — same toolbar order, same table anatomy,
   same footer; create buttons only where the pattern allows them.
3. Dashboards follow §4 (segmented Revenue|Operations tabs; KPI card anatomy fixed).
4. Detail screens follow §5 (breadcrumb, pill tabs, definition-list cards).
5. Create opens a modal (§5); edit opens the two-column form page (§6).
6. Settings follow §7 (left sub-nav + per-card Save). Brand settings own the tokens.
7. Tokens in §2 are law: colours, radii, type scale, pill/icon/switch conventions.
8. Do NOT copy: the floating LIVE DEMO bar; demo data; the Aureus name/logo.
9. Not covered by this pass (verify before building those parts): responsive
   breakpoints, the light theme's exact rendering, the Plan/Landing-page create
   forms, the Mail-template editor, Site-builder sections below "General".
