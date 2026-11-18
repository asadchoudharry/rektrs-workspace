# Sendqon Innovation Research — Innovation #3: "Human by the Minute"

**Date:** 2026-11-19 · **Lane:** Innovation research (feasibility) · **Status:** Research only — no build, no production change
**Concept under test:** Sendqon's AI agent takes a business's calls first. Where the AI gets stuck, the PBX conferences in a vetted Pakistani human working from home, within seconds. The human is paid per minute via JazzCash/EasyPaisa. Tenants rent human attention by the minute instead of hiring call-centre staff — a liquid gig-labour layer behind AI.

**Grading used throughout:** *(official)* = government/regulator/platform-stated primary source · *(industry)* = vendor or trade publication, directionally useful, self-interested · *(unverified)* = single secondary source or marketing claim, treat with care. FX: **PKR 277 = USD 1** (project standard).

---

## Verdict up front

**GO — WITH CONDITIONS.** The gap is real: nobody in Pakistan sells a vetted human, live on a business call, by the minute, behind an AI agent, with wallet payout. The concept has just been validated internationally (two US products launched in 2026 sell "humans for AI agents" at **$1/minute** — nine times our viable price point), and Pakistani market anchors (a human's *productive* minute already costs ≈ Rs 19 in-house; BPOs charge PKR 28–55 per *scheduled* minute) leave room for a profitable Rs 25–35/min tenant price with Rs 8–12/min worker pay. The conditions are legal and operational, not technical: recording consent design, gig-worker classification that survives the incoming Punjab Labour Code, PSEB/PTA registration, and WebRTC-first call delivery (PSTN legs to workers erode the margin). Start with a zero-code concierge pilot in one vertical (clinics) before building anything.

---

## 1. Prior art — how close is the world already?

### 1.1 Gig / microtask labour platforms (Premise, Appen, Sama)

These platforms proved that distributed, phone-based, per-task labour can be recruited, vetted and paid at scale in developing markets — but all of them are **asynchronous**. None answers a live call in seconds.

| Platform | Model | Pay evidence | Distance from our concept |
|---|---|---|---|
| **Premise Data** | Location-based microtasks (photo audits, price checks, surveys) in 140+ countries; pays via local mobile money | ~$2–8/hr equivalent; $0.25–5.00/task *(industry)* | Proves mobile-money payout + CNIC-grade onboarding works in markets like ours. No live voice, no real-time SLA. |
| **Appen / CrowdGen** | AI-training crowd, 1M+ contributors, 170+ countries | Platform-stated $3.60–$40/hr by project; Asia contributor bands ~$3–14/hr; independent reviewers report realised earnings as low as ~$2.20/hr *(industry/unverified)* | Proves Urdu/regional-language crowd supply exists. Also a warning: pay opacity → 1.4–1.5/5 Trustpilot ratings and churn. Our per-minute ledger must be radically transparent. |
| **Sama** | Enterprise human-in-the-loop AI data services, employed workforce model (Kenya, Uganda, US) | Enterprise contracts; no public rate card | Human-in-the-loop as a *service*, but B2B data work, async, employed staff — the opposite end from liquid gig minutes. |

### 1.2 "AI + human escalation" contact-centre products (Cresta, Observe.AI, Genesys)

These are the category leaders in AI↔human collaboration — and **every one of them assumes the customer already employs the humans**:

- **Cresta** — real-time agent assist + AI agents + QA overlay. Not published pricing; reported $100–200/agent/month; AWS Marketplace listing $150,000/yr; typical deployments $60K–150K/yr with **50–100 seat minimums** *(industry)*.
- **Observe.AI** — QA-first conversation intelligence; ~$69/agent/month per AWS Marketplace *(industry)*; scores 100% of interactions (a design pattern we should copy for worker QA).
- **Genesys Cloud** — CCaaS from $75/user/month (CX1), AI via metered tokens, $2,000/month minimum commitment *(industry)*.

**Closeness assessment:** they sell *software to companies that have agents*. Sendqon's concept sells *the agents themselves, by the minute, to companies that have none*. Different layer of the stack. Their pricing also proves the willingness-to-pay ceiling is far above ours: a 50-seat Cresta deployment costs more per month than our entire pilot's fixed costs.

### 1.3 Per-minute human marketplaces — the concept just appeared (2026)

This is the most important prior-art finding. The idea "AI hires a human by the minute" **launched in the US in 2026**:

- **LIVEAIHELP** (Product Hunt, Oct 2026) — "Hire a human expert by the minute — for you or your AI agent." **$1/min**, vetted experts, live video/chat, exposes an **MCP server** so an AI agent can call `hire_human_expert` when stuck *(industry — vendor's own listing)*.
- **TaskBullet** (MCP server) — an AI agent can place a **real phone call** executed by a human: **$2.50 first minute + $1/min**, US/Canada numbers only, no recording *(industry)*.
- **RentAHuman.ai** (viral, Feb 2026) — AI agents hire humans for *physical-world* tasks; hourly rates $15–500, crypto payout, 110,000+ signups claimed *(industry/unverified)*. A novelty market, not a call product — but it proves supply-side appetite: people queue up to be hired by software.

**What this means for us:** the *category* is being born right now, at US price points ($60/hr equivalent), for chat/video expertise and physical tasks. **Nobody** is doing it for (a) live inbound business *phone calls*, (b) SMBs rather than AI hobbyists/enterprises, (c) Pakistan's labour cost base, or (d) local-wallet per-minute payout. The window is open but it is a window — this is a 2026 idea, not a 2030 idea.

### 1.4 Pakistan BPO / call-centre market

- Dedicated Pakistan-based agent, billed to foreign clients: **$6–12 per agent per hour** (Servions 2026 guide) *(industry)*; Worldwide Call Centers' planning table: **Pakistan $8–12/hr** *(industry)*; a Lahore BPO advertises **$7.59/hr/seat** fully managed, 160 hr/month minimum *(industry)*.
- **Posted local wages** (the employer's side): customer-support postings average **PKR 47,700–60,256/month** across 45 postings (SourceGrowth index of Rozee.pk/Mustakbil/Indeed postings, pulled 2026) *(industry — observed postings, the hardest local number we found)*.
- Pricing models in-market are per-hour, per-seat/month, or per-minute **only for shared-agent arrangements** — and even then under contract, with minimums, sold to established businesses, not self-serve to SMBs *(industry)*.

### 1.5 What does NOT exist in Pakistan (searched 2026-11-19)

- No per-minute, self-serve human escalation product at any price.
- No AI voice-agent product whose escalation target is a *marketplace* — the two Pakistani AI-voice entrants found (**Nexio** by Xarasoft/Aitomation; **CallSphere**) both escalate to **the client's own human team** — which for a clinic, school or small seller after hours is nobody. That empty chair is exactly our product.
- No gig platform paying Pakistanis per minute for live voice work via JazzCash/EasyPaisa.

*Absence-of-evidence caveat: this is based on web research on 2026-11-19; a stealth or Urdu-only competitor cannot be fully excluded.*

---

## 2. Demand evidence

### 2.1 How many calls genuinely need a human?

AI containment claims vary wildly by definition; the honest field data:

- **Intercom (2026):** production voice-AI deployments typically achieve **20–40% containment** — i.e. **60–80% of calls still reach a human**, "but those calls are the ones that should" *(industry)*.
- **WhichVoIP field study (2026)** — full call records of a live AI receptionist, 2,151 engaged calls over 3 months: **37.8% resolved by AI alone, 51.2% transferred to a person**, 11.0% ended unresolved *(industry — full-population data, the most credible single dataset found)*.
- **NextPhone dataset (1.4M calls):** 73.8% transfer rate — but those agents were configured to triage, not resolve *(industry)*.
- **Practitioner benchmark consensus:** target escalation **20–35%** for mature, mixed-use deployments; below 15% only for narrow scopes (booking/FAQ only) *(industry)*.

**Planning assumption for Sendqon:** in year one, with SMB-grade knowledge bases, **40–60% of calls will escalate**, improving toward 30–40%. The escalated call's human portion is typically short — the AI has already identified the caller, intent and collected fields — plan on **3–5 human minutes per escalation**. A tenant taking 30 calls/day therefore consumes roughly **40–90 human-minutes/day (900–1,900/month)**; a small tenant at 10 calls/day, roughly **300–600/month**. This is a *feature* of the model: the demand curve is many small tenants, not a few big ones — precisely the segment BPOs refuse to serve.

### 2.2 The pain, priced (e-commerce — best documented)

- Growing Pakistani e-commerce brands spend **PKR 350,000–600,000/month** on manual COD call-centre salaries, headsets, SIMs and dialer bills, while courier return-to-origin (RTO) stays at **20–28%** and only **48% of confirmation calls are even answered** *(industry — R&B CRM/TaqwaShield 2026 benchmark; vendor marketing, directionally consistent with the known COD problem)*.
- A Pakistani AI-voice vendor's own published math: one human agent ≈ **Rs 75,833/month** fully loaded, producing ~3,960 real call minutes → **Rs 19.15 per productive call minute** *(industry — Nexio pricing page, Nov 2026)*. The same vendor sells AI minutes at **Rs 10–15/min** — establishing that Pakistani businesses already accept per-minute call pricing, and that a human minute is the premium tier above it.
- Automated COD robo-calls are already a paid category (Robo Calls PK: $0.02–0.03/call; Dialentra: PKR 7,500–35,000/month) *(industry)* — proof of willingness to pay for call handling, with human escalation as the unserved top tier.
- After-hours leakage: sellers report missed orders worth **Rs 2,000–4,000 each** in the 10pm–9am window *(unverified — vendor blog)*.

### 2.3 Clinics and schools

No published Pakistan-specific dataset on clinic/school call pain was found — **stated plainly: not published.** The structural case is strong (a clinic's phone is answered by one receptionist who is also checking patients in; a missed call is a patient who books elsewhere; schools face bursty admission-season call loads no fixed staff matches), and both verticals are already Sendqon packs (B6) — but this demand must be **validated in pilot interviews**, not assumed. Appointment value per call is high (a single booked patient/student pays for hundreds of minutes), which is why clinics are the recommended pilot vertical despite thinner published data.

---

## 3. Supply side — who sells the minutes?

### 3.1 The pool is large and already counted

- **2.36 million** Pakistanis do platform gig work; ~**462,596 are women** (Gallup Pakistan analysis of Labour Force Survey 2024–25, Oct 2026) *(industry — survey-based)*.
- Women are **>60% of home-based workers** (ILO Pakistan) while female labour-force participation is only ~**24%** — the gap between those two numbers is our supply: educated women at home who cannot take office jobs *(official/ILO)*.
- Of women gig workers, **17% hold a master's degree** and 63% are under 35 (CMACED/Gallup infographic, Oct 2026) *(industry)*.
- Freelancer earnings cluster at **$200–800/month**; youth unemployment is high (11.4% cited) *(industry)*. Students, retired clerks/teachers, and off-shift call-centre agents round out the pool.

### 3.2 Pay expectations vs the minimum-wage math

- **Minimum wage (official):** PKR **40,000/month** for unskilled workers in Punjab, Sindh and KP effective 1 Jul 2025 (ICT/Balochistan 37,000) → at 26 days × 8 h = **PKR 192/hour ≈ PKR 3.21/minute of scheduled time** *(official — provincial notifications via WageIndicator/FAFEN)*.
- Posted support wages (PKR 47,700–60,256/month) imply **PKR 229–290 per scheduled hour** *(industry)*.
- **The per-minute translation is the whole design problem.** A worker is not talking 60 minutes an hour; at a realistic **35–50% talk utilisation** while marked available:
  - Pay **PKR 10/talk-minute** → effective **PKR 210–300 per available hour** — at or above the minimum-wage hourly equivalent, and above posted-wage hourly at good utilisation.
  - A worker available 4 h/day × 26 days at 40% utilisation earns ≈ **PKR 25,000/month part-time**; 8 h/day ≈ **PKR 50,000/month** — competitive with the posted support-wage band, with zero commute.
- **Recommendation:** launch at **PKR 10/talk-minute** with a quality bonus (top-quartile QA score +20%), and publish the worker's live earnings-per-available-hour in the app. Appen's 1.4/5 reputation is what happens when platforms hide this math; our ledger transparency is a recruiting weapon. Revisit the rate after pilot utilisation data — if utilisation runs below 30%, add a small availability stipend for scheduled peak windows rather than raising the minute rate.

### 3.3 Vetting, KYC and quality control

- **Identity:** CNIC verification + a JazzCash/EasyPaisa account **in the worker's own name** (account-name match is a strong, cheap identity anchor — the same title-check rails our B2 payment plugins already use) + SIM registered to the same CNIC.
- **Voice gate:** recorded audition — Urdu reading, English reading, one mock difficult-caller call — scored by a human before activation; language tags (Urdu / English / Punjabi / Sindhi / Pashto) and vertical tags (clinic / school / commerce) drive routing.
- **Probation:** first 50 calls are 100% supervisor-reviewed (listen-in via ChanSpy), then sampling.
- **Ongoing QC (the Observe.AI pattern, at our scale):** 100% of calls recorded (with consent, §5) and **AI-scored** against a rubric (greeting, accuracy, no unauthorised promises, closing); human QA reviews the bottom decile + a random 5%; scores feed the worker's **trust score** — the direct interlock with Innovation #1 (Number Trust Bureau): workers, like numbers, accumulate portable reputation; tenants can require a minimum trust tier; callers with abuse/fraud history are flagged before the worker ever hears them.
- **Conduct rails:** scripted boundaries per tenant (what the human may promise), no access to tenant data beyond the call's context card, all actions (booking, order edit) taken through Sendqon tools so they are logged.

---

## 4. Technical design on our stack

Everything below uses components Sendqon already has or is building; the only genuinely new build is the worker app and the handoff protocol.

### 4.1 Call flow (Asterisk — B9 PBX module)

1. Call arrives on the tenant's number → B3 **AI agent** answers, with the mandatory recording-consent announcement (§5.2) before any conversation.
2. AI handles the call; on an escalation trigger it **keeps the caller on the line** and the PBX originates a leg to the best available worker (skill + language + trust tier), **whisper-briefing** the worker first: a 5-second private prompt ("Clinic caller, wants to reschedule Thursday's appointment, AI already verified CNIC…") using Asterisk's ChanSpy whisper / ConfBridge private announcement — the caller hears hold music or the AI's "ek minute, main aap ko mila deti hoon," never the briefing.
3. Parties join a **ConfBridge** conference: caller + worker, with the **AI remaining as a silent third participant** — transcribing, watching for the resolution, and able to take the call back (e.g., to send a payment link or WhatsApp summary after the human hangs up). A supervisor can **barge** (ChanSpy barge mode) on any live call from the QA console.
4. On hangup: AI posts the summary, outcome code and follow-ups to the tenant's Sendqon inbox; the minute ledger is written from Asterisk CDR (answer-to-hangup of the worker leg), cross-checked against voice-activity on the recording (see fraud, §4.4).

This "AI never leaves the call" pattern is the differentiator no BPO can copy cheaply: the human supplies judgement and warmth; the AI supplies memory, compliance and the audit trail.

### 4.2 Handoff protocol (extension of the B3 ai_agents plugin)

- **Triggers:** two consecutive low-confidence turns; caller explicitly asks for a human ("insaan se baat karao" — always honour instantly; it is also the legally safest default); negative-sentiment detection; high-value intent (fee dispute, medical urgency keywords, complaint); any tool/action failure; tenant-configured rules (e.g., "all calls about refunds").
- **Context packet** (passed to the worker app before they accept): caller number + trust score, tenant, language, intent, transcript so far, fields already collected, what the AI tried, the one-line job ("confirm the address and offer Friday slot"). Repeat-explanation rate — callers having to re-tell their story — is the #1 handoff quality killer in the literature (target <5%); the context packet is how we beat it.
- **Routing & SLA:** ring the top-3 rated available workers simultaneously; target **answer within 20 seconds**; if nobody takes it, AI offers a callback, books it, and sends the tenant a WhatsApp alert via Sendqon core. Unfilled escalations are logged as supply gaps (they drive recruiting by language/vertical/time-band).

### 4.3 Worker app and the WebRTC-vs-PSTN decision

Build on our existing Android base (B7 app codebase / the B9 Flutter companion): availability toggle, incoming request with context card, one-tap accept, in-call screen (context, script rails, outcome buttons), earnings ledger in real time.

| | **WebRTC leg (in-app)** | **PSTN leg (call to worker's mobile)** |
|---|---|---|
| Marginal cost/minute | ≈ data only (worker's own connection; ~PKR 0–1 platform-side) | Local mobile termination on a licensed route — **not published**; grey wholesale decks quote $0.016–0.054/min (PKR 4.4–15) but grey routes are a PTA enforcement risk and must not be used (§5.4) |
| Context/whisper/QA | Full: context card, whisper brief, in-app outcome codes | Voice only; context must be read out or sent separately |
| Worker privacy | Total — no number exists to expose | Number stays hidden behind the PBX bridge, but call metadata sits on a personal SIM |
| Reliability | Needs decent data (urban 4G fine; weak-signal homes suffer) | Works on any signal |
| Verdict | **Primary** | **Fallback only**, for workers/areas where data is unreliable — priced into the model as a cost ceiling, not the default |

### 4.4 Money rails and fraud controls

- **Payout:** per-minute ledger settles **weekly** via the JazzCash/EasyPaisa disbursement APIs (B2 plugins — live but unconfigured; owner merchant accounts are the same outstanding owner step as the rest of B2). Minimum payout PKR 500 to keep transaction overhead negligible; every payout to the worker's own-name wallet (§3.3).
- **Fraud controls (designed in from day one):**
  - *Fake minutes / call stretching:* billing counts only seconds with **bidirectional voice activity** (Asterisk recording + VAD analysis); abnormal duration distributions per worker are auto-flagged; per-worker daily minute caps during probation.
  - *Collusion (worker + fake caller farming minutes):* caller numbers are trust-scored (Innovation #1 interlock); repeat caller↔worker pairings are rate-limited and reviewed; tenant-side outcome codes must exist for minutes to settle (a "call" with no outcome doesn't pay full rate).
  - *Ghost availability:* random test calls into the pool; missed-answer rate feeds the trust score.
  - *Settlement safety:* 7-day holdback on a % of earnings against disputed minutes in the first 90 days; clawback clause in the worker contract.
  - *Tenant-side abuse:* tenants see per-call recordings and can dispute a call within 48 h; disputed minutes are reviewed by human QA before settlement.

---

## 5. Legal & labour (Pakistan)

*This section is research, not legal advice; a counsel review is Step 2 of the recommendation.*

### 5.1 Worker classification — the ground is moving under "independent contractor"

- Today there is **no enacted dedicated gig-work statute** in Pakistan; platform workers are generally engaged as independent contractors and sit outside most labour protections *(industry — ILO/Fairwork-cited academic review, 2026)*.
- **But:** the draft **Punjab Labour Code 2025** (introduced in the Punjab Assembly, with the Standing Committee as of reporting) and the parallel Sindh code would, for the first time in South Asia, **define platform/gig workers as "workers"** — entitled to minimum wage, a **written contract in English or Urdu accessible in the app** (stating pay, its calculation, rest, safety and deactivation terms), no platform work under 18, freedom of association, and employees' compensation via group insurance; employers with 20+ workers face a compulsory group-insurance duty *(industry — Centre for Labour Research / The News reporting on the draft codes)*.
- **Design consequence (GO condition):** build as if the Code is law — in-app Urdu/English contract, transparent per-minute calculation shown before every shift, 18+ gate at CNIC check, pay-floor logic (§3.2) that keeps effective earnings for engaged time at/above the minimum-wage equivalent, and budget for group insurance once the pool passes ~20 actives. Also manage the **control paradox**: scripts, QA scoring and routing all look like employer control; preserve genuine gig freedoms (log in/out at will, reject any call without penalty beyond its effect on future routing priority) and consider a **hybrid**: a small core of part-time *employees* guaranteeing peak coverage + a gig pool for overflow. Misclassification is the single largest legal risk in this business model worldwide; Pakistan is legislating toward the worker-protective answer, so we design for it rather than litigate against it.

### 5.2 Recording consent — PECA and the 2026 Supreme Court position

- **PECA 2016, s.19:** unauthorised interception of a non-public transmission *with dishonest intention* — up to **2 years' imprisonment and/or Rs 500,000 fine** *(official text via secondary legal sources)*.
- Secondary legal sources report a **March 2026 Supreme Court judgment (PLJ 2026 SC 114)** holding that secretly recording a private conversation without consent violates **Article 14 of the Constitution** — i.e. Pakistan is treated as an **all-party consent** jurisdiction *(industry/secondary — verify the judgment text with counsel before launch)*.
- **Design consequence (GO condition):** every call opens with a bilingual announcement — *"Yeh call quality aur training ke liye record ki ja sakti hai"* / "This call may be recorded for quality and training" — played **before** the AI's first substantive turn; consent + announcement playback logged against the CDR; recordings encrypted, access-logged, retention-limited (propose 90 days, then transcript-only), never downloadable by workers; worker consent to recording and QA scoring is an explicit contract clause. Treat recordings as personal data under the (still draft) Personal Data Protection Bill's principles: purpose-limited, minimised, secured.

### 5.3 Women's home-work safety & privacy (a design requirement, not a feature)

- The worker's **personal number is never exposed** — all calls ride the PBX/WebRTC with the tenant's number as the only identity; workers appear under a **pseudonymous display name** ("Ayesha — Sendqon Assistant").
- No location is collected or shown beyond city-level for language routing; no video, ever; no off-platform contact (a worker who moves a caller to her personal WhatsApp is deactivated — for *her* protection as much as ours).
- Abusive-caller controls: one-tap "end & report" that never penalises the worker, automatic trust-bureau strike against the number, and a women-workers' support channel staffed by a named human at Rektrs.
- Scheduling respects the worker's declared hours absolutely — the system never rings outside them; night-shift pools are opt-in and paid at a premium rate.

### 5.4 Licensing for operating a BPO-like service

- **PSEB call-centre registration:** the Pakistan Software Export Board states only PSEB-registered call centres are recognised as legally operational by PTA and law enforcement; registration is the precondition for **PTA IP whitelisting** of VoIP traffic (static IP required; ~PKR 500/IP whitelisting fee and Rs 20,000/yr principal-office renewal per industry sources) *(industry — PSEB statements via Uplyft/Sterling guides, Nov 2026)*.
- **PTA CVAS:** the Class VAS page shows new **Voice & Data licence applications suspended until further notice**, while **class registration remains open** (one-time Rs 10,000 per the PTA checklist) *(official — PTA)*. Whether a distributed home-worker platform is a "call centre," a CVAS voice service, or neither is genuinely unsettled — a July 2025 news report of a coming joint NCCIA/PTA call-centre licence found **no official notice** as of Nov 2026 *(industry)*.
- **Grey-route warning:** cheap wholesale termination decks to Pakistan ($0.016–0.096/min) are widely advertised, some explicitly "no KYC." Grey traffic is a PTA enforcement priority and would poison the aggregator track (Innovation-adjacent) and the whole Rektrs telecom posture. **Only licensed local/LDI routes, or inbound models where the customer dials us.**
- **Design consequence (GO condition):** before commercial launch — PSEB call-centre registration for Rektrs, PTA IP whitelisting for the Asterisk hosts, and a written position (counsel or PTA licensing division) on CVAS registration for the platform. Total known fees are trivial (tens of thousands of rupees); the cost of *not* doing it is existential.

---

## 6. Unit economics (per human talk-minute, PKR)

### 6.1 Anchors

| Anchor | Value | Grade |
|---|---|---|
| Twilio termination to PK mobile (international ceiling) | $0.1760/min ≈ **PKR 48.8/min** | official (Twilio pricing page) |
| Twilio PK landline / Plivo PK | $0.1510 / $0.1380 per min ≈ PKR 41.8 / 38.2 | official (vendor pricing pages) |
| Local licensed SIP trunk per-minute rates (PTCL/operators/LDI) | **Not published** — quote-based only | — (stated plainly) |
| In-house human, cost per *productive* minute (PK) | **Rs 19.15** (Rs 75,833/mo ÷ 3,960 productive min) | industry (Nexio) |
| PK AI voice minutes, retail | Rs 10–15/min | industry (Nexio published tiers) |
| PK BPO dedicated agent, billed | $6–12/hr scheduled → at ~35% talk utilisation ≈ **PKR 79–159 per talk-minute** | industry (Servions/WCC + utilisation math) |
| US "human for AI agent" retail | $1/min ≈ PKR 277/min | industry (LIVEAIHELP) |
| Minimum wage | PKR 40,000/mo ≈ PKR 3.21/min of scheduled time | official |

Two conclusions fall out of the table: (1) **Twilio-class international termination (PKR 48.8/min) would kill the model outright** — the product only works on local inbound + WebRTC economics; (2) even at premium pricing we are 3–5× cheaper than a BPO per actual talk-minute and ~9× cheaper than the US per-minute human products.

### 6.2 Model at launch pricing

**Tenant price: PKR 30 per human talk-minute** (AI minutes remain the tenant's existing Sendqon/AI pricing; human minutes are the premium tier, sold in prepaid minute-wallets). **Worker pay: PKR 10 per talk-minute** + quality bonus.

| Cost line (per talk-minute) | WebRTC leg | PSTN fallback leg |
|---|---|---|
| Worker pay (incl. avg. bonus) | 11.0 | 11.0 |
| Telephony (customer leg inbound, local trunk allowance / worker leg) | 1.5 | 6.0 |
| AI supervision, transcription, QA scoring | 1.5 | 1.5 |
| Human QA & supervision (amortised) | 3.5 | 3.5 |
| Payout & payment costs | 0.4 | 0.4 |
| **Total cost** | **17.9** | **22.4** |
| **Contribution at PKR 30** | **PKR 12.1 (40%)** | **PKR 7.6 (25%)** |

*Telephony lines are planning allowances, not quotes — local trunk pricing is unpublished (§6.1); the pilot must replace them with real CDR costs.*

### 6.3 Break-even

Lean fixed base for a small commercial pod: 2 QA/supervisors (loaded ≈ PKR 180k), platform/ops share, registrations and misc ≈ **PKR 300,000–500,000/month**. At ~PKR 12/min contribution (WebRTC-dominant mix):

- Break-even ≈ **25,000–42,000 talk-minutes/month** ≈ 850–1,400 minutes/day
- ≈ **15–25 small tenants** at 900–1,900 human-minutes/month each — or fewer, larger ones.

Sensitivity: the model survives worker pay rising to PKR 14/min (contribution ≈ PKR 8) and price falling to PKR 25 (contribution ≈ PKR 7) — but not both together, and not on PSTN-heavy delivery. Utilisation is the swing variable on the supply side: below ~30% talk utilisation, worker earnings/hour sag toward the minimum-wage line and churn follows; the fix is demand density (more tenants per pool), not rate cuts.

---

## 7. Risks, recommendation, first steps

### 7.1 Risk register (top items)

1. **Two-sided cold start** — tenants won't buy minutes without reliable answer times; workers won't stay available without minutes. *Mitigation: concierge pilot with a hand-picked pool and 2–3 friendly tenants; guarantee coverage windows, not 24/7, at first.*
2. **Labour reclassification** — Punjab/Sindh codes are moving gig workers toward "worker" status with minimum-wage and contract rights. *Mitigation: design-to-the-draft (§5.1); hybrid employee core.*
3. **Recording/privacy incident** — one leaked call recording is a brand-ending event in this market. *Mitigation: consent-by-design (§5.2), encryption, no worker downloads, retention limits, access logs.*
4. **Quality variance** — one bad human on a clinic's call costs more trust than ten good calls earn. *Mitigation: probation, AI scoring of 100% of calls, trust tiers, tenants can require tier minimums.*
5. **Telephony cost surprise** — if local inbound trunk terms are worse than the allowance, or PSTN fallback dominates, margin compresses toward zero. *Mitigation: WebRTC-first; measure real CDR cost in the pilot before publishing prices.*
6. **Fraud farming** — collusive fake minutes. *Mitigation: §4.4 controls; settlement holdbacks; trust-bureau interlock.*
7. **Regulatory shift** — the reported joint call-centre licence (NCCIA/PTA) could add requirements mid-flight. *Mitigation: register early (PSEB + whitelisting), keep the compliance file warm.*
8. **Category timing** — LIVEAIHELP/TaskBullet prove the idea is in the air in 2026; a funded entrant could localise it. *Mitigation: speed of the pilot; our unfair advantages (Sendqon's tenant base, B3 agents, B9 PBX, wallet rails, Urdu-first) are already built.*

### 7.2 Recommendation

**GO — WITH CONDITIONS.** Conditions precedent to commercial launch (the pilot may run under manual supervision before all are closed):

1. WebRTC-first delivery; PSTN worker legs capped as an exception path.
2. Consent announcement + recording design reviewed by counsel against PECA s.19 and the 2026 Supreme Court position.
3. Worker contracts and pay-floor logic drafted to the *draft* Punjab Labour Code standard (in-app Urdu/English contract, transparent calculation, 18+, insurance budgeted).
4. PSEB call-centre registration + PTA IP whitelisting completed; CVAS position confirmed in writing.
5. One vertical only (clinics) until QA scores and utilisation are proven for 60 days.

### 7.3 First three concrete steps

**Step 1 — Concierge pilot (zero new code, 2 weeks).** Recruit 5–8 vetted humans from Rektrs' own network (CNIC + own-name wallet + voice audition, done manually). Take **one clinic and one school** from existing Sendqon relationships. The B3 AI agent handles first contact on the tenant's existing channels; when it needs a human, a Rektrs dispatcher conferences the on-duty human in through the B9 Asterisk (or a plain 3-way call in week 1) and logs minutes in a shared sheet. Tenants are billed manually at **Rs 30/min**, workers paid weekly via JazzCash at **Rs 10/min**. Measure: escalation %, human minutes per escalation, answer latency, CSAT (one-question WhatsApp follow-up), worker earnings per available hour, real telephony cost per minute from CDRs. *Every assumption in §6 gets replaced by a measured number.*

**Step 2 — Legal pack (parallel, week 1–3).** Counsel review of (a) worker contract + classification posture, (b) recording-consent script and data-retention policy, (c) PSEB registration + PTA IP whitelisting filings and the CVAS question. Deliverable: a one-page compliance checklist signed off before any public launch.

**Step 3 — Build-list freeze from pilot data (end of week 2).** Only after the pilot: spec the worker app (WebRTC + context card + earnings ledger), the B3 handoff protocol (triggers, context packet, routing SLA), and the QA scoring rubric — sized by what the pilot proved tenants actually escalate. No marketplace features, no second vertical, no self-serve worker onboarding until the pilot's unit economics hold for 60 days.

---

## Sources (accessed 2026-11-19)

- Servions, *Call Center Outsourcing Cost in Pakistan (2026 Guide)* — servionspvtltd.com · Worldwide Call Centers, *Contact Center Pricing* — worldwidecallcenters.com · CareDesk Consultants (Lahore BPO $7.59/hr/seat) — teamcaredesk.com
- SourceGrowth, *Pakistan VA & BPO Rate Index* (observed postings; customer support PKR 47,700–60,256/mo) — sourcegrowth.com
- Intercom, *Building an AI-Human Phone Support Workflow* (20–40% containment) — intercom.com · WhichVoIP, *AI Receptionist Data* (2,151 engaged calls; 37.8% AI-resolved, 51.2% transferred) — whichvoip.co.za · JustCall, *AI Voice Agent Benchmarks 2026* (NextPhone 1.4M-call dataset) — justcall.io
- LIVEAIHELP, Product Hunt listing ($1/min, MCP `hire_human_expert`) — producthunt.com · TaskBullet MCP server (phone calls $2.50 + $1/min) — glama.ai · RentAHuman.ai coverage — aimojo.io, eu.36kr.com, thescottishsun.co.uk
- Rework/Rankite/GoldenOwl 2026 comparisons of Cresta, Observe.AI, Genesys (seat pricing, minimums) — resources.rework.com, rankite.com, goldenowl.asia
- Nexio (Xarasoft AI), published PK pricing & agent-cost math (Rs 75,833/mo; Rs 19.15/productive min; AI Rs 10–15/min) — xarasoftai.com · R&B CRM/TaqwaShield, *Manual Call Centers vs WhatsApp COD Verification: 2026 Benchmark* — aec.taqwashield.com · CallSphere PK playbook — callsphere.ai · Robo Calls PK — apps.shopify.com · Dialentra — dialentra.com
- Gallup Pakistan / CMACED, *Pakistan's 2.36 Million Gig Workers* (LFS 2024–25 analysis, Oct 2026) · Borgen Project, *The Boom of Freelancing in Pakistan* · ILO Pakistan home-based worker data via Knowledge Bylanes
- Minimum wage: provincial notifications FY2025-26 (PKR 40,000 Punjab/Sindh/KP) via WageIndicator/FAFEN and Ramco compliance releases
- Recording law: PECA 2016 s.19; PLJ 2026 SC 114 as reported by recordinglaw.com and legalbycountry.com (secondary — verify with counsel)
- Labour codes: Centre for Labour Research, *Addressing Concerns on Pakistan's Labour Codes* (Jan 2026); The News, *Punjab unveils sweeping reforms…* (Punjab Labour Code 2025); Springer, *Social (in)security… gig workers in South Asia* (2026)
- Licensing: PTA CVAS checklist & fee schedule (ptca.pk); PSEB call-centre registration & PTA IP whitelisting via Uplyft and Sterling guides (Nov 2026)
- Telephony: Twilio SIP Trunking pricing PK ($0.1760 mobile / $0.1510 landline) — twilio.com · Plivo SIP pricing PK ($0.1380) — plivo.com · Wholesale decks (AcePeak, AstralSIP, 6X) — grey-route risk noted, not relied on
- Microtask pay: Appen/CrowdGen via aitraining.jobs (Nov 2026); Premise Data via platform roundups (remogrid.com, AI-training job-site index)

*Prepared as a standalone research lane deliverable. No production systems were touched; no code was written; all figures are graded at the point of use and should be re-verified before any pricing or legal commitment.*
