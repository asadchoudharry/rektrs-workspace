# Operqon design system, navigation aur screen contracts

Darja: proposed product specification. Brand baseline: uploaded Operqon Twin Path Brand Guidelines, Concept B, v1.0. Purane repository screens ya tokens ke mukhtalif font/color ko approved brand samajh kar preserve na kiya jaye; migration compatibility ko alag assess karein.

## 1. Visual identity aur working environment

Dark ink navigation, mist workspace aur white task surfaces ko ek stable shell mein rakhein. Teal primary action aur selection ka accent ho. Har dashboard ko rang-birangi cards ka collection na banayein: pehle urgent work, phir meaningful operating metrics, phir drill-down evidence. Industry ke liye logo badalna nahin; terminology, task priority aur domain fields badlein.

| Token | Value | Product use |
|---|---|---|
| `brand.ink` | `#14272F` | Main text, navigation |
| `brand.teal` | `#008D83` | Brand accent, selected highlights |
| `action.primary` | `#00786F` | Small white-text primary controls |
| `surface.deep` | `#0B1E25` | Deep brand surfaces |
| `surface.workspace` | `#F4F8F7` | Page background |
| `surface.card` | `#FFFFFF` | Task/editing surface |
| `surface.mint` | `#DDF7F0` | Quiet positive/selection background |
| `text.secondary` | `#5B7075` | Secondary content, contrast verify per size |
| `accent.active` | `#4DE0C5` | Selected state on approved dark context |
| `font.heading` | Inter Display, approved fallback | Page/marketing headings |
| `font.ui` | Inter, approved fallback | Body, labels, controls |
| `spacing.base` | 4 px | Spacing scale |
| `radius.card` | 12–16 px | Cards/drawers; dense grid uses tighter corners |

Semantic warning/error/info colors abhi proposed hon; contrast tests aur redundant text/icon ke baad approve hon. Success/warning ko brand palette se infer na karein. Money aur quantities tabular numerals, aligned decimal/right edges aur visible currency/UOM ke saath hon. 14–16 px body, 13–14 px dense tables, 12 px supporting labels brand guidance ke mutabiq; browser zoom par content truncate na ho.

Arabic ke liye actual Arabic-capable approved font fallback select aur render QA karein; Inter ko Arabic glyph coverage ke baghair universal font declare na karein. Urdu future locale ke liye localized font, line height aur reading tests chahiye. English, Arabic, Urdu translations ko ek hi mixed string mein concatenate na karein.

## 2. Navigation information architecture

Teen related magar permission-wise alag surfaces:

| Surface | Audience | Main navigation | Context shown |
|---|---|---|---|
| Customer hub | Subscription owner/admin | Overview, Sites, Plan & billing, Team, Support, Settings | Customer account, tenant/site |
| Business workspace | Operational users | My work, domain modules, reports, search, help | Tenant + legal entity + branch/warehouse |
| Provider control | Authorized Operqon operators | Review queue, tenants, provisioning, plans, billing operations, pack registry, incidents | Environment + operator role + support scope |

Customer account ka billing owner hona ERP accountant permission nahin. Provider console ke support action ko customer tenant UI mein disguised login na banayein. Tenant switch explicit ho; switch par cached sensitive data, selected filters aur background requests ko clear/re-scope karein. Legal entity switch currency/tax/context banner update kare. Franchise outlet selector unhi records ko dikhaye jahan user scoped ho.

Sidebar ka universal top level: My work; Sales; Purchases; Inventory; Finance; Operations; People; Reports; Administration. Packs required entries ko named subnavigation mein add karein. Restaurant cashier landing POS ho, pharmacy dispenser landing dispensing queue ho, owner landing operating overview ho. Chhote business mein unused advanced sections progressive disclosure se hide hon; authorization server par enforce rahe.

Global search entity-aware ho: invoice ID, customer, VIN/serial, batch, order, document. Results mein entity/branch/type/status dikhaye. Cross-tenant suggestions kabhi na aayen. Keyboard command launcher permission-aware actions de. Recent/favorites per user hon, not shared across roles.

## 3. Screen contracts aur state coverage

Har screen implementation ticket yeh contract carry kare:

`purpose -> user/role -> scope -> entry -> primary action -> validation -> state model -> recoverable errors -> evidence/audit -> next step -> accessibility -> analytics acceptance`.

Required states: initial/loading; content; empty with useful action; no access; no results; validation error; timeout/offline; stale conflict; partial completion; quota limit; job running; success; archived; unsupported country/pack; dependency missing. Har screen par sab states mechanically nahin dikhani; applicable states declare karein.

Screen inventory CSV mein proposed screens, roles, actions aur acceptance requirement di gayi hai. Ye shipped-screen count nahin. Pack-specific detail industry specifications se join hoga.

## 4. Teen detailed page layouts

### A. Owner operating overview

| Page region | Content / interaction | Contract |
|---|---|---|
| Top bar | Brand, active company, branch scope, date range, search, notifications | Scope har drill-down mein carry ho |
| Page heading | Good morning optional; clear company name + period | No vague personalized headline replacing business context |
| Primary action row | New sale, Record receipt, Approvals | Role/pack-aware actions |
| Metric row | Cash position, overdue AR, sales/margin, stock-at-risk | Period, currency, freshness, calculation definition visible |
| Work queue | Due approvals, failed sync, low stock, overdue orders | Severity + owner + next action; counts scoped |
| Operating area | Sales trend and top overdue customers | Same reporting cutoff; accessible table alternative |
| Activity strip | Recent meaningful completed operations | Mask sensitive records by permission |
| Footer/help | Help topic + support status | No raw stack trace or internal ports |

Owner cash position ko bank actual versus book balance clearly label karein. Margin display negative discounts, returns aur landed cost policy ko include kare. Cross-currency totals mein reporting currency aur rate basis dikhaye. Data pending ho to zero display karke healthy impression na dein.

### B. Sales order editing aur fulfilment

| Region | Detail | Failure behavior |
|---|---|---|
| Header | Order number, customer, legal entity, status, last saved | Concurrent edit par version conflict, safe merge/reload |
| Customer card | Address, terms, tax identity, credit exposure | Missing required tax ID actionable error |
| Item grid | Scan/search, description, qty, UOM, available, price, discount, tax | Invalid UOM/serial duplicate/negative availability rules inline |
| Fulfilment drawer | Warehouse, date, delivery method, partial policy | No stock -> backorder/reserve choice per policy |
| Totals | Net, discounts, tax components, deposit, grand total | Server-authoritative recalculation; changed total warning |
| Approval panel | Trigger reason, approver, history | Salesperson apna credit override approve na kare |
| Primary actions | Save draft, Request approval, Confirm, Print | State-permitted action only; duplicate submission idempotent |
| Timeline | Documents, allocations, deliveries, invoices, returns | Related records maintain source links |

Long item tables mein sticky headers, keyboard row navigation, paste/import preview aur undo unsaved row edits hon. Approval request ke baad pricing change ho to existing approval invalidate/reevaluate kare. Posted invoice ko normal editable form se modify na karein.

### C. Country compliance operations center

| Region | Content | Required behavior |
|---|---|---|
| Status strip | Country/entity, pack version, environment, credential expiry | Sandbox aur live visually explicit |
| Summary | Ready, pending, rejected, reconciliation overdue | Counts underlying queue se match |
| Queue grid | Invoice ID, type, amount, authority status, last attempt, next attempt | Filters + safe export |
| Details drawer | Validation failures, response reference, canonical evidence | Sensitive identifiers permission-aware |
| Action row | Validate, retry eligible, reconcile, open correction | Final invoice duplicate/renumber safeguards |
| Change notice | Upcoming schema/certificate/rule effective dates | Owner assignment + acknowledgment |

Authority submission success aur financial posting success alag statuses hon. Retry operation user ko naya invoice banane ka mashwara na de jab purani request ka outcome unknown ho.

## 5. Reusable component system

| Primitive | Needed variants/states | Important behavior |
|---|---|---|
| Button | Primary, secondary, destructive, icon, pending | Pending label/action lock; double-click safe |
| Text/date/money inputs | Required, read-only, invalid, masked | Explicit label; localized display/canonical value |
| Entity picker | Single/multiple/search/create where allowed | Permission-filtered results and scope |
| Data grid | Sorting/filter/pagination/grouping/selection | Selection across pages explicit; bounded bulk jobs |
| Status badge | Neutral/positive/warning/error/pending | Text + color; timestamp where material |
| Form section | Collapsible, summary, validation | Error summary links to invalid field |
| Modal/drawer | Confirm, edit, evidence, preview | Focus trap, Escape safe, focus return |
| Timeline | Document and audit event | Actor/time/source visible; immutable log |
| Empty state | First-use/no-results/no-permission | Clear action or why user cannot act |
| Job progress | Queued/running/partial/failed/completed | Durable job ID, downloadable row errors |
| File uploader | Preview, validation, progress, quarantined | Type/size constraints and malware pipeline |
| Notification | In-app/email/SMS/WhatsApp where configured | Consent/preferences; transactional priority |
| Amount summary | Multi-tax, inclusive/exclusive, rounding | Do not hide rounding or currency |
| Pack banner | Trial, unsupported, update available | Truthful scope; no fake certification badge |

Component documentation includes semantic HTML, keyboard, screen-reader naming, reduced motion, touch targets, RTL, density and error examples. A disabled control needs accessible reason. Toast alone is insufficient for durable failure or required correction.

## 6. Enterprise interaction rules

Saved views store filter/sort/columns/scope intent, not unauthorized row snapshots. Shared views never grant data permission. Default views can be pack-installed but customer personalization remains versioned and recoverable. Bulk actions preview count, criteria, exception policy and authority; all-or-nothing versus partial processing is explicit. Completion report identifies failed rows without leaking unauthorized data.

Long forms autosave draft only when business state permits; server validation still mandatory. File import has template version, column mapping, dry run, row diagnostics, review, commit job, reconciliation and rollback/remediation reference. CSV exports must neutralize spreadsheet formula injection. Export job and download expiry get audit records.

Approvals show changed values, business reason, exposure and supporting documents. Approver can approve/reject/request change with structured note. Delegation has dates and scope. Absence delegation cannot silently exceed financial authority. Decision at stale version requires refreshed review.

## 7. Responsive, offline aur device design

Desktop accounting/warehouse management dense and keyboard-friendly ho. Tablet POS/KDS touch-focused ho. Mobile frontline mein route stops, customer recovery, approval, stock scan aur field-service tasks priority hon. Every desktop grid ko phone par squeeze na karein: summary cards + detail screens + scoped filters use karein.

Offline state visibly distinguish cached data, unsynced action aur authoritative transaction. Counter receipt, fiscal invoice aur payment authorization ko ek offline promise mein combine na karein; country/device rules har pack mein define hon. Sync conflict review queue mein user original intent aur server result samajh sake. Lost device/session revoke ho aur cache policy sensitive data par enforce ho.

## 8. Arabic / localization / accessibility

Arabic RTL mein navigation, drawers aur directional icons logically mirror hon; serials, VIN, IBAN, email, code aur mixed money values correct bidi isolation ke saath display hon. Date timezone aur calendar preference record ho; canonical UTC/audit timestamp alag rahe. Decimal separators, grouping, number system, currency fraction digits aur negative balances locale-aware hon.

Page at 200% zoom usable; keyboard-only complete primary flows; visible focus; readable error summaries; status announcements; charts ka tabular alternative; screen-reader grid behavior; no hover-only essential information. Targets ko WCAG 2.2 AA evidence se verify karein; badge tab publish ho jab actual audit scope clear ho.

## 9. UX validation aur design handoff

Har anchor industry ke 3-5 real roles se task testing karein. Tasks: first item setup, purchase receipt, sale/return, outstanding recovery, month-end report; specialist workflow industry-specific add ho. Completion time ke saath failure/recovery observe karein. Paused tasks aur moderator help record ho; vanity satisfaction score akela evidence nahin.

Handoff mein annotated screens, responsive variants, component references, API contract, permission matrix, all state examples, content strings, analytics events aur acceptance checks hon. Visual concept ko working production UI keh kar deliver na karein. Brand assets original proportions mein; logo clear space >=0.2x symbol height; horizontal lockup min 140px screen brand guidance se.

## Sources

Brand: uploaded Operqon Twin Path Brand Guidelines PDF, authoritative design baseline.
[PRD-04] ERPNext Role Based Permissions: https://docs.frappe.io/erpnext/permissions (accessed 2026-11-06).
[PRD-05] ERPNext Accounting Dimensions: https://docs.frappe.io/erpnext/accounting-dimensions (accessed 2026-11-06).
