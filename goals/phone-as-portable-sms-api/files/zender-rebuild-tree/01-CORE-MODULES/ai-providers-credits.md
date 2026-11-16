# CORE — AI Providers & AI Credits

**Status: core-owned (purchased). The paid "AI Agents / AI Flow
Builder / Knowledge Base" plugins build ON this core — see
`02-PAID-PLUGINS/`.**
Sources: Lane 2 (AI), Lane 4 §§A–B, Lane 5 §§2, 4.

## Purpose
One AI substrate for the whole platform: provider registry, per-feature
pricing, a shared credit wallet (SMS + WABA + AI draw from the same
credits), and BYOK (tenants bring their own keys).

## Screens / pages
- Admin > AI Providers: 1 demo provider (Anthropic, model
  `claude-haiku-5-5`, 1,024 max tokens, 10 credits/request).
- Tenant Billing > AI Usage (usage history); Billing > API Keys for
  BYOK keys.
- Tenant > AI Agents page exists in the demo (8 agents, all Off) — the
  agent *logic* is the paid plugin; the page shell + credits are core.

## Providers & capabilities
Anthropic, OpenAI, Grok, DeepSeek, OpenRouter, ElevenLabs.
Capability caps: OpenAI = everything; OpenRouter = Chat + Embeddings;
Anthropic/Grok/DeepSeek = Chat; ElevenLabs = Speech only.
Max Tokens configurable 64–16,000. Fallback providers are tried in
configured order. SDK note: providers register as `ai_integration`
plugins with a runtime contract (Lane 5 §5.2).

## Pricing & wallet rules
- Pricing precedence: **Feature > Model > Per Call**. Embeddings priced
  per 1k tokens, speech per 1k chars, transcription per minute.
- No price set = the call is **refused**; price 0 = free. Credits are
  deducted first and **refunded on failure**. The admin workspace is
  free.
- Seeded plan AI allowances: Free 0 credits / BYOK off; Starter 100 /
  off; Pro 500 / on; Enterprise 2,000 / on.
- **BYOK:** keys stored under Billing > API Keys, charged 0 credits.
  On provider refusal there is **no fallback to the platform key**.
  Downgrading the plan makes the key useless. **APP_KEY rotation
  destroys stored BYOK keys** (they are APP_KEY-encrypted) — coordinate
  with `05-INFRA.md`.

## Data (tables)
`ai_providers`, `ai_usage_logs`, `user_ai_keys`,
`user_ai_feature_models`, `plan_ai_provider`, `prompt_assets`
(voice/AI prompts), plus `knowledge_*` and `mcp_*` (owned by the
plugin specs in `02-PAID-PLUGINS/`).

## API surface
No public tenant API for provider admin; AI is consumed internally by
flows (AI Message node), AI Write in campaigns, AI Translate in
`localization.md`, and the AI plugins.

## Plan gates
AI credits allowance per plan; BYOK toggle per plan; `ai_agents` /
`ai_flow_generation` switches gate the paid-plugin surfaces.

## Keep / extension notes
- Core-owned. When we build AI Agents / AI Flow Builder / Knowledge
  Base, we consume this registry + wallet — we do not add a second
  billing path. New AI providers (e.g. a local model) attach as
  `ai_integration` plugins.
