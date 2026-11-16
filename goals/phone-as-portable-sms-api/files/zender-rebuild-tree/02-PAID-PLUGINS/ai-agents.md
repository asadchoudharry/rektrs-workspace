# PAID PLUGIN SPEC — AI Agents

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/ai-agents/
- **Demo state:** Active/Configured (AI); tenant AI Agents page shows 8
  agents (all Off) with templates Support / Sales / Appointments /
  Order Status / Custom / Lead Qualification (Lane 4 §B).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
AI agents that sit in Messenger conversations: answer customers,
qualify leads, and carry out tasks through tools.

## Features
GPT-5 and Claude agents with native conversation skills; a **system
prompt per agent**; knowledge sources (own files, the Knowledge Base
plugin, built-in system resources); **tool calls** — Chat Flows, API,
WhatsApp and Telegram messages, WhatsApp Business templates, customer
create/update; **human handoff rules** (by tag, keyword, or AI
decision); reply review modes (automatic / review / pause);
conversation summaries; automatic labels; per-agent limits and model
settings.

## Workflow
Upload → activate → enable AI Agents + Chat Flows on the plan → add
provider API key in Configure → create agent + system prompt → attach
to a channel or flow → the AI reads the conversation, follows the
prompt, calls tools.

## Logic / technology
Built on core's AI substrate: provider registry + credit wallet
(`../01-CORE-MODULES/ai-providers-credits.md`), the `ai-agents` queue,
and core contract families `app/Contracts/AiAgents/*` (Lane 5 §5.3).
Agent runs consume AI credits like any other AI call (deduct-first,
refund-on-failure). Knowledge grounding optionally comes from
`knowledge-base.md`.

## Data it touches
`conversations`/`conversation_messages` (read + reply), `contacts`
(create/update via tools), `ai_usage_logs`, `knowledge_*` (when KB
attached), agent config (plugin-owned storage — UNVERIFIED whether
vendor uses core tables or its own).

## Dependencies
An OpenAI or Anthropic account + API key (or core AI providers);
Chat Flows enabled; plan switch `ai_agents`.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract), consuming core
  `AiAgents/*` contracts and the core AI provider registry.
- **Key interfaces:** agent definition (prompt, model, limits,
  handoff rules, review mode) stored plugin-side; conversation event
  listener (new inbound message → agent turn); tool registry mapping
  to core actions (start flow, send message/template, upsert contact,
  apply label); review queue UI for review/pause modes; usage metering
  through core `ai_usage_logs` so billing stays unified.
- **Safety rules for our build:** agents never send outside the WABA
  24h window except via approved templates (core rule); handoff must
  always be reachable — an agent that cannot hand off does not ship.
- **Priority:** Phase 4, AI group (after MCP + payments; with AI Flow
  Builder + Knowledge Base).
- **Difficulty:** Hard. The plumbing is core's; the hard part is
  conversation quality, tool-call safety and handoff correctness.
