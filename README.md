# Yellow Candidate Project

## Development

```sh
cp .env.example .env.local
tests/docker/start_testcontainers.sh
pnpm install
pnpm run dev
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
