#!/bin/bash
BASEDIR="$(dirname $(readlink -f $0))"
IMAGENAME=localhost/ubuntu

docker build --no-cache -f "$BASEDIR/Dockerfile" -t "$IMAGENAME" "$BASEDIR"
