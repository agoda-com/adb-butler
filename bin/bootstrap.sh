#!/usr/bin/env bash

if [ -z "$STF_PROVIDER_PUBLIC_IP" ]; then
  echo "parameter is missing: the address (with port) of your emulator, e.g. 10.0.0.1"
  echo "assuming non-emulator mode"
  sleep infinite &
  wait
else
  ip="$STF_PROVIDER_PUBLIC_IP"
  echo "Remote device url is $ip"

  monitor() {
    while true; do
      if [ $(adb -P 5037 devices | grep $ip | wc -l) -eq 0 ]; then
        echo "Initiating adb connection to $ip:10001"
        adb -P 5037 connect "$ip:10001"
        adbExitCode=$?
        if [ $adbExitCode -ne 0 ]; then
            echo "adb connect failed"
        else
          bootstrap
        fi
      fi
      sleep 1
    done
  }

  clean() {
    /clean.js
    exit 0
  }

  bootstrap() {
    echo "Initiating bootstrap"
    timeout -t 20 adb -s $ip install /root/.android/test-butler-app-1.3.1.apk
  }

  trap clean SIGINT
  sleep 5
  monitor
fi
