```shell
# from project root
docker pull ghcr.io/j4ns-r/yellow-candidate-project:0.0.1
# OR
docker build -t ghcr.io/j4ns-r/yellow-candidate-project:0.0.1 .
# setup env
export $(cat .env.local | xargs)

# run local containers
cd tests/manual
docker compose up
```
