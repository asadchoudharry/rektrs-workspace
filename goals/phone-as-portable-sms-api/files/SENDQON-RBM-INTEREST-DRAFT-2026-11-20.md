# Google RCS for Business (RBM) — Partner Registration Interest Form DRAFT

**Status:** DRAFT ONLY — prepared 2026-11-20 for the owner's review. **Nothing has been submitted, no account created, Google not contacted.**
**Prepared for:** Rektrs (Private) Limited — product: Sendqon (sendqon.rektrs.com)
**Owner action:** fill the `[OWNER TO FILL]` items, review, then submit himself using the steps in §4.

---

## 1. The process, from Google's official documentation

Researched 2026-11-20 from Google's official RCS for Business documentation (sources in §5).

1. **Interest form first.** To send messages through RCS for Business you must first register as a partner. The first step is the **RCS for Business Partner Registration Interest Form**. It asks for details about your organisation and key contacts.
2. **Google decides.** "If you qualify to be an RCS for Business partner, Google will contact you with the next steps to complete your registration." Approval is entirely at Google's discretion — there is no published eligibility checklist, fee, or timeline.
3. **What approval grants.** Access, via the Google Account named in the form, to the **RCS for Business Developer Console**, the **RBM API**, and the **Management API** — the tools to set up the partner account and create/manage agents for brands.
4. **After partner approval, per brand:** create the brand's agent → **brand verification** (an authorised representative of the brand confirms the agent details and the partner's right to manage it; some carriers also require a token from a recognised Verification Authority) → **launch approval carrier by carrier** (Google-managed launches check, among other things: a working website, terms-of-service and privacy-policy links, STOP-keyword support, and an agent preview video or step-by-step flow transcripts).
5. **Partner vs direct-brand route.** Businesses normally reach RCS *through* a registered partner (aggregator / CPaaS / solution provider) rather than registering themselves. Registering as a partner ourselves — as an **RCS Solution Provider** — is the route that lets Sendqon create and operate agents for its own tenant brands. A brand that only wants its own messages would normally go via an existing partner instead; that is not our case.
6. **A key form rule:** the partner-account-owner email must be an **individual Google Account tied to the corporate email address — a gmail address is not accepted**. It also appears as the `agent_owner` in the billing reports carriers receive, and the partner display name appears as `owner_name` in those reports, so both should identify Rektrs clearly and align with the name used in carrier messaging contracts.

### Pakistan / carrier availability — honest position

- **Person-to-person RCS works in Pakistan:** Google Messages RCS chats are usable in Pakistan (Google-hosted rollout reported since 2020; Google's own help pages state no country limit, though a carrier can disable it).
- **Business (RBM) delivery is a separate, per-carrier step.** An agent only reaches a carrier's subscribers after that carrier approves its launch in that country. **No official Google source found in this research confirms that any Pakistani carrier (Jazz, Zong, Telenor Pakistan, Ufone) currently runs an RBM agent-launch programme** — Google does not publish a verifiable per-carrier RBM launch list, and third-party aggregator listings for Pakistan show RCS pricing as "on request" only. This is an open question to put to Google in the follow-up conversation the interest form starts — partner approval alone does **not** guarantee deliverable traffic in Pakistan.

---

## 2. Draft answers, field by field

Fields are exactly the prerequisites Google lists for the interest form. Every answer uses only facts on record; every gap is marked `[OWNER TO FILL]`.

| # | Form field | Draft answer | Notes |
|---|---|---|---|
| 1 | First name | Asad | Use the exact spelling on the company registration — see gap note below. |
| 2 | Last name | Choudhary | Owner also uses "Asad Ahmad"; the form name should match the SECP record. `[OWNER TO CONFIRM: legal name spelling as registered]` |
| 3 | Job title | Founder & CEO | |
| 4 | Corporate email address | asadchoudhary@rektrs.com | rektrs.com mail is live (Hostinger). |
| 5 | Google Account email for partner account owner | asadchoudhary@rektrs.com | This is an individual Google Account on the Rektrs Google Cloud Identity organisation (created and domain-verified 2026-11-17), tied to the corporate email — it satisfies Google's "no gmail, must be tied to corporate email" rule. Do **not** enter any gmail address here. This address will appear as `agent_owner` in carrier billing reports. |
| 6 | Public name of your company | Rektrs (Private) Limited | |
| 7 | Preferred display name for partner account | Rektrs (Private) Limited | Appears as `owner_name` in carrier billing reports; Google advises aligning it with carrier messaging contracts (we hold none yet, so the full legal name is the safest choice). |
| 8 | Company website | https://rektrs.com | Product site: https://sendqon.rektrs.com (also cite it in the description). |
| 9 | Company description | See draft text below. | |
| 10 | Service category | **RCS Solution Provider** | The category for an organisation that wants to use the RCS APIs to create, manage or operate one or more agents. |
| 11 | Name of your parent company | Rektrs (Private) Limited | Google's instruction: if you have no parent company, enter your own company's public name. Rektrs has no parent company. |
| 12 | Primary countries of operation | Pakistan | |
| 13 | Region associated with your partner account | Asia Pacific | |
| 14 | Technical point of contact | Name: Asad Choudhary · Job title: Founder & CEO · Corporate email: asadchoudhary@rektrs.com · Phone: `[OWNER TO FILL — a phone number with country code (+92 …) that you want Google to use for technical contact]` | Google contacts this person about technical issues with our agents. |
| 15 | How did you hear about RCS for Business? | Other — "Google's RCS for Business developer documentation (developers.google.com)" | |

### Draft company description (field 9)

> Rektrs (Private) Limited is a Pakistan-based software company. Its product Sendqon (sendqon.rektrs.com) is a live multi-channel business-messaging SaaS platform — SMS (via Android SIM gateways and SMPP), WhatsApp, Telegram and email — through which businesses send transactional and marketing messages, with plans priced in PKR for the Pakistani market. Rektrs is preparing its PTA CVAS registration for SMS aggregation in Pakistan and intends to add RCS as a channel on the same platform, creating and operating RCS agents for its tenant brands.

Every statement above is factual from our own records: Sendqon is live and multi-channel; PKR plans are live; the CVAS track is *in preparation* (feasibility complete, registration not yet filed) and is worded that way.

### What the interest form does NOT ask for

The form needs **no** NTN, CNIC, incorporation number, or registered address — it can be submitted without them. Those facts will be needed at later stages (brand verification, carrier contracts, CVAS), so they are listed here as standing gaps, all `[OWNER TO FILL]` when required:

- NTN (company tax number)
- Founder's CNIC number
- Exact registered office address (on record only as: Rahim Yar Khan District, Punjab, Pakistan)
- Company registration / incorporation (SECP) number
- Google-contact phone number (needed for field 14 above)

---

## 3. Honest readiness assessment

**What strengthens the application**

- **A live product, not an idea.** Sendqon is a running multi-channel messaging SaaS (SMS via our own Android gateway app and SMPP server, WhatsApp, Telegram, email) with paying-plan structure live in PKR — exactly the "solution provider" profile the category describes.
- **Own engineering.** The platform's gateway app, plugins and channel bridges are built in-house, so the RBM API integration after approval is a normal build for us, not a procurement.
- **The Google Account requirement is already satisfied cleanly.** The Rektrs Google Cloud Identity organisation exists and is domain-verified, so the partner-owner account is a real corporate Google Account — a detail many applicants trip on.
- **A regulatory track is under way.** The SMS aggregator path (PTA CVAS registration) has completed feasibility and preparation; it is the foundation Google/carrier due diligence would expect of a messaging business in Pakistan.

**What Google may push back on**

- **Approval is discretionary and volume-driven.** Google publishes no criteria; established aggregators/CPaaS providers with existing traffic are the typical partners. Rektrs is a young, small company with modest current messaging volume — a "not yet" is a realistic outcome, and re-applying after the CVAS registration and aggregator traffic exist is a credible fallback.
- **No carrier messaging contracts yet.** The form itself notes the display name should align with carrier contracts; we hold none, and per-carrier launch approval is a separate negotiation after partner approval.
- **Pakistan RBM delivery is unproven territory.** As stated in §1, no official source confirms a Pakistani carrier RBM launch programme today. Partner approval would position us for it; it would not by itself make RCS messages deliverable to Jazz/Zong/Telenor/Ufone subscribers.
- **Per-brand work remains.** Every tenant brand still needs its own agent, brand verification and carrier launch — RCS on Sendqon will be an onboarding process per brand, not a switch.

**Verdict:** the draft is complete enough to submit now — every form field is answerable from facts on record except the technical-contact phone. Submitting costs nothing and starts the conversation; expectations should be set on a discretionary, possibly slow Google review, with the CVAS/aggregator track continuing in parallel as the credibility builder.

---

## 4. Exact steps for the owner to submit (when ready)

1. Fill the one form gap: the **technical-contact phone number** (field 14). Confirm the **legal name spelling** matches the SECP record (fields 1–2).
2. Open Google's official page: https://developers.google.com/business-communications/rcs-business-messaging/guides/get-started/register-partner and follow its link to the **RCS for Business Partner Registration Interest Form**.
3. Sign in with the **asadchoudhary@rektrs.com** Google Account (the Cloud Identity account) — not any gmail address.
4. Enter the answers from §2 exactly as drafted (copy the company description from §2).
5. Review once, then submit. Submission is the owner's act — Muse does not submit on the owner's behalf.
6. Watch the asadchoudhary@rektrs.com inbox: if Google qualifies us, they contact us with the next registration steps. Keep any reply/Partner ID details in the Sendqon records when they arrive.
7. After approval (separate follow-on work, not part of this draft): partner-account setup in the Developer Console → first agent for the Sendqon/Rektrs brand → brand verification → raise the Pakistan carrier-launch question with Google and target carriers.

---

## 5. Sources (all accessed 2026-11-20)

- Google for Developers — *Register as a partner | RCS for Business* (field list, process, next steps): https://developers.google.com/business-communications/rcs-business-messaging/guides/get-started/register-partner
- Google for Developers — *RCS for Business support / contact* (interest form is the route to express interest in becoming a partner/developer): https://developers.google.cn/business-communications/rcs-business-messaging/support/overview/contact?hl=en&authuser=9
- Google for Developers — RCS for Business overview (partner application entry point): https://developers.google.com/business-communications/rcs-business-messaging
- Brand-verification and launch-approval requirements are summarised from Google's RCS for Business brand-verification and launch documentation as read 2026-10-24 in a third-party digest of the official docs (getkanal.com/blog/rcs-business-messaging) — the requirements themselves (working website, ToS/privacy links, STOP support, preview video/transcripts) are Google's published launch checks.
- Pakistan P2P RCS availability: Google Messages help position as reported by pakera.pk (read 2026-11-20; underlying rollout reporting dates to 2020). No official Google source confirming a Pakistani **carrier RBM launch programme** was found — stated as unverified in §1 rather than assumed.

*Draft prepared by Muse (Sendqon) under the owner's standing instruction — DRAFT ONLY, not submitted.*
