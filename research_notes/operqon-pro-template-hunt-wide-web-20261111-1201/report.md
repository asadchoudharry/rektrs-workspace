# OperQon Pro Template Hunt — Wider Web (Beyond Envato)

Baseline (one line, per brief): the exhaustive Envato Elements / CodeCanyon / ThemeForest search already produced a best candidate of only 8.5/10; nothing from those marketplaces is re-reported below. (Note: WrapPixel/AdminMart's premium admins turned out to be ThemeForest-sold, so they are excluded on the same basis.)

All prices, page lists and claims below are as shown on the product pages read on **2026-11-11**. Flags: **verified live** = read in the research browser window; **index** = read via web-index fetch of the product/vendor page. Scores are honest judgements against the ClickUp / Tailscale / Snowflake / Workday polish bar, weighing (a) visual-system quality and (b) how completely the required screens are actually pre-built, as evidenced — not assumed.

## Summary

- **Nothing found reaches 9.5–10/10 in any of the three categories.** The ceiling outside Envato is ~9.0–9.1, and it is reached only by *design systems* (Untitled UI) and one Framer site system (AlteraOS) — not by finished, purpose-built portal/console products.
- **Customer portal is the real gap.** No vendor sells a complete customer-portal kit (auth + dashboard + subscription + billing/invoices + documents + team + tickets + settings) at top-tier polish. The closest *coverage* is a brand-new, unreviewed $24 React template (Saasly); the closest *polish* is Untitled UI, where the portal must be assembled from generic dashboard/settings examples.
- **Provider console:** Saasly is also the only product found anywhere that literally lists a tenant table, tenant detail, operator MRR dashboard and plan manager. Runner-up for the money/billing surface is Shadcnblocks' Admin Kit (Payments app: MRR dashboards, subscriptions, invoices, webhooks).
- **Landing page is the healthiest category:** AlteraOS (Framer, $149), Saasplex X (Webflow, $129) and Untitled UI's marketing pages (Figma/React) all land at 8.8–9.1.
- **Important dead end:** Tailwind Plus (formerly Tailwind UI) including the **Catalyst** UI kit is **no longer buyable** — it closed to new customers on 9 Sep 2026 when Tailwind Labs joined Shopify. It cannot be the answer, however good it was.

---

## Findings — 1. Customer Portal template/kit

Required: sign-in/sign-up, customer dashboard, subscription & plan management, billing/invoices/payments, documents/files, team/user management, support tickets, account settings.

### 1.1 Saasly — SaaS Business Admin Dashboard Template — **8.7/10** (best coverage; unproven)
- **Seller / store:** codeflicks, on Wrapmarket (formerly WrapBootstrap) — **Price:** $24 Standard License (+$6 support extension to 1 year) — **Format:** code, React Router 7 / React 18, TypeScript, Vite, Tailwind CSS 3, Recharts
- **Link:** https://wrapmarket.com/item/saasly-saas-business-admin-dashboard-template-W0D1617T5 — **verified live**
- **Evidenced coverage (nearly the whole brief):** Authentication (login w/ social+SSO, register, forgot/reset, 2FA, email verification, lock screen); main dashboard (KPIs, MRR trends, plan distribution, system health); **Billing & Subscriptions** (current-plan dashboard with usage meters, upgrade/downgrade flow, side-by-side plan comparison, payment methods, billing address, invoice list, invoice detail with PDF preview, payment history, coupons/credits); usage/plans (usage overview, limits, plan features matrix, trial status); **Members & Teams** (member table, invite flow with seat counter, member detail, teams, RBAC/roles matrix); profile & account settings (branding, custom domain, notifications, SSO/SCIM security); **Support** (help center, knowledge base, submit-ticket form, my-tickets list, live chat); audit/activity log.
- **Gaps:** no dedicated **documents/files** page is evidenced (only AI search "across documents" and invoice PDF preview).
- **Quality evidence — weak, and it caps the score:** version **1.0.0, initial release 21 May 2026**; Reviews tab read live states **"No customer reviews yet"**; no sales count shown; download listed as just **537.8 KB .zip**, oddly small for the claimed 80+ pages. Mitigants: "Quality reviewed by Wrapmarket", 6-month support, 30-day refund eligibility. The live preview screenshot shows a clean, dense, professional indigo/slate UI (Jakarta Sans/Inter) — polished but generic; dark mode is only "tokens ready to be activated", not a finished theme.

### 1.2 Untitled UI Figma PRO — **9.0/10** (best polish; portal must be assembled)
- **Seller / store:** Untitled UI, own store — **Price:** $129 Solo (was $149); $399 Studio (8 users); $999 Business (20) — **Format:** Figma design system
- **Link:** https://www.untitledui.com/figma — **index** (full vendor page)
- **What it is:** 10,000+ components/variants, 900+ styles/variables, **420+ page examples** described as dashboards, settings pages and marketing sites, 2,000+ icons, one-click dark mode via variables, 100% Auto Layout 5.0, WCAG-minded, updated for Figma Config 2026, lifetime updates. Vendor claims 380,000+ designers and (in its own roundup) 3,650+ 5-star reviews.
- **Honest limitation:** the product page does **not** enumerate billing, invoice, subscription, ticket or file-manager pages. You get the highest-quality raw system in this hunt — closest to the reference class visually — but the portal flows are yours to compose from examples. Score is 9.0 as a portal *solution*, 9.3 as a design system.

### 1.3 Untitled UI React PRO — **9.0/10** (same system, in code)
- **Seller / store:** Untitled UI, own store — **Price:** from $349 Solo (was $499) — **Format:** React 19 + Tailwind CSS v4 + TypeScript + React Aria code library, Next.js starter kits, synced with the Figma kit (sold separately)
- **Link:** https://www.untitledui.com/react — **index** (full vendor page; page-example breakdown from the vendor's own comparison articles, figures stated as checked against primary sources 5 Nov 2026)
- **Evidenced:** 250+ page examples — 40 dashboards, 40 settings pages, 40 informational, **45 login/sign-up/verification pages**, plus 105 marketing pages; 5,000+ components/sections; dark mode via CSS variables. Same caveat as Figma: no named subscription-billing/ticket/files portal flow.

### 1.4 Vibra UI — **8.5/10** (most portal-literate page set; note: FREE, not premium)
- **Seller / store:** Vibra UI, own site — **Price:** **$0** (positioned as a free shadcn/ui kit; included because its coverage is uniquely on-brief — it is not a premium purchase) — **Format:** React/Next.js + Tailwind (shadcn/ui) source, installed via shadcn CLI; 13 dashboards, 109 pages, 207 components; last update shown 12 Oct 2026
- **Link:** https://www.vibraui.com/dashboards — **index** (full page)
- **Evidenced (29 shared pages):** sign-in, sign-up, forgot/reset, verify code, magic link, passkey sign-in, 2FA setup, accept-invitation, setup wizard, welcome/onboarding; **workspace settings** (workspace/brand, **members**, **billing & usage**, API keys, notifications, danger zone); **plan picker** (current tier with seats filled, monthly/yearly pricing, change-confirmation dialog); **invoices & payment methods** (billing history per workspace, invoice download, payment wallet); **metered usage** (seats/requests/tokens vs tier, overage forecast); profile/security/notification settings; **audit log** with diff viewer.
- **Gaps:** no support tickets, no documents/files evidenced; the dashboards themselves are verticals (ecommerce, finance…). No ratings/sales evidence; shadcn-default aesthetic is clean but undifferentiated.

### 1.5 Dashly X — **8.3/10**
- **Seller / store:** BRIX Templates, Webflow Marketplace — **Price:** $129 — **Format:** Webflow template (+ Figma file on request after purchase)
- **Link:** https://webflow.com/templates/html/dashly-x-dashboard-website-template — **verified live** (full page list); price via marketplace structured data (**index**)
- **Evidenced (45+ pages):** Dashboard v1–3, **Invoices**, **File Manager**, **Support**, Analytics, Logs, Messages, Contacts/Companies, Projects/Tasks/Board, Profile v1–3, **Settings v1–3 (5 views each)**, Pricing v1–3 (Ecommerce), Help Center (CMS), Sign Up, Log In, Email Confirmation, Reset Password, Notifications, Integrations (CMS).
- **Gaps:** no subscription/plan-management or payment-method pages; no explicit team/user-management page. Webflow is also a platform lock-in for a real ERP portal front-end.

### 1.6 AlignUI Figma — **8.6/10** (system score; portal assembled from templates)
- **Seller / store:** AlignUI, own store — **Price:** $119 Personal / $349 Startups (5 users), one-time, lifetime updates — **Format:** Figma design system v2.0 (7,800+ components, 1,200+ assets, 80+ widgets, templates included); matching React + Tailwind code library sold separately (from $299 per third-party reads of vendor pages)
- **Link:** https://figma.alignui.com/pricing — **verified live**
- **Evidenced:** dashboard-first system with sector templates (HR, Finance & Banking, Marketing & Sales, AI). The Finance & Banking template lists transactions/cards plus **4 authentication and 7 settings screens** (index, from a review that read the vendor page 14 Oct 2026). No subscription, invoice, ticket or team product pages are named — like Untitled UI, this is a foundation, not a portal.

### 1.7 Beyond UI — **8.4/10**
- **Seller / store:** Beyond UI, own store — **Price:** Standard $119; Premium $249 (adds 6 industry templates) — **Format:** Figma (9,000+ components, dark mode, tokens; CSS/Tailwind token files included)
- **Links:** https://www.beyondui.design/ and https://www.beyondui.design/pricing — **index**
- **Evidenced:** Starter SaaS templates — Dashboard, Messages, Email, Calendar, **Settings, Authentication**; Premium industry templates include a Fintech template listing **Invoices** (with Accounts/Cards/Transactions/Spending/Budgets) and a Project Management template listing Documents/Teams. 500+ landing-page sections (see §3).
- **Gaps/evidence:** no subscription/plan or ticket flows evidenced; homepage shows 5/5 from only **2 reviews** — promising but thin social proof.

### 1.8 Minimal UI Kit (Pro) — **8.4/10**
- **Seller / store:** Minimal UI Kit, via the official MUI Store — **Price:** $69 Standard (Next.js, JavaScript), $129 Standard Plus (TypeScript), $599 Extended (needed to charge end users) — **Format:** Next.js 16 + Material UI v9 code (Figma files in Pro per secondary sources)
- **Link:** https://mui.com/store/items/minimal-dashboard-free/ (free version; Pro sold via the same store) — **index** (pricing/page list from a Nov-2026 roundup that read the store pages)
- **Evidenced pages:** user management, **invoice**, **file manager**, mail, chat, calendar, Kanban, plus analytics/banking/booking dashboards and full auth/error sets — unusually portal-relevant breadth. MUI's Material look is a step away from the Tailwind/reference aesthetic, hence the score.

### 1.9 Shadcn UI Kit (Bundui) — **8.2/10**
- **Seller / store:** Bundui, shadcnuikit.com — **Price:** Pro $79 one-time (was $129); Team $199; Enterprise $499 — **Format:** Next.js 16 / React 19 / Tailwind v4 / TypeScript + included Figma file
- **Link:** https://shadcnuikit.com/pricing — **index**
- **Evidenced:** 16 admin dashboards, 550+ blocks; shared login/register, profile, settings, pricing, onboarding, notifications, empty/error pages. Broad and cheap, but dashboards are generic verticals — no evidenced subscription/ticket/files portal flow.

### 1.10 UI8's best relevant entry: Revu — **7.0/10**
- **Seller / store:** WhiteUI Store on UI8 — **Price:** $39 — **Format:** Figma + Sketch
- **Link:** https://ui8.net/whiteuistore/products/revu-uikit-for-saas-startups — **index**
- 187 pages across 19 categories including Login/Register, Dashboard, Team, File Manager, Support, Settings, Reports — on-brief categories, but the kit dates from **Dec 2022** (last noted update Dec 2024) and shows it. The wider UI8 trawl returned only vertical kits (hospital, construction, LMS, fitness) — **no SaaS portal or operator-console kit on UI8 qualified.**

---

## Findings — 2. Provider Admin Console template/kit

Required: overview (MRR / tenant growth / churn), tenant directory & detail, provisioning queue, plans/pricing management, billing/invoice oversight, system health, audit log, platform settings.

### 2.1 Saasly (Super Admin Panel) — **8.7/10** — the only literal match found
- Same product as §1.1 ($24, Wrapmarket, React/Tailwind code, **verified live**): https://wrapmarket.com/item/saasly-saas-business-admin-dashboard-template-W0D1617T5
- **Evidenced Super Admin section:** **all-tenants table with impersonation, tenant detail page, MRR dashboard for the SaaS operator, subscription analytics with funnel, plan manager, coupon manager**, email template editor, feature-flag controls with rollout targeting, maintenance-mode scheduler. Supporting evidence elsewhere in the kit: main dashboard shows **system health**; revenue reports cover **MRR/ARR/ARPU/NRR** and cohort retention; AI Insights surface **churn risks**; tamper-evident **audit/activity log**, login history, API call log; platform-level settings (branding, custom domain, SSO/SCIM, security).
- **Gaps:** a **provisioning queue** is not named (closest: pending workspace invitations, maintenance scheduler, feature flags); churn is via cohort/AI-insight surfaces rather than a headline churn dashboard (the preview dashboard does show a churn-rate KPI). And the §1.1 quality caveats apply in full: v1.0.0, zero reviews, $24, tiny download — coverage is 10/10 on paper, provenance is not.

### 2.2 Shadcnblocks Admin Kit — **8.5/10** (strongest billing/MRR surface from an actively maintained vendor)
- **Seller / store:** Shadcnblocks, own store — **Price: conflicting** — templates page lists the Admin Kit at **$129** and Premium (all templates + blocks + Figma kit) at **$299**; the product-page FAQ states the Admin Kit "ships with Premium ($299) — not as a separate add-on". Budget $299 until clarified. — **Format:** Next.js 16 / React 19 / Tailwind 4 / TypeScript / shadcn/ui code, light+dark
- **Link:** https://www.shadcnblocks.com/admin-dashboard — **index** (full page)
- **Evidenced:** 219 pages, 6 sub-apps. **Payments app (36 pages): MRR dashboards, subscriptions, invoice composers, webhook delivery logs with retry, transactions** — "shaped like Stripe". Developer console (API keys, webhooks, event logs); shell pages with user **role tables**, workspace settings, auth and error states. Updated monthly; changelog shows **v2.4.0, 29 Sep 2026**.
- **Gaps:** it is a *payments/product* admin, not a *tenant* admin — no tenant directory/detail, no plan manager, no system-health or audit-log page by those names.

### 2.3 Apex Dashboard (DashboardPack) — **8.3/10**
- **Seller / store:** DashboardPack, own store — **Price:** from $69 (Developer $149 / Lifetime $349 tiers reported) — **Format:** Next.js 16 / React 19 / Tailwind v4 / shadcn/ui code (other framework editions exist)
- **Link:** https://dashboardpack.com/compare-templates/ — **index**
- **Evidenced:** 216 prerendered pages, 12 dashboard variants including a **SaaS** variant, full CRUD, file manager, chat/mail/kanban/calendar apps, auth with 2FA, **RBAC permission matrix**, theme customizer, dark mode. A solid generic operator back-office — but no tenant, MRR, plan-management or audit-log pages are evidenced, so the console brief would still be custom work.

### 2.4 Build-it-from-a-system options — Untitled UI **8.5/10** / AlignUI **8.4/10** (console use)
- Same products as §1.2/§1.6. Both give dashboard/table/chart/settings components at the highest visual quality in this hunt, and either could *become* a 9+ console — but neither ships tenant, provisioning, churn or system-health screens. Scored here for what is buyable today, not what could be built.

### 2.5 Minimal UI Kit (Pro) — **8.2/10** (console use)
- Same product as §1.8. Breadth (users, invoices, orders, file manager, chat/mail) suits a generic back office; no SaaS-operator metrics (MRR/tenants/churn) evidenced.

**Console verdict:** there is exactly **one** product (Saasly) that even claims the full operator brief, and it is unproven. No 9+ console kit exists on the open web as a finished product.

---

## Findings — 3. Landing Page / Marketing template

Required: hero with product visuals, features, pricing with monthly/yearly toggle + comparison, testimonials, FAQ, blog.

### 3.1 Untitled UI marketing pages (Figma $129 / React from $349) — **9.1/10**
- Same vendor as §1.2/§1.3 — **index**. React PRO evidences **20 landing pages, 10 pricing pages, 10 FAQ pages, 10 blog + 10 blog-post pages**, about/contact/team/legal, and 428 marketing sections (hero, pricing tables etc. per vendor comparisons); Figma PRO includes the equivalent marketing-site examples and sections. Highest design polish available for a SaaS marketing site, and it shares one system with the portal/console work — a real strategic advantage. Caveat: these are page *examples/sections* in a library, not one finished ERP marketing site; the pricing toggle/comparison exists at section level rather than as one evidenced finished pricing page.

### 3.2 AlteraOS — **9.0/10** (best single finished Framer buy)
- **Seller / store:** Divplate, Framer Marketplace — **Price:** $149 — **Format:** Framer template (Figma project included in the Premium License), lifetime updates & support
- **Links:** https://www.framer.com/marketplace/templates/alteraos/ and https://framplates.com/alteraos — **index** (both pages)
- **Evidenced (28 pages):** 4 home variants with **multiple hero variations**, Features, **Pricing with a detailed 3-tier comparison table**, **FAQ page**, **Customers/case-study pages "designed for real testimonials"**, **Blog (CMS)** + Changelog (CMS), Integrations directory (CMS), Help Center, Support, Security, Careers, Press, Affiliate, Waitlist, legal pages, mega-menu navigation.
- **Gap:** a monthly/yearly pricing **toggle** is not explicitly stated on the pages read (comparison table is). Light, minimal, monochromatic style — closest in spirit to the Tailscale/Snowflake end of the reference bar.

### 3.3 Saasplex X — **8.8/10** (best Webflow buy)
- **Seller / store:** BRIX Templates, Webflow Marketplace / BRIX store — **Price:** $129 — **Format:** Webflow (+ Figma file on request)
- **Link:** https://brixtemplates.com/templates/saas-webflow-template-ui-kit — **index** (full vendor page)
- **Evidenced (33 pages):** Home v1–3, Features v1–3, **Blog v1–3 + category + post (CMS)**, **Pricing + Pricing Single (Ecommerce)**, Integrations (CMS), Careers, Help Center (CMS), Sign Up / Sign In / password flows, Schedule a Demo, Contact, legal, style guide; CMS + Ecommerce built in, speed-optimised, "always up-to-date" per vendor.
- **Gaps:** testimonials, FAQ and a pricing toggle are **not enumerated** in the vendor's page list — they may exist inside the home/pricing pages but are not evidenced as listed.

### 3.4 Beyond UI landing sections — **8.5/10**
- Same product as §1.7 (Standard $119) — **index**. **500+ responsive landing sections** explicitly covering headers, **pricing and testimonials**, with dark mode — strong raw material in Figma, but again sections to assemble, not a finished site, and toggle/comparison specifics are not itemised.

### 3.5 Also in category
- **Jet (Framer, $149, index-only via a Framer roundup):** reported as one of the most-viewed SaaS templates on the marketplace (47K+ views claimed by the roundup), with Home, Pricing, Blog (CMS), Updates (CMS), Careers, About, Contact, Waitlist pages. Not opened in depth; treat as a credible AlteraOS alternative to inspect, not a verified recommendation.
- **Saasly's marketing pages (part of §1.1):** only a pricing page with monthly/annual toggle and blog list/post — **7.5/10** as a landing solution; not a substitute for a real marketing template.
- **Tailwind Plus site templates (Studio, Salient, etc.) + Catalyst:** would historically have scored ~9 here — **but they are no longer sold** (closed to new customers 9 Sep 2026, Shopify/Tailwind Labs). Excluded as unbuyable.

---

## Conclusion — Best buy per category

| Category | Single best buy | Price / format | Score | Runner-up |
|---|---|---|---|---|
| 1. Customer portal | **Saasly** for coverage — with eyes open; **Untitled UI (Figma $129 or React $349)** for polish | $24 React code / $129 Figma, $349 React | 8.7 / 9.0 | Vibra UI (free, 8.5) for its plan-picker/invoices/workspace-settings pages |
| 2. Provider admin console | **Saasly** (only literal tenant/MRR/plan-manager match) | $24 React code | 8.7 | Shadcnblocks Admin Kit (8.5; budget $299 — price listing conflicts) for the MRR/subscriptions/invoices surface |
| 3. Landing page | **AlteraOS** (finished Framer site system); **Untitled UI** if the team wants one design system across all three surfaces | $149 Framer | 9.0 / 9.1 | Saasplex X (Webflow, $129, 8.8) |

**Does a complete buyable customer-portal kit at the 9.5–10/10 quality level exist at all? No.** Explicitly: **nothing in any category reaches 9.5–10/10.** For the portal specifically, the market splits in two — (a) high-polish *systems* (Untitled UI, AlignUI, Beyond UI) that ship components and generic examples but no finished subscription/billing/tickets/files portal flow, and (b) finished *products* with the right page lists (Saasly, Dashly X, Vibra UI) whose polish/provenance tops out at ~8.3–8.7 (new, unreviewed, or platform-locked). A 10/10-tier portal for this ERP will have to be **composed**: e.g. Untitled UI (or AlignUI) as the visual system, with Saasly/Vibra UI's page inventory as the coverage checklist — or commissioned. The same applies, slightly less severely, to the provider console: Saasly is the only off-the-shelf attempt at the full brief.

## Could not verify / open questions
- **Shadcnblocks Admin Kit price conflict** ($129 on the templates index vs "ships with Premium $299" in the product FAQ) — unresolved from public pages; budget $299.
- **Saasly's actual code quality/depth** cannot be verified without purchase: claims are unusually complete for a $24, v1.0.0, zero-review product with a 537.8 KB download. The 30-day refund eligibility is the safety net.
- **Pricing toggles** are not explicitly evidenced for AlteraOS or Saasplex X (comparison tables/pages are; toggles are explicitly evidenced only for Saasly's pricing page, Vibra UI's plan picker, and Untitled UI's pricing sections).
- **Sales counts** are not published for most independent stores (Wrapmarket, Shadcnblocks, Vibra); ratings evidence is therefore thin outside Untitled UI's vendor-claimed review counts.
- Figma Community / Dribbble / Behance / Creative Market / Gumroad were searched: **no qualifying premium portal or console kit** was found there (nearest Creative Market hit: a $15 fintech dashboard with no stated screen/component counts; Gumroad hits were small single-dashboard kits, $7–$63). This is a negative finding from search results, not an exhaustive catalogue audit of those platforms.

## Sources
- Saasly — Wrapmarket, seller codeflicks — https://wrapmarket.com/item/saasly-saas-business-admin-dashboard-template-W0D1617T5 — read 2026-11-11, **verified live** (price, version, reviews tab, page inventory, preview screenshot).
- Untitled UI Figma — https://www.untitledui.com/figma — read 2026-11-11, index (pricing tiers, component/page counts, dark mode).
- Untitled UI React — https://www.untitledui.com/react — read 2026-11-11, index (pricing, stack); page-example breakdown via vendor comparison articles on untitledui.com (figures stated as checked 5 Nov 2026), index.
- AlignUI Figma pricing — https://figma.alignui.com/pricing — read 2026-11-11, **verified live** ($119/$349, v2.0, counts).
- Beyond UI — https://www.beyondui.design/ and https://www.beyondui.design/pricing — read 2026-11-11, index.
- Dashly X — Webflow Marketplace — https://webflow.com/templates/html/dashly-x-dashboard-website-template — read 2026-11-11, **verified live** (page list); price $129 from marketplace structured data, index.
- Saasplex X — BRIX Templates — https://brixtemplates.com/templates/saas-webflow-template-ui-kit — read 2026-11-11, index.
- AlteraOS — https://www.framer.com/marketplace/templates/alteraos/ and https://framplates.com/alteraos — read 2026-11-11, index.
- Vibra UI dashboards — https://www.vibraui.com/dashboards — read 2026-11-11, index (shared-page inventory; free positioning and 12 Oct 2026 update via https://vibraui.com/).
- Shadcnblocks Admin Kit — https://www.shadcnblocks.com/admin-dashboard — read 2026-11-11, index; pricing conflict with https://www.shadcnblocks.com/templates (index).
- Shadcn UI Kit (Bundui) pricing — https://shadcnuikit.com/pricing — read 2026-11-11, index.
- Minimal UI Kit — free listing https://mui.com/store/items/minimal-dashboard-free/ — index; Pro tiers/page list via thekitbase.app Next.js roundup (28 Oct 2026), index.
- Apex / DashboardPack compare — https://dashboardpack.com/compare-templates/ — read 2026-11-11, index.
- Revu — UI8 — https://ui8.net/whiteuistore/products/revu-uikit-for-saas-startups — index.
- Tailwind Plus closure — Untitled UI alternatives analysis https://www.untitledui.com/blog/tailwind-plus-alternatives and TechTimes/BetaKit coverage of the 9 Sep 2026 Shopify–Tailwind Labs announcement, both quoting the official Tailwind blog ("closing sign ups for new customers") — index, two independent sources in agreement.
