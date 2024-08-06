# Yellow Candidate Project

## Development

```sh
# Install pnpm (10x better than npm)
sudo npm install -g pnpm

cp .env.example .env.local
tests/docker/start_testcontainers.sh
pnpm install
# Run main Svelte App
pnpm run dev

# Run express server wrapper
pnpm run build  # requires built svelte app
export $(cat .env.local | xargs)  # requires env vars
node server-wrapper
```

Updating the DB schema:

```sh
pnpm run drizzle-generate
# Migration happens at runtime
```

## Future scope

- cookie security: domain, JWT signing
- Custom db indexes, to speed up lookups.
- DB partitioning for cleaning
- Assuming currency=ZAR
- Login/session system; Pull phone sale data from server by customerId.
- Security on /webhook/payment-status endpoint
- Handle websocket client termination (payment approved after client disconnects)
- Handle malformed messages in websocket
- Handle multiple payment attempts. Currently, if a user starts a new payment previous attempts are discarded.
