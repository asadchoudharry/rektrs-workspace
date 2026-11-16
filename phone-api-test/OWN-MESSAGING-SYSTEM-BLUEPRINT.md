# Apna Messaging System — Blueprint (Zender jaisa, 100% apna)

Goal: Zender ke saare system ka apna version — Android phone as SMS gateway +
WhatsApp + campaigns + shared inbox + SaaS billing — poori malkiyet Rektrs ki,
koi vendor lock-in, koi per-plugin fees nahi. Operqon se direct integration.

## Pehle se prove shuda
- Phone -> SMS gateway: 2026-11-13 ko Assad ke Redmi Note 12 par SMS Gate se
  LIVE prove ho chuka (dashboard -> cloud -> SIM -> SMS received).
- Android gateway ka legal base mojood hai: SMS Gate (Apache 2.0, open source)
  fork, YA usi design par clean-room apni Kotlin app.

## Components (Zender parity list)
1. Android Gateway app — QR pairing, dual-SIM, send/receive SMS, delivery
   reports, USSD, foreground service, heartbeat. [APNA / fork — source hamara]
2. Server core — device registry, message queue, FCM push + polling fallback,
   REST API (scoped API keys), signed webhooks, OTP verify service.
3. Web dashboard — workspaces (multi-tenant), contacts/groups/tags, CSV import,
   opt-out handling.
4. Campaigns — bulk send, scheduling, send windows, duplicate protection,
   spintax, link tracking.
5. Shared inbox — SMS + WhatsApp conversations ek jagah, WebSocket live,
   assignment/labels/quick replies.
6. WhatsApp — (a) Official WABA via Meta API (safe, pehle), (b) QR-linked
   unofficial via open-source engine (Evolution API type) — number-ban risk
   ke sath, baad mein aur alag warning ke sath.
7. Cloud SMS providers — Twilio etc. + Custom HTTP provider (vendor-agnostic).
8. Chatbot flow builder — drag-drop canvas, keyword triggers, branching, drips.
9. SaaS layer — plans, message credits, vouchers, invoices, payments
   (bank transfer + PayPal pehle; Stripe/local gateways baad mein), admin panel,
   support tickets, landing pages.
10. Extras — AI assist/agents, MCP tools for agents, RCS, USSD schedules.

## Phases (estimates — Assad ki approval ke baad hi koi phase shuru hoga)
- Phase 1 MVP: components 1–4 ka core (gateway app, server, dashboard,
  contacts, simple campaigns, API + webhooks, single workspace).
  Andazan: chand haftay focused build. Yehi ~70% practical value hai.
- Phase 2 SaaS: component 9 + multi-workspace hardening (9–10 ka admin hissa).
- Phase 3 WhatsApp: pehle WABA official, phir QR wala.
- Phase 4 Advanced: shared inbox full, chatbot builder, AI/MCP, extras.

## Operqon integration (Phase 1 se hi design mein)
- API-first design: Operqon ka har tenant apna workspace khud connect karega
  (service-provider principle: tenant ke apne credentials).
- Operqon triggers: invoice SMS, payment reminder, delivery note, OTP,
  CRM campaign — per-integration pricing model ke mutabiq.
- NOTE: Operqon abhi Cursor-handover/stop state mein hai — ye system STANDALONE
  banta hai, Operqon-side wiring Cursor ke through / stop lift honay par.

## Buy vs Build — seedha hisaab
- Zender khareedo: launch dinon mein, lekin Android app band, calls/MCP/AI/Stripe
  sab paid plugins, Extended License, vendor ki discretion par free plugins.
- Khud banao: waqt zyada, lekin source, features, pricing, data — sab apna.
  Koi hissa aisa nahi hai jo technically hamari pounch se bahar ho.

## Risks / honest notes
- WhatsApp QR wala hissa Meta ke terms ke khilaf ja sakta hai; number ban
  risk hamesha rahega — is liye wo Phase 3 mein, warning ke sath, optional.
- Consumer SIM par bulk SMS = carrier throttle/block risk; campaigns mein
  rate limits aur opt-out lazmi hain.
- 100% Zender parity ek moving target hai; strategy parity nahi,
  "pehle 70% value wala core, phir baqi" hai.
