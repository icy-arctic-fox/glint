#!/usr/bin/env sh
set -e

screen=${SCREEN:-0}
width=${SCREEN_WIDTH:-1024}
height=${SCREEN_HEIGHT:-768}
depth=${SCREEN_DEPTH:-24}
xvfb-run --server-args="-screen ${screen} ${width}x${height}x${depth}" -e /dev/stderr "$@" | cat
