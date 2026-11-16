# Operqon — Paired Portal Designs (INDEX)

**What this is:** six complete design directions for Operqon, built natively in Figma (file `sAecdhy7xp8uyopYgCM76s`, pages prefixed `PAIR —`), each in the design language of a named pair/group of top companies, per the owner's instruction of 2026-11-11. FuseBase is separate (D0), as directed. Every direction covers the **full flow on both surfaces** — customer portal (login · signup · onboarding · dashboard · subscription & billing · invoices · documents · team · support · settings · feature coverage) + **provider console** (overview · tenants · tenant detail · provisioning · approvals · billing & invoices · pricing · users & roles · issues · support · audit log · settings) + the **referral & affiliate programme** (workflow · Refer & earn · affiliate dashboard · affiliate ledger & payouts · console programme management). 173 frames total. Design only — nothing coded; referral/affiliate is a future programme, all its numbers captioned "illustrative — programme not live".

**Reference base:** Phase 1 harvested **94 public portal/product-UI images across all 17 companies** into `hidden_files/portal-references/<company>/` (per-company `SOURCE.md`; root index `hidden_files/portal-references/INDEX.md`). Honest gaps: Copilot (rebranded **Assembly**, Sep 2025) yields only 2 public UI images anywhere; Paddle publishes **no** customer-facing portal screenshots (Billing product UI used); Mercury only 3 public dashboard images (Insights page); HubSpot 4/5 via credited republication of its own screenshots; Salesforce and Deel sets are stylised composites/cards; Zendesk set is agent-workspace UI (its portal articles were rate-limited); Freshdesk is a true customer-portal set; Chargebee is the strongest true portal set.

**Content rules held in all directions:** plans Starter Rs 7,500 / Growth Rs 9,999 / Business Rs 19,999 (users 5/25/100, extra seat Rs 500/500/1,000, 3-day trial); portal persona Rektrs Private Limited (Business, live 8 Nov 2026, admin Asad Choudhary, seats 18/100, workspace `rektrs-private-limited.stage.operqon.cloud`); invoices OPQ-202611-EBABC231 Paid (ref TX-5526658456885) and OPQ-202612-4F7A2C19 Pending due 10 Dec 2026; Faysal Bank with masked IBAN; console MRR Rs 59,997 (3 × 19,999), tenants Rektrs (8 Nov) · demo2 (10 Nov) · Rams Al Kayan (11 Nov 2026); zero ERPNext/Frappe mentions; no lorem ipsum; illustrative rows captioned.

---

## D0 — FuseBase (separate) · 28 frames
Exports: `d0-fusebase/` (01–28 + `00-contact-sheet.png`).

**Borrowed (FuseBase archive `hidden_files/fusebase-archive/` + study set `hidden_files/design-v3-references/fusebase/`):** status pills at the top of every page; onboarding as a **welcome guide** (welcome headline, orientation definition table, honest captions, go-live card on the same frame); **stages chevron tracker** (Verify → Company profile → Pay first invoice → Live; reused for provisioning and the referral workflow); documents/status cards with plain-language states + a "what each status means" explainer; **"Waiting on you"** action lists; **dates-ahead right rail**; widget-card portal home; the referral partner-program portal shape (link/code card, referred-signup tracker, earnings card).

**Screens:** Portal 11 (Login · Signup · Onboarding · Dashboard · Subscription & billing · Invoices · Documents · Team · Support · Settings · Feature coverage) · Console 12 (Overview · Tenants · Tenant detail · Provisioning · Approvals · Billing & invoices · Pricing · Users & roles · Issues · Support · Audit log · Settings) · Referral 5 (Workflow · Refer & earn · Affiliate dashboard · Affiliate ledger & payouts · Console programme).

**Coverage:** Feature-coverage frame maps all 17 portal features + console C1–C12 + referral R1–R4 to the exact hosting frame/element. Nothing dropped. Coordinator eyeball: PASS (one nit — Dashboard workspace KPI caption shortens the URL; full URL on Onboarding). Detail: `hidden_files/design-pairs-notes/d0.md`.

## D1 — Billing pair: Stripe + Paddle + Chargebee · 29 frames
Exports: `d1-billing/` (01–29 + `00-contact-sheet.png`). References: `hidden_files/portal-references/stripe/` (4) · `…/paddle/` (6) · `…/chargebee/` (6).

**Borrowed:** **Stripe** — ink-navy `#0A2540` text/shell, `#F6F9FC` wash, hairline tables with exact right-aligned money columns, blurple `#635BFF` primary, gradient reserved for logo/auth/go-live moments; invoice detail with line items, explicit GST note and TX payment-reference card. **Chargebee** — self-serve depth: Subscription & billing is a genuine **change-plan flow state** (radio plan rows, extra-seat add-on, next-charge banner naming OPQ-202612-4F7A2C19) plus pause/resume/cancel states card. **Paddle** — typographic confidence only (it publishes no portal screenshots): oversized KPI numerals for MRR, seats, prices, referral balances.

**Screens:** Portal 11 · Console 12 · Referral 6 (console programme split into Rules & directory + Approvals & payouts).

**Coverage:** Feature-coverage frame maps every portal, console and referral feature to its D1 screen; nothing dropped. Coordinator eyeball: PASS after **one coordinator-applied Figma fix** (Payment-method "Account title" label/value jam — re-exported and contact sheet recomposed). Detail: `hidden_files/design-pairs-notes/d1.md`.

## D2 — Client-portal pair: Copilot (Assembly) + HoneyBook + Dubsado, with Moxo + SuiteDash · 29 frames
Exports: `d2-clientportal/` (01–29 + `00-contact-sheet.png`). References: `hidden_files/portal-references/copilot/` (2) · `…/honeybook/` (6) · `…/dubsado/` (4) · `…/moxo/` (8) · `…/suitedash/` (5).

**Borrowed:** **Copilot/Assembly** — portal home as an **app grid** (six module tiles) + the **"Your actions"** row with counts. **HoneyBook** — warmth: cream palette (`#FAF6EF`), friendly human microcopy, gentle pending states. **Dubsado** — branded **pill tab bar** under the header on every portal screen + summary-card home. **Moxo** — onboarding as a guided checklist with states; document-collection checklist. **SuiteDash** — all-in-one sidebar grouping (every module in nav from the first screen).

**Screens:** Portal 11 · Console 12 · Referral 6 (programme split into rules/directory + approvals/payouts).

**Coverage:** Feature-coverage frame lists all 17 portal features + 12 console areas with hosting screens; nothing dropped — the app-grid + tab language hosts everything. Coordinator eyeball: PASS (one nit — Dashboard Refer-&-earn tile omits the illustrative caption that all dedicated referral frames carry). Detail: `hidden_files/design-pairs-notes/d2.md`.

## D3 — Enterprise pair: Salesforce + HubSpot + Zoho · 29 frames
Exports: `d3-enterprise/` (01–29 + `00-contact-sheet.png`). References: `hidden_files/portal-references/salesforce/` (7) · `…/hubspot/` (5) · `…/zoho/` (8).

**Borrowed:** **Salesforce Lightning** — navy `#032D60` utility bar (global search, "+ New" action) over an object-nav bar; list views with filter/sort headers; **record pages with highlights panel + related lists**; Path-style stage bars (onboarding, pricing proposal, referral workflow). **HubSpot** — clarity: friendly record titles, one status vocabulary (Paid/Pending/Open/Active) across both surfaces, uncluttered detail panels. **Zoho** — calm density: multi-card screens where every card carries a full sub-function; grouped settings (profile/notifications/security/danger-zone).

**Screens:** Portal 11 · Console 12 + console programme pair (rules/directory + approvals/payouts, on the Console page) · Referral 4 (Workflow · Refer & earn · Affiliate dashboard · Affiliate ledger & payouts).

**Coverage:** Feature-coverage frame lists all 17 portal features + 12 console areas + referral set; nothing dropped — list-view/record language hosts everything natively. Coordinator eyeball: PASS (observations: persona email rendered `asad@rektrs.pk` consistently on both surfaces — live record email is assadchoudharry@gmail.com if strict fidelity is wanted; two left-column cards carry extra bottom whitespace, lane-disclosed). Detail: `hidden_files/design-pairs-notes/d3.md`.

## D4 — Support pair: Intercom + Zendesk + Freshdesk · 29 frames
Exports: `d4-support/` (01–29 + `00-contact-sheet.png`). References: `hidden_files/portal-references/intercom/` (7) · `…/zendesk/` (5) · `…/freshdesk/` (7).

**Borrowed:** **Intercom** — help-centre search hero leading the portal home; conversation list with state badges as the dashboard's first block; a suggested article shown **before** the customer replies. **Freshdesk** — the true customer-portal set: **Submit a ticket** as a first-class form beside the ticket list; requester status vocabulary (Open · Being processed · Resolved · Closed). **Zendesk** — console agent discipline: a genuine **three-pane workspace** (queue views + ticket list | conversation with AI macro suggestion | customer-context panel with timeline), productivity measures (first reply, solved, CSAT), oldest-first queue discipline.

**Screens:** Portal 11 (Support is the deepest portal frame) · Console 12 (Support is the deepest console frame) · Referral 6 (programme split into rules & directory + conversion approvals & payout queue).

**Coverage:** Feature-coverage frame lists all 17 portal features + 12 console areas + referral set, with the honest note that in this direction billing/team sit one click deeper than in a billing-led design. Nothing dropped. Coordinator eyeball: PASS, no coordinator fixes. Detail: `hidden_files/design-pairs-notes/d4.md`.

## D5 — Dashboard pair: Mercury + Ramp + Deel · 29 frames
Exports: `d5-fintech/` (01–29 + `00-contact-sheet.png`). References: `hidden_files/portal-references/mercury/` (3) · `…/ramp/` (6) · `…/deel/` (5).

**Borrowed:** **Mercury** — calm banking minimalism: off-white ground, hairline white cards, **money movement as a clean list with % bars** and right-aligned amounts; segmented pill controls; plan/seats state stated plainly, no upsell chrome. **Ramp** — data density done right: big KPI numerals with delta chips, the **tenant-growth bar chart** as the console Overview centrepiece, alert cards ("Needs attention", "Worth a look"). **Deel** — people clarity: Team summary tiles (active members / pending invites / admins / seats remaining), plain-words role explanations, warm support microcopy.

**Screens:** Portal 11 (Dashboard is the showcase) · Console 12 (Overview is the showcase) · Referral 6 (programme split into rules & directory + approvals & payouts).

**Coverage:** Feature-coverage frame lists all 17 portal features + 12 console areas + 5 referral screens; nothing dropped. Data-viz honesty verified by the coordinator: growth chart is cumulative 0,0,0,1,1,2,3 across 5–11 Nov with a caption saying trials/signups are not growth; affiliate arithmetic is exact to the paisa (10% × Rs 19,999 = Rs 1,999.90; ×3 = Rs 5,999.70). Coordinator eyeball: PASS, no coordinator fixes. Detail: `hidden_files/design-pairs-notes/d5.md`.

---

**Programme record:** `hidden_files/team-design-pairs.md` (inventory, console inventory, referral spec, content rules, phase log with per-direction verdicts). **Per-direction notes:** `hidden_files/design-pairs-notes/d0.md`–`d5.md`. **Build scripts:** `hidden_files/design-pairs-src/d0/`–`d5/`. Status: complete, awaiting the owner's selection.
