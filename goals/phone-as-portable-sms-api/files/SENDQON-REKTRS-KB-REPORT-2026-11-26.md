# Sendqon — Rektrs Knowledge Base + AI Agent + WhatsApp wiring (2026-11-26)

**Owner's order:** "Rektrs ka apna complete knowledge base banao, her cheez say data ikatha karo — Rektrs website, social media say — or jo WhatsApp number connected hy usky sath jor do, phir test kerty hain automation."

**Result: DONE and live.** The Rektrs KB is built and indexed in the `knowledge_base` plugin (master-admin workspace), an AI Agent ("Rektrs Assistant") answers from it, and the agent is pinned to the connected WhatsApp account (+92 347 4162393). All five protocol test questions were answered by real agent turns through the live Gemini provider — every turn searched the KB first. The one remaining proof is a single real inbound WhatsApp message (see Honest limits).

Fresh verified backup before any production write (backup.sh: status=OK, push=OK). No plan flags were changed. No credential value was printed anywhere; the provider key was compared in-process only (unchanged, len 53).

---

## 1. What had to be fixed first — the embeddings gap (PR-007)

The B3 lane left the KB plugin **inactive + unconfigured**: activation requires a verified embeddings configuration, and no embeddings provider existed. Probing the live system found the real shape of the problem:

- Core's KB contract (`KnowledgeBaseSettings::MODELS`, `EmbeddingSpace`) only allows OpenAI embedding model names (`text-embedding-3-small/large`) at a fixed 512 dimensions.
- Sendqon's only AI provider is the Gemini row (OpenAI type → `https://generativelanguage.googleapis.com/v1beta/openai`). Live wire probes (key in-process only):
  - `text-embedding-3-small` → **HTTP 404** ("not found … not supported for embedContent")
  - `text-embedding-004` → **HTTP 404**
  - `gemini-embedding-001` with `dimensions: 512` → **HTTP 200, 512-length vector** ✅
- Gemini's response also differs from OpenAI's shape in two ways the core `EmbeddingClient` rejected outright: **no `usage` object at all**, and **no per-row `index`** — the first Configure attempt failed with exactly that ("The embeddings response has invalid vectors or usage").

**PR-007** (registered in `PATCH-REGISTER.md`, applied to the live container + host build tree, md5-identical both sides, `php -l` clean):
- `KnowledgeBaseSettings::MODELS` += `'gemini-embedding-001'` (1 line).
- `EmbeddingClient`: when `usage` is absent, estimate tokens from input length (chars/4, min 1/input) so metering never runs free; when a row's `index` is absent, use the row's position (rows are ordered). OpenAI-shaped responses take the exact old path.

Provider row (id 1) configuration completed through the model (key untouched): capabilities `["chat"]` → `["chat","embeddings"]`, and `pricing.embeddings.credits_per_1k_tokens = 1` (platform config so the machinery can meter; tenant plan pricing is untouched and still the owner's separate decision).

Then the plugin's own flow ran for real: `PluginManager::configure('knowledge_base', model=gemini-embedding-001, dimensions=512)` — the Configure **probe embedding passed** and the verified fingerprint was stored — followed by `activate('knowledge_base')`. End state: `KnowledgeBaseSettings::current()` = `gemini-embedding-001:512`, `KnowledgeBaseAccess::enabledFor(master)` = true.

**Model note (evidence-forced, same class as Step-1's):** during the first agent test run, `gemini-3.5-flash` chat returned **HTTP 503 on every call** (3 recorded failed turns, 0 credits — the audit trail is in `ai_agent_turns`). A live model sweep found `gemini-3.8-flash` also 503, `gemini-2.5-flash` 404 for this key, and **`gemini-3.5-flash-lite` answering 200 immediately**. The provider default model and the agent's model were set to `gemini-3.5-flash-lite` (provider `available_models` = `[gemini-3.5-flash-lite, gemini-3.5-flash]`, so switching back is one line when the full model's demand settles). Embeddings were unaffected throughout.

## 2. The Knowledge Base

**Base:** `Rektrs — Company Knowledge Base` (id 1, master-admin workspace). The full loaded text is saved as `REKTRS-KNOWLEDGE-BASE-CONTENT-2026-11-26.md` in this folder.

**Sources** (created through core's `KnowledgeSources` service; indexed on the `knowledge` queue — all jobs DONE):

| # | Source | Type | Status | Chunks | Bytes |
|---|---|---|---|---|---|
| 1 | Rektrs — Company Profile | text | ready | 2 | 1,887 |
| 2 | Rektrs — Services (15 pillars) | text | ready | 3 | 3,614 |
| 3 | Rektrs — Products & Platforms | text | ready | 1 | 1,023 |
| 4 | Rektrs — Offices, Contact & How We Work | text | ready | 2 | 1,626 |
| 5 | Rektrs — Frequently Asked Questions | faq (17 pairs) | ready | 17 | 5,088 |
| | **Total** | | | **25** | **13,238** |

Workspace embedding space: `openai:gemini-embedding-001:512`. Direct search probes (the same `KnowledgeSearch` service the agent uses) returned ranked, cited hits for services / offices / schools / quote queries (top scores 0.83 / 0.70 / 0.70 / 0.76).

**Data sources used:** rektrs.com live pages fetched today (home, locations, contact, company overview file, media kit) + the prepared 2026-11-26 website services scan (15 pillars, ~193 offerings) as backbone + standing facts from memory/LinkedIn (Google Cloud Partner status, partner@rektrs.com, Saudi offices, founded 2020, SECP/D-U-N-S references are from the company's own published overview).

**Deliberately excluded (could not verify / conflicting):**
- **Facebook / Instagram page URLs** — public search surfaced no verifiable Rektrs page on either platform; omitted rather than guessed (LinkedIn company page + YouTube @rektrs are in the KB, both verified).
- **Prices of anything** — no public price list exists; the KB states this and routes quotes to partner@/sales@ + phone.
- **The "Badar Mension, Model Town B, Flat No 5, Bahawalpur 63100" legal address** (Google Partner profile) — the live website's locations page publishes a different Bahawalpur address (Al Badar Plaza, 3rd Floor, Office #4, Model Town B) and names **Liaquatpur** as headquarters. The KB uses the website's published locations (the customer-facing source of truth); the owner may want to reconcile the two.
- **London register office** — present on the LinkedIn location list but not on the website's locations page; left out of the customer-facing KB for the same reason.
- **Incorporation-date nuance** (About page: structure formalized 20 Feb 2026 vs "founded 2020" on LinkedIn/TheOrg) — KB says "founded 2020" only.

## 3. The AI Agent + WhatsApp link

**Agent:** `Rektrs Assistant` (id 1), created through the plugin controller's own store/update shapes:
- Template `support`, model `gemini-3.5-flash-lite`, memory 20 messages, knowledge results 5, active.
- Persona/instructions: Rektrs assistant; always search the KB before answering about Rektrs; answer only from it; reply in the customer's language (English / Roman Urdu / Urdu); never invent prices, discounts, timelines, statistics or commitments — pricing questions get the discovery + contact route (partner@rektrs.com / sales@rektrs.com / +92 318 073 5877); no-answer → say so honestly and offer a human handover. (Core's runtime adds its own matching rules on top.)
- Actions: reply + knowledge search + handover (to anyone, round-robin, with a contact-bearing handover message). No labels/tags/HTTP actions — nothing else enabled.
- **Knowledge base attached:** base id 1 (pivot `ai_agent_knowledge_bases`).
- **WhatsApp link:** `channels = [{channel: "wa", connections: ["wa:1"]}]` — pinned to WhatsApp account id 1 (+92 347 4162393, WaAccount, vendor server, status **connected**, untouched by this lane). Verified with the model's own matcher: `covers('wa','1') = true`, `covers('wa', null) = false`, `covers('sms') = false` — the agent answers on that WhatsApp connection only.
- `AiAgentsAccess::enabledFor(master)` = true; the agent's `present()` payload (what the /ai-agents screen renders) shows the full wiring.

**Live-path note:** inbound WhatsApp messages on account 1 that no flow answers are dispatched to the `ai-agents` queue → `AgentRunner::handleMessage` → this agent (it is the only active agent and it covers wa:1). Safety gates from B3 apply unchanged (no group chats, stops when a human takes over, WhatsApp 24-hour window enforced by core's sender). The account's own settings also still apply (quiet hours 22:00–07:00 and warmup/throttle on account 1 were **not** changed).

## 4. Test — five protocol questions, real agent turns

Method: the plugins expose no test-chat surface, so each question was run as a real agent turn via `AgentRunner::runForFlow` (the flow engine's own entry point — real gateway turn, real KB search, real reply through core's `AutomatedMessageSender`) on a labelled test conversation (`KB Test — automation check`, contact numbers +923000000001–5, unassigned test numbers; replies were generated and queued into those conversations — no real subscriber received anything). Every turn: actions `["search_knowledge","reply"]`, 1 credit, outcome `replied`. Answers verbatim:

**Q1 — "What services does Rektrs offer?"** → **GROUNDED** (turn 5.5–8.4 s class; latency 8,398 ms)
> Rektrs offers a wide range of technology and digital transformation services across 15 connected pillars, including:
>
> • AI-Driven Platforms & Software Development (custom software, mobile apps, web development, and workflow automation)
> • ERP Implementation & Business Automation (Odoo, ERPNext, Microsoft Dynamics 365, and Zoho services)
> • Emerging & Advanced Technologies (IoT, blockchain, and smart contracts)
> • Managed IT, Cloud & Infrastructure (AWS, Azure, Google Cloud, cybersecurity, and helpdesk support)
> • Digital Growth & Marketing Services
>
> How can we help you with your project?

Minor paraphrase drift only ("cybersecurity" folded into the Managed IT bullet; pillar 9 shortened to "Digital Growth & Marketing Services"). No invented facts.

**Q2 — "Where are your offices?"** → **GROUNDED** (5,501 ms)
> Rektrs has offices in Pakistan and Saudi Arabia:
>
> • **Headquarters (Liaquatpur):** 214/C Housing Scheme, Near Government College Road, Liaquatpur 64000, Pakistan
> • **Bahawalpur Office:** Al Badar Plaza, 3rd Floor, Office #4, Model Town B, Bahawalpur, Pakistan
> • **Al Khobar Office (Saudi Arabia):** 12B At Taawun District, Al Khobar 34632, Eastern Province
> • **Riyadh Office (Saudi Arabia):** Rail Business Center, Office #111, Omar Almukhtar Street, Thulaim, Riyadh 11332
>
> Please contact our team before planning a visit!

All four addresses verbatim-correct against rektrs.com/locations.

**Q3 — "Aap schoolon ke liye kya banate hain?"** (Roman Urdu) → **GROUNDED, answered in Roman Urdu** (6,933 ms)
> Rektrs schoolon ke liye mukammal systems aur platforms banata hai, jin mein shamil hain:
> - School Management System (SMS): student records, fees aur front-office operations ke liye.
> - Learning Management System (LMS): schools aur training organizations ke liye digital learning platform.
> - School mobile apps: parents, students aur staff ke liye.

**Q4 — "How can I get a quote for an ERP system?"** → **GROUNDED — correct no-price behaviour** (2,548 ms)
> Pricing for an ERP system is scoped per project after a discovery conversation to understand your specific workflows, goals, and requirements. You can reach out to our team at partner@rektrs.com or sales@rektrs.com, or call/WhatsApp us at +92 318 073 5877 to discuss your project.

**Q5 — TRAP: "What is your price for a website?"** → **PASS — no invention** (4,222 ms)
> Pricing is scoped per project after a discovery conversation to understand your specific requirements and goals. You can reach out to us at sales@rektrs.com or partner@rektrs.com, or call/WhatsApp us at +92 318 073 5877 to discuss your project.

No price was invented; the contact route was given, exactly as designed.

**Metering proof:** `ai_usage_logs` shows each agent turn charged 1.0000 credit on `gemini-3.5-flash-lite` (status success) and each KB query embedding charged 0.0070 credits on `gemini-embedding-001` (feature `knowledge_query`); `knowledge_queries` recorded 9 rows. Site HTTP 200; today's app log tail shows 0 ERROR lines after the work.

## 5. Honest limits — what is still unproven

1. **The final live proof is one real inbound WhatsApp message.** Everything up to the channel edge is proven with real turns, but no message has yet arrived on +92 347 4162393 and been answered by the agent in the wild. The exact step left: **any WhatsApp message sent to +92 347 4162393 from another number** (outside the account's quiet hours 22:00–07:00 PKT, and with no human assigned to that conversation) — the agent should reply from the KB within seconds; the turn will appear in the agent's activity feed in the panel (AI Agents → Rektrs Assistant).
2. The first test attempt (before the model switch) left 3 failed turns in the audit trail (Gemini 503s, 0 credits) and the labelled test conversations/contacts remain in the workspace as the test record — they can be deleted from the panel at any time without affecting the wiring.
3. Test replies were queued to unassigned test numbers (0300-000000x), so WhatsApp-side delivery receipts for agent replies are unproven — that is part of proof #1.
4. The KB content is a snapshot of rektrs.com as of 2026-11-26; website changes will need a KB source refresh (the content doc in this folder is the editable master).
5. Tenant use of KB/AI Agents still sits behind the owner's plan-flag pricing decision (`knowledge_base` / `ai_agents` are off on all plans) — this build lives in the master-admin workspace only, per scope.
