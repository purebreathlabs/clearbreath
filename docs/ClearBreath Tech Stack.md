# Tech Stack Architecture & Recommendations

| Layer | Choice | Why in one line |
| ----- | ----- | ----- |
| Mobile | **Flutter (Dart) + Riverpod + go_router + Drift** | High-performance, deterministic rendering for timing-sensitive breathing visuals + offline-first local storage |
| Backend API | **Go + Chi (+ sqlc)** | Simple, fast, predictable API for auth, sessions, stats, and leaderboard with strong typing at the DB boundary |
| Database | **PostgreSQL (Neon)** | Managed Postgres with low ops and easy environment separation |
| Cache / Rate limiting | **Redis (Upstash)** | Sorted sets for leaderboard + rate limiting + caching without running your own Redis |
| Auth | **Apple/Google verification + JWT access/refresh rotation** | Optional accounts without vendor lock-in, with best-practice token lifecycle |
| Migrations | **goose** | Straightforward, Git-tracked migrations for Go/Postgres |
| Storage | **Cloudflare R2 (S3)** | Low-cost object storage for soundscapes with simple CDN delivery |
| Deployment | **Hetzner VPS + Docker + Caddy** | Simple deploy path with TLS, reverse proxy, and rollbacks via images |
| Analytics | **Minimal anonymous events (opt-out)** | Product health signals without PII; no crash/error tracking in v1 |
| Website | **Astro** | Fast landing + legal pages + SEO technique pages |
| Monorepo | **Makefile + Melos** | One-command workflows across Flutter, Go, and web projects |
