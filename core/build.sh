#!/bin/bash
BASEDIR="$(dirname $(readlink -f $0))"

docker compose down -f "$BASEDIR/docker-compose.stack-core-portainer.yml"
docker compose down -f "$BASEDIR/docker-compose.stack-core-proxy.yml"
docker compose down -f "$BASEDIR/docker-compose.yml"
docker compose up -f "$BASEDIR/docker-compose.yml"
docker compose up -f "$BASEDIR/docker-compose.yml"
docker compose up -f "$BASEDIR/docker-compose.stack-core-proxy.yml" -d
docker compose up -f "$BASEDIR/docker-compose.stack-core-portainer.yml" -d
