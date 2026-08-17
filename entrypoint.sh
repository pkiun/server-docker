#!/bin/sh
set -e

mkdir -p "$PUPY_WORKDIR"

mkfifo /tmp/pupy-stdin
tail -f /dev/null > /tmp/pupy-stdin &
tail_pid=$!

trap 'kill $tail_pid 2>/dev/null || true' EXIT INT TERM

exec pupysh --workdir "$PUPY_WORKDIR" -l $PUPY_LISTEN < /tmp/pupy-stdin