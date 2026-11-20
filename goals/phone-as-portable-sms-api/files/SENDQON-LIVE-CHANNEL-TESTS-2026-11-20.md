# Sendqon — Live Channel Test Battery — 2026-11-20

Owner order (2026-11-20): "baki channels bhi online testing kro" — real sends, not just the
readiness audit. All tests ran server-side on offbox-1 against production
(https://sendqon.rektrs.com), using the app's own REST API and the companions' own
interfaces. Test traffic went ONLY to the owner's own numbers
(SIM1 ZONG +92 318 073 5877, SIM2 Ufone +92 332 877 6333, WhatsApp +92 347 416 2393).
No campaigns, no third-party recipients: 4 battery messages total (ids 38, 39, 42, 43).

A fresh backup was taken before any state-changing step
(`sendqon-db/config/storage-2026-11-20` artifacts, gzip-verified, push OK; the script's
`status=FAIL` print is the known spurious one).

Device identification (before testing): the owner's NEW device row is **device id 2** —
app version **5.2.1** (our own app), paired 2026-11-20 06:18:46 UTC, online, not paused,
SIMs: slot 0 = ZONG +923180735877 (sim id 3), slot 1 = Ufone +923328776333 (sim id 4).
The old device id 1 is the vendor app (5.0.4), paused, last seen 2026-11-18.
Device 2's receiver report (v5.2.1 companion reporting) shows installed/connected,
read_sms + receive_sms + notifications + battery-unrestricted all true.

Baseline corroboration: the owner had already sent two messages himself today via
Messenger — id 36 WhatsApp (status **read**) and id 37 SMS via SIM1 (status sent).

---

## 1. SMS via the paired Android device — MIXED: SIM1 PASS, SIM2-send FAIL, inbound PASS

Sent via `POST /api/v1/messages/sms` with `from_sim_id` pinning (app's own API).

| Test | Message | Result |
|---|---|---|
| SIM1 (Zong, sim 3) → SIM2 number | id 38, created 06:53:06 UTC | **PASS** — served 06:53:06, sent 06:53:11, final status `sent` |
| SIM2 (Ufone, sim 4) → SIM1 number | id 39, created 06:54:03 UTC | **FAIL** — served 06:54:03, failed 06:54:14 |
| SIM2 → SIM1 retry | id 42, created 06:55:35 UTC | **FAIL** — same failure |

- Both SIM2 attempts failed with the phone-side radio error the app recorded verbatim:
  error_code `result_111`, "Radio reported result_111." — the handset's radio rejected
  the send on the Ufone subscription, twice in a row. This is a device/SIM-side
  rejection, not a panel or queue failure (the message was served to the phone within
  a second both times).
- **Inbound path PASS:** the inbound copy of test message 38 appeared in the panel as
  message id 41 (sim 4, from +923180735877, status `received`, 06:55:19 UTC), and the
  inbound copy of the owner's earlier "hi" (id 37) as id 40 (06:55:18 UTC). Inbound
  reporting works, but it flushes in a batch when the app syncs — the two rows landed
  together, ~2 min after test 38 and ~27 min after the owner's send — it is not instant.
- Panel `delivered_at` for device SMS stayed empty: the panel records `sent` for
  id 38 and proves handset receipt through the inbound copy instead of a carrier
  delivery-report state.

**Verdict:** SMS sending from SIM1 (Zong) works end-to-end including inbound replies.
SMS sending from SIM2 (Ufone) currently fails at the phone's radio (result_111) while
SIM2 receiving works — worth a handset-side look (dual-SIM send settings / Ufone SIM
state) before relying on SIM2 as a sender.

## 2. WhatsApp (vendor server, account +92 347 416 2393) — PASS

One self-chat message via `POST /api/v1/messages/whatsapp` (to the account's own number):
message id 43, queued 06:56:53 UTC → **sent 06:57:05 UTC**, with a real WhatsApp
provider message id recorded. The session is alive: the panel's
`last_connected_at = 2026-11-16` is stale bookkeeping (the row's status timestamp
refreshed today 01:25 UTC, and the owner's own WhatsApp message id 36 earlier today
reached status `read`, proving delivery receipts also flow). Delivered/read ticks on
this self-chat were not observed inside the check window, which is normal for
messages to self. The own WhatsApp bridge (server 5) was not touched — cutover is a
separate owner decision.

## 3. SMPP (own Jasmin companion) — machinery PASS to the route boundary; delivery BLOCKED (expected)

Production Jasmin was completely empty before the test (0 users, 0 groups,
0 connectors, 0 routes — the B9 battery had run against the dev Jasmin). A TEST group
and TEST user were created via jcli for this test and removed afterwards (see cleanup).

- `bind_transceiver` → **ESME_ROK**; `enquire_link` → OK; `unbind` → clean.
  (Operational note: Jasmin enforces the SMPP 9-octet bind-password limit — the first
  bind attempt with a longer test password was rejected at PDU parse; a compliant
  password bound immediately.)
- `submit_sm` to +923180735877 was accepted and parsed by Jasmin, then answered
  **ESME_RINVDSTADR (0x0B)** with the router log stating the reason verbatim:
  "No route matched from user TESTSYS for SubmitSmPDU". With zero MT routes and zero
  SMSC connectors, there is nowhere for the message to go — delivery failure at the
  route is the expected, honest end state until an upstream aggregator bind exists
  (Phase C of the aggregator track). The app-side server row "Primary SMPP (Own)"
  (id 6) shows healthy, inert with zero gateways, exactly as B9 left it.

**Verdict:** bind + submit + routing machinery proven live on production; end-to-end
delivery blocked solely by the missing upstream route.

## 4. Website Widget — PASS

A TEST widget channel was created exactly the way the panel creates it
(`WidgetQuota` + `ChannelConnection`), then exercised through the public visitor API
the real embed uses:

- `GET /widget.js` → 200, 44,618 bytes (loader serves).
- A fresh widget is intentionally **not live** until a site domain is registered
  (`WidgetRuntime` state `no_domains`) — the panel's own Install step. After adding a
  TEST domain to the widget config: launcher config served, `POST .../session`
  returned live + a visitor token ("Visitor 0001"), and
  `POST .../messages` delivered a visitor message into the inbox:
  channel_messages **id 49**, channel `widget`, conversation **id 13 (open)**,
  status `received`.
- The embed's JS rendering in a real browser was not covered (this lane has no
  browser); everything server-side of the channel is proven.
- All TEST widget artifacts were deleted afterwards (verified 0 remaining).

## 5. Web Push — BLOCKED

`push_subscription_states` holds **0 subscriptions**: a web-push subscription can only
be created by a real browser running the push site's service worker, and with no
subscriber in existence there is no recipient to send to. Not testable from the
server side alone.

## 6. Verdict-only channels (no live test possible — exact blocker)

- **Telegram Bot** — BLOCKED: Telegram server (id 3) is healthy, but zero Telegram
  channels exist; no bot token has been configured (owner credential step).
- **Telegram Account** — BLOCKED: same companion; no Telegram account session is
  linked (needs the owner's api credentials + sign-in).
- **Email channel** — BLOCKED: Email server (id 4) is healthy, but no mailbox
  credentials are configured; zero email connections exist.
- **WABA** — BLOCKED: zero WABA accounts; needs the owner's Meta business assets.
- **GSM Modem** — BLOCKED: telephony server row 7 "Primary Telephony (Own)" sits in
  `pending` state and the production modem daemon is deliberately not started;
  no live modem is attached.
- **Phone Bridge (calls)** — BLOCKED: PBX Telephony server (id 8) is healthy, but
  zero phone lines are paired; pairing the owner's phone is the B10.2 owner gate.
- **SMS Provider (external)** — BLOCKED: zero rows in `sms_providers`; no aggregator
  account/credentials exist yet (aggregator track, owner side).

## 7. Backup-restore dry test (pairing battery part 2) — PASS (decrypt scope)

Today's fresh backup DB dump was extracted in a scratch directory on the host
(production untouched). The dump contains 4 Laravel-encrypted payloads; one was
decrypted with the production APP_KEY through the app's own Crypt service —
**DECRYPT_OK** (plaintext length 1,704; content never printed). This proves the
backup and the production APP_KEY are consistent, i.e. encrypted values in a restore
would be readable. Scratch directory removed afterwards. A full restore rehearsal
was not performed (it would need a scratch stack; the decrypt check was the part
that could be done with zero production risk).

## Cleanup list (everything created for this battery)

| Artifact | Fate |
|---|---|
| API access token named "TEST channel battery 2026-11-20" (owner user) | Deleted; verified 0 remaining. Token file on host removed. |
| Jasmin group `TESTGRP` + user `test20261120` / system id `TESTSYS` | Removed via jcli and persisted; verified 0 users / 0 groups. Credential scratch files removed from the container and host. |
| TEST widget connection (id 1) + its visitor, conversation 13, message 49 | All deleted; verified 0 remaining. |
| Backup scratch dir `/tmp/sqrestore-check` | Removed. |
| Test messages 38, 39, 42 (SMS) and 43 (WhatsApp) | Kept in the message logs as the audit trail of this battery (owner's own numbers only). |

## Bottom line

- **Working live today:** SMS out via SIM1 + inbound replies, WhatsApp sending on the
  vendor server, the website widget channel end-to-end, and the SMPP server's
  bind/submit machinery up to its (empty) route table.
- **One real defect found:** outbound SMS from SIM2 (Ufone) is rejected by the
  phone's radio (result_111, twice) while SIM2 receives fine.
- **Everything else is blocked on a named owner-side input** (credentials, Meta
  assets, phone pairing, aggregator account, a real browser subscription) — not on
  broken machinery.
