#!/usr/bin/env bash

adb -P 5037 kill-server
killall adb || echo ... and it is good
ps ax  |  grep -i 'stf provider' | grep -v grep  |  awk '{print $1}' | xargs kill
if [ ! -z "$STF_PROVIDER_PUBLIC_IP" ]; then
  /clean.js
fi
adb -a -P 5037 server nodaemon
