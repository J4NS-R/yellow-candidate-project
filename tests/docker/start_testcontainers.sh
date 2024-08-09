#!/bin/bash

set -e

if [ ! -f ./tests/docker/docker-compose.yaml ]; then
  echo "Please run this script in the project base directory"
  exit 1
fi

if [ ! -f .env.local ]; then
  echo "Please set up .env.local before spinning up docker containers"
  exit 1
fi

# Load env
export $(cat .env.local | xargs)

cd tests/docker

docker compose up -d --wait
