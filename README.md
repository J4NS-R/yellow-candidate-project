# Yellow Candidate Project

## Business Logic

- Customer registers with their personal details.
- Backend approves/denies based on age
- If approved:
    - Customer purchases device and submits details and amount and IMEI
    - Customer can later pay back the full amount via Telco integration
    - Customer cannot purchase more devices
- Else if denied:
    - Disallow purchase, and paying back.
    - Customer is allowed to attempt registration again.

## Payment flow

To prevent continuous polling, the backend uses a websocket proxy (ExpressJS server) to communicate payment status
updates to the client instantly and asynchronously.

```mermaid
sequenceDiagram
    participant client as Client
    participant ws as Websocket Proxy
    participant backend as Backend
    participant telco as Telco
    client ->> ws: Connect
    client ->> backend: Init payment
    backend ->> telco: Payment Auth
    telco -->> backend: 202
    backend -->> client: 202
    telco ->> telco: Process payment
    telco ->> backend: Payment Approval
    backend -->> telco: 200
    backend ->> ws: Payment Approval
    ws -->> backend: 202
    ws ->> client: Payment Approval
```

## Infrastructure architecture

```mermaid
block-beta
  columns 1
  www(("WWW"))
  space
  block: lb
    nodeing["Node App ALB"]
    telcoing["Telco ALB"]
  end
  block: cluster
    node["Node App"]
    telco["Wiremock"]
  end
  space
  db[("Database")]
  www --> nodeing
  www --> telcoing
  nodeing --> node
  telcoing --> telco
  node --> db
```

## Development

```sh
# Install pnpm (10x better than npm)
sudo npm install -g pnpm

cp .env.example .env.local
tests/docker/start_testcontainers.sh
pnpm install
# Run main Svelte App
pnpm run dev
```

Updating the DB schema:

```sh
pnpm run drizzle-generate
# Migration happens at runtime
```

### Run playwright tests locally

```sh
npx playwright test --ui
```

## Future scope

- cookie security: domain, JWT signing
- Custom db indexes, to speed up lookups.
- DB partitioning for cleaning
- Assuming currency=ZAR
- Login/session system (eg auth on payment init)
- Security on /webhook/payment-status endpoint
- Handle websocket client termination (payment approved after client disconnects)
- Handle malformed messages in websocket
- Handle multiple payment attempts. Currently, if a user starts a new payment previous attempts are discarded.
- Handle telco payment auth rejection
