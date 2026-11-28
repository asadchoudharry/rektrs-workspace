# Study — Mautic (mautic/mautic): design reference for `automations`, Sendqon-as-SMS-transport pairing, and Rektrs-internal use

**Date:** 2026-11-28 · **Studied for:** three separate questions, three separate verdicts — (a) how deep a design reference Mautic is for our `automations` plugin (Phase 4 of `../SENDQON-AUTOMATION-MCP-DESIGN-2026-11-28.md`), beyond what the Novu and Dittofeed studies in this corner already flagged; (b) whether **Sendqon should become an SMS transport for Mautic**; (c) whether Rektrs should run Mautic for its **own marketing**.
**Sources:** GitHub repo + releases (checked live 2026-11-28), repo `LICENSE.txt` read directly, Mautic user docs + knowledgebase (campaign builder, points), Mautic **developer docs 7.2** (SMS/MMS transport extension page), community evidence for the Twilio transport. READ-ONLY study — nothing was installed or deployed.

## What it is

The open-source marketing-automation standard: contacts, filter-built **segments**, a visual **campaign builder**, **lead scoring** (points), forms, landing pages, email/SMS/push channels — PHP/Symfony on MySQL/MariaDB, executed by a fleet of cron commands (`segments:update`, `campaigns:update`, `campaigns:trigger`, …). Repo stats at study date: **11,133 stars, 3,575 forks, 43,127 commits, 199 releases, created 2013**; **v7.2.3 released 2026-11-25** (this week, as the brief said), with 7.2.2 and 6.0.10 released the same day a month earlier — two maintained lines (7.x current, 6.x maintenance) on a roughly monthly cadence. Community-governed (Open Source Collective; a recognised Digital Public Good).

**Licence posture for the whole file: Mautic is GPL-3.0, so everything below is design mining and integration-over-API only. No Mautic code enters our tree, ever — the same rule this corner applied to playSMS.**

## 1. Licence

The repo `LICENSE.txt` is the **GNU GPL v3** text ("Mautic is released under the GPL v3", © 2014 contributors), with an appended list of bundled works under GPL-compatible licences (e.g. Apache-2.0 graphics). GitHub's detector reports NOASSERTION because of that composite file; the operative licence is unambiguous. Consequences per question:

- **(a) Design mining:** unaffected — ideas are not licensed.
- **(b) A Sendqon transport plugin *for* Mautic:** the plugin would be a derivative work of Mautic's plugin API and must itself ship **GPL-3.0** — which is fine and even desirable here: it is a small open-source connector whose whole job is to call Sendqon's API over HTTPS. Our server-side code is untouched by the plugin's licence (separate program, network boundary — the aggregation shape). Publishing it on GitHub/Packagist under GPL is the normal Mautic-ecosystem move.
- **(c) Internal use:** GPL places no restriction on running the program for our own marketing, modified or not, as long as we don't convey it. Clean.
- **Tenant-facing hosting of Mautic itself** is *not* one of the questions, and GPL (unlike AGPL) has no network clause — but it is also not our product direction; not pursued.

## 2. What it adds that we don't have — question (a): the model depth Novu + Dittofeed did not reach

Novu contributed: digest node, per-automation preferences, `critical` semantics. Dittofeed contributed: one segment object in three uses, Wait For, performed/random-bucket vocabulary, pause semantics. Mautic, with a decade of campaign-builder production use, adds four things neither had:

### 2.1 Decision vs Condition — two different node kinds, named honestly
Mautic's builder has **three** event kinds, and the distinction between the two branch kinds is the deepest single idea in this study:
- **Actions** — things the system does (send email/SMS, adjust points, modify tags/segments, update contact, webhook, push to integration), each with its own timing (immediate / interval / scheduled).
- **Conditions** — a **synchronous test on data already held**: contact field value, tag present, segment membership, DNC status. Evaluated the instant the contact arrives; yes/no exits.
- **Decisions** — an **asynchronous wait for a future contact behaviour**: opens email, clicks a link, visits a page, submits a form, downloads an asset — *and, in the SMS channel, replies to a text message*. The contact parks at the decision until the behaviour happens (yes path) or a deadline passes (no path).

Our Phase 4 catalogue currently has "condition/branch on prior step output" (condition-like) and, via Dittofeed, a flagged Wait For. Mautic shows these are **one family with two members**, and that the decision node — *wait for a channel event from this contact, with a timeout and two exits* — is the natural primitive for messaging: "wait for a reply to this SMS, 3 days, then branch" is a decision, not a poll loop. **Flagged candidate A1: adopt the two-kind taxonomy in the node catalogue — Condition (test now) and Decision (wait for event, deadline, yes/no exits) — with channel events (reply received, link clicked, delivered/failed) as the decision vocabulary.** This subsumes Dittofeed's Wait For rather than adding a third concept.

### 2.2 Lead scoring as a complete subsystem — the capability we simply don't have
Sendqon contacts have no score of any kind. Mautic's model is four cooperating pieces:
- **Point actions (global rules):** behaviour → ±points, defined once, applied to every contact (opens email +5, clicks +10, visits pricing page +15, submits form +20 — and **negative rules for inactivity, e.g. −15 after 30 days quiet, which is how Mautic models decay**: there is no automatic half-life; decay is scheduled negative adjustment, explicit and auditable).
- **Adjust-points action (inside campaigns):** a flow can add/subtract points as a step — including *demographic* scoring (condition on job title → adjust points).
- **Point triggers:** when a contact's total **crosses a threshold**, fire actions (notify the owner, add to a segment, start another campaign). The trigger is the crossing, not the value — a contact sitting at 80 doesn't re-fire.
- **Point groups (Mautic 5+):** multiple independent scores per contact (engagement vs product-interest vs content consumption), each with its own actions/triggers; company-level scoring exists alongside contact-level.

Translated to Sendqon: a per-workspace **contact score** fed by messaging events we already record (replied, clicked, delivered-failed, opted out, purchased via a campaign) would give tenants the "who is warm" list that today they cannot get at any price in Sendqon — and it composes with everything Phase 4 already has (score as a Condition test, threshold-crossing as a trigger, adjust-score as an action). **Flagged candidate A2: a scoring subsystem — score field(s) on contacts, global point rules over channel events, adjust-score action, threshold-crossing trigger — as a Phase 4 candidate or the first post-v1 addition.** This is the one genuinely new *capability* in the study, not just a modelling refinement.

### 2.3 Segment dynamics — membership as an event stream
Mautic segments are filter sets (contact fields + behaviours + tags + other segments) **rebuilt continuously by cron**; contacts enter and leave as their data changes. And the campaign **source** is the segment: *joining the segment is what starts the campaign for that contact*. Combined with Dittofeed's "one segment, three uses", the operational shape is: segments are not just testable sets, they **emit join/leave events**. **Flagged candidate A3: our segment references in automations should specify join/leave events as triggers, not only membership as a condition** (our `list-segments` MCP tool already exposes core's segments; the delta is event emission, which belongs in the automations plugin's trigger layer).

### 2.4 Two smaller, cheap spec items
- **Restart/re-entry policy:** Mautic campaigns carry an explicit "allow contacts to restart this campaign" flag — whether the same contact may run the same automation again, and our design has no stated position. One-line policy flag; copy the question, decide the default (flagged candidate A4, a footnote like Dittofeed's pause semantics).
- **Non-linear canvas:** a Mautic contact can be on parallel paths simultaneously (the graph is a true DAG, events fire independently). Our run model implicitly assumes one position per run. Whether Phase 4 supports parallel branches in v1 is a real engine-cost question — recorded here as a question for the schema freeze, not a candidate: Mautic proves users expect it eventually; it does not prove v1 needs it.

Also noted as validation, not delta: Mautic's **DNC is per-channel** (a contact can be do-not-contact for SMS but reachable by email) — the legal-suppression axis that complements Novu's per-automation preferences; Sendqon core's suppressions should be checked for the same per-channel shape at Phase 4 spec time.

## 3. Stack fit

Mautic is PHP/Symfony + MySQL — our language family (Zender is PHP/Laravel), which matters for question (b): a transport plugin is in-house-writable PHP, no new stack. As a hypothetical internal install (question c) it is a heavy PHP application plus a cron fleet and a 2 GB-class footprint — it would fit on offbox-1, but it would also create a **second contact database** to keep in sync with Sendqon's own contacts, which is the real cost, not the RAM.

## 4. Integration route — question (b): Sendqon as Mautic's SMS transport

**The interface is real, documented and current.** Mautic's developer docs (7.2) specify exactly how a provider plugs in:
- SMS sending lives behind transport interfaces in core (`Mautic\SmsBundle\Sms`): **`TransportInterface`** — `sendSms(Lead $lead, $content)` returning `true` or an error string — is the mandatory base; **`BulkTransportInterface`** adds native batch sending (`sendBatchSms` over a recipient collection); **`MMSTransportInterface`** adds media (US/CA/AU carriers only — irrelevant for us).
- A transport ships as an ordinary **Mautic Plugin** (bundle with `Config/config.php` registering the transport service); the admin picks it under Text Message settings. **Twilio is the built-in reference transport**; transports that implement only the base interface fall back to per-contact iterative sending.
- **Inbound is part of the shape:** the reference transport receives replies at a callback endpoint, and an SMS reply is a first-class **campaign Decision** in Mautic — so a Sendqon transport can close the loop: Sendqon's existing inbound webhooks POST the reply into the plugin's endpoint, and Mautic campaigns branch on it.

So a "Sendqon SMS" plugin for Mautic is: read the admin's Sendqon API key from plugin config → `sendSms` calls Sendqon's send API (single + batch) → map Sendqon message ids/errors back → expose a reply endpoint fed by Sendqon webhooks. Every Mautic user who installs it becomes a Sendqon account holder sending through SIM gateways/SMPP — i.e. **Mautic's large self-host community is a distribution shelf we can put a free connector on**, the same pattern as our Postqon connector work, pointed the other way.

**Is it worth having? Honestly graded:** the build is small and the interface is stable, but the funnel is speculative — Mautic's user base skews US/EU, where Twilio is the default and our SIM-gateway price story is Pakistan-shaped; the realistic early adopters are Mautic users in SIM-gateway markets and cost-driven self-hosters. It is a good *by-product* (it also serves as living documentation of our send API and a demo of the provider model) and a bad *growth bet* to plan revenue on. It should be built when a lane is spare or when the first Mautic user asks — not ahead of Phase 4.

## 5. Effort

- (a) This study is the whole cost; candidates A1–A3 are **spec decisions inside Phase 4's existing lanes if made before the run-engine schema freezes** (A2 scoring is the largest — if it misses the freeze it is a follow-up lane of its own, ~1–2 lanes including the panel surface). A4 is a footnote.
- (b) The Mautic transport plugin: **~1 lane** (plugin + config UI + reply endpoint + a real end-to-end proof against a throwaway Mautic install), plus publishing to GitHub/Packagist. Does not include marketing it or supporting a community.
- (c) Standing Mautic up for Rektrs: ~1 lane to install + ongoing cron/patch care — rejected below on need, not on effort.

## 6. Risk

- **Design-creep (standing risk of this corner):** Mautic is a full marketing suite (landing pages, forms, focus items, stages). The flagged list is deliberately closed at A1–A4; the rest of Mautic is recorded here so it does not get re-proposed piecemeal. In particular, **lead scoring must not grow into a CRM** — A2 is a score on contacts we already have, nothing more.
- **(b) Support surface:** a published plugin invites GitHub issues from strangers; bounded by keeping the plugin a thin API client with no sending logic of its own.
- **(b) Licence hygiene:** the plugin is GPL-3.0 by construction (derivative of the plugin API) — intended and harmless, but it must never absorb proprietary Sendqon logic; it calls the public API only.
- No risk attaches to reference-only use for (a) or to not doing (c).

## 7. Maintenance health (live-checked 2026-11-28)

11,133 stars / 3,575 forks / 43,127 commits / 199 releases since 2013. **v7.2.3 on 2026-11-25**; 7.2.2 + 6.0.10 on 2026-10-26 — monthly cadence, two live lines, community governance with a corporate ecosystem around it. The healthiest large project in this corner alongside Novu/Chatwoot. Health is not a factor in any of the three verdicts — the constraints are fit and licence posture, not upstream vitality.

## 8. Verdicts — one per question

**(a) Design reference for `automations` — GO (reference-only; Mautic the software is never adopted).** Mautic is the deepest campaign-model reference we have studied — deeper than Dittofeed, as the owner predicted. Flagged for the Phase 4 spec, before the schema freeze: **A1** the Decision/Condition two-kind node taxonomy (channel-event decisions with deadlines), **A2** the scoring subsystem (point rules over messaging events, adjust-score action, threshold-crossing trigger, negative rules as decay), **A3** segment join/leave events as triggers, **A4** a restart-policy flag. Flagged, not adopted — the design's owner decides.

**(b) Sendqon as a Mautic SMS transport — GO, small and conditional.** Build the GPL transport plugin (~1 lane) when a lane is spare or the first Mautic user appears; publish it openly; treat it as a distribution shelf and API proof, not a forecast. The interface (TransportInterface + bulk + reply-callback-as-decision) is documented, stable and squarely in our PHP skill set.

**(c) Mautic for Rektrs' own marketing — NO-GO.** listmonk already holds the GO for our newsletter-shaped marketing (one Go binary, one job, done), and the journey/scoring end of our own marketing is precisely what Sendqon's own Phase 4 automations are being built to do on our own contacts. Running Mautic internally would mean a second contact database and a cron fleet to maintain for capability we are already building in-house. Re-open only if Phase 4 slips badly *and* Rektrs needs nurture journeys before it lands.

*One-line summary: mine Mautic's campaign brain (decisions vs conditions, and the scoring subsystem), sell into its ecosystem with a one-lane transport plugin, and don't run it — our own automations are the internal answer.*
