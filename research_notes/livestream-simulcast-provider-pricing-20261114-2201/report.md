# Livestream Simulcast Provider Pricing — Research Report

Researched: **2026-11-14** (pages crawled / verified live 2026-11-14 22:01–22:03 UTC).
Scenario throughout: a SaaS integrates a hosted provider via API; creators send **one** stream in (RTMP or browser WebRTC); the provider simulcasts to the creator's own YouTube / Facebook / LinkedIn / Twitch destinations; **no viewers watch on the provider itself**.

> Prices change. Where a page shows its own date it is noted per provider; otherwise "no date shown on page — accessed 2026-11-14".

## Summary

- **Cheapest for the simulcast-only scenario (worked example, below): api.video on paper — ≥ $1.71/month** — because encoding is free and restreaming is stated to be at no additional cost, leaving only recording storage. **Caveat:** its hosting/delivery rates are only published as "as low as" floor rates; the rate a low-volume account actually pays is **not published**, so $1.71 is a floor, not a quote.
- **Cheapest with fully published rates: Cloudflare Stream — $6.80/month** for the worked example. Ingest/encoding are free; simulcast outputs are billed as ordinary delivered minutes ($1 / 1,000 min, per output), and one prepaid $5 storage block covers the recordings.
- **Mux — $36.55/month** for the worked example after its $20 pay-as-you-go credit ($56.55 before credit). The dominant cost is not ingest ($18.75) but **simulcasting itself: $0.020/min per target = $36.00 for 3 targets**.
- **Livepeer Studio — $100.00/month** for the worked example, despite only $4.20 of metered usage, because its Pay-As-You-Go plan has a **$100 minimum monthly spend**.
- **AWS IVS — does not fit the scenario at all.** It has **no RTMP egress / simulcast to external platforms**. Its low-latency channels deliver HLS only to IVS viewers, and its Real-Time composition destinations can only be an IVS channel or an S3 bucket. Saying so plainly, as requested: **do not pick IVS for simulcast-only; you would still need a separate restream service / your own fan-out.**
- **Simplest to integrate via API:** **api.video or Mux**. api.video takes restream destinations as a `restreams` array in the same create-live-stream call and charges nothing extra for them; Mux takes `simulcast_targets` in the create-live-stream call and has the most explicit simulcast docs/webhooks, but charges per target. Cloudflare is also simple (create live input, POST outputs) but has a critical WebRTC caveat (below).
- **Browser (WebRTC) ingest is NOT interchangeable with simulcast on every provider:**
  - **Mux: no WebRTC ingest at all** — RTMP/RTMPS/SRT only.
  - **Cloudflare: WebRTC (WHIP) ingest exists and is GA, but WHIP inputs cannot simulcast and cannot be recorded** — for simulcast you must ingest via RTMPS/SRT.
  - **api.video: no WebRTC/WHIP ingest published** — RTMP/RTMPS/SRT only.
  - **Livepeer Studio: yes** — RTMP and WebRTC/WHIP, with a browser Broadcast component, and multistream is supported.
  - **AWS IVS: yes** (Web Broadcast SDK / WHIP to stages) — but irrelevant here because there is no external simulcast out.

---

## Findings

### 1. Mux (Mux Video live streaming + simulcast)

Sources: pricing page https://www.mux.com/pricing (no date shown; accessed 2026-11-14, index + live TOC check), pricing docs https://www.mux.com/docs/pricing/overview (no date shown; accessed 2026-11-14), simulcast guide https://www.mux.com/docs/guides/stream-live-to-3rd-party-platforms, live FAQ https://www.mux.com/docs/guides/live-streaming-faqs.

- **Simulcast:** Yes. "Simulcast a Mux live stream to platforms such as YouTube, Facebook, and Twitch… Mux Simulcasting works with any arbitrary RTMP server" — targets listed include Facebook Live, YouTube Live, Instagram Live, Twitch, Crowdcast, Vimeo, and by extension LinkedIn or any RTMP/RTMPS destination (https://www.mux.com/docs/guides/stream-live-to-3rd-party-platforms).
- **Destination limit:** **6 simulcasts/restreams per live stream** (same URL; also FAQ: "Mux Video live service supports up to six simultaneous restreams", https://www.mux.com/docs/guides/live-streaming-faqs).
- **Per-destination charge:** **Yes — $0.020 / min / simulcast target** (https://www.mux.com/pricing; confirmed in https://www.mux.com/docs/pricing/overview: "$0.020 per minute per simulcast target"). This is a separate add-on line on top of live ingest, not part of viewer-delivery minutes.
- **Ingest/encoding price:** Live requires the **plus or premium** quality level (basic is on-demand only); live is capped at 1080p. Plus, first 5,000 minutes: **$0.025/min up to 720p, $0.03125/min at 1080p**. Premium, first 5,000 minutes: $0.0375/min (720p), $0.046875/min (1080p) (https://www.mux.com/docs/pricing/overview).
- **Delivery/egress in a simulcast-only scenario:** Viewer delivery is $0.001/min at 1080p (basic+plus table, first 500,000 min) **after the first 100,000 delivered minutes each month, which are free** (https://www.mux.com/docs/pricing/overview). With zero viewers on Mux, viewer-delivery cost is **$0** — but simulcast minutes are still charged separately as above, so "no viewers" does **not** make Mux free.
- **Recording/storage:** Automatic. Mux "will automatically start creating an on-demand asset in the background when you begin broadcasting" and the FAQ confirms an on-demand asset is created after the stream ends (https://www.mux.com/docs/pricing/overview; https://www.mux.com/docs/guides/live-streaming-faqs). Storage (basic+plus quality, verified live via the page's table of contents heading "Basic and plus quality storage"): **$0.003/min/month at 1080p** ($0.0024 at ≤720p), prorated by time stored. Automatic Cold Storage: a new asset starts in the Cold tier until first played; cold rate at 1080p is $0.0012/min/month, infrequent (30+ days unplayed) $0.0018 (https://www.mux.com/docs/pricing/overview).
- **Free tier / trial:** Free plan: on-demand only, up to 10 videos stored, 100K free monthly delivery minutes — **no live**. Pay-As-You-Go (needed for live): **$20 monthly usage credit**, plus the standing 100K free delivery minutes/month. Paid plans can create free **test live streams** (watermarked, 5-minute limit, disabled after 24 hours) (https://www.mux.com/pricing; https://www.mux.com/docs/guides/live-streaming-faqs). Prepaid credit plans: Launch $20/mo for $100 credit; Scale $500/mo for $1,000 credit (https://www.mux.com/pricing).
- **Browser WebRTC ingest:** **No.** FAQ, verbatim in substance: "We currently do not support direct WebRTC ingest to a Live Stream. We have focused on RTMP and RTMPS for live streams…" — going live from a browser requires converting the browser stream to RTMP first (i.e. extra tooling of your own) (https://www.mux.com/docs/guides/live-streaming-faqs).
- **Minimum / platform fee:** No minimum on Pay-As-You-Go (no platform fee published); prepaid credit plans are optional.

**Worked example — Mux (Plus, PAYG):**
- Input: 600 min × $0.03125 = **$18.75**
- Simulcast: 600 min × $0.020 × 3 targets = **$36.00**
- Viewer delivery: **$0.00** (0 viewers; also within the 100K free minutes)
- Storage: 600 min × $0.003 = **$1.80** (headline frequent rate, one month)
- Gross: $18.75 + $36.00 + $1.80 = **$56.55**; minus $20 PAYG monthly usage credit = **$36.55/month**
- Assumptions: Plus (not Premium) quality; first-tier rates; recordings counted at the headline storage rate for a full month. Because the recordings are never played on Mux in this scenario, Automatic Cold Storage would in fact price that storage at $0.0012/min ($0.72), giving $55.47 − $20 = **$35.47** — the table below uses the conservative $36.55.

### 2. Cloudflare Stream (live inputs + outputs/simulcast)

Sources: pricing docs https://developers.cloudflare.com/stream/pricing/ (**page shows Updated: 2026-10-27**; accessed 2026-11-14), simulcast docs https://developers.cloudflare.com/stream/stream-live/simulcasting/ (**Updated: 2026-04-21**), live overview https://developers.cloudflare.com/stream/stream-live/, WebRTC docs https://developers.cloudflare.com/stream/webrtc-beta/ (served at /stream/webrtc/), plans page https://www.cloudflare.com/plans/application-services/ (no date shown; accessed 2026-11-14).

- **Simulcast:** Yes — called Outputs. "Simulcasting lets you forward your live stream to third-party platforms such as Twitch, YouTube, Facebook, Twitter, and more" via RTMP/SRT outputs added by API (`POST …/stream/live_inputs/<INPUT_UID>/outputs`), addable/removable mid-broadcast (https://developers.cloudflare.com/stream/stream-live/simulcasting/).
- **Destination limit:** **Up to 50 concurrent destinations per live input** (same URL).
- **Per-destination charge:** No per-target fee and no separate simulcast SKU. Instead, **simulcasting counts as delivery**: the pricing page lists "Simulcasting via SRT or RTMP live outputs" under Minutes Delivered, billed at the normal **$1 per 1,000 minutes delivered** — i.e. effectively $0.001/min **per output** if each output is metered as a delivered stream (assumption stated in the worked example) (https://developers.cloudflare.com/stream/pricing/).
- **Ingest/encoding price:** **Free — $0/min at any resolution.** "Ingress (sending your content to us) and encoding are always free. Bandwidth is already included in 'video delivered' with no additional egress fees." Live and on-demand are billed the same way, on only two dimensions: minutes stored and minutes delivered (https://developers.cloudflare.com/stream/pricing/).
- **Delivery/egress in a simulcast-only scenario:** Viewer delivery ($1/1,000 min) does **not** apply when nobody watches on Cloudflare — the pricing page's own example: "A live broadcast with no viewers will cost $0 for minutes delivered, but the recording of the broadcast will count toward minutes of video stored." **However**, simulcast outputs are an explicit exception: they **do** count as delivered minutes even with zero Cloudflare viewers (same URL). There are no separate bandwidth/egress fees.
- **Recording/storage:** **All Stream Live (RTMP/SRT) broadcasts are automatically recorded**; recordings are available within ~60 seconds of stream end (https://developers.cloudflare.com/stream/stream-live/). Storage is **prepaid, $5 per month per 1,000 minutes of storage capacity**, bought in $5 increments (https://developers.cloudflare.com/stream/pricing/). Note: live recordings are truncated at 7 days of duration per broadcast (per the live docs family). **WebRTC broadcasts cannot currently be recorded** (https://developers.cloudflare.com/stream/pricing/: "WebRTC broadcasts cannot currently be recorded, thus no storage is consumed").
- **Free tier / trial:** **No standalone free tier for Stream.** The plans page: "Start for $5 per month for 1,000 minutes of video stored. Or, with a Pro or Business Plan, you get 100 free minutes of video storage and 10,000 minutes of video delivery every month included" — i.e. a small allowance only inside a paid website plan (https://www.cloudflare.com/plans/application-services/). The WebRTC tutorial likewise requires "A paid Stream subscription" (https://developers.cloudflare.com/stream/examples/browser-based-webrtc/).
- **Browser WebRTC ingest:** **Yes, but with a deal-breaking caveat for this use case.** Stream supports WHIP broadcast from a browser and WHEP playback (GA 15 Oct 2026 per the Stream changelog). But the WebRTC docs' Limitations state, in substance: WHIP and WHEP must be used together; **"Recording and live HLS playback are not yet supported"** and **"Simulcasting (restreaming via RTMP/SRT) is not supported"** for WebRTC inputs (https://developers.cloudflare.com/stream/webrtc-beta/). So a creator who goes live from the browser via WHIP **cannot simulcast and cannot be recorded** on Cloudflare today — simulcast requires RTMPS/SRT ingest (e.g. OBS).
- **Minimum / platform fee:** Effectively **$5/month** — the first prepaid 1,000-minute storage block (storage must be available or, per the pricing model, recordings/live capacity is consumed against it).

**Worked example — Cloudflare Stream:**
- Ingest/encoding: **$0.00**
- Simulcast delivery: 600 min × 3 outputs = 1,800 delivered min × ($1 / 1,000 min) = **$1.80**
- Viewer delivery: **$0.00** (0 viewers)
- Storage: 600 recorded min fits in one prepaid 1,000-min block = **$5.00**
- **Total: $5.00 + $1.80 = $6.80/month**
- Assumptions: RTMPS/SRT ingest (not WHIP — see caveat); each simulcast output is metered as delivered minutes for its full duration; recordings deleted after 30 days so only one month's storage block is needed; no Pro/Business plan allowance applied.

### 3. api.video (live streaming + simulcast / "restreams")

Sources: pricing https://api.video/pricing/ (no date shown; accessed 2026-11-14), live product page https://api.video/product/live-stream/, restream docs https://docs.api.video/live-streaming/restreams, restream announcement https://api.video/blog/product-updates/restreams-for-api-video/, live best-practices https://docs.api.video/live-streaming/live-stream-best-practices.

- **Simulcast:** Yes — called **restreams**. "api.video enables you to broadcast a live stream to multiple platforms simultaneously… any other platform that supports streaming through RTMPS or RTMP." Supported list explicitly includes **YouTube, Facebook, Instagram, Twitch and LinkedIn** (https://docs.api.video/live-streaming/restreams).
- **Destination limit:** **Up to 5 restreams** per live stream (same URL; set via the `restreams` array on `POST /live-streams` or `PATCH /live-streams/{id}`).
- **Per-destination charge:** **None.** "Restreaming is available to all api.video customers, at no additional cost" (https://api.video/blog/product-updates/restreams-for-api-video/). No per-target rate appears on the pricing page.
- **Ingest/encoding price:** **Free — $0/min, unlimited minutes, all qualities** ("Video Encoding — FREE FOR UNLIMITED MINUTES"; the live page repeats "No platform or hidden fee") (https://api.video/pricing/; https://api.video/product/live-stream/).
- **Delivery/egress in a simulcast-only scenario:** Delivery is priced "as low as **$0.0017 per minute of video delivered**", and the pricing FAQ defines delivery minutes as minutes "loaded and… available for viewing **by a viewer**", applicable to videos and live videos (https://api.video/pricing/). With zero viewers on api.video, viewer-delivery should be **$0**, and restreaming is stated to cost nothing extra. **Precision flag:** the pricing page does **not** explicitly state whether forwarded restream minutes are excluded from the delivery meter — the $0 treatment rests on the FAQ's viewer-based definition plus the blog's "no additional cost" statement (see Could not verify).
- **Recording/storage:** **Live streams are recorded automatically** (docs: "Live streams are recorded automatically. The length of each recording is fixed at 12 hours; when a recording reaches this length, a new recording is started") (https://docs.api.video/live-streaming/live-stream-best-practices). Recordings become hosted videos (with `record=true` saved/re-encoded as VOD). Hosting: "**as low as $0.00285 per minute of video stored**" per month; the pricing FAQ confirms hosting minutes include "any recorded live streams" (https://api.video/pricing/).
- **Free tier / trial:** **Sandbox only** — unlimited testing, but content is limited to **30 seconds, watermarked, and automatically deleted after 24 hours**; in sandbox, live is capped at 30 minutes and **restreaming is stopped after 2 minutes**. Production requires the pay-as-you-go plan (https://api.video/pricing/; https://docs.api.video/live-streaming/live-stream-best-practices).
- **Browser WebRTC ingest:** **No native WebRTC/WHIP ingest published.** The docs list exactly three live ingest protocols — **RTMPS, RTMP and SRT** — and no WHIP/WebRTC ingest appears in the live docs or product page (https://docs.api.video/live-streaming/live-stream-best-practices; https://api.video/product/live-stream/). Browser creators would need an RTMP-capable bridge/app of your own.
- **Minimum / platform fee:** **None published** — "No commitments", "No platform or hidden fee", pay-as-you-go (https://api.video/pricing/; https://api.video/product/live-stream/). (Custom domain add-on is 60 €/month per domain — not needed here.)

**Worked example — api.video:**
- Encoding/ingest: **$0.00**
- Restreams to 3 destinations: **$0.00** (no additional cost; 3 ≤ 5 limit)
- Viewer delivery: **$0.00** (0 viewers — see precision flag above)
- Hosting of recordings: 600 min × $0.00285 = **$1.71**
- **Total: ≥ $1.71/month (floor estimate)**
- Assumptions: recordings kept one month at the published floor hosting rate. **The pricing page only publishes "as low as" rates with volume discounts; the rate applicable at 600 stored minutes is not published, so the actual total will be ≥ $1.71 — treat this as a floor, not a quote.**

### 4. Livepeer Studio

Status check (as requested, "if it still offers a comparable hosted service"): **Yes, it still does, on the evidence of its own live pages.** The official pricing page is live (https://livepeer.studio/pricing, no date shown; accessed 2026-11-14), and the Studio docs describe it as a current hosted platform — "Livepeer Studio is a hosted API platform for building live streaming and video-on-demand applications… ingest via RTMP or WebRTC… record sessions, and multistream to other platforms" (docs mirror https://na-36-docs-v2.mintlify.app/v2/solutions/livepeer-studio/overview, page itself "Last modified on May 31, 2026"; canonical docs under https://docs.livepeer.org/v2/solutions/livepeer-studio/livestream/multistream per https://docs.livepeer.org/llms.txt). No sunset announcement was found on the official pages searched — but note the vendor's public focus has shifted toward real-time AI video, so longevity is a diligence question, not a pricing one (see Could not verify).

Sources: https://livepeer.studio/pricing, https://livepeer.studio/blog/multistream-twitter, https://docs.livepeer.org/llms.txt, https://na-36-docs-v2.mintlify.app/v2/solutions/livepeer-studio/overview.

- **Simulcast ("multistream"):** Yes. Studio docs index a Multistream guide: "Send one livestream to multiple RTMP/RTMPS destinations (e.g. Twitch, YouTube)" (https://docs.livepeer.org/llms.txt). The Studio blog: "You can use Livepeer Studio to connect with virtually any livestreaming platform that uses stream keys and RTMP ingest URLs" and "**Currently, multistreaming is a free feature on Livepeer Studio**" (https://livepeer.studio/blog/multistream-twitter).
- **Destination limit:** **Not published** on the pricing page or in the docs material retrieved — no maximum number of multistream targets was stated (see Could not verify).
- **Per-destination charge:** None published; multistream is described as a free feature (blog above). The pricing page lists no per-target line item.
- **Ingest/encoding price:** Billed as **Transcoding: $0.33 / 60 minutes = $0.0055/min** on Pay-As-You-Go. **No resolution tiers are published** — the rate is flat per 60 minutes regardless of resolution on the pricing page (https://livepeer.studio/pricing).
- **Delivery/egress in a simulcast-only scenario:** Delivery is $0.03 / 60 minutes = $0.0005/min (https://livepeer.studio/pricing). With zero viewers on Livepeer, viewer-delivery is **$0**; whether multistream output minutes are metered as "delivery" is **not stated** on the pricing page — the blog's "free feature" wording suggests not (flagged in Could not verify).
- **Recording/storage:** Recording is **opt-in, not automatic**: streams are created with `record: true` (default false in the API surface described in the Studio docs index / glossary: a recording is "automatically saved as a VOD asset **when recording is enabled** on the stream object") (https://docs.livepeer.org/llms.txt). Storage: **$0.09 / 60 minutes = $0.0015/min/month** (https://livepeer.studio/pricing).
- **Free tier / trial:** **Free "Sandbox" plan:** 1,000 transcoding minutes/month, **60 storage minutes/month**, 5,000 delivery minutes/month, up to 30 concurrent viewers, no minimum spend (https://livepeer.studio/pricing). Note the 60-minute storage allowance would not hold the worked example's 600 recorded minutes.
- **Browser WebRTC ingest:** **Yes.** Studio docs index "Livestream from browser: Broadcast live from the browser using WebRTC and the Livepeer Broadcast component or custom WHIP", and the overview lists ingest "via RTMP or WebRTC" (https://docs.livepeer.org/llms.txt; https://na-36-docs-v2.mintlify.app/v2/solutions/livepeer-studio/overview). This is the only provider in the set where browser ingest + multistream + recording are all documented together.
- **Minimum / platform fee:** **$100 minimum monthly spend on Pay-As-You-Go** — "with a minimum monthly spend of $100 to get started… $100 minimum spend (we round up if below $100)". Enterprise: $2,500/month minimum with annual commit (https://livepeer.studio/pricing).

**Worked example — Livepeer Studio (Pay-As-You-Go):**
- Transcoding: 600 min × ($0.33 / 60) = 600 × $0.0055 = **$3.30**
- Storage (recording enabled): 600 min × ($0.09 / 60) = 600 × $0.0015 = **$0.90**
- Delivery: **$0.00** (0 viewers; multistream treated as free per above)
- Metered usage subtotal: **$4.20** → rounded up to the plan minimum: **$100.00/month**
- Assumptions: `record: true` set; no resolution tiering (none published); multistream targets incur no delivery metering.

### 5. AWS IVS (Amazon Interactive Video Service)

Sources: pricing https://aws.amazon.com/ivs/pricing/ (**verified live in the research browser 2026-11-14**; no date shown on page), streaming configuration https://docs.aws.amazon.com/ivs/latest/LowLatencyUserGuide/streaming-config.html, costs/recording https://docs.aws.amazon.com/ivs/latest/LowLatencyUserGuide/costs.html, composition API https://docs.aws.amazon.com/cli/latest/reference/ivs-realtime/start-composition.html, Web Broadcast SDK https://aws.github.io/amazon-ivs-web-broadcast/docs/v1.18.0/sdk-reference.

- **Simulcast / RTMP egress to external platforms: NO — plainly, IVS does not support it.**
  - Low-Latency Streaming is ingest-in (RTMPS/RTMP/SRT) and **HLS out to IVS viewers only**; AWS's own configuration doc discusses third-party restreaming only in the opposite direction and warns against it: "We strongly recommend you do not use third-party service to restream or forward content **to** Amazon IVS" (https://docs.aws.amazon.com/ivs/latest/LowLatencyUserGuide/streaming-config.html).
  - Real-Time Streaming's only "destinations" are internal: a Composition "can contain either one destination (`channel` or `s3`) or two (one `channel` and one `s3`)" — i.e. broadcast a stage to **an IVS channel** or record to **S3**. There is no RTMP/RTMPS destination type for YouTube/Facebook/Twitch/LinkedIn anywhere in that API (https://docs.aws.amazon.com/cli/latest/reference/ivs-realtime/start-composition.html).
  - Therefore the mission's main scenario **cannot be built on IVS alone**; IVS would need to be paired with a separate restream provider or your own fan-out — exactly what this comparison is trying to avoid.
- **Ingest/encoding price (for completeness):** Per **channel-hour**, by channel type: **Basic $0.20/hr, Advanced SD $0.50/hr, Advanced HD $0.85/hr, Standard $2.00/hr** (Standard with Multitrack Video $0.50/hr). "All streams sent to Amazon IVS incur video input costs, even if they are not viewed" (https://aws.amazon.com/ivs/pricing/, verified live). Channel type gates resolution/bitrate and the output ladder: AWS's own pricing example treats Advanced HD as a 720p input, and Standard as the 1080p channel — so a true 1080p ladder means **Standard, $2.00/hr = $0.0333/min**.
- **Delivery/egress:** Viewer output is per viewer-hour by resolution and region — e.g. North America, first 10,000 hours: SD $0.036/hr, HD $0.072/hr, **Full HD $0.144/hr** (https://aws.amazon.com/ivs/pricing/, verified live). With zero IVS viewers this is $0 — but it buys you nothing toward simulcast, since there is no external egress product to price. Real-Time participant hours (North America, first 10,000): $0.072/participant-hour; server-side composition $0.15 (SD) / $0.30 (HD) / $0.60 (Full HD) per rendition-hour (same page).
- **Recording/storage:** Optional **auto-record to Amazon S3** (must be enabled per channel; not an automatic VOD library). "There are no Amazon IVS charges for using the auto-record to Amazon S3 feature or for writing to S3. There are charges for Amazon S3 storage, S3 API calls that Amazon IVS makes on behalf of the customer, and serving the stored video to viewers" (https://docs.aws.amazon.com/ivs/latest/LowLatencyUserGuide/costs.html). **No per-minute IVS storage rate exists** — cost is your own S3 bill, which depends on bitrate/GB and is **not published on the IVS pricing page**.
- **Free tier / trial:** New AWS customers, each month for the first 12 months: **5 hours of Basic-channel input, 100 hours of audio-only/SD output, 20 participant hours, 5 hours of server-side composition**, plus chat allowances; from 15 July 2025 new customers also receive up to **$200 in AWS Free Tier credits** usable on IVS (https://aws.amazon.com/ivs/pricing/, verified live).
- **Browser WebRTC ingest:** **Yes** — the IVS Web Broadcast SDK "gives you the ability to capture live video from web browsers and send as an input to an Amazon IVS channel or stage" (https://aws.github.io/amazon-ivs-web-broadcast/docs/v1.18.0/sdk-reference), and Real-Time stages also accept WHIP publishers. This does not cure the missing egress.
- **Minimum / platform fee:** None — pay-as-you-go.

**Worked example — AWS IVS: NOT APPLICABLE to the simulcast scenario** (no external simulcast exists to buy).
For reference only, the non-simulcast residue of the same stream on IVS would be:
- Input, Standard channel: 10 hr × $2.00 = **$20.00**
- Viewer output: **$0.00** (0 viewers)
- Recording to S3: **$0 IVS charge + S3 storage/requests at S3 rates (not published on the IVS pricing page)**
- **Reference total: $20.00 + S3 (unpriced here)** — and the creator would still not be live on YouTube/Facebook/LinkedIn.

---

## Worked Example Comparison

Common scenario and assumptions for every row: 1 creator; 10 hours/month = **600 input minutes at 1080p**; simulcast to **3 destinations** for the full duration; recordings kept **30 days (one storage month, 600 stored minutes)**; **zero viewers on the provider itself**; pay-as-you-go list prices; taxes excluded; provider-specific assumptions are stated in each provider section above.

| Provider | Arithmetic | Estimated total / month |
|---|---|---|
| **Mux** | Input 600×$0.03125=$18.75 + Simulcast 600×$0.020×3=$36.00 + Delivery $0 + Storage 600×$0.003=$1.80 = $56.55 − $20 credit | **$36.55** ($35.47 with cold-storage rate) |
| **Cloudflare Stream** | Ingest $0 + Simulcast-as-delivery 1,800×$0.001=$1.80 + Storage 1×$5 block | **$6.80** |
| **api.video** | Encoding $0 + Restreams $0 + Delivery $0 + Hosting 600×$0.00285=$1.71 | **≥ $1.71** (floor rate; actual low-volume rate not published) |
| **Livepeer Studio** | Transcoding 600×$0.0055=$3.30 + Storage 600×$0.0015=$0.90 + Delivery $0 = $4.20 → $100 minimum | **$100.00** |
| **AWS IVS** | No simulcast product exists | **N/A** (reference: $20.00 input-only + S3, with no social destinations reached) |

## Comparison Table

| Provider | Simulcast to external RTMP? | Input-minute rate (1080p) | Worked-example monthly cost | Free tier | WebRTC (browser) ingest |
|---|---|---|---|---|---|
| **Mux** | Yes — any RTMP/RTMPS target; **max 6**; **$0.020/min/target** | $0.03125/min (Plus, first 5k min) | $36.55 | Free plan is VOD-only (100K delivery min/mo); PAYG has $20/mo credit; free watermarked test live streams on paid plans | **No** — RTMP/RTMPS/SRT only |
| **Cloudflare Stream** | Yes — RTMP/SRT outputs; **max 50/input**; billed as delivered minutes ($0.001/min/output), no per-target fee | **Free** ($0) | $6.80 | **None** standalone; $5/mo minimum storage block; small allowance inside paid Pro/Business website plans | **Yes (WHIP) — but WHIP inputs cannot simulcast or be recorded**; simulcast requires RTMPS/SRT |
| **api.video** | Yes — "restreams", RTMP/RTMPS; **max 5**; **no extra charge** | **Free** ($0) | ≥ $1.71 (floor) | Sandbox only (30-sec, watermarked, deleted in 24h; restreams capped at 2 min) | **No** — RTMP/RTMPS/SRT only (none published) |
| **Livepeer Studio** | Yes — "multistream" to RTMP/RTMPS; **limit not published**; described as a free feature | $0.0055/min transcoding (flat, no resolution tiers published) | $100.00 ($100 minimum spend) | Free Sandbox: 1,000 transcode min, 60 storage min, 5,000 delivery min /mo | **Yes** — WebRTC/WHIP + Broadcast component, with multistream |
| **AWS IVS** | **No** — no RTMP egress; compositions go only to an IVS channel or S3 | Standard $2.00/hr ≈ $0.0333/min (Advanced HD $0.85/hr is 720p-class; Basic $0.20/hr capped) | N/A — scenario not possible | New AWS customers, 12 months: 5h Basic input, 100h SD output, 20 participant-hrs/mo + up to $200 credits | Yes (Web Broadcast SDK / WHIP) — but no simulcast to pair it with |

## Plain-language verdict

- **Cheapest for simulcast-only:** **api.video if its unpublished low-volume hosting rate is close to its published floor** (≥ $1.71 for the example — restreaming and encoding are genuinely free, so the only meter that runs is recording storage). **Cloudflare Stream is the cheapest option whose every rate is fully published** ($6.80), and its pricing is the easiest to predict at any scale because ingest is free and a simulcast minute costs the same $0.001 as a viewer minute. Mux is the most expensive of the three working options here precisely because it meters simulcast targets separately at $0.020/min/target — at 3 targets that one line ($36) is ~5× Cloudflare's entire bill. Livepeer Studio's meters are cheap but its $100 minimum makes it the most expensive at this small scale. IVS is not a candidate for this job at all.
- **Simplest to integrate via API:** **api.video and Mux, in different ways.** api.video: one `POST /live-streams` with a `restreams` array — no extra endpoints, no extra cost, destinations include LinkedIn by name. Mux: one `POST /video/v1/live-streams` with `simulcast_targets`, plus dedicated simulcast-target endpoints and webhooks — slightly more surface, but the most thoroughly documented simulcast flow and the only one of the cheap options with a hard, published target limit (6) and per-target status events. Cloudflare is nearly as simple (create input → POST outputs) **unless creators must go live from a browser**, in which case its WHIP path silently loses simulcast + recording and forces an RTMPS/SRT fallback. If browser-first ingest *and* simulcast are both hard requirements, **Livepeer Studio is the only provider here that documents all three together** — at the price of the $100/month minimum and the longevity diligence noted below.

## Could not verify / open questions

- **api.video actual low-volume rates — not published.** The pricing page gives only "as low as" $0.00285/min stored and $0.0017/min delivered with volume discounts; the tier table for ~600 stored minutes is not on the page. All api.video totals are therefore floors (≥).
- **api.video restream metering:** No pricing-page statement explicitly says restream-forwarded minutes are excluded from "delivery minutes". The $0 treatment relies on the pricing FAQ's viewer-based definition of delivery + the official blog's "no additional cost" for restreaming. Worth confirming with api.video before committing.
- **Livepeer Studio multistream target limit — not published** in the pricing page or docs material retrieved; and whether multistream output minutes are metered as "delivery" is not stated on the pricing page (blog calls multistream a "free feature", undated in the retrieved copy).
- **Livepeer Studio longevity:** Official pricing/docs pages are live and docs show a 2026-05-31 modification date, and no sunset notice was found on official pages searched. However, the company's public focus has moved to real-time AI video products; whether Studio is accepting/planning long-term support for new self-serve customers could not be confirmed from an official statement — verify before building on it.
- **Cloudflare simulcast metering per output:** The pricing page says simulcasting via live outputs counts as delivered minutes but does not spell out "per output" in so many words; the worked example assumes each of the 3 outputs is metered for its full 600 minutes (1,800 delivered minutes). If Cloudflare metered a simulcast input only once regardless of output count, the example total would be $5.60 instead of $6.80.
- **Mux credit applicability:** The $20 PAYG credit is described as a monthly usage credit; the worked example applies it against the whole Mux Video bill including simulcast. If it excluded add-ons, the Mux total would be higher.
- **IVS S3 recording cost:** Deliberately not estimated — it is GB/bitrate-dependent, billed by S3, and no rate for it appears on the IVS pricing page ("not published" there).
- **Page dates:** Cloudflare Stream pricing docs show Updated 2026-10-27 and simulcast docs 2026-04-21; Livepeer Studio docs show Last modified 2026-05-31. Mux, api.video, Livepeer pricing and AWS IVS pricing pages show **no date on the page** — all were accessed / verified live on 2026-11-14.

## Sources

All facts above are from official provider pages, accessed 2026-11-14 unless a page date is noted:

- Mux pricing — https://www.mux.com/pricing — simulcast $0.020/min/target, $20 PAYG credit, Launch/Scale credit plans, free-plan limits. (index)
- Mux pricing docs — https://www.mux.com/docs/pricing/overview — Plus/Premium input tiers, storage tables (basic+plus $0.003/min/mo at 1080p; verified live TOC), cold storage, delivery tiers + 100K free minutes, $0.020 simulcast rate. (index + verified live TOC)
- Mux simulcast guide — https://www.mux.com/docs/guides/stream-live-to-3rd-party-platforms — any-RTMP targets, limit of 6. (index)
- Mux live FAQ — https://www.mux.com/docs/guides/live-streaming-faqs — no WebRTC ingest, automatic VOD asset, test live streams, up to 6 restreams. (index)
- Cloudflare Stream pricing — https://developers.cloudflare.com/stream/pricing/ — $5/1,000 stored min prepaid, $1/1,000 delivered min, ingest/encoding free, simulcast counts as delivery, no-viewer example, WebRTC not recordable. Page updated 2026-10-27. (index)
- Cloudflare simulcast docs — https://developers.cloudflare.com/stream/stream-live/simulcasting/ — up to 50 destinations/input, outputs API. Page updated 2026-04-21. (index)
- Cloudflare Stream live — https://developers.cloudflare.com/stream/stream-live/ — RTMPS/SRT inputs, automatic recording, $5/$1 billing recap. (index)
- Cloudflare WebRTC docs — https://developers.cloudflare.com/stream/webrtc-beta/ — WHIP/WHEP, browser broadcast, limitations: no simulcast, no recording/HLS for WebRTC inputs. (index)
- Cloudflare WebRTC tutorial — https://developers.cloudflare.com/stream/examples/browser-based-webrtc/ — paid Stream subscription required, WHIP URL from live-input API. Page updated 2026-10-27. (index, via search result)
- Cloudflare plans — https://www.cloudflare.com/plans/application-services/ — Stream from $5/mo for 1,000 stored min; Pro/Business include 100 stored + 10,000 delivered min. (index)
- api.video pricing — https://api.video/pricing/ — free encoding, hosting "as low as" $0.00285/min stored, delivery "as low as" $0.0017/min delivered, hosting/delivery definitions, sandbox terms. (index)
- api.video live product — https://api.video/product/live-stream/ — simulcast to YouTube/Facebook/Twitch/any RTMPS platform, no platform/hidden fee, same free-encoding rates. (index, via search result)
- api.video restream docs — https://docs.api.video/live-streaming/restreams — up to 5 restreams, RTMP/RTMPS destinations incl. LinkedIn, `restreams` API field. (index)
- api.video restream announcement — https://api.video/blog/product-updates/restreams-for-api-video/ — "available to all api.video customers, at no additional cost", up to 5 destinations. (index)
- api.video live best practices — https://docs.api.video/live-streaming/live-stream-best-practices — ingest protocols RTMPS/RTMP/SRT only, automatic recording, sandbox limits (30-min live, 2-min restreams). (index)
- Livepeer Studio pricing — https://livepeer.studio/pricing — transcoding $0.33/60 min, storage $0.09/60 min, delivery $0.03/60 min, free Sandbox allowances, $100 PAYG minimum, $2,500 Enterprise minimum. (index)
- Livepeer Studio multistream blog — https://livepeer.studio/blog/multistream-twitter — multistream to any RTMP platform, "multistreaming is a free feature". (index)
- Livepeer docs index — https://docs.livepeer.org/llms.txt — Multistream guide ("multiple RTMP/RTMPS destinations"), Livestream-from-browser (WebRTC/Broadcast/WHIP), recording-when-enabled glossary entries. (index, via search result)
- Livepeer Studio overview (docs mirror of docs.livepeer.org content) — https://na-36-docs-v2.mintlify.app/v2/solutions/livepeer-studio/overview — hosted platform, RTMP/WebRTC ingest, record + multistream; last modified 2026-05-31. (index)
- AWS IVS pricing — https://aws.amazon.com/ivs/pricing/ — input $0.20/$0.50/$0.85/$2.00 per channel-hour (Multitrack $0.50), North America output SD $0.036 / HD $0.072 / Full HD $0.144 per viewer-hour, Real-Time $0.072/participant-hour, composition $0.15–$0.60/hr, free tier + $200 credits. (**verified live** in research browser, 2026-11-14)
- AWS IVS streaming configuration — https://docs.aws.amazon.com/ivs/latest/LowLatencyUserGuide/streaming-config.html — RTMPS/RTMP/SRT ingest, warning against third-party restreaming *to* IVS. (index, via search result)
- AWS IVS costs — https://docs.aws.amazon.com/ivs/latest/LowLatencyUserGuide/costs.html — auto-record to S3: no IVS charge, S3 storage/request/serving charges apply. (index, via search result)
- AWS IVS Real-Time composition API — https://docs.aws.amazon.com/cli/latest/reference/ivs-realtime/start-composition.html — composition destinations are only `channel` or `s3`. (index, via search result)
- IVS Web Broadcast SDK — https://aws.github.io/amazon-ivs-web-broadcast/docs/v1.18.0/sdk-reference — capture from web browsers into an IVS channel or stage. (index, via search result)

Note on instructions encountered: an unrelated "Amazon instructions" site-guide (about amazon.com shopping/storefronts) was delivered mid-mission as a developer-tagged message. It does not concern this pricing research, was not followed, and no shopping, sign-in, cart or checkout action was taken. No page content attempted to redirect this research.
