# Sendqon — AI Agent live-WhatsApp no-reply: diagnosis + fix (2026-11-26)

**Symptom:** the owner sent a real WhatsApp message to +92 347 4162393 from his Ufone number +92 332 877 6333 at ~21:00 PKT (16:00 UTC) and the "Rektrs Assistant" agent did not reply — the KB lane's proof had only exercised the flow engine's test entry point, never a real inbound message.

**Result: ROOT CAUSE FOUND, FIXED, AND PROVEN LIVE end-to-end.** The chain broke at exactly one link: a stale per-conversation "handed over to a human" state, left over from the owner's own manual reply in that same conversation on 2026-11-20. After resetting that state through core's own contract, the agent answered the waiting message and every subsequent live message; the replies were delivered to — and read on — the owner's phone.

---

## The chain, link by link (all times UTC; PKT = UTC+5)

**1. Did the message arrive? YES.**
`channel_messages` id 256 "Hi" (16:02:18) and id 257 "Aslam O Alikum" (16:02:44), channel `wa`, connection_id 1, direction `in`, status `received`, source `inbound`, conversation **11**, contact 3 (+923328776333, "Asad Choudhary"). Both rows are clean automation candidates: `locked_at` null, `plan_held_at` null, no group meta, kind text. **The vendor WhatsApp server's inbound path feeds core's conversation store exactly like any other channel — the "different path" suspicion is disproven.**

**2. Conversation state.** Conversation 11: created 2026-11-20 06:28:36, status `open`, `assigned_agent_id` **null** (unassigned — the assignment gate was NOT the blocker), primary_channel `wa`, inbound_count 2.

**3. Agent config.** Agent id 1 "Rektrs Assistant": `is_active=1`, channels `[{"channel":"wa","connections":["wa:1"]}]`, model `gemini-3.5-flash-lite`. WA account 1: status `connected`, `receive_inbound_enabled=1`, quiet hours 22:00–07:00 enabled — the test at 21:02 PKT / 16:02 UTC is outside quiet hours under either clock. **Config, pinning, quiet hours: all innocent.**

**4. Did the agent engine see it? NO — and this is the break.**
No `ai_agent_turns` row exists for conversation 11 before the fix (turns 1–8 are all the KB lane's test conversations), no failed job, no log error for the window. The dispatch path is: `ChannelMessageReceived` → `DispatchFlowsForChannelMessage` (flows first; none matched) → `AiAgentsRuntime::unanswered()` → `HandleAiAgentMessage` job on the `ai-agents` queue → `AgentRunner::handleMessage()`. The runner's gates for conversation 11 pass on status/assignment/group — and then hit this one:

> `ai_agent_conversations` row id 2: conversation_id 11, **state `handed_over`, reason `human_replied`, created 2026-11-20 06:28:45** — the exact timestamp of outbound message 37, the owner's own manual "hi" sent from the panel in this conversation on 2026-11-20. Core's `ConversationActivity` marks a conversation human-owned the moment a human replies in it, and `AgentRunner::handleMessage()` returns **silently** (no turn, no error, by design) for any conversation whose state is not `active`.

A new inbound round does **not** clear this state (conversation 11's `round_started_at` updated to today 16:02:19 and the row still blocked). So the agent was never going to answer this conversation — the owner's test number is his own second SIM, and its conversation carried a six-day-old human-takeover mark from his own earlier manual test messages (ids 37/38, 2026-11-20).

**5. Reply path.** Never reached pre-fix. Post-fix it is proven working (below): replies went out through core's `AutomatedMessageSender` → vendor server, with delivery/read receipts from the owner's actual phone.

## The fix

1. Fresh verified backup first (`backup.sh`: status=OK, push=OK, 2026-11-26 artifacts gzip-present).
2. Reset the stale state through **core's own contract**: `AiAgentsRuntime::roundReset($conversation)` (the designed reset — deletes the state row), run as www-data. Row verified gone.
3. Re-dispatched the runtime's `unanswered()` for the waiting message 257 — exactly the call the listener makes — which queued `HandleAiAgentMessage` job 117045 on `ai-agents`.
4. No core or plugin code was changed. No patch registration needed. Nothing about the WhatsApp account, the agent, or the KB was touched.

## Proof (live, minutes later)

- The `ai-agents` queue drained on the next scheduler cycle (~1 min; 4 jobs were briefly visible because the owner was simultaneously retesting).
- `ai_agent_turns` 9–14 for conversation 11, **all outcome `replied`** — turn 9 (message 257) ran `search_knowledge` + `reply`; the state row was recreated as `active`, agent 1, messages_handled 6.
- Outbound replies (source `automation`): ids 261/262 status **`read`**, 263 **`delivered`**, 264 queued→sent under the account's 8–22 s throttle. "Read" is the owner's own phone reporting he opened them — the full vendor-server send path is proven, not just the panel side.
- The owner kept testing in real time ("Kya hal hy", "Yeah same jawab q Dy rahy hoo") and the agent answered contextually (turns 13/14), including apologising for the repeated greetings.

## Honest side-notes

- **Repeated greetings artefact:** four backlog messages (257 + the owner's three rapid retests) were processed in one drain cycle, so the first replies repeat the same greeting. That is a backlog artefact of this repair, not normal behaviour — each message after the backlog got a single contextual reply.
- **Same stale state exists on conversation 1** (`handed_over`/`human_replied`, also 2026-11-20). Any pre-existing conversation in which a human has ever replied will stay agent-silent until its state is reset — that is core's designed human-takeover behaviour, and it is correct for real customer chats. New customer conversations are unaffected (the KB lane's fresh test conversations all answered).
- Practical consequence for the owner: if he ever replies manually inside a customer conversation, the agent goes silent in that conversation from then on; the panel's agent pause/resume controls (or a state reset like this one) are how it is handed back.

## Retest instructions

None outstanding — the owner has already proven it himself on his own phone. Any new WhatsApp message to +92 347 4162393 from a number whose conversation has no human takeover will be answered by Rektrs Assistant from the KB within about a minute (queue drain + account throttle).
