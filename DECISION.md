# Decision Log

## 2026-05-07 — Database Choice (PostgreSQL)

A banking system requires ACID guarantees, so a relational database was non-negotiable.

Between MySQL and PostgreSQL, PostgreSQL was chosen because of how each handles bad data. MySQL has historically been lenient by default — it would silently accept wrong types, constraint violations, and truncated values and just store them. PostgreSQL rejects bad data at the database level and throws an error, enforcing the rules you define even when application code has a bug. For a banking system, the database should be the last line of defence, not a pushover.

Banking systems in general run on PostgreSQL or Oracle. Oracle was ruled out because PostgreSQL is open-source and has strong community support.

Notable real-world usage:
- **Stripe** — PostgreSQL
- **Square** — PostgreSQL
- **Robinhood** — PostgreSQL
- **Revolut** — PostgreSQL
- **JPMorgan Chase** — Oracle
- **Bank of America** — Oracle
- **Wells Fargo** — Oracle

## 2026-05-07 — Framework Choice (Ruby on Rails)

Rails was chosen for three reasons:
1. The assignment had a 24-hour submission deadline
2. Familiarity with the Ruby/Rails ecosystem
3. Rails convention-over-configuration philosophy allows faster development compared to more configuration-heavy frameworks.

## 2026-05-07 — Project Scaffolding

**Command used:**
```
rails new banking-api --api \
  --skip-action-mailer \
  --skip-action-mailbox \
  --skip-action-text \
  --skip-active-storage \
  --skip-action-cable \
  --skip-test \
  --skip-active-job
```

**Decisions:**

- `--api` — API-only mode. Strips middleware and views not needed for a JSON API (no cookies, sessions, or asset pipeline).
- `--skip-action-mailer` — No email delivery required for the initial banking API scope.
- `--skip-action-mailbox` — No inbound email processing needed.
- `--skip-action-text` — No rich text content (Trix/ActionText) required.
- `--skip-active-storage` — No file/blob uploads in scope; avoids cloud storage dependencies.
- `--skip-action-cable` — No WebSocket/real-time features planned at this stage.
- `--skip-test` — Default Minitest skipped; test framework to be decided separately (likely RSpec).
- `--skip-active-job` — No background job processing in the initial scaffold; a queue adapter will be added when async jobs are introduced.

## 2026-05-07 — Ruby Version (3.3.4 over 4.x)

Ruby 4.0 was released in December 2025. It was not adopted here due to gem incompatibility — many gems in the ecosystem have not yet updated to support Ruby 4.x.
