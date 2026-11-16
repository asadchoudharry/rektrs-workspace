# PAID PLUGIN SPEC — AI Flow Builder

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/ai-flow-builder/
- **Demo state:** Active/Configured (AI), Lane 4 §C.
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Generate a complete chat flow from a plain-language description.

## Features
AI builder that creates flows with nodes, steps, conditions and
branches; ready-made templates; **editing by chat** (adjust, remove,
rebuild, redo); an edit history; a preview before the flow is added;
a complete flow from a short description.

## Workflow
Upload → activate → enable Chat Flows + AI Flow Builder on the plan →
add OpenAI API key in Configure → Chat Flows > AI Builder → describe
the flow in plain language → preview → add to flows.

## Logic / technology
Core exposes the `FlowAiBuilder` contract (Lane 5 §5.3) and the flow
schema (`flows`, `flow_nodes`, `flow_edges` with engine caps: 500
nodes / 1,000 edges). The generator must emit flows that validate
against the engine's node catalogue and expression language
(`../01-CORE-MODULES/flows-drips.md`). Generation consumes AI credits
via the core wallet; the plan switch is `ai_flow_generation`.

## Data it touches
`flows`, `flow_nodes`, `flow_edges`, `ai_usage_logs`; content
published through it can be auto-indexed by the Knowledge Base
(`knowledge-base.md`).

## Dependencies
OpenAI account + API key (per vendor page); Chat Flows; plan switch
`ai_flow_generation`.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) implementing
  `FlowAiBuilder`.
- **Key interfaces:** prompt → structured flow JSON (validated against
  the node catalogue before save); preview renderer (reuse the flow
  canvas in read-only mode); chat-based edit operations (add/remove/
  modify node, re-branch) with an edit history table (plugin-owned);
  template library seeded with common flows (welcome, OTP, order
  status, appointment).
- **Validation rule:** a generated flow that fails engine validation
  is never saved — the builder repairs or reports, mirroring the
  engine caps.
- **Priority:** Phase 4, AI group (with AI Agents + Knowledge Base).
- **Difficulty:** Medium. Generation is an LLM task; correctness is a
  schema-validation task — the contract keeps it bounded.
