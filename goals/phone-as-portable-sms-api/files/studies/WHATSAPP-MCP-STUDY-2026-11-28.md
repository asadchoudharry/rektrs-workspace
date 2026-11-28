# Study — whatsapp-mcp (lharries/whatsapp-mcp) as a reference for Sendqon's MCP registry

**Date:** 2026-11-28 · **Studied for:** reference only — what this personal-WhatsApp MCP server's tool surface teaches our own MCP registry design, and a clear statement of the boundary it must never cross. It is not a candidate for deployment in any form.
**Sources:** GitHub repo + API (checked live 2026-11-28), repo `LICENSE` and README verbatim (tool list and architecture are quoted from the README). READ-ONLY study — nothing was installed or deployed.

## What it is

A **personal** MCP server that connects an LLM (Claude Desktop / Cursor, running locally) to the user's **own personal WhatsApp account**. Two parts: a Go bridge built on **whatsmeow** that pairs as a linked device to the account, mirrors message history into a **local SQLite database**, and stays connected; and a Python MCP server (local stdio) that exposes that database — plus sending through the bridge — as 12 tools. Repo stats at study time: **6,970 stars, 1,538 forks, 277 open issues**, created 2025-03-29; only release **v0.0.1 (2025-04-06)**; last push 2025-07-13 (a README edit) — a viral, single-author project whose code cadence has effectively stalled since mid-2025.

### The tool surface (README, verbatim names)

`search_contacts` · `list_messages` (filters + context) · `list_chats` · `get_chat` · `get_direct_chat_by_contact` · `get_contact_chats` · `get_last_interaction` · `get_message_context` (the messages around a specific message) · `send_message` · `send_file` · `send_audio_message` · `download_media` (fetch a message's media to a local path).

The shape to notice: **9 of the 12 tools are read/history tools**, and they are *conversational* reads — search across history, open a chat, pull context around one message, find the last interaction with a person. The sends are almost an afterthought.

## 1. Licence

**MIT** (repo `LICENSE`, © Luke Harries, read verbatim). Legally we could reuse all of it. We will not, for reasons that are architectural and ethical rather than legal (§6) — the licence section of this study exists to record that the barrier is *our choice*, not the licence's.

## 2. What it adds that we don't have — the one transferable lesson

Our MCP registry (30 tools live; census in `../SENDQON-AUTOMATION-MCP-DESIGN-2026-11-28.md`) is **send- and account-centric**: send SMS/WhatsApp, list accounts/groups, account views. Its read side is thin on *conversation history as a queryable surface*. whatsapp-mcp demonstrates the read shape that LLM clients actually use well:

- **Search-first history access** — a `search-messages` tool (by contact, keyword, date range) beats list-everything pagination for an LLM consumer.
- **Context-window retrieval** — `get_message_context` (N messages around a target message) is exactly the primitive an agent needs to answer "what did we agree with this customer?" without ingesting a whole thread.
- **Last-interaction lookup** — a cheap, high-value summary primitive.

**The transferable version for Sendqon is legitimate and already consistent with our model:** READ tools over a **tenant's own workspace channel history** — the same conversations the tenant already sees in their own panel, scoped by the same tenant/ability rules (`wa.accounts.view`-class abilities), exposed through the registry with the design's rate limits and audit. That is a Phase 2-style gap-tool candidate to add to the census list (search-messages / get-conversation-context over `channel_messages`), *not* a new product: the data is business channel data the tenant owns, not anyone's personal account. Flagged here for the Phase 2 tool list; the design's §4 safety model (tool-layer scoping, audit, no secrets returned) already covers it.

What does **not** transfer: history *sync/mirroring* as a feature (Sendqon already records its own channels' traffic in core — no mirror needed), and any read of a **personal** account's history (see §6).

## 3. Stack fit

None, deliberately. Its architecture (a whatsmeow linked device + a full-history SQLite mirror + a local stdio server with no auth, no tenancy, no audit) is the inverse of Sendqon's companion model (service-token contracts, workspace scoping, per-account session tokens, plan gates). There is no slot in our stack this fits, including on the owner's own infrastructure *as a Sendqon component*.

## 4. Integration route

**Reference-only.** No plugin, no companion, no API link, no code reuse.

## 5. Effort

- This study only.
- If the owner wants the §2 read tools added to the registry census: they join the existing Phase 2 gap-tools lane as 2 small READ tools — no separate lane, no new surface.

## 6. Risk — and the boundary statement

The project's own README carries the correct warning, quoting Simon Willison's **"lethal trifecta"**: an agent with (1) access to private data, (2) exposure to untrusted content, and (3) a channel to exfiltrate — prompt injection in an incoming WhatsApp message can steer the connected LLM into leaking the user's chat history. That risk is inherent to the shape, not a bug in this implementation. Add: the full personal history sits in a **plaintext SQLite file** on the machine; the bridge is an unofficial-protocol linked device on a **personal** account (the same ban category as every Baileys-class tool — here the number at risk is a person's primary identity number); the session needs re-authentication roughly every 20 days (README), so it is not even operationally quiet.

**The boundary, stated plainly for the record:**
- whatsapp-mcp's legitimate home is exactly one place: **the account owner's own machine, connected to their own MCP client, reading their own account, at their own risk.** If the owner ever wants it personally, that is a personal-tool decision on his laptop — it is not Sendqon work and no lane will be opened for it from this corner.
- It must **never** become: a Sendqon tenant feature; a server-side reader of any personal WhatsApp account (ours, a tenant's, or a customer's); a support shortcut ("just read the customer's WhatsApp to see what happened"); or a data source for the KB/agents. Sendqon's WhatsApp data is business channel data flowing through B8/the vendor server under workspace scoping — the moment personal-account reading enters the product, the trust model of the whole platform changes, and no feature justifies it.

## 7. Maintenance health (live-checked 2026-11-28)

6,970 stars / 1,538 forks — popularity is not in question. Health is weaker than the stars suggest: a single tagged release (v0.0.1, 2025-04-06), last code-era push 2025-07-13, 277 open issues against a stalled cadence, single author. whatsmeow underneath it is actively maintained (tulir), but this wrapper is not keeping pace. For a reference study this hardly matters; for the record, it is another reason nothing here should ever be load-bearing.

## 8. Verdict — **REFERENCE-ONLY** (tool-shape lesson adopted; the software itself: **NO-GO** in any Sendqon context)

Adopt: the read-tool shapes (search, context-window, last-interaction) into the MCP registry census as tenant-scoped READ tools over Sendqon's own channel history. Reject: the software, its architecture, and its data posture, in full, for anything connected to Sendqon or to any account other than a private individual experimenting on their own machine.

**One-line verdict: whatsapp-mcp is a good teacher of how LLMs want to read conversations — and a clean example of a data posture (personal-account mirror, no tenancy, no audit, lethal-trifecta exposure) that Sendqon must never import.**
