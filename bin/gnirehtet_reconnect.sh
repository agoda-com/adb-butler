#!/usr/bin/env bash

ls /tmp/one*.pid | while read p; do
  echo ${p}
  kill -KILL `cat ${p}`
  rm -f ${p}
done

while true; do
  if [ "$GNIREHTET_ENABLED" = "true" ]; then
    adb devices | egrep 'e$' | awk '{ print $1 }' | while read d; do
          echo ${d}
          if [ ! -f /tmp/one_${d}.pid ]; then
              /gnirehtet_reconnect_one.sh ${d} &
              sleep 2
          fi
    done
  fi
  sleep 30
done
