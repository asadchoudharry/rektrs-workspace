# Operqon RAG (bina LLM) — Retrieval Plan

**Status:** **OPTION 1 SELECTED — Assad, 2026-11-11 ~15:08 PKT** ("Option 1 select ker lo agar architecture ka masla hy to"). Retrieval-only MVP hi final rasta hai; alag RAG-ready architecture document nahi banega. Generation slot sirf interface level par khali rakha jayega (§2 / P3), taake baad mein bina redesign ke tenant apni LLM key laga sake — lekin v1 build sirf retrieval hai.
**Written:** 2026-11-11 (14:32 PKT) — Assad ke sawal "Kya hum Operqon main apna RAG bhi bana sakty hain bina LLM k" (RAG side chat, 13:36 PKT) par. Decision updated 2026-11-11 ~15:08 PKT.
**Scope note:** Ye **naya scope** hai — W1 close (Slice 10, pilot3/Rams) se pehle is ki build shuru nahi hogi. Plan sirf is liye tayyar hai ke faisla karte waqt sab kuch saamne ho.

## 1. Faisla — kya ban raha hai, kya nahi

**Ban raha hai: Retrieval system (RAG ka 80–90% valuable hissa), bina LLM ke.**
- Tenant ke documents/SOPs/policies/help articles/PDFs ko chunk karke embeddings banana, semantic search, aur jawab ki jagah **original cited passages** source link ke saath.
- Zero hallucination (kuch generate hi nahi hota), zero per-query cost, tenant ka data VPS se bahar kabhi nahi jata.

**Nahi ban raha (v1 mein):**
- ChatGPT jaisa apne alfaaz mein jama karke jawab — wo Generation hai, LLM ke baghair mumkin nahi. Search-result style milega, chat style nahi.
- Transactional numbers (GL, stock, trial balance, balances) kabhi RAG se nahi — wo hamesha SQL/API se exact aayenge.

## 2. Architecture (Operqon ke usoolon par)

| Hissa | Faisla | Wajah |
|---|---|---|
| Frappe app | Nayi custom app `operqon_rag` — **core edit nahi** | Operqon ka bounded-fork / app pattern; core clean rehta hai |
| Vector store | **Qdrant** (Apache 2.0, Docker `qdrant/qdrant`, VPS par) | Self-host, no per-query billing; payload filtering tenant/role ke liye built-in |
| Embedding model | **BAAI/bge-m3** (MIT licence, local, CPU par) | 568M params, 1024-dim dense, **100+ languages**, 8192-token context; dense + sparse + multi-vector ek hi pass mein. FP16 weights ~1.1 GB — VPS par chal sakta hai, GPU nahi chahiye |
| Tenancy | **Har tenant ki alag Qdrant collection** | Cross-tenant leakage ka rasta hi band; collection delete = tenant data delete |
| Permission gate | Retrieval se **pehle** Frappe permission check | Jo document user dekh hi nahi sakta, wo search result mein bhi nahi aayega (post-filter nahi, pre-filter) |
| Search | Hybrid: dense (semantic) + sparse/BM25 (keyword) + rerank | Sirf keyword se Roman Urdu / paraphrase wale sawal nahi milte; sirf semantic se exact terms (invoice no, code) miss hote hain |
| Generation slot | Khali rakha jayega, interface tayyar | Baad mein jo tenant chahe apni LLM key (OpenAI / local model) laga le |

**Service-provider principle (binding):** activation tenant khud kare apni credentials se; validate-or-error — ghalat key/config par saaf error, kabhi silent half-active state nahi. Operqon tenant ki LLM key apne paas plaintext mein nahi rakhta — wohi pattern jo gateway credentials ke liye tay hai (console settings, encrypted at rest, masked on read-back).

## 3. v1 corpus — kya index hoga

Tenant khud choose karega (opt-in, per DocType):
1. Help articles / knowledge base
2. SOPs aur policies (HR, finance, procurement)
3. Uploaded manuals / PDFs (File DocType se)
4. (Baad mein) Support ticket resolutions — sirf tenant ke apne

**Bahir:** transactional DocTypes (Sales Invoice, Journal Entry, Stock Ledger, Payment Entry, Salary Slip waghera) — kabhi index nahi honge.

## 4. Phases aur acceptance

### P0 — Spike / validation (pehle, chhota)
- Qdrant + bge-m3 VPS par Docker mein; 100-document test corpus (English + Urdu + **Roman Urdu** queries — Roman Urdu transliteration ki quality unproven hai, is liye P0 mein explicit test set).
- Acceptance: top-5 recall test set par ≥ 80%; query p95 < 500 ms (chhota corpus); permission-gate test: restricted doc kabhi result mein nahi.

### P1 — Ingestion + search (core build)
- `operqon_rag` app: chunking, embedding job (background), re-index on doc edit/delete, search API, Desk mein search UI (cited passages + source link + "open document").
- Acceptance: edit ke 60s andar index update; delete ke baad doc search se gayab; per-tenant collection isolation test PASS; koi core file change nahi.

### P2 — Tenant activation + admin controls
- Tenant khud activate kare (self-service), corpus choose kare, usage (docs indexed, queries) dekhe; admin (operqon-owner) per-tenant on/off.
- Acceptance: activation validate-or-error; deactivate par collection drop + data delete proof.

### P3 — Generation slot (optional, baad mein — abhi scope se bahir)
- Tenant apni LLM key lagaye → generated answer **sirf retrieved passages se**, har claim ke saath citation; key ghalat ho to saaf error.
- Ye phase Assad ke alag faislay se shuru hogi; P0–P2 is ke baghair mukammal hain.

## 5. Sizing / cost — imandaar unknowns

- **Cost:** licence $0 (Qdrant Apache 2.0, bge-m3 MIT); per-query $0; sirf VPS resources.
- **Footprint (checked 2026-11-11):** Qdrant dev/prototype 1 vCPU / 512 MB RAM se chalta hai (<100k vectors); small-prod 2 vCPU / 2–4 GB RAM. bge-m3 FP16 ~1.1 GB. VPS **srv2107420 KVM 2 (2 vCPU)** hai — **free RAM abhi unknown hai**; build se pehle lane `free -h` / disk check karegi.
- **Agar headroom tight nikle:** options — scalar quantization (RAM 4x tak kam), embedding service ko alag chhote VPS par rakhna, ya P1 ko pilot tenant tak mehdood rakhna. Ye P0 ka exit decision hai, abhi assume nahi kiya.

## 6. Risks (khulay)

1. **Roman Urdu queries** — bge-m3 Urdu script mein strong hai; Latin-script Roman Urdu par retrieval quality test karni hogi (P0 test set).
2. **Stale index** — doc edit/delete par re-index hook chhoota to ghalat jawab milega; P1 acceptance mein cover hai.
3. **PDF extraction** — scanned/Urdu PDFs ka text kharab ho sakta hai; v1 mein sirf text-layer wale PDFs, baqi "not indexed" label ke saath.
4. **VPS load** — embedding CPU par chalegi; bulk indexing ko background + throttled rakhna hoga taake live bench slow na ho.

## 7. Assad se 3 faislay (build se pehle)

1. **Priority:** plan manzoor hai? RAG W1 close (Slice 10 / pilot3) ke **baad** ki queue mein jaye — pehle nahi.
2. **v1 corpus:** upar §3 theek hai, ya kuch DocType nikalna/jorna hai?
3. **P3 generation slot:** abhi sirf design (recommendation: haan, design rakho, build baad mein) ya bilkul bahir?

## Sources

- Assad ka sawal + main agent ka jawab: RAG side chat (2026-11-11 13:36 PKT).
- bge-m3 specs: `BAAI/bge-m3` — 568M params, 1024-dim, 100+ languages, 8192 tokens, MIT — https://www.runlocalai.co/models/bge-m3 and https://docs.api.nvidia.com/nim/reference/baai-bge-m3
- Qdrant sizing: https://railway.com/deploy/qdrant-vector-database (dev 1 vCPU/512 MB; small prod 2 vCPU/2–4 GB) and https://www.29vps.com/vps-qdrant-vector-db-en.html
- Operqon principles: MEMORY.md — service-provider principle, integration standard (validate-or-error), gateway credentials pattern; VPS srv2107420 KVM 2.
