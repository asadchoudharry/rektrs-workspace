# Worked example calculations (600 input min, 1080p, 3 destinations, recordings 30 days, 0 provider viewers)

## Mux (Plus, PAYG)
- Input: 600 x $0.03125 = $18.75 (Plus 1080p, first 5,000 min tier, mux.com/docs/pricing/overview)
- Simulcast: 600 x $0.020 x 3 = $36.00
- Delivery: $0 (0 viewers; first 100k delivered min/mo free anyway)
- Storage: Basic+Plus table 1080p = $0.003/min/mo. Headline: 600 x 0.003 = $1.80. Cold (never played, asset starts in Cold): 1080p cold = $0.0012 -> $0.72
- Gross headline: 18.75+36+1.80 = $56.55; minus $20 PAYG monthly usage credit = $36.55. Cold-adjusted: $55.47-$20 = $35.47
- Verified: storage TOC heading in live browser = "Basic and plus quality storage" for first table; premium is second table ($0.0045).

## Cloudflare Stream
- Ingest/encoding: free ($0)
- Simulcast delivery: pricing docs count simulcasting via RTMP/SRT outputs as delivered minutes. Assume per output: 600 x 3 = 1,800 delivered min x $0.001 ($1/1000) = $1.80
- Storage: prepaid $5 per 1,000 stored-min block; 600 min needs 1 block = $5.00
- Total: $6.80. Assumes RTMPS/SRT ingest (WHIP/WebRTC inputs cannot simulcast or record per WebRTC docs limitations)

## api.video
- Encoding: free ($0)
- Restream: no additional cost (official blog), up to 5 destinations
- Delivery: $0 assumed (0 viewers; delivery defined as minutes loaded by a viewer). Pricing page does not explicitly say restream minutes are excluded from delivery metering - flag.
- Hosting/storage: floor rate "as low as" $0.00285/min stored; low-volume tier NOT published. Floor: 600 x 0.00285 = $1.71
- Total: >= $1.71 (floor estimate, actual low-volume rate not published)

## Livepeer Studio (PAYG Growth)
- Transcoding: $0.33/60min = $0.0055/min; 600 x = $3.30
- Storage: $0.09/60min = $0.0015/min; 600 x = $0.90
- Delivery: $0.03/60min = $0.0005/min; 0 viewers = $0. Multistream described as free feature (studio blog); pricing page lists no per-target fee.
- Usage subtotal $4.20, but $100 minimum monthly spend ("we round up if below $100") -> Total $100.00

## AWS IVS
- Simulcast to external RTMP: NOT supported. Low-latency = HLS to IVS viewers only; Real-Time composition destinations = only IVS channel or S3 (official API docs).
- Worked example: N/A for simulcast scenario.
- For reference, non-simulcast input only: Standard channel (1080p ladder) $2.00/hr x 10h = $20.00; output $0 with 0 viewers; auto-record to S3 has no IVS charge but S3 storage/request charges apply (rate not on IVS pricing page, depends on GB).
- Advanced HD $0.85/hr (= $8.50/10h) is 720p-class in AWS's own example; Basic $0.20/hr is bitrate/resolution capped.
