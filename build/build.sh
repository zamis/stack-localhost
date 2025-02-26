#!/bin/bash
BASEDIR="$(dirname $(readlink -f $0))"

docker compose -f "$BASEDIR/docker-compose.build-localhost-ubuntu.yml" build
