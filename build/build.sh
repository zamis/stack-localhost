#!/bin/bash
BASEDIR="$(dirname $(readlink -f $0))"

docker compose -f "$BASEDIR/docker-compose.stack-localhost-build-ubuntu.yml" build
