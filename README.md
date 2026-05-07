# Banking API

A simplified banking REST API built with Ruby on Rails and PostgreSQL.

## Tech Stack

- **Ruby** 3.3.4
- **Rails** 8.1 (API mode)
- **PostgreSQL** 18
- **JWT** for authentication

## Features

- `POST /sessions` — Login with email and PIN, returns a JWT token
- `GET /accounts/:id/balance` — Retrieve account balance
- `POST /accounts/:id/deposit` — Deposit funds into an account

## Setup

**Prerequisites:** Docker installed.

```bash
# Clone the repo
git clone git@github.com:sapienfrom2000s/banking-api.git
cd banking-api

# Create the .env file with the master key
echo "RAILS_MASTER_KEY=$(cat config/master.key)" > .env

# Start the app (builds, migrates, and seeds automatically)
docker compose up --build
```

The API will be available at `http://localhost:3000`.

## Running Tests

```bash
# Set up test database (first time only)
docker compose run --rm -e RAILS_ENV=test web bundle exec rails db:create db:migrate

# Run specs
docker compose run --rm -e RAILS_ENV=test web bundle exec rspec
```

## API Reference

All endpoints except login require an `Authorization: Bearer <token>` header.

### Login

`POST /sessions`

**Body**
- `email` — user's email
- `pin` — user's PIN

```bash
curl -X POST http://localhost:3000/sessions \
  -H "Content-Type: application/json" \
  -d '{ "email": "alice@example.com", "pin": "1234" }'
```

---

### Get Balance

`GET /accounts/:id/balance`

**Headers**
- `Authorization: Bearer <token>`

```bash
curl http://localhost:3000/accounts/1/balance \
  -H "Authorization: Bearer <token>"
```

---

### Deposit

`POST /accounts/:id/deposit`

**Headers**
- `Authorization: Bearer <token>`

**Body**
- `amount` — amount to deposit, must be positive

```bash
curl -X POST http://localhost:3000/accounts/1/deposit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{ "amount": 100 }'
```

---

## Pre-seeded Users

| Name  | Email               | PIN  | Starting Balance |
|-------|---------------------|------|-----------------|
| Alice | alice@example.com   | 1234 | 1000.00         |
| Bob   | bob@example.com     | 5678 | 500.00          |

## Assumptions

- No frontend required — REST APIs only
- Authentication is stateless via JWT (expires in 1 hour)
- A user owns exactly one account
- Deposit is the only supported transaction type
- Integer IDs are used for simplicity (UUIDs would be preferred in production)

## Design Decisions

See [DECISION.md](DECISION.md) for a full log of technical decisions and their rationale.
