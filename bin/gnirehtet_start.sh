#!/usr/bin/env bash

if [ "$GNIREHTET_ENABLED" = "true" ]; then
  echo "Starting gnirehtet daemon"
  (cd /; exec ./gnirehtet relay) || return
fi
