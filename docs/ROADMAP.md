# XeGhép247 — Roadmap

Ngân sách: free tier only; không kích hoạt billing. Cloudflare Pages là ứng dụng chính; GitHub Pages chỉ tài liệu/demo phi thương mại.

- [ ] P0: Next.js static export + TypeScript + Tailwind, Workers, CI build/test, deployment docs.
- [ ] P1: Supabase/PostGIS migrations, users/vehicles/trips/orders/matches/documents/events, RLS, GiST, pickup windows and ETA. Verify ownership and role escalation tests.
- [ ] P2: match pickup/dropoff within 10km of route, pickup before dropoff, capacity and time checks; atomic booking with row locks and concurrency tests.
- [ ] P3: auth email/password, profile, vehicle, trip, order, match APIs; optional OTP later; VND pricing.
- [ ] P4: Vietnamese responsive driver/shipper/admin UI, Leaflet, routing within provider limits, cache.
- [ ] P5: security, integration tests, CI, deployment validation.
- [ ] P6: release v0.1.0 only after verified end-to-end flow.
- [ ] P7: production feedback and v1.0.0.

Each iteration: inspect main, open PRs and CI; implement highest-priority unfinished task; verify, commit, open PR; merge only with passing CI. Record evidence and blockers. Never expose secrets, enable paid services or claim unverified deployment.

## Current status
README initialized. No working application or deployed services verified yet.
