#!/usr/bin/env bash

while true; do
  sleep 30
  if [ "$GNIREHTET_ENABLED" = "true" ]; then
    adb devices | egrep 'e$' | awk '{ print $1 }' | while read d; do
  	  echo $d
  	  echo -n | timeout -t 5 adb -s $d reverse localabstract:gnirehtet tcp:31416
  	  echo -n | timeout -t 10 adb -s $d shell am broadcast -a com.genymobile.gnirehtet.START -n com.genymobile.gnirehtet/.GnirehtetControlReceiver --esa dnsServers 10.120.1.123 &
    done
    wait
  fi
done
