# Tech Stack Architecture & Recommendations

| Layer | Choice | Why in one line |
| ----- | ----- | ----- |
| Mobile | **Flutter (Dart)** | Impeller renders every pixel at 60-120fps — the breathing animation IS the product |
| Backend | **Go \+ Chi \+ sqlc** | 76% less memory than Node, $4/mo VPS handles 100K+ users, stdlib-compatible |
| Database | **PostgreSQL via Neon** | Serverless, scales to zero, DB branching for team of 15, zero ops |
| Cache | **Upstash Redis** (serverless) | Sorted sets for leaderboard, streak cache, rate limiting — free tier |
| Auth | **Custom JWT \+ Google/Apple OAuth direct** | Zero cost, full control, no vendor lock-in |
| Storage | **Cloudflare R2** | S3-compatible, zero egress fees, 10GB free — audio served globally for $0 |
| Deployment | **Hetzner VPS (€3.49/mo)** \+ Docker \+ Caddy | Cheapest production-grade infra on the planet |
| Monitoring | **PostHog** (product) \+ **Prometheus/Grafana** (infra) \+ **Sentry** (errors) | Full observability stack, all free tier |
| Monorepo | **Melos** (Flutter) \+ **Makefile** (Go) |  |

