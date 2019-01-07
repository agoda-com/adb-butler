#!/usr/bin/env bash

if [ "$GNIREHTET_ENABLED" == "true" ]; then
  echo "Starting gnirehtet daemon"
  (cd /; exec ./gnirehtet relay) || return
else
  echo "gnirehtet daemon disabled"
  tail -f /dev/null
fi
