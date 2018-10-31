#!/usr/bin/env bash

if [ "$GNIREHTET_ENABLED" = "true" ]; then
  echo "Starting gnirehtet daemon"
  (cd /; exec gnirehtet autorun -d ${DNS_SERVER:=8.8.8.8})
fi
