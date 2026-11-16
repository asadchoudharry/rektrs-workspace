# PAID PLUGIN SPEC — Knowledge Base

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/knowledge-base/
- **Demo state:** **Inactive — "Configuration required"** (one of 3
  such plugins, Lane 4 §C).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
A searchable document store that gives AI Agents and the AI Flow
Builder grounded knowledge.

## Features
Sources: PDF, DOCX, TXT, Markdown — uploaded manually, by URL, by
public link, or by HTML paste. A document reader that preserves
headings and lists. Chunking at **2,048 tokens with overlap**.
Metadata, authorship and language detection. Search ranking. Automatic
indexing of content published with the AI Flow Builder. A search API.

## Workflow
Upload → activate → enable Knowledge Base + (AI Agents or AI Flow
Builder) on the plan → create a source → add documents → publish →
attach the source to an agent or AI-built flow.

## Logic / technology
The schema is **core**: `knowledge_bases`, `knowledge_sources`,
`knowledge_chunks`, `knowledge_queries`, `knowledge_workspaces`, the
`knowledge` queue, and scheduled `knowledge:refresh` / `knowledge:retry`
(15 min) + `knowledge:prune` (daily) (Lane 5 §§4, 12). Core also ships
the ingestion libraries (`smalot/pdfparser`, `phpoffice/phpword`) and
embeddings billing per 1k tokens through the AI wallet
(`../01-CORE-MODULES/ai-providers-credits.md`). Like Appointment
Booking, the paid plugin is substantially an activation layer over
core machinery — how much is plugin vs core is UNVERIFIED until tested
on our install.

## Data it touches
`knowledge_*` tables; `ai_usage_logs` (embedding charges).

## Dependencies
AI Agents or AI Flow Builder enabled; an AI provider with embeddings
(OpenAI = full capability; OpenRouter = chat + embeddings).

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) over core
  `Knowledge/*` services.
- **Key interfaces:** source CRUD + ingestion pipeline (parse →
  chunk 2,048 tokens w/ overlap → embed → index) on the `knowledge`
  queue; retrieval API used by agents (ranked chunks + citations);
  refresh/retry/prune via plugin-registered schedule entries.
- **Priority:** Phase 4, AI group (with AI Agents + AI Flow Builder —
  agents are notably better with grounding).
- **Difficulty:** Medium (Easy if the core pipeline proves complete
  and only gating/UI is missing — Phase 0/1 verification item).
