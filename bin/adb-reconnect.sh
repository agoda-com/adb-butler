#!/usr/bin/env bash

while read d
do
  if [ -z "$STF_PROVIDER_PUBLIC_IP" ]; then
    # real devices
    timeout -t 3 adb -s $d reboot
    timeout -t 3 adb -s $d reconnect
  else
    date > /tmp/reboot
  fi
done < "${1:-/dev/stdin}"
