# Final gap checks — read 2026-11-14 (index fetch of Docker Hub, crawled same day)

- Portainer Agent ARM64 VERIFIED: https://hub.docker.com/r/portainer/agent/tags — agent 3.0.1-alpine / alpine-sts list linux/amd64, linux/arm/v7, linux/arm64 (43.8 MB), linux/ppc64le. Agent version is now 3.0.1 (Portainer 3 agent line).
- ServerKit panel image ARM64 VERIFIED: https://hub.docker.com/r/jhd3197/serverkit/tags — jhd3197/serverkit:1.11.40 and :latest list linux/amd64 (121.84 MB) + linux/arm64 (121.01 MB); pushed ~6h before read on 2026-11-14. Same multi-arch pattern back through 1.9.x tags.
- Portainer pricing (official page, index): https://www.portainer.io/pricing — Starter $1,045/yr (5/10/15 nodes, ≤16 vCPU/node, community support), Scale $2,095/yr (5–25 nodes, ≤24 vCPU, 9x5 NBD support); BE free tier = 3 nodes (per official blog); Home & Student $155/yr 15 nodes non-commercial only (third-party summaries).
- Portainer founded 2016, first major release June 2016 (Packt book chapter; company profiles) — secondary sources.
- Cockpit started 2013, Red Hat-sponsored (LWN https://lwn.net/Articles/965434/); LGPL-2.1+; biweekly releases.
- Note: a search result for "MaroonedSoftware/ServerKit" is a DIFFERENT, unrelated .NET library also named ServerKit — excluded from this comparison.
