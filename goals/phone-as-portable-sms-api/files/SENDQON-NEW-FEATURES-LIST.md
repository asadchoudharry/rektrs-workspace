# Sendqon — New Features List

**Purpose:** features the owner has registered for Sendqon to be built LATER. Registration is not a build order — an item is built only when the owner says so. Each item records what is needed, what already exists, and what decision it carries.

---

## NF-1 — Postqon ke liye asal one-click OAuth connect (Sendqon-side izafa)

**Registered:** 2026-11-19 (owner, via the Postiz chat) · **Status:** REGISTERED — build nahi karna; jab owner kahega tab hoga.

**Context:** Postqon (social.rektrs.com) ka Sendqon Connector v1 ban chuka hai — user apni API key paste karke Connect & test karta hai. Asal one-click connect ke liye Sendqon ki taraf se ye chahiye:

1. **Postqon ko first-party OAuth client ke tor par register karna** — redirect URI: `https://social.rektrs.com/developers/sendqon/callback`. Sath confirm karna ke OAuth se mila token aam REST Bearer ke tor par send abilities (`wa.send`, `sms.send`, `account.view`) ke sath kaam kare. **Maujooda haal:** OAuth ka istemal abhi sirf MCP endpoint par proven hai, aur wo plan `mcp` flag ke peeche hai — **plan gating ka faisla bhi isi item ka hissa hai** (kis plan par OAuth-issued REST tokens chalenge).
2. **Media-upload endpoint ko customer OpenAPI/docs mein publish/confirm karna** — endpoint mojood hai aur Postqon ki taraf se pin ho chuka hai: `POST /api/v1/whatsapp/media`, field `file`, ≤ 51200 KB, top-level `media_path` return karta hai. Sirf documentation wala hissa baqi hai.
3. **(v2 nicety) `GET /api/v1/whatsapp/accounts`** — taake Postqon workspace ke default number par khamoshi se bhejne ke bajaye user ko number SELECT karne de sakay.
