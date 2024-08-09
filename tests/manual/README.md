```shell
export $(cat ../../.env.local | xargs)
docker pull ghcr.io/j4ns-r/yellow-candidate-project:0.0.1
docker compose up
```
