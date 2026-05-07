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

## 2026-05-07 — Database Schema Design

### Tables

Three tables were introduced: `users`, `accounts`, and `transactions`.

**Why separate `users` and `accounts`?**
In real banking, a user can hold multiple accounts (checking, savings, etc.).

**Why a `transactions` table?**
The assignment only requires deposit, but recording every transaction is a fundamental audit trail. It costs one extra row per operation and makes the system significantly more inspectable and debuggable. It was kept in scope.

### Column-level decisions

- `balance` uses `decimal(15, 2)` — `float` is never used for money due to floating-point precision errors.
- `balance` has a DB-level `default: 0` and `null: false` — a new account should always start at zero, enforced at the database level.
- `pin_digest` stores a bcrypt hash, never the plain PIN.
- `email` has a DB-level unique index in addition to the model-level uniqueness validation — the index prevents race conditions where two concurrent inserts could both pass the Rails uniqueness check before either commits.

### Validation strategy

Both DB constraints and model validations are applied. The model validations surface friendly error messages to the API consumer without hitting the database at all — the request is rejected in memory before any SQL is issued. The DB is the last line of defence.

## 2026-05-07 — Test Framework (RSpec over Minitest)

RSpec was chosen over the Rails default Minitest for two reasons:
1. Readability — RSpec's `describe`/`it`/`expect` DSL reads closer to plain English, making tests easier to understand at a glance.
2. Community support — RSpec has strong ecosystem adoption, extensive documentation, and a large library of complementary gems (e.g. FactoryBot, Shoulda Matchers).

## 2026-05-07 — Login API Error Messages

The login endpoint returns distinct error messages for an unknown email (`"Invalid email"`) and a wrong PIN (`"Invalid PIN"`). This is intentionally user-friendly.

The tradeoff is that separate messages enable **email enumeration** — an attacker can probe the endpoint to discover which email addresses are registered.

In a production system this is acceptable because it would be paired with:
- **IP-based rate limiting** — throttles the number of requests from a single IP, making enumeration at scale impractical
- **Exponential backoff** — each failed attempt increases the delay before the next attempt is accepted

Without these controls, the safer default would be a single generic message (`"Invalid email or PIN"`) for both cases. Since this assignment is not production-grade, user friendliness is prioritised, and the rate limiting gap is acknowledged as a known limitation.

## 2026-05-07 — Login Route Design (`POST /sessions`)

Three options were considered:

- `POST /login`
- `POST /users/login`
- `POST /sessions`

`POST /sessions` was chosen because it maps login to a resource (session) rather than a verb, and enables logical grouping — all session-related actions (login, logout, refresh) live in a single `SessionsController`. With `POST /users/login` and `POST /login`, you end up with a controller that is specific to just the login action, which doesn't scale cleanly as session management grows.

## 2026-05-07 — Exposing Integer IDs in API Responses

The login response returns the user's integer `id`. In a production system, exposing sequential integer IDs is a security concern — an attacker can infer the total number of users, enumerate records, and probe other endpoints by iterating IDs. The standard practice is to use UUIDs instead.

Since this is an assignment project, integer IDs were kept for simplicity.

## 2026-05-07 — JWT Authentication

JWT was chosen for authentication because it is stateless — the server does not need to store session data. The token is signed with the app's `secret_key_base` using HS256.

The access token expires in 1 hour. In a production system, this would be paired with a refresh token — a long-lived token (e.g. 30 days) used solely to obtain a new access token when the short-lived one expires. This keeps the system user-friendly (users are not forced to re-login frequently) while limiting the exposure window if an access token is compromised.

## 2026-05-07 — Concurrent Deposit Handling

Deposits use `increment!` which Rails translates to a single atomic SQL statement:

```sql
UPDATE accounts SET balance = balance + ? WHERE id = ?
```

Postgres serializes concurrent `UPDATE` statements on the same row using row-level locking automatically. There is no separate read step in the application, so two concurrent deposits cannot overwrite each other.

This is preferred over pessimistic locking (`with_lock`) for a single deposit operation — it is simpler, faster, and requires no application-level lock management. `with_lock` would be the right choice for a multi-step operation like a transfer, where two rows need to be locked together to prevent deadlocks.

## 2026-05-07 — `if !` over `unless`

`if !condition` is used throughout the codebase instead of `unless condition`. While `unless` is idiomatic Ruby, `if !` reads more naturally — it makes the negation explicit and is immediately familiar to anyone coming from other languages. This is a personal preference.
