# 09 — USP ADDENDUM 10: THE DIFFERENTIATION LAYER

Owner decision 2026-11-16: **all six USPs** from the 2026-11-15
discussion are recorded here and in the master plan
(`../ZENDER-CORE-PLUS-OWN-PLUGINS-PLAN-2026-11-15.md`, Addendum 10).

The core makes Sendqon *work*; this layer makes a tenant *choose*
Sendqon over any other Zender copy or generic messaging panel. Every
item below is our own build (plugin or clean-room module) — none of it
exists in the vendor product. Build sequence: **1, 2, 3 first**, then
4 with Phase 3, 5 after the channels exist, 6 last.

## USP-1 — Pakistan-first pack → Phase 1 (UI) + Phase 4 (payments)

- **Payments in-panel:** JazzCash, EasyPaisa, Raast as first-class
  billing/payment plugins (Phase 4 priority list already carries the
  payment builds; this USP is why they outrank global gateways).
- **Masked-SMS / PTA workflow in-panel:** a tenant applies for a
  sender mask from inside the panel (business name + NTN documents),
  tracks approval, and sends under the approved mask via the chosen
  aggregator route (see roadmap Phase 5 masked-SMS note; open item
  #12 — Telenor/Ufone mask display — resolves with the aggregator).
- **Urdu / Roman Urdu UI + template library:** localised interface
  strings and ready templates (school fee reminders, COD order
  confirmation, appointment reminders) in Urdu/Roman Urdu.
- **Moat:** no global competitor localises Pakistan payments, PTA
  process and language in one panel.

## USP-2 — SIM Fleet Intelligence → Phase 2

Built on our own Android gateway app (Phase 2), where we own the
device-side data the vendor app never exposes:

- **Warm-up schedules:** new SIMs ramp volume over days/weeks instead
  of blasting on day one.
- **Per-SIM limits + rotation:** daily caps per SIM, automatic
  rotation across the fleet, carrier-aware distribution.
- **Per-SIM health score:** delivery rate, failure patterns and
  carrier-block signals rolled into one score; sick SIMs are rested
  or retired before they get banned.
- **Moat:** a banned SIM fleet is the #1 operational pain of
  SIM-based sending; protecting the fleet is a retention feature,
  not a convenience.

## USP-3 — Deliverability engine → Phase 2/4 (cross-cutting)

- **Pre-send number validation (HLR):** dead numbers are filtered
  before a campaign burns credits on them.
- **Cross-channel cascade:** WhatsApp → SMS → email fallback chains
  per campaign/flow, so one unreachable channel does not lose the
  message.
- **Spam-content score:** campaign text is scored before sending;
  risky wording is flagged with suggestions.
- **Moat:** measurable delivery % is the metric tenants renew on.

## USP-4 — WhatsApp warm-up + ban-risk score → Phase 3

Built on our own WhatsApp QR bridge (Phase 3), where session data is
ours:

- **Warm-up ramps** for freshly linked numbers (volume + behaviour
  pacing in the first days).
- **Per-number ban-risk score** from sending patterns, block/report
  signals and session health, with in-panel guidance before a number
  crosses into danger.
- **Moat:** QR numbers are cheap for tenants but fragile; keeping
  them alive is what makes the unofficial channel sellable.

## USP-5 — Vertical packs → after Phase 4

Ready-made packs per industry — templates, flows, drip campaigns and
reports pre-built, switched on per workspace:

- **Schools:** fee reminders, result/announcement broadcasts,
  attendance alerts (the operator's own IQRS experience is the
  reference spec).
- **Clinics:** appointment booking + reminders, follow-up drips.
- **E-commerce:** COD confirmation, dispatch updates, abandoned-cart
  recovery.
- **Moat:** tenants buy an outcome ("my fee collection runs itself"),
  not a messaging tool; packs shorten time-to-value to one day.

## USP-6 — Reseller++ → Phase 5 era (last)

- Partners run their **own branded SaaS** on Sendqon: own domain,
  own pricing and plans, sub-tenant workspaces under the partner,
  partner-level reporting.
- Goes beyond the vendor's built-in Partner Network (referral-style);
  this is a white-label reseller tier.
- **Gate:** build only once the single-brand SaaS is proven with
  paying tenants; reseller support load before that is a distraction.

## Standing notes

- USPs never justify editing vendor code outside the patch register;
  each lands as a plugin/module per the tree's standing rules.
- USP-1's mask workflow and USP-3's HLR depend on third-party
  aggregator/lookup contracts — evaluate providers at build time,
  record the choice in `05-INFRA.md`.
