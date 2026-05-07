# Decision Log

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
